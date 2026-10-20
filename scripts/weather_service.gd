extends Node
## Optional point-model data. No startup, background or location-tracking requests.
signal weather_changed
const Data = preload("res://scripts/earth_services.gd")
var weather: Dictionary = {}
var weather_status := "Choose a place, then request its weather."
var weather_pending: Dictionary = {}
var weather_request: HTTPRequest
var cache_path := "user://weather-v2.json"
var generation := 0
var loading := false
var last_request := -60000
var retrieved := ""
const MAX_AGE := 86400.0

func _ready() -> void:
    if not FileAccess.file_exists(cache_path): return
    var file := FileAccess.open(cache_path,FileAccess.READ)
    if not file or file.get_length() > 2097152: return
    var cached = Data.decode_json(file.get_as_text())
    if not cached is Dictionary or cached.get("version") != 2 or not cached.get("location") is Dictionary: return
    var parsed := parse_weather(cached.get("feed"), cached.location)
    if parsed.is_empty(): return
    var age := Time.get_unix_time_from_system() - Time.get_unix_time_from_datetime_string(parsed.utc.replace(" ","T"))
    if age > MAX_AGE or age < -3600.0:
        weather_status = "Saved weather has expired. Request fresh weather for a place."
        return
    weather = parsed
    retrieved = str(cached.get("retrieved","unknown")).left(40)
    weather_status = "Cached model estimate · retrieved %s UTC" % retrieved

func request_weather(place: Dictionary) -> void:
    if not Data.valid_coordinates(place.get("latitude"),place.get("longitude")): return
    if Time.get_ticks_msec() - last_request < 60000:
        weather_status = "Please wait one minute between weather requests. Previous data stays labeled by place."
        weather_changed.emit()
        return
    cancel_weather()
    last_request = Time.get_ticks_msec()
    weather_pending = place.duplicate(true)
    loading = true
    weather_status = "Requesting weather for %s…" % str(place.get("name","Location"))
    weather_changed.emit()
    weather_request = HTTPRequest.new()
    weather_request.timeout = 15
    weather_request.body_size_limit = 2097152
    weather_request.max_redirects = 0
    add_child(weather_request)
    var proxy := OS.get_environment("HTTPS_PROXY")
    if not proxy.is_empty():
        var host_port := proxy.get_slice("://",1).get_slice("/",0)
        if not "@" in host_port and host_port.count(":") == 1:
            weather_request.set_https_proxy(host_port.get_slice(":",0),int(host_port.get_slice(":",1)))
    weather_request.request_completed.connect(_weather_received.bind(generation))
    var url := "https://api.open-meteo.com/v1/forecast?latitude=%.4f&longitude=%.4f&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m&timezone=UTC&temperature_unit=celsius&wind_speed_unit=kmh" % [place.latitude,place.longitude]
    if weather_request.request(url,["User-Agent: LivingEarth3D/0.7.0 (+https://github.com/nortja/Living-earth-3d)"]) != OK:
        _weather_received(HTTPRequest.RESULT_CANT_CONNECT,0,PackedStringArray(),PackedByteArray(),generation)

func cancel_weather() -> void:
    generation += 1
    if is_instance_valid(weather_request):
        weather_request.cancel_request()
        weather_request.queue_free()
    weather_request = null
    if loading:
        loading = false
        weather_status = "Weather request canceled. " + ("No model data loaded." if weather.is_empty() else "Previous data retained for " + weather.name + ".")
        weather_changed.emit()

