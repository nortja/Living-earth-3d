shader_type spatial;
render_mode unshaded, blend_add, cull_front, depth_draw_never, shadows_disabled;
uniform float visibility : hint_range(0.0, 1.0) = 1.0;
uniform vec3 sun_direction = vec3(0.5, 0.4, 1.0);
varying vec3 world_normal;
void vertex() {
    world_normal = normalize(MODEL_NORMAL_MATRIX * NORMAL);
}
void fragment() {
    float rim = pow(1.0 - abs(dot(normalize(NORMAL), normalize(VIEW))), 2.5);
    float day = smoothstep(-0.3, 0.4, dot(normalize(world_normal), normalize(sun_direction)));
    ALBEDO = mix(vec3(0.025, 0.08, 0.25), vec3(0.12, 0.38, 0.95), day) * rim * visibility;
    ALPHA = rim * 0.5 * visibility;
}
