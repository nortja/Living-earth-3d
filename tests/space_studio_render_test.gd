extends SceneTree
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(value: bool, message: String) -> void:
    if not value: failures+=1;push_error(message)
func run() -> void:
    var app = load("res://scenes/earth.tscn").instantiate()
    app.play_intro=false;app.preferences_path="user://space-render-%d.cfg" % Time.get_ticks_usec()
    root.add_child(app)
    var clean = app.clean_view
    clean.validation_pin=true
    app.space_studio.preset(2)
    app.set_quality("detailed",false)
    var sizes := [Vector2i(800,600),Vector2i(1920,1080),Vector2i(2496,1664),Vector2i(3440,1440),Vector2i(3840,1080),Vector2i(3840,2160),Vector2i(5120,1440),Vector2i(5120,2880)]
    if "--single-preview" in OS.get_cmdline_user_args(): sizes=[Vector2i(1920,1080)]
    for pixels in sizes:
        root.size=pixels
        app.interface.open_page("Space studio")
        if not app.interface.panel.visible: app.interface.open_page("Space studio")
        for frame in range(16): await process_frame
        await RenderingServer.frame_post_draw
        for control in [app.space_studio.moon_toggle,app.space_studio.galaxy_toggle,app.space_studio.clean_button,app.space_studio.save_button,app.space_studio.hide_toggle]:
            check(app.interface.page_scroll.get_global_rect().encloses(control.get_global_rect()),"Space studio primary controls fit "+str(pixels))
        root.get_texture().get_image().save_png("res://dist/space-controls-%dx%d.png" % [pixels.x,pixels.y])
        clean.validation_pin=false;clean.set_pointer(false)
        for frame in range(8): await process_frame
        await RenderingServer.frame_post_draw
        check(clean.hidden and not app.interface.visible and app.space_studio.credit.visible,"Clean scene has no menus and retains photographic credit")
        var path := "res://dist/space-clean-%dx%d.png" % [pixels.x,pixels.y]
        root.get_texture().get_image().save_png(path)
        if pixels==Vector2i(1920,1080):
            var with_moon := root.get_texture().get_image()
            app.set_visual_option("moon",false)
            for frame in range(4): await process_frame
            await RenderingServer.frame_post_draw
            var without_moon := root.get_texture().get_image()
            var center: Vector2 = app.camera.unproject_position(app.visuals.moon.global_position)
            var differs := false
            for y in range(int(center.y)-20,int(center.y)+20):
                for x in range(int(center.x)-20,int(center.x)+20):
                    if absf(with_moon.get_pixel(x,y).r-without_moon.get_pixel(x,y).r)+absf(with_moon.get_pixel(x,y).g-without_moon.get_pixel(x,y).g)>0.02: differs=true
            check(differs,"Chosen Moon must contribute actual rendered pixels against the galaxy")
            app.set_visual_option("moon",true)
        if pixels==Vector2i(1920,1080):
            var output := ProjectSettings.globalize_path("res://dist/space-postcard.png")
            await app.space_studio.capture_to(output)
            var picture := Image.load_from_file(output)
            check(picture.get_size()==pixels and not app.space_studio.saving and clean.hidden,"Postcard preserves native pixels and prior hidden state")
        clean.set_pointer(true);clean.validation_pin=true
        app.interface.open_page("Live Earth")
        for frame in range(12): await process_frame
        for control in app.interface.live_primary:
            check(app.interface.page_scroll.get_global_rect().encloses(control.get_global_rect()),"Primary Live Earth entry fits "+str(pixels))
    DirAccess.remove_absolute(ProjectSettings.globalize_path(app.preferences_path));app.queue_free();await process_frame
    print("Native space studio: %d failures" % failures)
    quit(1 if failures else 0)
