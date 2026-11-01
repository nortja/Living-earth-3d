extends RefCounted
## Hourly NASA geocentric data in 2026; explicitly estimated disks thereafter.
static var nasa: Array = []
static var phases: Array = []
const START := 1767225600 # 2026-01-01 00:00 UTC
const HOUR := 3600
const MONTHS := ["January","February","March","April","May","June","July","August","September","October","November","December"]

static func load_phases() -> Array:
    if phases.is_empty():
        for year in range(2026,2031):
            var source: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/calendar/usno-phases%d.json" % year))
            for item in source.phasedata:
                var date := "%04d-%02d-%02d" % [item.year,item.month,item.day]
                phases.append({"title":item.phase,"date":date,"time":item.time,"stamp":Time.get_unix_time_from_datetime_string(date+"T"+item.time+":00"),"category":"Lunar phase","source":"https://aa.usno.navy.mil/data/MoonPhases"})
        var boundary: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/calendar/usno-phase-boundary2031.json"))
        var item: Dictionary = boundary.phasedata[0]
        var date := "%04d-%02d-%02d" % [item.year,item.month,item.day]
        phases.append({"title":item.phase,"date":date,"time":item.time,"stamp":Time.get_unix_time_from_datetime_string(date+"T"+item.time+":00"),"category":"Lunar phase","source":"https://aa.usno.navy.mil/data/MoonPhases"})
    return phases

static func valid_date(text: String) -> bool:
    if text.length()!=10 or text[4]!="-" or text[7]!="-": return false
    for index in [0,1,2,3,5,6,8,9]:
        if text[index] not in "0123456789": return false
    var year := int(text.substr(0,4))
    var month := int(text.substr(5,2))
    var day := int(text.substr(8,2))
    if year<2026 or year>2030 or month<1 or month>12 or day<1 or day>31: return false
    var leap := year%4==0 and (year%100!=0 or year%400==0)
    var lengths := [31,29 if leap else 28,31,30,31,30,31,31,30,31,30,31]
    if day>int(lengths[month-1]): return false
    var stamp := Time.get_unix_time_from_datetime_string(text+"T12:00:00")
    return Time.get_date_string_from_unix_time(stamp)==text

static func vector(longitude: float, latitude: float) -> Vector3:
    var lon := deg_to_rad(longitude)
    var lat := deg_to_rad(latitude)
    return Vector3(cos(lat)*cos(lon),sin(lat),cos(lat)*sin(lon))

static func sample(stamp: float) -> Dictionary:
    if stamp>=START and stamp<START+8760*HOUR:
        if nasa.is_empty(): nasa = JSON.parse_string(FileAccess.get_file_as_string("res://data/moon/nasa-2026.json"))
        var index := clampi(int((stamp-START)/HOUR),0,nasa.size()-1)
        var row: Dictionary = nasa[index]
        return {"available":true,"precise":true,"phase":float(row.phase),"age":float(row.age),"distance":float(row.distance),"sun":vector(row.subsolar.lon,row.subsolar.lat),"subearth":Vector2(row.subearth.lon,row.subearth.lat),"stamp":START+index*HOUR,"source":"NASA SVS · hourly geocentric geometry","note":"Lunar north up · nearest preceding UTC hour. Surface shading is illustrative; no terrain shadows, local horizon rotation or eclipse shadow."}
    var events := load_phases()
    for index in range(events.size()-1):
        var a: Dictionary = events[index]
        var b: Dictionary = events[index+1]
        if stamp<float(a.stamp) or stamp>=float(b.stamp): continue
        var angle: float = {"New Moon":0.0,"First Quarter":PI/2.0,"Full Moon":PI,"Last Quarter":PI*1.5}[a.title]
        var fraction := (stamp-float(a.stamp))/(float(b.stamp)-float(a.stamp))
        angle += fraction*PI/2.0
        var age := -1.0
        for previous in range(index,-1,-1):
            if events[previous].title=="New Moon":
                age = (stamp-float(events[previous].stamp))/86400.0;break
        return {"available":true,"precise":false,"phase":50.0*(1.0-cos(angle)),"age":age,"distance":0.0,"sun":vector(180.0-rad_to_deg(angle),0.0),"subearth":Vector2.ZERO,"stamp":int(stamp),"source":"Estimated disk · USNO phase-event interpolation","note":"Lunar north up · estimated illumination between published phase events. Libration, distance, local sky rotation and eclipse shadow are not modeled."}
    return {"available":false,"source":"Outside bundled lunar coverage","note":"Choose a date from 2026–2030. Hourly NASA geometry covers 2026; later disks are explicitly estimated between USNO phase events."}

