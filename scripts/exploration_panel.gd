extends RefCounted
## Shared exploration UI; all remote requests remain explicit user actions.
var ui: Control
var app: Node3D
var sections: Dictionary = {}
var tabs: Dictionary = {}
var daily_title: Label
var daily_note: Label
var daily_date: Label
var featured: Dictionary = {}
var saved_list: VBoxContainer
var saved_status: Label
var history_year: Label
var history_slider: HSlider
var history_results: VBoxContainer
var weather_target: Label
var weather_status: Label
var weather_values: Label
var weather_refresh: Button
var weather_units: CheckButton
var feature_save: Button
var bookmark_buttons: Array = []
var utc_day := -1

func setup(interface: Control) -> void:
    ui = interface
    app = ui.app

func action(parent: Node, title: String, callback: Callable) -> Button:
    var result: Button = ui.button(parent,title,callback)
    result.clip_text = false
    return result

func build_explore(box: VBoxContainer) -> void:
    var row := HFlowContainer.new()
    box.add_child(row)
    for title in ["Discover","Search","History","Saved"]:
        var tab := action(row,title,func(): select_section(title))
        tab.toggle_mode = true
        tabs[title] = tab
        var section := VBoxContainer.new()
        box.add_child(section)
        sections[title] = section
    _discover(sections.Discover)
    ui._explore_search(sections.Search)
    bookmark_buttons.append(action(sections.Search,"Save selected place",func(): app.exploration.toggle_save(app.exploration.location)))
    action(sections.Search,"Weather for selected place",request_selected_weather)
    _history(sections.History)
    _saved(sections.Saved)
    select_section("Discover")
    app.exploration.bookmarks_changed.connect(_bookmarks_changed)
    app.exploration.location_changed.connect(_location_changed)
    refresh_daily()

func select_section(title: String) -> void:
    for key in sections:
        sections[key].visible = key == title
        tabs[key].set_pressed_no_signal(key == title)
    ui.page_scroll.set_deferred("scroll_vertical",0)
    ui.refresh_layout()

func _discover(box: VBoxContainer) -> void:
    ui.label(box,"A little wonder, every day",20)
    daily_date = ui.label(box,"",12)
    var card := PanelContainer.new()
    card.add_theme_stylebox_override("panel",ui.surface(Color("142c3c"),12,14))
    box.add_child(card)
    var content := VBoxContainer.new()
    card.add_child(content)
    daily_title = ui.label(content,"",19)
    daily_note = ui.label(content,"",14)
    var row := HFlowContainer.new()
    content.add_child(row)
    action(row,"Take me there",func(): show_place(featured))
    action(row,"Surprise me",surprise_wonder)
    feature_save = action(content,"Save this place",func(): app.exploration.toggle_save(featured))
    action(content,"Weather for this place",func(): show_place(featured);request_selected_weather())
    action(content,"Read the source ↗",func(): if not featured.is_empty(): OS.shell_open(featured.source))
    ui.label(box,"Twelve curated places, with sources. Today's selection changes at UTC midnight; the catalog repeats after twelve days.",12)
    ui.label(box,"Explore the collection",16)
    for place in app.exploration.catalog.places:
        var entry: Button = ui.button(box,place.name,func(): feature(place))
        entry.tooltip_text = place.name

func refresh_daily() -> void:
    var now := Time.get_unix_time_from_system()
    var today := int(floor(now / 86400.0))
    if today == utc_day: return
    utc_day = today
    daily_date.text = Time.get_date_string_from_system(true) + " · UTC daily selection"
    feature(app.exploration.catalog.daily(now),false)

func feature(place: Dictionary, fly := true) -> void:
    featured = place.duplicate(true)
    daily_title.text = place.name
    daily_note.text = place.note
    var is_today: bool = place.get("id") == app.exploration.catalog.daily(Time.get_unix_time_from_system()).get("id")
    daily_date.text = Time.get_date_string_from_system(true) + (" · UTC daily selection" if is_today else " · selected wonder")
    _update_save_buttons()
    if fly: show_place(place)
    ui.refresh_layout()

func surprise_wonder() -> void:
    var choices: Array = app.exploration.catalog.places.filter(func(place): return place.get("id") != featured.get("id"))
    if not choices.is_empty(): feature(choices.pick_random())

func show_place(place: Dictionary) -> void:
    if not app.fly_to_location(place): return
    app.description.text = "%s\n%s\nModern Earth imagery · approximate globe location" % [place.name,place.get("note","")]

func _history(box: VBoxContainer) -> void:
    ui.label(box,"Earth through human history",20)
    ui.label(box,"MODERN EARTH IMAGERY",14)
    ui.label(box,"This timeline filters dated site markers. It does not reconstruct ancient cities, change borders or replace the planet's imagery.",12)
    history_year = ui.label(box,"",20)
    history_slider = HSlider.new()
    history_slider.min_value = -3000
    history_slider.max_value = 2026
    history_slider.step = 1
    history_slider.value = -2550
    history_slider.custom_minimum_size = Vector2(220,36)
    history_slider.tooltip_text = "Choose an approximate historical era"
    history_slider.value_changed.connect(func(_year: float): refresh_history())
    box.add_child(history_slider)
    var row := HFlowContainer.new()
    box.add_child(row)
    for preset in [{"title":"Pyramids","year":-2550},{"title":"Rome","year":100},{"title":"Tikal","year":600},{"title":"Temples","year":850},{"title":"Medieval","year":1250}]:
        action(row,preset.title,func(): history_slider.value = preset.year)
    history_results = VBoxContainer.new()
    box.add_child(history_results)
    ui.label(box,"Ten introductory sites. The intervals are broad editorial teaching ranges, not exact founding dates or a complete historical map.",12)
    refresh_history()

