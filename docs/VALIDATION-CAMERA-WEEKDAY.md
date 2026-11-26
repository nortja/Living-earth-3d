# Camera Last-Modified weekday validation

Status: merged into `main` in [PR #23](https://github.com/nortja/Living-earth-3d/pull/23), squash commit [8b4b3c3](https://github.com/nortja/Living-earth-3d/commit/8b4b3c30ed1e73aa0b69b7b9503f54b6f03f7c25). The post-February leap-year correction passed the targeted pinned Godot 4.6.3 Linux/Windows workflow [45879310762](https://github.com/nortja/Living-earth-3d/actions/runs/45879310762).

## Change

The camera service accepts a provider's Last-Modified value as an `If-Modified-Since` validator only when it is a fixed-width IMF-fixdate with valid time fields, a valid Gregorian calendar day (including leap-year rules), and a weekday abbreviation that matches the actual date.

The weekday check uses integer Gregorian day arithmetic from 0001-01-01 (Monday). Leap years add February 29 to the month offsets for every date after February, not only when the input month is February. The accepted four-digit HTTP-date range begins at 1601, so the calculation is bounded and does not depend on local timezone or wall-clock settings.

ETag remains preferred. At most one conditional validator is sent. Display-only provider timestamps remain display-only when invalid, and 304 acceptance continues to require a validator on the current request. No camera source, URL allowlist, capture-time claim, image retention, retry policy or network behavior changes.

## Added regression cases

- Accept 1601-01-01 Monday, the lower supported HTTP-date boundary.
- Accept 2000-02-29 Tuesday, a Gregorian century leap year.
- Accept 2024-03-01 Friday and 2000-03-01 Wednesday, proving the leap-day offset is included after February.
- Accept 1900-03-01 Thursday, proving a non-leap century does not add a day.
- Continue accepting 1994-11-06 Sunday and 2024-02-29 Thursday.
- Reject mismatched weekday/date pairs, including 1994-11-06 labeled Monday and 2024-02-29 labeled Wednesday.
- Preserve rejection of impossible calendar dates, invalid times, obsolete formats and header-injection strings.

## Validation

The targeted pinned Godot 4.6.3 Linux/Windows workflow [45879310762](https://github.com/nortja/Living-earth-3d/actions/runs/45879310762) passed both jobs. Each OS passed 417 assertions: camera viewer 57, camera revalidation 256, camera expansion 26 and Camera Wall 78. Native camera-age rendering passed with zero failures on both platforms. Linux used virtual-desktop renders at 870×612, 2496×1664 and 3840×1080; Windows used checksum-pinned test-only software OpenGL at 870×612. An independent Gregorian arithmetic cross-check covered every date from 1601-01-01 through 9999-12-31 (3,067,671 dates) and matched Python's calendar weekday for all dates. A broader no-publication screensaver/installer workflow [45879310922](https://github.com/nortja/Living-earth-3d/actions/runs/45879310922) was still in progress when this record was updated and is not counted. No live provider request is required. Software-rendered CI does not establish physical Dell GPU/DPI, mixed-monitor movement, actual provider cache behavior or sleep/wake hardware behavior.

## Release

No installer or release artifact was built or published. The production authenticated feed, pinned RSA trust key, updater integrity inventory, preferences and saved scenes are untouched. The existing release gates remain mandatory for any future release.
