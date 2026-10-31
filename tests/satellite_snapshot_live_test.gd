extends SceneTree
## Optional real-network test, run manually; never part of startup or fixture CI.
func _initialize() -> void: call_deferred("run")
func run() -> void:
    var app = load("res://scenes/earth.tscn").instantiate()
    app.play_intro=false
    app.preferences_path="user://satellite-live-%d.cfg" % Time.get_ticks_usec()
    root.add_child(app)
    var service=app.satellite_snapshot
    for arg in OS.get_cmdline_user_args():
        if arg.begins_with("--days-ago="): service.select_days_ago(int(arg.trim_prefix("--days-ago=")))
    service.refresh()
    var deadline:=Time.get_ticks_msec()+40000
    while service.loading and Time.get_ticks_msec()<deadline:
        await create_timer(0.2).timeout
    var valid:bool=not service.loading and service.texture!=null and service.enabled and service.observed_date==service.pending_date
    print("Real NASA GIBS satellite request: %s" % ("PASS · "+service.observed_date+" · 2048×1024 dated mosaic" if valid else "FAIL · "+service.status))
    if valid:
        service.texture.get_image().save_png("res://dist/satellite-live-%s.png" % service.observed_date)
    service.cancel()
    DirAccess.remove_absolute(ProjectSettings.globalize_path(app.preferences_path))
    app.queue_free()
    await process_frame
    quit(0 if valid else 1)
