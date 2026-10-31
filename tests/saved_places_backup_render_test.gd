extends SceneTree
var failures:=0
func _initialize() -> void:call_deferred("run")
func run() -> void:
    var app=load("res://scenes/earth.tscn").instantiate()
    app.play_intro=false
    app.preferences_path="user://backup-render-%d.cfg" % Time.get_ticks_usec()
    root.add_child(app)
    var ui=app.interface
    ui.open_page("Explore")
    ui.exploration_panel.select_section("Saved")
    var panel=ui.exploration_panel
    for pixels in [Vector2i(800,600),Vector2i(1920,1080),Vector2i(3840,1080),Vector2i(5120,2880)]:
        root.size=pixels
        ui.page_scroll.scroll_vertical=0
        for frame in range(16):await process_frame
        await RenderingServer.frame_post_draw
        if not Rect2(Vector2.ZERO,ui.size).encloses(ui.panel.get_rect()) or ui.page_scroll.get_child(0).size.x>ui.page_scroll.size.x:
            failures+=1;push_error("Saved backup controls do not fit viewport")
        if not ui.page_scroll.get_global_rect().encloses(panel.backup_export.get_global_rect()) or not ui.page_scroll.get_global_rect().encloses(panel.backup_import.get_global_rect()):
            failures+=1;push_error("Backup export/import needs scrolling")
        root.get_texture().get_image().save_png("res://dist/backup-%dx%d.png" % [pixels.x,pixels.y])
    DirAccess.remove_absolute(ProjectSettings.globalize_path(app.preferences_path))
    app.queue_free();await process_frame
    print("Native saved-place backups: %d failures" % failures)
    quit(1 if failures else 0)
