extends RefCounted
## Immutable, bundled photographs with per-file attribution; never a live camera.
static func lookup(place: Dictionary) -> Dictionary:
    var catalog: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/discoveries.json"))
    var photos: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/discovery_photos.json"))
    for candidate in catalog:
        var same_id: bool = not str(place.get("id", "")).is_empty() and place.get("id") == candidate.id
        var close: bool = absf(float(place.get("latitude",999.0))-float(candidate.latitude)) < 0.1 and absf(float(place.get("longitude",999.0))-float(candidate.longitude)) < 0.1
        var same_context: bool = place.get("name") == candidate.name or (not str(place.get("source", "")).is_empty() and place.get("source") == candidate.source)
        if close and (same_id or same_context):
            var photo: Dictionary = photos.get(candidate.id,{})
            if photo.get("image", "").begins_with("res://assets/discoveries/") and str(photo.get("image", "")).ends_with(".jpg") and ResourceLoader.exists(photo.image): return photo
    return {}
