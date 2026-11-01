extends RefCounted
## A temporary offline lighting preview. No preferences, network or clock writes.
const Solar = preload("res://scripts/solar_position.gd")
var ui: Control
var app: Node3D
var active := false
var anchor_time := 0.0
var restore_satellite := false
var place: Dictionary = {}
var clock: Label
var phase: Label
var slider: HSlider
var now_button: Button
var finish_button: Button

func setup(interface: Control, box: VBoxContainer) -> void:
    ui = interface
    app = ui.app
    clock = ui.label(box,"",14)
    slider = HSlider.new()
    slider.min_value = -12.0
    slider.max_value = 12.0
    slider.step = 0.25
    slider.custom_minimum_size = Vector2(200,32)
    slider.tooltip_text = "Preview twelve hours before or after opening, in fifteen-minute steps"
    slider.value_changed.connect(func(_value: float): refresh())
    box.add_child(slider)
    var row := HBoxContainer.new()
    box.add_child(row)
    now_button = ui.button(row,"Now",reset_now)
    finish_button = ui.button(row,"Finish preview",ui.close_panel)
    now_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    finish_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    phase = ui.label(box,"",16)
    ui.label(box,"Offline sunlight simulation · UTC, not local time. Approximate geometric Sun height; terrain, refraction and weather are excluded. Close to restore your previous view.",12)
    ui.button(box,"Calculation source · NOAA ↗",func(): OS.shell_open("https://gml.noaa.gov/grad/solcalc/solareqns.PDF"))

func begin() -> void:
    if app.screensaver_mode: return
    if active: end()
    place = app.exploration.location.duplicate(true)
    if place.is_empty(): place = {"name":"Equator / Greenwich reference","latitude":0.0,"longitude":0.0}
    restore_satellite = app.satellite_snapshot.enabled
    app.satellite_snapshot.set_enabled(false)
    active = true
    reset_now()

func reset_now() -> void:
    if not active: return
    anchor_time = Time.get_unix_time_from_system()
    slider.set_value_no_signal(0.0)
    refresh()

func refresh() -> void:
    if not active or app.screensaver_mode: return
    var stamp := anchor_time + slider.value * 3600.0
    var altitude := Solar.elevation(float(place.latitude),float(place.longitude),stamp)
    clock.text = "%s UTC · SIMULATION\n%+.2f hours from preview start" % [Time.get_datetime_string_from_unix_time(int(stamp)).replace("T"," "),slider.value]
    phase.text = "%s · %s\nSun height: %.1f°" % [str(place.name),Solar.light_phase(altitude),altitude]
    app.sunlight_preview_time = stamp
    app.sunlight_preview_active = true
    app.solar_sample_ticks = -60000
    app.update_sunlight()
    ui.refresh_layout()

func end() -> void:
    if not active: return
    active = false
    app.sunlight_preview_active = false
    app.solar_sample_ticks = -60000
    app.update_sunlight()
    if restore_satellite: app.satellite_snapshot.set_enabled(true)
    restore_satellite = false
