# Earth and Moon texture credits

## Solar System Scope / INOVE — CC BY 4.0

The 4096×2048 daytime and night-light maps, 2048×1024 cloud map, and water mask come from the Solar System Scope texture collection, distributed under Creative Commons Attribution 4.0 International:

- Original creator/collection: https://www.solarsystemscope.com/textures/
- License and terms: https://creativecommons.org/licenses/by/4.0/
- Download mirror: https://github.com/neftale99/earth-shader/tree/main/static/Earth
- Mirror's original-source credit: https://github.com/neftale99/earth-shader/blob/main/readme.md

SOURCES.json pins the mirror commit and records checksums, original dimensions, and derivative processing. Balanced maps are 2048-pixel downsamplings of the 4096-pixel originals; no upscaling is used. The water mask is the source combined map's red channel. CC-BY-4.0.txt retains the creator credit, license link, and processing notice with the Windows installation.

Cloud imagery is a static offline artwork dataset. Its drift and the cloud shade are artistic animation; neither represents live weather, current cloud coverage, or wind. No image capture timestamp is claimed.

## Moon — NASA Scientific Visualization Studio / LRO

`moon_4k.jpg` is derived at its native 4096×2048 resolution from NASA SVS's 2025 LROC color-map edition in the CGI Moon Kit: https://svs.gsfc.nasa.gov/4720/. Credit NASA's Scientific Visualization Studio; visualization Ernie Wright (USRA), scientist Noah Petro (NASA/GSFC), LRO/LROC/LOLA instrument teams. Original 16-bit sRGB TIFF was converted to 8-bit RGB JPEG, quality 96, without chroma subsampling or resizing. Exact source and derivative hashes are retained in SOURCES.json. NASA permits educational/informational use with credit under https://www.nasa.gov/nasa-brand-center/images-and-media/; no NASA endorsement is implied.

This map is a normalized composite intended for visual rendering, with lower-resolution polar fill, not a contemporaneous observation or uniform-resolution scientific image. Lighting is an illustration and does not include terrain relief/shadows. NASA 2026 hourly geometry controls illumination and libration in the north-up viewer. Later dates use explicitly labelled interpolation between USNO phase events, with no distance or libration claim. The backdrop has illustrative placement and size, not an orbital or local-sky position. Stars are generated, not a stellar catalog.

The old 1024×512 three.js texture is retained only as an unused legacy asset with its upstream MIT notice in THREE-LICENSE.txt. Current rendering uses the NASA map.

Calendar/ephemeris data provenance and coverage are recorded in docs/LUNAR_OBSERVATORY.md. Calendar content from Hebcal.com is adapted under CC BY 4.0, with source and license links visible in the app.
