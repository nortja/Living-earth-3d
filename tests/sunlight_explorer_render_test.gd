extends SceneTree
var failures := 0
func _initialize() -> void: call_deferred("run")
func run() -> void:
    var app = load("res://scenes/earth.tscn").instantiate()
    app.play_intro = false
    app.preferences_path = "user://sunlight-render-%d.cfg" % Time.get_ticks_usec()
    root.add_child(app)
    app.exploration.set_location({"name":"Three Rivers, California","latitude":36.44,"longitude":-118.90})
    var ui = app.interface
    for pixels in [Vector2i(800,600),Vector2i(1920,1080),Vector2i(3440,1440),Vector2i(3840,1080),Vector2i(3840,2160),Vector2i(5120,1440),Vector2i(5120,2880)]:
        root.size = pixels
        ui.open_page("Sunlight explorer")
        ui.sunlight_explorer.anchor_time = Time.get_unix_time_from_datetime_string("2026-11-01T01:00:00")
        ui.sunlight_explorer.slider.value = 0.25
        for frame in range(16): await process_frame
        await RenderingServer.frame_post_draw
        for control in [ui.sunlight_explorer.slider,ui.sunlight_explorer.finish_button,ui.sunlight_explorer.clock]:
            if not ui.page_scroll.get_global_rect().encloses(control.get_global_rect()):
                failures += 1; push_error("Sunlight primary control clipped at %s" % pixels)
        if not Rect2(Vector2.ZERO,ui.size).encloses(ui.panel.get_rect()) or ui.page_scroll.get_child(0).size.x>ui.page_scroll.size.x:
            failures += 1; push_error("Sunlight panel does not fit viewport")
        root.get_texture().get_image().save_png("res://dist/sunlight-%dx%d.png" % [pixels.x,pixels.y])
        ui.close_panel()
    DirAccess.remove_absolute(ProjectSettings.globalize_path(app.preferences_path))
    app.queue_free()
    await process_frame
    print("Native sunlight explorer: %d failures" % failures)
    quit(1 if failures else 0)
