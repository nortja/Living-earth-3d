# Recent days from orbit

Live Earth → Recent days from orbit lets you choose one of the previous seven UTC dates, defaulting to yesterday. Pressing Load requests one dated 2048×1024 PNG from NASA GIBS. It displays the NOAA-20 / VIIRS corrected-reflectance true-color daily mosaic on the existing globe. Drag, zoom, arrivals and reset use the same geographic UV mapping. WMS 1.1.1 EPSG:4326 with longitude/latitude bounding box -180,-90,180,90 avoids WMS 1.3 axis-order ambiguity.

This is a daily mosaic assembled from multiple satellite passes, not a live cloud map or a simultaneous photograph. The requested UTC date and separate retrieval timestamp stay visible; the header retains the mosaic date while browsing. Black areas mean unavailable imagery, including seasonal darkness or gaps. No missing areas are fabricated or silently filled using offline photography. The snapshot is unshaded: it does not add current lighting, artificial cloud drift or night lights to historical observations. Atmosphere, Moon and stars remain artistic. The base 2K/4K Earth is unaffected and returns immediately using Return to offline Earth.

The default source is VIIRS because its wider swaths offer better geographic coverage than the initially investigated MODIS Terra daily layer. No promise of complete coverage, capture freshness, 4K detail or future availability is made. The exported globe source is 2048×1024, regardless of viewport size.

The request is manual, with a one-minute cooldown, HTTPS, no redirects, a 30-second timeout and a 16 MiB limit. PNG signature and exact expected dimensions are checked before decompression. Blank/unavailable images leave any previous snapshot clearly dated. Cancellation uses generation tokens. The service is absent in native screensavers; in-app preview cancels pending work, suspends its surface and restores the prior surface without a new request. Nothing downloads at startup, on a timer, on resume or when returning from preview. Only one image remains in memory for the current session. Selecting another date sends no request and does not relabel the displayed observation. The picker is disabled during a request; failures retain the previous texture and observation date. Dates are recomputed from the device UTC clock when opening the panel and loading. Today, future dates and arbitrary older dates are excluded. Offline Earth stays beside Load, visible without scrolling even at 800×600. The request sends a fixed global extent and date, never device coordinates or a user account.

## Sources and acknowledgement

- NASA GIBS access and WMS projection documentation: https://nasa-gibs.github.io/gibs-api-docs/access-basics/
- Available visualization definitions and temporal periods: https://nasa-gibs.github.io/gibs-api-docs/available-visualizations/
- NASA LAADS lists VIIRS NOAA-20 corrected reflectance true color: https://ladsweb.modaps.eosdis.nasa.gov/view-data/
- NASA Worldview documentation explains the narrower MODIS swath gaps and wider VIIRS overlap: https://earthdata.nasa.gov/s3fs-public/2025-03/worldview-booklet.pdf
- Service capabilities, checked 2026-10-31: https://gibs.earthdata.nasa.gov/wms/epsg4326/best/wms.cgi?SERVICE=WMS&REQUEST=GetCapabilities&VERSION=1.1.1
- NASA GIBS data-use guidance and acknowledgement: https://nasa-gibs.github.io/gibs-api-docs/

Imagery is provided through NASA Global Imagery Browse Services (GIBS), part of NASA's Earth Science Data and Information System (ESDIS). Instrument/platform: VIIRS / NOAA-20. The UI credits these sources and links to their data-use guidance. No NASA endorsement or ownership of NASA identifiers is implied.

## Evidence

Local tests cover UTC leap/year boundaries, fixed request extent/date, pre-decode PNG bounds, blank/error retention, cancellation, source/date labels, artistic-cloud exclusion, offline return, preview isolation, manual cooldown and layouts including 3840×1080. Actual 2026-10-30 and 2026-10-24 NASA GIBS mosaics were retrieved and rendered. Recent-week UTC leap/month/year boundaries, selection without requests, in-flight stability and retained-date identity are tested. Synthetic native/Windows fixtures are explicitly labeled synthetic. Packaged Windows validation must pass before authenticated release promotion; software renders do not establish physical Dell GPU/DPI or sleep behavior.
