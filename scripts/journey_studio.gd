extends RefCounted
## Bounded session-only tours. No preferences, files or provider requests.
const Geometry = preload("res://scripts/journey_geometry.gd")
const Places = preload("res://scripts/exploration_data.gd")
const Atlas = preload("res://scripts/offline_atlas.gd")
const MAX_STOPS := 8
const HOLD_SECONDS := 12.0
const COLORS := [Color("78e5e8"),Color("f3c777"),Color("9bafff"),Color("f18dba")]
var ui: Control
var app: Node3D
var stops: Array = []
var active := false
var playing := false
var current := 0
var remaining := HOLD_SECONDS
var arrived := false
var owned_tween: Tween
var saved_discovery := false
var marker_root: Node3D
var status: Label
var summary: Label
var play_button: Button
var pause_button: Button
var next_button: Button
var clear_button: Button
var query: LineEdit
var picker: OptionButton
var add_button: Button
var matches: Array = []
var rows: VBoxContainer
var notice := "Build a tour or choose a starter route."

func setup(interface: Control, box: VBoxContainer) -> void:
    ui = interface
    app = ui.app
    marker_root = Node3D.new()
    marker_root.name = "JourneyRoutes"
    app.earth.add_child(marker_root)
    marker_root.hide()
    var inset := Control.new()
    inset.custom_minimum_size.y = 2
    box.add_child(inset)
    status = ui.label(box,"",14)
    var controls := HBoxContainer.new()
    box.add_child(controls)
    play_button = ui.button(controls,"Play",play)
    pause_button = ui.button(controls,"Pause",func(): pause("Paused · Play continues from this stop."))
    next_button = ui.button(controls,"Next",next)
    clear_button = ui.button(controls,"Clear",clear)
    for control in controls.get_children(): control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    summary = ui.label(box,"",12)
    var presets := OptionButton.new()
    presets.add_item("Starter routes · replaces this session's tour…")
    for title in ["Across the Pacific", "Around Earth", "Saved places"]: presets.add_item(title)
    presets.item_selected.connect(func(index: int):
        if index>0: preset(index)
        presets.select(0))
    box.add_child(presets)
    ui.button(box,"Add selected globe destination",func(): add_place(app.exploration.location))
    query = LineEdit.new()
    query.placeholder_text = "Find an offline city or country"
    query.max_length = 80
    query.custom_minimum_size.y = 36
    query.text_changed.connect(search)
    box.add_child(query)
    picker = OptionButton.new()
    picker.clip_text = true
    box.add_child(picker)
    add_button = ui.button(box,"Add chosen city",func():
        if picker.selected>=0 and picker.selected<matches.size(): add_place(matches[picker.selected]))
    rows = VBoxContainer.new()
    box.add_child(rows)
    ui.label(box,"Up to eight stops · 12 seconds per stop, including arrival. Drag or zoom pauses playback. Routes and distances use a mean-radius sphere; these are illustrative shortest paths, not airline routes, travel times or navigation. Exact antipodes use one arbitrary shortest path. Session only; closing stops playback and removes the paths.",12)
    ui.button(box,"Finish tour · return to globe",ui.close_panel)
    search("")
    refresh()

func begin() -> void:
    if app.screensaver_mode: return
    active = true
    marker_root.visible = not stops.is_empty()
    refresh()

func end() -> void:
    pause("Tour stopped · your route remains in this session.")
    active = false
    marker_root.hide()

func search(text: String) -> void:
    matches = Atlas.search(text,ui.atlas).places
    picker.clear()
    for place in matches: picker.add_item(str(place.name))
    if matches.is_empty(): picker.add_item("Type a city or narrow the country search")
    picker.disabled = matches.is_empty()
    add_button.disabled = matches.is_empty()
    picker.tooltip_text = "First eight atlas matches; narrow your search for more specific results."

func add_place(place: Dictionary) -> bool:
    var clean := Places.sanitize(place)
    if clean.is_empty():
        notice = "Choose a globe destination or an offline city first."
        refresh(); return false
    if stops.size()>=MAX_STOPS:
        notice = "Eight-stop limit · remove a stop before adding another."
        refresh(); return false
    for existing in stops:
        if Places.key(existing)==Places.key(clean) or Geometry.distance(existing,clean)<0.001:
            notice = "That location is already in this tour."
            refresh(); return false
    pause("")
    stops.append(clean)
    current = 0
    notice = "Added %s." % clean.name
    rebuild()
    return true

func clear() -> void:
    pause("")
    stops.clear()
    current = 0
    notice = "Tour cleared."
    rebuild()

func move_stop(index: int, offset: int) -> void:
    var target := index+offset
    if index<0 or index>=stops.size() or target<0 or target>=stops.size(): return
    pause("")
    var item: Dictionary = stops[index]
    stops.remove_at(index)
    stops.insert(target,item)
    current = 0
    notice = "Stop order updated."
    rebuild()

func remove_stop(index: int) -> void:
    if index<0 or index>=stops.size(): return
    pause("")
    stops.remove_at(index)
    current = 0
    notice = "Stop removed."
    rebuild()

func preset(index: int) -> void:
    var candidates: Array = []
    if index == 3:
        candidates = app.exploration.bookmarks.slice(0,MAX_STOPS)
    else:
        var names: Array = ["Los Angeles", "Vancouver", "Tokyo", "Manila"] if index==1 else ["London", "Cairo", "Nairobi", "Singapore", "Sydney", "Santiago"]
        for title in names:
            var result: Array = Atlas.search(title,ui.atlas).places
            if not result.is_empty(): candidates.append(result[0])
    if candidates.is_empty():
        notice = "Save some globe places first; the current tour is unchanged."
        refresh(); return
    clear()
    for place in candidates: add_place(place)
    notice = "Starter route ready · customize it or press Play."
    refresh()

