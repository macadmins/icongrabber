#!/bin/bash
#
# build.sh - Build script for Icon Grabber CLI
#

set -e

echo "Building Icon Grabber CLI..."

# Create output directory
mkdir -p bin

# Compile the CLI tool
swiftc -o bin/icongrabber icongrabber-cli/main.swift -framework AppKit

echo "✓ Build complete: bin/icongrabber"
echo ""
echo "To install system-wide, run:"
echo "  sudo make install"
echo ""
echo "Or use it directly:"
echo "  ./bin/icongrabber --help"
