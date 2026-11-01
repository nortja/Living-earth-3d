extends SceneTree
const Weather = preload("res://scripts/observed_weather.gd")
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("run")
func verify(ok: bool, message: String) -> void:
    checks += 1
    if not ok: failures += 1;push_error(message)
func domains(periods: String) -> PackedByteArray:
    return ("<Domains xmlns:ows='http://www.opengis.net/ows/1.1'><DimensionDomain><ows:Identifier>time</ows:Identifier><Domain>"+periods+"</Domain><Size>1</Size></DimensionDomain></Domains>").to_utf8_buffer()
func commit_fixture(service: Node, source: int, stamp: String) -> void:
    service.pending_source = source
    service.pending_time = stamp
    service.loading = true
    service.canvas = Image.create(Weather.WIDTH,Weather.HEIGHT,false,Image.FORMAT_RGBA8)
    service.canvas.fill(Color(0.5,0.5,0.5,1.0))
    service.next_tile = 15
    service.completed = 14
    var tile := Image.create(512,512,false,Image.FORMAT_RGBA8)
    tile.fill(Color(0.6,0.6,0.6,1.0))
    var http := HTTPRequest.new()
    service.add_child(http)
    service.workers[14] = http
    service._tile_received(0,200,PackedStringArray(),tile.save_png_to_buffer(),service.generation,14)
