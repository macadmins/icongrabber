# Icon Grabber# Icon Grabber# Icon Grabber# Icon Grabber



> Extract beautiful, high-resolution icons from any macOS application with a single command.



[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

[![Platform](https://img.shields.io/badge/platform-macOS-lightgrey.svg)](https://www.apple.com/macos/)

[![Platform](https://img.shields.io/badge/platform-macOS-lightgrey.svg)](https://www.apple.com/macos/)

## What is Icon Grabber?

[![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)](https://swift.org)[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)A command-line tool for macOS that extracts icons from applications and exports them as PNG files.

Icon Grabber is a simple command-line tool that lets you extract the icon from any macOS application and save it as a PNG image. Need a Safari icon for your presentation? Want to grab all your app icons for a design project? Icon Grabber makes it effortless.



## Why Use Icon Grabber?

A lightweight, fast command-line tool for extracting icons from macOS applications.[![Platform](https://img.shields.io/badge/platform-macOS-lightgrey.svg)](https://www.apple.com/macos/)

- **Save Time**: No more hunting through app bundles or taking screenshots

- **Get Quality Icons**: Extract crisp, high-resolution icons in any size you need

- **Automate Everything**: Perfect for scripts, build processes, or batch operations

- **No Fuss**: Single command, instant results. No complicated setup or dependencies.## Quick Start[![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)](https://swift.org)## Features



## Quick Example



```bash```bash

# Extract Safari's icon

icongrabber /Applications/Safari.app# Install



# That's it! You now have Safari_512x512.pngmake installA lightweight, fast command-line tool for extracting icons from macOS applications.- � **Fast & Simple**: Extract icons in milliseconds with a single command

```



## Installation

# Extract an icon- 📦 **No Dependencies**: Single binary, just compile and run

**Install in 10 seconds:**

icongrabber /Applications/Safari.app

```bash

# Clone and install## Quick Start- 🎯 **Scriptable**: Perfect for automation and batch processing

git clone https://github.com/kitzy/icongrabber.git

cd icongrabber# Done! Creates Safari_512x512.png

make install

``````- 🖼️ **Multiple Sizes**: Extract icons from 16x16 up to 1024x1024 pixels



Now you can use `icongrabber` from anywhere in your terminal.



**No admin access?** Install to your home directory:## Features```bash- 💾 **PNG Export**: High-quality PNG output



```bash

make install PREFIX=$HOME/.local

export PATH="$HOME/.local/bin:$PATH"- 🚀 **Fast**: Extract icons in milliseconds# Install- 💻 **UNIX-friendly**: Standard input/output and proper exit codes

```

- 📦 **Lightweight**: ~79KB single binary, no dependencies

## How to Use It

- 🎯 **Scriptable**: Perfect for automation and batch processingmake install- 📝 **Well Documented**: Man page included

### Basic Usage

- 🖼️ **Flexible**: Multiple sizes from 16x16 to 1024x1024

The simplest way to use Icon Grabber:

- 💾 **High Quality**: PNG output with transparency

```bash

icongrabber /Applications/YourApp.app- 💻 **UNIX-friendly**: Proper exit codes and standard I/O

```

- 📖 **Well Documented**: Comprehensive man page included# Extract an icon## Requirements

This creates `YourApp_512x512.png` in your current directory.



### Choose Where to Save

## Installationicongrabber /Applications/Safari.app

```bash

# Save to a specific location

icongrabber /Applications/Safari.app -o ~/Desktop/safari-icon.png

### Using Make (Recommended)- macOS 10.15 or later

# Save to a specific directory (filename is auto-generated)

icongrabber /Applications/Safari.app -o ~/Desktop/

```

```bash# Done! Creates Safari_512x512.png- Swift compiler (included with Xcode Command Line Tools)

### Choose Icon Size

# Clone the repository

```bash

# Small icon for a menu bargit clone https://github.com/kitzy/icongrabber.git```

icongrabber /Applications/Safari.app -s 32

cd icongrabber

# Large icon for a poster

icongrabber /Applications/Safari.app -s 1024## Installation



# Common sizes: 16, 32, 64, 128, 256, 512, 1024# Build and install (requires sudo for system-wide install)

```

make install## Features

### Combine Options



```bash

icongrabber /Applications/Safari.app -s 256 -o ~/Desktop/safari.png# Now use from anywhere**Quick Install:**

```

icongrabber --help

## Real-World Examples

```- 🚀 **Fast**: Extract icons in milliseconds```bash

### For Designers



Extract all your app icons for a design mockup:

### Manual Installation- 📦 **Lightweight**: ~79KB single binary, no dependencies# Build and install to /usr/local/bin

```bash

# Create a folder for icons

mkdir ~/Desktop/app-icons

```bash- 🎯 **Scriptable**: Perfect for automation and batch processingmake install

# Extract your favorite apps

icongrabber /Applications/Safari.app -o ~/Desktop/app-icons/ -s 512# Build the binary

icongrabber /Applications/Mail.app -o ~/Desktop/app-icons/ -s 512

icongrabber /Applications/Calendar.app -o ~/Desktop/app-icons/ -s 512./build.sh- 🖼️ **Flexible**: Multiple sizes from 16x16 to 1024x1024```

```



### For Developers

# Copy to your PATH- 💾 **High Quality**: PNG output with transparency

Add to your build script to extract your app's icon:

sudo cp bin/icongrabber /usr/local/bin/

```bash

#!/bin/bash- 💻 **UNIX-friendly**: Proper exit codes and standard I/O**Manual Build:**

# Extract icon for documentation

icongrabber build/MyApp.app -o docs/images/app-icon.png -s 256# Or to user directory (no sudo needed)

```

cp bin/icongrabber ~/.local/bin/- 📖 **Well Documented**: Comprehensive man page included```bash

### For Content Creators

```

Grab icons for a tutorial or blog post:

# Build only

```bash

# Get the Xcode icon for your coding tutorial### Release Build

icongrabber /Applications/Xcode.app -s 512 -o xcode-icon.png

```## Installation./build.sh



### Batch Process All AppsFor an optimized production build:



Want icons from every app on your Mac? We've got you covered:



```bash```bash

./examples/batch_extract.sh

```# Create optimized binary### Using Make (Recommended)# Or use make



This extracts icons from all apps in `/Applications` and saves them to the `extracted_icons` folder.make release



### Get Multiple Sizes of the Same Iconmake build



Need different sizes for web, mobile, and print?# Binary will be in release/icongrabber (~79KB)



```bashsudo cp release/icongrabber /usr/local/bin/```bash

./examples/extract_multiple_sizes.sh /Applications/Safari.app

``````



This creates Safari icons in all common sizes: 16×16, 32×32, 64×64, 128×128, 256×256, 512×512, and 1024×1024.# Clone the repository# Run from the bin directory



## All Available Options## Usage



```git clone https://github.com/kitzy/icongrabber.git./bin/icongrabber --help

icongrabber [OPTIONS] <path-to-app>

### Basic Examples

OPTIONS:

  -o, --output <path>    Where to save the icon (default: current directory)cd icongrabber```

  -s, --size <pixels>    Icon size in pixels (default: 512)

                         Sizes: 16, 32, 64, 128, 256, 512, 1024```bash

  -h, --help            Show help message

  -v, --version         Show version# Extract with defaults (512x512 PNG)

```

icongrabber /Applications/Safari.app

## Tips & Tricks

# Build and install (requires sudo for system-wide install)**Custom Installation Location:**

**Find app paths easily:**

```bash# Specify size

# Most apps are in /Applications

ls /Applicationsicongrabber /Applications/Safari.app -s 256make install```bash



# System apps are in /System/Applications

ls /System/Applications

```# Custom output location# Install to a custom location



**Create a batch extraction loop:**icongrabber /Applications/Safari.app -o ~/Desktop/safari-icon.png

```bash

for app in /Applications/*.app; do# Now use from anywheremake install PREFIX=$HOME/.local

    icongrabber "$app" -s 256 -o ~/Desktop/icons/

done# All options

```

icongrabber -i /Applications/Safari.app -o icon.png -s 1024icongrabber --help```

**Use in automation scripts:**

```bash```

if icongrabber "$APP_PATH" -o "$OUTPUT_PATH" -s 512; then

    echo "✓ Icon extracted!"```

else

    echo "✗ Failed to extract icon"### Command Options

fi

```## Usage



## Troubleshooting```



**"Command not found"**USAGE:### Manual Installation

- Make sure you ran `make install`

- Check if `/usr/local/bin` is in your PATH: `echo $PATH`    icongrabber [OPTIONS] <app-path>

- Try installing to your home directory (see Installation section)

**Basic Usage:**

**Icon looks blurry**

- Try a larger size: `-s 512` or `-s 1024`OPTIONS:

- Some older apps may not have high-resolution icons

    -i, --input <path>      Application path (alternative to positional arg)```bash```bash

**Permission denied**

- Use `sudo make install` for system-wide installation    -o, --output <path>     Output file path (default: <AppName>_<size>.png)

- Or install to your home directory without sudo

    -s, --size <pixels>     Icon size: 16, 32, 64, 128, 256, 512, 1024 (default: 512)# Build the binary# Extract icon with default settings (512x512)

**App not found**

- Make sure the path is correct and ends in `.app`    -f, --format <format>   Output format: png (default: png)

- Try using the full path: `/Applications/Safari.app`

    -h, --help             Show help message./build.shicongrabber /Applications/Safari.app

## What Can I Do With The Extracted Icons?

    -v, --version          Show version information

- 🎨 Use in design mockups and presentations

- 📱 Create custom app launchers or themes

- 📖 Add to documentation and tutorials

- 🌐 Use on websites and blogs (check app licensing)EXIT CODES:

- 🖼️ Build icon galleries or collections

- 🔧 Use in development tools and scripts    0    Success# Copy to your PATH# Specify output location



## Examples Included    1    General error



The `examples/` folder contains ready-to-use scripts:    2    Invalid argumentssudo cp bin/icongrabber /usr/local/bin/icongrabber /Applications/Safari.app -o ~/Desktop/safari.png



- **batch_extract.sh** - Extract icons from all apps in /Applications    3    Icon extraction failed

- **extract_multiple_sizes.sh** - Get one icon in all sizes

```

Run them directly:

```bash

./examples/batch_extract.sh

```### Advanced Usage# Or to user directory (no sudo needed)# Custom size



## FAQ



**Q: Can I extract icons from iOS apps?**  **Batch Processing:**cp bin/icongrabber ~/.local/bin/icongrabber /Applications/Safari.app -s 256

A: No, Icon Grabber only works with macOS applications.

```bash

**Q: Can I get SVG or vector icons?**  

A: No, macOS app icons are stored as raster images (PNG format). There's no vector version to extract.# Extract all app icons from /Applications```



**Q: Is this legal?**  for app in /Applications/*.app; do

A: Yes, you're extracting icons from apps on your own Mac. However, how you *use* those icons may be subject to the app's licensing terms.

    icongrabber "$app" -s 512 -o "icons/$(basename "$app" .app).png"# All options combined

**Q: What format are the icons saved in?**  

A: PNG format with transparency preserved.done



**Q: Do I need Xcode installed?**  ```### Release Buildicongrabber -i /Applications/Xcode.app -o xcode_icon.png -s 1024

A: You need the Xcode Command Line Tools (free). macOS will prompt you to install them when you first run `make install`.



## Need Help?

**Multiple Sizes:**```

- Run `icongrabber --help` for quick reference

- View the manual: `man icongrabber````bash

- Check out [QUICKSTART.md](QUICKSTART.md) for more examples

# Extract the same icon in different sizesFor an optimized production build:

## Contributing

for size in 16 32 64 128 256 512 1024; do

Found a bug? Have an idea? Contributions are welcome!

    icongrabber /Applications/Safari.app -s $size -o "safari_${size}.png"**Batch Processing Example:**

1. Fork the repository

2. Create your feature branchdone

3. Make your changes

4. Submit a pull request``````bash```bash



## License



Apache License 2.0 - Free to use and modify. See [LICENSE](LICENSE) for details.**Scripting:**# Create optimized binary#!/bin/bash



---```bash



**Enjoy extracting icons!** 🎉#!/bin/bashmake release# Extract icons from all applications



If Icon Grabber saved you time, consider giving it a ⭐️ on GitHub.if icongrabber "$APP_PATH" -o "$OUTPUT" -s 512; then


    echo "✓ Icon extracted successfully"

    # Process the icon...

else# Binary will be in release/icongrabber (~79KB)for app in /Applications/*.app; do

    echo "✗ Failed to extract icon"

    exit 1sudo cp release/icongrabber /usr/local/bin/    name=$(basename "$app" .app)

fi

``````    icongrabber "$app" -o "icons/${name}.png" -s 512



**Use Provided Examples:**done

```bash

# Extract all apps in /Applications folder## Usage```

./examples/batch_extract.sh



# Extract one app in multiple sizes

./examples/extract_multiple_sizes.sh /Applications/Safari.app### Basic Examples**Use in Scripts:**

```

```bash

## Documentation

```bash# Check if extraction was successful

View the full manual:

```bash# Extract with defaults (512x512 PNG)if icongrabber /Applications/Safari.app -o safari.png; then

man icongrabber

```icongrabber /Applications/Safari.app    echo "Icon extracted successfully"



Or read the quick start guide: [QUICKSTART.md](QUICKSTART.md)else



## Project Structure# Specify size    echo "Failed to extract icon"



```icongrabber /Applications/Safari.app -s 256fi

icongrabber/

├── icongrabber-cli/```

│   └── main.swift                # Main CLI implementation (~275 lines)

├── examples/# Custom output location

│   ├── batch_extract.sh          # Batch extraction example

│   ├── extract_multiple_sizes.sh # Multi-size extraction exampleicongrabber /Applications/Safari.app -o ~/Desktop/safari-icon.png**CLI Options:**

│   └── README.md                 # Examples documentation

├── Makefile                      # Build system```

├── build.sh                      # Quick build script

├── release.sh                    # Optimized release build# All optionsUSAGE:

├── icongrabber.1                 # Man page

├── LICENSE                       # Apache 2.0 Licenseicongrabber -i /Applications/Safari.app -o icon.png -s 1024    icongrabber [OPTIONS] <input-app-path>

├── README.md                     # This file

└── QUICKSTART.md                 # Quick reference guide```

```

OPTIONS:

## Building from Source

### Command Options    -i, --input <path>      Input application path

### Requirements

- macOS 10.15 or later    -o, --output <path>     Output file path (default: <AppName>_<size>x<size>.png)

- Swift compiler (Xcode Command Line Tools)

```    -s, --size <pixels>     Icon size (default: 512)

### Build Commands

USAGE:                            Common: 16, 32, 64, 128, 256, 512, 1024

```bash

# Development build    icongrabber [OPTIONS] <app-path>    -f, --format <format>   Output format: png (default: png)

make build

    -h, --help             Show help message

# Optimized release build

make releaseOPTIONS:    -v, --version          Show version



# Run tests    -i, --input <path>      Application path (alternative to positional arg)```

make test

    -o, --output <path>     Output file path (default: <AppName>_<size>.png)

# Clean build artifacts

make clean    -s, --size <pixels>     Icon size: 16, 32, 64, 128, 256, 512, 1024 (default: 512)## Project Structure



# View all options    -f, --format <format>   Output format: png (default: png)

make help

```    -h, --help             Show help message```



## Examples    -v, --version          Show version informationicongrabber/



Check out the `examples/` directory for complete working examples:├── icongrabber-cli/



- **batch_extract.sh** - Extract icons from all apps in `/Applications`EXIT CODES:│   └── main.swift                # CLI implementation

- **extract_multiple_sizes.sh** - Extract a single app icon in all sizes

    0    Success├── examples/                     # Example scripts

## Technical Details

    1    General error│   ├── batch_extract.sh          # Extract all apps in /Applications

- **Language**: Swift 5.0

- **Framework**: AppKit (for icon access)    2    Invalid arguments│   ├── extract_multiple_sizes.sh # Extract multiple icon sizes

- **Binary Size**: ~79KB (optimized release build)

- **Dependencies**: None (single binary)    3    Icon extraction failed│   └── README.md

- **Minimum OS**: macOS 10.15 Catalina

```├── Makefile                      # Build and installation

### How It Works

├── build.sh                      # Quick build script

Icon Grabber uses macOS's native `NSWorkspace` API to access the registered icon for each application. The icons are then resized to the requested dimensions and exported as PNG with proper transparency preservation.

### Advanced Usage├── icongrabber.1                 # Man page

## Troubleshooting

└── README.md

**Command not found after installation:**

```bash**Batch Processing:**```

# Verify installation

which icongrabber```bash



# Check your PATH# Extract all app icons from /Applications## Technical Details

echo $PATH

for app in /Applications/*.app; do

# Install to user directory if needed

make install PREFIX=$HOME/.local    icongrabber "$app" -s 512 -o "icons/$(basename "$app" .app).png"- **Language**: Swift 5.0

export PATH="$HOME/.local/bin:$PATH"

```done- **Framework**: AppKit (for icon extraction)



**Permission denied:**```- **Minimum Deployment**: macOS 10.15

```bash

# Use sudo for system-wide installation- **Binary Size**: ~50KB (release build)

sudo make install

**Multiple Sizes:**

# Or install to user directory (no sudo needed)

make install PREFIX=$HOME/.local```bash## License

```

# Extract the same icon in different sizes

**Icon appears low quality:**

- Use larger sizes (512 or 1024)for size in 16 32 64 128 256 512 1024; doMIT License - feel free to use and modify as needed. See [LICENSE](LICENSE) for details.

- Some apps may not include high-resolution icons

- macOS icons are raster images; vector versions don't exist    icongrabber /Applications/Safari.app -s $size -o "safari_${size}.png"



## Contributingdone## Contributing



Contributions are welcome! Here's how:```



1. Fork the repositoryContributions are welcome! Feel free to submit issues or pull requests.

2. Create a feature branch (`git checkout -b feature/amazing-feature`)

3. Make your changes**Scripting:**

4. Test thoroughly (`make test`)

5. Commit your changes (`git commit -m 'Add amazing feature'`)```bash## Building and Development

6. Push to the branch (`git push origin feature/amazing-feature`)

7. Open a Pull Request#!/bin/bash



## Developmentif icongrabber "$APP_PATH" -o "$OUTPUT" -s 512; then### Build the CLI



### Build & Test Cycle    echo "✓ Icon extracted successfully"```bash



```bash    # Process the icon...# Quick build

# Make changes to icongrabber-cli/main.swift

# Buildelse./build.sh

make build

    echo "✗ Failed to extract icon"

# Test

./bin/icongrabber /Applications/Safari.app -s 128    exit 1# Or using make



# Run automated testfimake build

make test

```

# When ready, create release build

make release# Run tests

```

**Use Provided Examples:**make test

## License

```bash

Apache License 2.0 - see [LICENSE](LICENSE) file for details.

# Extract all apps in /Applications folder# Clean build artifacts

## Acknowledgments

./examples/batch_extract.shmake clean

- Built with Swift and AppKit

- Uses macOS native icon extraction APIs```

- Inspired by the need for scriptable icon extraction

# Extract one app in multiple sizes

## See Also

./examples/extract_multiple_sizes.sh /Applications/Safari.app### Development Workflow

- `iconutil(1)` - Convert iconsets to/from ICNS format

- `sips(1)` - Scriptable image processing system```1. Make changes to the code



---2. Build with `make build`



**Made with ❤️ for the macOS developer community**## Documentation3. Test with `./bin/icongrabber`


4. Install locally with `make install`

View the full manual:

```bash## Examples

man icongrabber

```Check out the `examples/` directory for example scripts:

- **batch_extract.sh** - Extract icons from all apps in /Applications

Or read the quick start guide: [QUICKSTART.md](QUICKSTART.md)- **extract_multiple_sizes.sh** - Extract one app in multiple sizes



## Project Structure## Troubleshooting



```**CLI tool not found after installation:**

icongrabber/```bash

├── icongrabber-cli/# Make sure /usr/local/bin is in your PATH

│   └── main.swift                # Main CLI implementation (~275 lines)echo $PATH

├── examples/

│   ├── batch_extract.sh          # Batch extraction example# Or install to a different location

│   ├── extract_multiple_sizes.sh # Multi-size extraction examplemake install PREFIX=$HOME/.local

│   └── README.md                 # Examples documentationexport PATH="$HOME/.local/bin:$PATH"

├── Makefile                      # Build system```

├── build.sh                      # Quick build script

├── release.sh                    # Optimized release build**Permission denied when installing:**

├── icongrabber.1                 # Man page```bash

├── LICENSE                       # MIT License# Use sudo for system-wide installation

├── README.md                     # This filesudo make install

└── QUICKSTART.md                 # Quick reference guide```

```

**App icon appears blurry:**

## Building from Source- Use higher resolution sizes (512 or 1024)

- Some apps may not have high-resolution icons available
### Requirements
- macOS 10.15 or later
- Swift compiler (Xcode Command Line Tools)

### Build Commands

```bash
# Development build
make build

# Optimized release build
make release

# Run tests
make test

# Clean build artifacts
make clean

# View all options
make help
```

## Examples

Check out the `examples/` directory for complete working examples:

- **batch_extract.sh** - Extract icons from all apps in `/Applications`
- **extract_multiple_sizes.sh** - Extract a single app icon in all sizes

## Technical Details

- **Language**: Swift 5.0
- **Framework**: AppKit (for icon access)
- **Binary Size**: ~79KB (optimized release build)
- **Dependencies**: None (single binary)
- **Minimum OS**: macOS 10.15 Catalina

### How It Works

Icon Grabber uses macOS's native `NSWorkspace` API to access the registered icon for each application. The icons are then resized to the requested dimensions and exported as PNG with proper transparency preservation.

## Troubleshooting

**Command not found after installation:**
```bash
# Verify installation
which icongrabber

# Check your PATH
echo $PATH

# Install to user directory if needed
make install PREFIX=$HOME/.local
export PATH="$HOME/.local/bin:$PATH"
```

**Permission denied:**
```bash
# Use sudo for system-wide installation
sudo make install

# Or install to user directory (no sudo needed)
make install PREFIX=$HOME/.local
```

**Icon appears low quality:**
- Use larger sizes (512 or 1024)
- Some apps may not include high-resolution icons
- macOS icons are raster images; vector versions don't exist

## Contributing

Contributions are welcome! Here's how:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Test thoroughly (`make test`)
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## Development

### Build & Test Cycle

```bash
# Make changes to icongrabber-cli/main.swift
# Build
make build

# Test
./bin/icongrabber /Applications/Safari.app -s 128

# Run automated test
make test

# When ready, create release build
make release
```

## License

Apache License 2.0 - see [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with Swift and AppKit
- Uses macOS native icon extraction APIs
- Inspired by the need for scriptable icon extraction

## See Also

- `iconutil(1)` - Convert iconsets to/from ICNS format
- `sips(1)` - Scriptable image processing system

---

**Made with ❤️ for the macOS developer community**
