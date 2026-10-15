extends SceneTree
var failures := 0
func _initialize() -> void:
    call_deferred("run")
func run() -> void:
    var scene = load("res://scenes/earth.tscn").instantiate()
    scene.preferences_path = "user://intro-render-test.cfg"
    root.add_child(scene)
    root.size = Vector2i(1280, 720)
    scene.intro_tween.pause()
    var brightness: Array[float] = []
    for stage in range(3):
        if stage > 0:
            scene.intro_tween.custom_step(1.45)
        scene._update_camera()
        for frame in range(3):
            await process_frame
        await RenderingServer.frame_post_draw
        var image := root.get_texture().get_image()
        brightness.append(image.get_pixel(image.get_width() / 2, image.get_height() / 2).get_luminance())
        image.save_png("/tmp/living-earth-intro-%d.png" % stage)
    if not (brightness[0] < 0.01 and brightness[1] > brightness[0] and brightness[2] > brightness[1]):
        failures += 1
        push_error("Intro did not reveal Earth smoothly: %s" % [brightness])
    if scene.intro_running or not scene.interface_layer.visible:
        failures += 1
        push_error("Intro did not hand control to Explorer")
    print("Intro render: dark → reveal → Explorer %s; %d failures" % [brightness, failures])
    quit(1 if failures else 0)
