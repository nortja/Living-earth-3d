extends Node3D

var earth: MeshInstance3D
var camera: Camera3D
var info: Label
var yaw := PI + 0.25
var pitch := 0.18
var distance := 3.6
var dragging := false
var angular_velocity := Vector2.ZERO
var play_intro := true
var intro_running := false
var intro_reveal := 1.0
var intro_tween: Tween
var earth_material: ShaderMaterial
var atmosphere_material: ShaderMaterial
var sun: DirectionalLight3D
var interface_layer: CanvasLayer
var preferences_path := "user://preferences.cfg"
var zoom_tween: Tween
var zoom_target := 3.6
var screensaver_mode := false
var screensaver_age := 0.0
var destinations: Array = []
var favorites: Array = []
var selected := -1
var discovery_enabled := false
var discovery_interval := 120.0
var elapsed := 0.0
var journey: Tween
var place_picker: OptionButton
var favorite_button: Button
var description: Label
var update_status: Label
var update_request: HTTPRequest
var preferences := ConfigFile.new()
const VERSION := "0.3.0"
const RELEASES_URL := "https://github.com/nortja/Living-earth-3d/releases"


func _ready() -> void:
    var arguments := OS.get_cmdline_args() + OS.get_cmdline_user_args()
    for argument in arguments:
        if argument.to_lower().begins_with("/p"):
            # Windows preview embedding is not implemented; never open a full window for /p.
            set_process(false)
            get_tree().quit()
            return
        if argument.to_lower() == "/s":
            screensaver_mode = true
    if DisplayServer.get_name() != "headless" and not screensaver_mode:
        var available := DisplayServer.screen_get_usable_rect()
        get_window().size = Vector2i(mini(1600, int(available.size.x * 0.85)), mini(900, int(available.size.y * 0.85)))
        get_window().move_to_center()
    var world := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color(0.005, 0.008, 0.025)
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.17, 0.25, 0.43)
    env.ambient_light_energy = 0.25
    world.environment = env
    add_child(world)

    earth = MeshInstance3D.new()
    var sphere := SphereMesh.new()
    sphere.radius = 1.0
    sphere.height = 2.0
    sphere.radial_segments = 96
    sphere.rings = 48
    earth.mesh = sphere
    var mat := ShaderMaterial.new()
    mat.shader = load("res://shaders/earth.gdshader")
    mat.set_shader_parameter("day_map", load("res://assets/earth/day.jpg"))
    mat.set_shader_parameter("night_map", load("res://assets/earth/night.png"))
    mat.set_shader_parameter("ocean_mask", load("res://assets/earth/specular.jpg"))
    earth_material = mat
    earth.material_override = mat
    add_child(earth)

    var atmosphere := MeshInstance3D.new()
    var outer := SphereMesh.new()
    outer.radius = 1.035
    outer.height = 2.07
    atmosphere.mesh = outer
    var glow := ShaderMaterial.new()
    glow.shader = load("res://shaders/atmosphere.gdshader")
    atmosphere_material = glow
    atmosphere.material_override = glow
    add_child(atmosphere)

    sun = DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-25, 150, 0)
    sun.light_energy = 2.0
    add_child(sun)
    mat.set_shader_parameter("sun_direction", sun.basis.z)

    camera = Camera3D.new()
    camera.current = true
    camera.fov = 50.0
    add_child(camera)
    _update_camera()

    var layer := CanvasLayer.new()
    add_child(layer)
    interface_layer = layer
    info = Label.new()
    info.text = "LIVING EARTH 3D  •  Drag to orbit  •  Scroll to zoom"
    info.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
    info.offset_left = 22
    info.offset_right = -22
    info.offset_top = 20
    info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    layer.add_child(info)
    _build_explorer(layer)
    if screensaver_mode:
        layer.hide()
        get_window().mode = Window.MODE_FULLSCREEN
        Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
        discovery_enabled = false
    if play_intro:
        start_intro()

func _process(delta: float) -> void:
    screensaver_age += delta
    if not dragging and angular_velocity.length() > 0.001:
        yaw += angular_velocity.x * delta
        pitch = clampf(pitch + angular_velocity.y * delta, -1.35, 1.35)
        angular_velocity *= exp(-4.5 * delta)
        _update_camera()
    if intro_running or (journey and journey.is_running()) or (zoom_tween and zoom_tween.is_running()):
        _update_camera()
    if selected < 0:
        earth.rotate_y(delta * 0.08)
    if discovery_enabled:
        elapsed += delta
        if elapsed >= discovery_interval:
            elapsed = 0.0
            surprise_me()

