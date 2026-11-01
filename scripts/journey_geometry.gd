extends RefCounted
## Educational spherical geometry, not flight routes or navigation.
const RADIUS_KM := 6371.0088
const SEGMENTS := 64

static func direction(place: Dictionary) -> Vector3:
    var lat := deg_to_rad(float(place.latitude))
    var lon := deg_to_rad(float(place.longitude)) + PI
    return Vector3(sin(lon)*cos(lat),sin(lat),cos(lon)*cos(lat))

static func angle(a: Vector3, b: Vector3) -> float:
    return atan2(a.cross(b).length(),clampf(a.dot(b),-1.0,1.0))

static func distance(a: Dictionary, b: Dictionary) -> float:
    return angle(direction(a),direction(b))*RADIUS_KM

static func arc(a: Dictionary, b: Dictionary) -> PackedVector3Array:
    var start := direction(a)
    var finish := direction(b)
    var sweep := angle(start,finish)
    var axis := start.cross(finish)
    # Antipodes have infinitely many shortest routes. Pick one stable plane.
    if axis.length_squared() < 1e-12:
        axis = start.cross(Vector3.UP if absf(start.y)<0.9 else Vector3.RIGHT)
    axis = axis.normalized()
    var points := PackedVector3Array()
    for index in range(SEGMENTS+1):
        var fraction := float(index)/SEGMENTS
        var point := start.rotated(axis,sweep*fraction)
        if index == SEGMENTS: point = finish
        if sweep<1e-7:
            points.append(start*1.018)
            continue
        points.append(point*(1.018+0.045*sin(PI*fraction)))
    return points

static func total(stops: Array) -> float:
    var result := 0.0
    for index in range(1,stops.size()): result += distance(stops[index-1],stops[index])
    return result
