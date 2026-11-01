extends SceneTree
const Visuals = preload("res://scripts/planet_visuals.gd")
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("run")
func verify(ok: bool, message: String) -> void:
    checks+=1
    if not ok: failures+=1;push_error(message)
func run() -> void:
    var app = load("res://scenes/earth.tscn").instantiate()
    app.play_intro=false;app.preferences_path="user://moon-zoom-%d.cfg" % Time.get_ticks_usec()
    root.add_child(app)
    app.set_visual_option("moon",true)
    var baseline := -1.0
    var spacing := Vector2.ZERO
    for size in [Vector2i(800,600),Vector2i(1920,1080),Vector2i(2496,1664),Vector2i(3840,1080),Vector2i(5120,2880)]:
        root.size=size
        for distance in [1.8,2.2,3.0,3.6,5.0,7.5,10.0]:
            app.distance=distance;app.yaw=0.7;app.pitch=0.3;app._update_camera()
            for frame in range(2): await process_frame
            var cam = app.camera
            var n: Vector3=cam.position.normalized()
            var tangent: Vector3=cam.global_basis.x
            var radius := sqrt(1.0-1.0/(distance*distance))
            var limb_a: Vector2=cam.unproject_position(n/distance+tangent*radius)
            var limb_b: Vector2=cam.unproject_position(n/distance-tangent*radius)
            var earth_radius := limb_a.distance_to(limb_b)*0.5
            var moon = app.visuals.moon
            var edge_a: Vector2=cam.unproject_position(moon.global_transform*Vector3(0.41,0,0))
            var edge_b: Vector2=cam.unproject_position(moon.global_transform*Vector3(-0.41,0,0))
            var moon_radius := edge_a.distance_to(edge_b)*0.5
            var ratio := moon_radius/earth_radius
            var separation: Vector2=(cam.unproject_position(moon.global_position)-cam.unproject_position(Vector3.ZERO))/earth_radius
            if baseline<0: baseline=ratio;spacing=separation
            verify(absf(ratio-baseline)<0.00001,"Moon/Earth apparent size ratio stays constant at %s / %s" % [size,distance])
            verify(separation.distance_to(spacing)<0.0001,"Relative composition spacing tracks the same zoom")
    verify(is_equal_approx(Visuals.composition_scale(3.6),1.0),"Existing normal view retains its scale")
    verify(Visuals.composition_scale(1.8)>2 and Visuals.composition_scale(10)<0.4,"Both close-up and distant views genuinely change Moon size")
    verify(is_finite(Visuals.composition_scale(NAN)) and is_finite(Visuals.composition_scale(0)),"Invalid distances cannot produce invalid transforms")
    app.distance=3.6;app._update_camera();app.zoom_target=3.6;app._zoom(0.8)
    while app.zoom_tween.is_running(): await process_frame
    verify(absf(app.camera.position.length()-app.distance)<0.00001,"Final tween frame commits camera and Moon together")
    app.set_visual_option("moon",false);app.distance=7;app._update_camera()
    verify(not app.visuals.moon.visible,"Scaling preserves optional Moon-off")
    DirAccess.remove_absolute(ProjectSettings.globalize_path(app.preferences_path));app.queue_free();await process_frame
    print("Moon zoom: %d checks, %d failures" % [checks,failures])
    quit(1 if failures else 0)
