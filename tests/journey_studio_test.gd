extends SceneTree
const Geometry = preload("res://scripts/journey_geometry.gd")
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("run")
func verify(ok: bool, message: String) -> void:
    checks += 1
    if not ok: failures += 1; push_error(message)
func run() -> void:
    var origin := {"name":"Origin","latitude":0.0,"longitude":0.0}
    var quarter := {"name":"Quarter","latitude":0.0,"longitude":90.0}
    verify(absf(Geometry.distance(origin,quarter)-PI*Geometry.RADIUS_KM/2.0)<0.0001,"Analytic quarter circumference")
    for pair in [[origin,origin],[origin,quarter],[origin,{"latitude":0.0,"longitude":180.0}],[{"latitude":90.0,"longitude":0.0},{"latitude":-90.0,"longitude":0.0}],[{"latitude":10.0,"longitude":179.9},{"latitude":10.0,"longitude":-179.9}]]:
        var points := Geometry.arc(pair[0],pair[1])
        verify(points.size()==65,"Bounded arc geometry")
        verify(points[0].distance_to(Geometry.direction(pair[0])*1.018)<0.00001 and points[-1].distance_to(Geometry.direction(pair[1])*1.018)<0.00001,"Both arc endpoints match globe coordinates")
        verify(absf(Geometry.distance(pair[0],pair[1])-Geometry.distance(pair[1],pair[0]))<0.00001,"Distance is symmetric")
        var finite := true
        for point in points:
            finite = finite and point.is_finite() and point.length()>=1.0179 and point.length()<=1.0631
        verify(finite,"Coincident, antipodal, polar and date-line paths stay finite and above Earth")
    verify(Geometry.distance({"latitude":0.0,"longitude":179.9},{"latitude":0.0,"longitude":-179.9})<23.0,"Date-line connection takes the short path")
    var app = load("res://scenes/earth.tscn").instantiate()
    app.play_intro = false
    app.preferences_path = "user://journey-studio-%d.cfg" % Time.get_ticks_usec()
    root.add_child(app)
    var ui = app.interface
    var studio = ui.journey_studio
    verify(not studio.active and not studio.playing and not studio.marker_root.visible,"No startup tour or visible routes")
    var prefs_before: String = app.preferences.encode_to_text()
    ui.open_page("Journey studio")
    verify(studio.active and not studio.playing,"Opening is opt-in editing, not autoplay")
    verify(not studio.add_place({}) and not studio.add_place({"name":"Bad","latitude":NAN,"longitude":0.0}),"Invalid locations rejected")
    verify(studio.add_place(origin) and not studio.add_place(origin),"Duplicates rejected without replacing first stop")
    studio.clear()
    verify(studio.add_place({"name":"Date line A","latitude":0.0,"longitude":180.0}) and not studio.add_place({"name":"Date line B","latitude":0.0,"longitude":-179.999999}),"Sub-meter date-line duplicates cannot create an empty arc surface")
    studio.preset(1)
    verify(studio.stops.size()==4 and studio.stops[0].name.contains("Los Angeles") and studio.stops[-1].name.contains("Manila"),"Pacific starter resolves four offline cities")
    verify(studio.marker_root.visible and studio.marker_root.get_child_count()==5,"One bounded path mesh plus four pins")
    verify(studio.summary.text.contains("km") and studio.summary.text.contains("mi"),"Approximate distance uses both units")
    var first: Dictionary = studio.stops[0].duplicate()
    studio.move_stop(0,1)
    verify(studio.stops[1]==first,"Route reordering preserves location")
    studio.remove_stop(0)
    verify(studio.stops.size()==3,"Remove updates bounded route")
    studio.search("Tokyo")
    verify(studio.matches.size()>0 and studio.matches[0].name.contains("Tokyo"),"Offline city picker resolves")
    studio.search("no-matching-city-zzzz")
    verify(studio.matches.is_empty() and studio.add_button.disabled,"Empty matches cannot add a stale selection")
    studio.clear()
    for index in range(8): verify(studio.add_place({"name":"Stop %d" % index,"latitude":float(index),"longitude":float(index)}),"Accept stop within capacity")
    verify(not studio.add_place({"name":"Ninth","latitude":20.0,"longitude":20.0}) and studio.stops.size()==8,"Eight-stop resource bound")
    verify(studio.marker_root.get_child_count()==9,"Maximum eight pins plus one path mesh")
    app.discovery_enabled = true
    studio.play()
    verify(studio.playing and not app.discovery_enabled and app.exploration.location.name==studio.stops[0].name,"Play suppresses competing timed discovery and visits first stop")
    studio.owned_tween.custom_step(3.0)
    verify(studio.arrived,"Actual tween arrival is distinguished from interruption")
    studio.remaining = 0.1
    studio.tick(0.2)
    verify(studio.current==1 and studio.playing,"Timer advances exactly one stop")
    studio.tick(600.0)
    verify(studio.current==1 and studio.remaining>11.0,"Suspend-sized delta cannot skip through a route")
    app._zoom(0.2)
    studio.tick(0.01)
    verify(not studio.playing and app.discovery_enabled,"Manual zoom pauses and restores discovery preference")
    studio.play()
    studio.move_stop(0,1)
    verify(not studio.playing and app.discovery_enabled,"Editing stops playback safely")
    studio.play()
    ui.close_panel()
    verify(not studio.playing and not studio.active and not studio.marker_root.visible and app.discovery_enabled,"Close stops owned motion, removes paths and restores discovery")
    ui.open_page("Journey studio")
    studio.play()
    ui.open_page("Live Earth")
    verify(not studio.active and not studio.playing and not studio.marker_root.visible,"Navigation clears playback and overlays")
    ui.open_page("Journey studio")
    studio.play()
    app.preview_screensaver()
    verify(not studio.active and not studio.playing and not studio.marker_root.visible,"Saver preview cannot inherit tour motion or paths")
    app.stop_screensaver_preview()
    ui.open_page("Journey studio")
    studio.current = studio.stops.size()-1
    studio.play()
    studio.next()
    verify(not studio.playing and studio.current==0 and studio.notice.contains("complete"),"Last stop ends instead of looping forever")
    verify(app.preferences.encode_to_text()==prefs_before,"Route editing/playback writes no preferences")
    verify(app.services.search_request.get_http_client_status()==HTTPClient.STATUS_DISCONNECTED and app.satellite_snapshot.request==null and app.camera_service.request==null,"Tours never start provider requests")
    ui.close_panel()
    DirAccess.remove_absolute(ProjectSettings.globalize_path(app.preferences_path))
    app.queue_free()
    await process_frame
    print("Journey studio: %d checks, %d failures" % [checks,failures])
    quit(1 if failures else 0)
