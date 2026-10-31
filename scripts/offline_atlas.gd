extends RefCounted
## Bundled reference places. Searching never starts a network request.
const PAGE_SIZE := 8
const COUNTRY_ALIASES := {"us":"united states usa", "gb":"united kingdom uk britain", "ae":"united arab emirates uae", "tr":"turkey türkiye", "kr":"south korea republic of korea"}

static func folded(value: String) -> String:
    var text:=value.strip_edges().to_lower()
    for group in ["àáâãäåāăą", "çćč", "ďđ", "èéêëēėęě", "ìíîïīı", "ñńň", "òóôõöøōő", "řŕ", "śšş", "ťţ", "ùúûüūůű", "ýÿ", "žźż"]:
        var ascii_character:String={"à":"a","ç":"c","ď":"d","è":"e","ì":"i","ñ":"n","ò":"o","ř":"r","ś":"s","ť":"t","ù":"u","ý":"y","ž":"z"}[group[0]]
        for character in group:text=text.replace(character,ascii_character)
    return text

static func load_places() -> Array:
    var places:Array=JSON.parse_string(FileAccess.get_file_as_string("res://data/atlas.json"))
    var cities:Array=JSON.parse_string(FileAccess.get_file_as_string("res://data/atlas_cities.json"))
    var original_names:Dictionary={}
    for index in range(places.size()):
        original_names[folded(str(places[index].name).get_slice(",",0))]=index
    for city in cities:
        var duplicate:=false
        for alias in city.aliases:
            var key:=folded(alias)
            if not original_names.has(key):continue
            var existing:Dictionary=places[original_names[key]]
            if absf(float(existing.latitude)-float(city.latitude))<0.25 and absf(float(existing.longitude)-float(city.longitude))<0.25:
                existing["aliases"]=city.aliases.duplicate()
                existing["country_code"]=city.country_code
                duplicate=true
                break
        if not duplicate:places.append(city)
    return places

static func search(query: String, places: Array, page := 0) -> Dictionary:
    var needle:=folded(query.left(80))
    if needle.is_empty():return {"places":[],"total":0,"page":0,"pages":0}
    var exact:String=str({"usa":"us","uk":"gb","uae":"ae"}.get(needle,needle))
    var known_code:=false
    for place in places:
        if str(place.get("country_code","")).to_lower()==exact:known_code=true;break
    var ranked:Array=[]
    for place in places:
        var code:=str(place.get("country_code","")).to_lower()
        var city:=folded(str(place.name).get_slice(",",0))
        var terms:Array=[str(place.name),str(COUNTRY_ALIASES.get(code,""))]
        terms.append_array(place.get("aliases",[]))
        var matches:=code==exact if known_code else false
        if not known_code:
            for term in terms:
                if folded(term).contains(needle):matches=true;break
        if matches:ranked.append({"place":place,"rank":0 if city==needle else (1 if city.begins_with(needle) else 2)})
    ranked.sort_custom(func(a,b):return str(a.place.name).naturalnocasecmp_to(str(b.place.name))<0 if a.rank==b.rank else a.rank<b.rank)
    var pages:=ceili(float(ranked.size())/PAGE_SIZE)
    page=clampi(page,0,maxi(0,pages-1))
    var results:Array=[]
    for item in ranked.slice(page*PAGE_SIZE,(page+1)*PAGE_SIZE):results.append(item.place)
    return {"places":results,"total":ranked.size(),"page":page,"pages":pages}
