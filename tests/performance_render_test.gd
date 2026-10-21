extends SceneTree
var failures := 0
func _initialize() -> void: call_deferred("run")
func run() -> void:
    var app = load("res://scenes/earth.tscn").instantiate()
    app.play_intro = false
    app.preferences_path = "user://performance-render-%d.cfg" % Time.get_ticks_usec()
    root.add_child(app)
    var ui = app.interface
    app.performance_report.start_recording()
    for pixels in [Vector2i(800,600),Vector2i(1920,1080),Vector2i(3440,1440),Vector2i(3840,2160),Vector2i(5120,1440),Vector2i(5120,2880)]:
        root.size = pixels
        if ui.active_page != "Display report": ui.open_page("Display report")
        for frame in range(24): await process_frame
        app.performance_report.snapshot = app.performance_report.build_snapshot()
        ui._performance_changed()
        for frame in range(12): await process_frame
        await RenderingServer.frame_post_draw
        if not Rect2(Vector2.ZERO,ui.size).encloses(Rect2(ui.panel.position,ui.panel.size)) or ui.page_scroll.get_child(0).size.x > ui.page_scroll.size.x:
            failures += 1
            push_error("Display report does not fit %s" % pixels)
        if not app.performance_report.snapshot.display.available or str(app.performance_report.snapshot.display.gpu).is_empty():
            failures += 1
            push_error("Native report lacks actual GPU/display")
        root.get_texture().get_image().save_png("res://dist/performance-%dx%d.png" % [pixels.x,pixels.y])
    app.performance_report.stop_recording()
    DirAccess.remove_absolute(ProjectSettings.globalize_path(app.preferences_path))
    app.queue_free()
    await process_frame
    print("Native performance report: %d failures" % failures)
    quit(1 if failures else 0)
