extends Node
signal location_changed
signal bookmarks_changed
const Catalog = preload("res://scripts/discovery_catalog.gd")
const Data = preload("res://scripts/earth_services.gd")
var catalog = Catalog.new()
var app: Node3D
var location: Dictionary = {}
var bookmarks: Array = []

func setup(owner_app: Node3D) -> void:
    app = owner_app
    var saved = app.preferences.get_value("places", "bookmarks", [])
    if saved is Array:
        for place in saved.slice(0, 50):
            var clean := sanitize(place)
            if not clean.is_empty() and not is_saved(clean): bookmarks.append(clean)

static func sanitize(place: Variant) -> Dictionary:
    if not place is Dictionary or not Data.valid_coordinates(place.get("latitude"),place.get("longitude")): return {}
    var name := str(place.get("name", "Location")).strip_edges().left(160)
    if name.is_empty(): return {}
    var source := str(place.get("source", ""))
    if not source.begins_with("https://"): source = ""
    return {"name":name,"latitude":float(place.latitude),"longitude":float(place.longitude),"note":str(place.get("note",place.get("fact",""))).left(1200),"source":source.left(500)}

static func key(place: Dictionary) -> String:
    return "%.4f,%.4f" % [place.latitude,place.longitude]

func set_location(place: Dictionary) -> void:
    var clean := sanitize(place)
    if clean.is_empty(): return
    if location.is_empty() or key(clean) != key(location):
        if app.observations: app.observations.cancel_weather()
    location = clean
    location_changed.emit()

func is_saved(place: Dictionary) -> bool:
    if place.is_empty(): return false
    for item in bookmarks:
        if key(item) == key(place): return true
    return false

func toggle_save(place: Dictionary) -> void:
    var clean := sanitize(place)
    if clean.is_empty(): return
    var wanted := key(clean)
    for index in range(bookmarks.size()):
        if key(bookmarks[index]) == wanted:
            bookmarks.remove_at(index)
            _save()
            return
    if bookmarks.size() < 50:
        bookmarks.append(clean)
        _save()

func _save() -> void:
    app.preferences.set_value("places", "bookmarks", bookmarks)
    app._save_preferences()
    bookmarks_changed.emit()
