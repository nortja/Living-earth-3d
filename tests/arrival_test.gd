extends SceneTree
var failures := 0
var checks := 0
func _initialize() -> void: call_deferred("run")
func verify(ok: bool, message: String) -> void:
    checks += 1
    if not ok:
        failures += 1
        push_error(message)
func run() -> void:
    var app = load("res://scenes/earth.tscn").instantiate()
    app.play_intro = false
    app.preferences_path = "user://arrival-test-%d.cfg" % Time.get_ticks_usec()
    root.add_child(app)
    await process_frame
    var ui = app.interface
    app.visit(0)
    verify(ui.active_page == "Destination" and ui.panel.visible, "Curated journey opens destination")
    verify(ui.arrival_place.name == "Grand Canyon", "Arrival identifies destination")
    app.journey.custom_step(3.0)
    verify(ui.arrival_status.text.contains("You’re here"), "Completed flight confirms arrival")
    ui.arrival_save.pressed.emit()
    verify(app.exploration.is_saved(ui.arrival_place), "Arrival saves selected destination")
    ui.arrival_save.pressed.emit()
    verify(not app.exploration.is_saved(ui.arrival_place), "Arrival removes saved destination")
    ui.exploration_panel.surprise_wonder()
    verify(ui.active_page == "Destination" and ui.arrival_place.has("note"), "Surprise opens its story")
    var first = ui.arrival_place.name
    ui.exploration_panel.surprise_wonder()
    verify(ui.panel.visible and ui.arrival_place.name != first, "Repeated surprises replace visible arrival")
    verify(not app.fly_to_location({"name":"Invalid","latitude":999,"longitude":0}), "Invalid journey rejected")
    verify(ui.arrival_place.name != "Invalid", "Invalid journey preserves destination")
    var venue = ui.cameras[0].duplicate(true)
    venue.image_url = "http://127.0.0.1:1/unavailable.jpg"
    ui.select_camera(venue)
    verify(ui.camera_overlay.visible, "Camera journey automatically opens viewer")
    verify(ui.camera_title.text == venue.name, "Viewer identifies selected camera")
    ui.close_camera()
    verify(ui.panel.visible and ui.arrival_place.name == venue.name, "Closing camera retains destination context")
    ui.cameras[0].image_url = venue.image_url
    app.fly_to_location(app.exploration.sanitize(venue))
    verify(ui.camera_overlay.visible, "Saved camera journey reopens its viewer")
    verify(app.camera_service.selected.name == venue.name, "Saved camera resolves official catalog entry")
    app.fly_to_location({"name":"Search result","latitude":12.0,"longitude":25.0})
    verify(ui.active_page == "Destination" and not ui.camera_overlay.visible, "Search arrival closes previous camera")
    app.fly_to_location(app.exploration.catalog.places[1])
    app._zoom(-0.2)
    ui._process(0.1)
    verify(ui.arrival_status.text.contains("paused"), "Interrupted journey stops claiming it is travelling")
    app.reset_view()
    verify(not ui.panel.visible, "Full Earth dismisses old destination card")
    ui.close_panel()
    app.screensaver_mode = true
    app.fly_to_location(app.exploration.catalog.places[0])
    verify(not ui.panel.visible, "Screensaver journey does not open destination controls")
    app.screensaver_mode = false
    for pixels in [Vector2i(800,600),Vector2i(1920,1080),Vector2i(5120,1440),Vector2i(5120,2880)]:
        root.size = pixels
        app.fly_to_location(app.exploration.catalog.places[0])
        for frame in range(12): await process_frame
        verify(Rect2(Vector2.ZERO,ui.size).encloses(Rect2(ui.panel.position,ui.panel.size)), "Arrival fits %s" % pixels)
        verify(ui.page_scroll.get_child(0).size.x <= ui.page_scroll.size.x, "Arrival text stays within scrolling width")
    DirAccess.remove_absolute(ProjectSettings.globalize_path(app.preferences_path))
    app.queue_free()
    await process_frame
    print("Arrival experience: %d checks, %d failures" % [checks,failures])
    quit(1 if failures else 0)
