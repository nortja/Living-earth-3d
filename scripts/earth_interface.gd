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
var dock_row: HBoxContainer
var layout_frames := 8
var page_animation: Tween
var camera_status: Label
var camera_selection := 0
var camera_clock: Label
var camera_health: Label
var solar_status: Label
var command_solar: Label
var weather_status: Label
var weather_detail: Label
var history_banner: Label
var history_results: VBoxContainer
var history_year: Label
var history_slider: HSlider
var history_toggle: CheckButton
var discovery_title: Label
var discovery_note: Label
var discovery_camera: Button
var current_discovery: Dictionary = {}
var discovery_is_daily := true
var daily_id := ""
const TITLES := {"Explore": "Explore Earth", "Live Earth": "Live Earth", "Cameras": "Global Cameras", "Command Center": "Command Center", "Screensavers": "Screensaver Settings", "Settings": "Display & Updates"}
const NAV := ["Explore", "Live Earth", "Cameras", "Command Center", "Screensavers"]

func setup(owner_app: Node3D) -> void:
    app = owner_app
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
    var brand := label(identity, "LIVING EARTH · DEV", 18)
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
        navigation[title] = button(dock_row, TITLES[title], func(): open_page(title))
        navigation[title].toggle_mode = true
        navigation[title].clip_text = false
    panel = PanelContainer.new()
    panel.add_theme_stylebox_override("panel", surface(Color(0.025, 0.045, 0.075, 0.91), 16, 18))
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
    command_solar = label(card_box, "Solar geometry · calculated from UTC", 12)
    label(card_box, "Earth imagery · offline\nCloud layer · artistic drift\nCameras · external provider players\nEarthquakes & weather · on request", 12)
    button(card_box, "Return to full Earth", func(): close_panel(); app.reset_view())
    history_banner = label(self, "", 12)
    history_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    history_banner.add_theme_color_override("font_color", Color("ffd49a"))
    history_banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
    history_banner.hide()
    panel.hide()
    command_card.hide()
    app.services.earthquakes_changed.connect(_refresh_quake_list)
    app.services.search_changed.connect(_worldwide_results)
    app.observations.weather_changed.connect(_refresh_weather)
    app.observations.camera_checked.connect(_refresh_camera)
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
    style.border_color = Color(0.29, 0.61, 0.76, 0.18)
    style.set_border_width_all(1)
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
    item.clip_text = parent != header and not parent is HFlowContainer
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
    if title not in pages: return
    active_page = title
    if app.camera_markers: app.camera_markers.visible = title == "Cameras"
    page_title.text = TITLES[title]
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
    if app.camera_markers: app.camera_markers.hide()
    panel.hide()
    command_card.hide()
    for item in navigation.values():
        item.set_pressed_no_signal(false)

func relayout() -> void:
    var pixels := get_viewport_rect().size
    # Keep controls compact on ultrawide displays; scale for high pixel density.
    display_scale = minf(clampf(pixels.y / 1080.0, 1.0, 1.75), maxf(1.0, pixels.x / 800.0))
    scale = Vector2.ONE * display_scale
    size = pixels / display_scale
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
    history_banner.position = Vector2(24, 78)
    history_banner.size = Vector2(size.x - 48, 24)
    command_card.position = Vector2(24, 114)
    command_card.size = Vector2(280, 265)
    command_card.visible = dashboard and active_page == "Command Center" and side_layout and size.x >= 1600

