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
    manager._process(0.0)
    var running := 0
    for service in manager.services.values():
        if service.loading: running += 1
    verify(running == 2, "Initial wall downloads capped at two")
    var first = manager.services.values()[0]
    var image := Image.create(16, 9, false, Image.FORMAT_RGB8)
    image.fill(Color("68afc4"))
    var bytes := image.save_jpg_to_buffer()
    first._received(HTTPRequest.RESULT_SUCCESS, 200, PackedStringArray(), bytes, first.generation)
    manager._process(0.0)
    running = 0
    for service in manager.services.values():
        if service.loading: running += 1
    verify(running == 2, "Queue fills one freed download slot")
    for index in range(9): wall.slots[index] = wall.sources[0].image_url
    wall.slot_count = 9
    wall._rebuild()
    verify(manager.services.size() == 1, "Nine duplicate tiles share one source")
    verify(wall.tiles.size() == 9 and wall.tiles[8].image.texture != null, "Shared image reaches every duplicate tile")
    manager.automatic = false
    manager.request_refresh()
    manager._process(0.0)
    verify(first.loading, "Manual refresh works with automatic polling disabled")
    var token: int = first.generation
    manager.set_suspended(true)
    first._received(HTTPRequest.RESULT_SUCCESS, 200, PackedStringArray(), bytes, token)
    verify(not first.active and not first.loading, "Focus suspension cancels and rejects late downloads")
    manager.set_suspended(false)
    verify(first.active, "Closing focus resumes the wall")
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
    app.queue_free()
    await process_frame
    print("Camera wall: %d checks, %d failures" % [checks,failures])
    quit(1 if failures else 0)
