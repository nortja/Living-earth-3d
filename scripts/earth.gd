extends Node3D

const Catalog = preload("res://scripts/destinations.gd")
const MIN_DISTANCE := 1.8
const MAX_DISTANCE := 10.0

var earth: MeshInstance3D
var camera: Camera3D
var info: Label
var yaw := 0.0
var pitch := 0.18
var distance := 3.6
var dragging := false
var auto_rotate := true
var selected_destination := -1
var target_yaw := 0.0
var target_pitch := 0.18
var target_distance := 3.6
var marker: MeshInstance3D
var destination_picker: OptionButton
var destination_info: Label
var rotation_button: CheckButton
var camera_tween: Tween

func _ready() -> void:
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
    mat.shader = preload("res://assets/earth.gdshader")
    mat.set_shader_parameter("earth_map", preload("res://assets/earth_map.svg"))
    earth.material_override = mat
    add_child(earth)

    var atmosphere := MeshInstance3D.new()
    var outer := SphereMesh.new()
    outer.radius = 1.035
    outer.height = 2.07
    atmosphere.mesh = outer
    var glow := StandardMaterial3D.new()
    glow.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    glow.albedo_color = Color(0.22, 0.56, 1.0, 0.10)
    glow.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    glow.cull_mode = BaseMaterial3D.CULL_DISABLED
    atmosphere.material_override = glow
    add_child(atmosphere)

    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-25, -45, 0)
    sun.light_energy = 2.0
    add_child(sun)

    camera = Camera3D.new()
    camera.current = true
    camera.fov = 50.0
    add_child(camera)
    _update_camera()

    marker = MeshInstance3D.new()
    var pin := SphereMesh.new()
    pin.radius = 0.018
    pin.height = 0.036
    marker.mesh = pin
    var pin_material := StandardMaterial3D.new()
    pin_material.albedo_color = Color(1.0, 0.77, 0.3)
    pin_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    marker.material_override = pin_material
    marker.visible = false
    earth.add_child(marker)
    _build_interface()

func _build_interface() -> void:
    var layer := CanvasLayer.new()
    add_child(layer)
    var panel := PanelContainer.new()
    panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
    panel.offset_left = 16
    panel.offset_right = -16
    panel.offset_top = 16
    layer.add_child(panel)
    var margin := MarginContainer.new()
    for side in ["left", "top", "right", "bottom"]:
        margin.add_theme_constant_override("margin_" + side, 12)
    panel.add_child(margin)
    var column := VBoxContainer.new()
    column.add_theme_constant_override("separation", 8)
    margin.add_child(column)
    info = Label.new()
    info.text = "LIVING EARTH 3D  |  Explorer"
    info.add_theme_font_size_override("font_size", 24)
    column.add_child(info)
    var help := Label.new()
    help.text = "Drag to orbit • Scroll to zoom • Space to pause • Home to reset • Esc to quit"
    help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    column.add_child(help)
    var controls := HFlowContainer.new()
    controls.add_theme_constant_override("h_separation", 12)
    column.add_child(controls)
    destination_picker = OptionButton.new()
    destination_picker.add_item("Explore a destination…")
    for place in Catalog.PLACES:
        destination_picker.add_item(place.name)
    destination_picker.item_selected.connect(func(index: int):
        if index > 0:
            visit_destination(index - 1))
    controls.add_child(destination_picker)
    var surprise := Button.new()
    surprise.text = "Surprise me"
    surprise.pressed.connect(surprise_me)
    controls.add_child(surprise)
    rotation_button = CheckButton.new()
    rotation_button.text = "Auto rotation"
    rotation_button.button_pressed = auto_rotate
    rotation_button.toggled.connect(_set_rotation)
    controls.add_child(rotation_button)
    var reset := Button.new()
    reset.text = "Reset view"
    reset.pressed.connect(reset_view)
    controls.add_child(reset)
    destination_info = Label.new()
    destination_info.text = "Choose a place or try Surprise me. Offline map • Natural Earth • Simplified coastlines"
    destination_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    column.add_child(destination_info)

func _set_rotation(enabled: bool) -> void:
    auto_rotate = enabled
    rotation_button.set_pressed_no_signal(enabled)

func visit_destination(index: int) -> void:
    if index < 0 or index >= Catalog.PLACES.size():
        return
    selected_destination = index
    var place: Dictionary = Catalog.PLACES[index]
    _set_rotation(false)
    dragging = false
    marker.position = geographic_position(place.latitude, place.longitude) * 1.025
    marker.visible = true
    destination_picker.select(index + 1)
    destination_info.text = "%s — %s\n%s" % [place.name, place.region, place.fact]
    # Move to the marker's world longitude, including the globe's current rotation.
    _move_camera(deg_to_rad(place.longitude) + earth.rotation.y,
        deg_to_rad(place.latitude), 2.8)

func surprise_me() -> void:
    # Pick a different destination when one is already selected.
    var index := randi_range(0, Catalog.PLACES.size() - (2 if selected_destination >= 0 else 1))
    if index >= selected_destination and selected_destination >= 0:
        index += 1
    visit_destination(index)

func reset_view() -> void:
    selected_destination = -1
    marker.visible = false
    destination_picker.select(0)
    destination_info.text = "Choose a place or try Surprise me. Offline map • Natural Earth • Simplified coastlines"
    _set_rotation(true)
    _move_camera(0.0, 0.18, 3.6)

static func geographic_position(latitude: float, longitude: float) -> Vector3:
    var lat := deg_to_rad(latitude)
    var lon := deg_to_rad(longitude)
    return Vector3(sin(lon) * cos(lat), sin(lat), cos(lon) * cos(lat))

func _move_camera(new_yaw: float, new_pitch: float, new_distance: float) -> void:
    _stop_camera_animation()
    target_yaw = yaw + wrapf(new_yaw - yaw, -PI, PI)
    target_pitch = new_pitch
    target_distance = new_distance
    camera_tween = create_tween().set_parallel(true)
    camera_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    camera_tween.tween_property(self, "yaw", target_yaw, 1.4)
    camera_tween.tween_property(self, "pitch", target_pitch, 1.4)
    camera_tween.tween_property(self, "distance", target_distance, 1.4)

func _stop_camera_animation() -> void:
    if camera_tween and camera_tween.is_valid():
        camera_tween.kill()

func _process(delta: float) -> void:
    if auto_rotate and not dragging:
        earth.rotate_y(delta * 0.08)
    _update_camera()

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT:
            dragging = event.pressed
            if dragging:
                _stop_camera_animation()
        elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
            _stop_camera_animation()
            distance = max(MIN_DISTANCE, distance - 0.2)
            _update_camera()
        elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            _stop_camera_animation()
            distance = min(MAX_DISTANCE, distance + 0.2)
            _update_camera()
    elif event is InputEventMouseMotion and dragging:
        yaw -= event.relative.x * 0.005
        pitch = clamp(pitch + event.relative.y * 0.005, -1.35, 1.35)
        _update_camera()
    elif event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_ESCAPE:
            get_tree().quit()
        elif event.keycode == KEY_SPACE:
            _set_rotation(not auto_rotate)
        elif event.keycode == KEY_HOME:
            reset_view()

func _input(event: InputEvent) -> void:
    # A release over the interface must still end a drag begun on the globe.
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
        dragging = false

func _notification(what: int) -> void:
    if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
        dragging = false

func _update_camera() -> void:
    camera.position = Vector3(sin(yaw) * cos(pitch), sin(pitch), cos(yaw) * cos(pitch)) * distance
    camera.look_at(Vector3.ZERO, Vector3.UP)
