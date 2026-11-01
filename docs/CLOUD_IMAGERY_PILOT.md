# Current-cloud pilot: source and truthfulness gates

Planning note, 2026-11-01. The default drifting clouds remain offline artwork. The dated NOAA-20/VIIRS surface already released is a daily true-color mosaic; it is not a current global cloud layer.

## Source selection

NASA GIBS documents each visualization's temporal period, platform/instrument, spatial reference and underlying product. Its near-real-time availability statement applies to many products, not every layer or pixel. A newly downloaded daily image does not establish a new capture time. [Official GIBS visualization catalog documentation](https://nasa-gibs.github.io/gibs-api-docs/available-visualizations/).

Before implementation, resolve one exact cloud product and its underlying metadata, distribution permission, attribution, validity/no-data mask, timestamp semantics, footprint, projection and actual request cadence. Check the particular product's credit rather than treating a NASA-hosted URL as proof of ownership or permission. [NASA media guidance](https://www.nasa.gov/nasa-brand-center/images-and-media/). The catalog's dynamic product table did not load during this review, so no exact cloud layer is selected or permission-cleared by this note.

## First bounded release

- One supported product/region with its true coverage visible; do not fill missing regions or claim global coverage before it exists.
- Visible observation time or observation interval, source, retrieval time and age. Distinguish mask/false-color science imagery from a natural-color cloud photograph.
- Explicit opt-in retrieval, provider-appropriate cooldown, compressed/pixel/decode bounds and one retained valid texture. Do not animate observed clouds with artistic drift.
- Transparent no-data and retained-date warnings on failure; immediate offline return. Keep requested surface mosaics and the sunlight simulation separate.
- No startup/native-saver downloads. Prove cancellation and late-response rejection on view/source change, plus ordinary offline use and bounded CPU/GPU memory.
- Native render/source checks, actual Windows package/upgrade/rollback/lifecycle/display gates, verified public bytes and authenticated feed promotion remain required.

No provider integration, fresh cloud observation or global freshness guarantee is delivered by this planning work.
