extends SceneTree
var failures := 0
func _initialize() -> void: call_deferred("run")
func run() -> void:
    var app = load("res://scenes/earth.tscn").instantiate()
    app.play_intro = false
    app.preferences_path = "user://journey-render-%d.cfg" % Time.get_ticks_usec()
    root.add_child(app)
    var ui = app.interface
    ui.open_page("Journey studio")
    ui.journey_studio.preset(1)
    app.fly_to_location({"name":"Pacific","latitude":20.0,"longitude":180.0},false)
    app.journey.custom_step(3.0)
    app.distance = 3.8
    app._update_camera()
    for pixels in [Vector2i(800,600),Vector2i(1920,1080),Vector2i(3440,1440),Vector2i(3840,1080),Vector2i(3840,2160),Vector2i(5120,1440),Vector2i(5120,2880)]:
        root.size = pixels
        for frame in range(16): await process_frame
        await RenderingServer.frame_post_draw
        for control in [ui.journey_studio.status,ui.journey_studio.play_button,ui.journey_studio.pause_button,ui.journey_studio.next_button,ui.journey_studio.clear_button,ui.journey_studio.summary]:
            if not ui.page_scroll.get_global_rect().encloses(control.get_global_rect()):
                failures += 1; push_error("Journey primary control clipped at %s: %s" % [pixels,control.get_global_rect()])
        if not Rect2(Vector2.ZERO,ui.size).encloses(ui.panel.get_rect()) or ui.page_scroll.get_child(0).size.x>ui.page_scroll.size.x:
            failures += 1; push_error("Journey panel overflows viewport")
        root.get_texture().get_image().save_png("res://dist/journey-%dx%d.png" % [pixels.x,pixels.y])
    ui.close_panel()
    if ui.journey_studio.marker_root.visible: failures += 1
    DirAccess.remove_absolute(ProjectSettings.globalize_path(app.preferences_path))
    app.queue_free()
    await process_frame
    print("Native journey studio: %d failures" % failures)
    quit(1 if failures else 0)
