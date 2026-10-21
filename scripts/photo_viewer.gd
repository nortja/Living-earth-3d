extends ColorRect
var app: Node3D
var frame: PanelContainer
var image: TextureRect
var title: Label
var credit: Label
var selected: Dictionary = {}
var source_button: Button
var license_button: Button
func setup(owner_app: Node3D) -> void:
    app = owner_app
    color = Color(0.002,0.008,0.02,0.90)
    mouse_filter = Control.MOUSE_FILTER_STOP
    frame = PanelContainer.new()
    frame.add_theme_stylebox_override("panel",app.interface.surface(Color("0e2030"),18,20))
    add_child(frame)
    var box := VBoxContainer.new()
    frame.add_child(box)
    var row := HBoxContainer.new()
    box.add_child(row)
    title = app.interface.label(row,"Photograph",20)
    app.interface.button(row,"Close",close).clip_text = false
    image = TextureRect.new()
    image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    image.size_flags_vertical = Control.SIZE_EXPAND_FILL
    image.custom_minimum_size.y = 160
    box.add_child(image)
    credit = app.interface.label(box,"",12)
    var links := HFlowContainer.new()
    box.add_child(links)
    source_button = app.interface.button(links,"Photo source ↗",func():
        if not selected.is_empty(): OS.shell_open(selected.source))
    source_button.clip_text = false
    license_button = app.interface.button(links,"License ↗",func():
        if not selected.is_empty(): OS.shell_open(selected.license_url))
    license_button.clip_text = false
    hide()
func open(photo: Dictionary, place_name: String) -> bool:
    if app.screensaver_mode: return false
    var path := str(photo.get("image",""))
    if not path.begins_with("res://assets/discoveries/") or not path.ends_with(".jpg") or not ResourceLoader.exists(path): return false
    selected = photo.duplicate(true)
    title.text = place_name
    image.texture = load(path)
    credit.text = "Photo: %s · %s\nResized for this app; original photo and license linked below.\nPhotograph · not live and not an ancient reconstruction." % [photo.author,photo.license]
    show()
    relayout()
    app.interface.refresh_layout()
    return true
func close() -> void:
    hide()
    image.texture = null
    selected = {}
func relayout() -> void:
    size = app.interface.size
    frame.size = Vector2(minf(1040,size.x-48),minf(800,size.y-100))
    frame.position = (size-frame.size)/2.0
