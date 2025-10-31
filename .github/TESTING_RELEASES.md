# Testing the Release Workflow

This guide helps you test the release workflow before creating a production release.

## Test Strategy

### 1. Test Without Signing (Simplest)

This tests the workflow mechanics without requiring Apple Developer certificates.

**Setup**
- No secrets required
- Works immediately

**Test**
```bash
# Create a test tag
git tag v1.0.0-test1
git push origin v1.0.0-test1
```

**Expected Result**
- Workflow runs successfully
- Binary is built
- ✗ Binary is unsigned
- PKG is created
- ✗ PKG is unsigned
- Notarization is skipped
- GitHub release is created
- Artifacts are uploaded

**Verify**
```bash
# Download the release
curl -LO https://github.com/kitzy/icongrabber/releases/download/v1.0.0-test1/icongrabber-1.0.0-test1.pkg

# Try to verify signature (will fail - expected)
pkgutil --check-signature icongrabber-1.0.0-test1.pkg
# Should show: "package is not signed"

# Install it (will trigger Gatekeeper warning - expected)
sudo installer -pkg icongrabber-1.0.0-test1.pkg -target /

# Test the binary works
icongrabber --version
icongrabber /Applications/Safari.app -o test.png -s 128
```

### 2. Test With Signing Only

Tests code signing without notarization (faster, doesn't require app-specific password).

**Setup**
Configure only signing secrets:
- `APPLE_CERTIFICATE_BASE64`
- `APPLE_CERTIFICATE_PASSWORD`
- `APPLE_SIGNING_IDENTITY`
- `APPLE_INSTALLER_SIGNING_IDENTITY`

Do NOT configure:
- ~~APPLE_ID~~
- ~~APPLE_TEAM_ID~~
- ~~APPLE_APP_PASSWORD~~

**Test**
```bash
git tag v1.0.0-test2
git push origin v1.0.0-test2
```

**Expected Result**
- Workflow runs successfully
- ✓ Binary is signed
- ✓ PKG is signed
- ✗ Notarization is skipped (no Apple ID)
- GitHub release is created

**Verify**
```bash
# Download
curl -LO https://github.com/kitzy/icongrabber/releases/download/v1.0.0-test2/icongrabber-1.0.0-test2.pkg

# Verify signature (should pass)
pkgutil --check-signature icongrabber-1.0.0-test2.pkg
# Should show: "signed by Developer ID Installer: Your Name"

# Try to verify notarization (will fail - expected)
xcrun stapler validate icongrabber-1.0.0-test2.pkg
# Should show: "The validate action failed"

# Install (might still show Gatekeeper warning without notarization)
sudo installer -pkg icongrabber-1.0.0-test2.pkg -target /
```

### 3. Test Full Workflow (Signing + Notarization)

Complete end-to-end test with full signing and notarization.

**Setup**
Configure all secrets:
- `APPLE_CERTIFICATE_BASE64`
- `APPLE_CERTIFICATE_PASSWORD`
- `APPLE_SIGNING_IDENTITY`
- `APPLE_INSTALLER_SIGNING_IDENTITY`
- `APPLE_ID`
- `APPLE_TEAM_ID`
- `APPLE_APP_PASSWORD`

**Test**
```bash
git tag v1.0.0-test3
git push origin v1.0.0-test3
```

**Expected Result**
- Workflow runs successfully
- ✓ Binary is signed
- ✓ PKG is signed
- ✓ Notarization succeeds (~2-5 minutes)
- ✓ Ticket is stapled
- GitHub release is created
- No Gatekeeper warnings!

**Verify**
```bash
# Download
curl -LO https://github.com/kitzy/icongrabber/releases/download/v1.0.0-test3/icongrabber-1.0.0-test3.pkg

# Verify signature
pkgutil --check-signature icongrabber-1.0.0-test3.pkg
# Should show: "signed by Developer ID Installer: Your Name"

# Verify notarization
xcrun stapler validate icongrabber-1.0.0-test3.pkg
# Should show: "The validate action worked!"

# Install (no warnings!)
sudo installer -pkg icongrabber-1.0.0-test3.pkg -target /

# Test
icongrabber --version
icongrabber /Applications/Safari.app -o test.png -s 128
```

## Local Testing (Before Pushing Tags)

### Test Build Locally

```bash
# Clean previous builds
rm -rf bin/

# Build
make build

# Verify it works
./bin/icongrabber --help
./bin/icongrabber /Applications/Safari.app -o test.png
```

### Test Signing Locally

```bash
# Get your signing identity
security find-identity -v -p codesigning

# Sign the binary
codesign --force \
  --sign "Developer ID Application: Your Name (TEAM_ID)" \
  --options runtime \
  --timestamp \
  --verbose \
  bin/icongrabber

# Verify signature
codesign --verify --verbose=4 bin/icongrabber
codesign --display --verbose=4 bin/icongrabber

# Test it still works
./bin/icongrabber --version
```

### Test PKG Creation Locally

```bash
# Create package structure
mkdir -p pkgroot/usr/local/bin
cp bin/icongrabber pkgroot/usr/local/bin/

# Build component package
pkgbuild \
  --root pkgroot \
  --identifier com.kitzy.icongrabber \
  --version 1.0.0 \
  --install-location / \
  test-component.pkg

# Create distribution XML
cat > test-distribution.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<installer-gui-script minSpecVersion="1">
  <title>Icon Grabber Test</title>
  <organization>com.kitzy.icongrabber</organization>
  <domains enable_localSystem="true"/>
  <options customize="never" require-scripts="false" rootVolumeOnly="true" />
  <choices-outline>
    <line choice="default">
      <line choice="com.kitzy.icongrabber"/>
    </line>
  </choices-outline>
  <choice id="default"/>
  <choice id="com.kitzy.icongrabber" visible="false">
    <pkg-ref id="com.kitzy.icongrabber"/>
  </choice>
  <pkg-ref id="com.kitzy.icongrabber" version="1.0.0" onConclusion="none">test-component.pkg</pkg-ref>
</installer-gui-script>
EOF

# Build product archive
productbuild \
  --distribution test-distribution.xml \
  --package-path . \
  test-unsigned.pkg

# Sign it
productsign \
  --sign "Developer ID Installer: Your Name (TEAM_ID)" \
  --timestamp \
  test-unsigned.pkg \
  test-signed.pkg

# Verify
pkgutil --check-signature test-signed.pkg

# Test install
sudo installer -pkg test-signed.pkg -target /

# Clean up
rm -rf pkgroot test-*.pkg test-*.xml
```

## Workflow Monitoring

### Watch the Workflow Run

1. Push a tag
2. Go to: https://github.com/kitzy/icongrabber/actions
3. Click on the running workflow
4. Watch each step in real-time

### Key Steps to Monitor

1. **Build release binary** - Should complete in ~30 seconds
2. **Import Code Signing Certificate** - Should succeed if secrets are correct
3. **Sign binary** - Look for "✓ Binary signed successfully"
4. **Sign PKG** - Look for "✓ Package signed successfully"
5. **Notarize PKG** - This takes 2-5 minutes (longest step)
6. **Create GitHub Release** - Final step

### Common Issues

| Step | Error | Solution |
|------|-------|----------|
| Import Certificate | "Invalid password" | Check `APPLE_CERTIFICATE_PASSWORD` secret |
| Sign binary | "No identity found" | Verify `APPLE_SIGNING_IDENTITY` matches exactly |
| Sign PKG | "No identity found" | Verify `APPLE_INSTALLER_SIGNING_IDENTITY` |
| Notarize | "Invalid credentials" | Check `APPLE_ID` and `APPLE_APP_PASSWORD` |
| Notarize | "Invalid team" | Verify `APPLE_TEAM_ID` |


## Cleanup Test Releases

After testing, clean up test releases:

### Delete GitHub Release

1. Go to https://github.com/kitzy/icongrabber/releases
2. Find the test release (e.g., v1.0.0-test1)
3. Click "Delete"

### Delete Tags

```bash
# Delete local tag
git tag -d v1.0.0-test1

# Delete remote tag
git push origin :refs/tags/v1.0.0-test1
```

### Clean Up Multiple Test Tags

```bash
# List all test tags
git tag -l "*-test*"

# Delete them all locally
git tag -l "*-test*" | xargs git tag -d

# Delete them all remotely
git tag -l "*-test*" | xargs -I {} git push origin :refs/tags/{}
```

## Manual Workflow Trigger Testing

You can also test without creating tags:

1. Go to **Actions** → **Release** workflow
2. Click **"Run workflow"**
3. Enter version: `1.0.0-manual-test`
4. Click **"Run workflow"**

This won't create a git tag, only a GitHub release.

## Checklist Before Production Release

Before creating your first production release (v1.0.0):

- [ ] Test unsigned build (v1.0.0-test1)
- [ ] Verify binary builds correctly
- [ ] Verify PKG installs correctly
- [ ] Test signed build (v1.0.0-test2)
- [ ] Verify signatures are valid
- [ ] Test full workflow with notarization (v1.0.0-test3)
- [ ] Verify notarization succeeds
- [ ] Install on a clean Mac and verify no Gatekeeper warnings
- [ ] Test all installation methods
- [ ] Verify binary works after installation
- [ ] Clean up all test releases and tags
- [ ] Update CHANGELOG.md
- [ ] Update version in release.sh if needed
- [ ] Review release notes template

## Success Criteria

A successful test should:

1. Workflow completes without errors
2. Binary is functional
3. PKG signature is valid (if signing enabled)
4. Notarization succeeds (if enabled)
5. Installation works on a clean Mac
6. No Gatekeeper warnings (if fully signed and notarized)
7. Binary executes successfully after installation
8. Checksums match downloaded files

## Tips

- **Start simple:** Test without signing first
- **Add secrets gradually:** Add signing, then notarization
- **Use test tags:** Always use `-test` suffix for testing
- **Clean up:** Delete test releases when done
- **Monitor carefully:** Watch the first run closely
- **Test on clean Mac:** If possible, test installation on a different Mac
- **Keep certificates safe:** Never commit or share certificate files

## Resources

- [GitHub Actions Logs](https://github.com/kitzy/icongrabber/actions)
- [Release Workflow](.github/workflows/release.yml)
- [Setup Guide](.github/RELEASE_SETUP.md)
- [Quick Reference](.github/QUICK_REFERENCE.md)

