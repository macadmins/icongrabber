Icon Grabber - Quick Start Guide

## Get Started in Seconds
```bash
Build
make build

Extract an icon
./bin/icongrabber /Applications/Safari.app

That's it! safari_x.png is created
```

## Common Commands

CLI Quick Reference

```bash
Basic extraction (x PNG by default)
icongrabber /Applications/Safari.app

Custom size
icongrabber /Applications/Safari.app -s 
Custom output location
icongrabber /Applications/Safari.app -o ~/Desktop/my-icon.png

All options
icongrabber -i /Applications/Safari.app -o output.png -s 
Help
icongrabber --help
```

Build & Install

```bash
Build the CLI tool
make build

Install system-wide (requires sudo)
sudo make install

Install to home directory (no sudo needed)
make install PREFIX=$HOME/.local

Run tests
make test

Clean up
make clean
```

 Notes

- mac OS app icons are raster images (PNG/ICNS format)
- SVG export would require vectorization (not currently supported)
- Paths with `~` are automatically expanded
- Exit codes: (success), (error), (invalid args), (extraction failed)

## Use Cases

Web Developer
Extract app icons for your website or documentation:
```bash
icongrabber /Applications/Your App.app -o assets/app-icon.png -s ```

Batch Processing
Extract all app icons from /Applications:
```bash
./examples/batch_extract.sh
```

Multiple Sizes
Get an icon in all common sizes:
```bash
./examples/extract_multiple_sizes.sh /Applications/Safari.app
```

Automation
Integrate into your build scripts:
```bash
!/bin/bash
if icongrabber "$APP_PATH" -o "$OUTPUT" -s ; then
 echo " Icon extracted"
 Do something with the icon
fi
```

## Output Files

Default naming pattern: `App Name_x.png`

Examples:
- Safari.app → `Safari_x.png`
- Visual Studio Code.app → `Visual_Studio_Code_x.png`
- Calculator.app → `Calculator_x.png`

 Available Sizes

- ×(Small)
- ×(Small)
- ×(Medium)
- ×(Medium)
- ×(Large)
- ×(Default)- ×(Extra Large)

 Need Help?

```bash
Show all options
icongrabber --help

Show version
icongrabber --version
```

See the main [README.md](README.md) for complete documentation.
