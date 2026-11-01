extends SceneTree
const Solar = preload("res://scripts/solar_position.gd")
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("run")
func verify(ok: bool, message: String) -> void:
    checks += 1
    if not ok: failures += 1; push_error(message)
func run() -> void:
    for date in ["2026-03-20T12:00:00","2026-06-21T00:00:00","2026-12-21T23:59:59","2024-02-29T12:00:00"]:
        var stamp := float(Time.get_unix_time_from_datetime_string(date))
        var sun := Solar.at_unix(stamp)
        verify(absf(Solar.elevation(sun.latitude,sun.longitude,stamp)-90.0)<0.001,"Subsolar point has overhead Sun: "+date)
        verify(absf(Solar.elevation(-sun.latitude,wrapf(sun.longitude+180.0,-180.0,180.0),stamp)+90.0)<0.001,"Antipode has midnight Sun below Earth: "+date)
        verify(absf(Solar.elevation(90.0,0.0,stamp)-sun.latitude)<0.001,"North-pole height equals declination: "+date)
        verify(absf(Solar.elevation(-90.0,180.0,stamp)+sun.latitude)<0.001,"South-pole height reverses declination: "+date)
        verify(absf(Solar.elevation(40.0,180.0,stamp)-Solar.elevation(40.0,-180.0,stamp))<0.001,"Date-line coordinates agree: "+date)
    for pair in [[0.0,"Daylight"],[-0.01,"Civil twilight"],[-6.0,"Civil twilight"],[-6.01,"Nautical twilight"],[-12.0,"Nautical twilight"],[-12.01,"Astronomical twilight"],[-18.0,"Astronomical twilight"],[-18.01,"Night"]]:
        verify(Solar.light_phase(pair[0])==pair[1],"Geometric twilight threshold: %s" % pair[0])
    var app = load("res://scenes/earth.tscn").instantiate()
    app.play_intro = false
    app.preferences_path = "user://sunlight-explorer-%d.cfg" % Time.get_ticks_usec()
    root.add_child(app)
    var ui = app.interface
    var explorer = ui.sunlight_explorer
    verify(not explorer.active and not app.sunlight_preview_active,"No startup sunlight simulation")
    app.set_utc_sunlight(false)
    var cinematic: Vector3 = app.sun.global_basis.z
    ui.open_page("Sunlight explorer")
    verify(explorer.active and app.sunlight_preview_active and not app.utc_sunlight,"Preview temporarily lights Earth without enabling saved UTC sunlight")
    verify(explorer.place.name.contains("reference"),"No selection uses an explicit reference point")
    explorer.anchor_time = Time.get_unix_time_from_datetime_string("2026-12-31T23:30:00")
    explorer.slider.value = 1.0
    verify(app.solar_sample.utc.begins_with("2027-01-01 00:30"),"Preview crosses UTC year boundary")
    verify(explorer.clock.text.contains("SIMULATION") and explorer.clock.text.contains("UTC") and ui.solar_status.text.contains("SIMULATION"),"Simulated time stays explicitly identified")
    explorer.slider.value = 100.0
    verify(explorer.slider.value==12.0,"Forward preview stays bounded")
    explorer.slider.value = -100.0
    verify(explorer.slider.value==-12.0,"Backward preview stays bounded")
    explorer.reset_now()
    verify(explorer.slider.value==0.0 and absf(app.sunlight_preview_time-Time.get_unix_time_from_system())<2.0,"Now reanchors to current clock")
    ui.close_panel()
    verify(not explorer.active and not app.sunlight_preview_active and cinematic.distance_to(app.sun.global_basis.z)<0.0001,"Close restores cinematic light")
    app.preferences.load(app.preferences_path)
    verify(not app.preferences.get_value("visuals","utc_sunlight",true),"Simulation never overwrites the saved lighting preference")
    app.exploration.set_location({"name":"Three Rivers","latitude":36.44,"longitude":-118.90})
    app.set_utc_sunlight(true)
    ui.open_page("Sunlight explorer")
    verify(explorer.place.name=="Three Rivers","Selected place identifies daylight calculation")
    explorer.slider.value = 8.0
    ui.open_page("Explore")
    verify(not explorer.active and app.utc_sunlight and absf(Time.get_unix_time_from_datetime_string(app.solar_sample.utc.replace(" ","T"))-Time.get_unix_time_from_system())<2.0,"Navigation restores actual current sunlight")
    var satellite = app.satellite_snapshot
    var image := Image.create(2048,1024,false,Image.FORMAT_RGBA8)
    image.fill(Color("356a94"))
    satellite.pending_date = "2026-10-30"
    satellite._received(0,200,PackedStringArray(),image.save_png_to_buffer(),satellite.generation)
    var retained: Texture2D = satellite.texture
    ui.open_page("Sunlight explorer")
    verify(not satellite.enabled and not app.earth_material.get_shader_parameter("satellite_view"),"Preview uses a lit offline surface")
    ui.close_panel()
    verify(satellite.enabled and satellite.texture==retained and satellite.observed_date=="2026-10-30" and satellite.request==null,"Closing restores loaded satellite identity without refetching")
    ui.open_page("Sunlight explorer")
    explorer.slider.value = 10.0
    app.preview_screensaver()
    verify(not explorer.active and not app.sunlight_preview_active and satellite.enabled,"Screensaver clears simulation and retains prior satellite choice")
    app.stop_screensaver_preview()
    verify(app.utc_sunlight and not app.sunlight_preview_active and satellite.enabled,"Screensaver return restores actual clock and prior surface")
    for pixels in [Vector2i(800,600),Vector2i(3840,1080),Vector2i(5120,2880)]:
        root.size = pixels
        ui.open_page("Sunlight explorer")
        for frame in range(16): await process_frame
        verify(ui.page_scroll.get_global_rect().encloses(explorer.slider.get_global_rect()),"Time scrubber visible at %s" % pixels)
        verify(ui.page_scroll.get_global_rect().encloses(explorer.finish_button.get_global_rect()),"Finish preview visible at %s" % pixels)
        ui.close_panel()
    DirAccess.remove_absolute(ProjectSettings.globalize_path(app.preferences_path))
    app.queue_free()
    await process_frame
    print("Sunlight explorer: %d checks, %d failures" % [checks,failures])
    quit(1 if failures else 0)
