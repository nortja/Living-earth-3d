extends Node
## Personal offline compositions. Only explicit saves create bounded thumbnails.
signal changed
const LIMIT := 8
const INTERVALS := [15,30,60,120]
const BOOLS := ["moon","galaxy","clouds","stars","sunlight"]
var app: Node3D
var scenes: Array[Dictionary] = []
var directory := "user://scene-library-v1"
var interval := 30
var playing := false
var shuffled := false
var shuffle_bag: Array[int] = []
var shuffle_toggle: CheckButton
var owns_discovery := false
var saved_discovery := false
var elapsed := 0.0
var current := -1
var busy := false
var transition: Tween
var status := "Save up to eight offline Earth/Moon/galaxy compositions."
var name_field: LineEdit
var save_button: Button
var play_button: Button
var pause_button: Button
var next_button: Button
var interval_picker: OptionButton
var status_label: Label
var rows: VBoxContainer
var undo_scene: Dictionary = {}
var undo_button: Button
var cache: Dictionary = {}

func _exit_tree() -> void:
    cache.clear()

static func valid(row: Variant) -> bool:
    if not row is Dictionary or row.size()!=13 or not row.get("id",null) is String or not row.get("name",null) is String: return false
    if row.id.length()!=16 or row.name.strip_edges().is_empty() or row.name.length()>48: return false
    for c in row.name:
        if c.unicode_at(0)<32: return false
    for c in row.id:
        if c not in "0123456789abcdef": return false
    for key in BOOLS:
        if not row.get(key,null) is bool: return false
    for item in [["yaw",-PI*2,PI*2],["pitch",-1.35,1.35],["distance",1.8,10.0],["earth",-PI*2,PI*2],["brightness",0.2,1.5],["orientation",0,360]]:
        var value = row.get(item[0],null)
        if not (value is float or value is int) or not is_finite(float(value)) or float(value)<float(item[1]) or float(value)>float(item[2]): return false
    return true

func setup(owner_app: Node3D) -> void:
    app = owner_app
    directory = app.preferences_path.get_basename()+"-scenes-v1"
    var saved = app.preferences.get_value("scene_library","scenes",[])
    if saved is Array:
        var seen := {}
        for row in saved.slice(0,LIMIT):
            if scenes.size()==LIMIT: break
            if valid(row) and not seen.has(row.id):
                scenes.append(row.duplicate(true));seen[row.id]=true
    var seconds = app.preferences.get_value("scene_library","interval",30)
    if seconds is int and seconds in INTERVALS: interval=seconds
    shuffled = app.preferences.get_value("scene_library","shuffle",false)==true
    cleanup_thumbnails()
    build_controls()

func snapshot(title: String) -> Dictionary:
    var clean_title := ""
    for c in title:
        clean_title += c if c.unicode_at(0)>=32 else " "
    return {"id":Crypto.new().generate_random_bytes(8).hex_encode(),"name":clean_title.strip_edges().left(48),"yaw":wrapf(app.yaw,-PI,PI),"pitch":app.pitch,"distance":clampf(app.camera.position.length(),1.8,10.0),"earth":wrapf(app.earth.rotation.y,-PI,PI),"moon":app.visuals.moon_enabled,"galaxy":app.space_studio.enabled,"clouds":app.visuals.clouds_enabled,"stars":app.visuals.stars_enabled,"sunlight":app.utc_sunlight,"brightness":app.space_studio.brightness,"orientation":app.space_studio.orientation}

func offline_scene() -> bool:
    return not app.sunlight_preview_active and not app.satellite_snapshot.enabled and not app.observed_weather.enabled and not app.weather_layer.marker_root.visible

func persist() -> bool:
    var previous = app.preferences.get_value("scene_library","scenes",[])
    if previous is Array or previous is Dictionary: previous=previous.duplicate(true)
    app.preferences.set_value("scene_library","scenes",scenes.duplicate(true))
    if app.preferences.save(app.preferences_path)==OK: return true
    app.preferences.set_value("scene_library","scenes",previous)
    status="Scene changes could not be saved. Check local storage."
    return false

