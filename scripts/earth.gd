extends Node3D

const SolarPosition = preload("res://scripts/solar_position.gd")
var utc_sunlight := false
var solar_sample: Dictionary = {}
var solar_sample_ticks := -60000

const EarthInterface = preload("res://scripts/earth_interface.gd")
const CameraService = preload("res://scripts/camera_service.gd")
var camera_service: Node

const EarthServices = preload("res://scripts/earth_services.gd")

const PlanetVisuals = preload("res://scripts/planet_visuals.gd")

const AmbientSound = preload("res://scripts/ambient_sound.gd")
var ambient: AudioStreamPlayer

var interface: Control
var services: Node
var monitor_poll := 0.0
var update_poll := 0.0
var update_check_age := 0.0
var last_monitor := -1
var external_focus := false
var saver_style := 0
var saver_preview := false
var previous_window_mode := Window.MODE_WINDOWED
var saved_discovery := false
var saved_interval := 120.0
var focus_marker: MeshInstance3D

var visuals: Node3D
var visual_quality := "balanced"
var power_saving := false
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
var update_feed: Dictionary = {}
var update_request: HTTPRequest
var preferences := ConfigFile.new()
const VERSION := "0.6.0"
const UPDATE_FEED_URL := "https://raw.githubusercontent.com/nortja/Living-earth-3d/main/updates/preview.json"
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
    if DisplayServer.get_name() != "headless" and not screensaver_mode and "--validate-display" not in arguments:
        var available := DisplayServer.screen_get_usable_rect()
        get_window().size = Vector2i(mini(1600, int(available.size.x * 0.85)), mini(900, int(available.size.y * 0.85)))
        get_window().move_to_center()
    var world := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color(0.005, 0.008, 0.025)
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.17, 0.25, 0.43)
    env.ambient_light_energy = 0.12
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
    mat.set_shader_parameter("cloud_map", load("res://assets/earth/clouds.jpg"))
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
    sun.light_energy = 1.6
    add_child(sun)
    mat.set_shader_parameter("sun_direction", sun.basis.z)
    glow.set_shader_parameter("sun_direction", sun.basis.z)
    visuals = PlanetVisuals.new()
    add_child(visuals)
    visuals.setup(earth)

    camera = Camera3D.new()
    camera.current = true
    camera.fov = 50.0
    add_child(camera)
    _update_camera()

    var layer := CanvasLayer.new()
    add_child(layer)
    interface_layer = layer
    _build_explorer(layer)
    update_sunlight()
    if screensaver_mode:
        layer.hide()
        get_window().mode = Window.MODE_FULLSCREEN
        Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
        apply_saver_style()
    if "--validate-display" in arguments:
        var validation = load("res://scripts/display_validation.gd").new()
        add_child(validation)
        validation.call_deferred("run", self, arguments)
    elif play_intro:
        start_intro()

func _process(delta: float) -> void:
    screensaver_age += delta
    if not screensaver_mode and OS.get_name() == "Windows":
        update_poll += delta
        update_check_age += delta
        if update_poll >= 2.0:
            update_poll = 0.0
            refresh_update_status()
        if update_check_age >= 1800.0:
            update_check_age = 0.0
            start_auto_update()
    monitor_poll += delta
    if monitor_poll >= 2.0 and DisplayServer.get_name() != "headless":
        monitor_poll = 0.0
        if last_monitor != get_window().current_screen:
            last_monitor = get_window().current_screen
            apply_frame_limit()
            interface.monitor_status.text = display_summary()
    visuals.advance(delta)
    earth_material.set_shader_parameter("cloud_offset", visuals.clouds.rotation.y / TAU)
    if not dragging and angular_velocity.length() > 0.001:
        yaw += angular_velocity.x * delta
        pitch = clampf(pitch + angular_velocity.y * delta, -1.35, 1.35)
        angular_velocity *= exp(-4.5 * delta)
        _update_camera()
    if intro_running or (journey and journey.is_running()) or (zoom_tween and zoom_tween.is_running()):
        _update_camera()
    if selected < 0 and not external_focus:
        earth.rotate_y(delta * (0.025 if screensaver_mode else 0.08))
    if utc_sunlight and not (screensaver_mode and saver_style == 2):
        update_sunlight()
    if screensaver_mode and saver_style == 2:
        sun.look_at(camera.position.normalized(), Vector3.UP)
        earth_material.set_shader_parameter("sun_direction", sun.basis.z)
        atmosphere_material.set_shader_parameter("sun_direction", sun.basis.z)
    if discovery_enabled:
        elapsed += delta
        if elapsed >= discovery_interval:
            elapsed = 0.0
            surprise_me()

