extends Control
## Physical-pixel layout: the 3D viewport keeps the display's native resolution.
var exploration_panel: RefCounted
var arrival_place: Dictionary = {}
var arrival_has_photo := false
var arrival_status: Label
var arrival_save: Button
var weather_model_badge: Button
var weather_layer_refresh: Button
var weather_layer_cancel: Button
var weather_layer_status: Label
var weather_layer_toggle: CheckButton
var weather_layer_picker: OptionButton
var weather_layer_legend: Label
var performance_values: Label
var performance_record: Button
var performance_export_status: Label
var exploration_poll := 0.0
var app: Node3D
var page_scroll: ScrollContainer
var panel: PanelContainer
var pages: Dictionary = {}
var navigation: Dictionary = {}
var active_page := ""
var dock: PanelContainer
var header: HBoxContainer
var page_title: Label
var atlas: Array = []
var cameras: Array = []
var search_results: VBoxContainer
var search_status: Label
var quake_results: VBoxContainer
var quake_status: Label
var monitor_status: Label
var command_card: PanelContainer
var dashboard := false
var display_scale := 1.0
var preferred_scale := 0.0
var scale_status: Label
var scale_picker: OptionButton
const SCALE_OPTIONS := [0.0, 1.0, 1.25, 1.5, 1.75, 2.0]
var dock_row: HBoxContainer
var layout_frames := 8
var page_animation: Tween
var photo_viewer: ColorRect
var wall: ColorRect
var sunlight_toggle: CheckButton
var solar_status: Label
var camera_rows: VBoxContainer
var camera_query: LineEdit
var camera_images_only := false
var camera_status: Label
var camera_overlay: ColorRect
var camera_viewer: PanelContainer
var camera_image: TextureRect
var camera_title: Label
var camera_detail: Label
var camera_source: Label
var camera_close: Button
var camera_refresh: Button
var camera_source_button: Button
const NAV := ["Explore", "Live Earth", "Cameras", "Command Center", "Screensavers"]

func setup(owner_app: Node3D) -> void:
    app = owner_app
    var saved_scale = app.preferences.get_value("interface", "ui_scale", 0.0)
    if (saved_scale is float or saved_scale is int) and float(saved_scale) in SCALE_OPTIONS:
        preferred_scale = float(saved_scale)
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    theme = Theme.new()
    theme.default_font_size = 14
    var font := SystemFont.new()
    font.multichannel_signed_distance_field = true
    font.font_names = PackedStringArray(["Segoe UI", "Noto Sans", "DejaVu Sans"])
    theme.default_font = font
    theme.set_color("font_color", "Label", Color("d7e4f2"))
    for type in ["Button", "OptionButton", "LineEdit"]:
        theme.set_stylebox("normal", type, surface(Color("142334"), 8, 10))
        theme.set_stylebox("hover", type, surface(Color("234156"), 8, 10))
        theme.set_stylebox("pressed", type, surface(Color("245a70"), 8, 10))
        var focus := surface(Color(0, 0, 0, 0), 8, 10)
        focus.border_color = Color("75daed")
        focus.set_border_width_all(2)
        theme.set_stylebox("focus", type, focus)
    theme.set_constant("separation", "VBoxContainer", 10)
    theme.set_constant("separation", "HBoxContainer", 8)
    atlas = JSON.parse_string(FileAccess.get_file_as_string("res://data/atlas.json"))
    cameras = JSON.parse_string(FileAccess.get_file_as_string("res://data/cameras.json"))
    header = HBoxContainer.new()
    add_child(header)
    var icon := TextureRect.new()
    icon.texture = load("res://assets/icon.png")
    icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    icon.custom_minimum_size = Vector2(40, 40)
    header.add_child(icon)
    var identity := VBoxContainer.new()
    identity.custom_minimum_size.x = 230
    header.add_child(identity)
    var brand := label(identity, "LIVING EARTH", 18)
    brand.autowrap_mode = TextServer.AUTOWRAP_OFF
    brand.add_theme_color_override("font_color", Color("eef8ff"))
    app.info = label(identity, "Drag to orbit · Scroll to zoom", 12)
    app.info.autowrap_mode = TextServer.AUTOWRAP_OFF
    icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    identity.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    var spacer := Control.new()
    spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    header.add_child(spacer)
    button(header, "Full Earth", func(): close_panel(); app.reset_view())
    button(header, "Full screen", func(): app.toggle_fullscreen())
    button(header, "Settings", func(): open_page("Settings"))
    dock = PanelContainer.new()
    dock.add_theme_stylebox_override("panel", surface(Color(0.025, 0.05, 0.08, 0.94), 16, 8))
    add_child(dock)
    dock_row = HBoxContainer.new()
    dock.add_child(dock_row)
    for title in NAV:
        navigation[title] = button(dock_row, title, func(): open_page(title))
        navigation[title].toggle_mode = true
        navigation[title].clip_text = false
    panel = PanelContainer.new()
    panel.add_theme_stylebox_override("panel", surface(Color(0.025, 0.045, 0.075, 0.97), 16, 18))
    add_child(panel)
    var box := VBoxContainer.new()
    panel.add_child(box)
    var title_row := HBoxContainer.new()
    box.add_child(title_row)
    page_title = label(title_row, "Explore", 21)
    page_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    button(title_row, "Close", close_panel).clip_text = false
    var scroll := ScrollContainer.new()
    page_scroll = scroll
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    box.add_child(scroll)
    var page_stack := VBoxContainer.new()
    page_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.add_child(page_stack)
    for title in NAV + ["Settings", "Destination", "Display report", "Weather globe"]:
        var page := VBoxContainer.new()
        page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        page_stack.add_child(page)
        page.visible = false
        pages[title] = page
    _explore(pages.Explore)
    _live(pages["Live Earth"])
    _cameras(pages.Cameras)
    _command(pages["Command Center"])
    _savers(pages.Screensavers)
    _settings(pages.Settings)
    command_card = PanelContainer.new()
    command_card.add_theme_stylebox_override("panel", surface(Color(0.025, 0.045, 0.075, 0.95), 16, 18))
    add_child(command_card)
    var card_box := VBoxContainer.new()
    command_card.add_child(card_box)
    label(card_box, "MISSION OVERVIEW", 16)
    label(card_box, "Earth imagery · offline\nCloud layer · artistic drift\nCamera pages · external providers\nEarthquakes · refresh on request\nMoon & stars · artistic backdrop")
    button(card_box, "Return to full Earth", func(): close_panel(); app.reset_view())
    wall = preload("res://scripts/camera_wall.gd").new()
    add_child(wall)
    wall.setup(app, cameras)
    _build_camera_viewer()
    photo_viewer = preload("res://scripts/photo_viewer.gd").new()
    add_child(photo_viewer)
    photo_viewer.setup(app)
    panel.hide()
    command_card.hide()
    app.services.earthquakes_changed.connect(_refresh_quake_list)
    app.services.search_changed.connect(_worldwide_results)
    get_viewport().size_changed.connect(refresh_layout)
    relayout()

