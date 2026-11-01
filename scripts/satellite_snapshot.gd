extends Node
## On-request dated observations. No startup, automatic or screensaver downloads.
signal changed
const WIDTH := 2048
const HEIGHT := 1024
const MAX_BYTES := 16777216
const COOLDOWN_MS := 60000
const RECENT_DAYS := 7
const LAYER := "VIIRS_NOAA20_CorrectedReflectance_TrueColor"
var app: Node3D
var texture: Texture2D
var enabled := false
var suspended := false
var loading := false
var observed_date := ""
var pending_date := ""
var selected_days_ago := 1
var retrieved := ""
var status := "Choose a recent UTC day, then Load its NASA mosaic. Yesterday is selected by default."
var request: HTTPRequest
var generation := 0
var last_attempt := -COOLDOWN_MS

func setup(owner_app: Node3D) -> void:
    app = owner_app
    set_process(false)

static func previous_utc_day(unix_time: float) -> String:
    return recent_utc_date(unix_time,1)

static func recent_utc_date(unix_time: float, days_ago: int) -> String:
    if days_ago < 1 or days_ago > RECENT_DAYS: return ""
    return Time.get_date_string_from_unix_time(int(unix_time) - days_ago*86400)

func select_days_ago(value: int) -> void:
    if loading or value < 1 or value > RECENT_DAYS: return
    selected_days_ago = value
    changed.emit()

static func request_url(date: String) -> String:
    return "https://gibs.earthdata.nasa.gov/wms/epsg4326/best/wms.cgi?SERVICE=WMS&VERSION=1.1.1&REQUEST=GetMap&LAYERS=%s&STYLES=&SRS=EPSG:4326&BBOX=-180,-90,180,90&WIDTH=2048&HEIGHT=1024&FORMAT=image/png&TRANSPARENT=TRUE&TIME=%s" % [LAYER,date.uri_encode()]

func refresh() -> void:
    if app.screensaver_mode or suspended or loading: return
    if Time.get_ticks_msec() - last_attempt < COOLDOWN_MS:
        status = "Wait one minute between satellite requests. Previous mosaic stays dated."
        changed.emit()
        return
    if app.observed_weather: app.observed_weather.set_enabled(false)
    cancel()
    pending_date = recent_utc_date(Time.get_unix_time_from_system(),selected_days_ago)
    if pending_date.is_empty():
        status = "Choose one of the previous seven UTC days. No request was sent."
        changed.emit()
        return
    last_attempt = Time.get_ticks_msec()
    loading = true
    status = "Requesting NASA NOAA-20 mosaic for %s UTC…" % pending_date
    changed.emit()
    request = HTTPRequest.new()
    request.timeout = 30
    request.body_size_limit = MAX_BYTES
    request.max_redirects = 0
    add_child(request)
    var proxy := OS.get_environment("HTTPS_PROXY")
    if not proxy.is_empty():
        var host_port := proxy.get_slice("://",1).get_slice("/",0)
        if not "@" in host_port and host_port.count(":") == 1:
            request.set_https_proxy(host_port.get_slice(":",0),int(host_port.get_slice(":",1)))
    request.request_completed.connect(_received.bind(generation))
    if request.request(request_url(pending_date),["User-Agent: LivingEarth3D/0.15.0 (+https://github.com/nortja/Living-earth-3d)"]) != OK:
        _received(HTTPRequest.RESULT_CANT_CONNECT,0,PackedStringArray(),PackedByteArray(),generation)

static func valid_png_size(bytes: PackedByteArray) -> bool:
    if bytes.size() < 33 or bytes.size() > MAX_BYTES: return false
    if bytes.slice(0,8) != PackedByteArray([137,80,78,71,13,10,26,10]) or bytes.slice(12,16).get_string_from_ascii() != "IHDR": return false
    var width := (int(bytes[16])<<24) | (int(bytes[17])<<16) | (int(bytes[18])<<8) | int(bytes[19])
    var height := (int(bytes[20])<<24) | (int(bytes[21])<<16) | (int(bytes[22])<<8) | int(bytes[23])
    return width == WIDTH and height == HEIGHT

static func has_observations(image: Image) -> bool:
    # A fully blank/error tile is unavailable, never a successful Earth observation.
    var samples := 0
    for y in range(16):
        for x in range(32):
            var color := image.get_pixel((x*image.get_width())/32,(y*image.get_height())/16)
            if color.a > 0.0 and maxf(color.r,maxf(color.g,color.b)) > 0.02: samples += 1
    return samples >= 8

func _received(result: int, code: int, _headers: PackedStringArray, bytes: PackedByteArray, token: int) -> void:
    if token != generation or suspended or app.screensaver_mode: return
    loading = false
    if is_instance_valid(request): request.queue_free()
    request = null
    var decoded := Image.new()
    if result != HTTPRequest.RESULT_SUCCESS or code != 200 or not valid_png_size(bytes):
        _unavailable()
        return
    if decoded.load_png_from_buffer(bytes) != OK or decoded.get_size() != Vector2i(WIDTH,HEIGHT) or not has_observations(decoded):
        _unavailable()
        return
    texture = ImageTexture.create_from_image(decoded)
    observed_date = pending_date
    retrieved = Time.get_datetime_string_from_system(true) + "Z"
    enabled = true
    status = "NASA GIBS · NOAA-20 / VIIRS · daily mosaic: %s UTC\nRetrieved %s\nBlack areas have no imagery. Multiple passes form this dated mosaic; it is not live." % [observed_date,retrieved]
    apply_view()
    changed.emit()

func _unavailable() -> void:
    status = "Satellite mosaic unavailable for %s. " % pending_date
    status += "Offline Earth remains available." if texture == null else "Previous mosaic retained: %s UTC." % observed_date
    changed.emit()

func cancel() -> void:
    generation += 1
    if is_instance_valid(request):
        request.cancel_request()
        request.queue_free()
    request = null
    if loading:
        loading = false
        status = "Satellite request canceled. " + ("Offline Earth remains available." if texture == null else "Previous mosaic retained: %s UTC." % observed_date)
        changed.emit()

func set_enabled(value: bool) -> void:
    if value and app.observed_weather and app.observed_weather.enabled: app.observed_weather.set_enabled(false)
    if not value: cancel()
    enabled = value and texture != null
    apply_view()
    changed.emit()

func set_suspended(value: bool) -> void:
    suspended = value
    if value: cancel()
    apply_view()
    changed.emit()

func apply_view() -> void:
    var showing: bool = enabled and texture != null and not suspended and not app.screensaver_mode
    app.earth_material.set_shader_parameter("satellite_view",showing)
    if texture != null: app.earth_material.set_shader_parameter("satellite_map",texture)
    app.visuals.clouds.visible = app.visuals.clouds_enabled and not showing
    app.info.text = "NASA mosaic · %s" % observed_date if showing else "Drag to orbit · Scroll to zoom"
    if app.observed_weather: app.observed_weather.apply_view()
