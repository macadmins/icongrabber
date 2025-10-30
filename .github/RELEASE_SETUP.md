# Release Workflow Setup Guide

This guide explains how to set up code signing and notarization for the Icon Grabber release workflow using 1Password for secure secrets management.

## Overview

The release workflow (`release.yml`) will:
1. Build an optimized release binary
2. Sign the binary with your Developer ID Application certificate
3. Create a `.pkg` installer
4. Sign the `.pkg` with your Developer ID Installer certificate
5. Notarize the package with Apple
6. Create a GitHub release with both the signed `.pkg` and a binary tarball

Secrets are securely stored in 1Password and accessed via the 1Password GitHub Action.

## Prerequisites

- Apple Developer account ($99/year) to sign and notarize macOS applications
- 1Password account with ability to create service accounts
- GitHub repository access

## Step 1: Generate Certificates

### 1.1 Developer ID Application Certificate

This certificate is used to sign the binary itself.

1. Go to [Apple Developer Certificates](https://developer.apple.com/account/resources/certificates/list)
2. Click the "+" button to create a new certificate
3. Select **"Developer ID Application"**
4. Follow the instructions to create a Certificate Signing Request (CSR) using Keychain Access
5. Upload the CSR and download the certificate
6. Double-click the downloaded certificate to install it in your Keychain

### 1.2 Developer ID Installer Certificate

This certificate is used to sign the `.pkg` installer.

1. Go to [Apple Developer Certificates](https://developer.apple.com/account/resources/certificates/list)
2. Click the "+" button to create a new certificate
3. Select **"Developer ID Installer"**
4. Follow the instructions to create a CSR and download the certificate
5. Install it in your Keychain

## Step 2: Export Certificates for GitHub

### 2.1 Export as P12 File

1. Open **Keychain Access**
2. Select **My Certificates** in the left sidebar
3. Find your **"Developer ID Application"** certificate
4. Right-click and select **"Export"**
5. Choose `.p12` format
6. Set a strong password (you'll need this for GitHub secrets)
7. Save the file (e.g., `DeveloperID_Application.p12`)

**Note:** The P12 file contains both certificates (Application and Installer) if they're in the same keychain. You only need to export once.

### 2.2 Convert to Base64

```bash
# Navigate to where you saved the P12 file
base64 -i DeveloperID_Application.p12 | pbcopy
```

This copies the base64-encoded certificate to your clipboard.

### 2.3 Get Your Certificate Identity

```bash
# List your signing identities
security find-identity -v -p codesigning

# Look for lines like:
# 1) ABCDEF1234567890... "Developer ID Application: Your Name (TEAM_ID)"
# 2) 1234567890ABCDEF... "Developer ID Installer: Your Name (TEAM_ID)"
```

Copy the full identity strings (including quotes).

## Step 3: Get Your Apple Team ID

```bash
# Your Team ID is in the certificate name or you can find it at:
# https://developer.apple.com/account (Membership Details)
```

## Step 4: Create App-Specific Password

1. Go to [appleid.apple.com](https://appleid.apple.com)
2. Sign in with your Apple Developer account
3. Go to **Security** → **App-Specific Passwords**
4. Click "+" to generate a new password
5. Name it (e.g., "GitHub Notarization")
6. Copy the generated password (you won't be able to see it again)

## Step 5: Configure 1Password

### 5.1 Create a 1Password Vault (if needed)

1. Open 1Password
2. Create a vault named **"GitHub"** (or use an existing vault)

### 5.2 Create an Item for Icon Grabber Secrets

1. In 1Password, go to the **GitHub** vault
2. Click **New Item** → **Secure Note**
3. Name it: **Icon Grabber Secrets**
4. Add the following fields (click "+ add more" for each):

| Field Name | Value | Notes |
|------------|-------|-------|
| `APPLE_CERTIFICATE_BASE64` | `<base64 string>` | From Step 3.4 |
| `APPLE_CERTIFICATE_PASSWORD` | `<password>` | Password you set when exporting P12 |
| `APPLE_SIGNING_IDENTITY` | `Developer ID Application: Your Name (TEAM_ID)` | Full identity string |
| `APPLE_INSTALLER_SIGNING_IDENTITY` | `Developer ID Installer: Your Name (TEAM_ID)` | Full identity string |
| `APPLE_ID` | `your.email@example.com` | Your Apple Developer email |
| `APPLE_TEAM_ID` | `ABCDE12345` | Your 10-character Team ID |
| `APPLE_APP_PASSWORD` | `xxxx-xxxx-xxxx-xxxx` | App-specific password from Step 4 |

5. Save the item

## Step 6: Create a 1Password Service Account

1. Go to [1Password.com](https://1password.com) and sign in
2. Navigate to **Developer Tools** → **Service Accounts**
3. Click **Create Service Account**
4. Name it: **GitHub Actions - Icon Grabber**
5. Grant access to the **GitHub** vault (read-only is sufficient)
6. Save the service account
7. Copy the service account token (you'll only see this once!)
   - Format: `ops_xxxxxxxxxxxxxxxxxxxxxxxxxxxx`

## Step 7: Add Service Account Token to GitHub

This is the ONLY secret stored in GitHub:

1. Go to your GitHub repository: https://github.com/kitzy/icongrabber
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Name: `OP_SERVICE_ACCOUNT_TOKEN`
5. Value: `ops_xxxxxxxxxxxxxxxxxxxxxxxxxxxx` (from step 6.7)
6. Click **Add secret**

## Step 8: Verify 1Password Secret References

The workflow uses 1Password secret references with this format:
```
op://GitHub/Icon Grabber Secrets/FIELD_NAME
```

Make sure your 1Password structure matches:
- Vault name: `GitHub`
- Item name: `Icon Grabber Secrets`
- Field names: Match exactly as shown in step 5.2

## Step 9: Test the Workflow

### Option 1: Create a Release Tag

```bash
# Create and push a version tag
git tag v1.0.0
git push origin v1.0.0
```

This will automatically trigger the release workflow.

### Option 2: Manual Trigger

1. Go to **Actions** → **Release**
2. Click **Run workflow**
3. Enter a version number (e.g., `1.0.0`)
4. Click **Run workflow**

## Workflow Behavior

### With All Secrets Configured in 1Password
- ✓ Binary is signed
- ✓ PKG is signed
- ✓ PKG is notarized with Apple
- ✓ Users can install without Gatekeeper warnings

### Without Secrets (Unsigned)
- ✗ Binary is unsigned
- ✗ PKG is unsigned
- ⚠️ Users will need to bypass Gatekeeper
- ✓ Workflow still completes and creates a release

## Troubleshooting

### "No identity found" Error

Make sure your certificate identities exactly match what's in your keychain:
```bash
security find-identity -v -p codesigning
security find-identity -v -p basic
```

Also verify the field names in 1Password match exactly.

### Notarization Fails

1. Check that your Apple ID and App-Specific Password are correct in 1Password
2. Verify your Team ID matches your Apple Developer account
3. Check the notarization logs in the GitHub Actions output

### 1Password Secret Loading Fails

1. Verify `OP_SERVICE_ACCOUNT_TOKEN` is set correctly in GitHub Secrets
2. Check that the service account has access to the GitHub vault
3. Verify the vault name is exactly `GitHub`
4. Verify the item name is exactly `Icon Grabber Secrets`
5. Check that field names match exactly (case-sensitive)

### Certificate Import Fails

1. Verify the P12 password in 1Password is correct
2. Check that the base64 encoding is complete (no line breaks)
```bash
# Re-encode without line breaks
base64 -i Developer_ID_Application.p12 | tr -d '\n' | pbcopy
```

### Cannot Access 1Password Vault

1. Ensure the service account has read access to the GitHub vault
2. Check that the vault name matches exactly in the workflow file
3. Verify the service account token hasn't expired

### Gatekeeper Still Blocks the App

If users report Gatekeeper issues:
1. Verify the package shows as "signed and notarized" in the workflow logs
2. Check that stapling succeeded: `xcrun stapler validate icongrabber-*.pkg`
3. The first time a user downloads, they may need to right-click → Open (this is normal for new developer IDs)

## Local Testing

You can test signing locally before pushing:

```bash
# Build
make build

# Sign the binary (use your actual identity)
codesign --force \
  --sign "Developer ID Application: Your Name (TEAM_ID)" \
  --options runtime \
  --timestamp \
  bin/icongrabber

# Verify
codesign --verify --verbose=4 bin/icongrabber
codesign --display --verbose=4 bin/icongrabber

# Test it works
./bin/icongrabber --help
```

## Security Best Practices

1. **Never commit certificates or passwords** to the repository
2. **Use 1Password service accounts** with minimal required permissions (read-only to specific vault)
3. **Rotate app-specific passwords** periodically in both Apple ID and 1Password
4. **Use separate certificates** for different projects if possible
5. **Revoke certificates** immediately if compromised
6. **Keep your P12 file secure** - it's like a password to your identity
7. **Limit service account access** - only grant access to the vaults needed
8. **Monitor service account usage** - review access logs in 1Password regularly

## Resources

- [1Password Service Accounts](https://developer.1password.com/docs/service-accounts/)
- [1Password GitHub Action](https://github.com/1password/load-secrets-action)
- [Apple Code Signing Guide](https://developer.apple.com/support/code-signing/)
- [Notarization Documentation](https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution)
- [Creating Distribution-Signed Code](https://developer.apple.com/documentation/xcode/distributing-your-app-for-beta-testing-and-releases)


Getting Help

If you encounter issues:
. Check the GitHub Actions logs for detailed error messages
. Review Apple's notarization logs if notarization fails
. Verify all secrets are correctly configured in Password
. Check that the service account has proper vault access
. Test signing locally first to isolate issues

---

Note:You can skip the signing setup and still use the workflow. It will create unsigned builds that work locally, but users will need to bypass Gatekeeper.
