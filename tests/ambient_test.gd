extends SceneTree
var failures := 0
func check(value: bool, message: String) -> void:
    if not value:
        failures += 1
        push_error(message)
func _initialize() -> void: call_deferred("run")
func run() -> void:
    var app = load("res://scenes/earth.tscn").instantiate()
    app.play_intro = false
    app.preferences_path = "user://ambient-test-%d.cfg" % Time.get_ticks_usec()
    root.add_child(app)
    await process_frame
    check(not app.ambient.enabled and not app.ambient.playing, "Fresh installation is silent")
    app.ambient.enabled = true
    app.ambient.level = 0.4
    app.ambient.apply()
    check(app.ambient.playing and app.ambient.stream.loop_end == 128000, "Enabling starts an offline loop")
    app.preferences.set_value("audio", "enabled", true)
    app.preferences.set_value("audio", "volume", 0.4)
    app._save_preferences()
    var settings := ConfigFile.new()
    settings.load(app.preferences_path)
    var restored = load("res://scripts/ambient_sound.gd").new()
    root.add_child(restored)
    restored.setup(settings, true)
    check(restored.enabled and is_equal_approx(restored.level, 0.4) and not restored.playing, "Preferences restore; screensaver launch stays silent")
    app.preview_screensaver()
    await create_timer(0.8).timeout
    check(not app.ambient.playing, "Screensaver preview fades to silence")
    app.stop_screensaver_preview()
    check(app.ambient.playing, "Return restores opted-in sound")
    app.ambient.level = 0.0
    app.ambient.apply()
    await create_timer(0.8).timeout
    check(not app.ambient.playing, "Zero volume stops playback")
    DirAccess.remove_absolute(app.preferences_path)
    restored.queue_free()
    app.queue_free()
    await process_frame
    print("Ambient audio: 6 checks, %d failures" % failures)
    quit(1 if failures else 0)
