extends SceneTree
const Library = preload("res://scripts/scene_library.gd")
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("run")
func verify(ok: bool, message: String) -> void:
    checks+=1
    if not ok: failures+=1;push_error(message)
func run() -> void:
    var app = load("res://scenes/earth.tscn").instantiate()
    app.play_intro=false;app.preferences_path="user://scene-test-%d.cfg" % Time.get_ticks_usec()
    root.add_child(app)
    var lib=app.scene_library
    verify(lib.scenes.is_empty() and lib.interval==30,"Fresh library is empty with bounded default interval")
    var row: Dictionary=lib.snapshot("Pacific companion")
    verify(Library.valid(row),"Exact current composition is a valid profile")
    verify(Library.valid(lib.snapshot("A\tname\nwith controls")),"Pasted name control characters are sanitized before saving")
    for key in ["yaw","pitch","distance","earth","brightness","orientation"]:
        var invalid=row.duplicate(true);invalid[key]=NAN
        verify(not Library.valid(invalid),"Nonfinite profile settings rejected")
    for changes in [{"distance":0},{"pitch":2},{"brightness":12},{"orientation":-1},{"id":"../escape"},{"moon":1},{"name":""},{"name":"a\nb"},{"extra":"field"}]:
        var invalid=row.duplicate(true);invalid.merge(changes,true)
        verify(not Library.valid(invalid),"Malformed profile never affects the scene")
    lib.scenes.append(row)
    var second: Dictionary=row.duplicate(true);second.id="0123456789abcdef";second.name="Distant galaxy";second.distance=7.5;second.moon=true;second.galaxy=true;second.sunlight=true
    lib.scenes.append(second)
    verify(lib.persist(),"Bounded compositions persist locally")
    var before: String=app.preferences.encode_to_text()
    lib.use_scene(1,false)
    verify(app.distance==7.5 and app.visuals.moon_enabled and app.space_studio.enabled and app.utc_sunlight,"Scene applies actual camera, Moon, sky and current sunlight")
    verify(app.interface.sunlight_toggle.button_pressed and app.space_studio.moon_toggle.button_pressed,"Visible controls reflect temporary scene choices")
    verify(app.preferences.encode_to_text()==before,"Temporary playback choices do not overwrite saved defaults")
    app.discovery_enabled=true;app.elapsed=11.0
    lib.play()
    verify(lib.playing,"Explicit playback starts without fetching a provider")
    verify(not app.discovery_enabled,"Scene playback suspends the competing automatic discovery timer")
    lib.next_scene();lib.pause()
    verify(not lib.playing and is_equal_approx(app.intro_reveal,1.0),"Interruption cancels fade and restores scene brightness")
    verify(app.discovery_enabled and app.elapsed==0.0,"Pause restores the previous discovery choice with a fresh timer")
    app.discovery_enabled=false
    var retained_scene: int=lib.current
    lib.next_scene()
    app.space_studio.dialog=FileDialog.new()
    app.add_child(app.space_studio.dialog)
    app.space_studio.dialog.show()
    lib._process(0.1)
    verify(not is_instance_valid(lib.transition) and is_equal_approx(app.intro_reveal,1.0),"A modal cancels manual Next even when timed playback is stopped")
    await create_timer(1.0).timeout
    verify(lib.current==retained_scene,"Cancelled manual transition never applies its delayed scene callback")
    app.space_studio.dialog.hide()
    lib.play();app._zoom(0.2)
    verify(not lib.playing,"Manual zoom interrupts cinematic playback")
    lib.play();app.interface.open_page("Space studio")
    verify(not lib.playing,"Other pages stop playback")
    lib.play();app.preview_screensaver()
    verify(not lib.playing and not app.interface_layer.visible,"Screensaver entry stops desktop sequence")
    app.stop_screensaver_preview()
    lib.set_interval(0);verify(lib.interval==30,"Unsupported intervals ignored")
    lib.set_interval(15);verify(lib.interval==15,"Allowed interval persists")
    lib.remove(0)
    verify(lib.scenes.size()==1 and not lib.undo_scene.is_empty(),"Removal retains one reversible undo")
    lib.busy=true;lib.undo()
    verify(lib.scenes.size()==1,"Undo cannot race an active thumbnail capture past the capacity limit")
    lib.busy=false
    lib.undo();verify(lib.scenes.size()==2 and lib.undo_scene.is_empty(),"Undo restores profile")
    lib.use_scene(0)
    verify(app.preferences.get_value("visuals","moon")==lib.scenes[0].moon,"Explicit Use persists chosen visual defaults")
    lib.set_shuffled(true)
    verify(lib.shuffled and not lib.playing,"Shuffle selection persists and pauses playback")
    for count in range(2,9):
        while lib.scenes.size()<count:
            var extra=lib.snapshot("Extra view");lib.scenes.append(extra)
        lib.current=0;lib.shuffle_bag.clear()
        for cycle in range(10):
            var visited={}
            var previous=lib.current
            for step in range(count-1):
                var index=lib.next_index()
                verify(index>=0 and index<count and index!=lib.current,"Shuffle index stays bounded without adjacent repeats")
                verify(not visited.has(index),"Every other scene is visited once per round")
                visited[index]=true;lib.current=index
            verify(not visited.has(previous),"Round excludes its starting view")
    lib.shuffle_bag.assign([1])
    lib.select_scene(1)
    verify(lib.shuffle_bag.is_empty(),"Manual scene selection discards a stale shuffle queue")
    lib.shuffle_bag.clear();lib.scenes=lib.scenes.slice(0,2)
    lib.current=0;lib.set_shuffled(false)
    verify(lib.next_index()==1,"Saved-order Next remains sequential")
    lib.set_shuffled(true)
    var path: String=app.preferences_path
    app.queue_free();await process_frame
    var again=load("res://scenes/earth.tscn").instantiate();again.play_intro=false;again.preferences_path=path;root.add_child(again)
    verify(again.scene_library.scenes.size()==2 and again.scene_library.interval==15,"Scene data and interval survive restart without requiring thumbnails")
    verify(again.scene_library.shuffled,"Shuffle choice survives restart")
    verify(again.services.search_request.get_http_client_status()==HTTPClient.STATUS_DISCONNECTED and again.observed_weather.request==null,"Library requires no provider requests")
    DirAccess.remove_absolute(ProjectSettings.globalize_path(path));again.queue_free();await process_frame
    print("Scene library: %d checks, %d failures" % [checks,failures])
    quit(1 if failures else 0)
