# Lunar observatory — 0.21.0 candidate

User requested a high-definition Moon, appropriate lunar cycles, biblical/Hebrew observance tags, celestial dates and simple screensaver activation. This candidate combines that work with Journey studio and the explicit Windows idle setup from unreleased 0.20.0. Nothing in this note establishes a Windows release pass or feed promotion.

## Moon rendering

The old 1024×512 spinning moon is replaced in active rendering by a native 4096×2048 NASA SVS 2025 LROC surface-map edition. Source TIFF: https://svs.gsfc.nasa.gov/vis/a000000/a004700/a004720/lroc_color_16bit_srgb_4k.tif . Source page and credit: https://svs.gsfc.nasa.gov/4720/ . NASA SVS / LRO / LROC / LOLA; visualization Ernie Wright, scientist Noah Petro. NASA media use: https://www.nasa.gov/nasa-brand-center/images-and-media/ . No NASA endorsement is implied.

The map is converted from 16-bit sRGB TIFF to RGB JPEG (quality 96, no chroma subsampling, no resize/upscale). Source SHA256 `9731fa8af425b6c2f88f277ecca82bf8c603f3743894f64ed7b25c5bfefa22ff`; derivative `aa3ff7bb7ca7a83005b64d1754d0c3d53e906a267ed80724f607374021e74954`. It is a normalized visual composite with lower-resolution polar fill, not a current capture or uniform-resolution scientific image.

The large viewer uses a circular ray/sphere surface lookup, north-up lunar map orientation, source sub-Earth libration and a terminator calculated from the subsolar direction. There is no atmosphere, glow, arbitrary spin or Earth light imposed on the disk. Photometry is illustrative, without terrain relief/shadows, eclipse obscuration or local-horizon rotation. Backdrop placement/size remains illustrative and is not a predicted orbit or local-sky position.

### Coverage and uncertainty

- NASA 2026 source: https://svs.gsfc.nasa.gov/5587/ and https://svs.gsfc.nasa.gov/vis/a000000/a005500/a005587/mooninfo_2026.json . Raw 8760 hourly records retained, SHA256 `098ec6434ba4fecb84e66485385816d465b7969f142864bcfc9ffc68311b4a86`. Lookup uses the preceding UTC hour, with its time visible. This is predicted geocentric geometry, not an observation. The numerical illuminated fraction is checked against the shader's subsolar/sub-Earth vector geometry.
- 2027–2030 disks interpolate angular phase between successive published USNO quarter-phase events. These are explicitly labelled **Estimated disk**, do not claim NASA precision, and invent neither distance nor libration. Exact event dates/times stay separate. Outside supported bracketing data the Moon is unavailable, never silently frozen/extrapolated as current.
- Current mode follows device UTC once per minute; manual date preview uses civil date at 12:00 UTC; astronomical event selection uses that event’s published UTC instant. Now restores current time. No device-clock writes or hidden geolocation are used.

## Calendar data and conventions

Hebcal.com API content is licensed CC BY 4.0: https://www.hebcal.com/home/developer-apis . Annual Israel and Diaspora responses for Gregorian 2026–2030 are retained under `data/calendar/`. Request pattern: `https://www.hebcal.com/hebcal?v=1&cfg=json&year=2026&maj=on&min=on&nx=on&i=off` (`i=on` for Israel). Concise labels and category tags adapt the data; original raw records, calendar versions, title, Hebrew date, link and license remain available. In-app credits identify Hebcal and link to the source and license.

The calendar is the traditional fixed Hebrew calendar, not a visible-crescent, barley-observation or other alternative calendar. Pesach, Shavuot, Rosh Hashana, Yom Kippur, Sukkot and Shmini Atzeret are tagged as Torah festivals. Other observances, including Purim, Hanukkah and Rosh Chodesh, remain separately identified. The cattle new year is not classified as Feast of Trumpets. For each listed full Hebrew day, its preceding civil sunset date is visible. Erev rows are omitted to avoid double-counting/mistaking an eve date for a full day. No actual local sunset, candle-lighting or festival-end time is supplied. Astronomical conjunction, visible crescent and Rosh Chodesh are distinct.

Five years of USNO principal phase events, plus the first 2031 event to bracket the final supported 2030 date, are retained from `https://aa.usno.navy.mil/api/moon/phases/year?year=2026` through 2030. USNO API documentation: https://aa.usno.navy.mil/data/api.html . Phases are event instants in UTC; Hebrew dates are civil date labels, not UTC instants. The UI keeps these semantics separate.

Solar events for 2026–2028 come from `https://aa.usno.navy.mil/api/seasons?year=2026` etc. The 2029/2030 API was unavailable; their four equinox/solstice dates/times are transcribed from the USNO table reproduced by NOAA/NWS: https://www.weather.gov/dvn/Climate_Astronomical_Seasons . These rows retain that distinct source/credit; no missing aphelion/perihelion is invented. Use month-based event names so northern/southern seasons are not confused. UTC times are rounded to the source's minute precision.

## Interaction and release gates

Live Earth → Moon & Hebrew calendar opens an offline full-window view. It stops the tour and closes camera/photo overlays. The date control rejects malformed/out-of-range dates before calling the engine parser; current-time and Back to Earth controls remain visible at compact sizes. Screensaver entry closes the viewer and clears date-preview follow state; it does not alter lighting/imagery preferences. The optional globe backdrop uses the current phase independently of preview date. Native saver startup never constructs the calendar UI or initiates a provider request.

Required: complete source and malformed-input regression, seven native sizes through 5K, multiple waxing/waning/new/full screenshots, packaged data inclusion, actual installed Windows controls and current/estimated distinction, upgrade/rollback/settings, full framebuffer matrix and preview lifecycle soak, independent public bytes/provenance, unchanged trust key and production updater. Pending checks are not passes.