func save_current() -> void:
    if busy or app.space_studio.saving: return
    pause()
    if scenes.size()>=LIMIT: status="Eight scenes saved. Remove one to make room.";refresh();return
    if not offline_scene(): status="Return to offline Earth before saving a scene. Requested imagery and simulated time are not stored.";refresh();return
    busy=true;refresh()
    var image: Image = await app.space_studio.capture_image()
    if image==null: busy=false;status="Scene capture requires a visible graphics window.";refresh();return
    var title := name_field.text.strip_edges()
    if title.is_empty(): title="Earth view %d" % (scenes.size()+1)
    var row := snapshot(title)
    var scale_factor := 384.0/float(maxi(image.get_width(),image.get_height()))
    image.resize(maxi(1,roundi(image.get_width()*scale_factor)),maxi(1,roundi(image.get_height()*scale_factor)),Image.INTERPOLATE_LANCZOS)
    var path := ProjectSettings.globalize_path(directory.path_join(row.id+".png"))
    var made := DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
    if made!=OK or image.save_png(path)!=OK:
        busy=false;status="The scene thumbnail could not be saved.";refresh();return
    shuffle_bag.clear()
    scenes.append(row)
    if not persist():
        scenes.pop_back();DirAccess.remove_absolute(path)
    else:
        cache[row.id]=ImageTexture.create_from_image(image)
        current=scenes.size()-1
        name_field.clear()
        status="Saved %s · %d of eight scenes." % [row.name,scenes.size()]
    busy=false;refresh()

func thumbnail(id: String) -> Texture2D:
    if cache.has(id): return cache[id]
    var path := directory.path_join(id+".png")
    if not FileAccess.file_exists(path): return null
    var file := FileAccess.open(path,FileAccess.READ)
    if not file or file.get_length()>1048576: return null
    var bytes := file.get_buffer(file.get_length())
    if bytes.size()<33 or bytes.slice(0,16)!=PackedByteArray([137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82]): return null
    var width := (int(bytes[16])<<24)|(int(bytes[17])<<16)|(int(bytes[18])<<8)|int(bytes[19])
    var height := (int(bytes[20])<<24)|(int(bytes[21])<<16)|(int(bytes[22])<<8)|int(bytes[23])
    if width<1 or height<1 or width>384 or height>384: return null
    var image := Image.new()
    if image.load_png_from_buffer(bytes)!=OK: return null
    cache[id]=ImageTexture.create_from_image(image)
    return cache[id]

func use_scene(index: int, persist_visuals := true) -> void:
    if index<0 or index>=scenes.size() or app.screensaver_mode: return
    var row := scenes[index]
    if not valid(row): return
    app.finish_intro()
    if app.journey: app.journey.kill()
    if app.zoom_tween: app.zoom_tween.kill()
    if app.interface.sunlight_explorer.active: app.interface.sunlight_explorer.end()
    app.observed_weather.set_enabled(false)
    app.satellite_snapshot.set_enabled(false)
    app.weather_layer.set_enabled(false)
    app.selected=-1;app.external_focus=true;app.dragging=false;app.angular_velocity=Vector2.ZERO
    if app.focus_marker: app.focus_marker.hide()
    app.yaw=row.yaw;app.pitch=row.pitch;app.distance=row.distance;app.zoom_target=app.distance
    app.earth.rotation.y=row.earth
    app.visuals.apply_options(row.clouds,row.stars,row.moon)
    app.earth_material.set_shader_parameter("cloud_strength",0.12 if row.clouds else 0.0)
    app.utc_sunlight=row.sunlight;app.solar_sample_ticks=-60000;app.update_sunlight()
    app.interface.sunlight_toggle.set_pressed_no_signal(row.sunlight)
    for option in app.visual_toggles: app.visual_toggles[option].set_pressed_no_signal(row[option])
    app.space_studio.set_brightness(row.brightness,false)
    app.space_studio.set_orientation(row.orientation,false)
    app.space_studio.set_enabled(row.galaxy,false)
    app._update_camera()
    if persist_visuals:
        for option in ["moon","clouds","stars"]: app.preferences.set_value("visuals",option,row[option])
        app.preferences.set_value("visuals","utc_sunlight",row.sunlight)
        app.preferences.set_value("space","galaxy",row.galaxy)
        app.preferences.set_value("space","brightness",row.brightness)
        app.preferences.set_value("space","orientation",row.orientation)
        app._save_preferences()
    current=index;elapsed=0
    status="%s · current Moon phase and current sunlight when enabled." % row.name
    app.space_studio.sync();refresh_state()

