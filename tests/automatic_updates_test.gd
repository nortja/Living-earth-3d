extends SceneTree
var failures := 0
var checks := 0
func verify(value: bool, message: String) -> void:
    checks += 1
    if not value:
        failures += 1
        push_error(message)
func _initialize() -> void: call_deferred("run")
func run() -> void:
    var app = load("res://scenes/earth.tscn").instantiate()
    app.play_intro = false
    app.preferences_path = "user://automatic-update-test-%d.cfg" % Time.get_ticks_usec()
    root.add_child(app)
    await process_frame
    verify(app.background_updates_enabled(), "Automatic updates default on for the updater-enabled install")
    app.set_background_updates(false)
    verify(not app.background_updates_enabled() and app.update_status.text.contains("paused"), "Automatic updates can be paused")
    var saved := ConfigFile.new()
    saved.load(app.preferences_path)
    verify(saved.get_value("updates", "background", true) == false, "Paused preference persists")
    var path: String = app.preferences_path
    app.queue_free()
    await process_frame
    var restored = load("res://scenes/earth.tscn").instantiate()
    restored.play_intro = false
    restored.preferences_path = path
    root.add_child(restored)
    verify(not restored.background_updates_enabled(), "Restart respects paused updates")
    restored.set_background_updates(true)
    verify(restored.background_updates_enabled(), "Automatic updates can be resumed")
    restored.screensaver_mode = true
    var status: String = restored.update_status.text
    restored.install_update()
    verify(restored.update_status.text == status, "Screensaver never starts an update helper")
    DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
    restored.queue_free()
    await process_frame
    print("Automatic updates: %d checks, %d failures" % [checks, failures])
    quit(1 if failures else 0)