func _unhandled_input(event: InputEvent) -> void:
    if screensaver_mode:
        if screensaver_age > 1.0 and (event is InputEventKey or event is InputEventMouseButton or (event is InputEventMouseMotion and event.relative.length() > 3.0)):
            get_tree().quit()
        return
    if intro_running and (event is InputEventMouseButton or event is InputEventKey):
        finish_intro()
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT:
            if event.pressed and event.double_click:
                dragging = false
                angular_velocity = Vector2.ZERO
                _zoom(-0.9)
                return
            dragging = event.pressed
            if dragging:
                angular_velocity = Vector2.ZERO
            if dragging and journey:
                journey.kill()
        elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
            _zoom(-0.2)
        elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            _zoom(0.2)
    elif event is InputEventMouseMotion and dragging:
        var velocity: Vector2 = event.velocity if event.velocity.length() > 0.0 else event.relative * 60.0
        angular_velocity = (Vector2(-velocity.x, velocity.y) * 0.005).limit_length(2.0)
        yaw -= event.relative.x * 0.005
        pitch = clamp(pitch + event.relative.y * 0.005, -1.35, 1.35)
        _update_camera()
    elif event is InputEventKey and event.pressed:
        if event.keycode == KEY_HOME:
            reset_view()
        elif event.keycode == KEY_F11:
            get_window().mode = Window.MODE_WINDOWED if get_window().mode == Window.MODE_FULLSCREEN else Window.MODE_FULLSCREEN
        elif event.keycode == KEY_ESCAPE:
            if get_window().mode == Window.MODE_FULLSCREEN:
                get_window().mode = Window.MODE_WINDOWED
            else:
                get_tree().quit()

func _update_camera() -> void:
    camera.position = Vector3(sin(yaw) * cos(pitch), sin(pitch), cos(yaw) * cos(pitch)) * distance
    camera.look_at(Vector3.ZERO, Vector3.UP)

func _build_explorer(layer: CanvasLayer) -> void:
    destinations = JSON.parse_string(FileAccess.get_file_as_string("res://data/destinations.json"))
    preferences.load(preferences_path)
    favorites = preferences.get_value("explorer", "favorites", [])
    var panel := PanelContainer.new()
    panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
    panel.offset_left = 20
    panel.offset_right = -20
    panel.offset_top = -230
    panel.offset_bottom = -20
    layer.add_child(panel)
    panel.visible = false
    var style := StyleBoxFlat.new()
    style.bg_color = Color(0.025, 0.04, 0.07, 0.94)
    style.set_corner_radius_all(16)
    style.content_margin_left = 18
    style.content_margin_right = 18
    style.content_margin_top = 14
    style.content_margin_bottom = 14
    panel.add_theme_stylebox_override("panel", style)
    var explore := Button.new()
    explore.text = "Explore & settings"
    explore.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
    explore.offset_left = -210
    explore.offset_right = -22
    explore.offset_top = 60
    explore.offset_bottom = 104
    explore.pressed.connect(func(): panel.visible = not panel.visible)
    layer.add_child(explore)
    var reset := Button.new()
    reset.text = "Reset Earth"
    reset.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
    reset.offset_left = -356
    reset.offset_right = -222
    reset.offset_top = 60
    reset.offset_bottom = 104
    reset.pressed.connect(reset_view)
    layer.add_child(reset)
    var scroll_panel := ScrollContainer.new()
    scroll_panel.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    panel.add_child(scroll_panel)
    var box := VBoxContainer.new()
    box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll_panel.add_child(box)
    var controls := HFlowContainer.new()
    box.add_child(controls)
    place_picker = OptionButton.new()
    place_picker.add_item("Explore a destination…")
    for place in destinations:
        place_picker.add_item(place.name)
    place_picker.item_selected.connect(func(index: int):
        if index > 0:
            visit(index - 1))
    controls.add_child(place_picker)
    _button(controls, "Surprise Me", surprise_me)
    favorite_button = _button(controls, "Save favorite", toggle_favorite)
    _button(controls, "Visit favorite", visit_favorite)
    _button(controls, "Free orbit", func():
        selected = -1
        if journey:
            journey.kill()
        description.text = "Free orbit • Drag to explore; scroll to zoom.")
    var discovery := CheckButton.new()
    discovery.text = "Timed discovery (opt-in)"
    discovery.button_pressed = preferences.get_value("explorer", "discovery", false)
    discovery_enabled = discovery.button_pressed
    discovery.toggled.connect(func(enabled: bool):
        discovery_enabled = enabled
        elapsed = 0.0
        preferences.set_value("explorer", "discovery", enabled)
        _save_preferences())
    controls.add_child(discovery)
    var frequency := OptionButton.new()
    for seconds in [60, 120, 300]:
        frequency.add_item("Every %d min" % (seconds / 60), seconds)
    discovery_interval = preferences.get_value("explorer", "interval", 120.0)
    frequency.select({60: 0, 120: 1, 300: 2}.get(int(discovery_interval), 1))
    frequency.item_selected.connect(func(index: int):
        discovery_interval = frequency.get_item_id(index)
        elapsed = 0.0
        preferences.set_value("explorer", "interval", discovery_interval)
        _save_preferences())
    controls.add_child(frequency)
    description = Label.new()
    description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    description.text = "Offline discovery • Choose a place or Surprise Me. Earth imagery: three.js texture collection. Globe-level exploration; no terrain streaming."
    box.add_child(description)
    var updates := HFlowContainer.new()
    box.add_child(updates)
    var automatic := CheckButton.new()
    automatic.text = "Check for updates on startup"
    automatic.button_pressed = preferences.get_value("updates", "automatic", false)
    automatic.toggled.connect(func(enabled: bool):
        preferences.set_value("updates", "automatic", enabled)
        _save_preferences()
        if enabled:
            check_updates())
    updates.add_child(automatic)
    _button(updates, "Check updates", check_updates)
    _button(updates, "Install update", install_update)
    if OS.get_name() == "Windows":
        _button(updates, "Screen saver settings", func():
            var saver := OS.get_executable_path().get_base_dir().path_join("LivingEarth3D.scr")
            if FileAccess.file_exists(saver):
                OS.create_process("rundll32.exe", ["desk.cpl,InstallScreenSaver", saver], false))
    _button(updates, "Official releases", func(): OS.shell_open(RELEASES_URL))
    update_status = Label.new()
    update_status.text = "Version " + VERSION + " • Updates are optional."
    update_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    box.add_child(update_status)
    update_request = HTTPRequest.new()
    update_request.timeout = 15.0
    add_child(update_request)
    update_request.request_completed.connect(_updates_received)
    if automatic.button_pressed:
        check_updates()

