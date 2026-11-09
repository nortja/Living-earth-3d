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
    DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://dist"))
    var sizes: Array[Vector2i]=[Vector2i(800,600),Vector2i(1920,1080),Vector2i(3440,1440),Vector2i(3840,2160),Vector2i(5120,1440),Vector2i(5120,2880)]
    if "--compact" in OS.get_cmdline_user_args(): sizes=[Vector2i(870,612)]
    for pixels in sizes:
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
        if not ui.page_scroll.get_global_rect().encloses(ui.performance_record.get_global_rect()) or not ui.page_scroll.get_global_rect().encloses(ui.performance_save.get_global_rect()):
            failures += 1
            push_error("Recording/save actions require scrolling")
        var display: Dictionary = app.performance_report.snapshot.display
        var topology_events:Array=app.performance_report.snapshot.recording.topology_events
        if topology_events.is_empty() or not topology_events[0].topology.available or topology_events[0].topology.monitors.size()!=DisplayServer.get_screen_count() or topology_events[0].topology.active_screen!=root.current_screen:
            failures += 1
            push_error("Recorded topology baseline lacks the actual native monitor inventory")
        var contexts:Array=app.performance_report.snapshot.recording.contexts
        if contexts.is_empty() or contexts[-1].context.viewport_pixels != [pixels.x,pixels.y]:
            failures += 1
            push_error("Native recording context lacks the current measured viewport")
        if display.monitors.size() != DisplayServer.get_screen_count() or display.active_screen != root.current_screen:
            failures += 1
            push_error("Native report lacks complete monitor inventory or active screen")
        for monitor in display.monitors:
            var actual := DisplayServer.screen_get_size(monitor.index)
            if monitor.pixels != [actual.x,actual.y] or monitor.scale != DisplayServer.screen_get_scale(monitor.index):
                failures += 1
                push_error("Monitor geometry/scale differs from display server")
        root.get_texture().get_image().save_png("res://dist/performance-%dx%d.png" % [pixels.x,pixels.y])
    app.performance_report.stop_recording()
    if app.performance_report.record_contexts.size()<sizes.size():
        failures += 1
        push_error("Native recording did not separate changed viewport sizes")
    DirAccess.remove_absolute(ProjectSettings.globalize_path(app.preferences_path))
    app.queue_free()
    await process_frame
    print("Native performance report: %d failures" % failures)
    quit(1 if failures else 0)
