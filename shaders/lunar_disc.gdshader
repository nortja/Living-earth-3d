shader_type canvas_item;
#include "res://shaders/lunar_surface.gdshaderinc"
void fragment() { COLOR = moon_surface(UV); }
