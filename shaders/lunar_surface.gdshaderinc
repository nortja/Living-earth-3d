uniform sampler2D lunar_map : source_color, filter_linear_mipmap, repeat_enable;
uniform vec3 lunar_sun = vec3(1.0,0.0,0.0);
uniform vec2 subearth_degrees = vec2(0.0);
uniform float visibility = 1.0;

vec4 moon_surface(vec2 uv) {
    vec2 xy = vec2(uv.x*2.0-1.0,1.0-uv.y*2.0);
    float rr = dot(xy,xy);
    if (rr>=1.0) return vec4(0.0);
    float lon = radians(subearth_degrees.x);
    float lat = radians(subearth_degrees.y);
    vec3 center = vec3(cos(lat)*cos(lon),sin(lat),cos(lat)*sin(lon));
    vec3 east = vec3(-sin(lon),0.0,cos(lon));
    vec3 north = vec3(-sin(lat)*cos(lon),cos(lat),-sin(lat)*sin(lon));
    vec3 surface_normal = normalize(center*sqrt(max(0.0,1.0-rr))+east*xy.x+north*xy.y);
    vec2 map_uv = vec2(atan(surface_normal.z,surface_normal.x)/6.28318530718+0.5,0.5-asin(clamp(surface_normal.y,-1.0,1.0))/3.14159265359);
    vec3 albedo = texture(lunar_map,map_uv).rgb;
    float sunlight = max(0.0,dot(surface_normal,normalize(lunar_sun)));
    float reflected = 0.004+1.15*pow(sunlight,0.5);
    float edge = 1.0-smoothstep(0.994,1.0,rr);
    return vec4(albedo*reflected*visibility,edge);
}
