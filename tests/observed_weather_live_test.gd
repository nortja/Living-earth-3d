extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
    var app = load("res://scenes/earth.tscn").instantiate()
    app.play_intro = false
    app.preferences_path = "user://observed-live-%d.cfg" % Time.get_ticks_usec()
    root.add_child(app)
    var service = app.observed_weather
    if "--east" in OS.get_cmdline_user_args(): service.select_source(1)
    service.refresh()
    var deadline := Time.get_ticks_msec()+120000
    var maximum := 0
    while service.loading and Time.get_ticks_msec()<deadline:
        maximum = maxi(maximum,service.workers.size())
        await create_timer(0.1).timeout
    var ok: bool = service.enabled and service.texture!=null and service.observed_source==service.selected_source and maximum<=2 and service.workers.is_empty() and service.canvas==null
    print("Real regional infrared: %s; source=%s; scan=%s; concurrent=%d; %s" % [ok,service.observed_source,service.observed_time,maximum,service.status+" url="+service.tile_url(service.pending_source,service.pending_time,0)+" transport="+str(service.last_transport)+" "+service.last_transport_detail])
    if ok:
        var prefix := "/tmp/earth-0220-real-infrared"+("-east" if service.selected_source==1 else "")
        service.texture.get_image().save_png(prefix+".png")
        var file := FileAccess.open(prefix+".json",FileAccess.WRITE)
        file.store_string(JSON.stringify({"source":service.observed_source,"time":service.observed_time,"retrieved":service.retrieved,"maximum_concurrent":maximum,"size":[int(service.texture.get_width()),int(service.texture.get_height())]},"  "))
        file.close()
    service.cancel()
    DirAccess.remove_absolute(ProjectSettings.globalize_path(app.preferences_path))
    app.queue_free()
    await process_frame
    quit(0 if ok else 1)
