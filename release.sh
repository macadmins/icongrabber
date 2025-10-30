#!/bin/bash
#
# release.sh - Create a release build of icongrabber
#

set -e

VERSION="1.0.0"
BUILD_DIR="release"
BINARY_NAME="icongrabber"

echo "Building Icon Grabber v${VERSION}..."
echo ""

# Clean previous build
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Compile with optimizations
echo "Compiling with optimizations..."
swiftc -O -o "${BUILD_DIR}/${BINARY_NAME}" icongrabber-cli/main.swift -framework AppKit

# Strip debug symbols for smaller binary
echo "Stripping debug symbols..."
strip "${BUILD_DIR}/${BINARY_NAME}"

# Get binary size
SIZE=$(ls -lh "${BUILD_DIR}/${BINARY_NAME}" | awk '{print $5}')

echo ""
echo "✓ Release build complete!"
echo "  Location: ${BUILD_DIR}/${BINARY_NAME}"
echo "  Size: ${SIZE}"
echo ""
echo "To install:"
echo "  sudo cp ${BUILD_DIR}/${BINARY_NAME} /usr/local/bin/"
echo ""
echo "To create a distribution:"
echo "  tar -czf icongrabber-${VERSION}-macos.tar.gz -C ${BUILD_DIR} ${BINARY_NAME}"
