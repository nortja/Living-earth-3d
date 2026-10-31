extends SceneTree
var failures:=0
func _initialize() -> void:call_deferred("run")
func run() -> void:
    var app=load("res://scenes/earth.tscn").instantiate()
    app.play_intro=false
    app.preferences_path="user://atlas-render-%d.cfg" % Time.get_ticks_usec()
    root.add_child(app)
    var ui=app.interface
    ui.open_page("Explore")
    ui.exploration_panel.select_section("Search")
    for pixels in [Vector2i(800,600),Vector2i(1920,1080),Vector2i(3440,1440),Vector2i(3840,1080),Vector2i(3840,2160),Vector2i(5120,1440),Vector2i(5120,2880)]:
        root.size=pixels
        ui.search_query.text="USA"
        ui.search_query.text_submitted.emit("USA")
        ui.page_scroll.scroll_vertical=0
        for frame in range(16):await process_frame
        await RenderingServer.frame_post_draw
        if not Rect2(Vector2.ZERO,ui.size).encloses(ui.panel.get_rect()) or ui.page_scroll.get_child(0).size.x>ui.page_scroll.size.x:
            failures+=1;push_error("Offline atlas does not fit viewport")
        if not ui.page_scroll.get_global_rect().encloses(ui.offline_next.get_global_rect()):
            failures+=1;push_error("Offline paging action is clipped")
        if ui.search_results.get_child_count()>0 and not ui.page_scroll.get_global_rect().encloses(ui.search_results.get_child(0).get_global_rect()):
            failures+=1;push_error("First offline result requires scrolling")
        root.get_texture().get_image().save_png("res://dist/atlas-%dx%d.png" % [pixels.x,pixels.y])
        ui._search_offline("a")
        ui.offline_next.pressed.emit()
        ui.page_scroll.scroll_vertical=0
        for frame in range(16):await process_frame
        await RenderingServer.frame_post_draw
        if not ui.offline_previous.visible or not ui.offline_next.visible or not ui.page_scroll.get_global_rect().encloses(ui.search_results.get_child(0).get_global_rect()):
            failures+=1;push_error("Middle-page controls leave first result clipped")
        root.get_texture().get_image().save_png("res://dist/atlas-paging-%dx%d.png" % [pixels.x,pixels.y])
    ui._search_offline("Vancouver")
    ui.search_results.get_child(0).pressed.emit()
    app.journey.custom_step(3.0)
    for frame in range(16):await process_frame
    await RenderingServer.frame_post_draw
    if app.exploration.location.name!="Vancouver, Canada":failures+=1;push_error("Atlas journey opened wrong source")
    root.get_texture().get_image().save_png("res://dist/atlas-arrival.png")
    DirAccess.remove_absolute(ProjectSettings.globalize_path(app.preferences_path))
    app.queue_free();await process_frame
    print("Native offline atlas: %d failures" % failures)
    quit(1 if failures else 0)