func _explore(box: VBoxContainer) -> void:
    var tabs := HBoxContainer.new()
    box.add_child(tabs)
    var sections: Dictionary = {}
    var controls: Dictionary = {}
    var stack := VBoxContainer.new()
    box.add_child(stack)
    for title in ["Discover", "Search", "Time Machine"]:
        var content := VBoxContainer.new()
        stack.add_child(content)
        content.visible = title == "Discover"
        sections[title] = content
        var tab := button(tabs, title, func():
            for name in sections:
                sections[name].visible = name == title
                controls[name].set_pressed_no_signal(name == title)
            refresh_layout())
        tab.clip_text = false
        tab.toggle_mode = true
        tab.set_pressed_no_signal(title == "Discover")
        controls[title] = tab
    _discovery_section(sections.Discover)
    app.place_picker = OptionButton.new()
    app.place_picker.add_item("Saved journeys & curated places…")
    for place in app.destinations: app.place_picker.add_item(place.name)
    app.place_picker.item_selected.connect(func(index: int):
        if index > 0: app.visit(index - 1))
    sections.Discover.add_child(app.place_picker)
    var favorites := HFlowContainer.new()
    sections.Discover.add_child(favorites)
    app.favorite_button = button(favorites, "Save favorite", app.toggle_favorite)
    button(favorites, "Visit favorite", app.visit_favorite)
    var search_box: VBoxContainer = sections.Search
    var query := LineEdit.new()
    query.placeholder_text = "Place or latitude, longitude"
    query.custom_minimum_size.y = 38
    search_box.add_child(query)
    query.text_submitted.connect(_search_offline)
    button(search_box, "Search offline atlas", func(): _search_offline(query.text))
    button(search_box, "Search worldwide · online", func(): app.services.search_worldwide(query.text))
    search_status = label(search_box, app.services.search_status, 12)
    search_results = VBoxContainer.new()
    search_box.add_child(search_results)
    button(search_box, "OpenStreetMap attribution ↗", func(): OS.shell_open("https://www.openstreetmap.org/copyright"))
    _history_section(sections["Time Machine"])
    app.description = label(box, "Choose a wonder, search a place, or explore the historical atlas.", 12)

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
    label(box, "Follow the light", 18)
    solar_status = label(box, "Solar position calculated from your UTC clock.", 12)
    var solar := CheckButton.new()
    solar.text = "Current daylight · UTC model"
    solar.button_pressed = app.solar_enabled
    solar.toggled.connect(app.set_solar)
    box.add_child(solar)
    var line := CheckButton.new()
    line.text = "Show daylight boundary"
    line.button_pressed = app.daylight_line
    line.toggled.connect(func(enabled: bool):
        app.daylight_line = enabled
        app.preferences.set_value("visuals", "daylight_line", enabled)
        app._save_preferences()
        app.apply_lighting())
    box.add_child(line)
    label(box, "UTC mode calculates approximate sunlight and the day–night boundary. Cinematic lighting remains available when it is off. Imagery is offline; clouds drift as artwork. Moon and stars use artistic positions.", 12)
    button(box, "Weather & earthquake observations", func(): open_page("Command Center"))
    button(box, "Official camera players", func(): open_page("Cameras"))
    button(box, "NASA Eyes on Earth ↗", func(): OS.shell_open("https://eyes.nasa.gov/apps/earth/#/"))
    label(box, "Satellite orbits, aurora forecasts, ISS passes and astronomy alerts are planned. NASA's external explorer is available now; no in-app tracking is simulated.", 12)

func _cameras(box: VBoxContainer) -> void:
    label(box, "Windows onto the planet", 18)
    label(box, "Choose a venue or a blue globe marker to fly there. Provider players open externally. Live streams, seasonal views and periodic images are labeled; playback is not embedded in the globe.", 12)
    camera_status = label(box, "Choose a camera venue.")
    camera_clock = label(box, "", 12)
    camera_health = label(box, "Availability unchecked · never assume a live connection", 12)
    button(box, "Open provider player window ↗", open_camera_player)
    button(box, "Check provider page", func(): app.observations.check_camera(cameras[camera_selection], cameras))
    button(box, "Surprise me · camera venue", surprise_camera)
    for index in range(cameras.size()):
        var venue: Dictionary = cameras[index]
        button(box, venue.name, func(): select_camera(index))
        label(box, venue.provider + " · " + venue.kind, 12)
    _refresh_camera()

func select_camera(index: int) -> void:
    if index < 0 or index >= cameras.size(): return
    camera_selection = index
    app.fly_to_location(cameras[index])
    _refresh_camera()

func surprise_camera() -> void:
    var index := randi_range(0, cameras.size() - 2)
    if index >= camera_selection: index += 1
    select_camera(index)

func _refresh_camera() -> void:
    if not camera_status: return
    var venue: Dictionary = cameras[camera_selection]
    camera_status.text = "%s\n%.3f°, %.3f° · approximate venue location" % [venue.name, venue.latitude, venue.longitude]
    camera_health.text = app.observations.camera_checks.get(venue.id, "Availability unchecked · stream status unknown")

