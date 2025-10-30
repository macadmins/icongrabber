#!/bin/bash
#
# extract_multiple_sizes.sh
# Example: Extract the same icon in multiple sizes
#

if [ $# -eq 0 ]; then
    echo "Usage: $0 <path-to-app>"
    echo "Example: $0 /Applications/Safari.app"
    exit 1
fi

APP_PATH="$1"
APP_NAME=$(basename "$APP_PATH" .app | tr ' ' '_')
SIZES=(16 32 64 128 256 512 1024)

# Check if icongrabber is available
if ! command -v icongrabber &> /dev/null; then
    if [ -f "./bin/icongrabber" ]; then
        ICONGRABBER="./bin/icongrabber"
    else
        echo "Error: icongrabber not found"
        exit 1
    fi
else
    ICONGRABBER="icongrabber"
fi

echo "Extracting icons for: $(basename "$APP_PATH")"
echo ""

for size in "${SIZES[@]}"; do
    output="${APP_NAME}_${size}x${size}.png"
    
    if $ICONGRABBER "$APP_PATH" -o "$output" -s "$size"; then
        echo "✓ Created: $output"
    else
        echo "✗ Failed: $output"
    fi
done

echo ""
echo "All sizes extracted!"
