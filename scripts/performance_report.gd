extends Node
## Local, bounded display measurements. No network, paths, bookmarks or camera images.
signal changed
const WINDOW_SAMPLES := 600
const MAX_RECORD_SECONDS := 300.0
var app: Node3D
var recent: Array[float] = []
var recording := false
var recorded_seconds := 0.0
var recorded_frames := 0
var record_sum_ms := 0.0
var record_peak_ms := 0.0
var record_slow_frames := 0
var record_start_memory := 0
var record_peak_memory := 0
var record_end_memory := 0
var snapshot: Dictionary = {}
var tick := 0.0
var report_path := "user://display-report.json"

func setup(owner_app: Node3D) -> void:
    app = owner_app
    set_process(not app.native_saver)

func _process(delta: float) -> void:
    if app.screensaver_mode: return
    var visible_settings: bool = app.interface != null and app.interface.active_page in ["Settings", "Display report"] and app.interface.panel.visible
    if not recording and not visible_settings:
        if not recent.is_empty(): recent.clear()
        return
    if (DisplayServer.get_name() != "headless" and get_window().mode == Window.MODE_MINIMIZED) or delta <= 0.0 or delta > 2.0:
        # Exclude time asleep/minimized; this measures active rendering, not wall time.
        return
    sample_frame(delta, int(Performance.get_monitor(Performance.MEMORY_STATIC)))
    tick += delta
    if tick >= 1.0:
        tick = 0.0
        snapshot = build_snapshot()
        changed.emit()

func sample_frame(delta: float, tracked_bytes: int) -> void:
    if delta <= 0.0 or not is_finite(delta): return
    var ms := delta * 1000.0
    recent.append(ms)
    if recent.size() > WINDOW_SAMPLES: recent.pop_front()
    if recording:
        recorded_seconds += delta
        recorded_frames += 1
        record_sum_ms += ms
        record_peak_ms = maxf(record_peak_ms, ms)
        if ms > 50.0: record_slow_frames += 1
        record_end_memory = tracked_bytes
        record_peak_memory = maxi(record_peak_memory, tracked_bytes)
        if recorded_seconds >= MAX_RECORD_SECONDS:
            recording = false
            snapshot = build_snapshot()
            changed.emit()

func start_recording() -> void:
    if app.screensaver_mode: return
    recording = true
    recorded_seconds = 0.0
    recorded_frames = 0
    record_sum_ms = 0.0
    record_peak_ms = 0.0
    record_slow_frames = 0
    record_start_memory = int(Performance.get_monitor(Performance.MEMORY_STATIC))
    record_peak_memory = record_start_memory
    record_end_memory = record_start_memory
    recent.clear()
    snapshot = build_snapshot()
    changed.emit()

func stop_recording() -> void:
    recording = false
    snapshot = build_snapshot()
    changed.emit()

static func frame_stats(values: Array[float]) -> Dictionary:
    if values.is_empty(): return {}
    var sorted := values.duplicate()
    sorted.sort()
    var sum := 0.0
    for value in values: sum += value
    return {"frames":values.size(),"fps":1000.0 * values.size() / sum,"mean_ms":sum / values.size(),"p95_ms":sorted[clampi(ceili(sorted.size() * 0.95) - 1,0,sorted.size()-1)],"max_ms":sorted[-1]}

static func memory_value(bytes: int) -> Variant:
    return bytes if bytes > 0 else null

static func refresh_value(hz: float) -> Variant:
    return hz if is_finite(hz) and hz > 0.0 else null

func build_snapshot() -> Dictionary:
    var tracked_bytes := int(Performance.get_monitor(Performance.MEMORY_STATIC))
    var display: Dictionary = {"available":false}
    if DisplayServer.get_name() != "headless":
        var screen := app.get_window().current_screen
        var pixels := DisplayServer.screen_get_size(screen)
        var viewport := app.get_viewport().get_visible_rect().size
        display = {"available":true,"monitor_pixels":[pixels.x,pixels.y],"viewport_pixels":[int(viewport.x),int(viewport.y)],"dpi":DisplayServer.screen_get_dpi(screen),"refresh_hz":refresh_value(DisplayServer.screen_get_refresh_rate(screen)),"gpu":RenderingServer.get_video_adapter_name(),"renderer":RenderingServer.get_current_rendering_method(),"window_mode":app.get_window().mode}
    return {"schema":1,"product":"LivingEarth3D","version":app.VERSION,"retrieved_utc":Time.get_datetime_string_from_system(true)+"Z","os":OS.get_name(),"engine":Engine.get_version_info().string,"display":display,"quality":app.visual_quality,"frame_cap":Engine.max_fps,"ui_scale":app.interface.display_scale if app.interface else 1.0,"recent_frames":frame_stats(recent),"memory_counter_available":tracked_bytes > 0,"engine_tracked_memory_bytes":memory_value(tracked_bytes),"recording":{"active":recording,"active_seconds":recorded_seconds,"frames":recorded_frames,"mean_ms":record_sum_ms / recorded_frames if recorded_frames > 0 else 0.0,"max_ms":record_peak_ms,"frames_over_50ms":record_slow_frames,"start_engine_memory_bytes":memory_value(record_start_memory),"end_engine_memory_bytes":memory_value(record_end_memory),"peak_engine_memory_bytes":memory_value(record_peak_memory)},"limits":"Frame intervals include the FPS cap and scheduling. Engine tracked memory is unavailable in release builds; when available it excludes driver/GPU/process allocations. Unavailable memory values are null. Minimized or sleep intervals over two seconds are excluded. No hardware pass/fail score."}

func export_report() -> Error:
    snapshot = build_snapshot()
    var file := FileAccess.open(report_path,FileAccess.WRITE)
    if file == null: return FileAccess.get_open_error()
    file.store_string(JSON.stringify(snapshot,"  ")+"\n")
    file.close()
    return OK
