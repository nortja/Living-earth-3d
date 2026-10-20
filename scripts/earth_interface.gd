extends Control
## Physical-pixel layout: the 3D viewport keeps the display's native resolution.
var app: Node3D
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
var camera_status: Label
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
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    box.add_child(scroll)
    var page_stack := VBoxContainer.new()
    page_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.add_child(page_stack)
    for title in NAV + ["Settings"]:
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
    panel.hide()
    command_card.hide()
    app.services.earthquakes_changed.connect(_refresh_quake_list)
    app.services.search_changed.connect(_worldwide_results)
    get_viewport().size_changed.connect(refresh_layout)
    relayout()

func _process(_delta: float) -> void:
    if layout_frames > 0:
        layout_frames -= 1
        relayout()

func refresh_layout() -> void:
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
    if active_page == title and panel.visible:
        close_panel()
        return
    active_page = title
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
        panel.position = Vector2(24, size.y - 282)
        panel.size = Vector2(size.x - 48, 190)
    command_card.position = Vector2(24, 104)
    command_card.size = Vector2(280, 230)
    command_card.visible = dashboard and active_page == "Command Center" and side_layout and size.x >= 1600

func set_ui_scale(value: float) -> void:
    preferred_scale = value if value in SCALE_OPTIONS else 0.0
    app.preferences.set_value("interface", "ui_scale", preferred_scale)
    app._save_preferences()
    if scale_picker:
        scale_picker.select(SCALE_OPTIONS.find(preferred_scale))
    refresh_layout()

func _explore(box: VBoxContainer) -> void:
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
    button(row, "Visit favorite", app.visit_favorite)
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
    label(box, "The globe uses offline satellite textures and night-light imagery. Clouds drift as artwork. Lighting is cinematic; it does not show the current Sun position.")
    button(box, "Earthquake observations", func(): open_page("Command Center"))
    button(box, "Official camera pages", func(): open_page("Cameras"))
    button(box, "NASA Eyes on Earth · browser", func(): OS.shell_open("https://eyes.nasa.gov/apps/earth/#/"))
    label(box, "NASA's external explorer provides satellite and Earth science views. In-app satellite tracking, current weather and seasonal imagery remain on the roadmap.", 12)

func _cameras(box: VBoxContainer) -> void:
    label(box, "Windows onto the planet", 18)
    label(box, "Select a venue to fly there. Open its official page in your browser to watch. Feeds can be seasonal or offline; availability is not verified. Locations are approximate.", 12)
    camera_status = label(box, "Choose a camera venue.")
    for venue in cameras:
        label(box, venue.provider, 12)
        button(box, venue.name, func():
            app.fly_to_location(venue)
            camera_status.text = venue.name + "\n" + venue.kind)
        label(box, venue.kind, 12)
        button(box, "Open official page ↗", func(): OS.shell_open(venue.url))

func _command(box: VBoxContainer) -> void:
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
    label(box, "Offline, cinematic lighting · no network requests", 12)
    var choices := OptionButton.new()
    for title in ["Ambient Earth", "Discovery journeys", "Night lights", "Deep space"]:
        choices.add_item(title)
    choices.select(app.saver_style)
    choices.item_selected.connect(func(index: int):
        app.saver_style = index
        app.preferences.set_value("screensaver", "style", index)
        app._save_preferences())
    box.add_child(choices)
    button(box, "Preview · move mouse or press key to return", app.preview_screensaver)
    label(box, "Slow rotation, independent clouds and ocean glints. Discovery visits a new destination every two minutes. Night lights uses artistic night-side lighting.", 12)
    if OS.get_name() == "Windows":
        button(box, "Windows screensaver settings", func():
            var saver := OS.get_executable_path().get_base_dir().path_join("LivingEarth3D.scr")
            if FileAccess.file_exists(saver): OS.create_process("rundll32.exe", ["desk.cpl,InstallScreenSaver", saver], false))

func _settings(box: VBoxContainer) -> void:
    label(box, "Display & graphics", 18)
    monitor_status = label(box, app.display_summary(), 12)
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
