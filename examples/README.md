# Icon Grabber CLI Examples

This directory contains example scripts showing how to use the Icon Grabber CLI tool.

## Scripts

### `batch_extract.sh`
Extract icons from all applications in `/Applications` folder.

**Usage:**
```bash
./batch_extract.sh
```

**Features:**
- Extracts all app icons in `/Applications`
- Creates organized output directory
- Shows progress counter
- Skips already extracted icons

### `extract_multiple_sizes.sh`
Extract a single app icon in multiple sizes.

**Usage:**
```bash
./extract_multiple_sizes.sh /Applications/Safari.app
```

**Features:**
- Extracts 7 different sizes (16, 32, 64, 128, 256, 512, 1024)
- Creates properly named files
- Shows success/failure for each size

## Custom Scripts

You can easily create your own scripts. Here's a simple template:

```bash
#!/bin/bash

# Extract a single icon
icongrabber /Applications/Safari.app -o safari.png -s 512

# Check if successful
if [ $? -eq 0 ]; then
  echo "Icon extracted successfully!"
fi
```

## Tips

- Always check exit codes for error handling
- Use `-o` to specify output paths for better organization
- Common sizes are: 16, 32, 64, 128, 256, 512, 1024
- Output format is currently PNG only

