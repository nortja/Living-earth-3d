extends AudioStreamPlayer
## Original synthesized pad: no recording, network request or external audio license.
var enabled := false
var level := 0.25
var suspended := false
var fade: Tween

func setup(settings: ConfigFile, quiet_mode: bool) -> void:
    enabled = settings.get_value("audio", "enabled", false)
    level = clampf(float(settings.get_value("audio", "volume", 0.25)), 0.0, 1.0)
    suspended = quiet_mode
    volume_db = -80.0
    apply()

func make_loop() -> AudioStreamWAV:
    # Integer cycles over eight seconds make a seamless, deterministic loop.
    var rate := 16000
    var count := rate * 8
    var samples := PackedByteArray()
    samples.resize(count * 2)
    for i in range(count):
        var t := float(i) / rate
        var swell := 0.7 + 0.3 * cos(TAU * t / 8.0)
        var value := (sin(TAU * 110.0 * t) * 0.45 + sin(TAU * 165.0 * t) * 0.25 + sin(TAU * 220.0 * t) * 0.15) * swell * 0.3
        samples.encode_s16(i * 2, int(value * 32767.0))
    var result := AudioStreamWAV.new()
    result.format = AudioStreamWAV.FORMAT_16_BITS
    result.mix_rate = rate
    result.data = samples
    result.loop_mode = AudioStreamWAV.LOOP_FORWARD
    result.loop_begin = 0
    result.loop_end = count
    return result

func set_suspended(value: bool) -> void:
    suspended = value
    apply()

func apply() -> void:
    if fade: fade.kill()
    var audible := enabled and not suspended and level > 0.0
    if audible and not playing:
        if not stream: stream = make_loop()
        volume_db = -80.0
        play()
    fade = create_tween()
    fade.tween_property(self, "volume_db", linear_to_db(level) if audible else -80.0, 0.6)
    if not audible: fade.tween_callback(stop)
