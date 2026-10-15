extends RefCounted
var places: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/discoveries.json"))
var history: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/history.json"))
func daily(utc: float) -> Dictionary:
    return places[posmod(int(floor(utc / 86400.0)), places.size())]
func historical_sites(year: int) -> Array:
    var result: Array = []
    for site in history:
        if year >= int(site.start_year) and year <= int(site.end_year): result.append(site)
    return result
static func year_label(year: int) -> String:
    return "%d BCE" % absi(year) if year < 0 else "%d CE" % maxi(1, year)
