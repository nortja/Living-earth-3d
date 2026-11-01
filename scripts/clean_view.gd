extends Node
## Window-level hover, independent of individual menus and their input filters.
signal changed
var app: Node3D
var enabled := true
var pointer_inside := true
var manual := false
var capture := false
var hidden := false
var validation_pin := false
var marker_was_visible := false
var resume_focus: Control

func setup(owner_app: Node3D) -> void:
    app = owner_app
    enabled = app.preferences.get_value("interface","hide_outside",true) == true
    var args := OS.get_cmdline_user_args()
    validation_pin = "--keep-controls-visible" in args or "--validate-display" in args or "--validate-packaged-desktop" in args
    var window := get_window()
    window.mouse_entered.connect(func(): set_pointer(true))
    window.mouse_exited.connect(func(): set_pointer(false))
    window.focus_exited.connect(func(): set_pointer(false))
    window.focus_entered.connect(_focus_returned)
    if DisplayServer.get_name()!="headless": _focus_returned()

func _focus_returned() -> void:
    if DisplayServer.get_name()=="headless": return
    set_pointer(Rect2i(DisplayServer.window_get_position(),get_window().size).has_point(DisplayServer.mouse_get_position()))

func set_pointer(inside: bool) -> void:
    pointer_inside = inside
    if inside: manual = false
    else:
        app.dragging = false
        app.angular_velocity = Vector2.ZERO
    apply()

func set_enabled(value: bool, persist := true) -> void:
    enabled = value
    if not value: manual = false
    if persist:
        app.preferences.set_value("interface","hide_outside",value)
        app._save_preferences()
    apply()
    changed.emit()

func modal_open() -> bool:
    if app.space_studio and app.space_studio.dialog and app.space_studio.dialog.visible: return true
    var dialog = app.interface.exploration_panel.backup_dialog
    return dialog!=null and dialog.visible

func clean_now() -> void:
    manual = true
    apply()

func _process(_delta: float) -> void:
    apply()

func apply() -> void:
    if not app or not app.interface or app.screensaver_mode: return
    var target: bool = capture or (not validation_pin and not modal_open() and (manual or (enabled and not pointer_inside)))
    if target!=hidden:
        hidden = target
        if hidden:
            resume_focus = get_viewport().gui_get_focus_owner()
            app.camera_service.set_view_suspended(true)
            if app.interface.wall.visible: app.interface.wall.manager.set_suspended(true)
        else:
            app.camera_service.set_view_suspended(false)
            if app.interface.wall.visible: app.interface.wall.manager.set_suspended(false)
        changed.emit()
    if hidden:
        if is_instance_valid(app.focus_marker):
            if app.focus_marker.visible: marker_was_visible = true
            app.focus_marker.hide()
        if app.weather_layer: app.weather_layer.marker_root.hide()
        app.interface.journey_studio.marker_root.hide()
    elif app.interface.visible==false:
        if is_instance_valid(app.focus_marker): app.focus_marker.visible = marker_was_visible and app.external_focus
        marker_was_visible = false
        if app.weather_layer: app.weather_layer._update_markers()
        var tour = app.interface.journey_studio
        tour.marker_root.visible = tour.active and not tour.stops.is_empty()
    app.interface.visible = not hidden
    if not hidden and is_instance_valid(resume_focus) and resume_focus.is_visible_in_tree() and get_window().has_focus():
        resume_focus.grab_focus()
        resume_focus = null

func _input(event: InputEvent) -> void:
    if app.screensaver_mode or modal_open(): return
    if event is InputEventMouseMotion and manual and event.relative.length()>3:
        manual = false
        apply()
    if event is InputEventKey and event.pressed and not event.echo:
        var focus := get_viewport().gui_get_focus_owner()
        if focus is LineEdit or focus is TextEdit: return
        if event.keycode==KEY_H or (event.keycode==KEY_ESCAPE and hidden):
            manual = not hidden
            if not manual: pointer_inside = true
            apply()
            get_viewport().set_input_as_handled()
