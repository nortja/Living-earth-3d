extends SceneTree
var failures := 0
func _initialize() -> void:
    call_deferred("run")
func run() -> void:
    var scene = load("res://scenes/earth.tscn").instantiate()
    scene.play_intro = false
    root.add_child(scene)
    for quality in ["balanced", "detailed"]:
        scene.set_quality(quality, false)
        for size in [Vector2i(800, 600), Vector2i(1920, 1080), Vector2i(3440, 1440), Vector2i(3840, 2160)]:
            root.size = size
            for frame in range(5):
                await process_frame
            await RenderingServer.frame_post_draw
            var image := root.get_texture().get_image()
            if image.is_empty() or image.get_size() != size or image.get_pixel(image.get_width() / 2, image.get_height() / 2).get_luminance() < 0.01:
                failures += 1
                push_error("Globe did not render at %s" % size)
            print("Rendered %s %s → viewport %s" % [quality, size, image.get_size()])
    print("Render tests: 2 quality modes × 4 sizes, %d failures" % failures)
    quit(1 if failures else 0)
