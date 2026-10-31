"""Reduce a pinned public-domain Natural Earth file. No network or app runtime work."""
import argparse
import hashlib
import json
import math
from pathlib import Path

SOURCE_URL = 'https://raw.githubusercontent.com/nvkelso/natural-earth-vector/117488dc884bad03366ff727eca013e434615127/geojson/ne_110m_populated_places.geojson'
SOURCE_SHA256 = 'a86028b083182b68c7620fc6e1a8a47ee547cb9cd2fb62ccbb78bea786440899'

def convert(raw: bytes) -> list[dict]:
    if hashlib.sha256(raw).hexdigest() != SOURCE_SHA256:
        raise ValueError('Pinned Natural Earth source checksum differs')
    features = json.loads(raw)['features']
    if len(features) != 243:
        raise ValueError('Expected 243 Natural Earth places')
    places = []
    identities = set()
    for feature in features:
        p = feature['properties']
        lon, lat = feature['geometry']['coordinates']
        if not all(math.isfinite(n) for n in [lat, lon]) or not (-90 <= lat <= 90 and -180 <= lon <= 180):
            raise ValueError('Invalid source coordinates')
        identity = str(p['NE_ID'])
        if identity in identities:
            raise ValueError('Duplicate Natural Earth identifier')
        identities.add(identity)
        city = p.get('NAME_EN') or p['NAME']
        country = p['ADM0NAME']
        aliases = list(dict.fromkeys(str(p[k]) for k in ['NAME', 'NAMEASCII', 'NAMEALT', 'ADM0NAME', 'ISO_A2'] if p.get(k) and (k != 'ISO_A2' or (len(p[k]) == 2 and p[k].isalpha()))))
        places.append({'id': 'natural-earth-' + identity, 'name': city + ', ' + country,
                       'latitude': lat, 'longitude': lon, 'country_code': p['ISO_A2'] if len(p.get('ISO_A2') or '') == 2 and p['ISO_A2'].isalpha() else '',
                       'aliases': aliases, 'source': 'Natural Earth 1:110m populated places',
                       'note': 'Approximate city reference point from Natural Earth. Modern globe imagery; no street-level or current population claim.'})
    return sorted(places, key=lambda p: p['name'].casefold())

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--source', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    args.output.write_text(json.dumps(convert(args.source.read_bytes()), ensure_ascii=False, indent=2) + '\n')
    print('Wrote 243 source-validated city reference points')
