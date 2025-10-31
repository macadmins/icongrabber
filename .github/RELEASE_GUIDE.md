# Release Guide

Complete guide for creating, signing, and distributing Icon Grabber releases.

## Table of Contents

- [Quick Start](#quick-start)
- [One-Time Setup](#one-time-setup)
- [Creating a Release](#creating-a-release)
  - [Creating Pre-Releases](#creating-pre-releases)
- [Testing](#testing)
- [Architecture](#architecture)
- [Troubleshooting](#troubleshooting)

---

## Quick Start

### For Maintainers: Create a Release

```bash
# 1. Update CHANGELOG.md with release notes
# 2. Commit all changes to main
# 3. Create and push a tag

git tag v1.0.0
git push origin v1.0.0
```

The workflow automatically builds, signs, notarizes, and publishes the release.

### Command Reference

```bash
# Create release
git tag v1.0.0 && git push origin v1.0.0

# Manual workflow trigger
# Go to: Actions → Release → Run workflow

# Verify a release locally
curl -LO https://github.com/kitzy/icongrabber/releases/download/v1.0.0/icongrabber-1.0.0.pkg
pkgutil --check-signature icongrabber-1.0.0.pkg
xcrun stapler validate icongrabber-1.0.0.pkg
sudo installer -pkg icongrabber-1.0.0.pkg -target /
icongrabber --version

# Local build & sign
make build
codesign --force --sign "Developer ID Application: Your Name (TEAM)" \
  --options runtime --timestamp bin/icongrabber
codesign --verify --verbose=4 bin/icongrabber
```

---

## One-Time Setup

Required only once to enable code signing and notarization.

### Prerequisites

- Apple Developer account
- 1Password account with service accounts
- GitHub repository admin access

### Step 1: Generate Certificates

#### 1.1 Developer ID Application Certificate

1. Go to [Apple Developer Certificates](https://developer.apple.com/account/resources/certificates/list)
2. Click "+" → Select **"Developer ID Application"**
3. Create a Certificate Signing Request (CSR) using Keychain Access
4. Upload CSR and download certificate
5. Install certificate in Keychain

#### 1.2 Developer ID Installer Certificate

1. Go to [Apple Developer Certificates](https://developer.apple.com/account/resources/certificates/list)
2. Click "+" → Select **"Developer ID Installer"**
3. Create CSR and download certificate
4. Install certificate in Keychain

### Step 2: Export Certificates

#### Using the helper script (recommended):

```bash
./scripts/setup_signing.sh
```

This script will:
- Find your certificates
- Guide you through export
- Generate base64-encoded values
- Display all required secrets

#### Manual export:

```bash
# 1. Export from Keychain
# Open Keychain Access → My Certificates
# Right-click "Developer ID Application" → Export
# Save as .p12 with a strong password

# 2. Convert to base64
base64 -i DeveloperID_Application.p12 | pbcopy

# 3. Get signing identities
security find-identity -v -p codesigning
# Copy the full identity strings
```

### Step 3: Get Apple Credentials

```bash
# Team ID
# Find at: https://developer.apple.com/account (Membership Details)

# App-Specific Password
# 1. Go to: https://appleid.apple.com
# 2. Sign in → Security → App-Specific Passwords
# 3. Click "+" → Name it "GitHub Notarization"
# 4. Copy the generated password
```

### Step 4: Configure 1Password

Create a 1Password item in the **GitHub** vault named **IconGrabberSecrets**:

| Field Name | Value | How to Get |
|------------|-------|------------|
| `APPLE_CERTIFICATE_BASE64` | Base64 string | `./scripts/setup_signing.sh` |
| `APPLE_CERTIFICATE_PASSWORD` | Your P12 password | Password you set during export |
| `APPLE_SIGNING_IDENTITY` | "Developer ID Application: Your Name (TEAM)" | `security find-identity -v -p codesigning` |
| `APPLE_INSTALLER_SIGNING_IDENTITY` | "Developer ID Installer: Your Name (TEAM)" | `security find-identity -v -p codesigning` |
| `APPLE_ID` | your.email@example.com | Your Apple Developer email |
| `APPLE_TEAM_ID` | AB12CD34EF | [developer.apple.com/account](https://developer.apple.com/account) |
| `APPLE_APP_PASSWORD` | xxxx-xxxx-xxxx-xxxx | Generated app-specific password |

Create a 1Password service account with read access to the GitHub vault.

### Step 5: Configure GitHub

Add ONE secret to GitHub repository settings:

| Secret Name | Value |
|-------------|-------|
| `OP_SERVICE_ACCOUNT_TOKEN` | Service account token from 1Password (starts with `ops_`) |

**That's it!** The workflow will fetch all other secrets from 1Password.

---

## Creating a Release

### Release Checklist

- [ ] Update version in `release.sh` if needed
- [ ] Update `CHANGELOG.md` with release notes
- [ ] Commit all changes to `main`
- [ ] Create and push version tag
- [ ] Verify workflow completes successfully
- [ ] Test the released package
- [ ] Announce the release

### Version Numbering

Follow [Semantic Versioning](https://semver.org/):

- **MAJOR** (1.0.0 → 2.0.0): Breaking changes
- **MINOR** (1.0.0 → 1.1.0): New features, backwards compatible
- **PATCH** (1.0.0 → 1.0.1): Bug fixes, backwards compatible

### Release Methods

#### Method 1: Git Tag (Recommended)

```bash
git checkout main
git pull origin main
git tag v1.0.0
git push origin v1.0.0
```

#### Method 2: Manual Workflow Trigger

1. Go to [Actions → Release](../../actions/workflows/release.yml)
2. Click "Run workflow"
3. Enter version (e.g., `1.0.0`)
4. Click "Run workflow"

### Creating Pre-Releases

Pre-releases are useful for testing, beta versions, or release candidates before making a full public release.

#### Pre-Release Tag Format

Use version tags with pre-release identifiers:

```bash
# Alpha releases
git tag v1.0.0-alpha.1
git push origin v1.0.0-alpha.1

# Beta releases
git tag v1.0.0-beta.1
git push origin v1.0.0-beta.1

# Release candidates
git tag v1.0.0-rc.1
git push origin v1.0.0-rc.1
```

#### Marking as Pre-Release on GitHub

After the workflow completes, edit the release on GitHub:

1. Go to the [Releases page](../../releases)
2. Click "Edit" on the new release
3. Check the box **"Set as a pre-release"**
4. Optionally check **"Set as the latest release"** if appropriate
5. Click "Update release"

**Pre-release benefits:**
- ✅ Not marked as "Latest" by default
- ✅ Clearly labeled with a "Pre-release" badge
- ✅ Won't trigger update notifications for users
- ✅ Perfect for testing with early adopters

#### Pre-Release Workflow

```bash
# 1. Create pre-release from development branch
git checkout development
git pull origin development

# 2. Update CHANGELOG.md with [Unreleased] or [1.0.0-beta.1]
# 3. Commit changes

# 4. Create pre-release tag
git tag v1.0.0-beta.1
git push origin v1.0.0-beta.1

# 5. After workflow completes, mark as pre-release on GitHub
# 6. Share with testers
# 7. Collect feedback and make fixes

# 8. When ready for production, create final release
git checkout main
git merge development
git tag v1.0.0
git push origin main --tags
```

### What Gets Released

Each release includes:

1. **icongrabber-X.Y.Z.pkg** - Signed and notarized installer
   - Installs to `/usr/local/bin/icongrabber`
   - Includes man page
   - No Gatekeeper warnings

2. **icongrabber-X.Y.Z-macos-binary.tar.gz** - Binary tarball
   - For manual installation
   - Includes README and LICENSE

3. **checksums.txt** - SHA-256 verification

### Workflow Process

When a tag is pushed, the workflow:

1. **Builds** the optimized binary
2. **Signs** the binary (if certificates configured)
3. **Creates** a `.pkg` installer
4. **Signs** the package with Developer ID
5. **Notarizes** with Apple (~2-5 minutes)
6. **Staples** notarization ticket
7. **Creates** GitHub release with notes
8. **Uploads** all artifacts

---

## Testing

### Test Without Signing

Tests workflow mechanics without Apple Developer certificates.

```bash
git tag v1.0.0-test1
git push origin v1.0.0-test1
```

**Expected:**
- ✓ Workflow runs
- ✓ Binary built
- ✗ Binary unsigned
- ✗ PKG unsigned
- ✗ Notarization skipped
- ✓ Release created

**Verify:**
```bash
curl -LO https://github.com/kitzy/icongrabber/releases/download/v1.0.0-test1/icongrabber-1.0.0-test1.pkg
pkgutil --check-signature icongrabber-1.0.0-test1.pkg  # Should show: not signed
sudo installer -pkg icongrabber-1.0.0-test1.pkg -target /  # Gatekeeper warning expected
icongrabber --version
```

### Test With Signing Only

Tests code signing without notarization (faster).

**Setup:** Configure only signing secrets (not APPLE_ID, APPLE_TEAM_ID, APPLE_APP_PASSWORD)

```bash
git tag v1.0.0-test2
git push origin v1.0.0-test2
```

**Expected:**
- ✓ Binary signed
- ✓ PKG signed
- ✗ Notarization skipped

**Verify:**
```bash
curl -LO https://github.com/kitzy/icongrabber/releases/download/v1.0.0-test2/icongrabber-1.0.0-test2.pkg
pkgutil --check-signature icongrabber-1.0.0-test2.pkg  # Should show: signed
xcrun stapler validate icongrabber-1.0.0-test2.pkg  # Should fail (not notarized)
```

### Test Full Workflow

Complete test with signing and notarization.

**Setup:** Configure all secrets

```bash
git tag v1.0.0-test3
git push origin v1.0.0-test3
```

**Expected:**
- ✓ Binary signed
- ✓ PKG signed
- ✓ Notarized
- ✓ Zero warnings

**Verify:**
```bash
curl -LO https://github.com/kitzy/icongrabber/releases/download/v1.0.0-test3/icongrabber-1.0.0-test3.pkg
pkgutil --check-signature icongrabber-1.0.0-test3.pkg  # Should show: signed
xcrun stapler validate icongrabber-1.0.0-test3.pkg  # Should show: valid
sudo installer -pkg icongrabber-1.0.0-test3.pkg -target /  # No warnings!
icongrabber --version
```

---

## Architecture

### Process Flow

```
TRIGGER → BUILD → SIGN BINARY → CREATE PKG → SIGN PKG → NOTARIZE → RELEASE
```

**Detailed steps:**

1. **Trigger:** Git tag push or manual workflow
2. **Build:** Compile optimized Swift binary
3. **Sign Binary:** Code sign with Developer ID Application (if configured)
4. **Create PKG:** Build installer with binary and man page
5. **Sign PKG:** Sign installer with Developer ID Installer (if configured)
6. **Notarize:** Submit to Apple, wait for approval, staple ticket (if configured)
7. **Release:** Create GitHub release, upload artifacts

### Workflow Files

- `.github/workflows/release.yml` - Main release workflow
- `.github/workflows/ci.yml` - Continuous integration tests
- `release.sh` - Legacy release script (superseded by GitHub Actions)
- `scripts/setup_signing.sh` - Certificate export helper

### Signing & Notarization

**Why sign?**

Without signing:
- ⚠️ "Unidentified developer" warnings
- ⚠️ Users must bypass Gatekeeper
- ⚠️ May be blocked on newer macOS

With signing + notarization:
- ✅ Zero security warnings
- ✅ Professional installer experience
- ✅ Trusted worldwide

**What's required:**

1. **Developer ID Application** - Signs the binary
2. **Developer ID Installer** - Signs the `.pkg`
3. **Apple ID + App Password** - For notarization
4. **Team ID** - Links everything to your developer account

### Secrets Management

Secrets are stored in 1Password and accessed via GitHub Actions using the 1Password GitHub Action. This provides:

- ✅ Centralized secret management
- ✅ No secrets stored in GitHub
- ✅ Audit logging
- ✅ Easy rotation
- ✅ Team sharing

---

## Troubleshooting

### "package is not signed"

**Cause:** Signing secrets not configured or incorrect

**Fix:**
1. Verify `OP_SERVICE_ACCOUNT_TOKEN` in GitHub secrets
2. Verify 1Password item has all fields
3. Run `./scripts/setup_signing.sh` to regenerate secrets
4. Check workflow logs for "Skipping code signing" message

### "The specified item could not be found in the keychain"

**Cause:** Incorrect certificate identity string

**Fix:**
```bash
# Get the exact identity string
security find-identity -v -p codesigning

# Copy the FULL string including quotes:
# "Developer ID Application: Your Name (TEAM_ID)"
```

### Notarization fails with "Invalid credentials"

**Cause:** Incorrect Apple ID or app-specific password

**Fix:**
1. Verify APPLE_ID is your Apple Developer email
2. Generate a new app-specific password at appleid.apple.com
3. Update 1Password item
4. Retry release

### Workflow hangs during notarization

**Cause:** Apple notarization service is slow

**Fix:**
- Wait up to 10 minutes
- Check workflow logs for submission UUID
- Check status: `xcrun notarytool log <UUID> --apple-id <email> --team-id <TEAM>`

### Release created but files are missing

**Cause:** Workflow step failed after release creation

**Fix:**
1. Check workflow logs for errors
2. Delete the release and tag
3. Fix the issue
4. Retry: `git tag v1.0.0 && git push origin v1.0.0`

---

## Additional Resources

- **Workflow file:** `.github/workflows/release.yml`
- **Setup helper:** `scripts/setup_signing.sh`
- **Test suite:** `tests/README.md`
- **Actions:** https://github.com/kitzy/icongrabber/actions
- **Releases:** https://github.com/kitzy/icongrabber/releases
- **Apple Developer:** https://developer.apple.com/account