func select_scene(index: int) -> void:
    if busy: return
    pause();use_scene(index)

func play() -> void:
    if scenes.is_empty() or busy or app.screensaver_mode: return
    pause()
    saved_discovery=app.discovery_enabled;owns_discovery=true
    app.discovery_enabled=false;playing=true
    shuffle_bag.clear()
    use_scene(0 if current<0 or current>=scenes.size() else current,false)
    status="Playing saved scenes · %d seconds each. Pause keeps the current view." % interval
    refresh_state()

func pause() -> void:
    if is_instance_valid(transition): transition.kill()
    transition=null
    if app: app._set_intro_reveal(1.0)
    if owns_discovery:
        app.discovery_enabled=saved_discovery;app.elapsed=0.0;owns_discovery=false
    if playing: status="Scene playback paused. Current composition retained."
    playing=false;elapsed=0
    refresh_state()

func next_scene() -> void:
    if scenes.is_empty() or busy or app.screensaver_mode: return
    if is_instance_valid(transition) and transition.is_running(): return
    var target := next_index()
    transition=create_tween()
    transition.tween_method(app._set_intro_reveal,1.0,0.0,0.3)
    transition.tween_callback(func(): use_scene(target,false))
    transition.tween_method(app._set_intro_reveal,0.0,1.0,0.6)
    transition.finished.connect(refresh_state)
    refresh_state()

func set_shuffled(value: bool) -> void:
    if busy: return
    pause()
    shuffled=value;shuffle_bag.clear()
    app.preferences.set_value("scene_library","shuffle",value)
    app._save_preferences()
    status="Shuffle enabled · every other view once before a new round." if value else "Saved-order playback selected."
    refresh_state()

func next_index() -> int:
    if scenes.is_empty(): return -1
    if not shuffled: return (current+1)%scenes.size()
    if scenes.size()==1: return 0
    if shuffle_bag.is_empty():
        for index in range(scenes.size()):
            if index!=current: shuffle_bag.append(index)
        shuffle_bag.shuffle()
    return shuffle_bag.pop_back()

func set_interval(value: int) -> void:
    if value not in INTERVALS: return
    interval=value;elapsed=0
    app.preferences.set_value("scene_library","interval",value);app._save_preferences();refresh_state()

func remove(index: int) -> void:
    if index<0 or index>=scenes.size() or busy: return
    pause()
    var row := scenes[index]
    shuffle_bag.clear()
    scenes.remove_at(index)
    if not persist(): scenes.insert(index,row);refresh();return
    if not undo_scene.is_empty():
        DirAccess.remove_absolute(ProjectSettings.globalize_path(directory.path_join(undo_scene.id+".png")))
        cache.erase(undo_scene.id)
    undo_scene=row
    current=-1;status="Removed %s. Undo is available." % row.name;refresh()

func undo() -> void:
    if busy or undo_scene.is_empty() or scenes.size()>=LIMIT: return
    pause();shuffle_bag.clear()
    scenes.append(undo_scene)
    if not persist(): scenes.pop_back();refresh();return
    undo_scene={};status="Scene restored.";refresh()

func _process(delta: float) -> void:
    if not playing: return
    if app.screensaver_mode or get_window().mode==Window.MODE_MINIMIZED or app.clean_view.modal_open(): pause();return
    if app.space_studio.saving or busy: return
    elapsed+=minf(delta,0.5)
    if elapsed>=interval:
        elapsed=0;next_scene()