func open_camera_player() -> void:
    var venue: Dictionary = cameras[camera_selection]
    # Edge app mode uses the provider's own player and normal browser security.
    # No private stream extraction, fake video, embedded cookies or web runtime dependency.
    if OS.get_name() == "Windows":
        for variable in ["ProgramFiles(x86)", "ProgramFiles", "LOCALAPPDATA"]:
            var base := OS.get_environment(variable)
            var edge := base.path_join("Microsoft/Edge/Application/msedge.exe")
            if not base.is_empty() and FileAccess.file_exists(edge):
                if OS.create_process(edge, ["--app=" + venue.url, "--new-window"], false) > 0: return
    OS.shell_open(venue.url)

func _command(box: VBoxContainer) -> void:
    label(box, "Weather at your view", 18)
    weather_status = label(box, app.observations.weather_status, 12)
    weather_detail = label(box, "Choose a place, then refresh. Weather is a periodic model estimate, not a live sensor feed.", 12)
    button(box, "Refresh weather at view center", func(): app.observations.request_weather(app.view_location()))
    button(box, "Open-Meteo sources & licence ↗", func(): OS.shell_open("https://open-meteo.com/en/terms"))
    _refresh_weather()
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
    label(box, "Offline globe · cinematic or calculated UTC lighting", 12)
    var choices := OptionButton.new()
    for title in ["Peaceful rotation", "Global discovery", "Night lights", "Deep space", "Day–night realism · current UTC", "Cinematic orbit"]:
        choices.add_item(title)
    choices.select(app.saver_style)
    choices.item_selected.connect(func(index: int):
        app.saver_style = index
        app.preferences.set_value("screensaver", "style", index)
        app._save_preferences())
    box.add_child(choices)
    button(box, "Preview · move mouse or press key to return", app.preview_screensaver)
    label(box, "Slow rotation, drifting clouds and ocean glints. Global discovery visits a wonder every two minutes. UTC realism calculates sunlight from your clock; cinematic orbit gently changes the viewing angle.", 12)
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
    for seconds in [60, 120, 300]: interval.add_item("Explorer journey every %d min" % (seconds / 60), seconds)
    interval.select({60: 0, 120: 1, 300: 2}.get(int(app.discovery_interval), 1))
    interval.item_selected.connect(func(index: int):
        app.discovery_interval = interval.get_item_id(index)
        app.elapsed = 0.0
        app.preferences.set_value("explorer", "interval", app.discovery_interval)
        app._save_preferences())
    box.add_child(interval)
    if OS.get_name() == "Windows":
        button(box, "Windows screensaver settings", func():
            var saver := OS.get_executable_path().get_base_dir().path_join("LivingEarth3D.scr")
            if FileAccess.file_exists(saver): OS.create_process("rundll32.exe", ["desk.cpl,InstallScreenSaver", saver], false))

func _settings(box: VBoxContainer) -> void:
    label(box, "Display & graphics", 18)
    monitor_status = label(box, app.display_summary(), 12)
    app._build_visual_options(box)
    label(box, "Balanced is recommended for everyday PCs. Detailed loads 4K Earth maps; higher-resolution monitors cannot add source detail. V-sync follows the display; the app caps animation at 60 FPS, or 30 in power saving.", 12)
    label(box, "Updates", 18)
    var automatic := CheckButton.new()
    automatic.text = "Check for updates on startup"
    automatic.button_pressed = app.preferences.get_value("updates", "automatic", false)
    automatic.toggled.connect(func(enabled: bool):
        app.preferences.set_value("updates", "automatic", enabled)
        app._save_preferences()
        if enabled: app.check_updates())
    box.add_child(automatic)
    button(box, "Check updates", app.check_updates)
    button(box, "Download latest installer", app.download_latest)
    button(box, "Install signed update", app.install_update)
    app.update_status = label(box, "Development " + app.VERSION + " · Separate development feed. Unsigned builds install manually.", 12)
    button(box, "Version history ↗", func(): OS.shell_open("https://github.com/nortja/Living-earth-3d/blob/development/CHANGELOG.md"))
    label(box, "Earth maps: Solar System Scope / INOVE · CC BY 4.0. Moon: three.js · MIT. Cloud and space layers are offline artwork.", 12)


func update_clock() -> void:
    var utc := Time.get_datetime_string_from_system(true).replace("T", " ")
    camera_clock.text = "Viewer clock · %s UTC\nCamera capture time is supplied by the provider." % utc
    if not app.solar_info.is_empty():
        var summary := "Sun overhead near %.2f°, %.2f°\n%s UTC · calculated, approximate" % [app.solar_info.latitude, app.solar_info.longitude, utc]
        solar_status.text = summary
        command_solar.text = summary
    var today: Dictionary = app.catalog.daily(Time.get_unix_time_from_system())
    if today.id != daily_id and discovery_is_daily:
        daily_id = today.id
        _discovery_text(today, true)

