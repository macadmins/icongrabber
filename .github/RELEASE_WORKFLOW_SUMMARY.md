GitHub Release Workflow - Summary

What Was Created

A complete automated release system for Icon Grabber with code signing and notarization support.

Files Added

. `.github/workflows/release.yml`- Main release workflow
. `.github/RELEASE_SETUP.md`- Detailed setup instructions for code signing
. `.github/CREATING_RELEASES.md`- Quick guide for creating releases
. `CHANGELOG.md`- Version history template
. `scripts/setup_signing.sh`- Interactive certificate export helper
. `scripts/README.md`- Scripts directory documentation

What the Workflow Does

Automatic Release Process

When you push a tag like `v1.0.0`, the workflow will:

. Buildthe optimized binary with Swift
. Signthe binary (if certificates are configured)
. Createa professional `.pkg` installer
. Signthe package with Developer ID
. Notarizewith Apple (no Gatekeeper warnings!)
. Staplethe notarization ticket
. Createa GitHub release
. Uploadsigned PKG and binary tarball
. Generate SHA-checksums

Release Artifacts

Each release includes:
- `icongrabber-X.Y.Z.pkg` - Signed & notarized installer
- `icongrabber-X.Y.Z-macos-binary.tar.gz` - Binary tarball
- `checksums.txt` - SHA-verification

Getting Started

Option : With Code Signing (Recommended)

Best for:Production releases, public distribution

. Get certificates(requires Apple Developer account - $/year)
 - Developer ID Application certificate
 - Developer ID Installer certificate

. Run the setup helper: ```bash
 ./scripts/setup_signing.sh
 ```
 This will guide you through exporting and encoding your certificates.

. Configure Password: - Create a vault named GitHub(if you don't have one)
 - Create an item named Icon Grabber Secrets - Add all the fields shown by the setup script
 - Create a Password service account
 - Grant it read access to the GitHub vault

. Add GitHub Secret: - Add only `OP_SERVICE_ACCOUNT_TOKEN` to GitHub repository secrets
 - This token allows the workflow to read from Password

. Create a release: ```bash
 git tag v1.0.0 git push origin v1.0.0 ```

Result:Fully signed and notarized package - users can install with zero warnings!

Option : Without Code Signing

Best for:Testing, personal use, development builds

. Just create a release tag: ```bash
 git tag v1.0.0 git push origin v1.0.0 ```

Result:The workflow still runs and creates a release, but the package is unsigned. Users will need to bypass Gatekeeper (right-click → Open).

Quick Commands

Create a Release
```bash
Tag the current commit
git tag v1.0.0
Push the tag
git push origin v1.0.0```

Manual Release Trigger
Go to: Actions → Release → Run workflow
Test Locally
```bash
Build
make build

Test
./bin/icongrabber --help

Create a test PKG
(Follow the steps in .github/workflows/release.yml manually)
```

Security Notes

What Gets Signed

. Binary- The `icongrabber` executable
 - Prevents "unidentified developer" warnings
 - Allows running without Gatekeeper bypass

. PKG- The installer package
 - Verifies package integrity
 - Shows as "trusted" in installer

. Notarization- Apple verification
 - Malware scan by Apple
 - Trusted worldwide distribution

Secrets Security

- All secrets stored in Password (encrypted)
- Only service account token in GitHub (minimal permissions)
- Certificates never committed to repo
- Temporary keychain created & destroyed each run
- Ppassword protected
- Service account can be revoked instantly

Workflow Highlights

Smart Conditional Logic

The workflow works with or without secrets:

```yaml
Signs only if certificate is configured
if: ${{ secrets.APPLE_CERTIFICATE_BASE!= '' }}

Notarizes only if Apple ID is configured
if: ${{ secrets.APPLE_ID != '' }}
```

Comprehensive Verification

Every step includes verification:
- Binary signature check
- PKG signature validation
- Notarization status
- Stapling validation
- SHA-checksums

Detailed Release Notes

Auto-generated release notes include:
- Installation instructions (both PKG and manual)
- Usage examples
- Checksum verification commands
- Security verification steps

Troubleshooting

Workflow Fails at Signing

Problem:Secrets not configured correctly

Solution:. Run `./scripts/setup_signing.sh` again
. Verify all fields in Password Icon Grabber Secrets item
. Check that identities match exactly
. Verify service account has vault access

Notarization Times Out

Problem:Apple's notarization service is slow

Solution:- Wait and retry (usually takes -minutes)
- Check Apple Developer account is in good standing
- Verify app-specific password is valid

Users Report Gatekeeper Issues

Problem:Package might not be properly stapled

Solution:. Download the release PKG
. Verify: `pkgutil --check-signature icongrabber-...pkg`
. Check stapling: `xcrun stapler validate icongrabber-...pkg`
. If stapling failed, re-run the release

Best Practices

Before Each Release

. Test locally with `make build`
. Run the test suite
. Update `CHANGELOG.md`
. Update version in `release.sh` if needed
. Commit all changes
. Tag and push

After Each Release

. Download and test the PKG
. Verify installation works
. Test the binary works
. Update Homebrew formula (if applicable)
. Announce the release

Resources

Documentation
- [Release Setup Guide](.github/RELEASE_SETUP.md) - Complete certificate setup
- [Creating Releases](.github/CREATING_RELEASES.md) - Release process guide
- [Scripts README](scripts/README.md) - Helper scripts documentation

Apple Documentation
- [Code Signing Guide](https://developer.apple.com/support/code-signing/)
- [Notarization](https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution)
- [Developer ID Certificates](https://developer.apple.com/account/resources/certificates/list)

GitHub Resources
- [GitHub Actions](https://docs.github.com/en/actions)
- [GitHub Releases](https://docs.github.com/en/repositories/releasing-projects-on-github)
- [Encrypted Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)

Next Steps

. Set Up Signing (Optional but Recommended)

If you have an Apple Developer account:
```bash
./scripts/setup_signing.sh
```

Then add the secrets to GitHub.

. Create Your First Release

```bash
Make sure everything is committed
git status

Create and push a tag
git tag v1.0.0
git push origin v1.0.0```

. Watch the Workflow

Go to: https://github.com/kitzy/icongrabber/actions

. Test the Release

Download the PKG from the release page and test installation.

Support

If you run into issues:

. Check the GitHub Actions logs (very detailed)
. Review the troubleshooting sections in setup docs
. Test signing locally before debugging workflow
. Verify all secrets are correctly configured

---

Note:The workflow is designed to work with or without code signing. You can start with unsigned builds and add signing later when you're ready to distribute publicly.
