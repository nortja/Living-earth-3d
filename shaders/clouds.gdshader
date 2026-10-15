shader_type spatial;
render_mode blend_mix, depth_draw_never, cull_back;
uniform sampler2D cloud_map : filter_linear_mipmap_anisotropic, repeat_enable;
uniform float visibility : hint_range(0.0, 1.0) = 1.0;
void fragment() {
    float cloud = smoothstep(0.1, 0.9, texture(cloud_map, UV).r);
    ALBEDO = vec3(0.92, 0.96, 1.0);
    ROUGHNESS = 1.0;
    SPECULAR = 0.05;
    ALPHA = cloud * 0.82 * visibility;
}
