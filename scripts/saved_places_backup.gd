extends RefCounted
## Explicit local file exchange. No network, automatic import or executable content.
const Exploration=preload("res://scripts/exploration_data.gd")
const MAX_BYTES:=1048576
const MAX_PLACES:=50
const PRODUCT:="LivingEarth3D-saved-places"

static func encode(places:Array) -> PackedByteArray:
    var clean:Array=[]
    for place in places.slice(0,MAX_PLACES):
        var item:=Exploration.sanitize(place)
        if not item.is_empty():clean.append(item)
    return (JSON.stringify({"product":PRODUCT,"schema":1,"exported_utc":Time.get_datetime_string_from_system(true)+"Z","places":clean},"  ")+"\n").to_utf8_buffer()

static func decode(bytes:PackedByteArray) -> Dictionary:
    if bytes.is_empty() or bytes.size()>MAX_BYTES:return {"ok":false}
    var text:=bytes.get_string_from_utf8()
    if text.to_utf8_buffer()!=bytes:return {"ok":false}
    var parser:=JSON.new()
    if parser.parse(text)!=OK:return {"ok":false}
    var value=parser.data
    if not value is Dictionary or value.get("product")!=PRODUCT or not (value.get("schema") is float or value.get("schema") is int) or value.schema!=1 or not value.get("places") is Array or value.places.size()>MAX_PLACES:return {"ok":false}
    var places:Array=[]
    for place in value.places:
        if not place is Dictionary or not place.get("name") is String or place.name.strip_edges().is_empty() or place.name.length()>160:return {"ok":false}
        for character in place.name:
            if character.unicode_at(0)<32 or character.unicode_at(0) in [127,65533]:return {"ok":false}
        for field in ["note","source"]:
            if place.has(field) and (not place[field] is String or place[field].length()>(1200 if field=="note" else 500)):return {"ok":false}
        var clean:=Exploration.sanitize(place)
        if clean.is_empty():return {"ok":false}
        places.append(clean)
    return {"ok":true,"places":places}

static func read_backup(path:String) -> Dictionary:
    var file:=FileAccess.open(path,FileAccess.READ)
    if file==null:return {"ok":false}
    if file.get_length()>MAX_BYTES:file.close();return {"ok":false}
    var bytes:=file.get_buffer(MAX_BYTES+1)
    file.close()
    return decode(bytes)

static func write_backup(path:String,places:Array) -> Error:
    var bytes:=encode(places)
    if bytes.size()>MAX_BYTES:return ERR_INVALID_DATA
    var temporary:=path+".earth-partial-%d" % Time.get_ticks_usec()
    var file:=FileAccess.open(temporary,FileAccess.WRITE)
    if file==null:return FileAccess.get_open_error()
    file.store_buffer(bytes);file.flush()
    var error:=file.get_error()
    file.close()
    if error==OK:error=DirAccess.rename_absolute(temporary,path)
    if error!=OK:DirAccess.remove_absolute(temporary)
    return error

static func merge(existing:Array,incoming:Array) -> Dictionary:
    var places:=existing.duplicate(true)
    var keys:Dictionary={}
    for place in places:keys[Exploration.key(place)]=true
    var added:=0
    var duplicates:=0
    var full:=0
    for place in incoming:
        var key:=Exploration.key(place)
        if keys.has(key):duplicates+=1;continue
        if places.size()>=MAX_PLACES:full+=1;continue
        keys[key]=true
        places.append(place.duplicate(true));added+=1
    return {"places":places,"added":added,"duplicates":duplicates,"capacity_skipped":full}
