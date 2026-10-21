extends SceneTree
var failures := 0
func _initialize() -> void: call_deferred("run")
func run() -> void:
    var directory := "/tmp/earth-camera-expansion"
    for arg in OS.get_cmdline_user_args():
        if arg.begins_with("--camera-fixtures="): directory = arg.trim_prefix("--camera-fixtures=")
    root.size = Vector2i(1920,1080)
    var app = load("res://scenes/earth.tscn").instantiate()
    app.play_intro = false
    app.preferences_path = "user://camera-source-render-%d.cfg" % Time.get_ticks_usec()
    root.add_child(app)
    var ui = app.interface
    var ids := ["grand-canyon","smokies-look-rock","rocky-alpine","kilauea-v1"]
    for id in ids:
        var venue: Dictionary = ui.cameras.filter(func(v):return v.get("id") == id)[0]
        var path := directory.path_join(str(venue.image_url).get_file())
        if not FileAccess.file_exists(path): failures += 1;push_error("Missing actual provider bytes: "+id);continue
        ui.show_arrival(venue)
        ui.camera_overlay.show()
        app.camera_service.open(venue,false)
        app.camera_service._received(0,200,PackedStringArray(),FileAccess.get_file_as_bytes(path),app.camera_service.generation)
        for frame in range(18): await process_frame
        await RenderingServer.frame_post_draw
        if ui.camera_image.texture == null or not ui.camera_detail.text.contains("capture time is not verified"):
            failures += 1;push_error("Actual provider image did not decode: "+id)
        root.get_texture().get_image().save_png("res://dist/camera-source-%s.png" % id)
        ui.close_camera()
    DirAccess.remove_absolute(ProjectSettings.globalize_path(app.preferences_path))
    app.queue_free()
    await process_frame
    print("Actual camera source renders: %d failures" % failures)
    quit(1 if failures else 0)
