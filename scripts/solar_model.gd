extends RefCounted
## NOAA-style approximate apparent solar coordinates. UTC clock input only.
## Not an ephemeris for navigation, eclipse prediction or precision astronomy.
static func at_unix(utc: float) -> Dictionary:
    var centuries := (utc / 86400.0 + 2440587.5 - 2451545.0) / 36525.0
    var mean_long := deg_to_rad(fposmod(280.46646 + centuries * (36000.76983 + centuries * 0.0003032), 360.0))
    var anomaly := deg_to_rad(357.52911 + centuries * (35999.05029 - 0.0001537 * centuries))
    var eccentricity := 0.016708634 - centuries * (0.000042037 + 0.0000001267 * centuries)
    var center := sin(anomaly) * (1.914602 - centuries * (0.004817 + 0.000014 * centuries)) + sin(2 * anomaly) * (0.019993 - 0.000101 * centuries) + sin(3 * anomaly) * 0.000289
    var omega := deg_to_rad(125.04 - 1934.136 * centuries)
    var apparent := mean_long + deg_to_rad(center - 0.00569 - 0.00478 * sin(omega))
    var tilt := deg_to_rad(23.0 + (26.0 + (21.448 - centuries * (46.815 + centuries * (0.00059 - centuries * 0.001813))) / 60.0) / 60.0 + 0.00256 * cos(omega))
    var declination := asin(sin(tilt) * sin(apparent))
    var y := pow(tan(tilt / 2.0), 2)
    var equation := 4 * rad_to_deg(y * sin(2 * mean_long) - 2 * eccentricity * sin(anomaly) + 4 * eccentricity * y * sin(anomaly) * cos(2 * mean_long) - 0.5 * y * y * sin(4 * mean_long) - 1.25 * eccentricity * eccentricity * sin(2 * anomaly))
    var longitude := wrapf((720.0 - fposmod(utc, 86400.0) / 60.0 - equation) / 4.0, -180, 180)
    return {"latitude": rad_to_deg(declination), "longitude": longitude, "equation_minutes": equation, "direction": local_direction(rad_to_deg(declination), longitude)}

static func local_direction(latitude: float, longitude: float) -> Vector3:
    var lat := deg_to_rad(latitude)
    var lon := deg_to_rad(longitude) + PI
    return Vector3(sin(lon) * cos(lat), sin(lat), cos(lon) * cos(lat))
