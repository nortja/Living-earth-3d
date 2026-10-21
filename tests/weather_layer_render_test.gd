extends SceneTree
var failures := 0
func _initialize() -> void: call_deferred("run")
func verify(ok: bool, message: String) -> void:
    if not ok: failures += 1;push_error(message)
func run() -> void:
    var app = load("res://scenes/earth.tscn").instantiate()
    app.play_intro=false
    app.preferences_path="user://weather-render-%d.cfg" % Time.get_ticks_usec()
    app.weather_layer_cache_path="user://weather-render-%d.json" % Time.get_ticks_usec()
    root.add_child(app)
    var layer = app.weather_layer
    var feed: Array = []
    for index in range(layer.places.size()):
        var place: Dictionary = layer.places[index]
        feed.append({"latitude":place.latitude,"longitude":place.longitude,"location_id":index,"utc_offset_seconds":0,"current_units":{"temperature_2m":"°C","wind_speed_10m":"km/h","relative_humidity_2m":"%"},"current":{"time":Time.get_datetime_string_from_system(true),"temperature_2m":-5+index*3,"wind_speed_10m":10.0,"relative_humidity_2m":55,"weather_code":2}})
    var actual := false
    for arg in OS.get_cmdline_user_args():
        if arg.begins_with("--weather-fixture="):
            feed=JSON.parse_string(FileAccess.get_file_as_string(arg.trim_prefix("--weather-fixture=")))
            actual=true
    layer._received(0,200,PackedStringArray(),JSON.stringify(feed).to_utf8_buffer(),layer.generation)
    verify(layer.points.size()==16,"Sixteen model points render")
    if not actual: layer.status="Synthetic model points · native layout test only"
    var ui = app.interface
    for pixels in [Vector2i(800,600),Vector2i(1920,1080),Vector2i(3440,1440),Vector2i(3840,2160),Vector2i(5120,1440),Vector2i(5120,2880)]:
        root.size=pixels
        app.reset_view()
        app.journey.custom_step(1.0);app._update_camera()
        if ui.active_page!="Weather globe":ui.open_page("Weather globe")
        for frame in range(16):await process_frame
        await RenderingServer.frame_post_draw
        verify(Rect2(Vector2.ZERO,ui.size).encloses(Rect2(ui.panel.position,ui.panel.size)),"Weather controls fit native viewport")
        verify(ui.page_scroll.get_child(0).size.x <= ui.page_scroll.size.x,"Weather controls fit scroll width")
        root.get_texture().get_image().save_png("res://dist/weather-points-%s-%dx%d.png" % ["actual" if actual else "fixture",pixels.x,pixels.y])
        ui.close_panel()
        for frame in range(12):await process_frame
        verify(ui.weather_model_badge.visible,"Closed panel leaves discoverable legend badge")
        verify(Rect2(Vector2.ZERO,ui.size).encloses(Rect2(ui.weather_model_badge.position,ui.weather_model_badge.size)),"Legend badge stays on screen")
        if layer.points.size()==16:
            layer.visit(0);app.journey.custom_step(3.0);app._update_camera()
            for frame in range(8):await process_frame
            var marker: MeshInstance3D = layer.markers[0]
            verify(layer.pick(app.camera.unproject_position(marker.global_position))==0,"Visible native weather point remains clickable")
    app.preview_screensaver()
    for frame in range(12):await process_frame
    verify(not layer.marker_root.visible and layer.request==null,"Native preview hides all model points and requests")
    app.stop_screensaver_preview()
    for path in [app.preferences_path,layer.cache_path]:DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
    app.queue_free()
    await process_frame
    print("Native weather globe layer: %d failures" % failures)
    quit(1 if failures else 0)
