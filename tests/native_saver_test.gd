extends SceneTree
var checks := 0
var failures := 0
func check(value: bool, title: String) -> void:
    checks += 1
    if not value:
        failures += 1
        push_error(title)
func _initialize() -> void:
    call_deferred("run")
func run() -> void:
    var app = load("res://scenes/earth.tscn").instantiate()
    app.preferences_path = "user://native-saver-test.cfg"
    app.weather_cache_path = "user://native-saver-weather.json"
    var prefs := ConfigFile.new()
    prefs.set_value("visuals", "quality", "detailed")
    prefs.set_value("visuals", "power_saving", false)
    prefs.set_value("screensaver", "style", 5)
    prefs.save(app.preferences_path)
    root.add_child(app)
    await process_frame
    check(app.native_saver, "Host flag enters native saver mode")
    check(app.screensaver_mode, "Hosted renderers are screensavers")
    check(not app.play_intro and not app.intro_running, "Hosted renderer skips intro")
    check(not app.interface_layer.visible, "Hosted renderer hides explorer")
    check(app.visual_quality == "balanced", "Hosted texture budget uses 2K")
    check(app.preferences.get_value("visuals", "quality") == "detailed", "Explorer quality preference preserved")
    check(app.saver_style == 5, "Saved screensaver style retained")
    check(Engine.max_fps == (15 if app.native_saver_preview else 30), "Preview/fullscreen frame budget")
    check(app.observations.weather_request == null, "No weather networking")
    check(app.services.quake_request.get_http_client_status() == HTTPClient.STATUS_DISCONNECTED, "No earthquake networking")
    check(not app.ambient.playing, "Saver stays silent")
    var key := InputEventKey.new()
    key.keycode = KEY_ESCAPE
    app.screensaver_age = 10
    app._unhandled_input(key)
    check(not app.is_queued_for_deletion(), "Native host owns input lifecycle")
    app.queue_free()
    await process_frame
    DirAccess.remove_absolute("user://native-saver-test.cfg")
    print("Native saver: %d checks, %d failures" % [checks, failures])
    quit(1 if failures else 0)
