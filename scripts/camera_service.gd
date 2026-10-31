extends Node
## Optional, user-selected periodic camera images. Never substitutes a bundled photo.
signal changed
var selected: Dictionary = {}
var image: Texture2D
var status := "Choose a camera."
var active := false
var automatic := true
var last_failed := false
var loading := false
var elapsed := 0.0
var consecutive_failures := 0
var refresh_interval := 60.0
var base_interval := 60.0
var max_texture_edge := 4096
var generation := 0
var request: HTTPRequest
var last_attempt := -10000
var retrieved := ""
var digest := ""
var etag := ""
var last_modified := ""
var unchanged_since := 0.0
const IMAGE_ORIGIN := "https://www.nps.gov/webcams-yell/"

func _process(delta: float) -> void:
    if not active or not automatic or loading or get_window().mode == Window.MODE_MINIMIZED: return
    elapsed += delta
    if elapsed >= refresh_interval: refresh()

func open(venue: Dictionary, start_request := true) -> void:
    stop()
    selected = venue.duplicate()
    image = null
    retrieved = ""
    digest = ""
    etag = ""
    last_modified = ""
    consecutive_failures = 0
    base_interval = clampf(float(venue.get("image_interval_seconds",60.0)),60.0,1800.0)
    refresh_interval = base_interval
    last_failed = false
    active = true
    last_attempt = -10000
    status = "Waiting to retrieve camera image…"
    if start_request: refresh()

func stop() -> void:
    active = false
    loading = false
    elapsed = 0.0
    generation += 1
    if is_instance_valid(request):
        request.cancel_request()
        request.queue_free()
    request = null

func refresh() -> void:
    if not active or loading or Time.get_ticks_msec() - last_attempt < 2000: return
    var url: String = selected.get("image_url", "")
    if not valid_image_url(url):
        status = "This source opens on its official website."
        changed.emit()
        return
    last_attempt = Time.get_ticks_msec()
    elapsed = 0.0
    loading = true
    status = "Loading camera image…" if image == null else "Refreshing… previous image remains visible."
    changed.emit()
    generation += 1
    request = HTTPRequest.new()
    request.timeout = 18.0
    request.body_size_limit = 8388608
    request.max_redirects = 3
    add_child(request)
    var proxy := OS.get_environment("HTTPS_PROXY")
    if not proxy.is_empty():
        var host_port := proxy.get_slice("://", 1).get_slice("/", 0)
        if not "@" in host_port and host_port.count(":") == 1:
            request.set_https_proxy(host_port.get_slice(":", 0), int(host_port.get_slice(":", 1)))
    request.request_completed.connect(_received.bind(generation))
    if request.request(url, request_headers()) != OK:
        _received(HTTPRequest.RESULT_CANT_CONNECT, 0, PackedStringArray(), PackedByteArray(), generation)

func request_headers() -> PackedStringArray:
    var headers := PackedStringArray(["User-Agent: LivingEarth3D/0.13.1 (+https://github.com/nortja/Living-earth-3d)","Cache-Control: no-cache"])
    if image != null and not digest.is_empty() and valid_etag(etag):
        headers.append("If-None-Match: " + etag)
    return headers

static func valid_etag(value: String) -> bool:
    if value.length() > 256: return false
    var opaque := value.trim_prefix("W/")
    if opaque.length() < 2 or not opaque.begins_with('"') or not opaque.ends_with('"'): return false
    for index in range(1,opaque.length()-1):
        var character := opaque.unicode_at(index)
        if character < 33 or character == 34 or character > 126: return false
    return true

static func jpeg_dimensions(bytes: PackedByteArray) -> Vector2i:
    if bytes.size() < 4 or bytes.size() > 8388608 or bytes[0] != 255 or bytes[1] != 216: return Vector2i.ZERO
    var offset := 2
    while offset < bytes.size():
        if bytes[offset] != 255: return Vector2i.ZERO
        while offset < bytes.size() and bytes[offset] == 255: offset += 1
        if offset >= bytes.size(): return Vector2i.ZERO
        var marker := int(bytes[offset])
        offset += 1
        if marker == 217 or marker == 218 or marker == 0: return Vector2i.ZERO
        if marker == 1 or (marker >= 208 and marker <= 215): continue
        if offset+2 > bytes.size(): return Vector2i.ZERO
        var length := (int(bytes[offset])<<8) | int(bytes[offset+1])
        if length < 2 or offset+length > bytes.size(): return Vector2i.ZERO
        if marker in [192,193,194,195,197,198,199,201,202,203,205,206,207]:
            if length < 8: return Vector2i.ZERO
            var height := (int(bytes[offset+3])<<8) | int(bytes[offset+4])
            var width := (int(bytes[offset+5])<<8) | int(bytes[offset+6])
            return Vector2i(width,height) if width > 0 and height > 0 and width <= 4096 and height <= 4096 else Vector2i.ZERO
        offset += length
    return Vector2i.ZERO

