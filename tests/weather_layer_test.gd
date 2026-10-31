extends SceneTree
const Layer = preload("res://scripts/weather_layer.gd")
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("run")
func verify(ok: bool, message: String) -> void:
    checks += 1
    if not ok: failures += 1;push_error(message)
func fixture(places: Array, when: float) -> Array:
    var feed: Array = []
    for index in range(places.size()):
        var place: Dictionary = places[index]
        feed.append({"latitude":place.latitude,"longitude":place.longitude,"location_id":index,"utc_offset_seconds":0,"current_units":{"temperature_2m":"°C","wind_speed_10m":"km/h","relative_humidity_2m":"%"},"current":{"time":Time.get_datetime_string_from_unix_time(int(when)),"temperature_2m":-5+(index*3)%60,"wind_speed_10m":10.0,"relative_humidity_2m":55,"weather_code":2}})
    return feed
func run() -> void:
    var app = load("res://scenes/earth.tscn").instantiate()
    app.play_intro = false
    app.preferences_path = "user://layer-test-%d.cfg" % Time.get_ticks_usec()
    app.weather_layer_cache_path = "user://layer-test-%d.json" % Time.get_ticks_usec()
    root.add_child(app)
    var layer = app.weather_layer
    verify(layer != null and layer.request == null and layer.points.is_empty(),"Normal startup creates no layer request")
    verify(not layer.enabled and not layer.marker_root.visible and not layer.is_processing(),"Layer starts hidden and idle")
    verify(layer.places.size() == 32 and layer.request_url().begins_with("https://api.open-meteo.com/"),"Batch uses fixed 32-place HTTPS source")
    var now := Time.get_unix_time_from_system()
    var feed := fixture(layer.places,now)
    verify(Layer.parse_batch(feed,layer.places,now).size() == 32,"Valid 32-place batch parses")
    verify(Layer.parse_batch({},layer.places,now).is_empty(),"Provider error object is not weather")
    var short := feed.duplicate(true);short.pop_back()
    verify(Layer.parse_batch(short,layer.places,now).is_empty(),"Truncated batch cannot shift city labels")
    for kind in ["id","coordinates","units","temperature","humidity","code","time"]:
        var bad := feed.duplicate(true)
        match kind:
            "id": bad[0].location_id=5
            "coordinates": bad[0].latitude=-60.0
            "units": bad[0].current_units.temperature_2m="°F"
            "temperature": bad[0].current.temperature_2m=NAN
            "humidity": bad[0].current.relative_humidity_2m=101
            "code": bad[0].current.weather_code=999
            "time": bad[0].current.time="2026-02-30T12:00:00"
        verify(Layer.parse_batch(bad,layer.places,now).size() == 31,"Malformed point excluded without relabelling: "+kind)
    verify(Layer.parse_batch(fixture(layer.places,now-86401),layer.places,now).is_empty(),"Expired model batch rejected")
    verify(Layer.parse_batch(fixture(layer.places,now+7200),layer.places,now).is_empty(),"Future model batch rejected against device clock")
    verify(Layer.parse_batch(fixture(layer.places,now-7200),layer.places,now).size() == 32,"Stale but unexpired estimates retain their times")
    verify(Layer.temperature_color(-1) == Color("53b7ff") and Layer.temperature_color(30) == Color("ff7f66"),"Temperature palette has clear cold/hot endpoints")
    verify(Layer.temperature_color(30,true) == Color("778391"),"Stale estimate loses current-temperature colour")
    layer._received(0,200,PackedStringArray(),JSON.stringify(feed).to_utf8_buffer(),layer.generation)
    verify(layer.points.size() == 32 and layer.enabled and layer.marker_root.visible,"Explicit successful load enables globe points")
    verify(layer.markers.size() == 32 and layer.marker_root.get_child_count() == 32,"Exactly one marker per accepted point")
    for point in layer.points:
        var marker: MeshInstance3D = layer.markers[int(point.location_index)]
        verify(absf(marker.position.length()-1.045)<0.00001,"Model marker lies on consistent display surface")
    verify(FileAccess.file_exists(layer.cache_path),"Valid batch caches locally")
    verify(layer.search_indices("").size()==32,"Empty local search retains every loaded model point")
    for query in ["US","USA","United States"]:
        var matches: Array[int]=layer.search_indices(query)
        verify(matches.size()==5 and matches.all(func(index):return layer.places[int(layer.points[index].location_index)].country_code=="US"),"Country aliases select US points without matching Australia: "+query)
    verify(layer.search_indices("CA").size()==1 and layer.points[layer.search_indices("CA")[0]].name=="Vancouver, Canada","Country code chooses Canada without matching Cape Town")
    verify(layer.search_indices("UK").size()==1 and layer.search_indices("turkey").size()==1,"Common country aliases find provider names")
    var ui=app.interface
    root.size=Vector2i(800,600)
    ui.open_page("Weather globe")
    for frame in range(12):await process_frame
    verify(ui.page_scroll.get_global_rect().encloses(ui.weather_layer_query.get_global_rect()) and ui.page_scroll.get_global_rect().encloses(ui.weather_layer_picker.get_global_rect()),"Loaded weather filter and place picker are fully visible at 800×600")
    ui.weather_layer_query.text="Cebu"
    ui.weather_layer_query.text_changed.emit("Cebu")
    verify(ui.weather_layer_picker.item_count==2 and layer.request==null,"Local place search filters choices without a network request")
    ui.weather_layer_picker.item_selected.emit(1)
    verify(app.exploration.location.name=="Cebu City, Philippines","Filtered option visits its mapped source point")
    var partial:=feed.duplicate(true)
    partial[0].current.temperature_2m=1000
    layer._received(0,200,PackedStringArray(),JSON.stringify(partial).to_utf8_buffer(),layer.generation)
    ui.weather_layer_picker.item_selected.emit(1)
    verify(layer.points.size()==31 and app.exploration.location.name=="Cebu City, Philippines","Filtered option mapping survives an omitted earlier model row")
    ui.weather_layer_query.text="no-such-public-weather-place"
    ui.weather_layer_query.text_changed.emit(ui.weather_layer_query.text)
    verify(ui.weather_layer_picker.disabled and ui.weather_layer_picker.get_item_text(0).contains("No loaded places"),"Empty local search has explicit no-match state")
    ui.weather_layer_query.text=""
    ui.weather_layer_query.text_changed.emit("")
    layer._received(0,200,PackedStringArray(),JSON.stringify(feed).to_utf8_buffer(),layer.generation)
    var too_many: Array=layer.places.duplicate(true);too_many.append(layer.places[0])
    verify(Layer.parse_batch(fixture(too_many,now),too_many,now).is_empty(),"Model batch cannot exceed its fixed 32-place bound")

    verify(layer.point_label(layer.points[0]).contains("°F"),"Layer uses saved weather units")
    app.preferences.set_value("weather","imperial",false)
    app.interface._weather_layer_changed()
    verify(layer.point_label(layer.points[0]).contains("°C") and app.interface.weather_layer_legend.text.contains("0°C"),"Unit changes keep picker and legend consistent")
    layer._received(0,503,PackedStringArray(),PackedByteArray(),layer.generation)
    verify(layer.points.size() == 32 and layer.status.contains("Previous"),"Failure preserves correctly labelled previous points")
    var before := FileAccess.get_sha256(layer.cache_path)
    var token: int = layer.generation
    layer.loading=true
    layer.cancel()
    layer._received(0,200,PackedStringArray(),JSON.stringify(fixture(layer.places,now-7200)).to_utf8_buffer(),token)
    verify(layer.status.contains("cancelled") and FileAccess.get_sha256(layer.cache_path)==before,"Late cancelled response cannot replace cache or status")
    layer._received(0,200,PackedStringArray(),JSON.stringify(fixture(layer.places,now-7200)).to_utf8_buffer(),layer.generation)
    verify(layer.point_label(layer.points[0]).contains("stale") and layer.markers[0].material_override.albedo_color == Color("778391"),"Stale globe data is grey and labelled")
    layer._received(0,200,PackedStringArray(),JSON.stringify(feed).to_utf8_buffer(),layer.generation)
    await process_frame
    verify(layer.marker_root.get_child_count() == 32,"Replacing a layer does not accumulate marker nodes")
    layer.set_suspended(true)
    verify(not layer.marker_root.visible and not layer.is_processing() and layer.request == null,"Suspension stops work and hides layer")
    layer.set_suspended(false)
    verify(layer.marker_root.visible and layer.request == null,"Resume restores points without a new download")
    var restored = Layer.new()
    restored.cache_path=layer.cache_path
    app.add_child(restored);restored.setup(app)
    verify(restored.points.size() == 32 and not restored.enabled and not restored.marker_root.visible and restored.status.begins_with("Cached"),"Valid cache restores hidden and explicitly cached")
    restored.queue_free()
    verify(layer.visit(0) and app.exploration.location.note.contains("Model time:"),"Visiting a point carries model time into its arrival")
    app.journey.custom_step(3.0);app._update_camera()
    await process_frame
    var marker: MeshInstance3D = layer.markers[0]
    var screen: Vector2 = app.camera.unproject_position(marker.global_position)
    verify(layer.pick(screen)==0,"Visible model point can be picked after globe journey")
    var opposite: MeshInstance3D = null
    for candidate in layer.markers.values():
        if candidate.global_position.normalized().dot(marker.global_position.normalized()) < -0.5: opposite=candidate;break
    if opposite:
        for candidate in layer.markers.values():candidate.visible=candidate==opposite
        verify(layer.pick(app.camera.unproject_position(opposite.global_position))==-1,"Back-of-Earth model points do not intercept input")
        layer._update_markers()
    layer.set_enabled(false)
    verify(layer.pick(screen)==-1,"Hidden model point cannot intercept globe input")
    layer.set_enabled(true)
    app.preview_screensaver()
    verify(layer.suspended and not layer.marker_root.visible and layer.request == null,"Screensaver preview cancels and hides model layer")
    app.stop_screensaver_preview()
    verify(not layer.suspended and layer.enabled and layer.request == null,"Returning from saver restores layer without downloading")
    layer.last_attempt=Time.get_ticks_msec()
    layer.refresh()
    verify(layer.request == null and layer.status.contains("ten minutes"),"Manual refresh cooldown is enforced")
    for point in layer.points:point.utc=Time.get_datetime_string_from_unix_time(int(now-90000)).replace("T"," ")
    layer._update_markers()
    verify(not layer.markers[0].visible and layer.point_label(layer.points[0]).contains("expired"),"Aged-out markers are hidden rather than painted as current")
    var cache: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(layer.cache_path))
    var valid_hash: String=cache.dataset_sha256
    cache.dataset_sha256="0".repeat(64)
    var cache_file:=FileAccess.open(layer.cache_path,FileAccess.WRITE)
    cache_file.store_string(JSON.stringify(cache));cache_file.close()
    var legacy=Layer.new();legacy.cache_path=layer.cache_path;app.add_child(legacy);legacy.setup(app)
    verify(legacy.points.is_empty() and not legacy.enabled,"Old dataset fingerprint cannot relabel a new 32-place sample")
    legacy.queue_free()
    cache.dataset_sha256=valid_hash
    cache.feed=feed.slice(0,16)
    cache_file=FileAccess.open(layer.cache_path,FileAccess.WRITE)
    cache_file.store_string(JSON.stringify(cache));cache_file.close()
    legacy=Layer.new();legacy.cache_path=layer.cache_path;app.add_child(legacy);legacy.setup(app)
    verify(legacy.points.is_empty() and legacy.status.contains("invalid"),"Old sixteen-row cache is rejected even with the new dataset fingerprint")
    legacy.queue_free()
    for path in [app.preferences_path,layer.cache_path]:DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
    app.queue_free()
    await process_frame
    print("Weather globe layer: %d checks, %d failures" % [checks,failures])
    quit(1 if failures else 0)
