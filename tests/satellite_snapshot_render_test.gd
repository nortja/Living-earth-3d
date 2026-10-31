extends SceneTree
var failures := 0
func _initialize() -> void: call_deferred("run")
func run() -> void:
    var app = load("res://scenes/earth.tscn").instantiate()
    app.play_intro = false
    app.preferences_path = "user://satellite-render-%d.cfg" % Time.get_ticks_usec()
    root.add_child(app)
    var image := Image.create(2048,1024,false,Image.FORMAT_RGBA8)
    image.fill(Color("356f8e"))
    for x in range(0,2048,64):
        for y in range(256,768): image.set_pixel(x,y,Color("c2d6d8"))
    var bytes := image.save_png_to_buffer()
    var date := "2026-10-30"
    var label := "Synthetic satellite mosaic · render validation"
    for arg in OS.get_cmdline_user_args():
        if arg.begins_with("--snapshot-date="): date=arg.trim_prefix("--snapshot-date=")
    for arg in OS.get_cmdline_user_args():
        if arg.begins_with("--snapshot-image="):
            bytes = FileAccess.get_file_as_bytes(arg.trim_prefix("--snapshot-image="))
            label = "Actual NASA GIBS mosaic · %s UTC · validation" % date
    var service = app.satellite_snapshot
    service.pending_date = date
    service._received(0,200,PackedStringArray(),bytes,service.generation)
    service.status = label + "\nBlack gaps are unavailable imagery. Dated mosaic, not live."
    app.interface._satellite_changed()
    app.fly_to_location({"name":"Atlantic snapshot orientation","latitude":15.0,"longitude":-30.0})
    app.journey.custom_step(3.0)
    for pixels in [Vector2i(800,600),Vector2i(1920,1080),Vector2i(3840,1080),Vector2i(5120,2880)]:
        root.size=pixels
        if app.interface.active_page != "Satellite view": app.interface.open_page("Satellite view")
        for frame in range(20): await process_frame
        await RenderingServer.frame_post_draw
        var ui=app.interface
        if not service.enabled or not app.earth_material.get_shader_parameter("satellite_view") or app.visuals.clouds.visible:
            failures+=1;push_error("Satellite renderer state incorrect")
        if not Rect2(Vector2.ZERO,ui.size).encloses(Rect2(ui.panel.position,ui.panel.size)) or ui.page_scroll.get_child(0).size.x > ui.page_scroll.size.x:
            failures+=1;push_error("Satellite controls do not fit %s" % pixels)
        if not ui.page_scroll.get_global_rect().encloses(ui.satellite_load.get_global_rect()):
            failures+=1;push_error("Initial satellite load action requires scrolling")
        if not ui.page_scroll.get_global_rect().encloses(ui.satellite_date_picker.get_global_rect()):
            failures+=1;push_error("Satellite date selector requires scrolling")
        if ui.satellite_offline.size.x<112 or not ui.page_scroll.get_global_rect().encloses(ui.satellite_offline.get_global_rect()):
            failures+=1;push_error("Offline return requires scrolling")
        root.get_texture().get_image().save_png("res://dist/satellite-%dx%d.png" % [pixels.x,pixels.y])
    service.set_enabled(false)
    for frame in range(12): await process_frame
    await RenderingServer.frame_post_draw
    root.get_texture().get_image().save_png("res://dist/satellite-offline-return.png")
    if app.earth_material.get_shader_parameter("satellite_view") or not app.visuals.clouds.visible:
        failures+=1;push_error("Offline return did not restore default clouds")
    DirAccess.remove_absolute(ProjectSettings.globalize_path(app.preferences_path))
    app.queue_free()
    await process_frame
    print("Native satellite snapshot: %d failures" % failures)
    quit(1 if failures else 0)
