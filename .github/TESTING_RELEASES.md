Testing the Release Workflow

This guide helps you test the release workflow before creating a production release.

Test Strategy

. Test Without Signing (Simplest)

This tests the workflow mechanics without requiring Apple Developer certificates.

Setup
- No secrets required
- Works immediately

Test
```bash
Create a test tag
git tag v1.0.0-test
git push origin v1.0.0-test
```

Expected Result
- Workflow runs successfully
- Binary is built
-  Binary is unsigned
- PKG is created
-  PKG is unsigned
- Notarization is skipped
- GitHub release is created
- Artifacts are uploaded

Verify
```bash
Download the release
curl -LO https://github.com/kitzy/icongrabber/releases/download/v1.0.0-test/icongrabber-..-test.pkg

Try to verify signature (will fail - expected)
pkgutil --check-signature icongrabber-..-test.pkg
Should show: "package is not signed"

Install it (will trigger Gatekeeper warning - expected)
sudo installer -pkg icongrabber-..-test.pkg -target /

Test the binary works
icongrabber --version
icongrabber /Applications/Safari.app -o test.png -s ```

. Test With Signing Only

Tests code signing without notarization (faster, doesn't require app-specific password).

Setup
Configure only signing secrets:
- `APPLE_CERTIFICATE_BASE`
- `APPLE_CERTIFICATE_PASSWORD`
- `APPLE_SIGNING_IDENTITY`
- `APPLE_INSTALLER_SIGNING_IDENTITY`

Do NOT configure:
- ~~APPLE_ID~~
- ~~APPLE_TEAM_ID~~
- ~~APPLE_APP_PASSWORD~~

Test
```bash
git tag v1.0.0-test
git push origin v1.0.0-test
```

Expected Result
- Workflow runs successfully
- Binary is signed
- PKG is signed
-  Notarization is skipped (no Apple ID)
- GitHub release is created

Verify
```bash
Download
curl -LO https://github.com/kitzy/icongrabber/releases/download/v1.0.0-test/icongrabber-..-test.pkg

Verify signature (should pass)
pkgutil --check-signature icongrabber-..-test.pkg
Should show: "signed by Developer ID Installer: Your Name"

Try to verify notarization (will fail - expected)
xcrun stapler validate icongrabber-..-test.pkg
Should show: "The validate action failed"

Install (might still show Gatekeeper warning without notarization)
sudo installer -pkg icongrabber-..-test.pkg -target /
```

. Test Full Workflow (Signing + Notarization)

Complete end-to-end test with full signing and notarization.

Setup
Configure all secrets:
- `APPLE_CERTIFICATE_BASE`
- `APPLE_CERTIFICATE_PASSWORD`
- `APPLE_SIGNING_IDENTITY`
- `APPLE_INSTALLER_SIGNING_IDENTITY`
- `APPLE_ID`
- `APPLE_TEAM_ID`
- `APPLE_APP_PASSWORD`

Test
```bash
git tag v1.0.0-test
git push origin v1.0.0-test
```

Expected Result
- Workflow runs successfully
- Binary is signed
- PKG is signed
- Notarization succeeds (~-minutes)
- Ticket is stapled
- GitHub release is created
- No Gatekeeper warnings!

Verify
```bash
Download
curl -LO https://github.com/kitzy/icongrabber/releases/download/v1.0.0-test/icongrabber-..-test.pkg

Verify signature
pkgutil --check-signature icongrabber-..-test.pkg
Should show: "signed by Developer ID Installer: Your Name"

Verify notarization
xcrun stapler validate icongrabber-..-test.pkg
Should show: "The validate action worked!"

Install (no warnings!)
sudo installer -pkg icongrabber-..-test.pkg -target /

Test
icongrabber --version
icongrabber /Applications/Safari.app -o test.png -s ```

Local Testing (Before Pushing Tags)

Test Build Locally

```bash
Clean previous builds
rm -rf bin/

Build
make build

Verify it works
./bin/icongrabber --help
./bin/icongrabber /Applications/Safari.app -o test.png
```

Test Signing Locally

```bash
Get your signing identity
security find-identity -v -p codesigning

Sign the binary
codesign --force \
 --sign "Developer ID Application: Your Name (TEAM_ID)" \
 --options runtime \
 --timestamp \
 --verbose \
 bin/icongrabber

Verify signature
codesign --verify --verbose=bin/icongrabber
codesign --display --verbose=bin/icongrabber

Test it still works
./bin/icongrabber --version
```

Test PKG Creation Locally

```bash
Create package structure
mkdir -p pkgroot/usr/local/bin
cp bin/icongrabber pkgroot/usr/local/bin/

Build component package
pkgbuild \
 --root pkgroot \
 --identifier com.kitzy.icongrabber \
 --version ..\
 --install-location / \
 test-component.pkg

Create distribution XML
cat > test-distribution.xml << 'EOF'
<?xml version="." encoding="utf-"?>
<installer-gui-script min Spec Version="">
 <title>Icon Grabber Test</title>
 <organization>com.kitzy.icongrabber</organization>
 <domains enable_local System="true"/>
 <options customize="never" require-scripts="false" root Volume Only="true" />
 <choices-outline>
 <line choice="default">
 <line choice="com.kitzy.icongrabber"/>
 </line>
 </choices-outline>
 <choice id="default"/>
 <choice id="com.kitzy.icongrabber" visible="false">
 <pkg-ref id="com.kitzy.icongrabber"/>
 </choice>
 <pkg-ref id="com.kitzy.icongrabber" version=".." on Conclusion="none">test-component.pkg</pkg-ref>
</installer-gui-script>
EOF

Build product archive
productbuild \
 --distribution test-distribution.xml \
 --package-path . \
 test-unsigned.pkg

Sign it
productsign \
 --sign "Developer ID Installer: Your Name (TEAM_ID)" \
 --timestamp \
 test-unsigned.pkg \
 test-signed.pkg

Verify
pkgutil --check-signature test-signed.pkg

Test install
sudo installer -pkg test-signed.pkg -target /

Clean up
rm -rf pkgroot test-.pkg test-.xml
```

Workflow Monitoring

Watch the Workflow Run

. Push a tag
. Go to: https://github.com/kitzy/icongrabber/actions
. Click on the running workflow
. Watch each step in real-time

Key Steps to Monitor

. Build release binary- Should complete in ~seconds
. Import Code Signing Certificate- Should succeed if secrets are correct
. Sign binary- Look for " Binary signed successfully"
. Sign PKG- Look for " Package signed successfully"
. Notarize PKG- This takes -minutes (longest step)
. Create GitHub Release- Final step

Common Issues

| Step | Error | Solution |
|------|-------|----------|
| Import Certificate | "Invalid password" | Check `APPLE_CERTIFICATE_PASSWORD` secret |
| Sign binary | "No identity found" | Verify `APPLE_SIGNING_IDENTITY` matches exactly |
| Sign PKG | "No identity found" | Verify `APPLE_INSTALLER_SIGNING_IDENTITY` |
| Notarize | "Invalid credentials" | Check `APPLE_ID` and `APPLE_APP_PASSWORD` |
| Notarize | "Invalid team" | Verify `APPLE_TEAM_ID` |

Cleanup Test Releases

After testing, clean up test releases:

Delete GitHub Release

. Go to https://github.com/kitzy/icongrabber/releases
. Find the test release (e.g., v1.0.0-test)
. Click "Delete"

Delete Tags

```bash
Delete local tag
git tag -d v1.0.0-test

Delete remote tag
git push origin :refs/tags/v1.0.0-test
```

Clean Up Multiple Test Tags

```bash
List all test tags
git tag -l "-test"

Delete them all locally
git tag -l "-test" | xargs git tag -d

Delete them all remotely
git tag -l "-test" | xargs -I {} git push origin :refs/tags/{}
```

Manual Workflow Trigger Testing

You can also test without creating tags:

. Go to Actions→ Releaseworkflow
. Click "Run workflow". Enter version: `..-manual-test`
. Click "Run workflow"
This won't create a git tag, only a GitHub release.

Checklist Before Production Release

Before creating your first production release (v1.0.0):

- [ ] Test unsigned build (v1.0.0-test)
- [ ] Verify binary builds correctly
- [ ] Verify PKG installs correctly
- [ ] Test signed build (v1.0.0-test)
- [ ] Verify signatures are valid
- [ ] Test full workflow with notarization (v1.0.0-test)
- [ ] Verify notarization succeeds
- [ ] Install on a clean Mac and verify no Gatekeeper warnings
- [ ] Test all installation methods
- [ ] Verify binary works after installation
- [ ] Clean up all test releases and tags
- [ ] Update CHANGELOG.md
- [ ] Update version in release.sh if needed
- [ ] Review release notes template

Success Criteria

A successful test should:

. Workflow completes without errors
. Binary is functional
. PKG signature is valid (if signing enabled)
. Notarization succeeds (if enabled)
. Installation works on a clean Mac
. No Gatekeeper warnings (if fully signed and notarized)
. Binary executes successfully after installation
. Checksums match downloaded files

Tips

- Start simple:Test without signing first
- Add secrets gradually:Add signing, then notarization
- Use test tags:Always use `-test` suffix for testing
- Clean up:Delete test releases when done
- Monitor carefully:Watch the first run closely
- Test on clean Mac:If possible, test installation on a different Mac
- Keep certificates safe:Never commit or share certificate files

Resources

- [GitHub Actions Logs](https://github.com/kitzy/icongrabber/actions)
- [Release Workflow](.github/workflows/release.yml)
- [Setup Guide](.github/RELEASE_SETUP.md)
- [Quick Reference](.github/QUICK_REFERENCE.md)
