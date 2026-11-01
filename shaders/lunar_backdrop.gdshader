shader_type spatial;
render_mode unshaded, cull_disabled, blend_mix, depth_draw_never;
#include "res://shaders/lunar_surface.gdshaderinc"
void fragment() {
    vec4 color = moon_surface(UV);
    ALBEDO = color.rgb;
    ALPHA = color.a;
}
