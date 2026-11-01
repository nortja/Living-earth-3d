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
    stage("done",{"version":app.VERSION,"passed":failures.is_empty(),"postcard_pixels":[picture.get_width(),picture.get_height()],"scope":"Real Windows cursor movements on isolated virtual desktop; no physical monitor/DPI claim"})
    DirAccess.remove_absolute(ProjectSettings.globalize_path(app.preferences_path))
    print("Installed native clean view: %d failures" % failures.size())
    get_tree().quit(1 if failures.size() else 0)
