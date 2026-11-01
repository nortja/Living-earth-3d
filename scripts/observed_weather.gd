extends Node
## Requested, time-stamped NOAA infrared scenes via NASA GIBS. Never a forecast.
signal changed
const Bounds = preload("res://scripts/satellite_snapshot.gd")
const SOURCES := [
    {"id":"GOES-West_ABI_Band13_Clean_Infrared","name":"GOES-West / ABI","region":"Pacific and western Americas","longitude":-137.2},
    {"id":"GOES-East_ABI_Band13_Clean_Infrared","name":"GOES-East / ABI","region":"Americas and western Atlantic","longitude":-75.2}]
const OFFSETS := [0,3600,10800,43200]
const RECENT_BUFFER := 1800
const WIDTH := 2560
const HEIGHT := 1280
const TILE_SIZE := 512
const COLUMNS := 5
const ROWS := 3
const MAX_META_BYTES := 262144
const MAX_TILE_BYTES := 4194304
const COOLDOWN_MS := 600000
const MAX_AGE := 259200.0
var app: Node3D
var selected_source := 0
var selected_offset := 0
var observed_source := -1
var observed_time := ""
var retrieved := ""
var texture: Texture2D
var enabled := false
var suspended := false
var loading := false
var status := "Load a supported regional infrared scene. No automatic downloads."
var generation := 0
var last_attempts: Dictionary = {}
var request: HTTPRequest
var workers: Dictionary = {}
var next_tile := 0
var completed := 0
var canvas: Image
var pending_source := 0
var pending_time := ""
var restore_satellite := false
var poll := 0.0
var last_transport := Vector2i.ZERO
var last_transport_detail := ""

func setup(owner_app: Node3D) -> void:
    app = owner_app

static func iso_stamp(text: String) -> float:
    # Validate before calling Time, which reports engine errors on malformed dates.
    if text.length()!=20 or text[4]!="-" or text[7]!="-" or text[10]!="T" or text[13]!=":" or text[16]!=":" or text[19]!="Z": return -1.0
    for index in [0,1,2,3,5,6,8,9,11,12,14,15,17,18]:
        if text[index] not in "0123456789": return -1.0
    var year := int(text.substr(0,4))
    var month := int(text.substr(5,2))
    var day := int(text.substr(8,2))
    var leap := year%4==0 and (year%100!=0 or year%400==0)
    var days := [31,29 if leap else 28,31,30,31,30,31,31,30,31,30,31]
    if year<2020 or year>2100 or month<1 or month>12 or day<1: return -1.0
    if day>int(days[month-1]) or int(text.substr(11,2))>23 or int(text.substr(14,2))>59 or int(text.substr(17,2))>59: return -1.0
    return float(Time.get_unix_time_from_datetime_string(text.trim_suffix("Z")))

