extends ColorRect
const Data = preload("res://scripts/lunar_data.gd")
var ui: Control
var app: Node3D
var title: Label
var close_button: Button
var caption: Label
var view_button: Button
var disc: ColorRect
var info: PanelContainer
var scroll: ScrollContainer
var date_input: LineEdit
var date_status: Label
var details: Label
var calendar_title: Label
var month_previous: Button
var month_next: Button
var now_button: Button
var events_box: VBoxContainer
var israel_picker: OptionButton
var kind_picker: OptionButton
var material_lunar: ShaderMaterial
var stamp := 0.0
var selected_date := ""
var follow_now := true
var poll := 0.0
var events: Array = []

func setup(interface: Control) -> void:
    ui = interface
    app = ui.app
    color = Color("03070e")
    mouse_filter = Control.MOUSE_FILTER_STOP
    title = ui.label(self,"LUNAR OBSERVATORY",22)
    close_button = ui.button(self,"Back to Earth",close)
    disc = ColorRect.new()
    disc.mouse_filter = Control.MOUSE_FILTER_IGNORE
    material_lunar = ShaderMaterial.new()
    material_lunar.shader = load("res://shaders/lunar_disc.gdshader")
    material_lunar.set_shader_parameter("lunar_map",load("res://assets/earth/moon_4k.jpg"))
    disc.material = material_lunar
    add_child(disc)
    caption = ui.label(self,"NASA SVS / LRO · 4096px source map · lunar north up",12)
    info = PanelContainer.new()
    info.add_theme_stylebox_override("panel",ui.surface(Color("0d1723"),14,16))
    add_child(info)
    scroll = ScrollContainer.new()
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    info.add_child(scroll)
    var box := VBoxContainer.new()
    box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.add_child(box)
    date_status = ui.label(box,"",15)
    var row := HBoxContainer.new()
    box.add_child(row)
    ui.button(row,"− Day",shift_day.bind(-1)).size_flags_horizontal = Control.SIZE_EXPAND_FILL
    now_button = ui.button(row,"Now UTC",open_now)
    now_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    ui.button(row,"+ Day",shift_day.bind(1)).size_flags_horizontal = Control.SIZE_EXPAND_FILL
    var date_row := HBoxContainer.new()
    box.add_child(date_row)
    date_input = LineEdit.new()
    date_input.placeholder_text = "YYYY-MM-DD"
    date_input.max_length = 10
    date_input.custom_minimum_size = Vector2(130,36)
    date_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    date_input.text_submitted.connect(select_date)
    date_row.add_child(date_input)
    view_button = ui.button(date_row,"View date",func(): select_date(date_input.text))
    view_button.custom_minimum_size.x = 88
    view_button.clip_text = false
    details = ui.label(box,"",12)
    ui.label(box,"Moon & seasons · Hebrew calendar",18)
    calendar_title = ui.label(box,"",14)
    var month_row := HBoxContainer.new()
    box.add_child(month_row)
    month_previous = ui.button(month_row,"Previous month",shift_month.bind(-1))
    month_next = ui.button(month_row,"Next month",shift_month.bind(1))
    for control in month_row.get_children(): control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    israel_picker = OptionButton.new()
    israel_picker.add_item("Hebrew calendar · Diaspora")
    israel_picker.add_item("Hebrew calendar · Israel")
    israel_picker.item_selected.connect(func(_index: int): refresh_events())
    box.add_child(israel_picker)
    kind_picker = OptionButton.new()
    for text in ["All events", "Hebrew observances", "Lunar & solar events"]: kind_picker.add_item(text)
    kind_picker.item_selected.connect(func(_index: int): refresh_events())
    box.add_child(kind_picker)
    ui.label(box,"Traditional fixed Hebrew calendar · not a crescent-sighting calendar. Listed Hebrew dates begin at sunset the previous civil date. No local sunset, candle-lighting or festival-end times are calculated. Astronomical conjunction is distinct from a visible crescent or Rosh Chodesh.",12)
    events_box = VBoxContainer.new()
    box.add_child(events_box)
    ui.label(box,"Surface: NASA SVS / LRO · 4K source (2025 map). Hourly 2026 geometry: NASA SVS. Later disks: estimates between USNO phase events, not precision ephemerides. Calendar: Hebcal.com (CC BY 4.0), adapted to concise labels; event times: USNO. Different observance traditions may use different calendars.",12)
    ui.button(box,"Moon imagery & geometry · NASA ↗",func(): OS.shell_open("https://svs.gsfc.nasa.gov/4720/"))
    ui.button(box,"Hebrew calendar · Hebcal & license ↗",func(): OS.shell_open("https://www.hebcal.com/home/developer-apis"))
    ui.button(box,"Lunar & solar events · USNO ↗",func(): OS.shell_open("https://aa.usno.navy.mil/data/"))
    ui.button(box,"Data license · CC BY 4.0 ↗",func(): OS.shell_open("https://creativecommons.org/licenses/by/4.0/"))
    hide()

