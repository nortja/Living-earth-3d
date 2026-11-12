extends SceneTree
var failures := 0
func _initialize() -> void: call_deferred("run")
func verify(ok: bool, message: String) -> void:
    if not ok: failures+=1;push_error(message)
func run() -> void:
    var app=load("res://scenes/earth.tscn").instantiate()
    app.play_intro=false
    app.preferences_path="user://camera-age-render-%d.cfg" % Time.get_ticks_usec()
    root.add_child(app)
    app.clean_view.validation_pin=true
    var ui=app.interface
    var service=app.camera_service
    ui.select_camera({"name":"TEST FIXTURE · image age","provider":"Test only","latitude":44.97,"longitude":-110.7,"image_url":"invalid","url":"https://www.nps.gov/"})
    service.set_process(false)
    service.automatic=false
    var fixture:=Image.create(320,180,false,Image.FORMAT_RGB8)
    fixture.fill(Color("376f83"))
    var bytes:=fixture.save_jpg_to_buffer()
    service._received(0,200,PackedStringArray(['ETag: "fixture"']),bytes,service.generation)
    service.unchanged_since_ticks=Time.get_ticks_msec()-301000
    service.retrieved="2099-01-01 00:00:00"
    service._received(0,304,PackedStringArray(),PackedByteArray(),service.generation)
    verify(ui.camera_detail.text.contains("Checked") and ui.camera_detail.text.contains("5+ minutes"),"Successful 304 revalidation keeps the elapsed-age warning")
    service._unavailable()
    verify(ui.camera_detail.text.contains("Camera unavailable:") and ui.camera_detail.text.contains("Last successful image retained") and ui.camera_detail.text.contains("5+ minutes"),"Failed refresh keeps the retained-image age warning visible in the actual viewer")
    var retained_before_suspend: Texture2D = service.image
    var late_token: int = service.generation
    service.loading = true
    service._set_minimized(true)
    verify(service.view_suspended and not service.loading and ui.camera_detail.text.contains("Last successful image retained"),"Suspending the native viewer cancels pending refresh and keeps retained-image context")
    service._received(0,200,PackedStringArray(),bytes,late_token)
    verify(service.image == retained_before_suspend and ui.camera_detail.text.contains("5+ minutes"),"Late native-viewer response cannot replace the retained image or erase its age warning")
    service._set_minimized(false)
    verify(not service.view_suspended and ui.camera_detail.text.contains("Camera unavailable:"),"Restoring the native viewer restores its prior failure state")
    service._set_focus_suspended(true)
    verify(service.view_suspended and ui.camera_detail.text.contains("Last successful image retained") and ui.camera_detail.text.contains("5+ minutes"),"Native viewer focus loss keeps retained image and elapsed-age context")
    service._set_focus_suspended(false)
    verify(not service.view_suspended and ui.camera_detail.text.contains("Camera unavailable:"),"Native viewer focus return restores the prior failure state")
    DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://dist"))
    var sizes: Array[Vector2i]=[Vector2i(870,612),Vector2i(2496,1664),Vector2i(3840,1080)]
    if "--compact" in OS.get_cmdline_user_args(): sizes=[Vector2i(870,612)]
    for pixels in sizes:
        root.size=pixels
        for frame in range(12): await process_frame
        await RenderingServer.frame_post_draw
        verify(ui.camera_detail.text.contains("5+ minutes") and ui.camera_detail.text.contains("2099-01-01"),"Failed refresh retains elapsed warning alongside distinct UTC retrieval metadata")
        verify(ui.camera_image.texture!=null and ui.camera_overlay.visible,"Retained fixture image remains visible")
        verify(Rect2(Vector2.ZERO,ui.size).encloses(Rect2(ui.camera_viewer.position,ui.camera_viewer.size)),"Camera viewer fits the rendered window")
        verify(root.get_texture().get_image().save_png("res://dist/camera-age-%dx%d.png" % [pixels.x,pixels.y])==OK,"Native capture saved")
    ui.close_camera()
    DirAccess.remove_absolute(ProjectSettings.globalize_path(app.preferences_path))
    app.queue_free();await process_frame
    print("Native camera age: %d failures" % failures)
    quit(1 if failures else 0)
