extends SceneTree
var checks := 0
var failures := 0
func verify(value: bool, message: String) -> void:
    checks += 1
    if not value:
        failures += 1
        push_error(message)
func _initialize() -> void: call_deferred("run")
func run() -> void:
    var app = load("res://scenes/earth.tscn").instantiate()
    app.play_intro = false
    app.preferences_path = "user://camera-test-%d.cfg" % Time.get_ticks_usec()
    root.add_child(app)
    var service = app.camera_service
    var ui = app.interface
    verify(not service.active and not ui.camera_overlay.visible, "Startup does not fetch or show a camera")
    var snapshots := 0
    for venue in ui.cameras:
        if venue.has("image_url"):
            snapshots += 1
            verify(service.valid_image_url(venue.image_url), "Snapshot URL is allowlisted")
    verify(snapshots == 3, "Three explicit in-app image cameras")
    verify(not service.valid_image_url("https://example.com/private.jpg"), "Unknown image origin rejected")
    # Invalid URL fixture exercises the UI action without accessing a real provider.
    ui.select_camera({"name":"Fixture image", "provider":"Test only", "latitude":44.97, "longitude":-110.7, "image_url":"invalid", "url":"https://www.nps.gov/"})
    verify(ui.camera_overlay.visible and service.active and app.external_focus, "Camera selection opens viewer and moves globe")
    var fixture := Image.create(16, 9, false, Image.FORMAT_RGB8)
    fixture.fill(Color("6cabc1"))
    var bytes := fixture.save_jpg_to_buffer()
    service._received(HTTPRequest.RESULT_SUCCESS, 200, PackedStringArray(["Last-Modified: fixture source time"]), bytes, service.generation)
    verify(ui.camera_image.texture != null and not service.retrieved.is_empty(), "A decoded image appears in viewer")
    verify(service.status.contains("not continuous video") and service.status.contains("capture time is not verified"), "Periodic image and freshness limits explicit")
    verify(service.status.contains("fixture source time"), "Provider timestamp shown separately from retrieval")
    service._received(HTTPRequest.RESULT_CANT_CONNECT, 0, PackedStringArray(), PackedByteArray(), service.generation)
    verify(service.image != null and service.status.contains("Last successful image retained"), "Network failure labels retained image")
    verify(service.refresh_interval == 60.0, "First failure retries after one minute")
    for attempt in range(6): service._unavailable()
    verify(service.refresh_interval == 480.0, "Repeated failures cap retries at eight minutes")
    service.automatic = false
    service._unavailable()
    verify(not service.status.contains("Automatic retry"), "Manual mode never promises an automatic retry")
    service.automatic = true
    service.unchanged_since = Time.get_unix_time_from_system() - 301
    service._received(HTTPRequest.RESULT_SUCCESS, 200, PackedStringArray(), bytes, service.generation)
    verify(service.refresh_interval == 60.0 and service.consecutive_failures == 0, "Successful refresh restores normal cadence")
    verify(service.status.contains("unchanged"), "Repeated unchanged frames flagged")
    var token: int = service.generation
    ui.close_camera()
    service._received(HTTPRequest.RESULT_SUCCESS, 200, PackedStringArray(), bytes, token)
    verify(not service.active and not ui.camera_overlay.visible, "Close stops requests; late response ignored")
    ui.select_camera({"name":"Another fixture", "latitude":40.0, "longitude":-100.0, "image_url":"invalid"})
    verify(service.refresh_interval == 60.0 and service.consecutive_failures == 0, "New camera resets failure backoff")
    verify(service.image == null and ui.camera_image.texture == null, "Switching camera never relabels an old image")
    for pixels in [Vector2i(800,600), Vector2i(1920,1080), Vector2i(5120,1440), Vector2i(5120,2880)]:
        root.size = pixels
        ui.set_ui_scale(2.0)
        for frame in range(10): await process_frame
        verify(Rect2(Vector2.ZERO,ui.size).encloses(Rect2(ui.camera_viewer.position,ui.camera_viewer.size)), "Viewer fits %s" % pixels)
    for action in [ui.camera_close,ui.camera_refresh,ui.camera_source_button]:
        var font: Font = action.get_theme_font("font")
        verify(action.size.x >= font.get_string_size(action.text,HORIZONTAL_ALIGNMENT_LEFT,-1,action.get_theme_font_size("font_size")).x,"Camera action label stays readable: " + action.text)
    app.preview_screensaver()
    verify(not service.active and not ui.camera_overlay.visible, "Screensaver preview stops camera networking")
    DirAccess.remove_absolute(ProjectSettings.globalize_path(app.preferences_path))
    app.queue_free()
    await process_frame
    print("Camera viewer: %d checks, %d failures" % [checks,failures])
    quit(1 if failures else 0)
