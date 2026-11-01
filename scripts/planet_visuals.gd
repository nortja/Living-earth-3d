extends Node3D

var clouds: MeshInstance3D
var moon: MeshInstance3D
var stars: MultiMeshInstance3D
var cloud_material: ShaderMaterial
var star_material: StandardMaterial3D
var moon_material: ShaderMaterial
const Lunar = preload("res://scripts/lunar_data.gd")
var moon_sample_hour := -1
var app: Node3D
var clouds_enabled := true
var stars_enabled := true
var moon_enabled := false
var reveal := 1.0

func setup(planet: MeshInstance3D) -> void:
    app = get_parent()
    clouds = MeshInstance3D.new()
    var cloud_mesh := SphereMesh.new()
    cloud_mesh.radius = 1.012
    cloud_mesh.height = 2.024
    cloud_mesh.radial_segments = 96
    cloud_mesh.rings = 48
    clouds.mesh = cloud_mesh
    cloud_material = ShaderMaterial.new()
    cloud_material.shader = load("res://shaders/clouds.gdshader")
    cloud_material.set_shader_parameter("cloud_map", load("res://assets/earth/clouds.jpg"))
    clouds.material_override = cloud_material
    clouds.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    planet.add_child(clouds)

    moon = MeshInstance3D.new()
    var moon_mesh := QuadMesh.new()
    moon_mesh.size = Vector2(0.82,0.82)
    moon.mesh = moon_mesh
    moon_material = ShaderMaterial.new()
    moon_material.shader = load("res://shaders/lunar_backdrop.gdshader")
    moon_material.set_shader_parameter("lunar_map",load("res://assets/earth/moon_4k.jpg"))
    moon.material_override = moon_material
    moon.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    add_child(moon)
    moon.visible = false
    _build_stars()

func _build_stars() -> void:
    stars = MultiMeshInstance3D.new()
    var star_mesh := SphereMesh.new()
    star_mesh.radius = 0.045
    star_mesh.height = 0.09
    star_mesh.radial_segments = 4
    star_mesh.rings = 1
    star_material = StandardMaterial3D.new()
    star_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    star_material.vertex_color_use_as_albedo = true
    star_mesh.material = star_material
    var multi := MultiMesh.new()
    multi.transform_format = MultiMesh.TRANSFORM_3D
    multi.use_colors = true
    multi.mesh = star_mesh
    multi.instance_count = 1100
    var random := RandomNumberGenerator.new()
    random.seed = 4042026
    for index in range(multi.instance_count):
        var z := random.randf_range(-1.0, 1.0)
        var angle := random.randf() * TAU
        var radius := sqrt(1.0 - z * z)
        var direction := Vector3(radius * cos(angle), z, radius * sin(angle))
        var scale := random.randf_range(0.5, 1.8)
        multi.set_instance_transform(index, Transform3D(Basis.IDENTITY.scaled(Vector3.ONE * scale), direction * 80.0))
        var tint := Color(0.75, 0.84, 1.0) if index % 5 else Color(1.0, 0.87, 0.7)
        multi.set_instance_color(index, tint * random.randf_range(0.35, 0.9))
    stars.multimesh = multi
    stars.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    add_child(stars)

func advance(delta: float) -> void:
    if clouds_enabled:
        clouds.rotate_y(delta * 0.012)
    if moon_enabled:
        update_moon_pose()
        var hour := int(Time.get_unix_time_from_system()/3600.0)
        if hour!=moon_sample_hour: update_moon()

func apply_options(clouds_on: bool, stars_on: bool, moon_on: bool) -> void:
    clouds_enabled = clouds_on
    stars_enabled = stars_on
    moon_enabled = moon_on
    clouds.visible = clouds_on
    stars.visible = stars_on
    moon.visible = moon_on
    if moon_on:
        update_moon()
        update_moon_pose()

func set_reveal(value: float) -> void:
    reveal = value
    cloud_material.set_shader_parameter("visibility", value)
    star_material.albedo_color = Color(value, value, value)
    moon_material.set_shader_parameter("visibility",value)

func update_moon() -> void:
    moon_sample_hour = int(Time.get_unix_time_from_system()/3600.0)
    var row := Lunar.sample(Time.get_unix_time_from_system())
    moon.visible = moon_enabled and row.available
    if row.available:
        moon_material.set_shader_parameter("lunar_sun",row.sun)
        moon_material.set_shader_parameter("subearth_degrees",row.subearth)

static func composition_scale(camera_distance: float) -> float:
    # A perspective sphere's projected radius is proportional to 1/sqrt(d²-r²).
    # Lock the illustrative Moon's size AND separation to Earth's apparent disk.
    if not is_finite(camera_distance): camera_distance = 3.6
    var distance := clampf(camera_distance,1.8,10.0)
    return sqrt(3.6*3.6-1.0)/sqrt(distance*distance-1.0)

func update_moon_pose() -> void:
    if not moon_enabled or not is_instance_valid(app.camera): return
    var factor := composition_scale(app.camera.global_position.distance_to(app.earth.global_position))
    moon.global_transform = Transform3D(app.camera.global_basis.scaled(Vector3.ONE*factor),app.camera.global_transform*Vector3(-2.1*factor,1.1*factor,-5.0))
