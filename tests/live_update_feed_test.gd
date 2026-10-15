extends SceneTree
func _initialize() -> void:
    call_deferred("run")
func run() -> void:
    var scene = load("res://scenes/earth.tscn").instantiate()
    scene.play_intro = false
    scene.preferences_path = "user://live-feed-test-%d.cfg" % Time.get_ticks_usec()
    root.add_child(scene)
    var proxy := OS.get_environment("HTTPS_PROXY")
    if not proxy.is_empty():
        var host_port := proxy.get_slice("://", 1).get_slice("/", 0)
        if not "@" in host_port and host_port.count(":") == 1:
            scene.update_request.set_https_proxy(host_port.get_slice(":", 0), int(host_port.get_slice(":", 1)))
    create_timer(20).timeout.connect(func():
        push_error("Live update request timed out")
        quit(1))
    scene.check_updates()
    await scene.update_request.request_completed
    if not scene.valid_update_feed(scene.update_feed):
        push_error("Live update metadata not accepted: " + scene.update_status.text)
        quit(1)
        return
    print("PASS: real HTTPS %s update feed accepted; version %s; signed=%s" % [scene.BUILD_CHANNEL, scene.update_feed.version, scene.update_feed.installer_signed])
    quit(0)