func _weather_received(result: int, status: int, _headers: PackedStringArray, bytes: PackedByteArray, token: int) -> void:
    if token != generation: return
    loading = false
    if is_instance_valid(weather_request): weather_request.queue_free()
    weather_request = null
    var feed = Data.decode_json(bytes.get_string_from_utf8())
    var parsed := parse_weather(feed,weather_pending)
    if result != HTTPRequest.RESULT_SUCCESS or status != 200 or bytes.size() > 2097152 or parsed.is_empty():
        weather_status = "Weather unavailable for %s. %s" % [str(weather_pending.get("name","this place")),"No model data loaded." if weather.is_empty() else "Previous model data retained for " + weather.name + "."]
    else:
        weather = parsed
        retrieved = Time.get_datetime_string_from_system(true).replace("T"," ")
        weather_status = "Retrieved %s UTC · Open-Meteo · model estimate" % retrieved
        var file := FileAccess.open(cache_path,FileAccess.WRITE)
        if file: file.store_string(JSON.stringify({"version":2,"location":weather_pending,"feed":feed,"retrieved":retrieved}))
    weather_changed.emit()

func freshness() -> String:
    if weather.is_empty(): return ""
    var age := Time.get_unix_time_from_system() - Time.get_unix_time_from_datetime_string(weather.utc.replace(" ","T"))
    if age < -3600.0: return "Model time is ahead of this device clock. Check the clock."
    if age > MAX_AGE: return "Expired model data (over 24 hours old). Refresh before using."
    if age > 5400: return "Stale model data (over 90 minutes old)."
    return "Recent model estimate; conditions can differ locally."
static func parse_weather(feed: Variant, location: Dictionary) -> Dictionary:
    if not feed is Dictionary or not feed.get("current") is Dictionary or not feed.get("current_units") is Dictionary:
        return {}
    if not Data.valid_coordinates(location.get("latitude"), location.get("longitude")):
        return {}
    var current: Dictionary = feed.current
    var units: Dictionary = feed.current_units
    if units.get("temperature_2m") != "°C" or units.get("wind_speed_10m") != "km/h" or units.get("relative_humidity_2m") != "%":
        return {}
    for key in ["temperature_2m", "wind_speed_10m", "relative_humidity_2m", "weather_code"]:
        var value = current.get(key)
        if not (value is int or value is float) or not is_finite(float(value)): return {}
    if current.relative_humidity_2m < 0 or current.relative_humidity_2m > 100 or current.wind_speed_10m < 0 or current.temperature_2m < -100 or current.temperature_2m > 70: return {}
    if int(current.weather_code) != current.weather_code or int(current.weather_code) not in [0, 1, 2, 3, 45, 48, 51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 71, 73, 75, 77, 80, 81, 82, 85, 86, 95, 96, 99]: return {}
    var time = current.get("time")
    if not time is String or not valid_model_time(time) or feed.get("utc_offset_seconds") != 0: return {}
    return {"name": str(location.get("name", "Location")).left(160), "latitude": location.latitude, "longitude": location.longitude, "temperature": float(current.temperature_2m), "wind": float(current.wind_speed_10m), "humidity": float(current.relative_humidity_2m), "code": int(current.weather_code), "utc": (time + ":00" if time.length() == 16 else time).replace("T", " ")}

static func weather_name(code: int) -> String:
    if code == 0: return "Clear sky"
    if code <= 3: return "Cloud cover"
    if code in [45, 48]: return "Fog"
    if code in [51, 53, 55, 56, 57]: return "Drizzle"
    if code in [61, 63, 65, 66, 67, 80, 81, 82]: return "Rain"
    if code in [71, 73, 75, 77, 85, 86]: return "Snow"
    return "Thunderstorm"

static func valid_model_time(value: String) -> bool:
    var pattern := RegEx.new()
    pattern.compile("^([0-9]{4})-([0-9]{2})-([0-9]{2})T([0-9]{2}):([0-9]{2})(:[0-9]{2})?$")
    var match_time := pattern.search(value)
    if not match_time: return false
    var year := int(match_time.get_string(1))
    var month := int(match_time.get_string(2))
    var day := int(match_time.get_string(3))
    if year < 1900 or year > 3000 or month < 1 or month > 12: return false
    var days := [31, 29 if year % 4 == 0 and (year % 100 != 0 or year % 400 == 0) else 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    return day >= 1 and day <= days[month - 1] and int(match_time.get_string(4)) < 24 and int(match_time.get_string(5)) < 60 and (value.length() == 16 or int(value.right(2)) < 60)
