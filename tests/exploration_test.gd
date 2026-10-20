extends SceneTree
const Catalog = preload("res://scripts/discovery_catalog.gd")
const Weather = preload("res://scripts/weather_service.gd")
var checks := 0
var failures := 0
func verify(ok: bool, message: String) -> void:
    checks += 1
    if not ok:
        failures += 1
        push_error(message)
func _initialize() -> void: call_deferred("run")
func run() -> void:
    var catalog = Catalog.new()
    var now := float(Time.get_unix_time_from_datetime_string("2026-10-20T00:00:00"))
    verify(catalog.daily(now).id == catalog.daily(now + 86399).id,"Daily wonder stable throughout UTC day")
    verify(catalog.daily(now).id != catalog.daily(now + 86400).id,"Daily wonder advances at midnight")
    verify(catalog.places.size() == 12,"Twelve curated wonders")
    for place in catalog.places:
        verify(place.source.begins_with("https://") and place.note.length() > 40,"Wonder has source and original explanatory note")
    verify(catalog.historical_sites(-2550).size() == 1 and catalog.historical_sites(100).size() == 1 and catalog.historical_sites(600).size() == 1,"Timeline era presets select appropriate site")
    verify(catalog.historical_sites(-1500).is_empty(),"Timeline never invents uncatalogued sites")
    verify(catalog.year_label(-2550) == "2550 BCE" and catalog.year_label(0) == "1 CE","Era labels omit year zero")
    var app = load("res://scenes/earth.tscn").instantiate()
    app.play_intro = false
    app.preferences_path = "user://exploration-test-%d.cfg" % Time.get_ticks_usec()
    app.weather_cache_path = "user://exploration-weather-%d.json" % Time.get_ticks_usec()
    root.add_child(app)
    var ui = app.interface.exploration_panel
    var model = app.exploration
    var obs = app.observations
    verify(not obs.loading and obs.weather_request == null and obs.weather.is_empty(),"Startup makes no weather request")
    verify(ui.sections.Discover.visible and not ui.sections.Search.visible,"Discover starts without adding primary navigation clutter")
    ui.show_place(catalog.places[0])
    verify(app.external_focus and model.location.name == catalog.places[0].name,"Wonder flies globe and updates selected-place context")
    verify(app.description.text.contains("Modern Earth imagery"),"Globe view stays explicitly modern")
    ui.feature(catalog.places[0],false)
    model.toggle_save(catalog.places[0])
    verify(ui.feature_save.text == "Remove saved place", "Saving gives immediate visible feedback")
    verify(model.bookmarks.size() == 1 and ui.saved_list.get_child_count() > 0,"Wonder saves locally and updates Saved panel")
    model.toggle_save(catalog.places[0])
    verify(model.bookmarks.is_empty(),"Bookmark toggle removes the same geographic place")
    verify(ui.feature_save.text == "Save this place", "Unsave immediately restores Save action")
    model.toggle_save({"name":"Bad","latitude":91,"longitude":0})
    verify(model.bookmarks.is_empty(),"Malformed bookmark rejected")
    model.toggle_save(catalog.history[0])
    var restored = load("res://scripts/exploration_data.gd").new()
    restored.setup(app)
    verify(restored.bookmarks.size() == 1 and restored.bookmarks[0].name == catalog.history[0].name,"Saved history place persists independently from legacy favorites")
    restored.free()
    var fixture := {"current":{"temperature_2m":20.0,"wind_speed_10m":10.0,"relative_humidity_2m":55,"weather_code":3,"time":Time.get_datetime_string_from_system(true).left(16)},"current_units":{"temperature_2m":"°C","wind_speed_10m":"km/h","relative_humidity_2m":"%"},"utc_offset_seconds":0}
    verify(not Weather.parse_weather(fixture,model.location).is_empty(),"Weather values and expected units parse")
    for field in ["temperature_2m","wind_speed_10m","relative_humidity_2m","weather_code"]:
        var bad := fixture.duplicate(true)
        bad.current[field] = "invalid"
        verify(Weather.parse_weather(bad,model.location).is_empty(),"Non-numeric model field rejected: " + field)
    for bad_time in ["2026-02-30T12:00","2026-13-01T12:00","2026-01-01T25:00"]:
        var bad := fixture.duplicate(true)
        bad.current.time = bad_time
        verify(Weather.parse_weather(bad,model.location).is_empty(),"Impossible model time rejected")
    var bad := fixture.duplicate(true)
    bad.current_units.temperature_2m = "°F"
    verify(Weather.parse_weather(bad,model.location).is_empty(),"Unexpected provider units rejected")
    obs.weather_pending = model.location.duplicate(true)
    obs._weather_received(HTTPRequest.RESULT_SUCCESS,200,PackedStringArray(),JSON.stringify(fixture).to_utf8_buffer(),obs.generation)
    verify(not obs.weather.is_empty() and FileAccess.file_exists(obs.cache_path),"Successful model response cached")
    verify(ui.weather_values.text.contains("68.0 °F") and ui.weather_values.text.contains("Model time"),"Fahrenheit conversion and separate model timestamp shown")
    ui.weather_units.button_pressed = false
    verify(ui.weather_values.text.contains("20.0 °C"),"Units change without another provider request")
    var original: String = obs.weather.name
    obs.weather_pending = {"name":"Other place","latitude":10.0,"longitude":20.0}
    obs._weather_received(HTTPRequest.RESULT_CANT_CONNECT,0,PackedStringArray(),PackedByteArray(),obs.generation)
    verify(obs.weather.name == original and obs.weather_status.contains(original),"Failure retains old values under their original place name")
    var token: int = obs.generation
    obs.loading = true
    app.fly_to_location(catalog.places[1])
    obs._weather_received(HTTPRequest.RESULT_SUCCESS,200,PackedStringArray(),JSON.stringify(fixture).to_utf8_buffer(),token)
    verify(not obs.loading and obs.weather.name == original,"Changing place cancels request and ignores late response")
    var cached = Weather.new()
    cached.cache_path = obs.cache_path
    root.add_child(cached)
    verify(not cached.weather.is_empty() and cached.weather_status.contains("Cached"),"Recent disk cache restored with a cached label")
    cached.queue_free()
    fixture.current.time = "2000-01-01T00:00"
    obs.weather_pending = model.location.duplicate()
    obs._weather_received(HTTPRequest.RESULT_SUCCESS,200,PackedStringArray(),JSON.stringify(fixture).to_utf8_buffer(),obs.generation)
    verify(obs.freshness().contains("Expired"),"Old network model values explicitly marked expired")
    var expired = Weather.new()
    expired.cache_path = obs.cache_path
    root.add_child(expired)
    verify(expired.weather.is_empty() and expired.weather_status.contains("expired"),"Disk cache older than 24 hours does not become current data")
    expired.queue_free()
    ui.select_section("History")
    ui.history_slider.value = 0
    verify(ui.history_year.text == "1 CE","Timeline control does not display year zero")
    for latitude in [-90.0,90.0]:
        app.fly_to_location({"name":"Pole","latitude":latitude,"longitude":0.0})
        app.journey.custom_step(3.0)
        app._update_camera()
        verify(app.camera.basis.is_finite() and app.camera.basis.z.normalized().dot(app.camera.position.normalized()) > 0.9999,"Exact polar navigation has a valid north-oriented camera")
    var saved_sun: bool = app.utc_sunlight
    for style in range(6):
        app.saver_style = style
        app.preview_screensaver()
        app._process(1.5)
        if style == 1: verify(catalog.places.any(func(place): return place.name == model.location.name),"Discovery screensaver journeys use the expanded wonder catalog")
        verify(app.screensaver_mode and not app.interface_layer.visible and app.ambient.suspended,"Screensaver style %d is quiet and hides UI" % style)
        app.stop_screensaver_preview()
        verify(not app.screensaver_mode and app.utc_sunlight == saved_sun,"Screensaver style %d restores sunlight preference" % style)
    for path in [app.preferences_path,app.weather_cache_path]: DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
    app.queue_free()
    await process_frame
    print("Exploration/weather/history: %d checks, %d failures" % [checks,failures])
    quit(1 if failures else 0)
