extends Node
## Optional, user-selected periodic camera images. Never substitutes a bundled photo.
signal changed
var selected: Dictionary = {}
var image: Texture2D
var status := "Choose a camera."
var active := false
var automatic := true
var loading := false
var elapsed := 0.0
var generation := 0
var request: HTTPRequest
var last_attempt := -10000
var retrieved := ""
var digest := ""
var unchanged_since := 0.0
const IMAGE_ORIGIN := "https://www.nps.gov/webcams-yell/"

func _process(delta: float) -> void:
    if not active or not automatic or loading or get_window().mode == Window.MODE_MINIMIZED: return
    elapsed += delta
    if elapsed >= 60.0: refresh()

func open(venue: Dictionary) -> void:
    stop()
    selected = venue.duplicate()
    image = null
    retrieved = ""
    digest = ""
    active = true
    last_attempt = -10000
    refresh()

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
    if request.request(url, ["User-Agent: LivingEarth3D/0.5.5 (+https://github.com/nortja/Living-earth-3d)", "Cache-Control: no-cache"]) != OK:
        _received(HTTPRequest.RESULT_CANT_CONNECT, 0, PackedStringArray(), PackedByteArray(), generation)

static func valid_image_url(url: String) -> bool:
    return url in [IMAGE_ORIGIN + "mammoth_parade.jpg", IMAGE_ORIGIN + "mammoth_electric.jpg", IMAGE_ORIGIN + "washburn_ne.jpg"]

func _received(result: int, code: int, headers: PackedStringArray, body: PackedByteArray, token: int) -> void:
    if not active or token != generation: return
    loading = false
    if is_instance_valid(request): request.queue_free()
    request = null
    if result != HTTPRequest.RESULT_SUCCESS or code != 200 or body.is_empty() or body.size() > 8388608:
        _unavailable()
        return
    var decoded := Image.new()
    if decoded.load_jpg_from_buffer(body) != OK or decoded.get_width() > 4096 or decoded.get_height() > 4096 or decoded.is_empty():
        _unavailable()
        return
    image = ImageTexture.create_from_image(decoded)
    retrieved = Time.get_datetime_string_from_system(true).replace("T", " ")
    var hashing := HashingContext.new()
    hashing.start(HashingContext.HASH_SHA256)
    hashing.update(body)
    var next_digest := hashing.finish().hex_encode()
    var now := Time.get_unix_time_from_system()
    if next_digest != digest:
        unchanged_since = now
        digest = next_digest
    status = "Retrieved %s UTC · periodic image, not continuous video.\nCamera capture time is not verified." % retrieved
    for header in headers:
        if header.to_lower().begins_with("last-modified:"):
            status += "\nSource Last-Modified: " + header.substr(14).strip_edges().left(80)
            break
    if now - unchanged_since >= 300.0:
        status += "\nImage unchanged for 5+ minutes; the provider may be delayed."
    changed.emit()

func _unavailable() -> void:
    status = "Camera unavailable. Try Refresh or open the official source."
    if image != null:
        status += "\nLast successful image retained (retrieved %s UTC)." % retrieved
    changed.emit()
