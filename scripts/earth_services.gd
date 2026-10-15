extends Node
## User-requested public data only. Offline maps never imply a live connection.
signal earthquakes_changed
signal search_changed
var earthquakes: Array = []
var results: Array = []
var quake_status := "Not loaded · USGS, periodically updated"
var search_status := "Search the offline atlas, coordinates, or request worldwide search."
var quake_request: HTTPRequest
var search_request: HTTPRequest
var cache_path := "user://earthquakes-v1.json"
var last_search := -2000

func _ready() -> void:
    quake_request = HTTPRequest.new()
    search_request = HTTPRequest.new()
    for request in [quake_request, search_request]:
        request.timeout = 12
        request.body_size_limit = 4 * 1024 * 1024
        add_child(request)
    quake_request.request_completed.connect(_quakes_received)
    search_request.request_completed.connect(_search_received)
    var cached = decode_json(FileAccess.get_file_as_string(cache_path)) if FileAccess.file_exists(cache_path) else null
    if cached is Dictionary and cached.get("version") == 1 and cached.get("feed") is Dictionary:
        earthquakes = parse_quakes(cached.feed)
        quake_status = "Cached · retrieved %s UTC · USGS" % cached.get("retrieved", "unknown")

static func valid_coordinates(latitude: Variant, longitude: Variant) -> bool:
    return (latitude is float or latitude is int) and (longitude is float or longitude is int) and is_finite(float(latitude)) and is_finite(float(longitude)) and abs(float(latitude)) <= 90 and abs(float(longitude)) <= 180

static func parse_quakes(feed: Variant) -> Array:
    var parsed: Array = []
    if not feed is Dictionary or not feed.get("features") is Array:
        return parsed
    for feature in feed.features:
        if not feature is Dictionary:
            continue
        var geometry = feature.get("geometry")
        var properties = feature.get("properties")
        if not geometry is Dictionary or not properties is Dictionary or geometry.get("type") != "Point":
            continue
        var coordinates = geometry.get("coordinates")
        var magnitude = properties.get("mag")
        if not coordinates is Array or coordinates.size() < 2 or not valid_coordinates(coordinates[1], coordinates[0]) or not (magnitude is float or magnitude is int) or not is_finite(float(magnitude)):
            continue
        var timestamp = properties.get("time")
        if not (timestamp is float or timestamp is int) or not is_finite(float(timestamp)) or timestamp < 0 or timestamp > 253402300799000:
            continue
        parsed.append({"name": str(properties.get("place", "Earthquake")), "latitude": float(coordinates[1]), "longitude": float(coordinates[0]), "magnitude": float(magnitude), "utc": Time.get_datetime_string_from_unix_time(int(timestamp / 1000.0)).replace("T", " ")})
        if parsed.size() >= 100:
            break
    return parsed

func refresh_quakes() -> void:
    if quake_request.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
        return
    quake_status = "Fetching USGS M2.5+ · past day…"
    earthquakes_changed.emit()
    if quake_request.request("https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/2.5_day.geojson") != OK:
        _quake_failure()

func _quake_failure() -> void:
    quake_status = "Unavailable · " + ("cached results retained; see event UTC times" if not earthquakes.is_empty() else "no cached data")
    earthquakes_changed.emit()

func _quakes_received(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
    var feed = decode_json(body.get_string_from_utf8())
    if result != HTTPRequest.RESULT_SUCCESS or code != 200 or not feed is Dictionary or not feed.get("features") is Array:
        _quake_failure()
        return
    var parsed := parse_quakes(feed)
    if not feed.features.is_empty() and parsed.is_empty():
        _quake_failure()
        return
    earthquakes = parsed
    var retrieved := Time.get_datetime_string_from_system(true).replace("T", " ")
    quake_status = "Updated %s UTC · USGS · periodic feed" % retrieved
    var file := FileAccess.open(cache_path, FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify({"version": 1, "retrieved": retrieved, "feed": feed}))
    earthquakes_changed.emit()

func search_worldwide(query: String) -> void:
    if query.strip_edges().length() < 2 or query.length() > 200:
        search_status = "Enter 2–200 characters."
        search_changed.emit()
        return
    if Time.get_ticks_msec() - last_search < 1100 or search_request.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
        return
    last_search = Time.get_ticks_msec()
    search_status = "Searching OpenStreetMap…"
    search_changed.emit()
    var error := search_request.request("https://nominatim.openstreetmap.org/search?format=jsonv2&limit=6&q=" + query.uri_encode(), ["User-Agent: LivingEarth3D/0.6.0 (+https://github.com/nortja/Living-earth-3d)", "Accept: application/json"])
    if error != OK:
        _search_received(HTTPRequest.RESULT_CANT_CONNECT, 0, PackedStringArray(), PackedByteArray())

func _search_received(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
    var response = decode_json(body.get_string_from_utf8())
    results.clear()
    if result != HTTPRequest.RESULT_SUCCESS or code != 200 or not response is Array:
        search_status = "Worldwide search unavailable · offline atlas still works."
    else:
        for place in response:
            if not place is Dictionary or not place.get("lat") is String or not place.get("lon") is String or not place.lat.is_valid_float() or not place.lon.is_valid_float():
                continue
            if valid_coordinates(float(place.lat), float(place.lon)):
                results.append({"name": str(place.get("display_name", "Place")).left(180), "latitude": float(place.lat), "longitude": float(place.lon)})
        search_status = "%d results · © OpenStreetMap contributors · approximate globe locations" % results.size()
    search_changed.emit()

static func decode_json(text: String) -> Variant:
    var parser := JSON.new()
    return parser.data if parser.parse(text) == OK else null
