extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
    var service = load("res://scripts/camera_service.gd").new()
    root.add_child(service)
    create_timer(180).timeout.connect(func(): push_error("Camera provider request timed out"); quit(1))
    var cameras: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/cameras.json"))
    var expected: int = cameras.filter(func(venue):return venue.has("image_url")).size()
    var passed := 0
    var revalidated := false
    for venue in cameras:
        if not venue.has("image_url"): continue
        service.open(venue)
        while service.loading: await service.changed
        if service.image == null:
            push_error("Camera unavailable: " + venue.name + " · " + service.status)
            quit(1)
            return
        print("PASS: real camera image decoded for %s (%d x %d). Retrieval does not establish capture freshness." % [venue.name,service.image.get_width(),service.image.get_height()])
        if not revalidated and not service.etag.is_empty():
            await create_timer(2.1).timeout
            service.refresh()
            while service.loading: await service.changed
            if service.last_failed or service.image == null:
                push_error("Camera conditional revalidation unavailable: " + venue.name)
                quit(1)
                return
            print("PASS: real conditional request accepted for %s; %s" % [venue.name,service.status.get_slice("\n",0)])
            revalidated = true
        passed += 1
        service.stop()
    service.queue_free()
    await process_frame
    print("Camera live: %d/%d sources; conditional provider path exercised: %s" % [passed,expected,str(revalidated)])
    quit(0 if passed == expected and expected > 0 else 1)
