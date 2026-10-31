extends SceneTree
const Snapshot = preload("res://scripts/satellite_snapshot.gd")
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("run")
func verify(ok: bool, message: String) -> void:
    checks += 1
    if not ok: failures += 1; push_error(message)
func run() -> void:
    var app = load("res://scenes/earth.tscn").instantiate()
    app.play_intro = false
    app.preferences_path = "user://satellite-test-%d.cfg" % Time.get_ticks_usec()
    root.add_child(app)
    var service = app.satellite_snapshot
    verify(service != null and not service.enabled and service.request == null, "Startup does not request or enable satellite imagery")
    verify(Snapshot.previous_utc_day(Time.get_unix_time_from_datetime_string("2024-03-01T00:00:00")) == "2024-02-29", "UTC date handles leap day")
    verify(Snapshot.previous_utc_day(Time.get_unix_time_from_datetime_string("2026-01-01T23:59:59")) == "2025-12-31", "UTC date handles year boundary")
    var boundary:=Time.get_unix_time_from_datetime_string("2024-03-01T23:59:59")
    verify(Snapshot.recent_utc_date(boundary,7)=="2024-02-23","Seven-day selector crosses leap-month boundary in UTC")
    verify(Snapshot.recent_utc_date(boundary,0).is_empty() and Snapshot.recent_utc_date(boundary,8).is_empty(),"Date range excludes today future and older arbitrary dates")
    verify(service.selected_days_ago==1 and app.interface.satellite_date_picker.item_count==7,"Date selector defaults to yesterday with seven explicit days")
    app.interface.satellite_date_picker.item_selected.emit(6)
    verify(service.selected_days_ago==7 and not service.loading and service.request==null and service.texture==null,"Selecting an older day stays local and does not fabricate an image")
    service.select_days_ago(0);service.select_days_ago(8)
    verify(service.selected_days_ago==7,"Invalid selections cannot escape recent-date bounds")
    service.loading=true
    service.select_days_ago(2)
    verify(service.selected_days_ago==7,"Selection is stable during an in-flight request")
    service.loading=false
    service.select_days_ago(1)
    var url := Snapshot.request_url("2026-10-30")
    verify(url.begins_with("https://gibs.earthdata.nasa.gov/") and url.contains("SRS=EPSG:4326") and url.contains("BBOX=-180,-90,180,90") and url.ends_with("TIME=2026-10-30"), "Fixed geographic request preserves longitude/latitude ordering and exact date")
    verify(not Snapshot.valid_png_size(PackedByteArray()) and not Snapshot.valid_png_size("<ServiceException>Unavailable</ServiceException>".to_utf8_buffer()), "Empty/XML errors are rejected before image decode")
    var fixture := Image.create(2048,1024,false,Image.FORMAT_RGBA8)
    fixture.fill(Color("457a98"))
    var bytes := fixture.save_png_to_buffer()
    verify(Snapshot.valid_png_size(bytes), "Expected bounded PNG dimensions accepted")
    var oversized := bytes.duplicate()
    oversized[16]=127
    verify(not Snapshot.valid_png_size(oversized), "Oversized PNG header rejected before decompression")
    service.pending_date = "2026-10-30"
    service._received(0,200,PackedStringArray(),bytes,service.generation)
    verify(service.enabled and service.observed_date == "2026-10-30" and service.texture.get_width() == 2048, "Validated dated mosaic appears")
    verify(app.earth_material.get_shader_parameter("satellite_view") and not app.visuals.clouds.visible, "Observed surface hides artistic cloud layer")
    verify(app.info.text.contains("2026-10-30") and service.status.contains("not live") and service.status.contains("Black areas"), "Date and observation limits remain visible")
    app.set_visual_option("clouds",true)
    verify(not app.visuals.clouds.visible, "Artistic cloud preference cannot cover the observed mosaic")
    var retained: Texture2D = service.texture
    service.select_days_ago(7)
    verify(service.observed_date=="2026-10-30" and app.info.text.contains("2026-10-30") and service.texture==retained and service.request==null,"Choosing another day preserves displayed observation identity until successful Load")
    service.pending_date = "2026-10-31"
    service._received(0,200,PackedStringArray(),"<ServiceException/>".to_utf8_buffer(),service.generation)
    verify(service.texture == retained and service.observed_date == "2026-10-30" and service.status.contains("retained"), "Provider error retains old date and texture")
    fixture.fill(Color.BLACK)
    service._received(0,200,PackedStringArray(),fixture.save_png_to_buffer(),service.generation)
    verify(service.texture == retained and service.observed_date == "2026-10-30", "Blank mosaic is unavailable rather than a false success")
    var token: int = service.generation
    service.cancel()
    service._received(0,200,PackedStringArray(),bytes,token)
    verify(service.texture == retained and service.observed_date == "2026-10-30", "Canceled late response cannot change the mosaic")
    service.set_enabled(false)
    verify(not app.earth_material.get_shader_parameter("satellite_view") and app.visuals.clouds.visible and not app.info.text.contains("NASA"), "Offline return restores selected artistic clouds and header")
    service.set_enabled(true)
    app.preview_screensaver()
    verify(service.suspended and service.request == null and not app.earth_material.get_shader_parameter("satellite_view"), "Screensaver preview excludes the satellite surface and cancels requests")
    app.stop_screensaver_preview()
    verify(not service.suspended and app.earth_material.get_shader_parameter("satellite_view") and not app.visuals.clouds.visible, "Preview return restores the dated snapshot without fetching")
    service.last_attempt = Time.get_ticks_msec()
    service.refresh()
    verify(not service.loading and service.request == null and service.status.contains("one minute"), "Manual cooldown does not start another request")
    service.loading = true
    service.set_enabled(false)
    verify(not service.loading and not service.enabled, "Turning off during a request cancels the pending selection")
    for pixels in [Vector2i(800,600),Vector2i(3840,1080),Vector2i(5120,2880)]:
        root.size=pixels
        app.interface.open_page("Satellite view")
        for frame in range(12): await process_frame
        verify(Rect2(Vector2.ZERO,app.interface.size).encloses(Rect2(app.interface.panel.position,app.interface.panel.size)), "Satellite controls fit %s" % pixels)
        verify(app.interface.page_scroll.get_global_rect().encloses(app.interface.satellite_load.get_global_rect()), "Initial satellite load action is visible without scrolling at %s" % pixels)
        verify(app.interface.page_scroll.get_global_rect().encloses(app.interface.satellite_date_picker.get_global_rect()),"Date selector is visible without scrolling at %s" % pixels)
        verify(app.interface.satellite_offline.size.x>=112 and app.interface.page_scroll.get_global_rect().encloses(app.interface.satellite_offline.get_global_rect()),"Offline return has readable width and remains visible beside Load at %s" % pixels)
        if app.interface.panel.visible: app.interface.close_panel()
    DirAccess.remove_absolute(ProjectSettings.globalize_path(app.preferences_path))
    app.queue_free()
    await process_frame
    print("Satellite snapshot: %d checks, %d failures" % [checks,failures])
    quit(1 if failures else 0)
