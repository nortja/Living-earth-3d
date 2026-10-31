# Expanded public weather sample (0.14.0 candidate)

The optional global sample expands from sixteen to 32 fixed public places. It remains a point sample, not a continuous global weather field. No device coordinates are used. New locations were resolved through Open-Meteo's GeoNames-backed geocoding service on 2026-10-31; populated-place/country identity was checked (Vancouver city, not Vancouver Island).

| Place | Latitude | Longitude | GeoNames ID | Geocoding source |
| --- | ---: | ---: | ---: | --- |
| Vancouver, Canada | 49.24966 | -123.11934 | 6173331 | [Open-Meteo](https://geocoding-api.open-meteo.com/v1/search?name=Vancouver&count=10&language=en&format=json) |
| Mexico City, Mexico | 19.42847 | -99.12766 | 3530597 | [Open-Meteo](https://geocoding-api.open-meteo.com/v1/search?name=Mexico+City&count=10&language=en&format=json) |
| Honolulu, United States | 21.30694 | -157.85834 | 5856195 | [Open-Meteo](https://geocoding-api.open-meteo.com/v1/search?name=Honolulu&count=10&language=en&format=json) |
| Buenos Aires, Argentina | -34.61315 | -58.37723 | 3435910 | [Open-Meteo](https://geocoding-api.open-meteo.com/v1/search?name=Buenos+Aires&count=10&language=en&format=json) |
| Santiago, Chile | -33.45694 | -70.64827 | 3871336 | [Open-Meteo](https://geocoding-api.open-meteo.com/v1/search?name=Santiago&count=10&language=en&format=json) |
| Lima, Peru | -12.04318 | -77.02824 | 3936456 | [Open-Meteo](https://geocoding-api.open-meteo.com/v1/search?name=Lima&count=10&language=en&format=json) |
| Beijing, China | 39.9075 | 116.39723 | 1816670 | [Open-Meteo](https://geocoding-api.open-meteo.com/v1/search?name=Beijing&count=10&language=en&format=json) |
| Seoul, South Korea | 37.566 | 126.9784 | 1835848 | [Open-Meteo](https://geocoding-api.open-meteo.com/v1/search?name=Seoul&count=10&language=en&format=json) |
| Cebu City, Philippines | 10.31672 | 123.89071 | 1717512 | [Open-Meteo](https://geocoding-api.open-meteo.com/v1/search?name=Cebu+City&count=10&language=en&format=json) |
| Bangkok, Thailand | 13.75398 | 100.50144 | 1609350 | [Open-Meteo](https://geocoding-api.open-meteo.com/v1/search?name=Bangkok&count=10&language=en&format=json) |
| Jakarta, Indonesia | -6.21462 | 106.84513 | 1642911 | [Open-Meteo](https://geocoding-api.open-meteo.com/v1/search?name=Jakarta&count=10&language=en&format=json) |
| Auckland, New Zealand | -36.84853 | 174.76349 | 2193733 | [Open-Meteo](https://geocoding-api.open-meteo.com/v1/search?name=Auckland&count=10&language=en&format=json) |
| Athens, Greece | 37.98376 | 23.72784 | 264371 | [Open-Meteo](https://geocoding-api.open-meteo.com/v1/search?name=Athens&count=10&language=en&format=json) |
| Istanbul, Republic of Türkiye | 41.01384 | 28.94966 | 745044 | [Open-Meteo](https://geocoding-api.open-meteo.com/v1/search?name=Istanbul&count=10&language=en&format=json) |
| Cairo, Egypt | 30.06263 | 31.24967 | 360630 | [Open-Meteo](https://geocoding-api.open-meteo.com/v1/search?name=Cairo&count=10&language=en&format=json) |
| Casablanca, Morocco | 33.58831 | -7.61138 | 2553604 | [Open-Meteo](https://geocoding-api.open-meteo.com/v1/search?name=Casablanca&count=10&language=en&format=json) |

The first sixteen locations retain their original names/coordinates. ISO country codes support local filtering; common US/USA, UK/GB, UAE/AE and Turkey/Türkiye terms are handled locally. Filtering choices never makes a network request or moves marker labels. Picker metadata refers to the accepted-point index, so filtering and omitted provider rows cannot redirect a selection to the wrong city. The globe still shows the loaded sample; the filter narrows the picker only.

Requests are manual and have a ten-minute cooldown. The 32-place bound, exact batch length, coordinate/ID/unit/value/time checks, per-row omissions, cancellation tokens and expiry rules remain enforced. Model time and retrieval time stay separate. The cache uses the fixed dataset's hash: old sixteen-place caches are ignored rather than relabelled. Startup/native screensaver behavior remains offline.

Sources: https://open-meteo.com/en/docs/geocoding-api ; https://open-meteo.com/en/docs ; GeoNames, https://www.geonames.org/ . Forecast attribution/licensing remains Open-Meteo, CC BY 4.0. Current free-service limits and non-commercial eligibility were checked at https://open-meteo.com/en/terms and https://open-meteo.com/en/pricing on 2026-10-31. The existing personal-preview distribution dependency remains: commercial/advertising use requires an appropriate arrangement. No paid plan/key is purchased or bundled.
