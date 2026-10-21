extends Node
## Explicitly requested model estimates at a fixed public set of places; no location tracking.
signal changed
const Weather = preload("res://scripts/weather_service.gd")
const Data = preload("res://scripts/earth_services.gd")
const MAX_AGE := 86400.0
const STALE_AGE := 5400.0
const COOLDOWN_MS := 300000
var app: Node3D
var places: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/weather_places.json"))
var points: Array = []
var enabled := false
var suspended := false
var loading := false
var status := "Load model points to compare weather around Earth."
var retrieved := ""
var request: HTTPRequest
var generation := 0
var last_attempt := -COOLDOWN_MS
var cache_path := "user://weather-points-v1.json"
var markers: Dictionary = {}
var marker_root: Node3D
var age_tick := 0.0

func setup(owner_app: Node3D) -> void:
    app = owner_app
    marker_root = Node3D.new()
    app.earth.add_child(marker_root)
    marker_root.hide()
    set_process(false)
    _restore_cache()
    get_window().focus_entered.connect(_focus_refresh)

func _focus_refresh() -> void:
    _update_markers()
    changed.emit()

func _exit_tree() -> void:
    if is_instance_valid(marker_root) and not marker_root.is_queued_for_deletion(): marker_root.queue_free()

func _process(delta: float) -> void:
    age_tick += delta
    if age_tick >= 60.0:
        age_tick = 0.0
        _update_markers()
        changed.emit()

func refresh() -> void:
    if app.screensaver_mode or suspended or loading: return
    if Time.get_ticks_msec()-last_attempt < COOLDOWN_MS:
        status = "Wait five minutes between model-layer requests. Previous points remain labelled."
        changed.emit()
        return
    cancel()
    last_attempt = Time.get_ticks_msec()
    loading = true
    status = "Requesting sixteen public model points…"
    changed.emit()
    request = HTTPRequest.new()
    request.timeout = 20
    request.body_size_limit = 2097152
    request.max_redirects = 0
    add_child(request)
    var proxy := OS.get_environment("HTTPS_PROXY")
    if not proxy.is_empty():
        var host_port := proxy.get_slice("://",1).get_slice("/",0)
        if not "@" in host_port and host_port.count(":") == 1: request.set_https_proxy(host_port.get_slice(":",0),int(host_port.get_slice(":",1)))
    request.request_completed.connect(_received.bind(generation))
    if request.request(request_url(),["User-Agent: LivingEarth3D/0.12.0 (+https://github.com/nortja/Living-earth-3d)"]) != OK:
        _received(HTTPRequest.RESULT_CANT_CONNECT,0,PackedStringArray(),PackedByteArray(),generation)

func request_url() -> String:
    var latitudes := PackedStringArray()
    var longitudes := PackedStringArray()
    for place in places:
        latitudes.append("%.4f" % float(place.latitude))
        longitudes.append("%.4f" % float(place.longitude))
    return "https://api.open-meteo.com/v1/forecast?latitude=%s&longitude=%s&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m&timezone=UTC&temperature_unit=celsius&wind_speed_unit=kmh&forecast_days=1" % [",".join(latitudes),",".join(longitudes)]

func cancel() -> void:
    generation += 1
    if is_instance_valid(request):
        request.cancel_request()
        request.queue_free()
    request = null
    if loading:
        loading = false
        status = "Model-layer request cancelled; previous points retained."
        changed.emit()

func set_suspended(value: bool) -> void:
    suspended = value
    if value: cancel()
    _update_markers()

func set_enabled(value: bool) -> void:
    enabled = value and not points.is_empty()
    _update_markers()
    changed.emit()

static func age(point: Dictionary, now: float) -> float:
    return now-Time.get_unix_time_from_datetime_string(str(point.get("utc", "")).replace(" ","T"))

static func parse_batch(feed: Variant, locations: Array, now: float) -> Array:
    var result: Array = []
    if not feed is Array or feed.size() != locations.size() or locations.size() != 16: return result
    for index in range(locations.size()):
        var row = feed[index]
        var place: Dictionary = locations[index]
        if not row is Dictionary or row.get("location_id",index) != index: continue
        if not Data.valid_coordinates(row.get("latitude"),row.get("longitude")): continue
        if absf(float(row.latitude)-float(place.latitude)) > 1.0 or absf(wrapf(float(row.longitude)-float(place.longitude),-180,180)) > 1.0: continue
        var parsed := Weather.parse_weather(row,place)
        if parsed.is_empty(): continue
        var model_age := age(parsed,now)
        if model_age < -3600.0 or model_age > MAX_AGE: continue
        parsed["location_index"] = index
        result.append(parsed)
    return result

func _received(result: int, code: int, _headers: PackedStringArray, bytes: PackedByteArray, token: int) -> void:
    if token != generation or suspended or app.screensaver_mode: return
    loading = false
    if is_instance_valid(request): request.queue_free()
    request = null
    var feed = Data.decode_json(bytes.get_string_from_utf8()) if bytes.size() <= 2097152 else null
    var parsed := parse_batch(feed,places,Time.get_unix_time_from_system())
    if result != HTTPRequest.RESULT_SUCCESS or code != 200 or parsed.is_empty():
        status = "Model layer unavailable. " + ("No points loaded." if points.is_empty() else "Previous model points retained with their original times.")
    else:
        points = parsed
        retrieved = Time.get_datetime_string_from_system(true).replace("T"," ")
        status = "Retrieved %s UTC · %d / 16 Open-Meteo model points" % [retrieved,points.size()]
        _rebuild_markers()
        enabled = true
        var file := FileAccess.open(cache_path,FileAccess.WRITE)
        if file: file.store_string(JSON.stringify({"version":1,"dataset_sha256":FileAccess.get_sha256("res://data/weather_places.json"),"retrieved":retrieved,"feed":feed}))
    _update_markers()
    changed.emit()

