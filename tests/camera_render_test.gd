extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
    var app = load("res://scenes/earth.tscn").instantiate()
    app.play_intro = false
    app.preferences_path = "user://camera-render-%d.cfg" % Time.get_ticks_usec()
    root.add_child(app)
    create_timer(90).timeout.connect(func(): push_error("Camera render timeout");quit(1))
    app.interface.select_camera(app.interface.cameras[0])
    while app.camera_service.loading: await app.camera_service.changed
    if app.camera_service.image == null:
        push_error("No provider image for render check: " + app.camera_service.status)
        quit(1)
        return
    app.camera_service.automatic = false
    for pixels in [Vector2i(800,600),Vector2i(1920,1080),Vector2i(5120,2880)]:
        root.size = pixels
        app.interface.set_ui_scale(2.0 if pixels.y > 1080 else 1.0)
        for frame in range(12): await process_frame
        await RenderingServer.frame_post_draw
        var ui = app.interface
        if not Rect2(Vector2.ZERO,ui.size).encloses(Rect2(ui.camera_viewer.position,ui.camera_viewer.size)):
            push_error("Native camera viewer leaves viewport")
            quit(1)
            return
        var capture := root.get_texture().get_image()
        if capture.get_size() != pixels or capture.save_png("res://dist/camera-%dx%d.png" % [pixels.x,pixels.y]) != OK:
            push_error("Native screenshot failed")
            quit(1)
            return
        print("PASS: native Linux camera view %s. This is not a Windows GPU benchmark." % pixels)
    app.interface.close_camera()
    DirAccess.remove_absolute(ProjectSettings.globalize_path(app.preferences_path))
    app.queue_free()
    await process_frame
    quit(0)
