extends SceneTree
const Camera = preload("res://scripts/camera_service.gd")
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("run")
func verify(ok: bool, message: String) -> void:
    checks += 1
    if not ok: failures += 1; push_error(message)
func run() -> void:
    var venues: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/cameras.json"))
    var urls: Array = []
    for venue in venues:
        if not venue.has("image_url"): continue
        verify(Camera.valid_image_url(venue.image_url), "Image source explicitly allowlisted")
        verify(venue.image_url not in urls, "Image sources distinct")
        urls.append(venue.image_url)
    verify(urls.size() == 8, "Eight distinct image sources")
    verify(not Camera.valid_image_url("https://volcanoes.usgs.gov.evil.test/observatories/hvo/cams/V1cam/images/M.jpg"), "USGS lookalike rejected")
    verify(not Camera.valid_image_url("http://www.nps.gov/featurecontent/ard/webcams/images/grcalarge.jpg"), "Unencrypted image source rejected")
    var service = Camera.new()
    root.add_child(service)
    service.set_process(false)
    var venue = venues.filter(func(v): return v.get("id") == "grand-canyon")[0]
    service.open(venue,false)
    verify(service.base_interval == 900 and service.refresh_interval == 900, "Air-quality feed respects 15-minute cadence")
    var image := Image.create(2048,1024,false,Image.FORMAT_RGB8)
    image.fill(Color("5c96ba"))
    var bytes := image.save_jpg_to_buffer()
    service.max_texture_edge = 1024
    service._received(0,200,PackedStringArray(),bytes,service.generation)
    verify(service.image.get_width() == 1024 and service.image.get_height() == 512, "Wall downsampling preserves aspect ratio and bounds GPU texture")
    service.unchanged_since = Time.get_unix_time_from_system() - 301
    service._received(0,200,PackedStringArray(),bytes,service.generation)
    verify(not service.status.contains("unchanged"), "Expected 15-minute image does not trigger five-minute delay warning")
    service.unchanged_since = Time.get_unix_time_from_system() - 1801
    service._received(0,200,PackedStringArray(),bytes,service.generation)
    verify(service.status.contains("30+ minutes"), "Slow image delay threshold reflects provider cadence")
    service._unavailable()
    verify(service.refresh_interval == 900, "Slow source retry starts at provider cadence")
    for index in range(6): service._unavailable()
    verify(service.refresh_interval == 7200 and service.status.contains("120 minutes"), "Long-source retry remains bounded and accurately labelled")
    service.open(venues[0],false)
    verify(service.base_interval == 60 and service.refresh_interval == 60, "Switch restores ordinary camera cadence")
    service.stop()
    service.queue_free()
    await process_frame
    print("Camera expansion: %d checks, %d failures" % [checks,failures])
    quit(1 if failures else 0)