func _process(_delta: float) -> void:
    if weather_model_badge:
        weather_model_badge.visible = app.weather_layer != null and app.weather_layer.marker_root.visible and not panel.visible and not wall.visible and not camera_overlay.visible and not photo_viewer.visible
    if is_instance_valid(arrival_status) and arrival_status.text.begins_with("Travelling") and app.journey and not app.journey.is_running():
        arrival_status.text = "Journey paused · " + str(arrival_place.get("name", "Earth"))
    exploration_poll += _delta
    if exploration_poll >= 60.0 and exploration_panel:
        exploration_poll = 0.0
        exploration_panel.refresh_daily()
        exploration_panel._weather_changed()
    if layout_frames > 0:
        layout_frames -= 1
        relayout()

func refresh_layout() -> void:
    if not command_card: return
    layout_frames = 8
    relayout()

func surface(color: Color, radius: int, margin: int) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = color
    style.set_corner_radius_all(radius)
    style.set_content_margin_all(margin)
    return style

func label(parent: Node, text: String, font_size := 14) -> Label:
    var item := Label.new()
    item.text = text
    item.add_theme_font_size_override("font_size", font_size)
    item.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    item.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    parent.add_child(item)
    return item

func button(parent: Node, text: String, action: Callable) -> Button:
    var item := Button.new()
    item.text = text
    item.clip_text = parent != header
    item.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    item.tooltip_text = text
    item.custom_minimum_size.y = 36
    item.pressed.connect(action)
    parent.add_child(item)
    return item

func open_page(title: String) -> void:
    if title in ["Live Earth", "Weather globe"] and app.weather_layer: _weather_layer_changed()
    if active_page == title and panel.visible:
        close_panel()
        return
    active_page = title
    page_scroll.scroll_vertical = 0
    page_title.text = title
    for key in pages:
        pages[key].visible = key == title
    for key in navigation:
        navigation[key].set_pressed_no_signal(key == title)
    panel.show()
    if page_animation:
        page_animation.kill()
    panel.modulate.a = 0.0
    page_animation = create_tween()
    page_animation.tween_property(panel, "modulate:a", 1.0, 0.18)
    refresh_layout()

func close_panel() -> void:
    active_page = ""
    panel.hide()
    command_card.hide()
    for item in navigation.values():
        item.set_pressed_no_signal(false)

