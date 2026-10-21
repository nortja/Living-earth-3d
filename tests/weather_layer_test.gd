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
        feed.append({"latitude":place.latitude,"longitude":place.longitude,"location_id":index,"utc_offset_seconds":0,"current_units":{"temperature_2m":"°C","wind_speed_10m":"km/h","relative_humidity_2m":"%"},"current":{"time":Time.get_datetime_string_from_unix_time(int(when)),"temperature_2m":-5+index*3,"wind_speed_10m":10.0,"relative_humidity_2m":55,"weather_code":2}})
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
    verify(layer.places.size() == 16 and layer.request_url().begins_with("https://api.open-meteo.com/"),"Batch uses fixed sixteen-place HTTPS source")
    var now := Time.get_unix_time_from_system()
    var feed := fixture(layer.places,now)
    verify(Layer.parse_batch(feed,layer.places,now).size() == 16,"Valid sixteen-place batch parses")
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
        verify(Layer.parse_batch(bad,layer.places,now).size() == 15,"Malformed point excluded without relabelling: "+kind)
    verify(Layer.parse_batch(fixture(layer.places,now-86401),layer.places,now).is_empty(),"Expired model batch rejected")
    verify(Layer.parse_batch(fixture(layer.places,now+7200),layer.places,now).is_empty(),"Future model batch rejected against device clock")
    verify(Layer.parse_batch(fixture(layer.places,now-7200),layer.places,now).size() == 16,"Stale but unexpired estimates retain their times")
    verify(Layer.temperature_color(-1) == Color("53b7ff") and Layer.temperature_color(30) == Color("ff7f66"),"Temperature palette has clear cold/hot endpoints")
    verify(Layer.temperature_color(30,true) == Color("778391"),"Stale estimate loses current-temperature colour")
    layer._received(0,200,PackedStringArray(),JSON.stringify(feed).to_utf8_buffer(),layer.generation)
    verify(layer.points.size() == 16 and layer.enabled and layer.marker_root.visible,"Explicit successful load enables globe points")
    verify(layer.markers.size() == 16 and layer.marker_root.get_child_count() == 16,"Exactly one marker per accepted point")
    for point in layer.points:
        var marker: MeshInstance3D = layer.markers[int(point.location_index)]
        verify(absf(marker.position.length()-1.045)<0.00001,"Model marker lies on consistent display surface")
    verify(FileAccess.file_exists(layer.cache_path),"Valid batch caches locally")
    verify(layer.point_label(layer.points[0]).contains("°F"),"Layer uses saved weather units")
    app.preferences.set_value("weather","imperial",false)
    app.interface._weather_layer_changed()
    verify(layer.point_label(layer.points[0]).contains("°C") and app.interface.weather_layer_legend.text.contains("0°C"),"Unit changes keep picker and legend consistent")
    layer._received(0,503,PackedStringArray(),PackedByteArray(),layer.generation)
    verify(layer.points.size() == 16 and layer.status.contains("Previous"),"Failure preserves correctly labelled previous points")
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
    verify(layer.marker_root.get_child_count() == 16,"Replacing a layer does not accumulate marker nodes")
    layer.set_suspended(true)
    verify(not layer.marker_root.visible and not layer.is_processing() and layer.request == null,"Suspension stops work and hides layer")
    layer.set_suspended(false)
    verify(layer.marker_root.visible and layer.request == null,"Resume restores points without a new download")
    var restored = Layer.new()
    restored.cache_path=layer.cache_path
    app.add_child(restored);restored.setup(app)
    verify(restored.points.size() == 16 and not restored.enabled and not restored.marker_root.visible and restored.status.begins_with("Cached"),"Valid cache restores hidden and explicitly cached")
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
    verify(layer.request == null and layer.status.contains("five minutes"),"Manual refresh cooldown is enforced")
    for point in layer.points:point.utc=Time.get_datetime_string_from_unix_time(int(now-90000)).replace("T"," ")
    layer._update_markers()
    verify(not layer.markers[0].visible and layer.point_label(layer.points[0]).contains("expired"),"Aged-out markers are hidden rather than painted as current")
    for path in [app.preferences_path,layer.cache_path]:DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
    app.queue_free()
    await process_frame
    print("Weather globe layer: %d checks, %d failures" % [checks,failures])
    quit(1 if failures else 0)
