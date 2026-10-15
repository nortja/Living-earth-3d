extends SceneTree
const Solar = preload("res://scripts/solar_model.gd")
const Observations = preload("res://scripts/earth_observations.gd")
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("run")
func verify(condition: bool, message: String) -> void:
    checks += 1
    if not condition:
        failures += 1
        push_error(message)
func utc(date: String) -> float: return float(Time.get_unix_time_from_datetime_string(date))
func run() -> void:
    var june := Solar.at_unix(utc("2026-06-21T12:00:00"))
    var december := Solar.at_unix(utc("2026-12-21T12:00:00"))
    var march := Solar.at_unix(utc("2026-03-20T15:00:00"))
    verify(abs(june.latitude - 23.44) < 0.1, "June solstice subsolar latitude")
    verify(abs(december.latitude + 23.44) < 0.1, "December solstice subsolar latitude")
    verify(abs(march.latitude) < 0.15, "March equinox subsolar latitude")
    verify(abs(june.longitude) < 1.0, "UTC noon Sun near Greenwich")
    var later := Solar.at_unix(utc("2026-06-21T18:00:00"))
    verify(abs(wrapf(later.longitude - june.longitude + 90, -180, 180)) < 0.2, "Sun longitude shifts west 90 degrees over six hours")
    verify(abs(june.direction.length() - 1.0) < 0.0001, "Solar direction normalized")
    var app = load("res://scenes/earth.tscn").instantiate()
    app.play_intro = false
    app.preferences_path = "user://cycle06-test-%d.cfg" % Time.get_ticks_usec()
    root.add_child(app)
    await process_frame
    var ui = app.interface
    verify(app.BUILD_CHANNEL == "development" and app.UPDATE_FEED_URL.contains("/development/"), "Development feed isolated from main preview")
    var feed := {"version": "0.7.0", "channel": "stable", "installer_signed": true, "sha256": "a".repeat(64), "installer_url": "https://github.com/nortja/Living-earth-3d/raw/refs/heads/downloads/windows-0.7.0/LivingEarth3D-Setup-0.7.0.exe"}
    verify(not app.valid_update_feed(feed), "Stable feed cannot cross into development")
    feed.channel = "development"
    verify(app.valid_update_feed(feed), "Correct development feed accepted")
    for latitude in [-90.0, 90.0]:
        app.fly_to_location({"name": "Pole navigation test", "latitude": latitude, "longitude": 0.0})
        app.journey.custom_step(3.0)
        app._update_camera()
        verify(app.camera.basis.z.normalized().dot(app.camera.position.normalized()) > 0.9999 and app.camera.basis.is_finite(), "Exact polar navigation keeps a valid camera orientation")
    app.reset_view()
    app.journey.custom_step(1.0)
    app.set_solar(true)
    app.daylight_line = true
    app.refresh_solar()
    verify(app.terminator.visible, "UTC daylight line enabled")
    var expected: Vector3 = app.earth.basis * Vector3(app.solar_info.direction)
    verify(app.sun.basis.z.normalized().dot(expected.normalized()) > 0.9999, "World lighting matches geographic solar model")
    app.earth.rotate_y(1.0)
    app.apply_lighting()
    expected = app.earth.basis * Vector3(app.solar_info.direction)
    verify(app.sun.basis.z.normalized().dot(expected.normalized()) > 0.9999, "Sun tracks globe orientation correctly")
    app.set_solar(false)
    verify(not app.terminator.visible, "Cinematic mode hides calculated daylight line")
    var day: float = utc("2026-10-15T00:00:00")
    verify(app.catalog.daily(day).id == app.catalog.daily(day + 86399).id, "Daily discovery stable throughout UTC day")
    verify(app.catalog.daily(day).id != app.catalog.daily(day + 86400).id, "Daily discovery changes at UTC midnight")
    verify(app.catalog.places.size() >= 12, "Curated wonder catalog loaded")
    for place in app.catalog.places:
        verify(place.source.begins_with("https://") and place.note.length() > 40 and app.services.valid_coordinates(place.latitude, place.longitude), "Wonder has source, meaningful note and coordinates")
        if place.has("camera_id"):
            verify(ui.cameras.any(func(camera): return camera.id == place.camera_id), "Discovery camera connection exists")
    ui.show_discovery(app.catalog.places[0])
    verify(app.external_focus and app.description.text.contains(app.catalog.places[0].note), "Discovery animates globe and explains place")
    ui.camera_selection = 0
    ui.surprise_camera()
    verify(ui.camera_selection != 0 and app.external_focus, "Camera surprise changes venue")
    ui.open_page("Cameras")
    ui.select_camera(0)
    app.journey.custom_step(3.0)
    app._update_camera()
    var marker: Node3D = app.camera_markers.get_child(0)
    verify(app.camera_at_screen(app.camera.unproject_position(marker.global_position)) == 0, "Visible camera marker can be picked on the globe")
    ui.close_panel()
    verify(not app.camera_markers.visible and app.camera_at_screen(Vector2.ZERO) == -1, "Camera markers leave the default globe uncluttered")
    var obs = app.observations
    obs.cache_path = "user://weather-test-%d.json" % Time.get_ticks_usec()
    var location := {"name": "Fixture city", "latitude": 40.0, "longitude": -73.0}
    var weather := {"current": {"temperature_2m": 15.5, "wind_speed_10m": 12.0, "relative_humidity_2m": 70, "weather_code": 3, "time": "2026-10-15T12:00"}, "current_units": {"temperature_2m": "°C", "wind_speed_10m": "km/h", "relative_humidity_2m": "%"}, "utc_offset_seconds": 0}
    verify(not Observations.parse_weather(weather, location).is_empty(), "Weather model values and units accepted")
    var invalid := weather.duplicate(true)
    invalid.current.relative_humidity_2m = 150
    verify(Observations.parse_weather(invalid, location).is_empty(), "Invalid humidity rejected")
    invalid = weather.duplicate(true)
    invalid.current_units.temperature_2m = "°F"
    verify(Observations.parse_weather(invalid, location).is_empty(), "Unexpected weather units rejected")
    invalid = weather.duplicate(true)
    invalid.current.time = "2026-02-30T25:00"
    verify(Observations.parse_weather(invalid, location).is_empty(), "Impossible model date/time rejected")
    invalid = weather.duplicate(true)
    invalid.utc_offset_seconds = 3600
    verify(Observations.parse_weather(invalid, location).is_empty(), "Non-UTC model time cannot be mislabeled UTC")
    obs.weather_pending = location
    obs._weather_received(0, 200, PackedStringArray(), JSON.stringify(weather).to_utf8_buffer())
    verify(obs.weather.name == "Fixture city" and obs.weather_status.contains("model estimate"), "Weather context and model label retained")
    obs.weather_pending = {"name": "Another place", "latitude": -20, "longitude": 100}
    obs._weather_received(HTTPRequest.RESULT_CANT_CONNECT, 0, PackedStringArray(), PackedByteArray())
    verify(obs.weather.name == "Fixture city" and obs.weather_status.contains("Another place") and obs.weather_status.contains("Fixture city"), "Failed request never relabels cached weather as another location")
    var restored = Observations.new()
    restored.cache_path = obs.cache_path
    root.add_child(restored)
    verify(restored.weather.name == "Fixture city" and restored.weather_status.begins_with("Cached"), "Weather disk cache explicitly restored as cached")
    obs.camera_id = ui.cameras[0].id
    obs._camera_received(0, 200, PackedStringArray(), PackedByteArray())
    verify(obs.camera_checks[obs.camera_id].contains("stream status unverified"), "Reachable provider page never becomes verified-live stream")
    obs._camera_received(HTTPRequest.RESULT_CANT_CONNECT, 0, PackedStringArray(), PackedByteArray())
    verify(obs.camera_checks[obs.camera_id].contains("stream status unknown"), "Failed provider check reports unknown stream status")
    ui.history_toggle.button_pressed = true
    ui.history_slider.value = -2550
    verify(app.history_enabled and app.history_root.get_child_count() == 1 and ui.history_banner.text.contains("Modern Earth imagery"), "Historical atlas distinguishes modern imagery and dates")
    verify(app.catalog.historical_sites(100)[0].name.contains("Rome"), "Rome dated site available")
    verify(app.catalog.historical_sites(600)[0].name.contains("Tikal"), "Maya dated site available")
    verify(app.catalog.historical_sites(2026).is_empty(), "No invented modern historical sites")
    ui.history_toggle.button_pressed = false
    verify(not app.history_enabled and not ui.history_banner.visible, "Historical markers and badge can be removed")
    app.screensaver_mode = true
    app.saver_style = 4
    app.apply_saver_style()
    verify(app.solar_active(), "Realism screensaver uses current UTC sunlight")
    app.saver_style = 5
    app.apply_saver_style()
    var angle: float = app.yaw
    app._process(1.0)
    verify(app.yaw != angle and is_finite(app.pitch), "Cinematic orbit changes viewing angle")
    for step in range(720): app._process(30.0)
    verify(app.camera.position.is_finite() and app.sun.basis.z.is_finite(), "Six simulated hours keep camera and lighting finite (not a real-time soak)")
    app.screensaver_mode = false
    app.reset_view()
    DirAccess.remove_absolute(ProjectSettings.globalize_path(app.preferences_path))
    DirAccess.remove_absolute(ProjectSettings.globalize_path(obs.cache_path))
    print("Cycle 0.6: %d checks, %d failures" % [checks, failures])
    quit(1 if failures else 0)
