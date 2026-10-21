extends SceneTree
## Real-time native rendering soak; explicit duration, no accelerated frame simulation.
var app: Node3D
var started := 0
var duration := 600
var failures := 0
var baseline_memory := 0
var baseline_nodes := 0
var peak_memory := 0
var samples: Array = []
func _initialize() -> void: call_deferred("run")
func verify(ok: bool, message: String) -> void:
    if not ok: failures += 1; push_error(message)
func run() -> void:
    for arg in OS.get_cmdline_user_args():
        if arg.begins_with("--soak-seconds="): duration = clampi(int(arg.get_slice("=",1)),60,10800)
    root.size = Vector2i(640,360)
    app = load("res://scenes/earth.tscn").instantiate()
    app.play_intro = false
    app.preferences_path = "user://saver-soak-%d.cfg" % Time.get_ticks_usec()
    root.add_child(app)
    verify(app.native_saver and app.screensaver_mode, "Soak must use actual native saver renderer mode")
    verify(DisplayServer.get_name() != "headless", "Soak requires actual graphics rendering")
    started = Time.get_ticks_msec()
    while true:
        await create_timer(30.0).timeout
        var elapsed := (Time.get_ticks_msec()-started)/1000.0
        var style := int(elapsed/300.0)%6
        if app.saver_style != style:
            app.saver_style = style
            app.apply_saver_style()
        var memory := int(Performance.get_monitor(Performance.MEMORY_STATIC))
        var nodes := int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
        peak_memory = maxi(peak_memory,memory)
        if baseline_memory == 0 and elapsed >= 120:
            baseline_memory = memory
            baseline_nodes = nodes
        verify(not app.interface_layer.visible and app.ambient.suspended, "Saver remains quiet without controls")
        verify(not app.camera_service.active and not app.interface.wall.manager.active, "Saver does not activate cameras")
        verify(not app.performance_report.is_processing(), "Native saver does not collect desktop performance samples")
        verify(Engine.max_fps == 15, "Tiny native preview preserves its frame budget")
        for request in app.find_children("*","HTTPRequest",true,false):
            verify(request.get_http_client_status() == HTTPClient.STATUS_DISCONNECTED, "Saver has no active public-data request")
        if baseline_memory > 0:
            verify(memory-baseline_memory < 67108864, "Engine tracked memory growth stays below 64 MiB after warmup")
            verify(nodes-baseline_nodes < 64, "Node count stays bounded across saver style changes")
        var sample := {"active_seconds":elapsed,"style":style,"fps":Engine.get_frames_per_second(),"engine_memory_bytes":memory,"nodes":nodes,"failures":failures}
        samples.append(sample)
        print("SAVER_SOAK ",JSON.stringify(sample))
        if samples.size() == 1 or int(elapsed)%600 < 31 or elapsed >= duration:
            await RenderingServer.frame_post_draw
            root.get_texture().get_image().save_png("res://dist/saver-soak-latest.png")
        if failures > 0 or elapsed >= duration: break
    var file := FileAccess.open("res://dist/saver-soak.json",FileAccess.WRITE)
    file.store_string(JSON.stringify({"version":app.VERSION,"duration_seconds":(Time.get_ticks_msec()-started)/1000.0,"peak_engine_memory_bytes":peak_memory,"baseline_engine_memory_bytes":baseline_memory,"samples":samples,"failures":failures,"limits":"Native Linux software rendering; not physical Windows multi-monitor/DPI/sleep validation."},"  ")+"\n")
    file.close()
    DirAccess.remove_absolute(ProjectSettings.globalize_path(app.preferences_path))
    app.queue_free()
    await process_frame
    print("Screensaver real-time soak: %d failures" % failures)
    quit(1 if failures else 0)
