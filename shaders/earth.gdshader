shader_type spatial;
render_mode specular_schlick_ggx;
uniform sampler2D day_map : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D night_map : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D ocean_mask : filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D cloud_map : filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D satellite_map : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform bool satellite_view = false;
uniform sampler2D observed_weather_map : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform bool observed_weather_view = false;
uniform float visibility : hint_range(0.0, 1.0) = 1.0;
uniform float cloud_offset = 0.0;
uniform float cloud_strength = 0.12;
uniform vec3 sun_direction = vec3(0.5, 0.4, 1.0);
varying vec3 world_normal;
void vertex() {
    world_normal = normalize(MODEL_NORMAL_MATRIX * NORMAL);
}
void fragment() {
    vec3 surface = texture(day_map, UV).rgb;
    float ocean = texture(ocean_mask, UV).r;
    float daylight = dot(normalize(world_normal), normalize(sun_direction));
    float day = smoothstep(-0.14, 0.18, daylight);
    // Subtle artistic cloud shade, not a physical weather simulation.
    float cloud = texture(cloud_map, vec2(UV.x - cloud_offset + 0.001, UV.y)).r;
    surface *= 1.0 - cloud * cloud_strength * day * (observed_weather_view ? 0.0 : 1.0);
    surface *= mix(1.0, 0.72, ocean);
    ALBEDO = surface * visibility;
    ROUGHNESS = mix(0.95, 0.58, ocean);
    SPECULAR = mix(0.12, 0.32, ocean);
    float rim = pow(1.0 - max(dot(normalize(NORMAL), normalize(VIEW)), 0.0), 3.0);
    EMISSION = (texture(night_map, UV).rgb * (1.0 - day) * 1.15 + vec3(0.015, 0.04, 0.08) * rim * day) * visibility;
    if (satellite_view) {
        // Dated multi-pass observations: no invented current night lights/clouds.
        ALBEDO = vec3(0.0);
        EMISSION = texture(satellite_map, UV).rgb * visibility;
        ROUGHNESS = 1.0;
        SPECULAR = 0.0;
    }    if (observed_weather_view) {
        // Only observed regional pixels replace the offline surface; no invented global clouds.
        vec4 scene = texture(observed_weather_map, UV);
        float valid = scene.a;
        ALBEDO *= 1.0-valid;
        EMISSION = mix(EMISSION,scene.rgb*visibility,valid);
        ROUGHNESS = mix(ROUGHNESS,1.0,valid);
        SPECULAR *= 1.0-valid;
    }

}
