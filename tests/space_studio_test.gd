extends SceneTree
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("run")
func verify(ok: bool, message: String) -> void:
    checks += 1
    if not ok: failures += 1;push_error(message)
func run() -> void:
    var app = load("res://scenes/earth.tscn").instantiate()
    app.play_intro = false
    app.preferences_path = "user://space-test-%d.cfg" % Time.get_ticks_usec()
    root.add_child(app)
    var studio = app.space_studio
    var clean = app.clean_view
    clean.validation_pin = false
    verify(not studio.enabled and studio.material.panorama==null,"Galaxy is optional and does not load a texture by default")
    verify(clean.enabled and clean.pointer_inside and app.interface.visible,"Fresh clean-view policy defaults on without hiding headless controls")
    var ui = app.interface
    ui.open_page("Space studio")
    verify(ui.live_primary.size()==6 and ui.pages["Live Earth"].get_child(0).text.begins_with("Space studio"),"Space studio is directly discoverable")
    studio.preset(2)
    verify(studio.enabled and app.visuals.moon_enabled and studio.material.panorama.get_size()==Vector2(4096,2048),"Galactic Earth uses native 4K photographic panorama and chosen Moon")
    studio.set_brightness(NAN);studio.set_orientation(INF)
    verify(studio.brightness==0.75 and studio.orientation==110,"Nonfinite display settings rejected")
    studio.set_brightness(99);studio.set_orientation(-99)
    verify(studio.brightness==1.5 and studio.orientation==0,"Bounded scene settings")
    studio.set_brightness(0.75);studio.set_orientation(110)
    var before: String = app.preferences.encode_to_text()
    ui.open_page("Explore");ui.exploration_panel.select_section("Search");ui.search_query.text="Manila"
    var page: String = ui.active_page
    app.dragging = true;app.angular_velocity = Vector2.ONE
    clean.set_pointer(false)
    verify(clean.hidden and not ui.visible and ui.panel.visible,"Pointer leaves: hide entire UI without closing active page")
    verify(not app.dragging and app.angular_velocity==Vector2.ZERO,"Pointer exit terminates drag/inertia safely")
    verify(app.earth.visible and app.visuals.moon.visible and studio.enabled,"Earth, chosen Moon and galaxy remain rendered")
    verify(app.camera_service.view_suspended,"Hidden camera work is paused")
    verify(app.preferences.encode_to_text()==before,"Pointer events write no preferences")
    clean.set_pointer(true)
    verify(not clean.hidden and ui.visible and ui.active_page==page and ui.search_query.text=="Manila","Return restores page and typed search")
    verify(not app.camera_service.view_suspended,"Camera pause ownership released on return")
    clean.clean_now()
    verify(clean.manual and clean.hidden,"Explicit clean scene hides controls within the window")
    var motion := InputEventMouseMotion.new();motion.relative=Vector2(10,0)
    clean._input(motion)
    verify(not clean.hidden,"Pointer movement returns from manual cinema view")
    clean.set_enabled(false,false);clean.set_pointer(false)
    verify(ui.visible,"User can disable automatic hiding")
    clean.set_enabled(true,false);clean.set_pointer(true)
    studio.choose_file()
    verify(studio.dialog!=null and studio.dialog.file_mode==FileDialog.FILE_MODE_SAVE_FILE and studio.dialog.use_native_dialog,"Export uses explicit chosen-file save dialog")
    clean.set_pointer(false)
    verify(studio.dialog.visible and ui.visible,"Chosen-file dialog stays usable when pointer leaves")
    studio.dialog.hide()
    clean.apply()
    verify(clean.hidden,"Dialog closure reapplies actual outside-pointer policy")
    clean.set_pointer(true)
    studio.capture_to("relative.png")
    verify(studio.status.contains("absolute PNG") and not studio.saving,"Invalid paths fail without hiding UI or writing")
    for option in [false,true]:
        app.set_visual_option("moon",option)
        for style in range(6):
            app.saver_style = style;app.apply_saver_style()
            verify(app.visuals.moon_enabled==option,"Every screensaver respects optional Moon")
    clean.set_pointer(false)
    app.preview_screensaver()
    verify(app.screensaver_mode and not app.interface_layer.visible,"Preview remains hidden independently of pointer policy")
    clean.set_pointer(true)
    verify(not app.interface_layer.visible,"Returning mouse cannot reveal saver UI")
    app.stop_screensaver_preview()
    verify(app.visuals.moon_enabled and studio.enabled,"Preview restores the saved optional scene")
    studio.set_enabled(false)
    verify(studio.material.panorama==null and not studio.enabled,"Disabled galaxy releases its material texture")
    var path: String = app.preferences_path
    app.queue_free();await process_frame
    var restored = load("res://scenes/earth.tscn").instantiate()
    restored.play_intro=false;restored.preferences_path=path;root.add_child(restored)
    verify(restored.visuals.moon_enabled and not restored.space_studio.enabled and restored.space_studio.brightness==0.75,"Visual choices restore from local preferences")
    DirAccess.remove_absolute(ProjectSettings.globalize_path(path));restored.queue_free();await process_frame
    print("Space studio: %d checks, %d failures" % [checks,failures])
    quit(1 if failures else 0)
