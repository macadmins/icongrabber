<div align="center">

# Icon Grabber

**A fast, simple command-line tool to extract high-quality icons from macOS applications.**

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-macOS-lightgrey.svg)](https://www.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![CI Tests](https://github.com/kitzy/icongrabber/workflows/CI%20Tests/badge.svg)](https://github.com/kitzy/icongrabber/actions)
[![GitHub Sponsors](https://img.shields.io/github/sponsors/kitzy?logo=github&color=ea4aaa)](https://github.com/sponsors/kitzy)

</div>

## Features

- **Simple & Fast** - Extract icons with a single command
- **Flexible Sizing** - Get icons in any size from 16x16 to 1024x1024
- **High Quality** - Preserves original icon quality in PNG format
- **Scriptable** - Perfect for automation and batch processing
- **Native** - Written in Swift, lightweight, no dependencies

## Installation

### Download Release (Recommended)

Download the latest signed and notarized installer from [Releases](https://github.com/kitzy/icongrabber/releases):

```bash
# Download the latest PKG installer
curl -LO $(curl -s https://api.github.com/repos/kitzy/icongrabber/releases/latest | grep "browser_download_url.*\.pkg" | cut -d '"' -f 4)

# Or if you know the latest version number, use:
# curl -LO https://github.com/kitzy/icongrabber/releases/latest/download/icongrabber-VERSION.pkg

# Install
sudo installer -pkg icongrabber-*.pkg -target /

# Verify installation
icongrabber --version
```

### Build from Source

```bash
# Clone the repository
git clone https://github.com/kitzy/icongrabber.git
cd icongrabber

# Build and install system-wide
make build
sudo make install

# Or install to your home directory (no sudo required)
make build
make install PREFIX=$HOME/.local
export PATH="$HOME/.local/bin:$PATH" # Add to ~/.zshrc
```

## Quick Start

Extract an icon in less than 30 seconds:

```bash
# Extract Safari's icon (creates Safari.png)
icongrabber /Applications/Safari.app

# Custom size
icongrabber /Applications/Safari.app -s 256

# Custom output location
icongrabber /Applications/Safari.app -o ~/Desktop/my-icon.png

# Force overwrite existing file
icongrabber /Applications/Safari.app -f
```

That's it! 

## Usage

### Basic Usage

```bash
icongrabber <app-path> [options]
```

### Options

| Option | Description | Example |
|--------|-------------|---------|
| `-s, --size <pixels>` | Icon size (default: 512) | `-s 256` |
| `-o, --output <path>` | Output file path | `-o icon.png` |
| `-i, --input <path>` | Input app path (alternative) | `-i /Applications/Safari.app` |
| `-f, --force` | Overwrite existing files without prompting | `-f` |
| `-h, --help` | Show help message | `-h` |
| `-v, --version` | Show version | `-v` |

### Common Sizes

- **16x16** - Toolbar icons, favicons
- **32x32** - Small UI elements
- **64x64** - List views, thumbnails
- **128x128** - Standard app icons
- **256x256** - Retina displays
- **512x512** - High-resolution (default)
- **1024x1024** - Maximum quality

## Examples

### Extract a Single Icon

```bash
# Get Safari's icon at 512x512
icongrabber /Applications/Safari.app
```

### Specify Output Location

```bash
# Save to a specific location
icongrabber /Applications/Safari.app -o ~/Desktop/safari-icon.png
```

### Custom Size

```bash
# Get a 256x256 icon
icongrabber /Applications/Safari.app -s 256 -o small-icon.png
```

### Multiple Sizes

```bash
# Extract multiple sizes for the same app
./examples/extract_multiple_sizes.sh /Applications/Safari.app
```

### Batch Processing

```bash
# Extract icons from all applications
./examples/batch_extract.sh
```

### Automation Script

```bash
#!/bin/bash
# Extract icon and use it in your workflow
if icongrabber /Applications/MyApp.app -o assets/icon.png -s 512; then
    echo "✓ Icon extracted successfully"
    # Do something with the icon
    convert assets/icon.png -resize 64x64 assets/icon-small.png
fi
```

## Output

### Default Naming

Icons are automatically named based on the app name (spaces removed):

| Application | Output File |
|-------------|-------------|
| Safari.app | `Safari.png` |
| Visual Studio Code.app | `VisualStudioCode.png` |
| Calculator.app | `Calculator.png` |

### Custom Naming

Use `-o` to specify your own filename:

```bash
icongrabber /Applications/Safari.app -o my-custom-name.png
```

## Development

### Build from Source

```bash
# Clone the repository
git clone https://github.com/kitzy/icongrabber.git
cd icongrabber

# Build
make build

# Run locally
./bin/icongrabber /Applications/Safari.app
```

### Run Tests

```bash
# Run the full test suite
make test

# Tests include:
# - Basic icon extraction
# - Multiple sizes (16, 32, 64, 128, 256, 512, 1024)
# - Custom output paths
# - Error handling
# - CLI argument parsing
```

See [tests/README.md](tests/README.md) for detailed test documentation.

### Clean Build Artifacts

```bash
make clean
```

### Continuous Integration

The project uses GitHub Actions for automated testing:
- Integration tests on every PR
- Multi-version testing (macOS 15, latest)
- Installation verification
- Swift syntax checking

View the [CI workflow](.github/workflows/ci.yml) for details.

## Documentation

- [Contributing Guide](CONTRIBUTING.md) - How to contribute
- [Release Guide](.github/RELEASE_GUIDE.md) - For maintainers: creating releases
- [Test Documentation](tests/README.md) - Test suite details
- [Scripts Documentation](scripts/README.md) - Helper scripts
- Man Page - `man icongrabber` (after installation)

## FAQ

**Q: What formats are supported?** 
A: Currently PNG format only. Icons are extracted at the highest quality available.

**Q: What if an app doesn't have an icon?** 
A: The tool will exit with an error code and display an error message.

**Q: Can I use this in my build scripts?** 
A: Absolutely! The tool returns proper exit codes (0 for success, non-zero for errors) for easy integration.

**Q: Does this work with paths containing spaces?** 
A: Yes! Just wrap the path in quotes: `icongrabber "/Applications/Visual Studio Code.app"`

**Q: Can I use `~` in paths?** 
A: Yes, tilde expansion is supported: `icongrabber ~/Applications/MyApp.app`

## Contributing

Contributions are welcome! Feel free to:

- Report bugs
- Suggest features
- Submit pull requests
- Improve documentation

Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## For Maintainers

### Creating Releases

See the complete [Release Guide](.github/RELEASE_GUIDE.md) for detailed instructions.

**Quick release:**
```bash
# 1. Update CHANGELOG.md
# 2. Create and push tag
git tag v1.0.0
git push origin v1.0.0
```

The workflow automatically builds, signs, notarizes, and publishes the release.

**First-time setup:**
```bash
./scripts/setup_signing.sh
```

This configures code signing and notarization (requires Apple Developer account).

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

Built with Swift and AppKit for the macOS community.

---

**Made with ❤️ for macOS administrators, developers and designers**
