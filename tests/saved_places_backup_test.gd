extends SceneTree
const Backup=preload("res://scripts/saved_places_backup.gd")
var checks:=0
var failures:=0
func _initialize() -> void:call_deferred("run")
func verify(ok:bool,message:String) -> void:
    checks+=1
    if not ok:failures+=1;push_error(message)
func envelope(places:Variant) -> Dictionary:return {"product":Backup.PRODUCT,"schema":1,"places":places}
func bytes(value:Variant) -> PackedByteArray:return JSON.stringify(value).to_utf8_buffer()
func run() -> void:
    var app=load("res://scenes/earth.tscn").instantiate()
    app.play_intro=false
    app.preferences_path="user://backup-test-%d.cfg" % Time.get_ticks_usec()
    root.add_child(app)
    var place:Dictionary={"name":"São Paulo · saved test","latitude":-23.55,"longitude":-46.63,"note":"A local note, not a current observation.","source":"https://www.naturalearthdata.com/"}
    var path:="user://places-backup-test-%d.json" % Time.get_ticks_usec()
    var parsed:=Backup.decode(Backup.encode([place]))
    verify(parsed.ok and parsed.places.size()==1 and parsed.places[0].name==place.name and parsed.places[0].note==place.note,"Unicode saved names, coordinates and notes roundtrip")
    verify(Backup.decode(Backup.encode([])).ok,"Empty backup is valid and harmless")
    verify(Backup.write_backup(path,[place])==OK and Backup.read_backup(path).ok,"Chosen-file export flushes and imports exact data")
    verify(Backup.write_backup(path,[])==OK and Backup.read_backup(path).places.is_empty(),"Replacing an exported file uses complete new bytes")
    verify(Backup.write_backup("user://nonexistent-parent-xyz/backup.json",[place])!=OK,"Unwritable location returns an error")
    verify(not Backup.read_backup(path+".missing").ok,"Missing input is unavailable without changing saved places")
    verify(not Backup.decode("not json".to_utf8_buffer()).ok and not Backup.decode(PackedByteArray()).ok,"Malformed/empty JSON rejected")
    var huge:=PackedByteArray();huge.resize(Backup.MAX_BYTES+1)
    verify(not Backup.decode(huge).ok,"Input bytes are bounded before parsing")
    for field in ["product","schema","places"]:
        var missing:=envelope([place]);missing.erase(field)
        verify(not Backup.decode(bytes(missing)).ok,"Missing backup envelope field rejected: "+field)
    for schema in [true,"1",0,2]:
        var bad:=envelope([place]);bad.schema=schema
        verify(not Backup.decode(bytes(bad)).ok,"Unsupported or wrongly typed schema rejected")
    var foreign:=envelope([place]);foreign.product="OtherApp"
    verify(not Backup.decode(bytes(foreign)).ok,"Unrelated JSON cannot be treated as a saved backup")
    verify(not Backup.decode(bytes(envelope({}))).ok,"Places must be an array")
    for kind in ["latitude","longitude","name","note","source"]:
        var bad:=place.duplicate()
        match kind:
            "latitude":bad.latitude=91
            "longitude":bad.longitude="-46.63"
            "name":bad.name=" "
            "note":bad.note={"command":"ignored"}
            "source":bad.source=123
        verify(not Backup.decode(bytes(envelope([place,bad]))).ok,"One invalid row rejects the complete import: "+kind)
    var long_name:=place.duplicate();long_name.name="x".repeat(161)
    verify(not Backup.decode(bytes(envelope([long_name]))).ok,"Overlong names rejected instead of silently relabelled")
    var many:Array=[]
    for index in range(51):many.append(place)
    verify(not Backup.decode(bytes(envelope(many))).ok,"Input record count cannot exceed 50")
    var executable:=place.duplicate();executable.source="file:///not-an-allowed-source"
    verify(Backup.decode(bytes(envelope([executable]))).places[0].source.is_empty(),"Non-HTTPS source is removed and never executed")
    var control:=place.duplicate();control.name="Invisible\tname"
    verify(not Backup.decode(bytes(envelope([control]))).ok,"Control characters cannot become an invisible saved name")
    control=place.duplicate();control.source="https://example.com/\nnot-a-valid-url"
    verify(Backup.decode(bytes(envelope([control]))).places[0].source.is_empty(),"Control characters cannot survive in an imported source link")
    var old:Array=[place.duplicate(true)]
    var changed:=place.duplicate();changed.name="Overwrite attempt";changed.note="Different note"
    var another:=place.duplicate();another.name="Another place";another.latitude=0;another.longitude=0
    var merged:=Backup.merge(old,[changed,another,another])
    verify(merged.added==1 and merged.duplicates==2 and merged.places[0].name==place.name and merged.places[0].note==place.note,"Merge preserves existing place identity and skips duplicate coordinates")
    verify(old.size()==1,"Preview merge does not mutate existing array")
    var full:Array=[]
    for index in range(50):full.append({"name":"Place %d" % index,"latitude":index,"longitude":1,"note":"","source":""})
    var capped:=Backup.merge(full,[place])
    verify(capped.places.size()==50 and capped.capacity_skipped==1 and capped.added==0,"Full collection is retained without replacement")
    var panel=app.interface.exploration_panel
    app.exploration.toggle_save(place)
    panel.export_backup(path)
    app.exploration.toggle_save(another)
    panel.import_backup(path)
    verify(app.exploration.bookmarks.size()==2 and panel.backup_status.text.contains("duplicate"),"UI merge retains places saved since export")
    var before:=JSON.stringify(app.exploration.bookmarks)
    var invalid:=FileAccess.open(path,FileAccess.WRITE);invalid.store_string("{}");invalid.close()
    panel.import_backup(path)
    verify(JSON.stringify(app.exploration.bookmarks)==before and panel.backup_status.text.contains("unchanged"),"Failed file import is transactional")
    panel.prepare_backup_dialog(true)
    verify(panel.backup_dialog.use_native_dialog and panel.backup_dialog.file_mode==FileDialog.FILE_MODE_SAVE_FILE,"Export asks for a chosen file using supported native dialog")
    panel.prepare_backup_dialog(false)
    verify(panel.backup_dialog.file_mode==FileDialog.FILE_MODE_OPEN_FILE,"Import chooses an existing JSON file")
    app.preview_screensaver()
    verify(panel.backup_dialog==null,"Screensaver preview releases any backup chooser")
    app.stop_screensaver_preview()
    verify(app.services.search_request.get_http_client_status()==HTTPClient.STATUS_DISCONNECTED and app.observations.weather_request==null,"Backup never triggers public requests")
    for file in [path,app.preferences_path]:DirAccess.remove_absolute(ProjectSettings.globalize_path(file))
    app.queue_free();await process_frame
    print("Saved places backup: %d checks, %d failures" % [checks,failures])
    quit(1 if failures else 0)
