extends Node
var directory := ""
var failures: Array[String] = []
func verify(value: bool, message: String) -> void:
    if not value: failures.append(message);push_error(message)
func stage(name: String, data: Dictionary = {}) -> void:
    data["failures"]=failures
    var file := FileAccess.open(directory.path_join(name+".json"),FileAccess.WRITE)
    file.store_string(JSON.stringify(data));file.close()
func wait_for(clean: Node, hidden: bool) -> void:
    var deadline := Time.get_ticks_msec()+20000
    var stable := 0
    while Time.get_ticks_msec()<deadline:
        await get_tree().process_frame
        if clean.hidden==hidden and clean.pointer_inside!=hidden: stable+=1
        else: stable=0
        if stable>=8: return
    verify(false,"Native pointer did not reach expected hidden state: "+str(hidden))
func run(app: Node3D, args: PackedStringArray) -> void:
    for arg in args:
        if arg.begins_with("--evidence-directory="): directory=arg.trim_prefix("--evidence-directory=")
    verify(OS.get_name()=="Windows" and DisplayServer.get_name()!="headless" and directory.is_absolute_path(),"Requires native installed Windows and an evidence destination")
    if not failures.is_empty():get_tree().quit(1);return
    app.finish_intro()
    var clean=app.clean_view
    var studio=app.space_studio
    studio.preset(2)
    app.interface.open_page("Space studio")
    app.interface.search_query.text="Manila preserved"
    for frame in range(10):await get_tree().process_frame
    stage("ready",{"version":app.VERSION,"validation_pin":clean.validation_pin})
    await wait_for(clean,false)
    verify(app.interface.visible and not clean.validation_pin,"Native pointer inside reveals active menus")
    stage("inside",{"menus_visible":app.interface.visible})
    await wait_for(clean,true)
    verify(not app.interface.visible and app.earth.visible and app.visuals.moon.visible and studio.enabled and studio.credit.visible,"Native pointer outside leaves Earth/Moon/galaxy and credit only")
    verify(app.camera_service.view_suspended,"Native pointer exit pauses hidden camera requests")
    await RenderingServer.frame_post_draw
    get_viewport().get_texture().get_image().save_png(directory.path_join("outside.png"))
    stage("outside",{"menus_visible":app.interface.visible,"moon":app.visuals.moon.visible,"galaxy":studio.enabled})
    await wait_for(clean,false)
    verify(app.interface.visible and app.interface.active_page=="Space studio" and app.interface.search_query.text=="Manila preserved","Native return restores the same page and typed values")
    verify(not app.camera_service.view_suspended,"Native return resumes visibility ownership")
    await RenderingServer.frame_post_draw
    get_viewport().get_texture().get_image().save_png(directory.path_join("returned.png"))
    stage("returned",{"menus_visible":app.interface.visible})
    var path:=directory.path_join("postcard.png")
    await studio.capture_to(path)
    var picture:=Image.load_from_file(path)
    verify(not picture.is_empty() and picture.get_size()==Vector2i(get_viewport().get_visible_rect().size),"Installed clean postcard has actual native dimensions")
    verify(app.interface.visible and not clean.capture and not studio.saving,"Installed postcard restores pointer policy and controls")
    app.set_visual_option("moon",false)
    verify(not app.visuals.moon.visible,"Installed Moon can be disabled")
    app.saver_style=3;app.apply_saver_style()
    verify(not app.visuals.moon.visible,"Installed Deep Space respects Moon-off choice")
    var lib=app.scene_library
    app.distance=3.6;app.zoom_target=3.6;app._update_camera()
    app.visuals.apply_options(true,true,true);studio.set_enabled(true,false)
    var near_radius: float=app.camera.unproject_position(app.visuals.moon.global_transform*Vector3(.41,0,0)).distance_to(app.camera.unproject_position(app.visuals.moon.global_position))
    app.interface.open_page("Scene library")
    lib.name_field.text="Installed Moon & galaxy"
    await lib.save_current()
    verify(lib.scenes.size()==1,"Installed Scene Library saves a real clean thumbnail")
    app.distance=7.5;app.zoom_target=7.5;app._update_camera()
    var far_radius: float=app.camera.unproject_position(app.visuals.moon.global_transform*Vector3(.41,0,0)).distance_to(app.camera.unproject_position(app.visuals.moon.global_position))
    verify(far_radius<near_radius*.5 and far_radius>0,"Installed Moon scales down together with Earth")
    app.visuals.apply_options(true,true,false);studio.set_enabled(false,false)
    lib.name_field.text="Installed quiet orbit"
    await lib.save_current()
    verify(lib.scenes.size()==2,"Installed scene stores independent Moon/galaxy choices")
    lib.select_scene(0)
    verify(app.visuals.moon.visible and studio.enabled and absf(app.distance-3.6)<.00001,"Installed Use restores camera, Moon and galaxy together")
    lib.play();lib.next_scene()
    await get_tree().create_timer(1.2).timeout
    verify(lib.playing and lib.current==1 and not app.visuals.moon.visible and not studio.enabled and is_equal_approx(app.intro_reveal,1),"Installed cinematic transition reaches second scene")
    lib.pause();lib.select_scene(0)
    await RenderingServer.frame_post_draw
    get_viewport().get_texture().get_image().save_png(directory.path_join("scene-library.png"))
    for row in lib.scenes:
        verify(lib.thumbnail(row.id)!=null,"Installed thumbnail reloads from bounded local PNG")
    stage("done",{"version":app.VERSION,"passed":failures.is_empty(),"postcard_pixels":[picture.get_width(),picture.get_height()],"saved_scenes":lib.scenes.size(),"moon_zoom_radii":[near_radius,far_radius],"cinematic_transition":lib.current==0 and not lib.playing,"scope":"Real Windows cursor movements and installed scene capture/playback on isolated virtual desktop; no physical monitor/DPI claim"})
    for filename in DirAccess.get_files_at(lib.directory): DirAccess.remove_absolute(ProjectSettings.globalize_path(lib.directory.path_join(filename)))
    DirAccess.remove_absolute(ProjectSettings.globalize_path(lib.directory))
    DirAccess.remove_absolute(ProjectSettings.globalize_path(app.preferences_path))
    print("Installed native clean view: %d failures" % failures.size())
    get_tree().quit(1 if failures.size() else 0)
