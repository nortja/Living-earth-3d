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
    scene.play_intro = false
    scene.preferences_path = "user://explorer-test-%d.cfg" % Time.get_ticks_usec()
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
    verify(saved.load(scene.preferences_path) == OK and "Grand Canyon" in saved.get_value("explorer", "favorites", []), "Favorite persists on disk")
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
    verify(scene.newer_version("v0.8.0"), "Newer minor release")
    verify(scene.newer_version("1.0.0"), "Newer major release")
    verify(not scene.newer_version("v0.7.0"), "Current release ignored")
    verify(not scene.newer_version("v0.0.9"), "Older release ignored")
    verify(not scene.newer_version("v1.0.0-beta"), "Prerelease ignored")
    scene._updates_received(0, 404, PackedStringArray(), PackedByteArray())
    verify(scene.update_status.text.contains("No published update"), "Missing release handled")
    var feed := {"version": "0.8.0", "channel": "preview", "installer_url": "https://github.com/nortja/Living-earth-3d/raw/refs/heads/downloads/windows-0.8.0/LivingEarth3D-Setup-0.8.0.exe", "sha256": "a".repeat(64), "installer_signed": false}
    scene._updates_received(0, 200, PackedStringArray(), JSON.stringify(feed).to_utf8_buffer())
    verify(scene.update_status.text.contains("available"), "New preview update shown")
    verify(scene.valid_update_feed(feed), "Official preview feed accepted")
    var invalid_feed := feed.duplicate()
    invalid_feed.installer_url = "https://example.com/untrusted.exe"
    verify(not scene.valid_update_feed(invalid_feed), "External installer host rejected")
    invalid_feed = feed.duplicate()
    invalid_feed.sha256 = "bad"
    verify(not scene.valid_update_feed(invalid_feed), "Invalid checksum rejected")
    invalid_feed = feed.duplicate()
    invalid_feed.version = "0.5.0/../../other"
    verify(not scene.valid_update_feed(invalid_feed), "Malformed version rejected")
    scene.install_update()
    verify(scene.update_status.text.contains("installed Windows app"), "Editor builds cannot run the installed updater")
    scene._updates_received(0, 200, PackedStringArray(), 'invalid'.to_utf8_buffer())
    verify(scene.update_status.text.contains("unavailable"), "Malformed response handled")
    scene._updates_received(HTTPRequest.RESULT_CANT_CONNECT, 0, PackedStringArray(), PackedByteArray())
    verify(scene.update_status.text.contains("Offline"), "Network failure remains offline-safe")
    scene.discovery_enabled = false
    scene.reset_view()
    scene.journey.custom_step(1.0)
    verify(abs(scene.distance - 3.6) < 0.001 and scene.selected == -1, "Reset restores full Earth")
    var click := InputEventMouseButton.new()
    click.button_index = MOUSE_BUTTON_LEFT
    click.pressed = true
    click.double_click = true
    scene._unhandled_input(click)
    scene.zoom_tween.custom_step(0.3)
    verify(scene.distance < 3.6, "Double-click zooms in")
    click.double_click = false
    scene._unhandled_input(click)
    var motion := InputEventMouseMotion.new()
    motion.relative = Vector2(20, 10)
    motion.velocity = Vector2(300, 100)
    scene._unhandled_input(motion)
    click.pressed = false
    scene._input(click)
    var before_yaw: float = scene.yaw
    var before_velocity: float = scene.angular_velocity.length()
    scene._process(0.1)
    verify(scene.yaw != before_yaw, "Orbit continues gently after release")
    verify(scene.angular_velocity.length() < before_velocity, "Inertia decays")
    scene.start_intro()
    verify(scene.intro_running and scene.intro_reveal == 0.0 and not scene.interface_layer.visible, "Intro starts dark without UI")
    scene.intro_tween.custom_step(1.4)
    verify(scene.intro_reveal > 0.1 and scene.intro_reveal < 0.9, "Intro reveals Earth gradually")
    scene.intro_tween.custom_step(2.0)
    verify(not scene.intro_running and scene.intro_reveal == 1.0 and scene.interface_layer.visible, "Intro finishes with interactive Earth")
    scene.start_intro()
    scene.finish_intro()
    verify(not scene.intro_running and scene.distance == 3.6, "Intro can be skipped")
    verify(scene.visuals.clouds_enabled and scene.visuals.stars_enabled and not scene.visuals.moon_enabled, "Visual defaults: clouds and stars on, Moon off")
    var cloud_before: float = scene.visuals.clouds.rotation.y
    scene.visuals.advance(1.0)
    verify(scene.visuals.clouds.rotation.y > cloud_before, "Cloud layer drifts independently")
    scene.set_visual_option("clouds", false)
    verify(not scene.visuals.clouds.visible and scene.earth_material.get_shader_parameter("cloud_strength") == 0.0, "Cloud toggle disables clouds and shade")
    cloud_before = scene.visuals.clouds.rotation.y
    scene.visuals.advance(1.0)
    verify(scene.visuals.clouds.rotation.y == cloud_before, "Disabled clouds stop processing")
    scene.set_visual_option("stars", false)
    verify(not scene.visuals.stars.visible, "Star backdrop can be disabled")
    scene.set_visual_option("moon", true)
    verify(scene.visuals.moon.visible, "Moon backdrop is optional")
    scene.set_quality("detailed")
    verify(scene.earth_material.get_shader_parameter("day_map").get_width() == 4096, "Detailed mode loads genuine 4K map")
    verify(scene.earth_material.get_shader_parameter("night_map").get_width() == 4096, "Detailed night lights are 4K")
    var restored = load("res://scenes/earth.tscn").instantiate()
    restored.play_intro = false
    restored.preferences_path = scene.preferences_path
    root.add_child(restored)
    verify(restored.visual_quality == "detailed" and not restored.visuals.clouds_enabled and not restored.visuals.stars_enabled and restored.visuals.moon_enabled, "Visual preferences survive restart")
    restored.queue_free()
    scene.set_quality("invalid")
    verify(scene.visual_quality == "balanced" and scene.earth_material.get_shader_parameter("day_map").get_width() == 2048, "Invalid quality falls back to Balanced")
    verify(scene.visuals.stars.multimesh.instance_count == 1100, "Stars use one instanced mesh")
    for button in scene.find_children("*", "CheckButton", true, false):
        if button.text.begins_with("Power saving"):
            button.button_pressed = true
            verify(Engine.max_fps == 30, "Power saving caps frame rate")
            button.button_pressed = false
            verify(Engine.max_fps == 60, "Normal mode restores frame cap")
    DirAccess.remove_absolute(ProjectSettings.globalize_path(scene.preferences_path))
    print("Explorer: %d checks, %d failures" % [checks, failures])
    quit(1 if failures else 0)
