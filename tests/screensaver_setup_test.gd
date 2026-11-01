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
    app.preferences_path = "user://saver-setup-%d.cfg" % Time.get_ticks_usec()
    root.add_child(app)
    var ui = app.interface
    var prior: String = app.preferences.encode_to_text()
    verify(not ProjectSettings.get_setting("display/window/energy_saving/keep_screen_on",true),"Desktop app must not inhibit Windows idle screensaving")
    if OS.get_name()!="Windows":
        ui._clear(ui.pages["Screensavers"])
        ui._windows_saver_controls(ui.pages["Screensavers"])
    ui.open_page("Screensavers")
    verify(ui.saver_timer.item_count==6 and ui.saver_timer.get_selected_id()==10,"Explicit ten-minute default among six bounded wait choices")
    verify(ui.saver_secure.button_pressed and ui.saver_apply.text.contains("Apply"),"Secure resume is an explicit choice applied only by the button")
    verify(ui.saver_status.text.contains("Preview alone does not enable"),"Preview and actual idle activation are distinguished")
    for pixels in [Vector2i(800,600),Vector2i(1920,1080),Vector2i(3840,1080),Vector2i(5120,2880)]:
        root.size = pixels
        for frame in range(16): await process_frame
        for control in [ui.saver_timer,ui.saver_secure,ui.saver_apply]:
            verify(ui.page_scroll.get_global_rect().encloses(control.get_global_rect()),"Idle activation controls visible without scrolling at %s" % pixels)
    verify(app.preferences.encode_to_text()==prior,"Opening timer setup does not change saved preferences")
    verify(ui.saver_timer.get_selected_id()==10,"Preview layout cannot apply or alter Windows timer")
    ui.close_panel()
    DirAccess.remove_absolute(ProjectSettings.globalize_path(app.preferences_path))
    app.queue_free()
    await process_frame
    print("Screensaver setup: %d checks, %d failures" % [checks,failures])
    quit(1 if failures else 0)