static func phase_name(row: Dictionary) -> String:
    if not row.get("available",false): return "Moon data unavailable"
    var lit := float(row.phase)
    if lit<1.0: return "Near new Moon"
    if lit>99.0: return "Near full Moon"
    # Solar longitude distinguishes waxing/wanning even when age is unknown.
    var waxing: bool = row.sun.z>=0.0
    if absf(lit-50.0)<2.0: return "First quarter vicinity" if waxing else "Last quarter vicinity"
    return ("Waxing " if waxing else "Waning ")+("crescent" if lit<50.0 else "gibbous")

static func events_for_month(year: int, month: int, israel: bool, kind := 0) -> Array:
    var result: Array = []
    if year<2026 or year>2030: return result
    var prefix := "%04d-%02d" % [year,month]
    if kind in [0,1]:
        var path := "res://data/calendar/hebrew-%d-%s.json" % [year,"israel" if israel else "diaspora"]
        var hebrew: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
        for item in hebrew.items:
            if not str(item.date).begins_with(prefix): continue
            var title := str(item.get("title_orig",item.title))
            if title.begins_with("Erev "): continue # Display full Hebrew dates, with the prior sunset stated separately.
            var tag := "Hebrew observance"
            var alias := ""
            for festival in ["Pesach","Shavuot","Rosh Hashana","Yom Kippur","Sukkot","Shmini Atzeret"]:
                if title.begins_with(festival) and not title.contains("LaBehemot"):
                    tag = "Torah festival"
                    alias = {"Pesach":"Passover / Unleavened Bread", "Shavuot":"Feast of Weeks", "Rosh Hashana":"Day of Trumpets", "Yom Kippur":"Day of Atonement", "Sukkot":"Feast of Tabernacles", "Shmini Atzeret":"Eighth Day Assembly"}[festival]+" · "
                    break
            if item.category=="roshchodesh": tag = "Hebrew month begins"
            var date := str(item.date)
            var previous := Time.get_date_string_from_unix_time(Time.get_unix_time_from_datetime_string(date+"T12:00:00")-86400)
            result.append({"title":item.title,"date":date,"category":tag,"detail":"%s%s · Hebrew date begins at sunset %s; no local observance times." % [alias,item.hdate,previous],"source":str(item.get("link","https://www.hebcal.com/"))})
    if kind in [0,2]:
        for event in load_phases():
            if event.date.begins_with(prefix):
                var copy: Dictionary = event.duplicate()
                copy.detail = str(copy.time)+" UTC · U.S. Naval Observatory"
                result.append(copy)
        var season_path := "res://data/calendar/usno-seasons%d.json" % year
        if FileAccess.file_exists(season_path):
            var seasons: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(season_path))
            for item in seasons.data:
                if int(item.month)!=month: continue
                var title := "%s %s" % [MONTHS[month-1],item.phenom] if item.phenom in ["Equinox","Solstice"] else str(item.phenom)
                result.append({"title":title,"date":"%04d-%02d-%02d" % [year,month,item.day],"category":"Solar event","time":item.time,"detail":str(item.time)+" UTC · "+str(seasons.get("credit","U.S. Naval Observatory")),"source":str(seasons.get("source","https://aa.usno.navy.mil/data/Earth_Seasons"))})
    result.sort_custom(func(a,b):return str(a.date)+str(a.title)<str(b.date)+str(b.title))
    return result
