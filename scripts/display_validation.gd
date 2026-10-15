extends Node
## Opt-in native application check used by the Windows validation script.
## This executes the installed app and writes evidence; it never claims a GPU benchmark.
func run(app: Node3D, arguments: PackedStringArray) -> void:
    var output := "user://display-validation"
    for argument in arguments:
        if argument.begins_with("--validation-output="):
            output = argument.trim_prefix("--validation-output=")
    DirAccess.make_dir_recursive_absolute(output)
    var failures: Array = []
    if DisplayServer.get_name() == "headless":
        failures.append("A real native graphics window is required")
    app.finish_intro()
    app.set_quality("detailed", false)
    await get_tree().create_timer(0.8).timeout
    for frame in range(12): await get_tree().process_frame
    await RenderingServer.frame_post_draw
    var viewport := get_viewport()
    var image := viewport.get_texture().get_image()
    var viewport_size := viewport.get_visible_rect().size
    if image.is_empty() or image.get_size() != Vector2i(viewport_size):
        failures.append("Framebuffer differs from native viewport")
    elif image.get_pixel(image.get_width() / 2, image.get_height() / 2).get_luminance() < 0.01:
        failures.append("Globe center is dark or missing")
    var screenshot_path := output.path_join("earth.png")
    if image.save_png(screenshot_path) != OK: failures.append("Screenshot save failed")
    var ui = app.interface
    ui.dashboard = true
    ui.open_page("Command Center")
    for frame in range(4): await get_tree().process_frame
    # Verify actual laid-out sizes, not requested sizes: containers may grow.
    var bounds := Rect2(Vector2.ZERO, ui.size)
    for control in [ui.header, ui.dock, ui.panel]:
        if not bounds.encloses(Rect2(control.position, control.size)):
            failures.append("Interface leaves viewport: " + control.get_class())
    if Rect2(ui.panel.position, ui.panel.size).has_point(ui.size / 2):
        failures.append("Command panel crowds the center of the globe")
    await RenderingServer.frame_post_draw
    if viewport.get_texture().get_image().save_png(output.path_join("command-center.png")) != OK:
        failures.append("Command screenshot save failed")
    var report := {"version": app.VERSION, "platform": OS.get_name(), "display": DisplayServer.get_name(), "viewport": [int(viewport_size.x), int(viewport_size.y)], "ui_scale": ui.display_scale, "gpu": RenderingServer.get_video_adapter_name(), "quality": app.visual_quality, "failures": failures, "passed": failures.is_empty()}
    var file := FileAccess.open(output.path_join("result.json"), FileAccess.WRITE)
    if not file:
        push_error("Cannot save display validation report")
        get_tree().quit(1)
        return
    file.store_string(JSON.stringify(report, "  "))
    print("Native display validation: ", JSON.stringify(report))
    get_tree().quit(0 if failures.is_empty() else 1)
