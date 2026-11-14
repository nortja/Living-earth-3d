extends SceneTree
const WallService = preload("res://scripts/camera_wall_service.gd")
class FakeCamera extends "res://scripts/camera_service.gd":
    var starts := 0
    func refresh() -> void:
        if not active or loading: return
        starts += 1
        elapsed = 0.0
        loading = true
        generation += 1
        status = "Fixture loading"
        changed.emit()
var failures := 0
var checks := 0
func verify(ok: bool, message: String) -> void:
    checks += 1
    if not ok:
        failures += 1
        push_error(message)
func _initialize() -> void: call_deferred("run")
func run() -> void:
    var app = load("res://scenes/earth.tscn").instantiate()
    app.play_intro = false
    app.preferences_path = "user://wall-test-%d.cfg" % Time.get_ticks_usec()
    root.add_child(app)
    var wall = app.interface.wall
    wall.set_process(false)
    var manager = wall.manager
    manager.service_script = FakeCamera
    manager.set_process(false)
    verify(not wall.visible and manager.services.is_empty(), "Wall never fetches on startup")
    wall.open()
    verify(manager.services.size() == 4, "Four distinct sources requested")
    var ordered_urls: Array = manager.services.keys()
    ordered_urls.sort()
    var due_first = manager.services[ordered_urls[0]]
    var due_second = manager.services[ordered_urls[1]]
    var due_third = manager.services[ordered_urls[2]]
    manager._process(0.0)
    verify(due_first.starts == 1 and due_second.starts == 0, "Only the first distinct source starts immediately")
    manager._process(1.9)
    verify(due_second.starts == 0, "Second source remains staggered before two seconds")
    manager._process(0.2)
    verify(due_second.starts == 1, "Second source starts after the two-second stagger")
    var image := Image.create(16, 9, false, Image.FORMAT_RGB8)
    image.fill(Color("68afc4"))
    var bytes := image.save_jpg_to_buffer()
    due_first._received(HTTPRequest.RESULT_SUCCESS, 200, PackedStringArray(), bytes, due_first.generation)
    manager._process(2.1)
    verify(due_third.starts == 1, "Third source becomes eligible after its stagger and a download slot frees")
    var running := 0
    for service in manager.services.values():
        if service.loading: running += 1
    verify(running == 2, "Staggered scheduler still respects the two-request cap")

    # Simulate a sleep-sized frame gap while two downloads are in flight.
    due_second.refresh_interval = 120.0 # Preserve an existing exponential retry interval.
    var old_second_token: int = due_second.generation
    var old_second_image: Texture2D = due_second.image
    manager._process(3600.0)
    verify(not due_second.loading and due_second.generation > old_second_token, "Resume gap cancels in-flight requests and invalidates callbacks")
    verify(due_second.refresh_interval == 120.0, "Resume gap preserves the existing retry/backoff interval")
    verify(absf(due_second.elapsed - 118.0) < 0.01, "Overdue second source is re-armed at its two-second stagger")
    due_second._received(HTTPRequest.RESULT_SUCCESS, 200, PackedStringArray(), bytes, old_second_token)
    verify(due_second.image == old_second_image and not due_second.status.contains("Refreshing"), "Late pre-sleep response cannot replace retained data or leave a false loading state")
    manager._process(0.0)
    verify(due_first.starts == 2 and due_second.starts == 1, "Only the first overdue source restarts immediately")
    manager._process(1.9)
    verify(due_second.starts == 1, "Second overdue source stays staggered after resume")
    manager._process(0.2)
    verify(due_second.starts == 2, "Second overdue source resumes after the two-second gap")

    manager.set_suspended(true)
    manager.set_suspended(false)
    var first_remaining: float = float(due_first.refresh_interval) - float(due_first.elapsed)
    var second_remaining: float = float(due_second.refresh_interval) - float(due_second.elapsed)
    verify(absf(first_remaining) < 0.01 and absf(second_remaining - 2.0) < 0.01, "Focus return restores deterministic two-second spacing")
    var first = manager.services[wall.sources[0].image_url]
    first._received(HTTPRequest.RESULT_SUCCESS, 200, PackedStringArray(), bytes, first.generation)
    for index in range(9): wall.slots[index] = wall.sources[0].image_url
    wall.slot_count = 9
    wall._rebuild()
    verify(manager.services.size() == 1, "Nine duplicate tiles share one source")
    verify(wall.tiles.size() == 9 and wall.tiles[8].image.texture != null, "Shared image reaches every duplicate tile")

    manager.automatic = false
    manager.request_refresh()
    manager._process(0.0)
    var pending = null
    for service in manager.services.values():
        if service.loading:
            pending = service
            break
    verify(pending != null, "Manual refresh works with automatic polling disabled")
    if pending != null:
        var token: int = pending.generation
        manager.set_suspended(true)
        pending._received(HTTPRequest.RESULT_SUCCESS, 200, PackedStringArray(), bytes, token)
        verify(not pending.active and not pending.loading, "Focus suspension cancels and rejects late downloads")
    manager.set_suspended(false)
    verify(first.active, "Closing focus resumes the wall")
    var focus_retained: Texture2D = first.image
    var wall_focus_token: int = first.generation
    first.loading = true
    manager._set_focus_suspended(true)
    verify(manager.focus_suspended and not first.active and not first.loading, "Window focus loss stops all Camera Wall requests")
    verify(wall.note.text.contains("paused") and first.image == focus_retained, "Background Camera Wall status is explicit and keeps validated tiles")
    first._received(HTTPRequest.RESULT_SUCCESS, 200, PackedStringArray(), bytes, wall_focus_token)
    verify(first.image == focus_retained, "Late Camera Wall response after focus loss is ignored")
    manager._set_focus_suspended(false)
    verify(first.active and wall.note.text.contains("resumed"), "Window focus return resumes the bounded Camera Wall scheduler")
    manager._set_minimized(true)
    manager._set_focus_suspended(true)
    manager._set_focus_suspended(false)
    verify(manager.minimized and not first.active and wall.note.text.contains("paused"), "Focus return while minimized keeps Camera Wall requests paused and status honest")
    manager._set_minimized(false)
    verify(first.active and wall.note.text.contains("resumed"), "Unminimizing after focus return resumes Camera Wall downloads")
    manager.set_visible_urls([])
    verify(not first.active, "Offscreen tiles suspend downloads")
    manager.set_visible_urls([wall.sources[0].image_url])
    verify(first.active, "Visible tiles resume")
    wall.collection_name.text = "Quiet places"
    wall.save_collection()
    verify(wall.collections.has("Quiet places"), "Named collection saved")
    wall.slot_count = 1
    wall.slots[0] = ""
    wall._load_collection(1)
    verify(wall.slot_count == 9 and wall.slots[0] == wall.sources[0].image_url, "Collection restores layout and sources")
    for pixels in [Vector2i(800,600),Vector2i(1920,1080),Vector2i(5120,1440),Vector2i(5120,2880)]:
        root.size = pixels
        app.interface.set_ui_scale(2.0)
        for count in wall.LAYOUTS:
            wall.slot_count = count
            wall._rebuild()
            for frame in range(10): await process_frame
            var bounds := Rect2(Vector2.ZERO,app.interface.size)
            verify(bounds.encloses(Rect2(wall.frame.position,wall.frame.size)), "Wall fits %s with %d tiles" % [pixels,count])
            verify(wall.grid.size.x <= wall.frame.size.x, "Wall grid fits width at %s with %d tiles" % [pixels,count])
    app.preview_screensaver()
    verify(not wall.visible and not manager.active and not first.active, "Screensaver closes all wall networking")
    app.stop_screensaver_preview()
    wall.close()
    verify(not wall.visible and not manager.active, "Close stops all feeds")
    DirAccess.remove_absolute(ProjectSettings.globalize_path(app.preferences_path))
    wall.fill_different_cameras()
    verify(wall.slots.filter(func(url):return not str(url).is_empty()).size() == 8, "Fill chooses eight distinct image cameras")
    verify(wall.slots[8] == "", "Ninth tile stays empty when only eight sources exist")
    verify(not manager.active, "Filling a closed wall does not start hidden downloads")
    wall.open()
    verify(wall.manager.services.size() == 8, "Expanded wall keeps one service per distinct source")
    wall.close()
    DirAccess.remove_absolute(ProjectSettings.globalize_path(app.preferences_path))
    app.queue_free()
    await process_frame
    print("Camera wall: %d checks, %d failures" % [checks,failures])
    quit(1 if failures else 0)
