# Icon Grabber - Quick Start Guide

## 🚀 Get Started in 30 Seconds
```bash
# Build
make build

# Extract an icon
./bin/icongrabber /Applications/Safari.app

# That's it! safari_512x512.png is created
```

## 📝 Common Commands

### CLI Quick Reference

```bash
# Basic extraction (512x512 PNG by default)
icongrabber /Applications/Safari.app

# Custom size
icongrabber /Applications/Safari.app -s 256

# Custom output location
icongrabber /Applications/Safari.app -o ~/Desktop/my-icon.png

# All options
icongrabber -i /Applications/Safari.app -o output.png -s 1024

# Help
icongrabber --help
```

### Build & Install

```bash
# Build the CLI tool
make build

# Install system-wide (requires sudo)
sudo make install

# Install to home directory (no sudo needed)
make install PREFIX=$HOME/.local

# Run tests
make test

# Clean up
make clean
```

## 📝 Notes

- macOS app icons are raster images (PNG/ICNS format)
- SVG export would require vectorization (not currently supported)
- Paths with `~` are automatically expanded
- Exit codes: 0 (success), 1 (error), 2 (invalid args), 3 (extraction failed)

## 🎯 Use Cases

### Web Developer
Extract app icons for your website or documentation:
```bash
icongrabber /Applications/YourApp.app -o assets/app-icon.png -s 256
```

### Batch Processing
Extract all app icons from /Applications:
```bash
./examples/batch_extract.sh
```

### Multiple Sizes
Get an icon in all common sizes:
```bash
./examples/extract_multiple_sizes.sh /Applications/Safari.app
```

### Automation
Integrate into your build scripts:
```bash
#!/bin/bash
if icongrabber "$APP_PATH" -o "$OUTPUT" -s 512; then
    echo "✓ Icon extracted"
    # Do something with the icon
fi
```

## 📁 Output Files

Default naming pattern: `AppName_512x512.png`

Examples:
- Safari.app → `Safari_512x512.png`
- Visual Studio Code.app → `Visual_Studio_Code_512x512.png`
- Calculator.app → `Calculator_512x512.png`

## ⚙️ Available Sizes

- 16×16 (Small)
- 32×32 (Small)
- 64×64 (Medium)
- 128×128 (Medium)
- 256×256 (Large)
- **512×512 (Default)**
- 1024×1024 (Extra Large)

## 🆘 Need Help?

```bash
# Show all options
icongrabber --help

# Show version
icongrabber --version
```

See the main [README.md](README.md) for complete documentation.