func refresh_history() -> void:
    var year := int(history_slider.value)
    if year == 0: year = 1
    history_year.text = app.exploration.catalog.year_label(year)
    ui._clear(history_results)
    var sites: Array = app.exploration.catalog.historical_sites(year)
    if sites.is_empty():
        ui.label(history_results,"No sites in this small catalog for that era. Try a preset above.",12)
    for place in sites:
        var entry: Button = ui.button(history_results,place.name,func(): show_place(place))
        entry.tooltip_text = place.name
        ui.label(history_results,place.note,12)
        var row := HFlowContainer.new()
        history_results.add_child(row)
        action(row,"Save / unsave",func(): app.exploration.toggle_save(place))
        action(row,"Source ↗",func(): OS.shell_open(place.source))
    ui.refresh_layout()

func _saved(box: VBoxContainer) -> void:
    ui.label(box,"Places worth returning to",20)
    saved_status = ui.label(box,"",12)
    bookmark_buttons.append(action(box,"Save selected place",func(): app.exploration.toggle_save(app.exploration.location)))
    saved_list = VBoxContainer.new()
    box.add_child(saved_list)
    ui.label(box,"Existing curated favorites remain available under Search. Saved places and camera collections stay on this computer.",12)
    _bookmarks_changed()

func _bookmarks_changed() -> void:
    _update_save_buttons()
    if not saved_list: return
    saved_status.text = "%d / 50 places saved locally" % app.exploration.bookmarks.size()
    ui._clear(saved_list)
    if app.exploration.bookmarks.is_empty(): ui.label(saved_list,"Choose a wonder, history marker or search result, then save it here.",12)
    for place in app.exploration.bookmarks:
        var entry: Button = ui.button(saved_list,place.name,func(): show_place(place))
        entry.tooltip_text = place.name
        var row := HFlowContainer.new()
        saved_list.add_child(row)
        action(row,"Remove",func(): app.exploration.toggle_save(place))
        action(row,"Weather",func(): show_place(place);request_selected_weather())
    ui.refresh_layout()

func build_weather(box: VBoxContainer) -> void:
    ui.label(box,"Weather where you're exploring",18)
    weather_target = ui.label(box,"",12)
    weather_refresh = action(box,"Request selected place weather",request_selected_weather)
    weather_units = CheckButton.new()
    weather_units.text = "Fahrenheit & mph"
    weather_units.button_pressed = app.preferences.get_value("weather","imperial",true)
    weather_units.toggled.connect(func(enabled: bool):
        app.preferences.set_value("weather","imperial",enabled)
        app._save_preferences()
        _weather_changed()
        if app.weather_layer: ui._weather_layer_changed())
    box.add_child(weather_units)
    weather_status = ui.label(box,"",12)
    weather_values = ui.label(box,"",14)
    ui.label(box,"Requests submit the selected coordinates to Open-Meteo. Weather loads only when you ask.",12)
    action(box,"Weather data source ↗",func(): OS.shell_open("https://open-meteo.com/"))
    app.observations.weather_changed.connect(_weather_changed)
    _location_changed()
    _weather_changed()

func request_selected_weather() -> void:
    if app.exploration.location.is_empty():
        select_section("Search")
        ui.open_page("Explore")
        return
    if ui.active_page != "Command Center": ui.open_page("Command Center")
    app.observations.request_weather(app.exploration.location)

func _location_changed() -> void:
    _update_save_buttons()
    if weather_target:
        weather_target.text = "Selected: " + str(app.exploration.location.get("name","choose a place in Explore"))
        weather_refresh.disabled = app.exploration.location.is_empty()

func _weather_changed() -> void:
    if not weather_status: return
    weather_status.text = app.observations.weather_status
    var weather: Dictionary = app.observations.weather
    if weather.is_empty():
        weather_values.text = "No weather values loaded."
    else:
        var imperial := weather_units.button_pressed
        weather_values.text = "%s\n%s · %.1f %s\nWind %.1f %s · humidity %.0f%%\nModel time: %s UTC\n%s" % [weather.name,app.observations.weather_name(weather.code),weather.temperature * 1.8 + 32.0 if imperial else weather.temperature,"°F" if imperial else "°C",weather.wind * 0.621371 if imperial else weather.wind,"mph" if imperial else "km/h",weather.humidity,weather.utc,app.observations.freshness()]
    ui.refresh_layout()


func _update_save_buttons() -> void:
    if feature_save:
        var saved: bool = app.exploration.is_saved(featured)
        feature_save.text = "Remove saved place" if saved else "Save this place"
        feature_save.disabled = featured.is_empty() or (not saved and app.exploration.bookmarks.size() >= 50)
    for control in bookmark_buttons:
        var saved: bool = app.exploration.is_saved(app.exploration.location)
        control.text = "Remove selected saved place" if saved else "Save selected place"
        control.disabled = app.exploration.location.is_empty() or (not saved and app.exploration.bookmarks.size() >= 50)
