extends SceneTree
const Atlas=preload("res://scripts/offline_atlas.gd")
var checks:=0
var failures:=0
func _initialize() -> void:call_deferred("run")
func verify(ok:bool,message:String) -> void:
    checks+=1
    if not ok:failures+=1;push_error(message)
func run() -> void:
    var app=load("res://scenes/earth.tscn").instantiate()
    app.play_intro=false
    app.preferences_path="user://atlas-test-%d.cfg" % Time.get_ticks_usec()
    root.add_child(app)
    var ui=app.interface
    var cities:Array=JSON.parse_string(FileAccess.get_file_as_string("res://data/atlas_cities.json"))
    verify(cities.size()==243 and ui.atlas.size()>250,"243 sourced city points expand the original offline atlas")
    verify(cities.all(func(p):return app.services.valid_coordinates(float(p.latitude),float(p.longitude)) and p.id.begins_with("natural-earth-") and not p.note.is_empty()),"Every bundled city has valid geography, identity and context")
    var legacy:Array=JSON.parse_string(FileAccess.get_file_as_string("res://data/atlas.json"))
    verify(legacy.all(func(p):return ui.atlas.any(func(q):return p.name==q.name and p.latitude==q.latitude and p.longitude==q.longitude)),"Original atlas names and exact coordinates remain available")
    var ny:=Atlas.search("New York",ui.atlas)
    verify(ny.total==1 and ny.places[0].name=="New York, USA","Matching source city merges aliases without duplicating the original New York")
    verify(Atlas.search("Cairo",ui.atlas).total==1 and Atlas.search("Giza",ui.atlas).total==1,"Nearby city and heritage site remain distinct")
    var ca:=Atlas.search("CA",ui.atlas)
    verify(ca.total>=2 and ca.places.all(func(p):return p.country_code=="CA"),"Exact Canada code does not match Cairo or Cape Town")
    verify(Atlas.search("Sao Paulo",ui.atlas).places[0].name.begins_with("São Paulo"),"ASCII query finds sourced accented city name")
    verify(Atlas.search("  SÃO PAULO ",ui.atlas).places[0].name.begins_with("São Paulo"),"Accented mixed-case query normalizes locally")
    verify(Atlas.search("Turkey",ui.atlas).total==Atlas.search("Türkiye",ui.atlas).total and Atlas.search("Türkiye",ui.atlas).total>0,"Country aliases retain alternate spelling")
    var us:=Atlas.search("USA",ui.atlas)
    verify(us.total>8 and us.places.size()==8 and us.pages>1,"Large country query is bounded and paginated")
    var all_us:Array=[]
    for page in range(us.pages):
        var part:=Atlas.search("USA",ui.atlas,page)
        all_us.append_array(part.places)
    var unique:Dictionary={}
    for place in all_us:unique[place.name]=true
    verify(all_us.size()==us.total and unique.size()==us.total and all_us.all(func(p):return p.country_code=="US"),"Pagination exposes every country match once without crossing country codes")
    verify(Atlas.search("USA",ui.atlas,-99).page==0 and Atlas.search("USA",ui.atlas,999).page==us.pages-1,"Page bounds stay inside real results")
    verify(Atlas.search("",ui.atlas).total==0 and Atlas.search("no-such-reference-city-xyz",ui.atlas).pages==0,"Empty/no-match queries do not invent places")
    ui._search_offline("USA")
    verify(ui.offline_next.visible and not ui.offline_previous.visible and ui.search_results.get_child_count()==8,"First offline page offers the next real results")
    ui.offline_next.pressed.emit()
    verify(ui.offline_page==1 and ui.offline_previous.visible,"Next control advances local results")
    ui.offline_previous.pressed.emit()
    verify(ui.offline_page==0,"Previous control returns to first page")
    ui._search_offline("a")
    ui.offline_next.pressed.emit()
    verify(ui.offline_page==1 and ui.offline_previous.visible and ui.offline_next.visible and ui.offline_pager.visible,"Middle result page keeps both paging actions together")
    ui._search_offline("Vancouver")
    verify(ui.search_results.get_child_count()==1 and not ui.offline_next.visible,"New city query resets pagination")
    ui.search_results.get_child(0).pressed.emit()
    verify(app.exploration.location.name=="Vancouver, Canada" and app.exploration.location.note.contains("Natural Earth"),"Selected city opens its own geographically sourced destination")
    ui._search_offline("0, 0")
    verify(ui.search_results.get_child_count()==1 and not ui.offline_previous.visible and not ui.offline_pager.visible,"Coordinate search remains independent of city pages")
    ui._search_offline("91, 0")
    verify(ui.search_results.get_child_count()==0,"Out-of-range coordinates remain rejected")
    verify(app.services.search_request.get_http_client_status()==HTTPClient.STATUS_DISCONNECTED and app.services.results.is_empty(),"Offline queries and paging never start worldwide requests")
    DirAccess.remove_absolute(ProjectSettings.globalize_path(app.preferences_path))
    app.queue_free();await process_frame
    print("Offline atlas: %d checks, %d failures" % [checks,failures])
    quit(1 if failures else 0)
