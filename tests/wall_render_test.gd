extends SceneTree
var failures := 0
func _initialize() -> void: call_deferred("run")
func verify(ok: bool, message: String) -> void:
    if not ok:
        failures += 1
        push_error(message)
func run() -> void:
    var app = load("res://scenes/earth.tscn").instantiate()
    app.play_intro = false
    app.preferences_path = "user://wall-render-%d.cfg" % Time.get_ticks_usec()
    root.add_child(app)
    var wall = app.interface.wall
    wall.set_process(false)
    wall.manager.set_process(false)
    wall.show()
    var fixture := Image.create(320,180,false,Image.FORMAT_RGB8)
    fixture.fill(Color("376f83"))
    var texture := ImageTexture.create_from_image(fixture)
    DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://dist"))
    for pixels in [Vector2i(800,600),Vector2i(1920,1080),Vector2i(5120,1440),Vector2i(5120,2880)]:
        root.size = pixels
        app.interface.set_ui_scale(2.0 if pixels.y > 1080 else 1.0)
        for count in [1,4,9]:
            wall.slot_count = count
            wall._rebuild(false)
            for tile in wall.tiles:
                tile.image.texture = texture
                tile.detail.text = "TEST FIXTURE · periodic image layout"
            for frame in range(14): await process_frame
            await RenderingServer.frame_post_draw
            verify(Rect2(Vector2.ZERO,app.interface.size).encloses(Rect2(wall.frame.position,wall.frame.size)), "Native wall fits %s/%d" % [pixels,count])
            verify(wall.grid.size.x < wall.frame.size.x, "Native grid fits width")
            if count == 1: verify(wall.tiles[0].tile.size.y >= wall.scroll.size.y - 4.0, "Single camera uses available wall height")
            for row in wall.frame.get_child(0).get_children():
                for control in row.get_children():
                    if control is Button and not control is OptionButton:
                        var font: Font = control.get_theme_font("font")
                        verify(control.size.x >= font.get_string_size(control.text,HORIZONTAL_ALIGNMENT_LEFT,-1,control.get_theme_font_size("font_size")).x,"Wall action readable: " + control.text)
            var capture := root.get_texture().get_image()
            verify(capture.get_size() == pixels, "Exact native framebuffer size")
            verify(capture.save_png("res://dist/wall-%dx%d-%d.png" % [pixels.x,pixels.y,count]) == OK,"Screenshot saved")
            print("Rendered wall %s with %d tiles (test fixture)" % [pixels,count])
    wall.close()
    app.set_utc_sunlight(true)
    app.interface.open_page("Live Earth")
    for frame in range(14): await process_frame
    await RenderingServer.frame_post_draw
    verify(root.get_texture().get_image().save_png("res://dist/sunlight.png") == OK,"Sunlight screenshot saved")
    DirAccess.remove_absolute(ProjectSettings.globalize_path(app.preferences_path))
    app.queue_free()
    await process_frame
    print("Wall native renders: %d failures" % failures)
    quit(1 if failures else 0)
