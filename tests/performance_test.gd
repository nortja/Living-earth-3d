extends SceneTree
const Report = preload("res://scripts/performance_report.gd")
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("run")
func verify(ok: bool, message: String) -> void:
    checks += 1
    if not ok: failures += 1; push_error(message)
func run() -> void:
    var app = load("res://scenes/earth.tscn").instantiate()
    app.play_intro = false
    app.preferences_path = "user://performance-test-%d.cfg" % Time.get_ticks_usec()
    root.add_child(app)
    var report = app.performance_report
    report.set_process(false)
    verify(Report.memory_value(0) == null,"Unavailable memory counter is not presented as zero usage")
    verify(Report.memory_value(1048576) == 1048576,"Available engine memory remains numeric")
    verify(Report.refresh_value(NAN) == null,"Unknown display refresh is explicit null")
    verify(Report.refresh_value(INF) == null and Report.refresh_value(0.0) == null and Report.refresh_value(-1.0) == null,"Invalid refresh cannot enter the JSON report")
    verify(Report.refresh_value(59.94) == 59.94,"Known fractional refresh is preserved")
    for refresh in [NAN, INF, -INF, 0.0, -1.0, 1.0]:
        verify(app.frame_limit_for(refresh,false,false,false) == 60, "Invalid monitor refresh retains a bounded desktop cap")
        verify(app.frame_limit_for(refresh,false,true,true) == 15, "Invalid monitor refresh preserves native preview budget")
    verify(app.frame_limit_for(59.97,false,false,false) == 60, "Fractional 60 Hz monitor avoids truncation to 59 FPS")
    verify(app.frame_limit_for(144.0,false,false,false) == 60, "Fast monitor retains desktop budget")
    verify(app.frame_limit_for(25.0,false,false,false) == 25, "Slower monitor limits desktop rendering")
    verify(app.frame_limit_for(144.0,true,false,false) == 30, "Power saving preserves 30 FPS cap")
    verify(app.frame_limit_for(144.0,false,true,false) == 30, "Native saver preserves 30 FPS cap")
    var stats := Report.frame_stats([10.0,10.0,20.0,40.0])
    verify(stats.mean_ms == 20.0 and stats.fps == 50.0, "FPS uses total active frame intervals")
    verify(stats.p95_ms == 40.0 and stats.max_ms == 40.0, "Tail frame intervals retained")
    verify(Report.frame_stats([]).is_empty(), "No frames is not fake zero FPS")
    report.start_recording()
    for index in range(800): report.sample_frame(0.01,1000000000+index)
    verify(report.recent.size() == 600, "Rolling frame buffer bounded")
    verify(report.recorded_frames == 800 and report.record_peak_memory == 1000000799, "Recording retains memory peak and total frames")
    report.sample_frame(0.06,1000100)
    verify(report.record_slow_frames == 1, "Slow frame threshold is explicit")
    var contexts:Array[Dictionary]=report.context_snapshot()
    verify(contexts.size()==1 and contexts[0].frames==801 and contexts[0].frames_over_50ms==1,"Unchanged configuration groups all active frames without losing slow frames")
    verify(contexts[0].context.quality==app.visual_quality and contexts[0].context.active_screen==null,"Context records actual quality and no invented headless screen")
    contexts[0].context.quality="tampered snapshot"
    verify(report.context_snapshot()[0].context.quality==app.visual_quality,"Exported context copy cannot alter retained measurements")
    report.sample_frame(INF,1)
    report.sample_frame(-1.0,1)
    verify(report.recorded_frames == 801, "Invalid frame intervals ignored")
    report.stop_recording()
    var total: int = report.recorded_frames
    report.sample_frame(0.01,1000000)
    verify(report.recorded_frames == total, "Stopped recording remains stable")
    report.start_recording()
    var initial_cap:=Engine.max_fps
    report.sample_frame(0.02,1)
    Engine.max_fps=30
    report.sample_frame(0.04,1)
    verify(report.record_contexts.size()==2 and report.record_contexts[0].context.frame_cap==initial_cap and report.record_contexts[1].context.frame_cap==30,"Frame cap change starts a separate measured context")
    verify(is_equal_approx(report.record_contexts[1].start_active_seconds,0.02) and is_equal_approx(report.context_snapshot()[1].mean_ms,40.0),"Context uses active elapsed time and its own frame intervals")
    for index in range(50):
        Engine.max_fps=31+index
        report.sample_frame(0.01,1)
    verify(report.record_contexts.size()==Report.MAX_CONTEXTS and report.context_limit_reached,"Repeated changes cannot grow the context report without bound")
    var exported:Array[Dictionary]=report.context_snapshot()
    verify(exported[-1].context.mixed and not exported[-1].context.has("frame_cap"),"Overflow explicitly groups mixed settings without assigning a false cap")
    var counted:=0
    var seconds:=0.0
    for segment in exported: counted+=segment.frames;seconds+=segment.active_seconds
    verify(counted==report.recorded_frames and is_equal_approx(seconds,report.recorded_seconds),"Bounded context totals retain every recorded frame and active second")
    Engine.max_fps=initial_cap
    report.start_recording()
    verify(report.record_contexts.is_empty() and not report.context_limit_reached,"New recording clears old contexts and overflow state")
    for index in range(301): report.sample_frame(1.0,2000000)
    verify(not report.recording and report.recorded_frames == 300, "Five active minute recording stops automatically")
    report.start_recording()
    app.screensaver_mode = true
    report._process(1.0)
    verify(report.recorded_frames == 0, "Screensaver mode pauses recording")
    app.screensaver_mode = false
    report._process(3.0)
    verify(report.recorded_frames == 0, "Sleep gaps excluded")
    report._process(0.1)
    verify(report.recorded_frames == 1, "Recording resumes on active rendering")
    report.stop_recording()
    report.report_path = "user://display-report-test-%d.json" % Time.get_ticks_usec()
    verify(report.export_report() == OK, "Local report exports")
    var data = JSON.parse_string(FileAccess.get_file_as_string(report.report_path))
    verify(data.schema == 1 and data.version == app.VERSION and data.product == "LivingEarth3D", "Report identifies version and schema")
    verify(not data.display.available, "Headless run does not invent a GPU/display")
    verify(report.monitor_snapshot().is_empty(), "Headless run does not invent attached monitors")
    verify(not data.has("paths") and not data.has("bookmarks") and not data.has("username") and not data.has("camera_images"), "Report excludes personal content")
    verify(data.limits.contains("excludes driver/GPU"), "Memory measurement limits included")
    app.interface.open_page("Settings")
    app.interface.performance_record.pressed.emit()
    verify(report.recording, "Settings starts recording")
    app.interface.performance_record.pressed.emit()
    verify(not report.recording, "Settings stops recording")
    for path in [report.report_path, app.preferences_path]: DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
    app.queue_free()
    await process_frame
    print("Local performance: %d checks, %d failures" % [checks,failures])
    quit(1 if failures else 0)