func _button(parent: Node, title: String, action: Callable) -> Button:
    var button := Button.new()
    button.text = title
    button.pressed.connect(action)
    parent.add_child(button)
    return button

func visit(index: int) -> void:
    if index < 0 or index >= destinations.size():
        return
    finish_intro()
    angular_velocity = Vector2.ZERO
    selected = index
    var place: Dictionary = destinations[index]
    place_picker.select(index + 1)
    description.text = "%s • %s\n%s\n%.2f°, %.2f° • Globe-level journey" % [place.name, place.region, place.fact, place.latitude, place.longitude]
    favorite_button.text = "Remove favorite" if place.name in favorites else "Save favorite"
    if journey:
        journey.kill()
    if zoom_tween:
        zoom_tween.kill()
    zoom_target = 3.0
    var target_yaw := deg_to_rad(float(place.longitude)) + PI + earth.rotation.y
    target_yaw = yaw + wrapf(target_yaw - yaw, -PI, PI)
    journey = create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    journey.tween_property(self, "yaw", target_yaw, 2.5)
    journey.tween_property(self, "pitch", deg_to_rad(float(place.latitude)), 2.5)
    journey.tween_property(self, "distance", 3.0, 2.5)
    journey.step_finished.connect(func(_step: int): _update_camera())

func surprise_me() -> void:
    if destinations.is_empty():
        return
    var next := randi_range(0, destinations.size() - 1)
    if next == selected:
        next = (next + 1) % destinations.size()
    visit(next)

func toggle_favorite() -> void:
    if selected < 0:
        return
    var place_name: String = destinations[selected].name
    if place_name in favorites:
        favorites.erase(place_name)
    else:
        favorites.append(place_name)
    preferences.set_value("explorer", "favorites", favorites)
    _save_preferences()
    favorite_button.text = "Remove favorite" if place_name in favorites else "Save favorite"

func visit_favorite() -> void:
    for offset in range(1, destinations.size() + 1):
        var index := (selected + offset) % destinations.size()
        if destinations[index].name in favorites:
            visit(index)
            return
    description.text = "Choose a destination and save it to start a favorites journey."

func _save_preferences() -> void:
    if preferences.save(preferences_path) != OK:
        push_warning("Could not save local preferences.")

