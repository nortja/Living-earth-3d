extends SceneTree
const Camera = preload("res://scripts/camera_service.gd")
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("run")
func verify(ok: bool, message: String) -> void:
    checks += 1
    if not ok: failures += 1;push_error(message)
func run() -> void:
    verify(Camera.valid_etag('"abc"') and Camera.valid_etag('W/"abc"') and Camera.valid_etag('""'), "Strong, weak and empty opaque entity tags are accepted")
    for value in ['abc','*','"a b"','"a"b"','"abc"\r\nInjected: value','"'+'a'.repeat(256)+'"']:
        verify(not Camera.valid_etag(value), "Malformed, control or oversized entity tag rejected")
    var fixture := Image.create(32,16,false,Image.FORMAT_RGB8)
    fixture.fill(Color("5aabc1"))
    var bytes := fixture.save_jpg_to_buffer()
    verify(Camera.jpeg_dimensions(bytes)==Vector2i(32,16), "JPEG dimensions found before decode")
    verify(Camera.jpeg_dimensions(fixture.save_png_to_buffer())==Vector2i.ZERO, "Wrong image format rejected before decode")
    var progressive := bytes.duplicate()
    for index in range(progressive.size()-1):
        if progressive[index]==255 and progressive[index+1]==192:
            progressive[index+1]=194
            break
    verify(Camera.jpeg_dimensions(progressive)==Vector2i(32,16), "Progressive SOF marker supported by dimension parser")
    for invalid in [PackedByteArray(),bytes.slice(0,20),PackedByteArray([255,216,255,224,255,255]),PackedByteArray([255,216,255,218,0,2]),PackedByteArray([255,216,255,255,255])]:
        verify(Camera.jpeg_dimensions(invalid)==Vector2i.ZERO, "Truncated or invalid marker sequence rejected")
    var oversized := Image.create(4097,1,false,Image.FORMAT_RGB8)
    oversized.fill(Color.BLACK)
    verify(Camera.jpeg_dimensions(oversized.save_jpg_to_buffer())==Vector2i.ZERO, "Oversized JPEG rejected before pixel allocation")
    var random := RandomNumberGenerator.new()
    random.seed=32462
    for attempt in range(200):
        var malformed:=PackedByteArray([255,216])
        for index in range(random.randi_range(0,100)):malformed.append(random.randi_range(0,255))
        verify(Camera.jpeg_dimensions(malformed)==Vector2i.ZERO, "Bounded malformed input does not become an image")
    var camera=Camera.new()
    root.add_child(camera)
    camera.set_process(false)
    var venues:Array=JSON.parse_string(FileAccess.get_file_as_string("res://data/cameras.json"))
    camera.open(venues[0],false)
    verify(camera.request_headers().size()==2, "No conditional request before a validated image")
    camera._received(0,304,PackedStringArray(),PackedByteArray(),camera.generation)
    verify(camera.last_failed and camera.image==null, "First-response 304 cannot invent an image")
    camera._received(0,200,PackedStringArray(['ETag: W/"frame-1"','Last-Modified: fixture time']),bytes,camera.generation)
    verify(camera.request_headers().has('If-None-Match: W/"frame-1"'), "Validated frame enables provider revalidation")
    var texture:Texture2D=camera.image
    camera.retrieved="2026-10-30 12:00:00"
    camera.unchanged_since_ticks=Time.get_ticks_msec()-301000
    var frame_ticks: int=camera.unchanged_since_ticks
    camera._received(0,200,PackedStringArray(['ETag: W/"frame-1"','Last-Modified: fixture time']),bytes,camera.generation)
    verify(camera.unchanged_since_ticks==frame_ticks and camera.status.contains("5+ minutes"), "Repeated HTTP 200 bytes retain monotonic image age")
    camera.retrieved="2099-01-01 00:00:00"
    camera._describe_success(true)
    verify(camera.status.contains("5+ minutes"), "A future UTC display timestamp does not suppress the elapsed-age warning")
    camera.retrieved="2026-10-30 12:00:00"
    camera._unavailable()
    verify(camera.unchanged_since_ticks==frame_ticks, "Failed refresh does not reset image age")
    verify(camera.status.contains("Last successful image retained") and camera.status.contains("5+ minutes"), "Failed refresh preserves the unchanged-image warning beside the retained image")
    camera._received(0,304,PackedStringArray(),PackedByteArray(),camera.generation)
    verify(camera.image==texture and camera.retrieved=="2026-10-30 12:00:00", "304 retains the original texture and image retrieval time")
    verify(camera.status.contains("Checked") and camera.status.contains("fixture time") and camera.status.contains("5+ minutes"), "304 separates verification time, source metadata and delay warning")
    verify(camera.unchanged_since_ticks==frame_ticks, "HTTP 304 preserves monotonic age")
    verify(not camera.last_failed and camera.consecutive_failures==0 and camera.refresh_interval==camera.base_interval, "304 recovers failure backoff")
    fixture.fill(Color("cc8844"))
    camera._received(0,200,PackedStringArray(['ETag: "frame-2"']),fixture.save_jpg_to_buffer(),camera.generation)
    verify(camera.image!=texture and camera.etag=='"frame-2"' and camera.last_modified.is_empty(), "New image replaces both texture and source validators")
    verify(camera.unchanged_since_ticks>=frame_ticks+300000 and not camera.status.contains("5+ minutes"), "Changed image resets the monotonic delay timer")
    var token:int=camera.generation
    camera.open(venues[1],false)
    camera._received(0,304,PackedStringArray(['ETag: "old-source"']),PackedByteArray(),token)
    verify(camera.image==null and camera.etag.is_empty() and camera.request_headers().size()==2, "Camera switch clears validators and rejects late 304")
    camera._received(0,200,PackedStringArray(['ETag: bad\r\nInjected: value']),bytes,camera.generation)
    verify(camera.image!=null and camera.etag.is_empty(), "Malformed validator does not poison a successful image or later headers")
    camera.stop();camera.queue_free()
    await process_frame
    print("Camera revalidation: %d checks, %d failures" % [checks,failures])
    quit(1 if failures else 0)
