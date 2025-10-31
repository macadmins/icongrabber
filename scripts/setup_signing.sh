#!/bin/bash
#
# setup_signing.sh - Helper script to export certificates for GitHub Actions
#
# This script helps you export your Apple Developer certificates in the format
# needed for the GitHub Actions release workflow.
#

set -e

echo "=================================================="
echo "  Icon Grabber - Code Signing Setup Helper"
echo "=================================================="
echo ""
echo "This script will help you:"
echo "  1. Find your signing certificates"
echo "  2. Export them in P12 format"
echo "  3. Generate the base64 encoding for GitHub"
echo "  4. Display the secrets you need to configure"
echo ""

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ Error: This script must be run on macOS"
    exit 1
fi

# Find code signing identities
echo "Step 1: Finding your Developer ID certificates..."
echo ""

CODE_SIGN_IDENTITIES=$(security find-identity -v -p codesigning 2>/dev/null | grep "Developer ID" || true)

if [ -z "$CODE_SIGN_IDENTITIES" ]; then
    echo "❌ No Developer ID certificates found in your keychain"
    echo ""
    echo "You need to:"
    echo "  1. Enroll in the Apple Developer Program ($99/year)"
    echo "  2. Create 'Developer ID Application' and 'Developer ID Installer' certificates"
    echo "  3. Download and install them in Keychain Access"
    echo ""
    echo "See: https://developer.apple.com/account/resources/certificates/list"
    exit 1
fi

echo "Found the following Developer ID certificates:"
echo "$CODE_SIGN_IDENTITIES"
echo ""

# Extract identities
APP_IDENTITY=$(echo "$CODE_SIGN_IDENTITIES" | grep "Developer ID Application" | sed 's/.*"\(.*\)"/\1/' | head -n 1)
INSTALLER_IDENTITY=$(echo "$CODE_SIGN_IDENTITIES" | grep "Developer ID Installer" | sed 's/.*"\(.*\)"/\1/' | head -n 1)

if [ -z "$APP_IDENTITY" ]; then
    echo "⚠️  Warning: No 'Developer ID Application' certificate found"
    echo "   You need this to sign the binary"
fi

if [ -z "$INSTALLER_IDENTITY" ]; then
    echo "⚠️  Warning: No 'Developer ID Installer' certificate found"
    echo "   You need this to sign the PKG installer"
fi

if [ -z "$APP_IDENTITY" ] || [ -z "$INSTALLER_IDENTITY" ]; then
    echo ""
    echo "Please create the missing certificates and try again."
    exit 1
fi

# Extract Team ID
TEAM_ID=$(echo "$APP_IDENTITY" | grep -o '([A-Z0-9]\{10\})' | tr -d '()')

echo "✓ Developer ID Application: $APP_IDENTITY"
echo "✓ Developer ID Installer: $INSTALLER_IDENTITY"
echo "✓ Team ID: $TEAM_ID"
echo ""

# Export certificate
echo "Step 2: Exporting certificates..."
echo ""
echo "You'll be prompted to:"
echo "  1. Allow access to your keychain"
echo "  2. Set a password for the P12 file (remember this!)"
echo ""
read -p "Press Enter to continue..."

# Create temporary directory
TEMP_DIR=$(mktemp -d)
P12_FILE="$TEMP_DIR/DeveloperID.p12"

# Export the certificate
echo ""
echo "Exporting certificate (you may be prompted for your keychain password)..."

if security find-certificate -c "$APP_IDENTITY" -p > "$TEMP_DIR/cert.pem" 2>/dev/null; then
    # Prompt for P12 password
    echo ""
    read -s -p "Enter a password for the P12 file: " P12_PASSWORD
    echo ""
    read -s -p "Confirm password: " P12_PASSWORD_CONFIRM
    echo ""
    
    if [ "$P12_PASSWORD" != "$P12_PASSWORD_CONFIRM" ]; then
        echo "❌ Passwords don't match!"
        rm -rf "$TEMP_DIR"
        exit 1
    fi
    
    # Try to export via command line
    echo ""
    echo "Attempting to export certificate..."
    echo ""
    echo "If this fails, you'll need to export manually:"
    echo "  1. Open Keychain Access"
    echo "  2. Select 'My Certificates'"
    echo "  3. Right-click '$APP_IDENTITY'"
    echo "  4. Choose 'Export'"
    echo "  5. Save as DeveloperID.p12"
    echo ""
    
    # This often requires manual intervention
    echo "Please use Keychain Access to export your certificate:"
    echo "  Certificate: $APP_IDENTITY"
    echo "  Format: Personal Information Exchange (.p12)"
    echo "  Save to: $P12_FILE"
    echo "  Password: (the one you just entered)"
    echo ""
    
    open -a "Keychain Access"
    
    read -p "Press Enter after you've exported the P12 file to $P12_FILE..."
    
    if [ ! -f "$P12_FILE" ]; then
        echo ""
        echo "❌ P12 file not found at $P12_FILE"
        echo ""
        echo "Please export manually and then run:"
        echo "  base64 -i /path/to/your/certificate.p12 | pbcopy"
        rm -rf "$TEMP_DIR"
        exit 1
    fi
