extends SceneTree
var failures := 0
func _initialize() -> void: call_deferred("run")
func run() -> void:
    var app = load("res://scenes/earth.tscn").instantiate()
    app.play_intro = false
    app.preferences_path = "user://observed-render-%d.cfg" % Time.get_ticks_usec()
    root.add_child(app)
    var service = app.observed_weather
    var image := Image.create(2560,1280,false,Image.FORMAT_RGBA8)
    image.fill(Color.TRANSPARENT)
    image.fill_rect(Rect2i(60,300,960,680),Color(0.5,0.5,0.5,1))
    service.texture = ImageTexture.create_from_image(image)
    service.observed_source = 0
    service.observed_time = "2026-11-01T17:40:00Z"
    service.retrieved = "Synthetic layout fixture · not an observation"
    var real := false
    for arg in OS.get_cmdline_user_args():
        if arg.begins_with("--real-infrared="):
            var prefix := arg.trim_prefix("--real-infrared=")
            var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(prefix+".json"))
            var observed := Image.load_from_file(prefix+".png")
            service.texture = ImageTexture.create_from_image(observed)
            service.observed_source = int(data.source)
            service.observed_time = str(data.time)
            service.retrieved = str(data.retrieved)
            real = true
    service.set_enabled(true)
    service.status = "Actual NOAA provider retrieval · render verification" if real else "Synthetic regional infrared fixture · layout test only"
    service.changed.emit()
    service.focus_coverage()
    app.journey.custom_step(3.0)
    app._update_camera()
    var ui = app.interface
    ui.open_page("Satellite weather")
    var sizes := [Vector2i(800,600),Vector2i(1920,1080),Vector2i(2496,1664),Vector2i(3440,1440),Vector2i(3840,1080),Vector2i(3840,2160),Vector2i(5120,1440),Vector2i(5120,2880)]
    if "--single-preview" in OS.get_cmdline_user_args(): sizes = [Vector2i(1920,1080)]
    for pixels in sizes:
        root.size = pixels
        for frame in range(16): await process_frame
        await RenderingServer.frame_post_draw
        for control in [ui.observed_load,ui.observed_region,ui.observed_return,ui.observed_source_picker,ui.observed_offset_picker]:
            if not ui.page_scroll.get_global_rect().encloses(control.get_global_rect()):
                failures += 1;push_error("Observed-weather %s %s clipped in %s at %s" % [control.get_class(),control.get_global_rect(),ui.page_scroll.get_global_rect(),pixels])
        if ui.page_scroll.get_child(0).size.x>ui.page_scroll.size.x:
            failures += 1;push_error("Observed weather horizontal overflow")
        root.get_texture().get_image().save_png("res://dist/observed-%dx%d.png" % [pixels.x,pixels.y])
        if real:
            ui.page_scroll.scroll_vertical = 260
            for frame in range(8): await process_frame
            await RenderingServer.frame_post_draw
            root.get_texture().get_image().save_png("res://dist/observed-legend-%dx%d.png" % [pixels.x,pixels.y])
            ui.close_panel()
            for frame in range(12): await process_frame
            await RenderingServer.frame_post_draw
            root.get_texture().get_image().save_png("res://dist/observed-earth-%dx%d.png" % [pixels.x,pixels.y])
        ui.open_page("Live Earth")
        for frame in range(12): await process_frame
        for control in ui.live_primary:
            if not ui.page_scroll.get_global_rect().encloses(control.get_global_rect()):
                failures += 1;push_error("Primary Live Earth action clipped at %s: %s" % [pixels,control.text])
        root.get_texture().get_image().save_png("res://dist/observed-menu-%dx%d.png" % [pixels.x,pixels.y])
        ui.open_page("Satellite weather")
    app.preview_screensaver()
    if app.earth_material.get_shader_parameter("observed_weather_view"): failures += 1
    app.stop_screensaver_preview()
    DirAccess.remove_absolute(ProjectSettings.globalize_path(app.preferences_path))
    app.queue_free()
    await process_frame
    print("Native observed weather: %d failures" % failures)
    quit(1 if failures else 0)