func run() -> void:
    var now := Weather.iso_stamp("2026-11-01T18:00:00Z")
    var xml := domains("2026-10-31/2026-11-01T17:40:00Z/PT10M")
    for item in [[0,"17:40"],[3600,"16:40"],[10800,"14:40"],[43200,"05:40"]]:
        verify(Weather.parse_domains(xml,now,item[0])=="2026-11-01T%s:00Z" % item[1],"Advertised scan selected at supported ten-minute instant")
    verify(Weather.parse_domains(xml,now,Weather.RECENT_BUFFER)=="2026-11-01T17:10:00Z","Recent default uses a thirty-minute dissemination buffer")
    verify(Weather.parse_domains(domains("2026-11-01T00:00:00Z/2026-11-01T13:20:00Z/PT10M,2026-11-01T15:00:00Z/2026-11-01T17:40:00Z/PT10M"),now,10800)=="2026-11-01T13:20:00Z","Gaps select an earlier supported scan rather than inventing data")
    for bad in ["", "2026-02-29T12:00:00Z", "2026-11-31T12:00:00Z", "2026-11-01T25:00:00Z", "2026-11-01T18:60:00Z", "2026-11-01T18:00:00+00:00", "2026-11-01T18:00:00z", "2026-11-01T18:00:00Zx"]:
        verify(Weather.iso_stamp(bad)<0,"Malformed timestamps rejected before engine parser")
    for bad_xml in [PackedByteArray(),PackedByteArray([0,0,0]),"<Domains/>".to_utf8_buffer(),domains("2026-11-01/2026-11-01T18:00:00Z/P1D"),domains("2026-11-01/2026-11-02T18:00:00Z/PT10M"),domains("2026-10-01/2026-10-02T00:00:00Z/PT10M"),"<!DOCTYPE x [<!ENTITY a 'expansion'>]><Domains/>".to_utf8_buffer()]:
        verify(Weather.parse_domains(bad_xml,now,0).is_empty(),"Unsupported metadata never supplies an observed time")
    verify(Weather.parse_domains(xml,now,1200).is_empty(),"Offset outside allowed choices rejected")
    verify(Weather.tile_url(0,"2026-11-01T17:40:00Z",14).ends_with("/2km/2/2/4.png"),"Last source tile maps to the correct geographic row/column")
    verify(Weather.tile_url(3,"2026-11-01T17:40:00Z",0).is_empty() and Weather.tile_url(0,"bad",0).is_empty(),"No arbitrary source or malformed time URL")
    var tile := Image.create(512,512,false,Image.FORMAT_RGBA8)
    tile.fill(Color.WHITE)
    verify(Weather.valid_tile(tile.save_png_to_buffer()),"Bounded exact-size PNG tile accepted")
    verify(not Weather.valid_tile(Image.create(1024,512,false,Image.FORMAT_RGBA8).save_png_to_buffer()),"Oversized dimensions rejected before decoding")
    var app = load("res://scenes/earth.tscn").instantiate()
    app.play_intro = false
    app.preferences_path = "user://observed-weather-%d.cfg" % Time.get_ticks_usec()
    root.add_child(app)
    var ui = app.interface
    var service = app.observed_weather
    var preferences: String = app.preferences.encode_to_text()
    verify(service.request==null and service.workers.is_empty() and not service.enabled,"No startup provider work")
    ui.open_page("Satellite weather")
    verify(service.request==null and service.workers.is_empty(),"Opening the view is offline until explicit Load")
    var satellite = app.satellite_snapshot
    var base := Image.create(2048,1024,false,Image.FORMAT_RGBA8)
    base.fill(Color("365f85"))
    satellite.pending_date = "2026-10-30"
    satellite._received(0,200,PackedStringArray(),base.save_png_to_buffer(),satellite.generation)
    var original_satellite: Texture2D = satellite.texture
    commit_fixture(service,0,"2026-11-01T17:40:00Z")
    verify(service.enabled and not satellite.enabled and service.restore_satellite and service.texture.get_size()==Vector2(2560,1280),"Completed exact regional scene temporarily replaces prior satellite view")
    verify(service.canvas==null and service.workers.is_empty() and not service.loading,"CPU staging and workers released after commit")
    verify(app.earth_material.get_shader_parameter("observed_weather_view") and not app.visuals.clouds.visible,"Observed layer has independent unshaded rendering without artistic cloud drift")
    verify(ui.observed_badge.text.contains("2026-11-01 17:40 UTC"),"Closed-panel badge retains full scan date and time")
    var retained: Texture2D = service.texture
    var stamp: String = service.observed_time
    var token: int = service.generation
    service.select_source(1)
    verify(service.observed_source==0 and service.observed_time==stamp and service.texture==retained,"Changing selection never relabels a retained observation")
    service._metadata_received(0,200,PackedStringArray(),xml,token)
    verify(service.request==null and service.canvas==null,"Stale metadata callback ignored after selection change")
    service.loading = true
    service._fail("Synthetic offline failure")
    verify(service.texture==retained and service.observed_time==stamp and service.status.contains("Previous scene retained"),"Failure preserves identity and pixels")
    ui.open_page("Sunlight explorer")
    verify(service.suspended and not app.earth_material.get_shader_parameter("observed_weather_view") and ui.sunlight_explorer.active,"Sunlight simulation excludes observed weather without discarding it")
    ui.close_panel()
    verify(not service.suspended and service.enabled and app.earth_material.get_shader_parameter("observed_weather_view"),"Return from sunlight restores the observation")
    app.preview_screensaver()
    verify(service.suspended and service.request==null and service.workers.is_empty() and not app.earth_material.get_shader_parameter("observed_weather_view"),"Screensaver cancels work and excludes observed imagery")
    app.stop_screensaver_preview()
    verify(not service.suspended and service.enabled and service.texture==retained,"Screensaver return retains original scene/time")
    service.pending_time = "2026-11-01T18:00:00Z"
    service.loading = true
    service.canvas = Image.create(Weather.WIDTH,Weather.HEIGHT,false,Image.FORMAT_RGBA8)
    service.canvas.fill(Color.TRANSPARENT)
    service.completed = 14
    service.next_tile = 15
    var empty_http := HTTPRequest.new()
    service.add_child(empty_http)
    service.workers[14] = empty_http
    var empty_tile := Image.create(512,512,false,Image.FORMAT_RGBA8)
    empty_tile.fill(Color.TRANSPARENT)
    service._tile_received(0,200,PackedStringArray(),empty_tile.save_png_to_buffer(),service.generation,14)
    verify(service.texture==retained and service.observed_time==stamp and service.status.contains("empty scene") and service.canvas==null,"All-transparent result cannot overwrite a prior observation")
    service.set_enabled(false)
    verify(satellite.enabled and satellite.texture==original_satellite and satellite.observed_date=="2026-10-30" and satellite.request==null,"Return restores previous dated satellite without a request")
    service.set_enabled(true)
    satellite.set_enabled(true)
    verify(not service.enabled and satellite.enabled,"Choosing satellite surface cancels the observed override")
    service.select_source(0)
    service.select_offset(0)
    service.last_attempts["0:0"] = Time.get_ticks_msec()
    service.refresh()
    verify(not service.loading and service.request==null and service.status.contains("ten minutes"),"Cooldown sends no request")
    service.focus_coverage()
    verify(app.exploration.location.name.contains("coverage center") and absf(app.exploration.location.longitude+137.2)<0.01,"Region action has a named coverage context")
    verify(app.preferences.encode_to_text()==preferences,"Observation controls write no preferences or bookmarks")
    ui.open_page("Satellite weather")
    service.loading = true
    service.request = service._http(1000)
    ui.close_panel()
    verify(not service.loading and service.request==null,"Closing the panel cancels an unfinished request")
    DirAccess.remove_absolute(ProjectSettings.globalize_path(app.preferences_path))
    app.queue_free()
    await process_frame
    print("Observed satellite weather: %d checks, %d failures" % [checks,failures])
    quit(1 if failures else 0)
