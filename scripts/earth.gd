extends Node3D

var earth: MeshInstance3D
var camera: Camera3D
var info: Label
var yaw := 0.0
var pitch := 0.18
var distance := 3.6
var dragging := false

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
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(0.08, 0.32, 0.65)
    mat.metallic = 0.05
    mat.roughness = 0.8
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

    var layer := CanvasLayer.new()
    add_child(layer)
    info = Label.new()
    info.text = "LIVING EARTH 3D  |  First interactive prototype  •  Drag to orbit  •  Scroll to zoom  •  Esc to quit"
    info.position = Vector2(22, 20)
    layer.add_child(info)

func _process(delta: float) -> void:
    earth.rotate_y(delta * 0.08)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT:
            dragging = event.pressed
        elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
            distance = max(1.8, distance - 0.2)
            _update_camera()
        elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            distance = min(10.0, distance + 0.2)
            _update_camera()
    elif event is InputEventMouseMotion and dragging:
        yaw -= event.relative.x * 0.005
        pitch = clamp(pitch + event.relative.y * 0.005, -1.35, 1.35)
        _update_camera()
    elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
        get_tree().quit()

func _update_camera() -> void:
    camera.position = Vector3(sin(yaw) * cos(pitch), sin(pitch), cos(yaw) * cos(pitch)) * distance
    camera.look_at(Vector3.ZERO, Vector3.UP)
