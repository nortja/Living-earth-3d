extends SceneTree
var failures := 0
func _initialize() -> void: call_deferred("run")
func run() -> void:
    var app = load("res://scenes/earth.tscn").instantiate()
    app.play_intro = false
    app.preferences_path = "user://saver-soak-%d.cfg" % Time.get_ticks_usec()
    root.add_child(app)
    for style in range(6):
        app.saver_style = style
        app.preview_screensaver()
        await create_timer(8.0).timeout
        if not app.screensaver_mode or app.interface_layer.visible or not app.camera.position.is_finite():
            failures += 1
            push_error("Screensaver preview failed in style %d" % style)
        app.stop_screensaver_preview()
        if app.screensaver_mode or not app.interface_layer.visible or app.visuals.moon_enabled:
            failures += 1
            push_error("Preview state was not restored in style %d" % style)
        await process_frame
    DirAccess.remove_absolute(ProjectSettings.globalize_path(app.preferences_path))
    print("Native saver run: 6 styles × 8 real seconds; %d failures. Hours-long soak remains unrun." % failures)
    quit(1 if failures else 0)
