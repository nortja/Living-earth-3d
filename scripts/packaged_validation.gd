extends Node
## Opt-in installed-resource validation. Never runs during ordinary app/saver use.
const Photos = preload("res://scripts/discovery_photos.gd")
var failures := 0
var directory := ""
func verify(ok: bool, message: String) -> void:
    if not ok: failures += 1;push_error(message)
func run(app: Node3D, arguments: PackedStringArray) -> void:
    var root := get_tree().root
    for arg in arguments:
        if arg.begins_with("--evidence-directory="):directory=arg.trim_prefix("--evidence-directory=")
    verify(not directory.is_empty() and OS.get_name()=="Windows" and DisplayServer.get_name()!="headless","Packaged UI test requires Windows graphics and evidence directory")
    if failures:get_tree().quit(1);return
    progress("Installed validator started")
    var ui=app.interface
    for place in app.exploration.catalog.places:
        var photo: Dictionary=Photos.lookup(place)
        verify(not photo.is_empty(),"Installed photograph resolves: "+place.id)
        if not photo.is_empty():verify(ui.photo_viewer.open(photo,place.name) and ui.photo_viewer.image.texture.get_width()>0,"Installed photograph actually decodes: "+place.id)
        for frame in range(4):await get_tree().process_frame
        ui.photo_viewer.close()
    app.fly_to_location(app.exploration.catalog.places[0]);app.journey.custom_step(3.0);app._update_camera()
    for frame in range(16):await get_tree().process_frame
    await RenderingServer.frame_post_draw
    root.get_texture().get_image().save_png(directory.path_join("windows-packaged-discovery.png"))
    progress("All twelve installed photographs decoded")
    var satellite=app.satellite_snapshot
    var synthetic:=Image.create(2048,1024,false,Image.FORMAT_RGBA8)
    synthetic.fill(Color("35788e"))
    satellite.pending_date="2026-10-30"
    satellite._received(0,200,PackedStringArray(),synthetic.save_png_to_buffer(),satellite.generation)
    verify(satellite.enabled and app.earth_material.get_shader_parameter("satellite_view") and not app.visuals.clouds.visible,"Installed satellite mosaic shader is active without artistic clouds")
    satellite.status="Synthetic NASA mosaic · packaged Windows rendering fixture · not an observation"
    ui._satellite_changed();ui.open_page("Satellite view")
    for frame in range(16):await get_tree().process_frame
    await RenderingServer.frame_post_draw
    verify(ui.page_scroll.get_global_rect().encloses(ui.satellite_load.get_global_rect()),"Installed satellite load action is visible without scrolling")
    root.get_texture().get_image().save_png(directory.path_join("windows-packaged-satellite-fixture.png"))
    app.preview_screensaver()
    verify(satellite.suspended and not app.earth_material.get_shader_parameter("satellite_view") and satellite.request==null,"Installed native-style preview excludes satellite surface and requests")
    app.stop_screensaver_preview()
    verify(not satellite.suspended and app.earth_material.get_shader_parameter("satellite_view"),"Installed preview return restores dated mosaic")
    satellite.set_enabled(false)
    verify(not app.earth_material.get_shader_parameter("satellite_view") and app.visuals.clouds.visible,"Installed offline return restores artistic view")
    progress("Satellite surface, source date, preview isolation and offline return passed")
    var layer=app.weather_layer
    var feed: Array=[]
    for index in range(layer.places.size()):
        var place: Dictionary=layer.places[index]
        feed.append({"latitude":place.latitude,"longitude":place.longitude,"location_id":index,"utc_offset_seconds":0,"current_units":{"temperature_2m":"°C","wind_speed_10m":"km/h","relative_humidity_2m":"%"},"current":{"time":Time.get_datetime_string_from_system(true),"temperature_2m":-5+(index*3)%60,"wind_speed_10m":10.0,"relative_humidity_2m":55,"weather_code":2}})
    layer._received(0,200,PackedStringArray(),JSON.stringify(feed).to_utf8_buffer(),layer.generation)
    verify(layer.points.size()==32 and layer.markers.size()==32,"Installed model layer creates 32 points")
    layer.status="Synthetic model points · packaged Windows UI test"
    ui.open_page("Weather globe")
    ui.weather_layer_query.text="Canada"
    ui.weather_layer_query.text_changed.emit("Canada")
    verify(ui.weather_layer_picker.item_count==2,"Installed local country filter finds Vancouver")
    if ui.weather_layer_picker.item_count==2:
        var point_index:int=ui.weather_layer_picker.get_item_metadata(1)
        verify(layer.points[point_index].name.begins_with("Vancouver"),"Installed filtered picker preserves source identity")
        ui.weather_layer_picker.item_selected.emit(1)
        verify(app.exploration.location.name=="Vancouver, Canada" and app.journey.is_running(),"Installed filtered place begins the correct journey")
    ui.weather_layer_query.text=""
    ui.weather_layer_query.text_changed.emit("")
    verify(ui.weather_layer_picker.item_count==33,"Installed cleared search restores all 32 choices")
    for frame in range(16):await get_tree().process_frame
    await RenderingServer.frame_post_draw
    root.get_texture().get_image().save_png(directory.path_join("windows-packaged-weather-fixture.png"))
    app.preview_screensaver()
    verify(not layer.marker_root.visible and layer.request==null,"Installed preview hides and cancels model layer")
    app.stop_screensaver_preview()
    progress("Weather points and screensaver isolation passed")
    var report=app.performance_report
    report.report_path=directory.path_join("windows-display-report.json")
    report.start_recording();ui.close_panel()
    var deadline:=Time.get_ticks_msec()+360000
    while report.recording and Time.get_ticks_msec()<deadline and failures==0:
        await get_tree().create_timer(30.0).timeout
        progress("PACKAGED_PERFORMANCE "+JSON.stringify(report.build_snapshot().recording))
    verify(not report.recording and report.recorded_seconds>=300 and report.recorded_frames>0,"Installed five-active-minute recording completes")
    verify(report.export_report()==OK,"Installed application exports local display report")
    verify(report.snapshot.display.available and not str(report.snapshot.display.gpu).is_empty(),"Installed report contains actual Windows GPU/display fields")
    verify(not report.snapshot.has("username") and not report.snapshot.has("paths") and not report.snapshot.has("bookmarks"),"Installed report excludes personal content")
    verify(layer.request==null and not app.camera_service.active and app.observations.weather_request==null,"Desktop recording did not start public-data requests")
    ui.open_page("Display report")
    for frame in range(16):await get_tree().process_frame
    await RenderingServer.frame_post_draw
    root.get_texture().get_image().save_png(directory.path_join("windows-packaged-performance.png"))
    for path in [app.preferences_path,layer.cache_path]:DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
    print("Packaged Windows desktop: %d failures" % failures)
    get_tree().quit(1 if failures else 0)

func progress(message: String) -> void:
    print(message)
    var file := FileAccess.open(directory.path_join("windows-packaged-progress.txt"), FileAccess.READ_WRITE if FileAccess.file_exists(directory.path_join("windows-packaged-progress.txt")) else FileAccess.WRITE)
    if file:
        file.seek_end()
        file.store_line(message)
        file.close()
