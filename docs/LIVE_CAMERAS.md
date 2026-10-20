# Camera channel — 0.5.4

Selecting a venue now has a visible outcome. Three public NPS Yellowstone image cameras open a modal viewer in the app: Mammoth Hot Springs, Electric Peak and Mount Washburn. The viewer keeps aspect ratio, displays provider credit, supports manual/60-second refresh and shows retrieval time independently from any Last-Modified header. Camera capture freshness is not inferred from download success. Repeated identical bytes for five minutes produce a delay warning. Failed refreshes explicitly label the retained image; changing camera clears the old image. Closing the viewer, changing selection or entering screensaver preview cancels outstanding requests. No image is bundled or substituted for an unavailable source.

Official NPS venue pages and image endpoints were checked 2026-10-20, and all three JPEGs decoded at 1920×1080. These endpoints can later fail or become stale/seasonal. They are **periodic camera images, not embedded continuous video**. Video/seasonal sources (aquarium, Old Faithful, Katmai, USGS and Sequoia) are clearly marked as external and open on their official websites on selection.

Sources:
- https://www.nps.gov/yell/learn/photosmultimedia/webcams.htm
- https://www.nps.gov/media/webcam/view.htm?id=696F20E1-F421-B232-FE72D6D85B157422
- https://www.nps.gov/media/webcam/view.htm?id=81B468AB-1DD8-B71B-0BE84D8E8E0F1112
- https://www.nps.gov/media/webcam/view.htm?id=81B46891-1DD8-B71B-0B6575944D4DECD5
- https://www.nps.gov/aboutus/disclaimer.htm

NPS-created material is generally public domain unless marked otherwise. These NPS-hosted static camera views are credited to NPS; no protection is claimed in original U.S. Government works. No NPS insignia or endorsement is used. Third-party video pages are linked rather than copied or embedded; authorized continuous playback and stream-specific rights remain future work.

Next: an authorized video playback component and Camera Wall layouts for 1/2/4/6/9 views with bounded network/decoder use, saved collections and accurate live/unavailable indicators. Test actual Dell hardware before promising multi-stream performance.