func relayout() -> void:
    var pixels := get_viewport_rect().size
    # Keep controls compact on ultrawide displays; scale for high pixel density.
    var requested := preferred_scale if preferred_scale > 0.0 else clampf(pixels.y / 1080.0, 1.0, 1.75)
    # Preserve at least an 800 x 600 logical workspace when a window shrinks.
    # Only the interface scales; the 3D framebuffer remains native resolution.
    var fitting_scale := maxf(1.0, minf(pixels.x / 800.0, pixels.y / 600.0))
    display_scale = minf(requested, fitting_scale)
    scale = Vector2.ONE * display_scale
    size = pixels / display_scale
    if scale_status:
        scale_status.text = "Interface size: %d%%" % roundi(display_scale * 100.0)
        if display_scale < requested - 0.001:
            scale_status.text += " · reduced to fit this window"
        elif preferred_scale == 0.0:
            scale_status.text += " · automatic"
    header.position = Vector2(24, 18)
    header.size = Vector2(size.x - 48, 48)
    dock.size = dock.get_combined_minimum_size()
    dock.position = Vector2((size.x - dock.size.x) / 2, size.y - dock.size.y - 22)
    # Side panels on wide displays; a compact bottom sheet on narrower displays
    # keeps the center of the planet unobstructed.
    var side_layout := size.x >= 1200 and pixels.x / pixels.y >= 1.6
    var width := clampf(size.x * 0.23, 340, 400)
    if side_layout:
        panel.position = Vector2(size.x - width - 24, 88)
        panel.size = Vector2(width, maxf(250, size.y - 88 - dock.size.y - 44))
    else:
        var sheet_height := minf(360,size.y-190) if (active_page == "Destination" and arrival_has_photo) or active_page == "Weather globe" else 190.0
        panel.position = Vector2(24, size.y - sheet_height - 92)
        panel.size = Vector2(size.x - 48, sheet_height)
    command_card.position = Vector2(24, 104)
    command_card.size = Vector2(280, 230)
    if weather_model_badge: weather_model_badge.position = Vector2(24,size.y-136)
    if wall: wall.relayout()
    if photo_viewer: photo_viewer.relayout()
    if camera_overlay:
        camera_overlay.size = size
        camera_viewer.size = Vector2(minf(960, size.x - 48), minf(680, size.y - 100))
        camera_viewer.position = (size - camera_viewer.size) / 2.0
    command_card.visible = dashboard and active_page == "Command Center" and side_layout and size.x >= 1600

func set_ui_scale(value: float) -> void:
    preferred_scale = value if value in SCALE_OPTIONS else 0.0
    app.preferences.set_value("interface", "ui_scale", preferred_scale)
    app._save_preferences()
    if scale_picker:
        scale_picker.select(SCALE_OPTIONS.find(preferred_scale))
    refresh_layout()

func _explore(box: VBoxContainer) -> void:
    exploration_panel = preload("res://scripts/exploration_panel.gd").new()
    exploration_panel.setup(self)
    exploration_panel.build_explore(box)

func _explore_search(box: VBoxContainer) -> void:
    label(box, "A world worth exploring", 18)
    var query := LineEdit.new()
    query.placeholder_text = "Place or latitude, longitude"
    query.custom_minimum_size.y = 38
    box.add_child(query)
    query.text_submitted.connect(_search_offline)
    button(box, "Search offline atlas", func(): _search_offline(query.text))
    button(box, "Search worldwide · online", func(): app.services.search_worldwide(query.text))
    search_status = label(box, app.services.search_status, 12)
    search_results = VBoxContainer.new()
    box.add_child(search_results)
    app.place_picker = OptionButton.new()
    app.place_picker.add_item("Curated destinations…")
    for place in app.destinations:
        app.place_picker.add_item(place.name)
    app.place_picker.item_selected.connect(func(index: int):
        if index > 0: app.visit(index - 1))
    box.add_child(app.place_picker)
    button(box, "Surprise me", app.surprise_me)
    var row := HFlowContainer.new()
    box.add_child(row)
    app.favorite_button = button(row, "Save favorite", app.toggle_favorite)
    app.favorite_button.clip_text = false
    button(row, "Visit favorite", app.visit_favorite).clip_text = false
    var timed := CheckButton.new()
    timed.text = "Timed journeys in Explorer"
    timed.button_pressed = app.discovery_enabled
    timed.toggled.connect(func(enabled: bool):
        app.discovery_enabled = enabled
        app.elapsed = 0.0
        app.preferences.set_value("explorer", "discovery", enabled)
        app._save_preferences())
    box.add_child(timed)
    var interval := OptionButton.new()
    for seconds in [60, 120, 300]: interval.add_item("Every %d minutes" % (seconds / 60), seconds)
    interval.select({60: 0, 120: 1, 300: 2}.get(int(app.discovery_interval), 1))
    interval.item_selected.connect(func(index: int):
        app.discovery_interval = interval.get_item_id(index)
        app.elapsed = 0.0
        app.preferences.set_value("explorer", "interval", app.discovery_interval)
        app._save_preferences())
    box.add_child(interval)
    app.description = label(box, "Offline discovery · Choose a destination or search. Globe-scale views; no street imagery.")