static func parse_domains(bytes: PackedByteArray, now: float, offset: int) -> String:
    if bytes.size()==0 or bytes.size()>MAX_META_BYTES or offset not in OFFSETS and offset!=RECENT_BUFFER: return ""
    if bytes.get_string_from_utf8().contains("<!"): return ""
    var xml := XMLParser.new()
    if xml.open_buffer(bytes)!=OK: return ""
    var tags: Array[String] = []
    var identifier := ""
    var domain := ""
    var domain_count := 0
    var code := xml.read()
    while code==OK:
        match xml.get_node_type():
            XMLParser.NODE_ELEMENT:
                var tag := xml.get_node_name().get_slice(":",xml.get_node_name().get_slice_count(":")-1)
                if not xml.is_empty(): tags.append(tag)
                if tag=="DimensionDomain": identifier = ""
            XMLParser.NODE_ELEMENT_END:
                if not tags.is_empty(): tags.pop_back()
            XMLParser.NODE_TEXT:
                if tags.size()>1 and tags[-2]=="DimensionDomain":
                    if tags[-1]=="Identifier": identifier = xml.get_node_data().strip_edges()
                    if tags[-1]=="Domain" and identifier.to_lower()=="time":
                        domain_count += 1
                        domain = xml.get_node_data().strip_edges()
        code = xml.read()
    if code!=ERR_FILE_EOF or domain_count!=1 or domain.length()>MAX_META_BYTES/2: return ""
    var ranges: Array = []
    var latest := -1.0
    var pieces := domain.split(",",false)
    if pieces.size()>2048: return ""
    for piece in pieces:
        var fields := piece.strip_edges().split("/")
        if fields.size()!=3 or fields[2]!="PT10M": return ""
        var start_text: String = fields[0]
        if start_text.length()==10: start_text += "T00:00:00Z"
        var start := iso_stamp(start_text)
        var finish := iso_stamp(fields[1])
        if start<0 or finish<start or finish>now+600.0: return ""
        var end := minf(finish,start+floor((now-start)/600.0)*600.0)
        if end<start: continue
        ranges.append([start,end])
        latest = maxf(latest,end)
    var target := latest-offset
    var chosen := -1.0
    for interval in ranges:
        if float(interval[0])>target: continue
        var candidate := minf(float(interval[1]),float(interval[0])+floor((target-float(interval[0]))/600.0)*600.0)
        chosen = maxf(chosen,candidate)
    if chosen<0 or now-chosen>MAX_AGE: return ""
    return Time.get_datetime_string_from_unix_time(int(chosen))+"Z"

static func metadata_url(source: int, now: float) -> String:
    if source<0 or source>=SOURCES.size(): return ""
    var start := Time.get_datetime_string_from_unix_time(int(now)-172800)+"Z"
    var end := Time.get_datetime_string_from_unix_time(int(now))+"Z"
    return "https://gibs.earthdata.nasa.gov/wmts/epsg4326/best/wmts.cgi?SERVICE=WMTS&REQUEST=DescribeDomains&VERSION=1.0.0&LAYER=%s&TILEMATRIXSET=2km&TIME=%s/%s" % [SOURCES[source].id,start,end]

static func tile_url(source: int, stamp: String, index: int) -> String:
    if source<0 or source>=SOURCES.size() or iso_stamp(stamp)<0 or index<0 or index>=COLUMNS*ROWS: return ""
    return "https://gibs.earthdata.nasa.gov/wmts/epsg4326/best/%s/default/%s/2km/2/%d/%d.png" % [SOURCES[source].id,stamp,index/COLUMNS,index%COLUMNS]

static func valid_tile(bytes: PackedByteArray) -> bool:
    if bytes.size()<33 or bytes.size()>MAX_TILE_BYTES: return false
    if bytes.slice(0,8)!=PackedByteArray([137,80,78,71,13,10,26,10]) or bytes.slice(12,16).get_string_from_ascii()!="IHDR": return false
    var width := (int(bytes[16])<<24)|(int(bytes[17])<<16)|(int(bytes[18])<<8)|int(bytes[19])
    var height := (int(bytes[20])<<24)|(int(bytes[21])<<16)|(int(bytes[22])<<8)|int(bytes[23])
    return width==TILE_SIZE and height==TILE_SIZE

func select_source(index: int) -> void:
    if index<0 or index>=SOURCES.size(): return
    cancel()
    selected_source = index
    changed.emit()

func select_offset(index: int) -> void:
    if index<0 or index>=OFFSETS.size(): return
    cancel()
    selected_offset = index
    changed.emit()

func _http(limit: int) -> HTTPRequest:
    var http := HTTPRequest.new()
    http.timeout = 25
    http.body_size_limit = limit
    http.max_redirects = 0
    add_child(http)
    var proxy := OS.get_environment("HTTPS_PROXY")
    if not proxy.is_empty():
        var host_port := proxy.get_slice("://",1).get_slice("/",0)
        if not "@" in host_port and host_port.count(":")==1: http.set_https_proxy(host_port.get_slice(":",0),int(host_port.get_slice(":",1)))
    return http

