extends SceneTree
var failures := 0
func _initialize() -> void: call_deferred("run")
func verify(ok: bool, message: String) -> void:
    if not ok: failures += 1;push_error(message)
func run() -> void:
    for year in range(2026,2031):
        for scheme in ["israel","diaspora"]:
            var path := "res://data/calendar/hebrew-%d-%s.json" % [year,scheme]
            verify(FileAccess.file_exists(path) and JSON.parse_string(FileAccess.get_file_as_string(path)) is Dictionary,"Pack contains Hebrew calendar "+path)
        for kind in ["phases","seasons"]:
            var path := "res://data/calendar/usno-%s%d.json" % [kind,year]
            verify(FileAccess.file_exists(path) and JSON.parse_string(FileAccess.get_file_as_string(path)) is Dictionary,"Pack contains event data "+path)
    verify(FileAccess.file_exists("res://data/moon/nasa-2026.json"),"Pack contains NASA ephemeris")
    var app = load("res://scenes/earth.tscn").instantiate()
    app.play_intro = false
    app.preferences_path = "user://pack-validation-%d.cfg" % Time.get_ticks_usec()
    root.add_child(app)
    verify(app.observed_weather != null and load("res://assets/weather/infrared-legend.svg").get_width()>0 and FileAccess.file_exists("res://assets/weather/infrared-colormap.xml"),"Pack contains regional infrared service, readable legend and original numeric color map")
    app.space_studio.set_enabled(true,false)
    verify(app.space_studio.material.panorama.get_width()==4096 and load("res://assets/space/milkyway_2k.jpg").get_width()==2048,"Packed 4K/2K galaxy and shader resolve")
    app.space_studio.set_enabled(false,false)
    verify(app.scene_library != null and app.scene_library.valid(app.scene_library.snapshot("Packed view")),"Packed Scene Library module and composition schema resolve")
    var viewer = app.interface.lunar_observatory
    viewer.open()
    viewer.select_date("2026-11-01")
    verify(viewer.disc.visible and viewer.details.text.contains("NASA SVS") and viewer.material_lunar.get_shader_parameter("lunar_map").get_width()==4096,"Packed Moon surface, shader and actual geometry resolve")
    viewer.select_date("2030-12-31")
    verify(viewer.disc.visible and viewer.details.text.contains("Estimated"),"Packed final supported date has bracketing events")
    viewer.close()
    app.interface.open_page("Journey studio")
    app.interface.journey_studio.preset(1)
    verify(app.interface.journey_studio.stops.size()==4,"Packed journey atlas resolves")
    DirAccess.remove_absolute(ProjectSettings.globalize_path(app.preferences_path))
    app.queue_free()
    await process_frame
    print("Packaged resource smoke: %d failures" % failures)
    quit(1 if failures else 0)
