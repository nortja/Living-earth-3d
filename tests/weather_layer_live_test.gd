extends SceneTree
## Optional real-network check. No fixture or startup path invokes this test.
func _initialize() -> void: call_deferred("run")
func run() -> void:
    var app=load("res://scenes/earth.tscn").instantiate()
    app.play_intro=false
    app.preferences_path="user://weather-live-%d.cfg" % Time.get_ticks_usec()
    app.weather_layer_cache_path="user://weather-live-%d.json" % Time.get_ticks_usec()
    root.add_child(app)
    var layer=app.weather_layer
    layer.refresh()
    var deadline:=Time.get_ticks_msec()+30000
    while layer.loading and Time.get_ticks_msec()<deadline:await create_timer(0.2).timeout
    await process_frame
    var passed:bool=not layer.loading and layer.points.size()==layer.places.size() and layer.points.size()==32
    if passed:
        var cache=JSON.parse_string(FileAccess.get_file_as_string(layer.cache_path))
        var file:=FileAccess.open("res://dist/weather-32-real.json",FileAccess.WRITE)
        if file:file.store_string(JSON.stringify(cache.feed));file.close()
        print("Real Open-Meteo layer: PASS · %d/%d dated model points; local provider estimates, not observations" % [layer.points.size(),layer.places.size()])
    else:push_error("Real model layer: %d/%d accepted · %s" % [layer.points.size(),layer.places.size(),layer.status])
    layer.cancel()
    for path in [app.preferences_path,layer.cache_path]:DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
    app.queue_free();await process_frame
    quit(0 if passed else 1)
