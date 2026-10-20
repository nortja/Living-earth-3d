extends SceneTree
var failures := 0
func _initialize() -> void: call_deferred("run")
func run() -> void:
    var app = load("res://scenes/earth.tscn").instantiate()
    app.play_intro = false
    app.preferences_path = "user://arrival-render-%d.cfg" % Time.get_ticks_usec()
    root.add_child(app)
    for pixels in [Vector2i(800,600),Vector2i(1920,1080),Vector2i(3440,1440),Vector2i(3840,2160),Vector2i(5120,1440),Vector2i(5120,2880)]:
        root.size = pixels
        app.fly_to_location(app.exploration.catalog.places[0])
        app.journey.custom_step(3.0)
        app._update_camera()
        for frame in range(16): await process_frame
        await RenderingServer.frame_post_draw
        var ui = app.interface
        if not Rect2(Vector2.ZERO,ui.size).encloses(Rect2(ui.panel.position,ui.panel.size)) or ui.page_scroll.get_child(0).size.x > ui.page_scroll.size.x:
            failures += 1
            push_error("Arrival does not fit %s" % pixels)
        root.get_texture().get_image().save_png("res://dist/arrival-%dx%d.png" % [pixels.x,pixels.y])
    DirAccess.remove_absolute(ProjectSettings.globalize_path(app.preferences_path))
    app.queue_free()
    await process_frame
    print("Native destination arrivals: %d failures" % failures)
    quit(1 if failures else 0)
