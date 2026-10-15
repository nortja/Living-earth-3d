shader_type spatial;
render_mode specular_schlick_ggx;
uniform sampler2D earth_map : source_color, filter_linear_mipmap, repeat_enable;
varying vec3 local_position;
void vertex() {
    local_position = VERTEX;
}
void fragment() {
    vec3 direction = normalize(local_position);
    vec2 map_uv = vec2(atan(direction.x, direction.z) / TAU + 0.5,
        0.5 - asin(clamp(direction.y, -1.0, 1.0)) / PI);
    vec3 color = texture(earth_map, map_uv).rgb;
    float ice = smoothstep(0.91, 0.98, abs(direction.y));
    ALBEDO = mix(color, vec3(0.85, 0.92, 0.94), ice);
    ROUGHNESS = 0.85;
    SPECULAR = 0.25;
}
