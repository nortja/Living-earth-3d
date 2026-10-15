extends Node3D

var clouds: MeshInstance3D
var moon: MeshInstance3D
var stars: MultiMeshInstance3D
var cloud_material: ShaderMaterial
var star_material: StandardMaterial3D
var moon_material: StandardMaterial3D
var clouds_enabled := true
var stars_enabled := true
var moon_enabled := false
var reveal := 1.0

func setup(planet: MeshInstance3D) -> void:
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
    var moon_mesh := SphereMesh.new()
    moon_mesh.radius = 0.273
    moon_mesh.height = 0.546
    moon_mesh.radial_segments = 48
    moon_mesh.rings = 24
    moon.mesh = moon_mesh
    moon.position = Vector3(-3.0, 1.3, 3.0)
    moon_material = StandardMaterial3D.new()
    moon_material.albedo_texture = load("res://assets/earth/moon.jpg")
    moon_material.roughness = 1.0
    moon.material_override = moon_material
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
        moon.rotate_y(delta * 0.01)

func apply_options(clouds_on: bool, stars_on: bool, moon_on: bool) -> void:
    clouds_enabled = clouds_on
    stars_enabled = stars_on
    moon_enabled = moon_on
    clouds.visible = clouds_on
    stars.visible = stars_on
    moon.visible = moon_on

func set_reveal(value: float) -> void:
    reveal = value
    cloud_material.set_shader_parameter("visibility", value)
    star_material.albedo_color = Color(value, value, value)
    moon_material.albedo_color = Color(value, value, value)
