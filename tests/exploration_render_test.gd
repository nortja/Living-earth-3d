extends SceneTree
var failures := 0
func verify(ok: bool, message: String) -> void:
    if not ok:
        failures += 1
        push_error(message)
func _initialize() -> void: call_deferred("run")
func run() -> void:
    var app = load("res://scenes/earth.tscn").instantiate()
    app.play_intro = false
    app.preferences_path = "user://exploration-render-%d.cfg" % Time.get_ticks_usec()
    app.weather_cache_path = "user://exploration-render-weather-%d.json" % Time.get_ticks_usec()
    root.add_child(app)
    var ui = app.interface
    var explorer = ui.exploration_panel
    explorer.show_place(app.exploration.catalog.places[0])
    app.exploration.toggle_save(app.exploration.catalog.places[0])
    DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://dist"))
    for pixels in [Vector2i(800,600),Vector2i(1920,1080),Vector2i(3440,1440),Vector2i(3840,2160),Vector2i(5120,1440),Vector2i(5120,2880)]:
        root.size = pixels
        ui.set_ui_scale(2.0 if pixels.y > 1080 else 1.0)
        ui.open_page("Explore") if ui.active_page != "Explore" else ui.panel.show()
        for title in ["Discover","Search","History","Saved"]:
            explorer.select_section(title)
            for frame in range(12): await process_frame
            await RenderingServer.frame_post_draw
            var bounds := Rect2(Vector2.ZERO,ui.size)
            verify(bounds.encloses(Rect2(ui.panel.position,ui.panel.size)),"Exploration panel fits %s/%s" % [pixels,title])
            verify(ui.page_scroll.get_child(0).size.x <= ui.page_scroll.size.x,"Exploration content stays within scrolling width")
            for tab in explorer.tabs.values():
                var font: Font = tab.get_theme_font("font")
                verify(tab.size.x >= font.get_string_size(tab.text,HORIZONTAL_ALIGNMENT_LEFT,-1,tab.get_theme_font_size("font_size")).x,"Explore tab readable")
            if title == "Search":
                var action: Button = ui.app.favorite_button
                var font: Font = action.get_theme_font("font")
                verify(action.size.x >= font.get_string_size(action.text,HORIZONTAL_ALIGNMENT_LEFT,-1,action.get_theme_font_size("font_size")).x,"Legacy favorite button stays readable in Search")
            var image := root.get_texture().get_image()
            verify(image.get_size() == pixels,"Native framebuffer size")
            verify(image.save_png("res://dist/explore-%s-%dx%d.png" % [title.to_lower(),pixels.x,pixels.y]) == OK,"Native exploration screenshot saved")
        ui.open_page("Command Center")
        for frame in range(12): await process_frame
        await RenderingServer.frame_post_draw
        verify(Rect2(Vector2.ZERO,ui.size).encloses(Rect2(ui.panel.position,ui.panel.size)),"Weather panel fits native viewport")
        root.get_texture().get_image().save_png("res://dist/explore-weather-%dx%d.png" % [pixels.x,pixels.y])
        print("Rendered discovery/search/history/saved/weather at %s" % pixels)
    for style in range(6):
        app.saver_style = style
        app.preview_screensaver()
        for frame in range(10): await process_frame
        await RenderingServer.frame_post_draw
        verify(not root.get_texture().get_image().is_empty() and app.ambient.suspended,"Native screensaver style %d renders quietly" % style)
        app.stop_screensaver_preview()
        for frame in range(3): await process_frame
    for path in [app.preferences_path,app.weather_cache_path]: DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
    app.queue_free()
    await process_frame
    print("Exploration native layouts and screensavers: %d failures" % failures)
    quit(1 if failures else 0)
