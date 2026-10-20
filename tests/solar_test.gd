extends SceneTree
const Solar = preload("res://scripts/solar_position.gd")
var failures := 0
var checks := 0
func verify(ok: bool, message: String) -> void:
    checks += 1
    if not ok:
        failures += 1
        push_error(message)
func sample(date: String) -> Dictionary:
    return Solar.at_unix(Time.get_unix_time_from_datetime_string(date))
func _initialize() -> void: call_deferred("run")
func run() -> void:
    var june := sample("2026-06-21T12:00:00")
    var december := sample("2026-12-21T12:00:00")
    var march := sample("2026-03-20T12:00:00")
    verify(absf(june.latitude - 23.44) < 0.5, "June Sun near Tropic of Cancer")
    verify(absf(december.latitude + 23.44) < 0.5, "December Sun near Tropic of Capricorn")
    verify(absf(march.latitude) < 0.6, "Equinox Sun near equator")
    verify(absf(march.longitude - 2.0) < 0.5, "Equation of time shifts equinox solar noon east of Greenwich")
    var midnight := sample("2026-03-20T00:00:00")
    verify(absf(wrapf(midnight.longitude - march.longitude, -180, 180)) > 179, "UTC midnight Sun on opposite longitude")
    for date in ["2024-02-29T23:59:59", "2000-12-31T12:00:00", "2100-03-01T00:00:00"]:
        var sun := sample(date)
        verify(absf(sun.direction.length() - 1.0) < 0.00001, "Leap/century result normalized: " + date)
        verify(sun.longitude >= -180 and sun.longitude < 180, "Longitude wraps: " + date)
    var app = load("res://scenes/earth.tscn").instantiate()
    app.play_intro = false
    app.preferences_path = "user://solar-test-%d.cfg" % Time.get_ticks_usec()
    root.add_child(app)
    app.set_utc_sunlight(true)
    verify(app.interface.sunlight_toggle.button_pressed, "Sunlight control matches enabled state")
    var local_before: Vector3 = app.earth.global_basis.inverse() * app.sun.global_basis.z
    app.earth.rotate_y(1.4)
    app.update_sunlight()
    var local_after: Vector3 = app.earth.global_basis.inverse() * app.sun.global_basis.z
    verify(local_before.distance_to(local_after) < 0.0001, "Geographic sunlight remains fixed during cinematic spin")
    verify(local_after.distance_to(app.solar_sample.direction) < 0.0001, "Shader/light direction matches geographic convention")
    verify(app.interface.solar_status.text.contains("UTC"), "Calculation UTC disclosed")
    app.preferences.load(app.preferences_path)
    verify(app.preferences.get_value("visuals", "utc_sunlight", false), "Sunlight choice saved")
    app.set_utc_sunlight(false)
    verify(not app.interface.sunlight_toggle.button_pressed, "Sunlight control matches disabled state")
    verify(app.interface.solar_status.text.contains("Cinematic"), "Cinematic mode restored")
    DirAccess.remove_absolute(ProjectSettings.globalize_path(app.preferences_path))
    app.queue_free()
    await process_frame
    print("Sunlight: %d checks, %d failures" % [checks, failures])
    quit(1 if failures else 0)
