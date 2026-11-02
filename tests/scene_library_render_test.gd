extends SceneTree
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
    if not ok: failures+=1;push_error(message)
func settle(frames := 8) -> void:
    for frame in range(frames): await process_frame
    await RenderingServer.frame_post_draw
func run() -> void:
    DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://dist"))
    var app = load("res://scenes/earth.tscn").instantiate()
    app.play_intro=false;app.preferences_path="user://scene-render-%d.cfg" % Time.get_ticks_usec()
    root.add_child(app)
    app.clean_view.validation_pin=true
    app.set_quality("detailed",false)
    var lib=app.scene_library
    root.size=Vector2i(1920,1080)
    app.space_studio.preset(2)
    app.interface.open_page("Scene library")
    await settle()
    lib.name_field.text="Blue world · Moon & Milky Way"
    await lib.save_current()
    check(lib.scenes.size()==1 and not lib.busy,"Actual clean capture creates a scene")
    if lib.scenes.is_empty(): quit(1);return
    var first: Dictionary=lib.scenes[0]
    var thumb: Image=Image.load_from_file(ProjectSettings.globalize_path(lib.directory.path_join(first.id+".png")))
    check(thumb.get_size()==Vector2i(384,216) and lib.thumbnail(first.id)!=null,"Native thumbnail is bounded and decodes")
    app.distance=7.5;app.zoom_target=7.5;app._update_camera()
    app.space_studio.set_enabled(false,false);app.visuals.apply_options(true,true,false)
    lib.name_field.text="Quiet orbit · Earth only"
    await lib.save_current()
    check(lib.scenes.size()==2 and not lib.scenes[1].moon and not lib.scenes[1].galaxy,"Independent visual choices captured")
    var sizes := [Vector2i(800,600),Vector2i(870,612),Vector2i(1920,1080),Vector2i(2496,1664),Vector2i(3440,1440),Vector2i(3840,1080),Vector2i(3840,2160),Vector2i(5120,1440),Vector2i(5120,2880)]
    if "--single-preview" in OS.get_cmdline_user_args(): sizes=[Vector2i(1920,1080)]
    for pixels in sizes:
        root.size=pixels
        lib.select_scene(0)
        app.interface.open_page("Live Earth")
        await settle()
        for control in app.interface.live_primary:
            check(app.interface.page_scroll.get_global_rect().encloses(control.get_global_rect()),"Primary navigation %s fits %s: %s within %s" % [control.text,pixels,control.get_global_rect(),app.interface.page_scroll.get_global_rect()])
        if pixels==Vector2i(870,612):
            app.interface.theme.default_font_size=16
            app.interface.refresh_layout()
            await settle()
            for control in app.interface.live_primary:
                check(app.interface.page_scroll.get_global_rect().encloses(control.get_global_rect()),"Larger system-font metrics retain all six primary actions")
            app.interface.theme.default_font_size=14
            app.interface.refresh_layout()
        app.interface.open_page("Scene library")
        await settle()
        for control in [lib.name_field,lib.save_button,lib.play_button,lib.pause_button,lib.next_button,lib.interval_picker,lib.shuffle_toggle]:
            check(app.interface.page_scroll.get_global_rect().encloses(control.get_global_rect()),"Scene primary control %s fits %s: %s within %s" % [control.name,pixels,control.get_global_rect(),app.interface.page_scroll.get_global_rect()])
        root.get_texture().get_image().save_png("res://dist/scene-library-%dx%d.png" % [pixels.x,pixels.y])
    root.size=Vector2i(1920,1080)
    lib.play();lib.next_scene()
    await create_timer(1.1).timeout
    check(lib.playing and lib.current==1 and not app.visuals.moon.visible and not app.space_studio.enabled and is_equal_approx(app.intro_reveal,1.0),"Rendered fade reaches next scene and restores brightness")
    lib.interval=15;lib.elapsed=14.99
    await create_timer(1.2).timeout
    check(lib.current==0 and app.visuals.moon.visible and app.space_studio.enabled,"Timed playback advances automatically")
    app.interface.close_panel()
    check(lib.playing,"Closing menu preserves explicit playback")
    lib.pause()
    # Next is also a live transition when timed playback is stopped.
    var retained_scene: int=lib.current
    var defaults: String=app.preferences.encode_to_text()
    lib.next_scene()
    app.space_studio.dialog=FileDialog.new()
    app.space_studio.dialog.use_native_dialog=false
    app.add_child(app.space_studio.dialog)
    app.space_studio.dialog.popup_centered(Vector2i(500,300))
    await create_timer(1.1).timeout
    check(lib.current==retained_scene and is_equal_approx(app.intro_reveal,1.0),"A file dialog cancels a manual Next before changing the composition")
    check(app.preferences.encode_to_text()==defaults,"Interrupted manual Next preserves visual defaults")
    app.space_studio.dialog.hide()
    await settle()
    lib.next_scene()
    await create_timer(1.1).timeout
    check(lib.current!=retained_scene and is_equal_approx(app.intro_reveal,1.0),"Manual Next still completes after the dialog closes")
    app.clean_view.validation_pin=false;app.clean_view.set_pointer(false)
    var radii: Array[float]=[]
    for distance in [3.6,7.5]:
        app.distance=distance;app.zoom_target=distance;app._update_camera();app.visuals.apply_options(true,true,true)
        await settle()
        var with_moon:=root.get_texture().get_image()
        app.visuals.apply_options(true,true,false)
        await settle()
        var without_moon:=root.get_texture().get_image()
        var center: Vector2=app.camera.unproject_position(app.visuals.moon.global_position)
        var radius: float=absf(app.camera.unproject_position(app.visuals.moon.global_transform*Vector3(.41,0,0)).x-center.x)
        radii.append(radius)
        var changed := 0
        for y in range(maxi(0,int(center.y-radius)),mini(with_moon.get_height(),int(center.y+radius))):
            for x in range(maxi(0,int(center.x-radius)),mini(with_moon.get_width(),int(center.x+radius))):
                if with_moon.get_pixel(x,y).r!=without_moon.get_pixel(x,y).r: changed+=1
        check(changed>50,"Zoomed Moon contributes genuine rendered pixels at "+str(distance))
        with_moon.save_png("res://dist/scene-moon-zoom-%s.png" % str(distance))
    check(radii[1]<radii[0]*.5,"Actual projected Moon shrinks when Earth zooms out")
    var path: String=app.preferences_path
    var directory: String=lib.directory
    var saved := ConfigFile.new()
    check(saved.load(path)==OK and saved.get_value("scene_library","scenes",[]).size()==2,"Actual persisted scene data reloads from disk")
    lib.cache.clear()
    check(lib.thumbnail(first.id)!=null,"Thumbnail reloads from disk rather than in-memory cache")
    for filename in DirAccess.get_files_at(directory): DirAccess.remove_absolute(ProjectSettings.globalize_path(directory.path_join(filename)))
    DirAccess.remove_absolute(ProjectSettings.globalize_path(directory))
    DirAccess.remove_absolute(ProjectSettings.globalize_path(path));app.queue_free();await settle(4)
    print("Native scene library: %d failures" % failures)
    quit(1 if failures else 0)
