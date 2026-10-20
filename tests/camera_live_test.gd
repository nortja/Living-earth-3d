extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
    var service = load("res://scripts/camera_service.gd").new()
    root.add_child(service)
    create_timer(65).timeout.connect(func(): push_error("Camera provider request timed out"); quit(1))
    var cameras: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/cameras.json"))
    var passed := 0
    for venue in cameras:
        if not venue.has("image_url"): continue
        service.open(venue)
        while service.loading: await service.changed
        if service.image == null:
            push_error("Camera unavailable: " + venue.name + " · " + service.status)
            quit(1)
            return
        print("PASS: real camera image decoded for %s (%d x %d). Retrieval does not establish capture freshness." % [venue.name,service.image.get_width(),service.image.get_height()])
        passed += 1
        service.stop()
    service.queue_free()
    await process_frame
    quit(0 if passed == 4 else 1)
