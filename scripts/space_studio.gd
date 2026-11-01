extends Node
## Offline photographic backdrop and opt-in native-resolution PNG postcards.
signal changed
var app: Node3D
var enabled := false
var brightness := 0.75
var orientation := 110.0
var sky: Sky
var previous_reflection := Environment.REFLECTION_SOURCE_BG
var environment: Environment
var material: PanoramaSkyMaterial
var credit: Label
var dialog: FileDialog
var saving := false
var status := "Save a clean PNG at the current viewport's actual resolution."
var moon_toggle: CheckButton
var galaxy_toggle: CheckButton
var hide_toggle: CheckButton
var brightness_slider: HSlider
var angle_slider: HSlider
var save_button: Button
var clean_button: Button
var status_label: Label

func _exit_tree() -> void:
    if environment: environment.sky = null
    sky = null
    material = null

func number(key: String, fallback: float, low: float, high: float) -> float:
    var value = app.preferences.get_value("space",key,fallback)
    return clampf(float(value),low,high) if (value is float or value is int) and is_finite(float(value)) else fallback

func setup(owner_app: Node3D) -> void:
    app = owner_app
    brightness = number("brightness",0.75,0.2,1.5)
    orientation = number("orientation",110.0,0.0,360.0)
    for child in app.get_children():
        if child is WorldEnvironment: environment = child.environment
    previous_reflection = environment.reflected_light_source
    sky = Sky.new()
    sky.radiance_size = Sky.RADIANCE_SIZE_32
    material = PanoramaSkyMaterial.new()
    sky.sky_material = material
    environment.sky = sky
    var layer := CanvasLayer.new()
    layer.layer = 2
    add_child(layer)
    credit = Label.new()
    credit.text = "Milky Way panorama · ESO/S. Brunier · CC BY 4.0"
    credit.add_theme_font_size_override("font_size",12)
    credit.add_theme_color_override("font_color",Color.WHITE)
    credit.add_theme_color_override("font_outline_color",Color.BLACK)
    credit.add_theme_constant_override("outline_size",3)
    credit.mouse_filter = Control.MOUSE_FILTER_IGNORE
    layer.add_child(credit)
    get_viewport().size_changed.connect(layout_credit)
    set_enabled(app.preferences.get_value("space","galaxy",false)==true,false)
    layout_credit()
    if not app.native_saver: build_controls()

func layout_credit() -> void:
    if credit: credit.position = Vector2(16,maxf(0,get_viewport().get_visible_rect().size.y-28))

func set_enabled(value: bool, persist := true) -> void:
    enabled = value
    environment.background_mode = Environment.BG_SKY if enabled else Environment.BG_COLOR
    environment.reflected_light_source = Environment.REFLECTION_SOURCE_DISABLED if enabled else previous_reflection
    if enabled:
        var path := "res://assets/space/milkyway_2k.jpg" if app.native_saver else "res://assets/space/milkyway_4k.jpg"
        material.panorama = load(path)
    else: material.panorama = null
    environment.background_energy_multiplier = brightness if enabled else 1.0
    environment.sky_rotation = Vector3(deg_to_rad(18),deg_to_rad(orientation),deg_to_rad(-18))
    if persist:
        app.preferences.set_value("space","galaxy",enabled)
        app._save_preferences()
    sync()
    changed.emit()

func set_brightness(value: float, persist := true) -> void:
    if not is_finite(value): return
    brightness = clampf(value,0.2,1.5)
    environment.background_energy_multiplier = brightness if enabled else 1.0
    if persist:
        app.preferences.set_value("space","brightness",brightness)
        app._save_preferences()
    sync()

func set_orientation(value: float, persist := true) -> void:
    if not is_finite(value): return
    orientation = clampf(value,0,360)
    environment.sky_rotation = Vector3(deg_to_rad(18),deg_to_rad(orientation),deg_to_rad(-18))
    if persist:
        app.preferences.set_value("space","orientation",orientation)
        app._save_preferences()
    sync()

func preset(index: int) -> void:
    if index<0 or index>2: return
    app.set_visual_option("moon",index!=0)
    set_enabled(index==2)

func _process(_delta: float) -> void:
    environment.background_energy_multiplier = brightness*app.intro_reveal if enabled else 1.0
    var ui = app.interface
    credit.visible = enabled and app.intro_reveal>0.05 and (app.screensaver_mode or not ui.visible or not (ui.wall.visible or ui.photo_viewer.visible or ui.lunar_observatory.visible or ui.camera_overlay.visible))
    # The photographic star field replaces the decorative generated points.
    app.visuals.stars.visible = app.visuals.stars_enabled and not enabled