func refresh() -> void:
    if app.screensaver_mode or suspended or loading: return
    if Time.get_ticks_msec()-int(last_attempts.get(str(selected_source)+":"+str(selected_offset),-COOLDOWN_MS))<COOLDOWN_MS:
        status = "Wait ten minutes between requests. Any retained scene keeps its own source/time."
        changed.emit();return
    cancel()
    pending_source = selected_source
    last_attempts[str(selected_source)+":"+str(selected_offset)] = Time.get_ticks_msec()
    loading = true
    status = "Checking advertised image times · %s…" % SOURCES[pending_source].name
    changed.emit()
    request = _http(MAX_META_BYTES)
    request.request_completed.connect(_metadata_received.bind(generation))
    if request.request(metadata_url(pending_source,Time.get_unix_time_from_system()),["User-Agent: LivingEarth3D/0.22.0 (+https://github.com/nortja/Living-earth-3d)"])!=OK:
        _metadata_received(HTTPRequest.RESULT_CANT_CONNECT,0,PackedStringArray(),PackedByteArray(),generation)

func _metadata_received(result: int, code: int, _headers: PackedStringArray, bytes: PackedByteArray, token: int) -> void:
    if token!=generation or suspended or app.screensaver_mode: return
    if is_instance_valid(request): request.queue_free()
    request = null
    last_transport = Vector2i(result,code)
    last_transport_detail = bytes.get_string_from_utf8().left(1024) if code!=200 else ""
    if result!=HTTPRequest.RESULT_SUCCESS or code!=200:
        _fail("Image-time metadata unavailable");return
    pending_time = parse_domains(bytes,Time.get_unix_time_from_system(),RECENT_BUFFER if selected_offset==0 else OFFSETS[selected_offset])
    if pending_time.is_empty():
        _fail("No supported recent image time; check your device clock");return
    canvas = Image.create(WIDTH,HEIGHT,false,Image.FORMAT_RGBA8)
    canvas.fill(Color.TRANSPARENT)
    next_tile = 0
    completed = 0
    status = "Loading %s · %s · 0/15 tiles…" % [SOURCES[pending_source].name,pending_time]
    changed.emit()
    _pump()

func _pump() -> void:
    if not loading or suspended or app.screensaver_mode: return
    while workers.size()<2 and next_tile<COLUMNS*ROWS:
        var index := next_tile
        next_tile += 1
        var http := _http(MAX_TILE_BYTES)
        workers[index] = http
        http.request_completed.connect(_tile_received.bind(generation,index))
        if http.request(tile_url(pending_source,pending_time,index),["User-Agent: LivingEarth3D/0.22.0 (+https://github.com/nortja/Living-earth-3d)"])!=OK:
            _tile_received(HTTPRequest.RESULT_CANT_CONNECT,0,PackedStringArray(),PackedByteArray(),generation,index)
            return

func _tile_received(result: int, code: int, _headers: PackedStringArray, bytes: PackedByteArray, token: int, index: int) -> void:
    if token!=generation or suspended or app.screensaver_mode: return
    if not workers.has(index) or canvas==null: return
    var http: HTTPRequest = workers[index]
    workers.erase(index)
    if is_instance_valid(http): http.queue_free()
    var image := Image.new()
    last_transport = Vector2i(result,code)
    last_transport_detail = "Tile %d; bytes %d; prefix %s" % [index,bytes.size(),bytes.slice(0,24).hex_encode()]
    if code!=200: last_transport_detail += " "+bytes.get_string_from_utf8().left(700)
    if result!=HTTPRequest.RESULT_SUCCESS or code!=200 or not valid_tile(bytes):
        _fail("A regional image tile was unavailable");return
    if image.load_png_from_buffer(bytes)!=OK or image.get_size()!=Vector2i(TILE_SIZE,TILE_SIZE):
        _fail("A regional image tile was invalid");return
    image.convert(Image.FORMAT_RGBA8)
    var position := Vector2i((index%COLUMNS)*TILE_SIZE,(index/COLUMNS)*TILE_SIZE)
    canvas.blit_rect(image,Rect2i(Vector2i.ZERO,Vector2i(TILE_SIZE,mini(TILE_SIZE,HEIGHT-position.y))),position)
    completed += 1
    status = "Loading %s · %s · %d/15 tiles…" % [SOURCES[pending_source].name,pending_time,completed]
    changed.emit()
    if completed==COLUMNS*ROWS:
        if not Bounds.has_observations(canvas):
            _fail("The provider returned an empty scene");return
        texture = ImageTexture.create_from_image(canvas)
        canvas = null
        loading = false
        observed_source = pending_source
        observed_time = pending_time
        retrieved = Time.get_datetime_string_from_system(true)+"Z"
        status = "Regional infrared scene loaded."
        set_enabled(true)
        return
    _pump()