func play() -> void:
    if not active or app.screensaver_mode or stops.is_empty(): return
    if not playing:
        saved_discovery = app.discovery_enabled
        app.discovery_enabled = false
    playing = true
    visit_current()

func visit_current() -> void:
    if stops.is_empty(): return
    current = clampi(current,0,stops.size()-1)
    app.fly_to_location(stops[current],false)
    owned_tween = app.journey
    arrived = false
    owned_tween.finished.connect(func(): arrived = true)
    remaining = HOLD_SECONDS
    notice = "Stop %d/%d · %s" % [current+1,stops.size(),stops[current].name]
    refresh()

func pause(message: String) -> void:
    if playing:
        app.discovery_enabled = saved_discovery
        app.elapsed = 0.0
    playing = false
    if owned_tween and owned_tween.is_valid(): owned_tween.kill()
    owned_tween = null
    if not message.is_empty(): notice = message
    if status: refresh()

func next() -> void:
    if not active or stops.is_empty() or app.screensaver_mode: return
    if current>=stops.size()-1:
        pause("Tour complete · Play starts again from the first stop.")
        current = 0
        refresh(); return
    current += 1
    if not playing: play()
    else: visit_current()

func tick(delta: float) -> void:
    if not playing: return
    if not active or app.screensaver_mode or not ui.panel.visible or ui.active_page!="Journey studio":
        end(); return
    if DisplayServer.get_name()!="headless" and (app.get_window().mode==Window.MODE_MINIMIZED or not app.get_window().has_focus()):
        pause("Paused while Earth is in the background · press Play to continue."); return
    if app.dragging or app.journey!=owned_tween or (owned_tween and not owned_tween.is_valid() and not arrived):
        pause("Paused for manual exploration · press Play to continue."); return
    remaining -= minf(delta,0.25) # No catch-up skips after a suspended frame.
    if remaining<=0.0: next()

func refresh() -> void:
    status.text = notice
    summary.text = "%d/%d stops · ≈ %s km / %s mi\nOffline great-circle paths · session only" % [stops.size(),MAX_STOPS,String.num(Geometry.total(stops),0),String.num(Geometry.total(stops)*0.621371,0)]
    play_button.disabled = stops.is_empty() or playing
    pause_button.disabled = not playing
    next_button.disabled = stops.is_empty()
    clear_button.disabled = stops.is_empty()
    ui.refresh_layout()

func rebuild() -> void:
    for child in marker_root.get_children():
        marker_root.remove_child(child)
        child.queue_free()
    ui._clear(rows)
    var mesh := ImmediateMesh.new()
    var material := StandardMaterial3D.new()
    material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    material.vertex_color_use_as_albedo = true
    material.cull_mode = BaseMaterial3D.CULL_DISABLED
    if stops.size()>1 and Geometry.total(stops)>0.000001:
        mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES,material)
        for index in range(1,stops.size()):
            var points := Geometry.arc(stops[index-1],stops[index])
            mesh.surface_set_color(COLORS[(index-1)%COLORS.size()])
            for segment in range(points.size()-1):
                var p: Vector3 = points[segment]
                var q: Vector3 = points[segment+1]
                if p.distance_squared_to(q)<1e-12: continue
                var along := (q-p).normalized()
                var side := along.cross(p).normalized()*0.002
                var up := along.cross(side).normalized()*0.002
                var ring := [side,up,-side,-up]
                for face in range(4):
                    var a: Vector3 = ring[face]
                    var b: Vector3 = ring[(face+1)%4]
                    for vertex in [p+a,q+a,q+b,p+a,q+b,p+b]: mesh.surface_add_vertex(vertex)
        mesh.surface_end()
        var line := MeshInstance3D.new()
        line.mesh = mesh
        marker_root.add_child(line)
    for index in range(stops.size()):
        var pin := MeshInstance3D.new()
        var sphere := SphereMesh.new()
        sphere.radius = 0.008
        sphere.height = 0.016
        pin.mesh = sphere
        var color := StandardMaterial3D.new()
        color.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
        color.albedo_color = COLORS[index%COLORS.size()]
        pin.material_override = color
        pin.position = Geometry.direction(stops[index])*1.018
        marker_root.add_child(pin)
        var row := HBoxContainer.new()
        rows.add_child(row)
        var name: Label = ui.label(row,"%d · %s" % [index+1,stops[index].name],13)
        name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        name.custom_minimum_size.x = 80
        var up_button: Button = ui.button(row,"Up",move_stop.bind(index,-1))
        up_button.disabled = index==0
        up_button.tooltip_text = "Move stop up"
        var down_button: Button = ui.button(row,"Dn",move_stop.bind(index,1))
        down_button.disabled = index==stops.size()-1
        down_button.tooltip_text = "Move stop down"
        var remove_button: Button = ui.button(row,"×",remove_stop.bind(index))
        remove_button.tooltip_text = "Remove stop"
        for control in [up_button,down_button,remove_button]:
            control.custom_minimum_size.x = 36
            control.clip_text = false
    marker_root.visible = active and not stops.is_empty() and not app.screensaver_mode
    refresh()
