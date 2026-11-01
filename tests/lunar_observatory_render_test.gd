extends SceneTree
var failures := 0
func _initialize() -> void: call_deferred("run")
func verify(ok: bool, message: String) -> void:
    if not ok: failures += 1;push_error(message)
func run() -> void:
    var app = load("res://scenes/earth.tscn").instantiate()
    app.play_intro = false
    app.preferences_path = "user://lunar-render-%d.cfg" % Time.get_ticks_usec()
    root.add_child(app)
    var ui = app.interface
    var viewer = ui.lunar_observatory
    viewer.open()
    viewer.select_date("2026-11-01")
    for pixels in [Vector2i(800,600),Vector2i(1920,1080),Vector2i(3440,1440),Vector2i(3840,1080),Vector2i(3840,2160),Vector2i(5120,1440),Vector2i(5120,2880)]:
        root.size = pixels
        for frame in range(16): await process_frame
        await RenderingServer.frame_post_draw
        verify(Rect2(Vector2.ZERO,ui.size).encloses(viewer.close_button.get_rect()),"Lunar close action visible at %s" % pixels)
        verify(Rect2(Vector2.ZERO,ui.size).encloses(viewer.disc.get_rect()) and viewer.disc.size.x>=300,"Moon disk has a usable size and fits viewport")
        verify(viewer.scroll.get_global_rect().encloses(viewer.now_button.get_global_rect()) and viewer.scroll.get_global_rect().encloses(viewer.date_input.get_global_rect()),"Lunar current-time and date controls visible")
        verify(viewer.view_button.size.x>=88 and viewer.scroll.get_global_rect().encloses(viewer.view_button.get_global_rect()),"View date button readable without clipping")
        verify(viewer.scroll.get_child(0).size.x<=viewer.scroll.size.x,"Lunar sidebar has no horizontal overflow")
        root.get_texture().get_image().save_png("res://dist/lunar-%dx%d.png" % [pixels.x,pixels.y])
    root.size = Vector2i(1920,1080)
    for date in ["2026-01-18","2026-01-26","2026-02-01","2026-02-09","2027-04-22"]:
        viewer.select_date(date)
        for frame in range(8): await process_frame
        await RenderingServer.frame_post_draw
        root.get_texture().get_image().save_png("res://dist/lunar-date-%s.png" % date)
    viewer.close()
    DirAccess.remove_absolute(ProjectSettings.globalize_path(app.preferences_path))
    app.queue_free()
    await process_frame
    print("Native lunar observatory: %d failures" % failures)
    quit(1 if failures else 0)
