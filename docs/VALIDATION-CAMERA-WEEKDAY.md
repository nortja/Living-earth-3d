# Camera Last-Modified weekday validation

Status: merged into `main` in [PR #22](https://github.com/nortja/Living-earth-3d/pull/22), squash commit [f96152c](https://github.com/nortja/Living-earth-3d/commit/f96152c736f63a80c7f31433be2f583a0e9097b0). Pinned Godot 4.6.3 Linux/Windows workflow [45676870010](https://github.com/nortja/Living-earth-3d/actions/runs/45676870010) passed.

## Change

The camera service accepts a provider's Last-Modified value as an `If-Modified-Since` validator only when it is a fixed-width IMF-fixdate with valid time fields, a valid Gregorian calendar day (including leap-year rules), and a weekday abbreviation that matches the actual date.

The weekday check uses integer Gregorian day arithmetic from 0001-01-01 (Monday). The accepted four-digit HTTP-date range begins at 1601, so the calculation is bounded and does not depend on local timezone or wall-clock settings.

ETag remains preferred. At most one conditional validator is sent. Display-only provider timestamps remain display-only when invalid, and 304 acceptance continues to require a validator on the current request. No camera source, URL allowlist, capture-time claim, image retention, retry policy or network behavior changes.

## Added regression cases

- Accept 1601-01-01 Monday, the lower supported HTTP-date boundary.
- Accept 2000-02-29 Tuesday, a Gregorian century leap year.
- Continue accepting 1994-11-06 Sunday and 2024-02-29 Thursday.
- Reject mismatched weekday/date pairs, including 1994-11-06 labeled Monday and 2024-02-29 labeled Wednesday.
- Preserve rejection of impossible calendar dates, invalid times, obsolete formats and header-injection strings.

## Validation

Workflow 45676870010 completed successfully on both Linux and Windows. Each OS passed 414 assertions: camera viewer 57, camera revalidation 253, camera expansion 26 and Camera Wall 78. Native camera-age rendering passed on both platforms. Linux used a virtual desktop at 870×612, 2496×1664 and 3840×1080; Windows used 870×612 with checksum-pinned test-only software OpenGL. No live provider request was made. These results do not establish physical Dell GPU/DPI, mixed-monitor movement, actual provider cache behavior or sleep/wake hardware behavior.

## Release

No installer or release artifact was built or published. The production authenticated feed, pinned RSA trust key, updater integrity inventory, preferences and saved scenes are untouched. The existing release gates remain mandatory for any future release.
