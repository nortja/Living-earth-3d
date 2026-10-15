extends SceneTree
var failures := 0
func _initialize() -> void: call_deferred("run")
func run() -> void:
    var app = load("res://scenes/earth.tscn").instantiate()
    app.play_intro = false
    app.preferences_path = "user://experience-render-%d.cfg" % Time.get_ticks_usec()
    root.add_child(app)
    root.size = Vector2i(1920, 1080)
    var output := "res://build/experience-060"
    DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
    await create_timer(0.8).timeout
    for page in ["Explore", "Cameras", "Live Earth", "Command Center", "Screensavers", "Settings"]:
        app.interface.open_page(page)
        for frame in range(12): await process_frame
        var panel: Control = app.interface.panel
        if not Rect2(Vector2.ZERO, app.interface.size).encloses(Rect2(panel.position, panel.size)):
            failures += 1
            push_error("Experience panel leaves screen: " + page)
        await RenderingServer.frame_post_draw
        root.get_texture().get_image().save_png(output.path_join(page.replace(" ", "-").to_lower() + ".png"))
    if app.favorite_button.clip_text or app.favorite_button.size.x < 60:
        failures += 1
        push_error("Favorite controls have no readable label width")
    app.interface.open_page("Explore")
    for button in app.find_children("*", "Button", true, false):
        if button.text == "Time Machine": button.pressed.emit()
    app.interface.history_toggle.button_pressed = true
    app.interface.history_slider.value = -2550
    for frame in range(12): await process_frame
    await RenderingServer.frame_post_draw
    root.get_texture().get_image().save_png(output.path_join("historical-atlas.png"))
    if not app.interface.history_banner.visible:
        failures += 1
        push_error("Historical imagery disclosure missing")
    app.interface.history_toggle.button_pressed = false
    app.interface.close_panel()
    app.set_solar(true)
    app.daylight_line = true
    app.fly_to_location({"name": "Calculated sunlight view", "latitude": 0.0, "longitude": wrapf(app.solar_info.longitude + 65, -180, 180)})
    app.journey.custom_step(3.0)
    app._update_camera()
    for frame in range(12): await process_frame
    await RenderingServer.frame_post_draw
    root.get_texture().get_image().save_png(output.path_join("utc-daylight.png"))
    if not app.terminator.visible:
        failures += 1
        push_error("Calculated daylight line missing")
    DirAccess.remove_absolute(ProjectSettings.globalize_path(app.preferences_path))
    print("Experience render: 6 pages + historical atlas + UTC sunlight; %d failures" % failures)
    quit(1 if failures else 0)
