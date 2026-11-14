extends Node
## Deduplicates tiles and limits the entire wall to two simultaneous downloads.
signal changed
signal focus_changed(suspended: bool)
const CameraService = preload("res://scripts/camera_service.gd")
const MAX_REQUESTS := 2
const REFRESH_STAGGER_SECONDS := 2.0
const RESUME_GAP_SECONDS := 30.0
var service_script: Script = CameraService
var services: Dictionary = {}
var active := false
var suspended := false
var minimized := false
var focus_suspended := false
var automatic := true
var visible_urls: Array = []
var limit_visibility := false

func _ready() -> void:
    if DisplayServer.get_name() == "headless": return
    var window := get_window()
    if window == null: return
    if not window.focus_exited.is_connected(_on_window_focus_exited):
        window.focus_exited.connect(_on_window_focus_exited)
    if not window.focus_entered.is_connected(_on_window_focus_entered):
        window.focus_entered.connect(_on_window_focus_entered)
    focus_suspended = not DisplayServer.window_is_focused()

func _on_window_focus_exited() -> void:
    _set_focus_suspended(true)

func _on_window_focus_entered() -> void:
    _set_focus_suspended(false)

func _set_minimized(value: bool) -> void:
    if minimized == value: return
    minimized = value
    _apply_visibility()
    focus_changed.emit(not active or suspended or minimized or focus_suspended)

func _set_focus_suspended(value: bool) -> void:
    if focus_suspended == value: return
    focus_suspended = value
    _apply_visibility()
    focus_changed.emit(not active or suspended or minimized or focus_suspended)

func configure(venues: Array) -> void:
    var wanted: Dictionary = {}
    for venue in venues:
        var url: String = venue.get("image_url", "")
        if CameraService.valid_image_url(url): wanted[url] = venue
    for url in services.keys():
        if url not in wanted:
            services[url].stop()
            services[url].queue_free()
            services.erase(url)
    var added_urls: Array = []
    for url in wanted:
        if url in services: continue
        var service = service_script.new()
        service.manage_window_focus = false
        add_child(service)
        service.set_process(false)
        service.max_texture_edge = 1920
        service.changed.connect(func(): changed.emit())
        service.automatic = automatic
        service.open(wanted[url], false)
        services[url] = service
        added_urls.append(url)
    active = true
    _apply_visibility()
    # A new wall should not make every provider due in the same frame.
    # Apply the same deterministic spacing used when suspended services resume.
    for url in added_urls:
        var service = services[url]
        if service.active:
            service.elapsed = maxf(0.0, service.refresh_interval - _stagger_delay(url))
    changed.emit()

func _process(delta: float) -> void:
    var now_minimized := DisplayServer.get_name() != "headless" and get_window().mode == Window.MODE_MINIMIZED
    if now_minimized != minimized:
        _set_minimized(now_minimized)
    if not active or suspended or minimized or focus_suspended: return
    if delta >= RESUME_GAP_SECONDS:
        _recover_after_resume_gap(delta)
        return
    var in_flight := 0
    for service in services.values():
        if service.loading: in_flight += 1
    for service in services.values():
        if not service.active or service.loading: continue
        if automatic or service.get_meta("refresh_requested", false) or (service.image == null and service.consecutive_failures == 0):
            service.elapsed += delta
            if service.elapsed >= service.refresh_interval and in_flight < MAX_REQUESTS:
                service.refresh()
                if service.loading:
                    service.remove_meta("refresh_requested")
                    in_flight += 1

func _recover_after_resume_gap(delta: float) -> void:
    # A long frame gap commonly means Windows slept or the renderer was paused.
    # Do not catch up every missed interval in one burst when the app returns.
    var urls: Array = services.keys()
    urls.sort()
    for url in urls:
        var service = services[url]
        if not service.active: continue
        if service.loading and not service.view_suspended:
            # Cancel the pre-suspend request and invalidate its late callback,
            # while retaining the last validated image and its freshness context.
            service.set_view_suspended(true)
            service.set_view_suspended(false)
            service.elapsed = maxf(0.0, service.refresh_interval - _stagger_delay(url))
            continue
        var caught_up := minf(service.refresh_interval, service.elapsed + delta)
        if caught_up >= service.refresh_interval:
            # Preserve the existing retry interval, but stagger overdue sources.
            service.elapsed = maxf(0.0, service.refresh_interval - _stagger_delay(url))
        else:
            service.elapsed = caught_up


func set_suspended(value: bool) -> void:
    if suspended == value: return
    suspended = value
    _apply_visibility()
    focus_changed.emit(not active or suspended or minimized or focus_suspended)

func _stagger_delay(url: String) -> float:
    var eligible: Array = []
    for candidate in services.keys():
        if not limit_visibility or candidate in visible_urls:
            eligible.append(candidate)
    eligible.sort()
    return float(maxi(0, eligible.find(url))) * REFRESH_STAGGER_SECONDS

func _apply_visibility() -> void:
    for url in services:
        var service = services[url]
        if not active or suspended or minimized or focus_suspended or (limit_visibility and url not in visible_urls):
            service.stop()
        else:
            # Preserve validated images and stagger overdue downloads on return.
            if not service.active:
                service.elapsed = maxf(0.0, service.refresh_interval - _stagger_delay(url))
            service.active = true

func request_refresh() -> void:
    # Explicit refresh uses the same bounded scheduler; no immediate fan-out.
    for service in services.values():
        service.elapsed = service.refresh_interval
        service.set_meta("refresh_requested", true)

func close() -> void:
    active = false
    for service in services.values(): service.stop()


func set_visible_urls(urls: Array) -> void:
    if limit_visibility and visible_urls == urls: return
    visible_urls = urls.duplicate()
    limit_visibility = true
    _apply_visibility()


func set_automatic(enabled: bool) -> void:
    automatic = enabled
    for service in services.values(): service.set_automatic(enabled)
