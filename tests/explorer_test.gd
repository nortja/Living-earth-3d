extends SceneTree

var failures := 0
var checks := 0

func _initialize() -> void:
    call_deferred("run")

func verify(value: bool, message: String) -> void:
    checks += 1
    if not value:
        failures += 1
        push_error(message)

func run() -> void:
    var scene = load("res://scenes/earth.tscn").instantiate()
    root.add_child(scene)
    await process_frame
    verify(scene.destinations.size() == 6, "Offline catalog loaded")
    verify(not scene.discovery_enabled, "Discovery defaults off")
    for place in scene.destinations:
        verify(abs(place.latitude) <= 90 and abs(place.longitude) <= 180, "Valid coordinates")
    scene.visit(0)
    verify(scene.selected == 0 and scene.description.text.contains("Grand Canyon"), "Selection shows destination")
    scene.journey.custom_step(3.0)
    scene._update_camera()
    verify(abs(scene.pitch - deg_to_rad(36.1)) < 0.001, "Journey reaches latitude")
    verify(abs(scene.distance - 3.0) < 0.001, "Journey reaches zoom")
    verify(abs(wrapf(scene.yaw - scene.earth.rotation.y - PI - deg_to_rad(-112.1), -PI, PI)) < 0.001, "Journey longitude matches texture UV")
    scene._zoom(-0.2)
    scene.zoom_tween.custom_step(0.3)
    scene._update_camera()
    verify(abs(scene.distance - 2.8) < 0.001, "Wheel zoom animates to target")
    scene._zoom(-100.0)
    scene.zoom_tween.custom_step(0.3)
    verify(abs(scene.distance - 1.8) < 0.001, "Zoom clamps before surface")
    scene._zoom(100.0)
    scene.zoom_tween.custom_step(0.3)
    verify(abs(scene.distance - 10.0) < 0.001, "Zoom clamps outer limit")
    scene.toggle_favorite()
    verify("Grand Canyon" in scene.favorites, "Favorite saved")
    var saved := ConfigFile.new()
    verify(saved.load("user://preferences.cfg") == OK and "Grand Canyon" in saved.get_value("explorer", "favorites", []), "Favorite persists on disk")
    scene.visit(1)
    scene.visit_favorite()
    verify(scene.selected == 0, "Favorite revisited")
    scene.toggle_favorite()
    verify(scene.favorites.is_empty(), "Favorite removed")
    scene.surprise_me()
    verify(scene.selected != 0, "Surprise selects a different place")
    var previous: int = scene.selected
    scene.discovery_enabled = true
    scene._process(121.0)
    verify(scene.selected != previous, "Timed discovery advances")
    verify(scene.newer_version("v0.3.0"), "Newer minor release")
    verify(scene.newer_version("1.0.0"), "Newer major release")
    verify(not scene.newer_version("v0.2.0"), "Current release ignored")
    verify(not scene.newer_version("v0.0.9"), "Older release ignored")
    verify(not scene.newer_version("v1.0.0-beta"), "Prerelease ignored")
    scene._updates_received(0, 404, PackedStringArray(), PackedByteArray())
    verify(scene.update_status.text.contains("No published release"), "Missing release handled")
    scene._updates_received(0, 200, PackedStringArray(), '{"tag_name":"v0.3.0"}'.to_utf8_buffer())
    verify(scene.update_status.text.contains("available"), "New release shown")
    scene._updates_received(0, 200, PackedStringArray(), 'invalid'.to_utf8_buffer())
    verify(scene.update_status.text.contains("unavailable"), "Malformed response handled")
    scene._updates_received(HTTPRequest.RESULT_CANT_CONNECT, 0, PackedStringArray(), PackedByteArray())
    verify(scene.update_status.text.contains("Offline"), "Network failure remains offline-safe")
    print("Explorer: %d checks, %d failures" % [checks, failures])
    quit(1 if failures else 0)