func open() -> void:
    if app.screensaver_mode: return
    ui.close_panel()
    ui.close_camera()
    ui.wall.close()
    ui.photo_viewer.close()
    show()
    open_now()
    relayout()

func close() -> void:
    hide()
    follow_now = false

func open_now() -> void:
    follow_now = true
    stamp = Time.get_unix_time_from_system()
    refresh()

func select_date(text: String) -> void:
    if not Data.valid_date(text):
        date_status.text = "Use a valid YYYY-MM-DD date from 2026–2030."
        return
    follow_now = false
    stamp = Time.get_unix_time_from_datetime_string(text+"T12:00:00")
    refresh()

func select_event(event: Dictionary) -> void:
    if not Data.valid_date(str(event.date)): return
    if event.has("time"):
        follow_now = false
        stamp = Time.get_unix_time_from_datetime_string(str(event.date)+"T"+str(event.time)+":00")
        refresh()
    else: select_date(str(event.date))

func shift_day(amount: int) -> void:
    var date := Time.get_date_string_from_unix_time(int(stamp)+amount*86400)
    if Data.valid_date(date): select_date(date)

func shift_month(amount: int) -> void:
    var date := Time.get_datetime_dict_from_unix_time(int(stamp))
    var index := int(date.year)*12+int(date.month)-1+amount
    var text := "%04d-%02d-01" % [index/12,index%12+1]
    if Data.valid_date(text): select_date(text)

func refresh() -> void:
    selected_date = Time.get_date_string_from_unix_time(int(stamp))
    date_input.text = selected_date
    var row := Data.sample(stamp)
    disc.visible = row.available
    date_status.text = "%s %s UTC · %s" % [selected_date,Time.get_time_string_from_unix_time(int(stamp)).substr(0,5),"CURRENT" if follow_now else "DATE PREVIEW"]
    if row.available:
        material_lunar.set_shader_parameter("lunar_sun",row.sun)
        material_lunar.set_shader_parameter("subearth_degrees",row.subearth)
        var distance := " · %s km" % String.num(row.distance,0) if float(row.distance)>0.0 else ""
        details.text = "%s · %.1f%% illuminated%s\n%s\n%s UTC\n%s" % [Data.phase_name(row),row.phase,distance,row.source,Time.get_datetime_string_from_unix_time(int(row.stamp)).replace("T"," "),row.note]
    else: details.text = str(row.source)+"\n"+str(row.note)
    refresh_events()

func refresh_events() -> void:
    if selected_date.is_empty(): return
    var date := Time.get_datetime_dict_from_unix_time(int(stamp))
    calendar_title.text = "%s %d · dates are civil calendar dates" % [Data.MONTHS[int(date.month)-1],date.year]
    month_previous.disabled = selected_date.begins_with("2026-01")
    month_next.disabled = selected_date.begins_with("2030-12")
    events = Data.events_for_month(date.year,date.month,israel_picker.selected==1,kind_picker.selected)
    ui._clear(events_box)
    for event in events:
        var entry: Button = ui.button(events_box,"%s · %s" % [event.date,event.title],select_event.bind(event))
        entry.alignment = HORIZONTAL_ALIGNMENT_LEFT
        entry.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        entry.tooltip_text = str(event.title)+"\n"+str(event.detail)
        ui.label(events_box,str(event.category)+" · "+str(event.detail),12)
    if events.is_empty(): ui.label(events_box,"No bundled events match this month and filter.",12)

func relayout() -> void:
    if not ui: return
    size = ui.size
    title.position = Vector2(24,22)
    title.size = Vector2(size.x-200,36)
    close_button.position = Vector2(size.x-164,18)
    close_button.size = Vector2(140,40)
    var width := clampf(size.x*0.42,350,430)
    info.position = Vector2(size.x-width-24,78)
    info.size = Vector2(width,size.y-102)
    var available := size.x-width-72
    var diameter := minf(available,size.y-140)
    disc.size = Vector2.ONE*diameter
    caption.position = Vector2(24,size.y-42)
    caption.size = Vector2(available,36)
    disc.position = Vector2(24+(available-diameter)/2.0,90+(size.y-140-diameter)/2.0)

func _process(delta: float) -> void:
    if not visible or not follow_now: return
    poll += delta
    if poll>=60.0:
        poll = 0.0
        stamp = Time.get_unix_time_from_system()
        refresh()
