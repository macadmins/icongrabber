# GitHub Release Workflow - Summary

## What Was Created

A complete automated release system for Icon Grabber with code signing and notarization support.

### Files Added

1. `.github/workflows/release.yml` - Main release workflow
2. `.github/RELEASE_SETUP.md` - Detailed setup instructions for code signing
3. `.github/CREATING_RELEASES.md` - Quick guide for creating releases
4. `CHANGELOG.md` - Version history template
5. `scripts/setup_signing.sh` - Interactive certificate export helper
6. `scripts/README.md` - Scripts directory documentation

## What the Workflow Does

### Automatic Release Process

When you push a tag like `v1.0.0`, the workflow will:

1. **Build** the optimized binary with Swift
2. **Sign** the binary (if certificates are configured)
3. **Create** a professional `.pkg` installer
4. **Sign** the package with Developer ID
5. **Notarize** with Apple (no Gatekeeper warnings!)
6. **Staple** the notarization ticket
7. **Create** a GitHub release
8. **Upload** signed PKG and binary tarball
9. **Generate** SHA-256 checksums

### Release Artifacts

Each release includes:
- `icongrabber-X.Y.Z.pkg` - Signed & notarized installer
- `icongrabber-X.Y.Z-macos-binary.tar.gz` - Binary tarball
- `checksums.txt` - SHA-256 verification

## Getting Started

### Option 1: With Code Signing (Recommended)

**Best for:** Production releases, public distribution

1. **Get certificates** (requires Apple Developer account - $99/year)
   - Developer ID Application certificate
   - Developer ID Installer certificate

2. **Run the setup helper:**
   ```bash
   ./scripts/setup_signing.sh
   ```
   This will guide you through exporting and encoding your certificates.

3. **Configure 1Password:**
   - Create a vault named **GitHub** (if you don't have one)
   - Create an item named **Icon Grabber Secrets**
   - Add all the fields shown by the setup script
   - Create a 1Password service account
   - Grant it read access to the GitHub vault

4. **Add GitHub Secret:**
   - Add only `OP_SERVICE_ACCOUNT_TOKEN` to GitHub repository secrets
   - This token allows the workflow to read from 1Password

5. **Create a release:**
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

**Result:** Fully signed and notarized package - users can install with zero warnings!

### Option 2: Without Code Signing

**Best for:** Testing, personal use, development builds

1. **Just create a release tag:**
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

**Result:** The workflow still runs and creates a release, but the package is unsigned. Users will need to bypass Gatekeeper (right-click → Open).

## Quick Commands

### Create a Release
```bash
# Tag the current commit
git tag v1.0.0

# Push the tag
git push origin v1.0.0
```

### Manual Release Trigger
Go to: **Actions** → **Release** → **Run workflow**

### Test Locally
```bash
# Build
make build

# Test
./bin/icongrabber --help

# Create a test PKG
# (Follow the steps in .github/workflows/release.yml manually)
```

## Security Notes

### What Gets Signed

1. **Binary** - The `icongrabber` executable
   - Prevents "unidentified developer" warnings
   - Allows running without Gatekeeper bypass

2. **PKG** - The installer package
   - Verifies package integrity
   - Shows as "trusted" in installer

3. **Notarization** - Apple verification
   - Malware scan by Apple
   - Trusted worldwide distribution

### Secrets Security

- All secrets stored in 1Password (encrypted)
- Only service account token in GitHub (minimal permissions)
- Certificates never committed to repo
- Temporary keychain created & destroyed each run
- P12 password protected
- Service account can be revoked instantly

## Workflow Highlights

### Smart Conditional Logic

The workflow works with or without secrets:

```yaml
# Signs only if certificate is configured
if: ${{ secrets.APPLE_CERTIFICATE_BASE64 != '' }}

# Notarizes only if Apple ID is configured
if: ${{ secrets.APPLE_ID != '' }}
```

### Comprehensive Verification

Every step includes verification:
- Binary signature check
- PKG signature validation
- Notarization status
- Stapling validation
- SHA-256 checksums

### Detailed Release Notes

Auto-generated release notes include:
- Installation instructions (both PKG and manual)
- Usage examples
- Checksum verification commands
- Security verification steps

## Troubleshooting

### Workflow Fails at Signing

**Problem:** Secrets not configured correctly

**Solution:**
1. Run `./scripts/setup_signing.sh` again
2. Verify all fields in 1Password **Icon Grabber Secrets** item
3. Check that identities match exactly
4. Verify service account has vault access

### Notarization Times Out

**Problem:** Apple's notarization service is slow

**Solution:**
- Wait and retry (usually takes 2-5 minutes)
- Check Apple Developer account is in good standing
- Verify app-specific password is valid

### Users Report Gatekeeper Issues

**Problem:** Package might not be properly stapled

**Solution:**
1. Download the release PKG
2. Verify: `pkgutil --check-signature icongrabber-*.pkg`
3. Check stapling: `xcrun stapler validate icongrabber-*.pkg`
4. If stapling failed, re-run the release

## Best Practices

### Before Each Release

1. Test locally with `make build`
2. Run the test suite
3. Update `CHANGELOG.md`
4. Update version in `release.sh` if needed
5. Commit all changes
6. Tag and push

### After Each Release

1. Download and test the PKG
2. Verify installation works
3. Test the binary works
4. Update Homebrew formula (if applicable)
5. Announce the release

## Resources

### Documentation
- [Release Setup Guide](.github/RELEASE_SETUP.md) - Complete certificate setup
- [Creating Releases](.github/CREATING_RELEASES.md) - Release process guide
- [Scripts README](scripts/README.md) - Helper scripts documentation

### Apple Documentation
- [Code Signing Guide](https://developer.apple.com/support/code-signing/)
- [Notarization](https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution)
- [Developer ID Certificates](https://developer.apple.com/account/resources/certificates/list)

### GitHub Resources
- [GitHub Actions](https://docs.github.com/en/actions)
- [GitHub Releases](https://docs.github.com/en/repositories/releasing-projects-on-github)
- [Encrypted Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)

## Next Steps

### 1. Set Up Signing (Optional but Recommended)

If you have an Apple Developer account:
```bash
./scripts/setup_signing.sh
```

Then add the secrets to GitHub.

### 2. Create Your First Release

```bash
# Make sure everything is committed
git status

# Create and push a tag
git tag v1.0.0
git push origin v1.0.0
```

### 3. Watch the Workflow

Go to: https://github.com/kitzy/icongrabber/actions

### 4. Test the Release

Download the PKG from the release page and test installation.

## Support

If you run into issues:

1. Check the GitHub Actions logs (very detailed)
2. Review the troubleshooting sections in setup docs
3. Test signing locally before debugging workflow
4. Verify all secrets are correctly configured

---


Note:The workflow is designed to work with or without code signing. You can start with unsigned builds and add signing later when you're ready to distribute publicly.