func _unhandled_input(event: InputEvent) -> void:
    if screensaver_mode:
        if screensaver_age > 1.0 and (event is InputEventKey or event is InputEventMouseButton or (event is InputEventMouseMotion and event.relative.length() > 3.0)):
            if saver_preview:
                stop_screensaver_preview()
            else:
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
            toggle_fullscreen()
        elif event.keycode == KEY_ESCAPE:
            if interface.camera_overlay.visible:
                interface.close_camera()
            elif interface.wall.visible:
                interface.wall.close()
            elif interface.panel.visible:
                interface.close_panel()
            elif get_window().mode == Window.MODE_FULLSCREEN:
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
    discovery_enabled = preferences.get_value("explorer", "discovery", false)
    discovery_interval = preferences.get_value("explorer", "interval", 120.0)
    saver_style = clampi(int(preferences.get_value("screensaver", "style", 0)), 0, 3)
    utc_sunlight = bool(preferences.get_value("visuals", "utc_sunlight", false))
    ambient = AmbientSound.new()
    add_child(ambient)
    ambient.setup(preferences, screensaver_mode)
    services = EarthServices.new()
    add_child(services)
    update_request = HTTPRequest.new()
    update_request.timeout = 15.0
    add_child(update_request)
    update_request.request_completed.connect(_updates_received)
    camera_service = CameraService.new()
    add_child(camera_service)
    interface = EarthInterface.new()
    layer.add_child(interface)
    interface.setup(self)
    if not screensaver_mode and "--validate-display" not in OS.get_cmdline_user_args() and DisplayServer.get_name() != "headless":
        call_deferred("start_auto_update")

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
    external_focus = false
    favorite_button.disabled = false
    if focus_marker: focus_marker.hide()
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
    update_status.text = "Checking Living Earth 3D updates…"
    var error := update_request.request(UPDATE_FEED_URL, ["Accept: application/json", "User-Agent: Living-earth-3d/" + VERSION])
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
        update_status.text = "No published update yet. Running " + VERSION + "."
        return
    var parser := JSON.new()
    var parse_result := parser.parse(body.get_string_from_utf8())
    var feed = parser.data
    if code != 200 or parse_result != OK or not valid_update_feed(feed):
        update_status.text = "Update check unavailable. Try again later."
        return
    update_feed = feed
    if newer_version(feed.version):
        update_status.text = "Version %s available · checking release signature…" % feed.version
        start_auto_update()
    else:
        update_status.text = "You're up to date • " + VERSION

func valid_update_feed(feed: Variant) -> bool:
    if not feed is Dictionary:
        return false
    var version = feed.get("version")
    var digest = feed.get("sha256")
    if not version is String or not digest is String:
        return false
    var parts: PackedStringArray = version.split(".")
    if parts.size() != 3:
        return false
    for part in parts:
        if not part.is_valid_int() or int(part) < 0 or str(int(part)) != part:
            return false
    if digest.length() != 64 or digest.to_lower() != digest:
        return false
    for character in digest:
        if character not in "0123456789abcdef":
            return false
    var expected := "https://github.com/nortja/Living-earth-3d/raw/refs/heads/downloads/windows-%s/LivingEarth3D-Setup-%s.exe" % [version, version]
    return feed.get("installer_url") == expected and feed.get("channel") == "preview" and feed.get("installer_signed") is bool

func download_latest() -> void:
    if valid_update_feed(update_feed):
        OS.shell_open(update_feed.installer_url)
    else:
        update_status.text = "Check updates first to find the latest installer."

func background_updates_enabled() -> bool:
    return preferences.get_value("updates", "background", true)

func set_background_updates(enabled: bool) -> void:
    preferences.set_value("updates", "background", enabled)
    _save_preferences()
    if enabled:
        start_auto_update()
    else:
        _launch_update_helper(false, true)
        update_status.text = "Automatic updates are paused."

func start_auto_update() -> void:
    if background_updates_enabled():
        _launch_update_helper(false, false)

func install_update() -> void:
    _launch_update_helper(true, false)

func _launch_update_helper(restart_now: bool, cancel: bool) -> void:
    if screensaver_mode:
        return
    var directory := OS.get_executable_path().get_base_dir()
    var helper := directory.path_join("update.ps1")
    if OS.get_name() != "Windows" or not FileAccess.file_exists(helper):
        if restart_now:
            update_status.text = "Automatic updates are available in the installed Windows app."
        return
    if not cancel:
        DirAccess.remove_absolute(directory.path_join(".updates/cancel"))
    var arguments := PackedStringArray(["-NoProfile", "-NonInteractive", "-ExecutionPolicy", "Bypass", "-WindowStyle", "Hidden", "-File", helper, "-CurrentVersion", VERSION, "-AppProcessId", str(OS.get_process_id())])
    if restart_now: arguments.append("-RestartNow")
    if cancel: arguments.append("-Cancel")
    var pid := OS.create_process("powershell.exe", arguments, false)
    if not cancel:
        update_status.text = "Checking verified updates in the background…" if pid > 0 else "Updater could not start. Your current app still works."