func _clear(parent: Node) -> void:
    for child in parent.get_children():
        parent.remove_child(child)
        child.queue_free()

func _show_search(places: Array) -> void:
    _clear(search_results)
    for place in places:
        var entry := button(search_results, str(place.name).left(42), func(): app.fly_to_location(place))
        entry.tooltip_text = place.name

func _search_offline(query: String) -> void:
    query = query.strip_edges()
    var matches: Array = []
    var coordinates := query.split(",")
    if coordinates.size() == 2 and coordinates[0].strip_edges().is_valid_float() and coordinates[1].strip_edges().is_valid_float():
        var lat := float(coordinates[0])
        var lon := float(coordinates[1])
        if app.services.valid_coordinates(lat, lon):
            matches.append({"name": "%.4f°, %.4f°" % [lat, lon], "latitude": lat, "longitude": lon})
    elif not query.is_empty():
        for place in atlas + app.destinations:
            if str(place.name).to_lower().contains(query.to_lower()):
                matches.append(place)
            if matches.size() == 8: break
    search_status.text = "%d offline results · use worldwide search for more" % matches.size()
    _show_search(matches)

func _worldwide_results() -> void:
    search_status.text = app.services.search_status
    _show_search(app.services.results)

func _live(box: VBoxContainer) -> void:
    label(box, "Know what you're seeing", 18)
    label(box, "The globe uses offline satellite textures and night-light imagery. Clouds, Moon and stars are artistic.")
    var sunlight := CheckButton.new()
    sunlight_toggle = sunlight
    sunlight.text = "Current UTC sunlight"
    sunlight.button_pressed = app.utc_sunlight
    sunlight.toggled.connect(app.set_utc_sunlight)
    box.add_child(sunlight)
    solar_status = label(box, "", 12)
    label(box, "Approximate seasonal day/night boundary, calculated offline every 30 seconds. Keep your computer clock correct. Night lights screensaver uses artistic lighting.", 12)
    button(box, "Sunlight calculation source · NOAA ↗", func(): OS.shell_open("https://gml.noaa.gov/grad/solcalc/solareqns.PDF"))
    button(box, "Earthquake observations", func(): open_page("Command Center"))
    button(box, "Official camera pages", func(): open_page("Cameras"))
    button(box, "NASA Eyes on Earth · browser", func(): OS.shell_open("https://eyes.nasa.gov/apps/earth/#/"))
    label(box, "NASA's external explorer provides satellite and Earth science views. Requested point weather is in Command Center. Satellite tracking and seasonal imagery remain on the roadmap.", 12)

func _cameras(box: VBoxContainer) -> void:
    label(box, "Windows onto the planet", 18)
    label(box, "Image cameras open here. Video and seasonal sources open their official websites. Every selection also flies Earth to the approximate location.", 12)
    button(box, "Open Camera Wall", func(): wall.open())
    camera_status = label(box, "Choose a camera below.")
    camera_query = LineEdit.new()
    camera_query.placeholder_text = "Find a camera or provider"
    camera_query.max_length = 80
    camera_query.text_changed.connect(func(_text: String): _camera_list())
    box.add_child(camera_query)
    var image_filter := CheckButton.new()
    image_filter.text = "Image cameras only"
    image_filter.toggled.connect(func(enabled: bool): camera_images_only = enabled; _camera_list())
    box.add_child(image_filter)
    camera_rows = VBoxContainer.new()
    box.add_child(camera_rows)
    _camera_list()

func _camera_list() -> void:
    if not camera_rows: return
    _clear(camera_rows)
    var query := camera_query.text.strip_edges().to_lower()
    var count := 0
    for venue in cameras:
        if camera_images_only and not venue.has("image_url"): continue
        if not query.is_empty() and query not in (str(venue.name)+" "+str(venue.provider)+" "+str(venue.kind)).to_lower(): continue
        count += 1
        label(camera_rows, venue.provider, 12)
        var title: String = venue.name + ("" if venue.has("image_url") else " ↗")
        button(camera_rows, title, func(): select_camera(venue))
        label(camera_rows, venue.kind, 12)
    camera_status.text = "%d camera%s · select a view below" % [count,"" if count == 1 else "s"] if count > 0 else "No cameras match. Try another place or provider."
    refresh_layout()