func cancel() -> void:
    generation += 1
    if is_instance_valid(request): request.cancel_request();request.queue_free()
    request = null
    for worker in workers.values():
        if is_instance_valid(worker): worker.cancel_request();worker.queue_free()
    workers.clear()
    canvas = null
    if loading:
        loading = false
        status = "Request canceled. Previous scene, if any, is retained with its original time."
        changed.emit()

func _fail(message: String) -> void:
    cancel()
    status = message+". "+("Offline Earth remains available." if texture==null else "Previous scene retained: %s · %s." % [SOURCES[observed_source].name,observed_time])
    changed.emit()

func set_enabled(value: bool) -> void:
    if not value: cancel()
    var will_show := value and texture!=null
    if will_show and not enabled:
        restore_satellite = app.satellite_snapshot.enabled
        app.satellite_snapshot.set_enabled(false)
    var restore := restore_satellite and not will_show and enabled
    enabled = will_show
    if not enabled: restore_satellite = false
    apply_view()
    if restore: app.satellite_snapshot.set_enabled(true)
    changed.emit()

func set_suspended(value: bool) -> void:
    suspended = value
    if value: cancel()
    apply_view()
    changed.emit()

func apply_view() -> void:
    var showing: bool = enabled and texture!=null and not suspended and not app.screensaver_mode
    app.earth_material.set_shader_parameter("observed_weather_view",showing)
    if texture!=null: app.earth_material.set_shader_parameter("observed_weather_map",texture)
    var satellite_showing: bool = app.satellite_snapshot.enabled and not app.satellite_snapshot.suspended and not app.screensaver_mode
    app.visuals.clouds.visible = app.visuals.clouds_enabled and not showing and not satellite_showing
    if showing: app.info.text = "%s%s IR · %s UTC" % ["OLD " if is_stale() else "",str(SOURCES[observed_source].id).get_slice("_",0),observed_time.substr(5,5)+" "+observed_time.substr(11,5)]
    elif not satellite_showing: app.info.text = "Drag to orbit · Scroll to zoom"

func is_stale() -> bool:
    return texture!=null and Time.get_unix_time_from_system()-iso_stamp(observed_time)>7200.0

func context() -> String:
    if texture==null: return "No infrared scene loaded."
    var age := maxf(0.0,Time.get_unix_time_from_system()-iso_stamp(observed_time))
    return "%s · %s\nNominal scan time %s · age %.0f min%s\nRetrieved %s" % [SOURCES[observed_source].name,SOURCES[observed_source].region,observed_time,age/60.0," · OLD SCENE" if age>7200 else "",retrieved]

func focus_coverage() -> void:
    var source := observed_source if observed_source>=0 and enabled else selected_source
    app.fly_to_location({"name":str(SOURCES[source].name)+" coverage center (approximate)","latitude":10.0,"longitude":SOURCES[source].longitude},false)

func _process(delta: float) -> void:
    if texture==null: return
    poll += delta
    if poll>=60.0:
        poll = 0.0
        apply_view()
        changed.emit()
