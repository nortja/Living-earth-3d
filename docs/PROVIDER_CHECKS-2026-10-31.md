# Actual provider checks — 2026-10-31

Manual checks near 19:06 UTC ran through frozen 0.18.2's Linux source paths, Godot 4.6.3 and the real public endpoints. These are separate from synthetic Windows/native layout fixtures and are not startup behavior or a recurring provider poll.

| Service | Actual result | Limit |
| --- | --- | --- |
| NPS/USGS image cameras | 8/8 images decoded; a real Mammoth conditional response reported unchanged | Retrieval/check time does not verify capture freshness; images are periodic, not continuous video |
| Open-Meteo model layer | 32/32 fixed public points accepted with model UTC retained | Dated model estimates, not station observations or a global field |
| NASA GIBS NOAA-20 / VIIRS | 2026-10-30 mosaic decoded at 2048×1024 | Daily composite with real no-data gaps, not a simultaneous/current cloud photo |

The camera run covered Mammoth, Electric Peak, Mount Washburn, Giant Forest, Yavapai Point, Look Rock, Alpine Visitor Center and Kīlauea V1. No user coordinates/account were sent. No signing key was used. Availability at this check does not promise future provider behavior or prove the user's Windows network configuration.

Raw generated logs: [cameras](evidence/provider-camera-2026-10-31.txt), [model points](evidence/provider-weather-2026-10-31.txt), [NASA](evidence/provider-satellite-2026-10-31.txt). Provider credits/terms remain in the feature documentation and UI.
