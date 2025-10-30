Creating a Release

Quick guide for maintainers on how to create a new release.

Prerequisites

. Complete the setup in [RELEASE_SETUP.md](RELEASE_SETUP.md) (one-time setup)
. Ensure all changes are merged to `main`
. Update version numbers and changelog

Release Checklist

- [ ] Update version in `release.sh` if needed
- [ ] Update `CHANGELOG.md` or `README.md` with release notes
- [ ] Commit all changes
- [ ] Push to main
- [ ] Create and push a version tag
- [ ] Verify the release workflow completes
- [ ] Test the released package

Creating a Release

Method : Using Git Tags (Recommended)

```bash
Ensure you're on main and up to date
git checkout main
git pull origin main

Create a version tag (replace X.Y.Z with your version)
git tag v1.0.0
Push the tag to GitHub
git push origin v1.0.0```

The workflow will automatically:
. Build the binary
. Sign it (if secrets are configured)
. Create a signed `.pkg`
. Notarize the package
. Create a GitHub release
. Upload all artifacts

Method : Manual Workflow Trigger

. Go to [Actions → Release](../../actions/workflows/release.yml)
. Click "Run workflow". Enter the version number (e.g., `..`)
. Click "Run workflow"
Version Numbering

Follow [Semantic Versioning](https://semver.org/):

- MAJORversion (..→ ..): Incompatible API changes
- MINORversion (..→ ..): New functionality (backwards compatible)
- PATCHversion (..→ ..): Bug fixes (backwards compatible)

What Gets Released

Each release includes:

. `icongrabber-X.Y.Z.pkg`- Signed and notarized installer
 - Installs to `/usr/local/bin/icongrabber`
 - Includes man page
 - No Gatekeeper issues

. `icongrabber-X.Y.Z-macos-binary.tar.gz`- Binary tarball
 - For users who prefer manual installation
 - Includes README and LICENSE

. `checksums.txt`- SHA-checksums
 - For verifying downloads

After Release

. Test the release ```bash
 Download and test the PKG
 curl -LO https://github.com/kitzy/icongrabber/releases/download/v X.Y.Z/icongrabber-X.Y.Z.pkg
 
 Install it
 sudo installer -pkg icongrabber-X.Y.Z.pkg -target /
 
 Test it works
 icongrabber --version
 icongrabber /Applications/Safari.app -o test.png -s ```

. Announce the release - Update project README if needed
 - Share on relevant platforms
 - Update package managers (Homebrew, etc.)

. Monitor for issues - Watch for user reports
 - Check GitHub issues
 - Be ready to patch if needed

Rollback a Release

If you need to remove a release:

. Go to [Releases](../../releases)
. Find the release
. Click "Delete release"
. Delete the tag:
 ```bash
 git tag -d v X.Y.Z
 git push origin :refs/tags/v X.Y.Z
 ```

Troubleshooting

Release workflow fails

. Check the [Actions logs](../../actions/workflows/release.yml)
. Common issues:
 - Certificate/signing issues → Review `.github/RELEASE_SETUP.md`
 - Build errors → Test locally with `make build`
 - Notarization timeout → Wait and retry

PKG is not signed

- Verify all secrets are configured (see `RELEASE_SETUP.md`)
- Check the workflow logs for signing steps
- If secrets are missing, the workflow will still complete but create unsigned builds

Users report Gatekeeper issues

. Verify the package is signed: `pkgutil --check-signature icongrabber-X.Y.Z.pkg`
. Verify it's stapled: `xcrun stapler validate icongrabber-X.Y.Z.pkg`
. Users can bypass Gatekeeper: Right-click the PKG → Open

Emergency Hotfix Release

For critical bugs:

```bash
Create a patch version
git tag v1.0.0
git push origin v1.0.0```

The release process is the same, but consider:
- Testing more thoroughly first
- Documenting the fix in release notes
- Notifying users of the critical update

Resources

- [GitHub Releases Documentation](https://docs.github.com/en/repositories/releasing-projects-on-github)
- [Semantic Versioning](https://semver.org/)
- [Keep a Changelog](https://keepachangelog.com/)
