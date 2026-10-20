extends SceneTree
var checks := 0
var failures := 0
const Services = preload("res://scripts/earth_services.gd")
func _initialize() -> void: call_deferred("run")
func verify(condition: bool, message: String) -> void:
    checks += 1
    if not condition:
        failures += 1
        push_error(message)
func run() -> void:
    var app = load("res://scenes/earth.tscn").instantiate()
    app.play_intro = false
    app.preferences_path = "user://interface-test-%d.cfg" % Time.get_ticks_usec()
    root.add_child(app)
    var ui = app.interface
    var services = app.services
    services.cache_path = "user://quake-test-%d.json" % Time.get_ticks_usec()
    await process_frame
    verify(not ui.panel.visible and not ui.command_card.visible, "Launch is a clear full Earth")
    verify(ui.navigation.size() == 5, "Five primary destinations")
    for title in ui.NAV + ["Settings"]:
        ui.open_page(title)
        verify(ui.panel.visible and ui.pages[title].visible, "Navigation opens " + title)
    ui.close_panel()
    verify(not ui.panel.visible, "Panel can close")
    ui._search_offline("Tokyo")
    verify(ui.search_results.get_child_count() == 1, "Offline city search")
    ui._search_offline("-33.9, 151.2")
    verify(ui.search_results.get_child_count() == 1, "Coordinate search")
    ui._search_offline("91, 181")
    verify(ui.search_results.get_child_count() == 0, "Invalid coordinates rejected")
    verify(not app.fly_to_location({"latitude": 91, "longitude": 0}), "Invalid fly-to rejected")
    verify(app.fly_to_location({"name": "Tokyo", "latitude": 35.6762, "longitude": 139.6503}), "Fly to atlas/camera/data coordinates")
    app.journey.custom_step(2.5)
    verify(abs(app.pitch - deg_to_rad(35.6762)) < 0.001 and app.external_focus, "Search journey reaches destination")
    verify(app.focus_marker.visible and app.favorite_button.disabled, "Search location marked; curated favorites stay distinct")
    var rotation: float = app.earth.rotation.y
    app._process(1.0)
    verify(app.earth.rotation.y == rotation, "Globe holds data location steady")
    app.reset_view()
    verify(not app.external_focus and not app.focus_marker.visible and not app.favorite_button.disabled, "Reset clears data focus")
    verify(ui.cameras.size() == 8, "Eight curated camera venues")
    for venue in ui.cameras:
        verify(Services.valid_coordinates(venue.latitude, venue.longitude) and venue.url.begins_with("https://"), "Camera source and location valid")
    var fixture := {"type": "FeatureCollection", "features": [{"geometry": {"type": "Point", "coordinates": [-122.5, 38.0, 2]}, "properties": {"place": "Fixture observation", "mag": 3.2, "time": 1700000000000}}, {"geometry": {"type": "Point", "coordinates": [200, 95]}, "properties": {"mag": 4.0}}, null]}
    var quakes: Array = Services.parse_quakes(fixture)
    verify(quakes.size() == 1 and quakes[0].magnitude == 3.2, "Parser filters malformed and out-of-range observations")
    verify(quakes[0].utc == "2023-11-14 22:13:20", "USGS event milliseconds converted to UTC")
    services._quakes_received(HTTPRequest.RESULT_SUCCESS, 200, PackedStringArray(), JSON.stringify(fixture).to_utf8_buffer())
    verify(services.earthquakes.size() == 1 and services.quake_status.begins_with("Updated"), "Successful feed labels retrieval time")
    verify(FileAccess.file_exists(services.cache_path), "Successful feed cached")
    services._quakes_received(HTTPRequest.RESULT_CANT_CONNECT, 0, PackedStringArray(), PackedByteArray())
    verify(services.earthquakes.size() == 1 and services.quake_status.contains("cached"), "Failure retains observations with cached warning")
    var restored = Services.new()
    restored.cache_path = services.cache_path
    root.add_child(restored)
    verify(restored.earthquakes.size() == 1 and restored.quake_status.begins_with("Cached"), "Disk cache restored as cached, never live")
    services._quakes_received(0, 200, PackedStringArray(), '{"features":[]}'.to_utf8_buffer())
    verify(services.earthquakes.is_empty() and services.quake_status.begins_with("Updated"), "Valid empty feed clears old observations")
    services._search_received(0, 200, PackedStringArray(), '[{"display_name":"Tokyo","lat":"35.6","lon":"139.6"},{"lat":"999","lon":"0"}]'.to_utf8_buffer())
    verify(services.results.size() == 1 and services.search_status.contains("OpenStreetMap"), "Worldwide results filtered and attributed")
    services._search_received(HTTPRequest.RESULT_CANT_CONNECT, 0, PackedStringArray(), PackedByteArray())
    verify(services.results.is_empty() and services.search_status.contains("unavailable"), "Failed worldwide query never leaves misleading results")
    app.saver_style = 1
    app.apply_saver_style()
    verify(app.discovery_enabled and app.external_focus and app.exploration.catalog.places.any(func(place): return place.name == app.exploration.location.name), "Discovery screensaver visits the expanded wonder catalog")
    app.saver_style = 3
    app.apply_saver_style()
    verify(not app.discovery_enabled and app.visuals.moon.visible, "Deep space includes Moon and free rotation")
    app.stop_screensaver_preview()
    verify(not app.screensaver_mode and app.interface_layer.visible and not app.visuals.moon_enabled, "Preview restores visual preferences")
    for style in [0, 1, 2, 3]:
        app.preferences.set_value("screensaver", "style", style)
        app._save_preferences()
        var saved := ConfigFile.new()
        saved.load(app.preferences_path)
        verify(saved.get_value("screensaver", "style") == style, "Screensaver style persists")
    DirAccess.remove_absolute(ProjectSettings.globalize_path(services.cache_path))
    DirAccess.remove_absolute(ProjectSettings.globalize_path(app.preferences_path))
    print("Interface/data: %d checks, %d failures" % [checks, failures])
    quit(1 if failures else 0)
