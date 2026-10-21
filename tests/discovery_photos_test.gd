extends SceneTree
const Photos = preload("res://scripts/discovery_photos.gd")
const Catalog = preload("res://scripts/discovery_catalog.gd")
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("run")
func verify(ok: bool, message: String) -> void:
    checks += 1
    if not ok: failures += 1;push_error(message)
func run() -> void:
    var catalog = Catalog.new()
    var photos: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/discovery_photos.json"))
    verify(photos.size() == 12, "All twelve discoveries have licensed photographs")
    var paths: Array = []
    for place in catalog.places:
        var photo: Dictionary = Photos.lookup(place)
        verify(not photo.is_empty(), "Discovery resolves its bundled photo: "+place.id)
        if photo.is_empty(): continue
        verify(photo.image not in paths, "Distinct discovery image assets")
        paths.append(photo.image)
        var bytes := FileAccess.get_file_as_bytes(photo.image)
        var hashing := HashingContext.new()
        hashing.start(HashingContext.HASH_SHA256);hashing.update(bytes)
        verify(hashing.finish().hex_encode() == photo.sha256, "Bundled photo matches provenance hash")
        var image := Image.new()
        verify(image.load_jpg_from_buffer(bytes) == OK and image.get_width() == photo.width and image.get_height() == photo.height and maxi(image.get_width(),image.get_height()) <= 1280, "Bundled photograph decodes at bounded dimensions")
        verify(photo.license in ["CC BY 4.0","CC BY 3.0","CC BY 2.0","CC BY 2.5","CC0","Public domain"] and not str(photo.author).is_empty() and str(photo.source).begins_with("https://commons.wikimedia.org/wiki/File:"), "Photo credit and source are explicit")
        verify(str(photo.license_url).begins_with("https://") and photo.modifications.contains("Resized"), "License link and modification disclosure preserved")
        var saved := preload("res://scripts/exploration_data.gd").sanitize(place)
        verify(Photos.lookup(saved).get("image") == photo.image, "Saved discovery restores photograph without persisting an arbitrary path")
    verify(Photos.lookup({"id":"unknown","image":"https://example.com/untrusted.jpg"}).is_empty(), "Unknown place cannot inject an image")
    verify(Photos.lookup({"id":"plitvice","latitude":0.0,"longitude":0.0}).is_empty(), "A copied catalog ID cannot mislabel another location’s photo")
    verify(catalog.history.size() == 10, "Ten sourced historical contexts")
    for site in catalog.history:
        verify(site.start_year <= site.end_year and site.source.begins_with("https://") and site.note.length() > 60, "History interval has source and context")
        verify(site in catalog.historical_sites(site.start_year) and site in catalog.historical_sites(site.end_year), "Historical interval includes its boundaries")
        verify(site not in catalog.historical_sites(site.start_year-1) and site not in catalog.historical_sites(site.end_year+1), "Historical marker is absent outside its teaching interval")
    var app = load("res://scenes/earth.tscn").instantiate()
    app.play_intro = false
    app.preferences_path = "user://photo-test-%d.cfg" % Time.get_ticks_usec()
    root.add_child(app)
    var ui = app.interface
    var photo: Dictionary = Photos.lookup(catalog.places[0])
    verify(ui.photo_viewer.open(photo,catalog.places[0].name), "Photograph opens in dedicated viewer")
    verify(ui.photo_viewer.visible and ui.photo_viewer.credit.text.contains(photo.author) and ui.photo_viewer.credit.text.contains("not live"), "Viewer credits actual creator and distinguishes photograph from live imagery")
    verify(not ui.photo_viewer.open({"image":"res://project.godot"},"Invalid"), "Viewer rejects non-photo paths")
    ui.photo_viewer.close()
    verify(not ui.photo_viewer.visible and ui.photo_viewer.image.texture == null, "Close releases full photo reference")
    app.fly_to_location(catalog.places[0])
    var images: Array = ui.pages.Destination.find_children("*","TextureRect",true,false)
    verify(images.size() == 1 and images[0].texture != null, "Discovery arrival automatically shows its photograph")
    ui.photo_viewer.open(photo,catalog.places[0].name)
    var escape := InputEventKey.new();escape.keycode=KEY_ESCAPE;escape.pressed=true
    app._unhandled_input(escape)
    verify(not ui.photo_viewer.visible and ui.panel.visible, "Escape returns from photo to destination context")
    ui.photo_viewer.open(photo,catalog.places[0].name)
    app.preview_screensaver()
    verify(not ui.photo_viewer.visible and not app.interface_layer.visible, "Screensaver preview clears photograph overlay")
    verify(not app.camera_service.active and app.observations.weather_request == null, "Static photos do not start data requests")
    app.stop_screensaver_preview()
    DirAccess.remove_absolute(ProjectSettings.globalize_path(app.preferences_path))
    app.queue_free()
    await process_frame
    print("Discovery photographs/history: %d checks, %d failures" % [checks,failures])
    quit(1 if failures else 0)