func select_camera(venue: Dictionary) -> void:
    if not app.fly_to_location(venue, false): return
    show_arrival(venue)
    if venue.has("image_url"):
        if wall and wall.visible: wall.manager.set_suspended(true)
        camera_overlay.show()
        app.camera_service.open(venue)
        refresh_layout()
    else:
        var error := OS.shell_open(venue.url)
        camera_status.text = "Opened official camera website: " + venue.name if error == OK else "Could not open the browser. Try the official source again."
        label(pages.Destination, camera_status.text, 14)
        refresh_layout()

func show_arrival(place: Dictionary) -> void:
    if app.screensaver_mode: return
    if photo_viewer: photo_viewer.close()
    close_camera()
    arrival_place = place.duplicate(true)
    var box: VBoxContainer = pages.Destination
    _clear(box)
    label(box, str(place.get("name", "Your destination")), 23)
    label(box, str(place.get("region", place.get("provider", "Exploring Earth"))), 12)
    arrival_status = label(box, "Travelling to your destination…", 14)
    var photo: Dictionary = preload("res://scripts/discovery_photos.gd").lookup(place)
    arrival_has_photo = not photo.is_empty()
    if arrival_has_photo:
        var image := TextureRect.new()
        image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        image.custom_minimum_size.y = 170
        image.texture = load(photo.image)
        box.add_child(image)
        label(box, "Photo: %s · %s · not live" % [photo.author,photo.license],12)
        button(box,"View photograph & credits",func(): photo_viewer.open(photo,str(place.get("name","Earth"))))

    var story := str(place.get("note", place.get("fact", place.get("kind", ""))))
    if story.is_empty():
        story = "Explore this location on Earth, save it for another journey, or request its current weather."
    label(box, story, 16)
    label(box, "%.4f°, %.4f° · approximate location on modern Earth imagery" % [place.latitude, place.longitude], 12)
    arrival_save = button(box, "", func():
        app.exploration.toggle_save(arrival_place)
        _arrival_save_state())
    _arrival_save_state()
    button(box, "Weather here", exploration_panel.request_selected_weather)
    var source := str(place.get("source", place.get("url", "")))
    if source.begins_with("https://"):
        button(box, "Explore the official source ↗", func(): OS.shell_open(source))
    for venue in cameras:
        if venue.name == place.get("name") or (place.has("camera_id") and venue.get("id", "") == place.camera_id):
            button(box, "View camera", func(): select_camera(venue))
    button(box, "Discover another place", exploration_panel.surprise_wonder)
    button(box, "Back to the globe", close_panel)
    # Repeated arrivals must replace the card rather than toggle it closed.
    active_page = ""
    open_page("Destination")
    if app.journey and app.journey.is_running():
        app.journey.finished.connect(func():
            if is_instance_valid(arrival_status): arrival_status.text = "You’re here · " + str(arrival_place.get("name", "Earth")))
    else:
        arrival_status.text = "You’re here"

func _arrival_save_state() -> void:
    arrival_save.text = "Remove saved place" if app.exploration.is_saved(arrival_place) else "Save this place"
    arrival_save.disabled = not app.exploration.is_saved(arrival_place) and app.exploration.bookmarks.size() >= 50

func _build_camera_viewer() -> void:
    camera_overlay = ColorRect.new()
    camera_overlay.color = Color(0.002, 0.008, 0.02, 0.83)
    camera_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
    add_child(camera_overlay)
    camera_viewer = PanelContainer.new()
    camera_viewer.add_theme_stylebox_override("panel", surface(Color("0e2030"), 18, 20))
    camera_overlay.add_child(camera_viewer)
    var box := VBoxContainer.new()
    camera_viewer.add_child(box)
    var row := HBoxContainer.new()
    box.add_child(row)
    camera_title = label(row, "Camera", 20)
    camera_close = button(row, "Close", close_camera)
    camera_close.clip_text = false
    camera_source = label(box, "", 12)
    camera_image = TextureRect.new()
    camera_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    camera_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    camera_image.size_flags_vertical = Control.SIZE_EXPAND_FILL
    camera_image.custom_minimum_size.y = 140
    box.add_child(camera_image)
    camera_detail = label(box, "", 12)
    var controls := HFlowContainer.new()
    box.add_child(controls)
    camera_refresh = button(controls, "Refresh", app.camera_service.refresh)
    camera_refresh.clip_text = false
    camera_source_button = button(controls, "Official source ↗", func():
        if app.camera_service.selected.has("url"): OS.shell_open(app.camera_service.selected.url))
    camera_source_button.clip_text = false
    var automatic := CheckButton.new()
    automatic.text = "Auto refresh (backs off on errors)"
    automatic.button_pressed = true
    automatic.toggled.connect(app.camera_service.set_automatic)
    controls.add_child(automatic)
    app.camera_service.changed.connect(_camera_changed)
    camera_overlay.hide()

