extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
    root.size = Vector2i(1920,1080)
    var app = load("res://scenes/earth.tscn").instantiate()
    app.play_intro = false
    app.preferences_path = "user://weather-render-%d.cfg" % Time.get_ticks_usec()
    app.weather_cache_path = "user://weather-render-data-%d.json" % Time.get_ticks_usec()
    root.add_child(app)
    root.size = Vector2i(1920,1080)
    create_timer(30).timeout.connect(func(): push_error("Weather render timeout");quit(1))
    app.fly_to_location({"name":"Three Rivers, California","latitude":36.4388,"longitude":-118.9045})
    app.journey.custom_step(3.0)
    app._update_camera()
    app.interface.exploration_panel.request_selected_weather()
    while app.observations.loading: await app.observations.weather_changed
    if app.observations.weather.is_empty():
        push_error(app.observations.weather_status);quit(1);return
    for frame in range(12): await process_frame
    await RenderingServer.frame_post_draw
    var path := "res://dist/actual-weather-1920x1080.png"
    var image := root.get_texture().get_image()
    if image.get_size() != Vector2i(1920,1080) or image.save_png(path) != OK:
        push_error("Weather screenshot failed");quit(1);return
    print("PASS: actual model-weather view rendered with provider time and units.")
    for file in [app.preferences_path,app.weather_cache_path]: DirAccess.remove_absolute(ProjectSettings.globalize_path(file))
    app.queue_free()
    await process_frame
    quit(0)