func _restore_cache() -> void:
    if not FileAccess.file_exists(cache_path): return
    var file := FileAccess.open(cache_path,FileAccess.READ)
    if not file or file.get_length() > 2097152: return
    var cache = Data.decode_json(file.get_as_text())
    if not cache is Dictionary or cache.get("version") != 1 or cache.get("dataset_sha256") != FileAccess.get_sha256("res://data/weather_places.json"): return
    points = parse_batch(cache.get("feed"),places,Time.get_unix_time_from_system())
    if points.is_empty():
        status = "Saved model points have expired or are invalid. Load the layer again."
        return
    retrieved = str(cache.get("retrieved","unknown")).left(40)
    status = "Cached model points · retrieved %s UTC · hidden until enabled" % retrieved
    _rebuild_markers()

static func temperature_color(celsius: float, stale := false) -> Color:
    if stale: return Color("778391")
    if celsius <= 0: return Color("53b7ff")
    if celsius <= 15: return Color("51d4bd")
    if celsius <= 25: return Color("f6c85f")
    return Color("ff7f66")

static func surface_position(latitude: float, longitude: float) -> Vector3:
    var lat := deg_to_rad(latitude)
    var lon := deg_to_rad(longitude)+PI
    return Vector3(sin(lon)*cos(lat),sin(lat),cos(lon)*cos(lat))*1.045

func _rebuild_markers() -> void:
    for child in marker_root.get_children():
        marker_root.remove_child(child)
        child.queue_free()
    markers.clear()
    var mesh := SphereMesh.new()
    mesh.radius = 0.014
    mesh.height = 0.028
    mesh.radial_segments = 12
    mesh.rings = 6
    for point in points:
        var marker := MeshInstance3D.new()
        marker.mesh = mesh
        marker.position = surface_position(point.latitude,point.longitude)
        var material := StandardMaterial3D.new()
        material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
        marker.material_override = material
        marker_root.add_child(marker)
        markers[int(point.location_index)] = marker

func _update_markers() -> void:
    if not is_instance_valid(marker_root): return
    marker_root.visible = enabled and not suspended and not app.screensaver_mode
    var now := Time.get_unix_time_from_system()
    for point in points:
        var marker: MeshInstance3D = markers.get(int(point.location_index))
        if not marker: continue
        var model_age := age(point,now)
        marker.visible = model_age <= MAX_AGE and model_age >= -3600.0
        marker.material_override.albedo_color = temperature_color(point.temperature,model_age > STALE_AGE)
    set_process(marker_root.visible)

func temperature_text(point: Dictionary) -> String:
    var imperial: bool = app.preferences.get_value("weather","imperial",true)
    return "%.0f°F" % (float(point.temperature)*1.8+32.0) if imperial else "%.0f°C" % float(point.temperature)

func point_label(point: Dictionary) -> String:
    var model_age := age(point,Time.get_unix_time_from_system())
    var freshness := "expired" if model_age > MAX_AGE or model_age < -3600 else ("stale" if model_age > STALE_AGE else "model")
    return "%s · %s · %s" % [point.name,temperature_text(point),freshness]

func visit(index: int) -> bool:
    if index < 0 or index >= points.size(): return false
    var point: Dictionary = points[index]
    var place: Dictionary = places[int(point.location_index)].duplicate(true)
    var model_age := age(point,Time.get_unix_time_from_system())
    var freshness := "Expired" if model_age > MAX_AGE or model_age < -3600 else ("Stale" if model_age > STALE_AGE else "Point")
    place["note"] = "%s model snapshot at selection: %s · %s.\nModel time: %s UTC.\nOpen-Meteo · local conditions can differ. This is a point estimate, not satellite imagery." % [freshness,temperature_text(point),Weather.weather_name(int(point.code)),point.utc]
    place["source"] = "https://open-meteo.com/"
    return app.fly_to_location(place)

func pick(screen_position: Vector2) -> int:
    if not marker_root.visible: return -1
    var best := -1
    var best_distance: float = 12.0 * app.interface.display_scale
    for index in range(points.size()):
        var marker: MeshInstance3D = markers.get(int(points[index].location_index))
        if not marker or not marker.visible or app.camera.is_position_behind(marker.global_position): continue
        var earth_center: Vector3 = app.earth.global_position
        var camera_offset: Vector3 = app.camera.global_position-earth_center
        var ray: Vector3 = marker.global_position-app.camera.global_position
        var length_squared := ray.length_squared()
        var b := camera_offset.dot(ray)
        var discriminant := b*b-length_squared*(camera_offset.length_squared()-1.0)
        if discriminant >= 0.0:
            var intersection := (-b-sqrt(discriminant))/length_squared
            if intersection > 0.0 and intersection < 1.0: continue
        var distance: float = app.camera.unproject_position(marker.global_position).distance_to(screen_position)
        if distance < best_distance:
            best = index
            best_distance = distance
    return best