func _camera_changed() -> void:
    camera_title.text = app.camera_service.selected.get("name", "Camera")
    camera_source.text = app.camera_service.selected.get("provider", "") + " · camera image"
    camera_image.texture = app.camera_service.image
    camera_detail.text = app.camera_service.status
    refresh_layout()

func close_camera() -> void:
    if camera_overlay: camera_overlay.hide()
    app.camera_service.stop()
    if wall and wall.visible: wall.manager.set_suspended(false)


func _command(box: VBoxContainer) -> void:
    exploration_panel.build_weather(box)
    label(box, "Earthquake watch", 18)
    quake_status = label(box, app.services.quake_status, 12)
    button(box, "Refresh USGS · M2.5+ past day", app.services.refresh_quakes)
    quake_results = VBoxContainer.new()
    box.add_child(quake_results)
    _refresh_quake_list()
    var layout := CheckButton.new()
    layout.text = "Wide command center layout"
    layout.button_pressed = app.preferences.get_value("interface", "dashboard", false)
    dashboard = layout.button_pressed
    layout.toggled.connect(func(enabled: bool):
        dashboard = enabled
        app.preferences.set_value("interface", "dashboard", enabled)
        app._save_preferences()
        relayout())
    box.add_child(layout)
    label(box, "The overview card appears on spacious displays. Data is refreshed on request, not streamed. This app is not an emergency alert service.", 12)
    button(box, "USGS volcano observatories ↗", func(): OS.shell_open("https://www.usgs.gov/programs/VHP/volcano-observatories"))

func _refresh_quake_list() -> void:
    if not quake_status: return
    quake_status.text = app.services.quake_status
    _clear(quake_results)
    for quake in app.services.earthquakes:
        var entry := button(quake_results, "M%.1f · %s" % [quake.magnitude, quake.name.left(29)], func(): app.fly_to_location(quake))
        entry.tooltip_text = "%s\n%s UTC" % [quake.name, quake.utc]
        label(quake_results, quake.utc + " UTC", 12)
    if app.services.earthquakes.is_empty():
        label(quake_results, "No observations loaded. Refresh to request the public USGS feed.", 12)

func _savers(box: VBoxContainer) -> void:
    label(box, "Your own quiet planet", 18)
    label(box, "Offline · saved sunlight setting · no network requests", 12)
    var choices := OptionButton.new()
    for title in ["Ambient Earth", "Discovery journeys", "Night lights", "Deep space", "Daylight Earth", "Orbital drift"]:
        choices.add_item(title)
    choices.select(app.saver_style)
    choices.item_selected.connect(func(index: int):
        app.saver_style = index
        app.preferences.set_value("screensaver", "style", index)
        app._save_preferences())
    box.add_child(choices)
    button(box, "Preview · move mouse or press key to return", app.preview_screensaver)
    label(box, "Slow rotation, independent clouds and ocean glints. Discovery visits a new destination every two minutes. Night lights uses artistic night-side lighting.", 12)
    label(box, "Windows preview stays inside Screen Saver Settings. Fullscreen saver covers every monitor: up to four animated Earth views, with additional displays kept black. Saver views use 2K textures and up to 30 FPS; the small Windows preview uses 15 FPS. Keyboard, mouse or a display change exits the fullscreen saver.", 12)
    if OS.get_name() == "Windows":
        var windows_status := label(box, "Choose Use Living Earth 3D to select it for your Windows account. In Windows settings, choose the wait time and click Apply.", 12)
        button(box, "Use Living Earth 3D · open Windows settings", func(): _windows_saver_action(true, windows_status))
        button(box, "Windows screensaver settings", func(): _windows_saver_action(false, windows_status))

