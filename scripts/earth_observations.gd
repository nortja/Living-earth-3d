extends Node
signal weather_changed
signal camera_checked
var weather: Dictionary = {}
var weather_status := "Not loaded · Open-Meteo model estimates"
var weather_pending: Dictionary = {}
var weather_request: HTTPRequest
var camera_request: HTTPRequest
var camera_id := ""
var camera_checks: Dictionary = {}
var cache_path := "user://weather-v1.json"
const Data = preload("res://scripts/earth_services.gd")

func _ready() -> void:
    weather_request = HTTPRequest.new()
    camera_request = HTTPRequest.new()
    for request in [weather_request, camera_request]:
        request.timeout = 12
        request.body_size_limit = 2 * 1024 * 1024
        add_child(request)
    weather_request.request_completed.connect(_weather_received)
    camera_request.request_completed.connect(_camera_received)
    if FileAccess.file_exists(cache_path):
        var cached = Data.decode_json(FileAccess.get_file_as_string(cache_path))
        if cached is Dictionary and cached.get("version") == 1 and cached.get("location") is Dictionary:
            weather = parse_weather(cached.get("feed"), cached.location)
            if not weather.is_empty():
                weather_status = "Cached · retrieved %s UTC · %s" % [str(cached.get("retrieved", "unknown")), weather.name]

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
    return {"name": str(location.get("name", "Location")).left(160), "latitude": location.latitude, "longitude": location.longitude, "temperature": float(current.temperature_2m), "wind": float(current.wind_speed_10m), "humidity": float(current.relative_humidity_2m), "code": int(current.weather_code), "utc": time.replace("T", " ")}

static func weather_name(code: int) -> String:
    if code == 0: return "Clear sky"
    if code <= 3: return "Cloud cover"
    if code in [45, 48]: return "Fog"
    if code in [51, 53, 55, 56, 57]: return "Drizzle"
    if code in [61, 63, 65, 66, 67, 80, 81, 82]: return "Rain"
    if code in [71, 73, 75, 77, 85, 86]: return "Snow"
    return "Thunderstorm"

func request_weather(location: Dictionary) -> void:
    if not Data.valid_coordinates(location.get("latitude"), location.get("longitude")): return
    if weather_request.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED: return
    weather_pending = location.duplicate(true)
    weather_status = "Requesting weather for %s…" % str(location.get("name", "Location"))
    weather_changed.emit()
    var url := "https://api.open-meteo.com/v1/forecast?latitude=%.4f&longitude=%.4f&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m&timezone=UTC&temperature_unit=celsius&wind_speed_unit=kmh" % [location.latitude, location.longitude]
    if weather_request.request(url, ["User-Agent: LivingEarth3D/0.6.0"]) != OK:
        _weather_received(HTTPRequest.RESULT_CANT_CONNECT, 0, PackedStringArray(), PackedByteArray())

func _weather_received(result: int, status: int, _headers: PackedStringArray, bytes: PackedByteArray) -> void:
    var feed = Data.decode_json(bytes.get_string_from_utf8())
    var parsed := parse_weather(feed, weather_pending)
    if result != HTTPRequest.RESULT_SUCCESS or status != 200 or parsed.is_empty():
        weather_status = "Unavailable for %s · %s" % [str(weather_pending.get("name", "requested place")), "no cached data" if weather.is_empty() else "retaining cached data for " + weather.name]
    else:
        weather = parsed
        var retrieved := Time.get_datetime_string_from_system(true).replace("T", " ")
        weather_status = "Updated %s UTC · Open-Meteo · model estimate" % retrieved
        var file := FileAccess.open(cache_path, FileAccess.WRITE)
        if file: file.store_string(JSON.stringify({"version": 1, "location": weather_pending, "feed": feed, "retrieved": retrieved}))
    weather_changed.emit()

func check_camera(venue: Dictionary, catalog: Array) -> void:
    # Only a catalog-owned HTTPS page can be requested. A successful page is not a live-feed check.
    if venue not in catalog or not str(venue.get("url", "")).begins_with("https://"): return
    if camera_request.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED: return
    camera_id = str(venue.id)
    camera_checks[camera_id] = "Checking provider page…"
    camera_checked.emit()
    if camera_request.request(venue.url, ["User-Agent: LivingEarth3D/0.6.0"]) != OK:
        _camera_received(HTTPRequest.RESULT_CANT_CONNECT, 0, PackedStringArray(), PackedByteArray())

func _camera_received(result: int, status: int, _headers: PackedStringArray, _bytes: PackedByteArray) -> void:
    var utc := Time.get_datetime_string_from_system(true).replace("T", " ")
    camera_checks[camera_id] = ("Provider page reached · stream status unverified" if result == HTTPRequest.RESULT_SUCCESS and status == 200 else "Provider page unavailable · stream status unknown") + "\nChecked %s UTC" % utc
    camera_checked.emit()

func cancel_requests() -> void:
    if weather_request.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
        weather_request.cancel_request()
        weather_status = "Request canceled · " + ("no data loaded" if weather.is_empty() else "cached data retained for " + weather.name)
        weather_changed.emit()
    if camera_request.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
        camera_request.cancel_request()
        camera_checks[camera_id] = "Page check canceled · stream status unknown"
        camera_checked.emit()

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
