extends ColorRect
const WallService = preload("res://scripts/camera_wall_service.gd")
const LAYOUTS := [1, 2, 4, 6, 9]
var app: Node3D
var sources: Array = []
var slots: Array = []
var slot_count := 4
var manager: Node
var frame: PanelContainer
var scroll: ScrollContainer
var grid: GridContainer
var layout_picker: OptionButton
var collection_picker: OptionButton
var collection_name: LineEdit
var note: Label
var tiles: Array = []
var collections: Dictionary = {}

func setup(owner_app: Node3D, cameras: Array) -> void:
    app = owner_app
    for venue in cameras:
        if venue.has("image_url"): sources.append(venue)
    slot_count = int(app.preferences.get_value("camera_wall", "layout", 4))
    if slot_count not in LAYOUTS: slot_count = 4
    var saved = app.preferences.get_value("camera_wall", "slots", [])
    for index in range(9):
        var fallback: String = sources[index].image_url if index < sources.size() else ""
        var url: String = str(saved[index]) if saved is Array and index < saved.size() else fallback
        slots.append(url if _source(url) != {} else "")
    var saved_collections = app.preferences.get_value("camera_wall", "collections", {})
    if saved_collections is Dictionary: collections = saved_collections
    color = Color(0.002, 0.008, 0.02, 0.96)
    mouse_filter = Control.MOUSE_FILTER_STOP
    manager = WallService.new()
    add_child(manager)
    manager.changed.connect(_changed)
    frame = PanelContainer.new()
    frame.add_theme_stylebox_override("panel", app.interface.surface(Color("0e2030"), 18, 16))
    add_child(frame)
    var box := VBoxContainer.new()
    frame.add_child(box)
    var heading := HBoxContainer.new()
    box.add_child(heading)
    app.interface.label(heading, "CAMERA WALL", 20)
    _button(heading, "Close", close)
    var controls := HFlowContainer.new()
    box.add_child(controls)
    layout_picker = OptionButton.new()
    for count in LAYOUTS: layout_picker.add_item("%d view%s" % [count, "" if count == 1 else "s"])
    layout_picker.select(LAYOUTS.find(slot_count))
    layout_picker.item_selected.connect(func(index: int):
        slot_count = LAYOUTS[index]
        _save()
        _rebuild())
    controls.add_child(layout_picker)
    _button(controls, "Refresh images", manager.request_refresh)
    var auto := CheckButton.new()
    auto.text = "Auto refresh"
    auto.button_pressed = true
    auto.toggled.connect(manager.set_automatic)
    controls.add_child(auto)
    var saved_row := HFlowContainer.new()
    box.add_child(saved_row)
    collection_picker = OptionButton.new()
    collection_picker.custom_minimum_size.x = 160
    collection_picker.item_selected.connect(_load_collection)
    saved_row.add_child(collection_picker)
    collection_name = LineEdit.new()
    collection_name.placeholder_text = "Collection name"
    collection_name.max_length = 32
    collection_name.custom_minimum_size.x = 170
    saved_row.add_child(collection_name)
    _button(saved_row, "Save collection", save_collection)
    note = app.interface.label(box, "Periodic images, not video · three available sources · repeated tiles share a download · at most two downloads at once", 12)
    scroll = ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    box.add_child(scroll)
    grid = GridContainer.new()
    grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.add_child(grid)
    _collection_choices()
    _rebuild(false)
    hide()

func _source(url: String) -> Dictionary:
    for source in sources:
        if source.image_url == url: return source
    return {}

func _venues() -> Array:
    var result: Array = []
    for index in range(slot_count):
        var source := _source(slots[index])
        if not source.is_empty(): result.append(source)
    return result

func open() -> void:
    app.interface.close_camera()
    show()
    manager.suspended = false
    manager.configure(_venues())
    relayout()

func close() -> void:
    hide()
    manager.close()

func _save() -> void:
    app.preferences.set_value("camera_wall", "layout", slot_count)
    app.preferences.set_value("camera_wall", "slots", slots)
    app.preferences.set_value("camera_wall", "collections", collections)
    app._save_preferences()

