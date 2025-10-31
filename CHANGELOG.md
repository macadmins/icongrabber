# Changelog

All notable changes to Icon Grabber will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - YYYY-MM-DD

### Added
- Initial release
- Extract icons from macOS applications
- Support for custom sizes (16x16 to 1024x1024)
- PNG output format
- Command-line interface
- Man page documentation
- Batch processing examples

### Features
- Fast, native Swift implementation
- No external dependencies
- High-quality icon extraction
- Scriptable and automatable

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

### Example Entry

```markdown
## [1.1.0] - 2024-01-15

### Added
- Support for ICNS file output format
- `--format` flag to choose output format (png or icns)
- Progress indicator for batch operations

### Fixed
- Crash when processing apps without icons
- Incorrect aspect ratio for non-square icons

### Changed
- Improved error messages
- Faster icon extraction algorithm
```

[Unreleased]: https://github.com/kitzy/icongrabber/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/kitzy/icongrabber/releases/tag/v1.0.0
