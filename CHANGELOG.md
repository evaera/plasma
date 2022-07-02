# Changelog

## [0.3.0] - 2022-07-01
### Added
- Added `hydrateAutomaticSize` function
### Changed
- `automaticSize` no longer applies automatic sizing on the server. Instead, it configures the instance to be compatible with `hydrateAutomaticSize` from the client.
- `automaticSize` now accepts a UDim2 as a `maxSize` for use with Scale
### Fixed
- Fixed `automaticSize` with scrolling frames sometimes causing an infinite content reflow loop.

## [0.2.0] - 2022-06-30
### Added
- Added `useKey`
- Added heading, label, slider, and space widgets
- Add multi-phase frame API with `beginFrame`, `continueFrame`, and `finishFrame`
- Add event callback injection
### Fixed
- Widget state now resets if the widget in the slot changed from last frame

## [0.1.0] - 2021-12-13
- Initial release