extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
    var service = load("res://scripts/weather_service.gd").new()
    service.cache_path = "user://weather-live-%d.json" % Time.get_ticks_usec()
    root.add_child(service)
    create_timer(30).timeout.connect(func(): push_error("Weather provider timeout");quit(1))
    service.request_weather({"name":"Three Rivers, California","latitude":36.4388,"longitude":-118.9045})
    while service.loading: await service.weather_changed
    var success: bool = not service.weather.is_empty() and service.weather.name == "Three Rivers, California"
    if success: print("PASS: actual Open-Meteo point model parsed, model UTC %s. This is a model estimate, not a station observation." % service.weather.utc)
    else: push_error(service.weather_status)
    DirAccess.remove_absolute(ProjectSettings.globalize_path(service.cache_path))
    service.queue_free()
    await process_frame
    quit(0 if success else 1)
