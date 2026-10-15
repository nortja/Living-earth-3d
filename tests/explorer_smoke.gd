extends SceneTree

var failures := 0
var checks := 0

func expect(condition: bool, description: String) -> void:
    checks += 1
    if not condition:
        failures += 1
        push_error(description)

func _initialize() -> void:
    call_deferred("run")

func run() -> void:
    var explorer = load("res://scenes/earth.tscn").instantiate()
    root.add_child(explorer)
    await process_frame
    explorer.set_process(false)
    expect(explorer.earth.material_override is ShaderMaterial, "Earth has its geographic material")
    expect(explorer.camera.current, "Explorer camera is active")
    var previous: float = explorer.earth.rotation.y
    explorer._process(1.0)
    expect(explorer.earth.rotation.y > previous, "Ambient mode rotates")
    explorer._set_rotation(false)
    previous = explorer.earth.rotation.y
    explorer._process(1.0)
    expect(is_equal_approx(explorer.earth.rotation.y, previous), "Pause stops rotation")
    # Geographic marker and camera must agree after globe rotation, including across the dateline.
    explorer.earth.rotation.y = 2.7
    for index in explorer.Catalog.PLACES.size():
        explorer.visit_destination(index)
        explorer.camera_tween.custom_step(2.0)
        explorer._update_camera()
        var place: Dictionary = explorer.Catalog.PLACES[index]
        expect(not explorer.auto_rotate, "Destination stays in view")
        expect(explorer.marker.visible, "Destination marker is visible")
        expect(explorer.destination_info.text.contains(place.name), "Destination fact matches selection")
        expect(explorer.camera.position.normalized().dot(explorer.marker.global_position.normalized()) > 0.999,
            "Camera faces selected geographic location")
    for iteration in 30:
        var selected: int = explorer.selected_destination
        explorer.surprise_me()
        expect(explorer.selected_destination != selected, "Surprise avoids immediate repeats")
    explorer.camera_tween.custom_step(2.0)
    var zoom := InputEventMouseButton.new()
    zoom.button_index = MOUSE_BUTTON_WHEEL_UP
    zoom.pressed = true
    for iteration in 100:
        explorer._unhandled_input(zoom)
    expect(is_equal_approx(explorer.distance, explorer.MIN_DISTANCE), "Zoom respects near limit")
    zoom.button_index = MOUSE_BUTTON_WHEEL_DOWN
    for iteration in 100:
        explorer._unhandled_input(zoom)
    expect(is_equal_approx(explorer.distance, explorer.MAX_DISTANCE), "Zoom respects far limit")
    zoom.button_index = MOUSE_BUTTON_LEFT
    explorer._unhandled_input(zoom)
    var motion := InputEventMouseMotion.new()
    motion.relative = Vector2(20, 10000)
    previous = explorer.yaw
    explorer._unhandled_input(motion)
    expect(explorer.yaw < previous, "Drag orbits")
    expect(explorer.pitch <= 1.35, "Drag clamps pitch")
    zoom.pressed = false
    explorer._input(zoom)
    expect(not explorer.dragging, "Release over UI ends drag")
    explorer.reset_view()
    explorer.camera_tween.custom_step(2.0)
    explorer._update_camera()
    expect(explorer.auto_rotate and not explorer.marker.visible, "Reset restores ambient mode")
    expect(explorer.selected_destination == -1 and explorer.destination_picker.selected == 0, "Reset clears selection")
    expect(is_equal_approx(explorer.distance, 3.6), "Reset restores zoom")
    explorer.visit_destination(-1)
    explorer.visit_destination(999)
    expect(explorer.selected_destination == -1, "Invalid catalog indices are ignored")
    print("Explorer checks: %d passed, %d failed" % [checks - failures, failures])
    quit(1 if failures else 0)