func refresh_update_status() -> void:
    var path := OS.get_executable_path().get_base_dir().path_join(".updates/status.json")
    if not FileAccess.file_exists(path): return
    var status = JSON.parse_string(FileAccess.get_file_as_string(path))
    if status is Dictionary and status.get("message") is String:
        update_status.text = str(status.message).left(500)


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
    intro_tween.tween_property(sun, "light_energy", 1.6, 2.8)
    intro_tween.tween_property(self, "distance", 3.6, 2.8)
    intro_tween.finished.connect(finish_intro)

func _set_intro_reveal(value: float) -> void:
    intro_reveal = value
    earth_material.set_shader_parameter("visibility", value)
    atmosphere_material.set_shader_parameter("visibility", value)
    visuals.set_reveal(value)

func finish_intro() -> void:
    if not intro_running:
        return
    intro_running = false
    if intro_tween:
        intro_tween.kill()
    _set_intro_reveal(1.0)
    sun.light_energy = 1.6
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
    external_focus = false
    favorite_button.disabled = false
    if focus_marker: focus_marker.hide()
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

func _build_visual_options(box: VBoxContainer) -> void:
    var row := HFlowContainer.new()
    box.add_child(row)
    visuals.apply_options(preferences.get_value("visuals", "clouds", true), preferences.get_value("visuals", "stars", true), preferences.get_value("visuals", "moon", false))
    for option in ["clouds", "stars", "moon"]:
        var toggle := CheckButton.new()
        toggle.text = {"clouds": "Clouds · offline", "stars": "Stars", "moon": "Moon · artistic"}[option]
        toggle.button_pressed = preferences.get_value("visuals", option, option != "moon")
        toggle.tooltip_text = "Offline cloud artwork drifts independently; this is not live weather." if option == "clouds" else "Artistic backdrop, not live astronomical positions."
        toggle.toggled.connect(func(enabled: bool): set_visual_option(option, enabled))
        row.add_child(toggle)
    var quality := OptionButton.new()
    quality.add_item("Balanced · 2K")
    quality.add_item("Detailed · 4K")
    var saved_quality: String = preferences.get_value("visuals", "quality", "balanced")
    set_quality(saved_quality, false)
    quality.select(1 if visual_quality == "detailed" else 0)
    quality.item_selected.connect(func(index: int): set_quality("detailed" if index == 1 else "balanced"))
    row.add_child(quality)
    var power := CheckButton.new()
    power.text = "Power saving · 30 FPS"
    power_saving = preferences.get_value("visuals", "power_saving", false)
    power.button_pressed = power_saving
    apply_frame_limit()
    power.toggled.connect(func(enabled: bool):
        power_saving = enabled
        apply_frame_limit()
        preferences.set_value("visuals", "power_saving", enabled)
        _save_preferences())
    row.add_child(power)
    earth_material.set_shader_parameter("cloud_strength", 0.12 if visuals.clouds_enabled else 0.0)

func set_visual_option(option: String, enabled: bool) -> void:
    if option not in ["clouds", "stars", "moon"]:
        return
    preferences.set_value("visuals", option, enabled)
    visuals.apply_options(preferences.get_value("visuals", "clouds", true), preferences.get_value("visuals", "stars", true), preferences.get_value("visuals", "moon", false))
    earth_material.set_shader_parameter("cloud_strength", 0.12 if visuals.clouds_enabled else 0.0)
    _save_preferences()

func set_quality(quality: String, persist := true) -> void:
    visual_quality = quality if quality in ["balanced", "detailed"] else "balanced"
    var high := visual_quality == "detailed"
    earth_material.set_shader_parameter("day_map", load("res://assets/earth/day_4k.jpg" if high else "res://assets/earth/day.jpg"))
    earth_material.set_shader_parameter("night_map", load("res://assets/earth/night_4k.jpg" if high else "res://assets/earth/night.png"))
    if persist:
        preferences.set_value("visuals", "quality", visual_quality)
        _save_preferences()


func apply_frame_limit() -> void:
    var refresh := DisplayServer.screen_get_refresh_rate(get_window().current_screen) if DisplayServer.get_name() != "headless" else 60.0
    Engine.max_fps = mini(30 if power_saving else 60, int(refresh)) if refresh >= 24 else (30 if power_saving else 60)

func display_summary() -> String:
    if DisplayServer.get_name() == "headless":
        return "Headless validation · display and GPU unavailable"
    var monitor := DisplayServer.screen_get_size(get_window().current_screen)
    var refresh := DisplayServer.screen_get_refresh_rate(get_window().current_screen)
    return "%d × %d · %.0f Hz · %d DPI\n%s\nNative resolution · proportional globe · adjustable interface size" % [monitor.x, monitor.y, refresh, DisplayServer.screen_get_dpi(get_window().current_screen), RenderingServer.get_video_adapter_name()]

