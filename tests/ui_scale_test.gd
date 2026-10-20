extends SceneTree
var checks := 0
var failures := 0
func verify(value: bool, message: String) -> void:
    checks += 1
    if not value:
        failures += 1
        push_error(message)
func _initialize() -> void: call_deferred("run")
func run() -> void:
    var app = load("res://scenes/earth.tscn").instantiate()
    app.play_intro = false
    app.preferences_path = "user://ui-scale-test-%d.cfg" % Time.get_ticks_usec()
    root.add_child(app)
    var ui = app.interface
    verify(ui.preferred_scale == 0.0, "Fresh installation uses Automatic")
    ui.open_page("Settings")
    for pixels in [Vector2i(800, 600), Vector2i(1920, 1080), Vector2i(3440, 1440), Vector2i(3840, 2160), Vector2i(5120, 1440), Vector2i(5120, 2880)]:
        root.size = pixels
        for value in ui.SCALE_OPTIONS:
            ui.set_ui_scale(value)
            for frame in range(10): await process_frame
            var bounds := Rect2(Vector2.ZERO, ui.size)
            for control in [ui.header, ui.dock, ui.panel]:
                verify(bounds.encloses(Rect2(control.position, control.size)), "Controls remain within %s at size %s: %s" % [pixels, value, control.get_class()])
            verify(not Rect2(ui.panel.position, ui.panel.size).has_point(ui.size / 2), "Settings leave globe center clear at %s / %s" % [pixels, value])
            verify(Vector2i(ui.size * ui.scale) == pixels, "Interface scaling preserves native viewport dimensions")
    root.size = Vector2i(800, 600)
    ui.set_ui_scale(2.0)
    for frame in range(10): await process_frame
    verify(ui.display_scale == 1.0 and ui.scale_status.text.contains("reduced to fit"), "Small window explains temporary size limit")
    root.size = Vector2i(3840, 2160)
    for frame in range(10): await process_frame
    verify(ui.display_scale == 2.0 and ui.preferred_scale == 2.0, "Growing window restores selected size")
    var settings := ConfigFile.new()
    settings.load(app.preferences_path)
    verify(settings.get_value("interface", "ui_scale") == 2.0, "Chosen size persisted")
    var path: String = app.preferences_path
    app.queue_free()
    await process_frame
    var restored = load("res://scenes/earth.tscn").instantiate()
    restored.play_intro = false
    restored.preferences_path = path
    root.add_child(restored)
    verify(restored.interface.preferred_scale == 2.0 and restored.interface.scale_picker.selected == 5, "Selected size restores after restart")
    restored.interface.set_ui_scale(NAN)
    verify(restored.interface.preferred_scale == 0.0, "Invalid requested size falls back to Automatic")
    restored.preferences.set_value("interface", "ui_scale", "invalid")
    restored._save_preferences()
    restored.queue_free()
    await process_frame
    var recovered = load("res://scenes/earth.tscn").instantiate()
    recovered.play_intro = false
    recovered.preferences_path = path
    root.add_child(recovered)
    verify(recovered.interface.preferred_scale == 0.0, "Corrupt saved size recovers without a startup error")
    DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
    recovered.queue_free()
    await process_frame
    print("Interface scale: %d checks, %d failures" % [checks, failures])
    quit(1 if failures else 0)
