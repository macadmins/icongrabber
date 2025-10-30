# Quick Reference Card

## Create a Release

```bash
git tag v1.0.0
git push origin v1.0.0
```

## Required Setup

### 1Password Configuration

Create a 1Password item in the **GitHub** vault named **IconGrabberSecrets** with these fields:

| Field Name | Where to Get It |
|------------|----------------|
| `APPLE_CERTIFICATE_BASE64` | Run `./scripts/setup_signing.sh` |
| `APPLE_CERTIFICATE_PASSWORD` | Password you set when exporting P12 |
| `APPLE_SIGNING_IDENTITY` | `security find-identity -v -p codesigning` |
| `APPLE_INSTALLER_SIGNING_IDENTITY` | `security find-identity -v -p codesigning` |
| `APPLE_ID` | Your Apple Developer email |
| `APPLE_TEAM_ID` | [developer.apple.com/account](https://developer.apple.com/account) |
| `APPLE_APP_PASSWORD` | [appleid.apple.com](https://appleid.apple.com) → Security → App-Specific Passwords |

### GitHub Secret

Only ONE secret needed in GitHub:

| Secret Name | Value |
|-------------|-------|
| `OP_SERVICE_ACCOUNT_TOKEN` | From 1Password service account (starts with `ops_`) |

## Verify a Release Locally

```bash
# Download the PKG
curl -LO https://github.com/kitzy/icongrabber/releases/download/v1.0.0/icongrabber-1.0.0.pkg

# Check signature
pkgutil --check-signature icongrabber-1.0.0.pkg

# Verify notarization
xcrun stapler validate icongrabber-1.0.0.pkg

# Install
sudo installer -pkg icongrabber-1.0.0.pkg -target /

# Test
icongrabber --version
```

## Local Build & Sign

```bash
# Build
make build

# Sign (replace with your identity)
codesign --force --sign "Developer ID Application: Your Name (TEAM)" \
  --options runtime --timestamp bin/icongrabber

# Verify
codesign --verify --verbose=4 bin/icongrabber
codesign --display --verbose=4 bin/icongrabber
```

## Release Files

Each release includes:
- `icongrabber-X.Y.Z.pkg` - Signed installer (recommended)
- `icongrabber-X.Y.Z-macos-binary.tar.gz` - Binary tarball
- `checksums.txt` - SHA-256 verification

## Important Links

- **Workflow:** `.github/workflows/release.yml`
- **Setup Guide:** `.github/RELEASE_SETUP.md`
- **Create Release:** `.github/CREATING_RELEASES.md`
- **Architecture:** `.github/WORKFLOW_ARCHITECTURE.md`
- **Actions:** https://github.com/kitzy/icongrabber/actions
- **Releases:** https://github.com/kitzy/icongrabber/releases

## Common Commands

```bash
# Setup signing (one-time)
./scripts/setup_signing.sh

# Build locally
make build

# Test locally
./bin/icongrabber --help

# Create release
git tag v1.0.0 && git push origin v1.0.0

# List tags
git tag -l

# Delete tag (if needed)
git tag -d v1.0.0
git push origin :refs/tags/v1.0.0
```

## Version Numbers

- **v1.0.0** → **v2.0.0** - Breaking changes
- **v1.0.0** → **v1.1.0** - New features
- **v1.0.0** → **v1.0.1** - Bug fixes

## Pre-Release Checklist

- [ ] Update `CHANGELOG.md`
- [ ] Test locally: `make build && ./bin/icongrabber --help`
- [ ] Run tests: `./tests/run_tests.sh`
- [ ] Commit all changes
- [ ] Tag and push
- [ ] Wait for workflow to complete
- [ ] Download and test the PKG
- [ ] Verify checksums

## Troubleshooting

| Problem | Solution |
|---------|----------|
| "No identity found" | Run `security find-identity -v -p codesigning` and verify certificates |
| Notarization fails | Check Apple ID and app-specific password in 1Password |
| 1Password loading fails | Verify `OP_SERVICE_ACCOUNT_TOKEN` in GitHub and vault access |
| Unsigned build | Secrets not configured in 1Password (workflow still works, creates unsigned build) |
| Gatekeeper blocks | Right-click PKG → Open (or verify it's properly signed and notarized) |

## Tips

- **Test first:** Create a test release with a tag like `v0.0.1-test`
- **Clean up:** Delete test releases and tags when done
- **Monitor:** Watch the Actions tab during your first release
- **Verify:** Always download and test the PKG after release
- **Document:** Update `CHANGELOG.md` with each release

---

**Need help?** See detailed guides in `.github/` directory.
Need help? See detailed guides in `.github/` directory.
