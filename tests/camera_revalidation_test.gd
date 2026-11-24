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
    verify(Camera.valid_last_modified("Sun, 06 Nov 1994 08:49:37 GMT"), "Valid IMF-fixdate is accepted")
    verify(Camera.valid_last_modified("Thu, 29 Feb 2024 12:00:00 GMT"), "Leap-day IMF-fixdate is accepted")
    for value in ["fixture time", "Wed, 29 Feb 2023 12:00:00 GMT", "Sun, 31 Apr 1994 08:49:37 GMT", "Sun, 06 Nov 1994 24:00:00 GMT", "Sun, 06 Nov 1994 08:49:37 GMT\r\nInjected: value", "Sun, 06 Nov 1994 08:49:37 PST"]:
        verify(not Camera.valid_last_modified(value), "Malformed, impossible or unsafe Last-Modified value rejected")
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
    verify(camera.request_headers().size()==2 and camera.request_validator.is_empty(), "No conditional request before a validated image")
    camera._received(0,304,PackedStringArray(),PackedByteArray(),camera.generation)
    verify(camera.last_failed and camera.image==null and camera.last_failure_reason.contains("HTTP 304"), "First-response 304 cannot invent an image and reports why it was rejected")
    camera._received(0,200,PackedStringArray(['ETag: W/"frame-1"','Last-Modified: fixture time']),bytes,camera.generation)
    var etag_headers := camera.request_headers()
    verify(etag_headers.has('If-None-Match: W/"frame-1"') and not etag_headers.has("If-Modified-Since: fixture time") and camera.request_validator == "etag" and camera.last_failure_reason.is_empty(), "A valid ETag takes precedence over display-only Last-Modified metadata and clears prior failure reason")
    var texture:Texture2D=camera.image
    camera.retrieved="2026-10-30 12:00:00"
    camera.unchanged_since_ticks=Time.get_ticks_msec()-301000
    var frame_ticks: int=camera.unchanged_since_ticks
    camera.request_headers()
    camera._received(0,200,PackedStringArray(['ETag: W/"frame-1"','Last-Modified: fixture time']),bytes,camera.generation)
    verify(camera.unchanged_since_ticks==frame_ticks and camera.status.contains("5+ minutes"), "Repeated HTTP 200 bytes retain monotonic image age")
    camera.retrieved="2099-01-01 00:00:00"
    camera._describe_success(true)
    verify(camera.status.contains("5+ minutes"), "A future UTC display timestamp does not suppress the elapsed-age warning")
    camera.retrieved="2026-10-30 12:00:00"
    camera._unavailable()
    verify(camera.unchanged_since_ticks==frame_ticks, "Failed refresh does not reset image age")
    verify(camera.last_failure_reason=="The provider did not return a usable image.", "Fallback failure reason remains explicit for non-HTTP internal failures")
    verify(camera.status.contains("Last successful image retained") and camera.status.contains("5+ minutes"), "Failed refresh preserves the unchanged-image warning beside the retained image")
    camera.request_headers()
    camera._received(0,304,PackedStringArray(),PackedByteArray(),camera.generation)
    verify(camera.image==texture and camera.retrieved=="2026-10-30 12:00:00", "ETag 304 retains the original texture and image retrieval time")
    verify(camera.status.contains("Checked") and camera.status.contains("fixture time") and camera.status.contains("5+ minutes"), "304 separates verification time, source metadata and delay warning")
    verify(camera.unchanged_since_ticks==frame_ticks, "HTTP 304 preserves monotonic age")
    verify(not camera.last_failed and camera.consecutive_failures==0 and camera.refresh_interval==camera.base_interval, "304 recovers failure backoff")
    fixture.fill(Color("cc8844"))
    camera._received(0,200,PackedStringArray(['ETag: "frame-2"']),fixture.save_jpg_to_buffer(),camera.generation)
    verify(camera.image!=texture and camera.etag=='"frame-2"' and camera.last_modified.is_empty(), "New image replaces both texture and source validators")
    verify(camera.unchanged_since_ticks>=frame_ticks+300000 and not camera.status.contains("5+ minutes"), "Changed image resets the monotonic delay timer")
    var etag_frame: Texture2D = camera.image
    var etag_retrieved := camera.retrieved
    var etag_age := camera.unchanged_since_ticks
    var dated_bytes := fixture.save_jpg_to_buffer()
    camera._received(0,200,PackedStringArray(["Last-Modified: Thu, 29 Feb 2024 12:00:00 GMT"]),dated_bytes,camera.generation)
    verify(camera.etag.is_empty() and camera.last_modified == "Thu, 29 Feb 2024 12:00:00 GMT", "A source without ETag retains its syntactically valid Last-Modified date")
    var modified_headers := camera.request_headers()
    verify(modified_headers.has("If-Modified-Since: Thu, 29 Feb 2024 12:00:00 GMT") and not modified_headers.has("If-None-Match:") and camera.request_validator == "last-modified", "Last-Modified is used as a conditional fallback only when ETag is absent")
    var modified_retrieved := camera.retrieved
    var modified_age := camera.unchanged_since_ticks
    var modified_texture: Texture2D = camera.image
    camera._received(0,304,PackedStringArray(["Last-Modified: Thu, 29 Feb 2024 12:00:00 GMT"]),PackedByteArray(),camera.generation)
    verify(camera.image == modified_texture and camera.retrieved == modified_retrieved and camera.unchanged_since_ticks == modified_age, "Last-Modified 304 retains the validated image, retrieval time and monotonic unchanged age")
    verify(camera.status.contains("Checked") and camera.status.contains("Image retrieved") and camera.status.contains("Source Last-Modified"), "Last-Modified 304 distinguishes check, retrieval and provider metadata")
    camera._received(0,200,PackedStringArray(["Last-Modified: fixture time"]),dated_bytes,camera.generation)
    verify(camera.last_modified == "fixture time", "Unparseable provider date remains display-only metadata")
    var unsafe_headers := camera.request_headers()
    verify(unsafe_headers.size() == 2 and camera.request_validator.is_empty(), "Unparseable Last-Modified is never sent as a request header")
    camera._received(0,304,PackedStringArray(),PackedByteArray(),camera.generation)
    verify(camera.last_failed and camera.image != null and camera.last_failure_reason.contains("without a validated cached image"), "Unsolicited 304 without a safe validator is rejected while retaining the last-good image")
    verify(camera.image == modified_texture and camera.retrieved == modified_retrieved, "Rejected 304 cannot replace the retained frame or retrieval time")
    verify(etag_frame != null and not etag_retrieved.is_empty() and etag_age > 0, "ETag baseline remains available after Last-Modified fallback coverage")
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
