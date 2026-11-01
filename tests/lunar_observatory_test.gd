extends SceneTree
const Data = preload("res://scripts/lunar_data.gd")
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("run")
func verify(ok: bool, message: String) -> void:
    checks += 1
    if not ok: failures += 1;push_error(message)
func run() -> void:
    for date in ["2026-01-01","2028-02-29","2030-12-31"]: verify(Data.valid_date(date),"Valid supported Gregorian date: "+date)
    for date in ["2026-02-29","2028-02-30","2026-13-01","2026-00-01","2026-11-31","2026-01-00","2026-1-01","2026-01-0x","2025-12-31","2031-01-01"]: verify(not Data.valid_date(date),"Invalid or uncovered date rejected: "+date)
    for month in range(1,13):
        var stamp := Time.get_unix_time_from_datetime_string("2026-%02d-15T12:37:00" % month)
        var row := Data.sample(stamp)
        verify(row.available and row.precise and int(row.stamp)%3600==0,"NASA sample uses preceding full UTC hour")
        verify(row.phase>=0 and row.phase<=100 and row.distance>350000 and row.distance<410000,"NASA phase/distance bounds")
        var observer := Data.vector(row.subearth.x,row.subearth.y)
        var fraction := 50.0*(1.0+observer.dot(row.sun))
        verify(absf(fraction-float(row.phase))<0.02,"Rendered terminator agrees with NASA illuminated fraction")
    var events := Data.load_phases()
    verify(events.size()==249,"Five complete USNO phase years plus final-date boundary retained")
    for index in range(1,events.size()):
        verify(events[index].stamp>events[index-1].stamp,"Chronological phase events")
    for date in ["2027-01-15","2028-02-29","2029-12-01","2030-06-15","2030-12-31"]:
        var row := Data.sample(Time.get_unix_time_from_datetime_string(date+"T12:00:00"))
        verify(row.available and not row.precise and row.source.contains("Estimated"),"Future disk does not pretend to be NASA ephemeris")
        verify(row.distance==0.0 and row.subearth==Vector2.ZERO,"Estimated disk does not invent distance or libration")
    verify(not Data.sample(Time.get_unix_time_from_datetime_string("2040-01-01T00:00:00")).available,"No stale extrapolation beyond bundled coverage")
    for year in range(2026,2031):
        for month in range(1,13):
            for israel in [false,true]:
                var entries := Data.events_for_month(year,month,israel)
                var valid := true
                for entry in entries: valid = valid and Data.valid_date(entry.date) and entry.source.begins_with("https://") and not entry.title.begins_with("Erev ")
                verify(valid,"Calendar entries retain valid dates/source and unambiguous full-day semantics")
    var september := Data.events_for_month(2026,9,false,1)
    var rosh := september.filter(func(x):return x.title=="Rosh Hashana 5787")
    verify(rosh.size()==1 and rosh[0].date=="2026-09-12" and rosh[0].detail.contains("sunset 2026-09-11"),"Rosh Hashana full civil date and preceding sunset are distinct")
    var december := Data.events_for_month(2026,12,false,2)
    var solstice := december.filter(func(x):return x.title=="December Solstice")
    verify(solstice.size()==1 and solstice[0].date=="2026-12-21" and solstice[0].detail.begins_with("20:50 UTC"),"December solstice retains source UTC date/time")
    var diaspora := Data.events_for_month(2027,6,false,1)
    var israel := Data.events_for_month(2027,6,true,1)
    verify(diaspora.filter(func(x):return x.title=="Shavuot II").size()==1 and israel.filter(func(x):return x.title=="Shavuot II").is_empty(),"Israel and Diaspora schemes differ without moving Gregorian dates")
    verify(Data.events_for_month(2026,8,false,1).filter(func(x):return x.title.contains("LaBehemot") and x.category=="Torah festival").is_empty(),"Cattle new-year observance is not misclassified as Feast of Trumpets")
    var app = load("res://scenes/earth.tscn").instantiate()
    app.play_intro = false
    app.preferences_path = "user://lunar-test-%d.cfg" % Time.get_ticks_usec()
    root.add_child(app)
    var ui = app.interface
    var viewer = ui.lunar_observatory
    var preferences: String = app.preferences.encode_to_text()
    verify(not viewer.visible,"No startup lunar overlay")
    ui.open_page("Journey studio")
    ui.journey_studio.preset(1)
    ui.journey_studio.play()
    viewer.open()
    verify(viewer.visible and not ui.journey_studio.active and not ui.journey_studio.playing,"Moon entry stops tour and clears paths")
    viewer.select_date("2026-11-01")
    var original: float = viewer.stamp
    verify(viewer.disc.visible and viewer.details.text.contains("NASA SVS") and viewer.date_status.text.contains("PREVIEW"),"Dated Moon identifies actual hourly source and preview")
    viewer.select_date("2026-02-30")
    verify(viewer.stamp==original and viewer.date_status.text.contains("valid"),"Malformed date preserves previous moon")
    viewer.shift_day(1)
    verify(viewer.selected_date=="2026-11-02","Day navigation advances safely")
    viewer.select_date("2026-12-31")
    viewer.shift_day(1)
    verify(viewer.selected_date=="2027-01-01" and viewer.details.text.contains("Estimated disk"),"Year boundary clearly switches from NASA to event interpolation")
    viewer.israel_picker.select(1)
    viewer.select_date("2027-06-11")
    verify(viewer.events.filter(func(x):return x.title=="Shavuot II").is_empty(),"Viewer scheme reaches actual event list")
    var quarter: Dictionary = Data.load_phases().filter(func(x):return x.date=="2026-01-26")[0]
    viewer.select_event(quarter)
    verify(viewer.date_status.text.contains("04:47") and absf(viewer.stamp-float(quarter.stamp))<1.0,"Astronomical event clicks preview the event instant rather than noon")
    verify(viewer.details.text.contains("quarter vicinity"),"Hourly sample near quarter event has the corresponding phase label")
    viewer.open_now()
    verify(viewer.follow_now and absf(viewer.stamp-Time.get_unix_time_from_system())<2.0,"Now restores current UTC")
    app.preview_screensaver()
    verify(not viewer.visible and not viewer.follow_now,"Screensaver never inherits Moon viewer or simulated date")
    app.stop_screensaver_preview()
    verify(app.preferences.encode_to_text()==preferences,"Moon calendar edits do not overwrite preferences")
    verify(app.satellite_snapshot.request==null and app.camera_service.request==null and app.services.search_request.get_http_client_status()==HTTPClient.STATUS_DISCONNECTED,"Moon/calendars are fully offline")
    app.set_visual_option("moon",true)
    app.visuals.advance(0.1)
    verify(app.visuals.moon.visible and app.visuals.moon_material.get_shader_parameter("lunar_map").get_width()==4096,"Optional backdrop uses real 4K map and current phase")
    viewer.close()
    DirAccess.remove_absolute(ProjectSettings.globalize_path(app.preferences_path))
    app.queue_free()
    await process_frame
    print("Lunar observatory: %d checks, %d failures" % [checks,failures])
    quit(1 if failures else 0)