func _source_metadata(headers: PackedStringArray, reset: bool) -> void:
    if reset:
        etag = ""
        last_modified = ""
    for header in headers:
        if header.to_lower().begins_with("etag:"):
            var value := header.substr(5).strip_edges()
            if valid_etag(value): etag = value
        elif header.to_lower().begins_with("last-modified:"):
            last_modified = header.substr(14).strip_edges().left(80)

static func valid_image_url(url: String) -> bool:
    return url in [IMAGE_ORIGIN + "mammoth_parade.jpg", IMAGE_ORIGIN + "mammoth_electric.jpg", IMAGE_ORIGIN + "washburn_ne.jpg", "https://www.nps.gov/featurecontent/ard/webcams/images/sekilarge.jpg", "https://www.nps.gov/featurecontent/ard/webcams/images/grcalarge.jpg", "https://www.nps.gov/featurecontent/ard/webcams/images/grsmlarge.jpg", "https://www.nps.gov/webcams-romo/alpine_visitor_center.jpg", "https://volcanoes.usgs.gov/observatories/hvo/cams/V1cam/images/M.jpg"]

func _received(result: int, code: int, headers: PackedStringArray, body: PackedByteArray, token: int) -> void:
    if not active or token != generation: return
    loading = false
    if is_instance_valid(request): request.queue_free()
    request = null
    if result == HTTPRequest.RESULT_SUCCESS and code == 304 and image != null and not digest.is_empty() and valid_etag(etag):
        _source_metadata(headers,false)
        _describe_success(true)
        return
    if result != HTTPRequest.RESULT_SUCCESS or code != 200 or body.is_empty() or body.size() > 8388608:
        _unavailable()
        return
    var hashing := HashingContext.new()
    hashing.start(HashingContext.HASH_SHA256)
    hashing.update(body)
    var next_digest := hashing.finish().hex_encode()
    # Identical provider frames need neither JPEG decoding nor a new GPU texture.
    # Only reuse a texture after these exact bytes have passed decoding once.
    if image == null or next_digest != digest:
        var expected := jpeg_dimensions(body)
        if expected == Vector2i.ZERO:
            _unavailable()
            return
        var decoded := Image.new()
        if decoded.load_jpg_from_buffer(body) != OK or decoded.get_size() != expected or decoded.is_empty():
            _unavailable()
            return
        if maxi(decoded.get_width(),decoded.get_height()) > max_texture_edge:
            var factor := float(max_texture_edge) / maxi(decoded.get_width(),decoded.get_height())
            decoded.resize(maxi(1,roundi(decoded.get_width()*factor)),maxi(1,roundi(decoded.get_height()*factor)),Image.INTERPOLATE_LANCZOS)
        image = ImageTexture.create_from_image(decoded)
    retrieved = Time.get_datetime_string_from_system(true).replace("T", " ")
    if next_digest != digest:
        unchanged_since = Time.get_unix_time_from_system()
        digest = next_digest
    _source_metadata(headers,true)
    _describe_success(false)

func _describe_success(revalidated: bool) -> void:
    consecutive_failures = 0
    refresh_interval = base_interval
    last_failed = false
    if revalidated:
        status = "Checked %s UTC · provider reports unchanged.\nImage retrieved %s UTC · periodic image, not continuous video.\nCamera capture time is not verified." % [Time.get_datetime_string_from_system(true).replace("T"," "),retrieved]
    else:
        status = "Retrieved %s UTC · periodic image, not continuous video.\nCamera capture time is not verified." % retrieved
    if not last_modified.is_empty(): status += "\nSource Last-Modified (last reported): " + last_modified
    var stale_after := maxf(300.0,base_interval * 2.0)
    if Time.get_unix_time_from_system() - unchanged_since >= stale_after:
        status += "\nImage unchanged for %d+ minutes; the provider may be delayed." % int(stale_after / 60.0)
    changed.emit()

func _unavailable() -> void:
    consecutive_failures = mini(consecutive_failures + 1, 4)
    refresh_interval = minf(base_interval * pow(2.0, consecutive_failures - 1), 7200.0)
    elapsed = 0.0
    last_failed = true
    _describe_unavailable()

func set_automatic(enabled: bool) -> void:
    automatic = enabled
    if last_failed: _describe_unavailable()

func _describe_unavailable() -> void:
    status = "Camera unavailable. Try Refresh or open the official source."
    if automatic:
        status += "\nAutomatic retry in %d minutes while this viewer is open." % int(refresh_interval / 60.0)
    if image != null:
        status += "\nLast successful image retained (retrieved %s UTC)." % retrieved
    changed.emit()
