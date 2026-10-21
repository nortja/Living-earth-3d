# Camera source verification

Checked 2026-10-20. Camera coordinates are approximate globe destinations. Source images are requested only when a viewer or visible wall tile is selected. No photos are bundled as substitutes for current images. Retrieval time is distinct from provider capture time; dark, obscured, unavailable or unchanged frames remain possible.

## 0.10.0 additions

| View | Official page | Verified image endpoint | Cadence and rights |
| --- | --- | --- | --- |
| Grand Canyon, Yavapai Point | https://www.nps.gov/media/webcam/view.htm?id=6AB2E06A-B28C-A55F-6E7C6519E2AA8F51 | https://www.nps.gov/featurecontent/ard/webcams/images/grcalarge.jpg | NPS air-quality network, about 15 minutes; availability may be seasonal. 3840×2160 JPEG observed. |
| Great Smoky Mountains, Look Rock | https://www.nps.gov/media/webcam/view.htm?id=6878C635-B83A-8F41-A6E3B0160539BEAA | https://www.nps.gov/featurecontent/ard/webcams/images/grsmlarge.jpg | NPS air-quality network, about 15 minutes. 3840×2160 JPEG observed. |
| Rocky Mountain, Alpine Visitor Center | https://www.nps.gov/media/webcam/view.htm?id=81B4681E-1DD8-B71B-0B8311E4FAC15EF4 | https://www.nps.gov/webcams-romo/alpine_visitor_center.jpg | NPS periodic image. 1920×1080 JPEG observed. Weather and seasonal outages possible. |
| Kīlauea, west Halemaʻumaʻu V1 | https://www.usgs.gov/volcanoes/kilauea/v1cam-kilauea-volcano-hawaii-west-halemaumau-crater | https://volcanoes.usgs.gov/observatories/hvo/cams/V1cam/images/M.jpg | Official USGS media page explicitly labels Public Domain. 1920×1080 JPEG observed. Visible light, not thermal; view may move and can be dark or obscured. |

The official NPS camera pages directly link the listed images. NPS air-quality network cadence: https://www.nps.gov/features/ard/webcams/ . Federal-agency imagery is credited to its provider; third-party material is not treated as public domain merely because it appears on a government page. These are NPS-operated cameras, with no separate third-party credit observed. USGS media rights: https://www.usgs.gov/media/webcams/v1cam-kilauea-volcano-hawaii-west-halemaumau-crater . No agency endorsement is implied.

Existing Mammoth Hot Springs, Electric Peak, Mount Washburn and Giant Forest endpoints are preserved. Giant Forest is assigned the air-quality network’s 15-minute cadence. Eight distinct in-app image feeds and four external provider pages are available. A nine-tile wall leaves one tile empty when filled with different sources.

Camera Wall downsamples images to a maximum 1920-pixel texture edge; the focused viewer retains available detail up to 4096 pixels. At most two wall requests run together. Backoff uses each source’s refresh interval and remains bounded; unchanged-frame warnings wait at least two provider periods (five minutes minimum). This avoids treating a normal 15-minute frame as a five-minute outage.

Continuous video remains pending. YouTube/provider streams are not scraped or proxied, and image polling is not advertised as video. Yosemite Conservancy usage agreement remains unresolved, so those views are not newly embedded.
