# Camera Last-Modified weekday validation

Status: candidate on `fix/camera-imf-weekday-validation`; Linux/Windows source and native validation pending.

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

Pending the dedicated pinned Godot 4.6.3 Linux and Windows camera workflow. It must pass camera viewer, revalidation, expansion and Camera Wall suites plus native camera-age rendering on both operating systems. Windows uses checksum-pinned test-only software OpenGL; Linux uses a virtual desktop. These do not establish physical Dell GPU/DPI, mixed-monitor movement, actual provider cache behavior or sleep/wake hardware behavior.

## Release

No installer or release artifact was built or published. The production authenticated feed, pinned RSA trust key, updater integrity inventory, preferences and saved scenes are untouched. The existing release gates remain mandatory for any future release.