func build_controls() -> void:
    var ui = app.interface
    var entry: Button = ui.button(ui.pages["Live Earth"],"Space studio · Earth, Moon & galaxy",func(): ui.open_page("Space studio"))
    ui.pages["Live Earth"].move_child(entry,0)
    ui.live_primary.append(entry)
    ui.button(ui.pages["Settings"],"Space studio · Moon, galaxy & clean view",func(): ui.open_page("Space studio"))
    ui.pages["Settings"].move_child(ui.pages["Settings"].get_child(-1),1)
    var box: VBoxContainer = ui.pages["Space studio"]
    moon_toggle = CheckButton.new();moon_toggle.text = "Show Moon · dated phase"
    moon_toggle.toggled.connect(func(value: bool): app.set_visual_option("moon",value))
    box.add_child(moon_toggle)
    galaxy_toggle = CheckButton.new();galaxy_toggle.text = "Show Milky Way · 4K photographic sky"
    galaxy_toggle.toggled.connect(set_enabled);box.add_child(galaxy_toggle)
    var row := HBoxContainer.new();box.add_child(row)
    clean_button = ui.button(row,"Clean view",func(): app.clean_view.clean_now())
    clean_button.tooltip_text = "Hide controls now; move the pointer or press H to return"
    save_button = ui.button(row,"Save picture",choose_file)
    for control in row.get_children(): control.size_flags_horizontal = Control.SIZE_EXPAND_FILL;control.clip_text = false
    hide_toggle = CheckButton.new();hide_toggle.text = "Hide menus when pointer leaves"
    hide_toggle.toggled.connect(func(value: bool): app.clean_view.set_enabled(value))
    box.add_child(hide_toggle)
    status_label = ui.label(box,status,12)
    var presets := HBoxContainer.new();box.add_child(presets)
    for index in range(3):
        var value := index
        var control: Button = ui.button(presets,["Earth","+ Moon","+ Galaxy"][index],func(): preset(value))
        control.size_flags_horizontal = Control.SIZE_EXPAND_FILL;control.clip_text = false
    ui.label(box,"Galaxy brightness",14)
    brightness_slider = HSlider.new();brightness_slider.min_value = 0.2;brightness_slider.max_value = 1.5;brightness_slider.step = 0.05;brightness_slider.custom_minimum_size.y = 28
    brightness_slider.value_changed.connect(set_brightness);box.add_child(brightness_slider)
    ui.label(box,"Galaxy orientation",14)
    angle_slider = HSlider.new();angle_slider.min_value = 0;angle_slider.max_value = 360;angle_slider.step = 1;angle_slider.custom_minimum_size.y = 28
    angle_slider.value_changed.connect(set_orientation);box.add_child(angle_slider)
    ui.label(box,"Real Milky Way panorama · ESO/S. Brunier · CC BY 4.0. Offline optical composite published in 2009, resized from the public 6000×3000 photograph. Desktop uses 4096×2048; native screensaver uses 2048×1024. Brightness and orientation are adjustable. This is our sky seen from Earth, not an exterior photograph or current local sky. Earth/Moon sizes and placement are composed.",12)
    ui.label(box,"Move outside the app for an unobstructed view; return to restore the same menus. H also hides controls; move the pointer or press H/Esc to return. Moon is optional in every screensaver style. Picture export includes the scene and any galaxy credit, with no menus or dialogs. Pixel dimensions match the actual viewport; no upscaling.",12)
    ui.button(box,"Milky Way source · ESO ↗",func(): OS.shell_open("https://www.eso.org/public/images/eso0932a/"))
    ui.button(box,"Image license · CC BY 4.0 ↗",func(): OS.shell_open("https://creativecommons.org/licenses/by/4.0/"))
    sync()

func sync() -> void:
    if not moon_toggle: return
    moon_toggle.set_pressed_no_signal(app.visuals.moon_enabled)
    galaxy_toggle.set_pressed_no_signal(enabled)
    if app.clean_view: hide_toggle.set_pressed_no_signal(app.clean_view.enabled)
    brightness_slider.set_value_no_signal(brightness)
    angle_slider.set_value_no_signal(orientation)
    save_button.disabled = saving
    status_label.text = status

func choose_file() -> void:
    if saving or app.screensaver_mode: return
    if not dialog:
        dialog = FileDialog.new()
        dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
        dialog.access = FileDialog.ACCESS_FILESYSTEM
        dialog.use_native_dialog = true
        dialog.title = "Save a Living Earth picture"
        dialog.filters = PackedStringArray(["*.png ; PNG image"])
        app.add_child(dialog)
        dialog.file_selected.connect(capture_to)
    dialog.current_file = "LivingEarth-"+Time.get_datetime_string_from_system().replace(":","-")+".png"
    dialog.popup_centered_ratio(0.8)

func capture_to(path: String) -> void:
    if saving or app.screensaver_mode: return
    if not path.is_absolute_path() or not path.to_lower().ends_with(".png"):
        status = "Choose an absolute PNG destination.";sync();return
    if DisplayServer.get_name()=="headless":
        status = "Picture export requires the app's graphics window.";sync();return
    var pixels := get_viewport().get_visible_rect().size
    if pixels.x>7680 or pixels.y>4320 or pixels.x*pixels.y>33177600:
        status = "Use a viewport no larger than 7680×4320 for picture export.";sync();return
    var image: Image = await capture_image()
    if image==null: return
    var result := image.save_png(path)
    status = "Saved %d×%d · %s" % [image.get_width(),image.get_height(),path.get_file()] if result==OK else "Picture could not be saved. Choose a writable PNG location."
    sync()

func capture_image() -> Image:
    if saving or app.screensaver_mode or DisplayServer.get_name()=="headless": return null
    var pixels := get_viewport().get_visible_rect().size
    if pixels.x>7680 or pixels.y>4320 or pixels.x*pixels.y>33177600: return null
    if app.scene_library: app.scene_library.pause()
    saving = true
    var cleaner = app.clean_view
    cleaner.capture = true;cleaner.apply()
    await get_tree().process_frame
    await get_tree().process_frame
    await RenderingServer.frame_post_draw
    pixels = get_viewport().get_visible_rect().size
    var image: Image
    if not app.screensaver_mode and pixels.x<=7680 and pixels.y<=4320 and pixels.x*pixels.y<=33177600:
        image = get_viewport().get_texture().get_image()
    cleaner.capture = false;cleaner.apply()
    saving = false
    sync()
    return null if image==null or image.is_empty() else image