func build_controls() -> void:
    var ui=app.interface
    var entry: Button=ui.button(ui.pages["Live Earth"],"Scene library · save & play your views",func(): ui.open_page("Scene library"))
    ui.pages["Live Earth"].move_child(entry,1);ui.live_primary.append(entry)
    var box: VBoxContainer=ui.pages["Scene library"]
    name_field=LineEdit.new();name_field.placeholder_text="Name this scene (optional)";name_field.max_length=48;box.add_child(name_field)
    var action_margin:=MarginContainer.new();action_margin.add_theme_constant_override("margin_right",2);box.add_child(action_margin)
    var actions:=HBoxContainer.new();action_margin.add_child(actions)
    save_button=ui.button(actions,"Save view",save_current)
    play_button=ui.button(actions,"Play",play)
    pause_button=ui.button(actions,"Pause",pause)
    next_button=ui.button(actions,"Next",next_scene)
    for control in actions.get_children(): control.size_flags_horizontal=Control.SIZE_EXPAND_FILL;control.custom_minimum_size.x=42;control.clip_text=false
    interval_picker=OptionButton.new()
    for value in INTERVALS: interval_picker.add_item("%d seconds per scene" % value,value)
    interval_picker.select(INTERVALS.find(interval));interval_picker.item_selected.connect(func(index: int): set_interval(INTERVALS[index]));box.add_child(interval_picker)
    shuffle_toggle=CheckButton.new();shuffle_toggle.text="Shuffle scenes · no immediate repeats"
    shuffle_toggle.toggled.connect(set_shuffled);box.add_child(shuffle_toggle)
    status_label=ui.label(box,status,12)
    undo_button=ui.button(box,"Undo last removal",undo)
    rows=VBoxContainer.new();box.add_child(rows)
    ui.label(box,"Personal offline compositions · retained on this PC. Scenes store camera, lighting and sky choices; the Moon phase stays current. Play uses temporary visual choices and does not overwrite your saved defaults. Pause keeps the frame; Use applies a scene's saved settings. Drag/zoom, other pages, minimization or screensaver entry stop playback. Closing this panel lets playback continue. Shuffle visits each other view once before starting a fresh round and never immediately repeats a view when two or more exist. Changing order pauses playback. No provider requests.",12)
    ui.label(box,"Milky Way thumbnails: ESO/S. Brunier · CC BY 4.0. Sources and license are in Space Studio. Camera distance and Earth/Moon composition are illustrative, not orbital scale.",12)
    refresh()

func refresh_state() -> void:
    if not status_label: return
    status_label.text=status
    shuffle_toggle.set_pressed_no_signal(shuffled)
    shuffle_toggle.disabled=busy
    save_button.disabled=busy or scenes.size()>=LIMIT
    play_button.disabled=busy or scenes.is_empty() or playing
    pause_button.disabled=not playing and not (is_instance_valid(transition) and transition.is_running())
    next_button.disabled=busy or scenes.is_empty()
    undo_button.visible=not undo_scene.is_empty()
    undo_button.disabled=busy or scenes.size()>=LIMIT
    changed.emit()

func refresh() -> void:
    if not rows: return
    for child in rows.get_children(): rows.remove_child(child);child.queue_free()
    for index in range(scenes.size()):
        var value:=index
        var row:=scenes[index]
        var card:=VBoxContainer.new();rows.add_child(card)
        var picture:=TextureRect.new();picture.texture=thumbnail(row.id);picture.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;picture.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;picture.custom_minimum_size.y=112;card.add_child(picture)
        if not picture.texture: app.interface.label(card,"Preview unavailable · saved view is ready",12)
        if row.galaxy: app.interface.label(card,"Sky: ESO/S. Brunier · CC BY 4.0",11)
        app.interface.label(card,row.name,15)
        var actions:=HBoxContainer.new();card.add_child(actions)
        app.interface.button(actions,"Use view",func(): select_scene(value)).clip_text=false
        app.interface.button(actions,"Remove",func(): remove(value)).clip_text=false
    refresh_state()

func cleanup_thumbnails() -> void:
    if not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(directory)): return
    var keep := {}
    for row in scenes: keep[row.id]=true
    for filename in DirAccess.get_files_at(directory):
        if not filename.ends_with(".png"): continue
        var id := filename.trim_suffix(".png")
        if id.length()!=16 or keep.has(id): continue
        var owned := true
        for c in id:
            if c not in "0123456789abcdef": owned=false
        if owned: DirAccess.remove_absolute(ProjectSettings.globalize_path(directory.path_join(filename)))
