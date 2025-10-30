Changelog

All notable changes to Icon Grabber will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/../),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v1.0.0.html).

[Unreleased]

Added
- Automated release workflow with code signing and notarization
- PKG installer for easy distribution

[..] - YYYY-MM-DD

Added
- Initial release
- Extract icons from mac OS applications
- Support for custom sizes (xto x)
- PNG output format
- Command-line interface
- Man page documentation
- Batch processing examples

Features
- Fast, native Swift implementation
- No external dependencies
- High-quality icon extraction
- Scriptable and automatable

---

How to Update This Changelog

When preparing a release, move items from [Unreleased]to a new version section.

Categories

- Addedfor new features
- Changedfor changes in existing functionality
- Deprecatedfor soon-to-be removed features
- Removedfor now removed features
- Fixedfor any bug fixes
- Securityfor vulnerability fixes

Example Entry

```markdown
[..] - --
Added
- Support for ICNS file output format
- `--format` flag to choose output format (png or icns)
- Progress indicator for batch operations

Fixed
- Crash when processing apps without icons
- Incorrect aspect ratio for non-square icons

Changed
- Improved error messages
- Faster icon extraction algorithm
```

[Unreleased]: https://github.com/kitzy/icongrabber/compare/v1.0.0...HEAD
[..]: https://github.com/kitzy/icongrabber/releases/tag/v1.0.0