func _windows_saver_action(select_earth: bool, status: Label) -> void:
    # Let the Windows dialog be visible when Earth was fullscreen.
    if app.get_window().mode in [Window.MODE_FULLSCREEN, Window.MODE_EXCLUSIVE_FULLSCREEN]:
        app.get_window().mode = Window.MODE_WINDOWED
    var saver := OS.get_executable_path().get_base_dir().path_join("LivingEarth3D.scr")
    if not FileAccess.file_exists(saver):
        if select_earth:
            status.text = "The Windows screensaver file is missing. Reinstall Living Earth 3D to repair it."
            return
        var control := OS.get_environment("SystemRoot").path_join("System32/control.exe")
        var pid := OS.create_process(control, ["desk.cpl,screensaver,@screensaver"], false)
        status.text = "Windows settings requested. Check the taskbar if it opens behind Earth." if pid > 0 else "Windows settings could not open. Press Win+R and enter: control desk.cpl,screensaver,@screensaver"
        return
    var result := OS.execute(saver, ["/select" if select_earth else "/settings"], [], false, false)
    match result:
        0: status.text = "Living Earth 3D selected. Choose the wait time and click Apply in Windows settings." if select_earth else "Windows settings requested. Check the taskbar if it opens behind Earth."
        3: status.text = "The Windows screensaver installation is incomplete. Reinstall Living Earth 3D to repair it."
        5: status.text = "Your Windows organization policy controls the screensaver. Ask your administrator to allow Living Earth 3D."
        6: status.text = "Windows could not save the screensaver selection. Open Windows settings and check your account permissions."
        _: status.text = "Windows settings could not open. Press Win+R and enter: control desk.cpl,screensaver,@screensaver"

func _settings(box: VBoxContainer) -> void:
    label(box, "Display & graphics", 18)
    monitor_status = label(box, app.display_summary(), 12)
    button(box, "Performance & support", func(): open_page("Display report"))
    label(box, "Interface size", 16)
    scale_picker = OptionButton.new()
    for value in SCALE_OPTIONS:
        scale_picker.add_item("Automatic" if value == 0.0 else "%d%%" % roundi(value * 100.0))
    scale_picker.select(SCALE_OPTIONS.find(preferred_scale))
    scale_picker.item_selected.connect(func(index: int): set_ui_scale(SCALE_OPTIONS[index]))
    box.add_child(scale_picker)
    scale_status = label(box, "", 12)
    label(box, "Make controls easier to read on large displays. Your choice is saved; smaller windows limit the size so controls stay within reach. Earth stays at native resolution.", 12)
    app._build_visual_options(box)
    label(box, "Balanced is recommended for everyday PCs. Detailed loads 4K Earth maps; higher-resolution monitors cannot add source detail. V-sync follows the display; the app caps animation at 60 FPS, or 30 in power saving.", 12)
    label(box, "Ambient sound", 18)
    var sound := CheckButton.new()
    sound.text = "Quiet ambient pad"
    sound.button_pressed = app.ambient.enabled
    sound.toggled.connect(func(enabled: bool):
        app.ambient.enabled = enabled
        app.preferences.set_value("audio", "enabled", enabled)
        app._save_preferences()
        app.ambient.apply())
    box.add_child(sound)
    var volume := HSlider.new()
    volume.min_value = 0.0
    volume.max_value = 1.0
    volume.step = 0.01
    volume.value = app.ambient.level
    volume.custom_minimum_size = Vector2(200, 32)
    volume.tooltip_text = "Ambient volume"
    volume.value_changed.connect(func(value: float):
        app.ambient.level = value
        app.preferences.set_value("audio", "volume", value)
        app._save_preferences()
        app.ambient.apply())
    box.add_child(volume)
    label(box, "Original offline synthesized sound · off by default. Screensaver mode stays silent.", 12)
    label(box, "Updates", 18)
    var automatic := CheckButton.new()
    automatic.text = "Automatic updates"
    automatic.button_pressed = app.background_updates_enabled()
    automatic.toggled.connect(app.set_background_updates)
    box.add_child(automatic)
    button(box, "Check updates", app.check_updates)
    button(box, "Update and restart now", app.install_update)
    button(box, "Download installer manually", app.download_latest)
    app.update_status = label(box, "Version " + app.VERSION + " · Verified updates install when you close the app.", 12)
    label(box, "Automatic checks run at startup and every 30 minutes while open. Small and large releases use the same verified update process. Turn this off to defer pending updates. Offline exploration always works.", 12)
    button(box, "Version history ↗", func(): OS.shell_open("https://github.com/nortja/Living-earth-3d/blob/main/CHANGELOG.md"))
    label(box, "Earth maps: Solar System Scope / INOVE · CC BY 4.0. Moon: three.js · MIT. Cloud and space layers are offline artwork.", 12)

