#!/bin/bash
#
# example_batch_extract.sh
# Example script showing how to use icongrabber CLI for batch processing
#

set -e

# Configuration
OUTPUT_DIR="extracted_icons"
ICON_SIZE=512

# Check if icongrabber is available
if ! command -v icongrabber &> /dev/null; then
    if [ -f "./bin/icongrabber" ]; then
        ICONGRABBER="./bin/icongrabber"
        echo "Using local build: $ICONGRABBER"
    else
        echo "Error: icongrabber not found. Please install it or build it first."
        echo "Run: make install"
        exit 1
    fi
else
    ICONGRABBER="icongrabber"
    echo "Using installed icongrabber"
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo "Extracting icons from /Applications..."
echo "Output directory: $OUTPUT_DIR"
echo "Icon size: ${ICON_SIZE}x${ICON_SIZE}"
echo ""

# Counter for progress
count=0
total=$(find /Applications -maxdepth 1 -name "*.app" | wc -l | tr -d ' ')

# Extract icons from all applications in /Applications
for app in /Applications/*.app; do
    # Skip if not a valid app bundle
    [ -d "$app" ] || continue
    
    # Get app name
    app_name=$(basename "$app" .app)
    
    # Clean up the filename (replace spaces with underscores)
    clean_name=$(echo "$app_name" | tr ' ' '_' | tr -cd '[:alnum:]_-')
    
    # Output path
    output_path="$OUTPUT_DIR/${clean_name}.png"
    
    # Skip if already extracted
    if [ -f "$output_path" ]; then
        echo "⊘ Skipping (exists): $app_name"
        ((count++))
        continue
    fi
    
    # Extract the icon
    if $ICONGRABBER "$app" -o "$output_path" -s "$ICON_SIZE" > /dev/null 2>&1; then
        ((count++))
        echo "[$count/$total] ✓ Extracted: $app_name"
    else
        ((count++))
        echo "[$count/$total] ✗ Failed: $app_name"
    fi
done

echo ""
echo "Done! Extracted icons saved to: $OUTPUT_DIR"
echo "Total icons: $(ls -1 "$OUTPUT_DIR" | wc -l | tr -d ' ')"
