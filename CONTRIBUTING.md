# Contributing to Icon Grabber

Thank you for your interest in contributing to Icon Grabber! 

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/icongrabber.git`
3. Create a feature branch: `git checkout -b my-feature`
4. Make your changes
5. Run tests: `make test`
6. Commit your changes: `git commit -am 'Add new feature'`
7. Push to your fork: `git push origin my-feature`
8. Open a Pull Request

## Development Setup

```bash
# Clone the repository
git clone https://github.com/macadmins/icongrabber.git
cd icongrabber

# Build the project
make build

# Run tests
make test

# Test locally
./bin/icongrabber /Applications/Safari.app
```

## Running Tests

Before submitting a PR, make sure all tests pass:

```bash
make test
```

The test suite includes:
- Integration tests
- CLI argument parsing tests
- Error handling tests
- Multiple icon size tests

See [tests/README.md](tests/README.md) for details.

## Code Guidelines

- **Swift Style:** Follow standard Swift conventions
- **Comments:** Add comments for complex logic
- **Error Handling:** Always handle errors gracefully
- **User Messages:** Keep CLI output clear and helpful

## Pull Request Process

1. **Update Documentation:** If you add features, update the README
2. **Add Tests:** Add tests for new functionality
3. **Pass CI:** Ensure all GitHub Actions checks pass
4. **Description:** Provide a clear description of changes
5. **One Feature:** Keep PRs focused on a single feature/fix

## Reporting Bugs

When reporting bugs, please include:

- macOS version
- Icon Grabber version (`icongrabber --version`)
- Steps to reproduce
- Expected vs actual behavior
- Error messages (if any)

## Feature Requests

Feature requests are welcome! Please:

- Check if it's already requested in Issues
- Explain the use case
- Describe the desired behavior
- Consider if it fits the project scope

## Questions?

Feel free to open an issue for any questions about contributing!

## For Maintainers

This section is for maintainers who have write access to the repository.

### Creating a Release

1. **Update CHANGELOG.md** with release notes for the new version
2. **Commit the changes:**
   ```bash
   git add CHANGELOG.md
   git commit -m "Update changelog for v1.0.0"
   git push origin main
   ```

3. **Create and push a tag:**
   ```bash
   git tag -a v1.0.0 -m "Release version 1.0.0"
   git push origin v1.0.0
   ```

4. **Monitor the workflow** at https://github.com/macadmins/icongrabber/actions

The GitHub Actions workflow will automatically:
1. Build the optimized binary
2. Sign the binary with hardened runtime
3. Create a signed installer package
4. Submit to Apple for notarization (~10 minutes)
5. Staple the notarization ticket
6. Create a GitHub release with all artifacts
7. Extract changelog entries and include them in release notes

### Manual Release (Alternative)

You can also trigger a release manually:

1. Go to **Actions** → **Release** workflow
2. Click **"Run workflow"**
3. Enter the version number (e.g., `1.0.0`)
4. Click **"Run workflow"**

### Release Documentation

- [Workflow Documentation](.github/workflows/README.md) - How the build process works
- [Secrets Management](.github/SECRETS.md) - Managing certificates and credentials
- [Setup Summary](.github/SETUP_SUMMARY.md) - Overview of the automated build setup

### Verifying Releases

After a release is created, verify the artifacts:

```bash
# Download and verify signature
curl -LO https://github.com/macadmins/icongrabber/releases/download/v1.0.0/icongrabber-1.0.0.pkg
pkgutil --check-signature icongrabber-1.0.0.pkg

# Verify notarization
spctl --assess --verbose --type install icongrabber-1.0.0.pkg

# Verify checksums
curl -LO https://github.com/macadmins/icongrabber/releases/download/v1.0.0/checksums.txt
shasum -a 256 -c checksums.txt
```

## License

By contributing, you agree that your contributions will be licensed under the Apache License 2.0.

