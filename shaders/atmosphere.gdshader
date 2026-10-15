shader_type spatial;
render_mode unshaded, blend_add, cull_front, depth_draw_never, shadows_disabled;
uniform float visibility : hint_range(0.0, 1.0) = 1.0;
void fragment() {
    float rim = pow(1.0 - abs(dot(normalize(NORMAL), normalize(VIEW))), 3.0);
    ALBEDO = vec3(0.12, 0.38, 0.9) * rim * 0.55 * visibility;
    ALPHA = rim * 0.55 * visibility;
}
