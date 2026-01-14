# Changelog

All notable changes to Icon Grabber will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed
- Fixed icon sizing bug where output images were created at 2× the requested dimensions (e.g., 512px request would produce 1024px output) ([#3](https://github.com/macadmins/icongrabber/issues/3))
- Corrected bitmap creation to use explicit pixel dimensions instead of relying on NSImage.size which was affected by Retina scaling

### Changed
- Improved test suite with pixel dimension verification using `sips` to ensure icons are created at exact requested sizes
- Added 4 new dimension verification tests covering standard icon sizes (64×64, 256×256, 512×512, 1024×1024)

---

## [1.0.0] - 2024-12-15

### Added
- Initial release
- Extract icons from macOS applications
- Support for custom sizes (16x16 to 1024x1024)
- PNG output format
- File size optimization using sips compression
- Command-line interface with intuitive options
- Man page documentation
- Batch processing examples
- Native Swift implementation with no dependencies
- High-quality icon extraction preserving original quality
- Scriptable and automatable for workflows
- Automated build process with code signing and notarization
- GitHub Actions workflows for CI and releases

---

## How to Update This Changelog

When preparing a release, move items from [Unreleased] to a new version section.

### Categories

- **Added** for new features
- **Changed** for changes in existing functionality
- **Deprecated** for soon-to-be removed features
- **Removed** for now removed features
- **Fixed** for any bug fixes
- **Security** for vulnerability fixes

[Unreleased]: https://github.com/macadmins/icongrabber/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/macadmins/icongrabber/releases/tag/v1.0.0