func toggle_fullscreen() -> void:
    get_window().mode = Window.MODE_WINDOWED if get_window().mode == Window.MODE_FULLSCREEN else Window.MODE_FULLSCREEN
    apply_frame_limit()

func fly_to_location(place: Dictionary) -> bool:
    if not EarthServices.valid_coordinates(place.get("latitude"), place.get("longitude")):
        return false
    finish_intro()
    selected = -1
    external_focus = true
    dragging = false
    angular_velocity = Vector2.ZERO
    favorite_button.disabled = true
    place_picker.select(0)
    description.text = "%s\n%.4f°, %.4f° · approximate globe location" % [str(place.get("name", "Location")), place.latitude, place.longitude]
    if journey: journey.kill()
    if zoom_tween: zoom_tween.kill()
    zoom_target = 3.0
    var longitude := deg_to_rad(float(place.longitude)) + PI
    var latitude := deg_to_rad(float(place.latitude))
    if not focus_marker:
        focus_marker = MeshInstance3D.new()
        var dot := SphereMesh.new()
        dot.radius = 0.009
        dot.height = 0.018
        focus_marker.mesh = dot
        var material := StandardMaterial3D.new()
        material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
        material.albedo_color = Color("7ce8ee")
        focus_marker.material_override = material
        earth.add_child(focus_marker)
    focus_marker.position = Vector3(sin(longitude) * cos(latitude), sin(latitude), cos(longitude) * cos(latitude)) * 1.045
    focus_marker.show()
    var target := yaw + wrapf(longitude + earth.rotation.y - yaw, -PI, PI)
    journey = create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    journey.tween_property(self, "yaw", target, 2.2)
    journey.tween_property(self, "pitch", latitude, 2.2)
    journey.tween_property(self, "distance", 3.0, 2.2)
    return true

func apply_saver_style() -> void:
    discovery_enabled = saver_style == 1
    discovery_interval = 120.0
    elapsed = 0.0
    if saver_style == 1:
        surprise_me()
    else:
        reset_view()
    if saver_style == 3:
        visuals.apply_options(visuals.clouds_enabled, true, true)

func preview_screensaver() -> void:
    finish_intro()
    interface.close_camera()
    interface.wall.close()
    previous_window_mode = get_window().mode
    saved_discovery = discovery_enabled
    saved_interval = discovery_interval
    update_request.cancel_request()
    services.quake_request.cancel_request()
    services.search_request.cancel_request()
    ambient.set_suspended(true)
    _launch_update_helper(false, true)
    saver_preview = true
    screensaver_mode = true
    screensaver_age = 0.0
    interface_layer.hide()
    get_window().mode = Window.MODE_FULLSCREEN
    Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
    apply_saver_style()

func stop_screensaver_preview() -> void:
    screensaver_mode = false
    saver_preview = false
    ambient.set_suspended(false)
    discovery_enabled = saved_discovery
    discovery_interval = saved_interval
    update_sunlight()
    visuals.apply_options(preferences.get_value("visuals", "clouds", true), preferences.get_value("visuals", "stars", true), preferences.get_value("visuals", "moon", false))
    get_window().mode = previous_window_mode
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    interface_layer.show()
    reset_view()


func set_utc_sunlight(enabled: bool) -> void:
    utc_sunlight = enabled
    preferences.set_value("visuals", "utc_sunlight", enabled)
    _save_preferences()
    solar_sample_ticks = -60000
    update_sunlight()

func update_sunlight() -> void:
    if utc_sunlight:
        var ticks := Time.get_ticks_msec()
        if solar_sample.is_empty() or ticks - solar_sample_ticks >= 30000:
            solar_sample = SolarPosition.at_unix(Time.get_unix_time_from_system())
            solar_sample_ticks = ticks
            if interface and interface.solar_status:
                interface.solar_status.text = "Calculated for %s UTC\nSubsolar point: %.1f°, %.1f°\nApproximate sunlight from your device clock; not a live observation." % [solar_sample.utc, solar_sample.latitude, solar_sample.longitude]
        # Earth's cinematic spin must not move the terminator across geographic locations.
        var direction: Vector3 = earth.global_basis * solar_sample.direction
        sun.look_at(-direction, Vector3.UP)
    else:
        sun.rotation_degrees = Vector3(-25, 150, 0)
        if interface and interface.solar_status:
            interface.solar_status.text = "Cinematic lighting selected. Current sunlight is off."
    earth_material.set_shader_parameter("sun_direction", sun.global_basis.z)
    atmosphere_material.set_shader_parameter("sun_direction", sun.global_basis.z)
