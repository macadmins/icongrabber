# Creating a Release

Quick guide for maintainers on how to create a new release.

## Prerequisites

1. Complete the setup in [RELEASE_SETUP.md](RELEASE_SETUP.md) (one-time setup)
2. Ensure all changes are merged to `main`
3. Update version numbers and changelog

## Release Checklist

- [ ] Update version in `release.sh` if needed
- [ ] Update `CHANGELOG.md` or `README.md` with release notes
- [ ] Commit all changes
- [ ] Push to main
- [ ] Create and push a version tag
- [ ] Verify the release workflow completes
- [ ] Test the released package

## Creating a Release

### Method 1: Using Git Tags (Recommended)

```bash
# Ensure you're on main and up to date
git checkout main
git pull origin main

# Create a version tag (replace X.Y.Z with your version)
git tag v1.0.0

# Push the tag to GitHub
git push origin v1.0.0
```

The workflow will automatically:
1. Build the binary
2. Sign it (if secrets are configured)
3. Create a signed `.pkg`
4. Notarize the package
5. Create a GitHub release
6. Upload all artifacts

### Method 2: Manual Workflow Trigger

1. Go to [Actions → Release](../../actions/workflows/release.yml)
2. Click **"Run workflow"**
3. Enter the version number (e.g., `1.0.0`)
4. Click **"Run workflow"**

## Version Numbering

Follow [Semantic Versioning](https://semver.org/):

- **MAJOR** version (1.0.0 → 2.0.0): Incompatible API changes
- **MINOR** version (1.0.0 → 1.1.0): New functionality (backwards compatible)
- **PATCH** version (1.0.0 → 1.0.1): Bug fixes (backwards compatible)

## What Gets Released

Each release includes:

### 1. `icongrabber-X.Y.Z.pkg` - Signed and notarized installer
- Installs to `/usr/local/bin/icongrabber`
- Includes man page
- No Gatekeeper issues

### 2. `icongrabber-X.Y.Z-macos-binary.tar.gz` - Binary tarball
- For users who prefer manual installation
- Includes README and LICENSE

### 3. `checksums.txt` - SHA-256 checksums
- For verifying downloads

## After Release

### 1. Test the release
```bash
# Download and test the PKG
curl -LO https://github.com/kitzy/icongrabber/releases/download/vX.Y.Z/icongrabber-X.Y.Z.pkg

# Install it
sudo installer -pkg icongrabber-X.Y.Z.pkg -target /

# Test it works
icongrabber --version
icongrabber /Applications/Safari.app -o test.png -s 128
```

### 2. Announce the release
- Update project README if needed
- Share on relevant platforms
- Update package managers (Homebrew, etc.)

### 3. Monitor for issues
- Watch for user reports
- Check GitHub issues
- Be ready to patch if needed

## Rollback a Release

If you need to remove a release:

1. Go to [Releases](../../releases)
2. Find the release
3. Click **"Delete release"**
4. Delete the tag:
   ```bash
   git tag -d vX.Y.Z
   git push origin :refs/tags/vX.Y.Z
   ```

## Troubleshooting

### Release workflow fails

1. Check the [Actions logs](../../actions/workflows/release.yml)
2. Common issues:
   - Certificate/signing issues → Review `.github/RELEASE_SETUP.md`
   - Build errors → Test locally with `make build`
   - Notarization timeout → Wait and retry

### PKG is not signed

- Verify all secrets are configured (see `RELEASE_SETUP.md`)
- Check the workflow logs for signing steps
- If secrets are missing, the workflow will still complete but create unsigned builds

### Users report Gatekeeper issues

1. Verify the package is signed: `pkgutil --check-signature icongrabber-X.Y.Z.pkg`
2. Verify it's stapled: `xcrun stapler validate icongrabber-X.Y.Z.pkg`
3. Users can bypass Gatekeeper: Right-click the PKG → Open

## Emergency Hotfix Release

For critical bugs:

```bash
# Create a patch version
git tag v1.0.1
git push origin v1.0.1
```

The release process is the same, but consider:
- Testing more thoroughly first
- Documenting the fix in release notes
- Notifying users of the critical update

## Resources

- [GitHub Releases Documentation](https://docs.github.com/en/repositories/releasing-projects-on-github)
- [Semantic Versioning](https://semver.org/)
- [Keep a Changelog](https://keepachangelog.com/)