else
    echo "❌ Failed to find certificate"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Convert to base64
echo ""
echo "Step 3: Converting to base64..."
BASE64_CERT=$(base64 -i "$P12_FILE" | tr -d '\n')

if [ -z "$BASE64_CERT" ]; then
    echo "❌ Failed to encode certificate"
    rm -rf "$TEMP_DIR"
    exit 1
fi

echo "✓ Certificate encoded successfully (${#BASE64_CERT} characters)"

# Get Apple ID
echo ""
echo "Step 4: Apple Developer Account Information"
echo ""
read -p "Enter your Apple ID (email): " APPLE_ID
echo ""
echo "You need an app-specific password for notarization."
echo "Create one at: https://appleid.apple.com"
echo "  → Security → App-Specific Passwords → Generate"
echo ""
read -s -p "Enter your app-specific password: " APP_PASSWORD
echo ""

# Display summary
echo ""
echo "=================================================="
echo "  1Password Configuration"
echo "=================================================="
echo ""
echo "Step 1: Create a 1Password item"
echo "  1. Open 1Password"
echo "  2. Go to the 'GitHub' vault (create if needed)"
echo "  3. Create a new Secure Note named 'IconGrabberSecrets'"
echo "  4. Add the following fields:"
echo ""
echo "---------------------------------------------------"
echo "Field: APPLE_CERTIFICATE_BASE64"
echo "---------------------------------------------------"
echo "$BASE64_CERT"
echo ""
echo "---------------------------------------------------"
echo "Field: APPLE_CERTIFICATE_PASSWORD"
echo "---------------------------------------------------"
echo "$P12_PASSWORD"
echo ""
echo "---------------------------------------------------"
echo "Field: APPLE_SIGNING_IDENTITY"
echo "---------------------------------------------------"
echo "$APP_IDENTITY"
echo ""
echo "---------------------------------------------------"
echo "Field: APPLE_INSTALLER_SIGNING_IDENTITY"
echo "---------------------------------------------------"
echo "$INSTALLER_IDENTITY"
echo ""
echo "---------------------------------------------------"
echo "Field: APPLE_ID"
echo "---------------------------------------------------"
echo "$APPLE_ID"
echo ""
echo "---------------------------------------------------"
echo "Field: APPLE_TEAM_ID"
echo "---------------------------------------------------"
echo "$TEAM_ID"
echo ""
echo "---------------------------------------------------"
echo "Field: APPLE_APP_PASSWORD"
echo "---------------------------------------------------"
echo "$APP_PASSWORD"
echo ""
echo "=================================================="
echo ""
echo "Step 2: Create a 1Password Service Account"
echo "  1. Go to 1Password.com → Developer Tools → Service Accounts"
echo "  2. Create a new service account named 'GitHub Actions - Icon Grabber'"
echo "  3. Grant it READ access to the 'GitHub' vault"
echo "  4. Copy the service account token (starts with 'ops_')"
echo ""
echo "Step 3: Add the service account token to GitHub"
echo "  1. Go to: https://github.com/kitzy/icongrabber/settings/secrets/actions"
echo "  2. Click 'New repository secret'"
echo "  3. Name: OP_SERVICE_ACCOUNT_TOKEN"
echo "  4. Value: (paste the service account token)"
echo ""
echo "=================================================="
echo ""

# Offer to copy to clipboard
if command -v pbcopy &> /dev/null; then
    echo "Would you like to copy the certificate base64 to clipboard?"
    read -p "(y/N): " COPY_CERT
    if [[ "$COPY_CERT" =~ ^[Yy]$ ]]; then
        echo "$BASE64_CERT" | pbcopy
        echo "✓ Certificate base64 copied to clipboard"
    fi
fi

# Clean up
echo ""
echo "Cleaning up temporary files..."
rm -rf "$TEMP_DIR"

echo ""
echo "✓ Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Add all the fields above to your 1Password IconGrabberSecrets item"
echo "  2. Create a 1Password service account with access to the GitHub vault"
echo "  3. Add OP_SERVICE_ACCOUNT_TOKEN to GitHub repository secrets"
echo "  4. Create a release tag: git tag v1.0.0 && git push origin v1.0.0"
echo "  5. Watch the workflow at: https://github.com/kitzy/icongrabber/actions"
echo ""
echo "For detailed instructions, see: .github/RELEASE_SETUP.md"
echo ""
