shader_type spatial;
render_mode specular_schlick_ggx;
uniform sampler2D day_map : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D night_map : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D ocean_mask : filter_linear_mipmap_anisotropic, repeat_enable;
uniform vec3 sun_direction = vec3(0.5, 0.4, 1.0);
varying vec3 world_normal;
void vertex() {
    world_normal = normalize(MODEL_NORMAL_MATRIX * NORMAL);
}
void fragment() {
    vec3 surface = texture(day_map, UV).rgb;
    float ocean = texture(ocean_mask, UV).r;
    float day = smoothstep(-0.12, 0.2, dot(normalize(world_normal), normalize(sun_direction)));
    ALBEDO = surface;
    ROUGHNESS = mix(0.9, 0.6, ocean);
    SPECULAR = mix(0.15, 0.32, ocean);
    EMISSION = texture(night_map, UV).rgb * (1.0 - day) * 0.8;
}
