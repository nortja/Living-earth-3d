extends SceneTree
func _initialize() -> void:
    call_deferred("run")
func run() -> void:
    var app = load("res://scenes/earth.tscn").instantiate()
    app.preferences_path = "user://native-render-isolated.cfg"
    app.weather_cache_path = "user://native-render-weather.json"
    root.add_child(app)
    if app.get("weather_layer") != null or not app.native_saver or not app.ambient.suspended or Engine.max_fps != (15 if app.native_saver_preview else 30):
        push_error("Native saver budget, silence or weather isolation failed")
        quit(1)
        return
    root.min_size = Vector2i.ZERO
    for size in [Vector2i(320,200),Vector2i(580,330),Vector2i(1920,1080),Vector2i(5120,1440)]:
        root.size = size
        for frame in range(8): await process_frame
        await RenderingServer.frame_post_draw
        var image := root.get_texture().get_image()
        if image.get_size() != size or app.interface_layer.visible:
            push_error("Native saver render dimensions or hidden UI failed")
            quit(1)
            return
        image.save_png("res://dist/saver-%dx%d.png" % [size.x,size.y])
    print("Native saver renders: 4 sizes, 0 failures")
    app.queue_free()
    await process_frame
    quit()