func check_updates() -> void:
    if update_request.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
        return
    update_status.text = "Checking official GitHub Releases…"
    var error := update_request.request("https://api.github.com/repos/nortja/Living-earth-3d/releases/latest", ["Accept: application/vnd.github+json", "User-Agent: Living-earth-3d/" + VERSION])
    if error != OK:
        update_status.text = "Update check unavailable. Offline exploration still works."

func newer_version(tag: String) -> bool:
    var remote := tag.trim_prefix("v").split(".")
    var local := VERSION.split(".")
    if remote.size() != 3:
        return false
    for part in remote:
        if not part.is_valid_int() or int(part) < 0:
            return false
    for index in range(3):
        if int(remote[index]) != int(local[index]):
            return int(remote[index]) > int(local[index])
    return false

func _updates_received(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
    if result != HTTPRequest.RESULT_SUCCESS:
        update_status.text = "Update check unavailable. Offline exploration still works."
        return
    if code == 404:
        update_status.text = "No published release yet. Running " + VERSION + "."
        return
    var parser := JSON.new()
    var parse_result := parser.parse(body.get_string_from_utf8())
    var release = parser.data
    if code != 200 or parse_result != OK or not release is Dictionary or not release.get("tag_name", null) is String:
        update_status.text = "Update check unavailable. Try again later."
        return
    if newer_version(release.tag_name):
        update_status.text = "Update %s available • Choose Install update (Windows)." % release.tag_name
        if preferences.get_value("updates", "automatic", false) and OS.get_name() == "Windows":
            install_update()
    else:
        update_status.text = "No newer stable version available • " + VERSION

func install_update() -> void:
    var helper := OS.get_executable_path().get_base_dir().path_join("update.ps1")
    if OS.get_name() != "Windows" or not FileAccess.file_exists(helper):
        update_status.text = "Install updates through the Windows installer. Use Official releases for other builds."
        return
    var pid := OS.create_process("powershell.exe", ["-NoProfile", "-WindowStyle", "Hidden", "-File", helper, "-CurrentVersion", VERSION, "-AppProcessId", str(OS.get_process_id())], false)
    update_status.text = "Updater started • A verified update will ask before restarting." if pid > 0 else "Could not start updater. Use Official releases."

func _zoom(amount: float) -> void:
    angular_velocity = Vector2.ZERO
    if journey and journey.is_running():
        journey.kill()
        zoom_target = distance
    if zoom_tween:
        zoom_tween.kill()
    zoom_target = clampf(zoom_target + amount, 1.8, 10.0)
    zoom_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
    zoom_tween.tween_property(self, "distance", zoom_target, 0.18)

func start_intro() -> void:
    intro_running = true
    interface_layer.hide()
    distance = 4.6
    sun.light_energy = 0.0
    _set_intro_reveal(0.0)
    _update_camera()
    intro_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    intro_tween.tween_method(_set_intro_reveal, 0.0, 1.0, 2.8)
    intro_tween.tween_property(sun, "light_energy", 2.0, 2.8)
    intro_tween.tween_property(self, "distance", 3.6, 2.8)
    intro_tween.finished.connect(finish_intro)

func _set_intro_reveal(value: float) -> void:
    intro_reveal = value
    earth_material.set_shader_parameter("visibility", value)
    atmosphere_material.set_shader_parameter("visibility", value)

func finish_intro() -> void:
    if not intro_running:
        return
    intro_running = false
    if intro_tween:
        intro_tween.kill()
    _set_intro_reveal(1.0)
    sun.light_energy = 2.0
    distance = 3.6
    zoom_target = distance
    _update_camera()
    if not screensaver_mode:
        interface_layer.show()

func reset_view() -> void:
    finish_intro()
    angular_velocity = Vector2.ZERO
    dragging = false
    if journey:
        journey.kill()
    if zoom_tween:
        zoom_tween.kill()
    selected = -1
    place_picker.select(0)
    favorite_button.text = "Save favorite"
    description.text = "Full Earth • Drag to spin, scroll or double-click to zoom. Home resets the view."
    zoom_target = 3.6
    var target_yaw := yaw + wrapf(PI + 0.25 + earth.rotation.y - yaw, -PI, PI)
    journey = create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    journey.tween_property(self, "distance", 3.6, 0.8)
    journey.tween_property(self, "pitch", 0.18, 0.8)
    journey.tween_property(self, "yaw", target_yaw, 0.8)
    journey.finished.connect(_update_camera)

func _input(event: InputEvent) -> void:
    # Release must be observed even when a control consumes the mouse event.
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
        dragging = false

func _notification(what: int) -> void:
    if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
        dragging = false
        angular_velocity = Vector2.ZERO
