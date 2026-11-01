# Regional infrared pilot — 0.22.0 candidate

Implemented 2026-11-01; Windows release gates pending. Default drifting clouds remain offline artwork. The previous-day VIIRS mosaic is separate. This pilot adds explicitly requested NOAA GOES-West/GOES-East ABI Clean Infrared (10.3 µm, Band 13, ten-minute) visualization via NASA GIBS. It shows cloud tops and land/ocean brightness temperatures in false color, with a readable retained NASA color scale. It does not cover the Philippines or all Earth.

## Identity and permission

Exact products: `GOES-West_ABI_Band13_Clean_Infrared` and `GOES-East_ABI_Band13_Clean_Infrared`. [NASA metadata](https://gibs.earthdata.nasa.gov/layer-metadata/v1.0/GOES-West_ABI_Band13_Clean_Infrared.json) identifies the band and subdaily period; [NASA access documentation](https://nasa-gibs.github.io/gibs-api-docs/access-basics/) supplies DescribeDomains and exact timestamp WMTS retrieval. [NOAA imagery guidance](https://www.nesdis.noaa.gov/imagery/interactive-maps/how-use-the-interactive-satellite-maps) permits informational/educational graphical use with NOAA credit. [NASA guidance](https://www.nasa.gov/nasa-brand-center/images-and-media/) applies to its color-map/visualization assets. No third-party Himawari product is assumed cleared. Product IDs, links, original numeric XML and derivative hashes are retained under `assets/weather/` and credit appears in the app.

## Retrieval and display

- Explicit Load only. Metadata lists supported nominal scan instants. The recent choice applies a thirty-minute distribution buffer; older choices select supported scans about one/three/twelve hours earlier than the metadata's latest scan. Metadata gaps choose an earlier advertised instant. No silent nearest-image HTTP substitution is requested.
- Fifteen exact 512px WMTS tiles, EPSG:4326 `2km` matrix level 2, at most two concurrent requests, cropped to 2560×1280. The source matrix name is not a claim of native 2km output detail. Each tile is bounded to 4MiB and exact dimensions before decode; metadata to 256KiB. No redirects, 25-second per-request timeout, ten-minute cooldown per source/time choice.
- Commit only after all tiles validate and the assembled scene contains observations. Missing/invalid/empty/cancelled/late responses keep the old pixels, source and time together. Transparent no-data remains transparent over the offline globe; it cannot establish cloud-free sky.
- Full nominal UTC scan/date, retrieval time, age and OLD SCENE after two hours. Nominal scan time is not the same acquisition time for every pixel. The compact visible badge retains the full date. No forecast/alert/rainfall or surface-air-temperature claim.
- Return cancels requests and restores the previous offline Earth or retained dated NASA mosaic without another download. Artistic cloud drift/shadow is suppressed. Simulated sunlight and screensaver preview suspend the layer; native saver hosts never construct the service. No startup/background downloads, tracking or stored image preferences.

## Evidence and remaining scope

Actual in-app HTTP retrieval of both regions passed on 2026-11-01; metadata records exact scan/retrieval times and maximum two requests. Source state/geometry/failure tests and native layouts include 800×600, laptop 2496×1664, Dell 3840×1080 and 5K. Installed Windows controls, upgrade/rollback, settings, lifecycle and display matrix remain required before feed promotion. Continuous playback, animation, Asia/global cloud coverage and physical hardware validation remain future work.
