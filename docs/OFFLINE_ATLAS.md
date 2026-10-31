# Expanded offline reference atlas

Explore → Search → Search offline atlas searches bundled city reference points and the original places without a network request. The added dataset contains 243 Natural Earth 1:110m populated places; matching original city entries retain their existing names/coordinates and gain aliases instead of duplicate results. Nearby heritage sites remain distinct. The combined atlas contains more than 250 places; it is a selected reference atlas, not every settlement or a street map.

Country/place terms and common US/USA, UK/GB, UAE/AE and Turkey/Türkiye forms work locally. An exact available two-letter country code filters that country, avoiding incidental city-name matches. Latin accent folding finds São Paulo with Sao Paulo. Exact city names sort first, then city prefixes and other matches. Eight results appear per page, with previous/next controls and a total/page count. New searches reset paging; coordinate search and explicit online OpenStreetMap search remain separate. Query length is bounded to 80 characters.

Names/coordinates describe approximate city reference locations on modern globe imagery. No current population, street-level, city-boundary or reconstruction claim is made. Upstream geographic labels are retained; the app does not derive political boundaries from them. Source identifiers and a Natural Earth note follow a selected city into its destination. No location tracking, startup download or new native-saver requests are introduced.

## Provenance and reproduction

Natural Earth 1:110m populated places, version 5.1.2, checked 2026-10-31. Primary description: https://www.naturalearthdata.com/downloads/110m-cultural-vectors/110m-populated-places/ . Terms: https://www.naturalearthdata.com/about/terms-of-use/ . The publisher releases its vector data into the public domain and permits modification/redistribution. Made with Natural Earth; contributors include Tom Patterson and Nathaniel Vaughn Kelso.

Pinned upstream commit: `117488dc884bad03366ff727eca013e434615127`; GeoJSON source: https://raw.githubusercontent.com/nvkelso/natural-earth-vector/117488dc884bad03366ff727eca013e434615127/geojson/ne_110m_populated_places.geojson . Exact source size 654,324 bytes, SHA256 `a86028b083182b68c7620fc6e1a8a47ee547cb9cd2fb62ccbb78bea786440899`. The pinned commit's bytes were downloaded independently and matched the checked source.

Maintainer conversion: `python packaging/data/build_offline_atlas.py --source <downloaded-source.geojson> --output data/atlas_cities.json`. It performs no network request, requires the exact source checksum and 243 features, verifies coordinates/unique IDs, keeps city/country/ASCII aliases and drops population/unrelated metadata. Unassigned upstream country codes remain empty rather than becoming invented ISO codes. All generated data ships in the app; the converter/upstream full file do not.