func build_performance_controls() -> void:
    var box: VBoxContainer = pages["Display report"]
    label(box, "Local performance report", 18)
    performance_values = label(box, "Open Settings for live frame and memory measurements.", 12)
    performance_record = button(box, "Record 5 active minutes", func():
        if app.performance_report.recording: app.performance_report.stop_recording()
        else: app.performance_report.start_recording())
    button(box, "Save local display report", func():
        var error: Error = app.performance_report.export_report()
        performance_export_status.text = "Saved display-report.json in the app data folder." if error == OK else "Could not save the display report. Try again."
        refresh_layout())
    if OS.get_name() == "Windows":
        button(box, "Open report folder", func(): OS.shell_open(ProjectSettings.globalize_path("user://")))
    performance_export_status = label(box, "Report stays on this computer. No upload, account name, file paths, saved places or camera images.", 12)
    label(box, "Frame intervals include the FPS cap. Engine memory excludes driver/GPU allocations. Recording pauses while minimized or in screensaver mode; sleep gaps over two seconds are excluded. This is a measurement, not a hardware rating.", 12)
    button(box, "Back to the globe · keep recording", close_panel)
    app.performance_report.changed.connect(_performance_changed)

func _performance_changed() -> void:
    var report: Dictionary = app.performance_report.snapshot
    var frames: Dictionary = report.get("recent_frames", {})
    var memory_text := "Engine memory: unavailable in this build" if not report.get("memory_counter_available",false) else "Engine tracked memory: %.1f MiB" % (float(report.engine_tracked_memory_bytes)/1048576.0)
    performance_values.text = "Gathering active frames…" if frames.is_empty() else "%.1f FPS · %.1f ms average · %.1f ms p95\n%s" % [frames.fps,frames.mean_ms,frames.p95_ms,memory_text]
    var recording: Dictionary = report.get("recording", {})
    if not recording.is_empty() and recording.frames > 0:
        performance_values.text += "\nRecording: %d / 300 active seconds · %d frames over 50 ms" % [int(recording.active_seconds),recording.frames_over_50ms]
    performance_record.text = "Stop recording" if app.performance_report.recording else "Record 5 active minutes"
    if active_page == "Display report": refresh_layout()

func build_weather_layer_controls() -> void:
    var entry := button(pages["Live Earth"],"Weather around Earth",func(): open_page("Weather globe"))
    pages["Live Earth"].move_child(entry,2)
    var box: VBoxContainer = pages["Weather globe"]
    label(box,"Weather around Earth",18)
    label(box,"Sixteen public model points · refreshed only when requested",12)
    weather_layer_status = label(box,"",12)
    weather_layer_refresh = button(box,"Load / refresh weather points",app.weather_layer.refresh)
    weather_layer_cancel = button(box,"Cancel weather-layer request",app.weather_layer.cancel)
    weather_layer_toggle = CheckButton.new()
    weather_layer_toggle.text = "Show temperature points on Earth"
    weather_layer_toggle.toggled.connect(app.weather_layer.set_enabled)
    box.add_child(weather_layer_toggle)
    weather_layer_legend = label(box,"",12)
    weather_layer_picker = OptionButton.new()
    weather_layer_picker.clip_text = true
    weather_layer_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    weather_layer_picker.item_selected.connect(func(index: int):
        if index > 0: app.weather_layer.visit(index-1))
    box.add_child(weather_layer_picker)
    label(box,"Choose a place above or click a visible globe point. Model times stay with each place. Grey points are stale; expired points are hidden. This samples sixteen places, not a continuous global weather map.",12)
    label(box,"Loading submits only the fixed public coordinates to Open-Meteo, without tracking your location. No automatic weather downloads run at startup or in screensaver mode.",12)
    button(box,"Weather data · Open-Meteo · CC BY 4.0 ↗",func(): OS.shell_open("https://open-meteo.com/"))
    weather_model_badge = button(self,"Model weather · Open-Meteo",func(): open_page("Weather globe"))
    weather_model_badge.clip_text = false
    weather_model_badge.custom_minimum_size = Vector2(240,36)
    weather_model_badge.hide()
    app.weather_layer.changed.connect(_weather_layer_changed)
    _weather_layer_changed()

func _weather_layer_changed() -> void:
    if not app.weather_layer: return
    var service = app.weather_layer
    weather_layer_status.text = service.status
    weather_layer_refresh.disabled = service.loading
    weather_layer_cancel.disabled = not service.loading
    weather_layer_toggle.disabled = service.points.is_empty()
    weather_layer_toggle.set_pressed_no_signal(service.enabled)
    weather_layer_legend.text = "Blue ≤32°F · teal to 59°F · amber to 77°F · coral above 77°F" if app.preferences.get_value("weather","imperial",true) else "Blue ≤0°C · teal to 15°C · amber to 25°C · coral above 25°C"
    weather_layer_picker.clear()
    weather_layer_picker.add_item("Visit a weather point…")
    for point in service.points:
        weather_layer_picker.add_item(service.point_label(point))
        weather_layer_picker.set_item_tooltip(weather_layer_picker.item_count-1,service.point_label(point)+"\nModel time: "+point.utc+" UTC")
    weather_layer_picker.disabled = service.points.is_empty()
    refresh_layout()
