extends Node
## Deduplicates tiles and limits the entire wall to two simultaneous downloads.
signal changed
const CameraService = preload("res://scripts/camera_service.gd")
const MAX_REQUESTS := 2
var service_script: Script = CameraService
var services: Dictionary = {}
var active := false
var suspended := false
var minimized := false
var automatic := true
var visible_urls: Array = []
var limit_visibility := false

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
    for url in wanted:
        if url in services: continue
        var service = service_script.new()
        add_child(service)
        service.set_process(false)
        service.changed.connect(func(): changed.emit())
        service.automatic = automatic
        service.open(wanted[url], false)
        service.elapsed = service.refresh_interval
        services[url] = service
    active = true
    _apply_visibility()
    changed.emit()

func _process(delta: float) -> void:
    var now_minimized := DisplayServer.get_name() != "headless" and get_window().mode == Window.MODE_MINIMIZED
    if now_minimized != minimized:
        minimized = now_minimized
        _apply_visibility()
    if not active or suspended or minimized: return
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

func set_suspended(value: bool) -> void:
    suspended = value
    _apply_visibility()

func _apply_visibility() -> void:
    for url in services:
        var service = services[url]
        if not active or suspended or minimized or (limit_visibility and url not in visible_urls):
            service.stop()
        else:
            # Retain successful images while hidden; stagger overdue refreshes on return.
            if not service.active: service.elapsed = service.refresh_interval
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
