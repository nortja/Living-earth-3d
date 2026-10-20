extends RefCounted
## Approximate geometric Sun position from NOAA's fractional-year equations.
## https://gml.noaa.gov/grad/solcalc/solareqns.PDF
## Uses device UTC, not a network observation. No refraction or terrain correction.

static func at_unix(unix_time: float) -> Dictionary:
    var utc := Time.get_datetime_dict_from_unix_time(int(unix_time))
    var year := int(utc.year)
    var start := Time.get_unix_time_from_datetime_dict({"year":year,"month":1,"day":1,"hour":0,"minute":0,"second":0})
    var day := int(floor((unix_time - start) / 86400.0)) + 1
    var leap := year % 4 == 0 and (year % 100 != 0 or year % 400 == 0)
    var hour := float(utc.hour) + float(utc.minute) / 60.0 + float(utc.second) / 3600.0
    var gamma := TAU / (366.0 if leap else 365.0) * (float(day - 1) + (hour - 12.0) / 24.0)
    var equation := 229.18 * (0.000075 + 0.001868 * cos(gamma) - 0.032077 * sin(gamma) - 0.014615 * cos(2.0 * gamma) - 0.040849 * sin(2.0 * gamma))
    var declination := 0.006918 - 0.399912 * cos(gamma) + 0.070257 * sin(gamma) - 0.006758 * cos(2.0 * gamma) + 0.000907 * sin(2.0 * gamma) - 0.002697 * cos(3.0 * gamma) + 0.00148 * sin(3.0 * gamma)
    # At the subsolar longitude, true solar time is 720 minutes (local solar noon).
    var longitude := wrapf((720.0 - hour * 60.0 - equation) / 4.0, -180.0, 180.0)
    var angle := deg_to_rad(longitude) + PI
    var direction := Vector3(sin(angle) * cos(declination), sin(declination), cos(angle) * cos(declination))
    return {"latitude":rad_to_deg(declination), "longitude":longitude, "direction":direction, "utc":Time.get_datetime_string_from_unix_time(int(unix_time)).replace("T", " ")}
