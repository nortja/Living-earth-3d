extends SceneTree
const Photos = preload("res://scripts/discovery_photos.gd")
var failures := 0
func _initialize() -> void: call_deferred("run")
func verify(ok: bool, message: String) -> void:
    if not ok: failures += 1;push_error(message)
func run() -> void:
    var app = load("res://scenes/earth.tscn").instantiate()
    app.play_intro = false
    app.preferences_path = "user://photo-render-%d.cfg" % Time.get_ticks_usec()
    root.add_child(app)
    var ui = app.interface
    root.size = Vector2i(1920,1080)
    for place in app.exploration.catalog.places:
        app.fly_to_location(place)
        app.journey.custom_step(3.0);app._update_camera()
        for frame in range(14): await process_frame
        await RenderingServer.frame_post_draw
        var images: Array = ui.pages.Destination.find_children("*","TextureRect",true,false)
        verify(images.size() == 1 and images[0].texture != null,"Native photo arrival renders: "+place.id)
        if place.id in ["plitvice","tikal"]: root.get_texture().get_image().save_png("res://dist/discovery-photo-%s.png" % place.id)
    var place: Dictionary = app.exploration.catalog.places[0]
    var photo := Photos.lookup(place)
    for pixels in [Vector2i(800,600),Vector2i(1920,1080),Vector2i(3440,1440),Vector2i(3840,2160),Vector2i(5120,1440),Vector2i(5120,2880)]:
        root.size = pixels
        app.fly_to_location(place)
        app.journey.custom_step(3.0);app._update_camera()
        for frame in range(14): await process_frame
        await RenderingServer.frame_post_draw
        verify(Rect2(Vector2.ZERO,ui.size).encloses(Rect2(ui.panel.position,ui.panel.size)),"Photograph arrival fits native viewport")
        verify(ui.page_scroll.get_child(0).size.x <= ui.page_scroll.size.x,"Photograph card stays within scroll width")
        root.get_texture().get_image().save_png("res://dist/discovery-card-%dx%d.png" % [pixels.x,pixels.y])
        ui.photo_viewer.open(photo,place.name)
        for frame in range(14): await process_frame
        await RenderingServer.frame_post_draw
        verify(Rect2(Vector2.ZERO,ui.size).encloses(Rect2(ui.photo_viewer.frame.position,ui.photo_viewer.frame.size)),"Full photograph viewer fits viewport %s; frame %s / UI %s" % [pixels,Rect2(ui.photo_viewer.frame.position,ui.photo_viewer.frame.size),ui.size])
        verify(ui.photo_viewer.credit.get_global_rect().end.y <= ui.photo_viewer.frame.get_global_rect().end.y,"Photo attribution stays inside viewer")
        for action in [ui.photo_viewer.source_button,ui.photo_viewer.license_button]:
            var font: Font = action.get_theme_font("font")
            verify(action.size.x >= font.get_string_size(action.text,HORIZONTAL_ALIGNMENT_LEFT,-1,action.get_theme_font_size("font_size")).x,"Photograph credit links stay readable")
        root.get_texture().get_image().save_png("res://dist/discovery-viewer-%dx%d.png" % [pixels.x,pixels.y])
        ui.photo_viewer.close()
    root.size = Vector2i(800,600)
    ui.exploration_panel.select_section("History")
    ui.open_page("Explore")
    for year in [-2550,-450,850,1250]:
        ui.exploration_panel.history_slider.value = year
        for frame in range(12):await process_frame
        verify(ui.page_scroll.get_child(0).size.x <= ui.page_scroll.size.x,"Expanded history fits compact screen")
    DirAccess.remove_absolute(ProjectSettings.globalize_path(app.preferences_path))
    app.queue_free()
    await process_frame
    print("Native discovery photographs/history: %d failures" % failures)
    quit(1 if failures else 0)