func _rebuild(fetch := true) -> void:
    layout_picker.select(LAYOUTS.find(slot_count))
    for child in grid.get_children():
        grid.remove_child(child)
        child.queue_free()
    tiles.clear()
    for index in range(slot_count):
        var tile := PanelContainer.new()
        tile.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        tile.custom_minimum_size.y = 220
        tile.add_theme_stylebox_override("panel", app.interface.surface(Color("142c3c"), 10, 10))
        grid.add_child(tile)
        var box := VBoxContainer.new()
        tile.add_child(box)
        var picker := OptionButton.new()
        picker.clip_text = true
        picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        picker.add_item("Choose image camera…")
        for source in sources: picker.add_item(source.name)
        var selected := 0
        for choice in range(sources.size()):
            if sources[choice].image_url == slots[index]: selected = choice + 1
        picker.select(selected)
        picker.item_selected.connect(func(choice: int):
            slots[index] = sources[choice - 1].image_url if choice > 0 else ""
            _save()
            manager.configure(_venues())
            _changed())
        box.add_child(picker)
        var image := TextureRect.new()
        image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        image.custom_minimum_size.y = 100
        image.size_flags_vertical = Control.SIZE_EXPAND_FILL
        box.add_child(image)
        var detail: Label = app.interface.label(box, "Choose a camera above.", 12)
        var focus: Button = app.interface.button(box, "Focus view", func():
            var source := _source(slots[index])
            if source.is_empty(): return
            manager.set_suspended(true)
            app.interface.select_camera(source))
        tiles.append({"tile":tile, "image":image, "detail":detail, "focus":focus})
    if fetch and visible: manager.configure(_venues())
    _changed()
    relayout()

func _changed() -> void:
    for index in range(tiles.size()):
        var tile: Dictionary = tiles[index]
        var url: String = slots[index]
        var service = manager.services.get(url)
        tile.image.texture = service.image if service else null
        tile.detail.text = service.status.get_slice("\n", 0) if service else "Choose a camera above."
        tile.detail.tooltip_text = (service.status + "\n" + service.selected.get("provider", "")) if service else ""
        tile.focus.disabled = _source(url).is_empty()

func relayout() -> void:
    if not frame or not grid: return
    size = get_parent().size
    frame.position = Vector2(24, 24)
    frame.size = size - Vector2(48, 48)
    var columns := 1
    if slot_count > 1 and size.x >= 900: columns = 2
    if slot_count >= 6 and size.x >= 1300: columns = 3
    grid.columns = columns
    var width := maxf(220.0, (frame.size.x - 60.0) / columns - 12.0)
    for tile in tiles: tile.tile.custom_minimum_size.x = width

func _collection_choices() -> void:
    collection_picker.clear()
    collection_picker.add_item("Saved collections")
    for title in collections.keys().slice(0, 8): collection_picker.add_item(str(title))

func save_collection() -> void:
    var title := collection_name.text.strip_edges()
    if title.is_empty():
        note.text = "Enter a collection name first."
        return
    if title not in collections and collections.size() >= 8:
        note.text = "Eight collections saved. Reuse a name to replace that collection."
        return
    collections[title] = {"layout":slot_count, "slots":slots.duplicate()}
    _save()
    _collection_choices()
    note.text = "Saved “%s” locally. Camera images are fetched only while the wall is open." % title

func _load_collection(index: int) -> void:
    if index <= 0: return
    var title := collection_picker.get_item_text(index)
    var saved = collections.get(title)
    if not saved is Dictionary or int(saved.get("layout", 0)) not in LAYOUTS or not saved.get("slots") is Array: return
    slot_count = int(saved.layout)
    for slot in range(9):
        var url := str(saved.slots[slot]) if slot < saved.slots.size() else ""
        slots[slot] = url if not _source(url).is_empty() else ""
    collection_name.text = title
    layout_picker.select(LAYOUTS.find(slot_count))
    _save()
    _rebuild()


func _button(parent: Node, title: String, callback: Callable) -> Button:
    var result: Button = app.interface.button(parent, title, callback)
    result.clip_text = false
    return result

func _process(_delta: float) -> void:
    if not visible or not scroll or not manager.active: return
    var visible_urls: Array = []
    for index in range(tiles.size()):
        if scroll.get_global_rect().intersects(tiles[index].tile.get_global_rect()):
            visible_urls.append(slots[index])
    manager.set_visible_urls(visible_urls)