func _refresh_weather() -> void:
    if not weather_status: return
    weather_status.text = app.observations.weather_status
    var report: Dictionary = app.observations.weather
    if report.is_empty(): return
    weather_detail.text = "%s · %.3f°, %.3f°\n%.1f °C · %s\nWind %.1f km/h · Humidity %.0f%%\nModel time %s UTC\nApproximate model grid; not a local sensor." % [report.name, report.latitude, report.longitude, report.temperature, app.observations.weather_name(report.code), report.wind, report.humidity, report.utc]

func _discovery_section(box: VBoxContainer) -> void:
    discovery_title = label(box, "Today's discovery", 17)
    discovery_note = label(box, "", 13)
    button(box, "Visit today's wonder", func():
        discovery_is_daily = true
        show_discovery(app.catalog.daily(Time.get_unix_time_from_system())))
    button(box, "Surprise me · hidden wonder", func():
        discovery_is_daily = false
        var choices: Array = app.catalog.places.filter(func(place): return place.id != current_discovery.get("id", ""))
        show_discovery(choices.pick_random()))
    button(box, "Why this place matters · source ↗", func():
        if not current_discovery.is_empty(): OS.shell_open(current_discovery.source))
    discovery_camera = button(box, "Camera connection", func():
        for index in range(cameras.size()):
            if cameras[index].id == current_discovery.get("camera_id", ""):
                open_page("Cameras")
                select_camera(index)
                return)
    _discovery_text(app.catalog.daily(Time.get_unix_time_from_system()), true)

func _discovery_text(place: Dictionary, daily: bool) -> void:
    current_discovery = place
    discovery_title.text = ("Today's discovery · " if daily else "Earth discovery · ") + place.name
    discovery_note.text = place.note + "\nOffline editorial selection · daily choice changes at 00:00 UTC."
    discovery_camera.disabled = not place.has("camera_id")
    discovery_camera.text = "Explore official camera connection" if place.has("camera_id") else "No camera curated for this place"

func show_discovery(place: Dictionary) -> void:
    _discovery_text(place, discovery_is_daily and place.id == app.catalog.daily(Time.get_unix_time_from_system()).id)
    app.fly_to_location(place)
    app.description.text = place.name + "\n" + place.note

func _history_section(box: VBoxContainer) -> void:
    label(box, "Earth Time Machine", 18)
    label(box, "Historical atlas preview · dated site markers on modern Earth imagery. No historical imagery, borders or 3D reconstruction is shown.", 12)
    history_toggle = CheckButton.new()
    history_toggle.text = "Show historical atlas"
    box.add_child(history_toggle)
    var content := VBoxContainer.new()
    box.add_child(content)
    content.hide()
    history_year = label(content, "100 CE", 17)
    history_slider = HSlider.new()
    history_slider.min_value = -3000
    history_slider.max_value = int(Time.get_datetime_dict_from_system(true).year)
    history_slider.step = 1
    history_slider.value = 100
    history_slider.custom_minimum_size.y = 32
    history_slider.tooltip_text = "Drag through years; BCE / CE dates use broad teaching intervals."
    content.add_child(history_slider)
    var jumps := HFlowContainer.new()
    content.add_child(jumps)
    for era in [{"name": "Egypt", "year": -2550}, {"name": "Rome", "year": 100}, {"name": "Maya", "year": 600}]:
        button(jumps, era.name, func(): history_slider.value = era.year).clip_text = false
    history_results = VBoxContainer.new()
    content.add_child(history_results)
    history_slider.value_changed.connect(func(value: float): _history_changed(int(value)))
    history_toggle.toggled.connect(func(enabled: bool):
        content.visible = enabled
        _history_changed(int(history_slider.value)))

func _history_changed(year: int) -> void:
    app.set_history(history_toggle.button_pressed, year)
    history_year.text = app.catalog.year_label(app.historical_year)
    _clear(history_results)
    for site in app.catalog.historical_sites(app.historical_year):
        button(history_results, site.name, func(): app.fly_to_location(site))
        label(history_results, site.note, 12)
        button(history_results, "Historical context ↗", func(): OS.shell_open(site.source))
    if history_results.get_child_count() == 0:
        label(history_results, "No catalogued sites in this teaching interval. Modern Earth imagery remains visible.", 12)
    refresh_layout()
