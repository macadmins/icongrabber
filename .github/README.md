GitHub Workflows & Documentation

This directory contains GitHub Actions workflows and comprehensive documentation for building, testing, and releasing Icon Grabber.

## Quick Start

For Users
Download the latest signed release from [Releases](https://github.com/kitzy/icongrabber/releases).

For Contributors
See [CONTRIBUTING.md](../CONTRIBUTING.md) in the root directory.

For Maintainers
To create a new release:
```bash
git tag v1.0.0
git push origin v1.0.0```

See [CREATING_RELEASES.md](CREATING_RELEASES.md) for details.

## Directory Contents

Workflows

| File | Purpose |
|------|---------|
| [`workflows/ci.yml`](workflows/ci.yml) | Continuous Integration - runs tests on PRs |
| [`workflows/release.yml`](workflows/release.yml) | Release automation - builds, signs, and releases |

Documentation

| Document | What It Covers | When to Read |
|----------|---------------|--------------|
| [QUICK_REFERENCE.md](QUICK_REFERENCE.md) | Command cheat sheet | Quick lookup of common commands |
| [1PASSWORD_SETUP.md](1PASSWORD_SETUP.md) | Password configuration guide | Setting up secrets management |
| [RELEASE_SETUP.md](RELEASE_SETUP.md) | Complete setup guide | One-time setup for code signing |
| [CREATING_RELEASES.md](CREATING_RELEASES.md) | How to create releases | Every time you release |
| [TESTING_RELEASES.md](TESTING_RELEASES.md) | Test the release workflow | Before first production release |
| [WORKFLOW_ARCHITECTURE.md](WORKFLOW_ARCHITECTURE.md) | Technical deep dive | Understanding how it works |
| [RELEASE_WORKFLOW_SUMMARY.md](RELEASE_WORKFLOW_SUMMARY.md) | Overview of release system | Introduction to the release process |

## Workflows Explained

CI Workflow (`workflows/ci.yml`)

Triggers: Pull requests to main, manual dispatch

What it does:
- Builds the binary
- Runs integration tests
- Tests on multiple mac OS versions
- Validates project structure
- Tests installation

Purpose:Ensures code quality before merging

Release Workflow (`workflows/release.yml`)

Triggers:Version tags (`v1.0.0`), manual dispatch

What it does:. Builds optimized binary
. Signs binary with Developer ID
. Creates `.pkg` installer
. Signs PKG with Developer ID
. Notarizes with Apple
. Staples notarization ticket
. Creates GitHub release
. Uploads signed artifacts

Purpose:Automated, signed, production releases

Key Features:- Works with or without code signing
- Comprehensive verification at each step
- Detailed release notes
- SHA-checksums
- Professional `.pkg` installer

## Code Signing & Notarization

Why Sign?

Without signing:
- Users see "unidentified developer" warnings
- Users must bypass Gatekeeper (right-click Open)
- Apps may be blocked on newer mac OS versions

With signing + notarization:
- Zero security warnings
- Professional installer experience
- Trusted worldwide
- No Gatekeeper issues

What You Need

. Apple Developer Account($/year)
. Developer ID Application Certificate(signs binary)
. Developer ID Installer Certificate(signs PKG)
. App-Specific Password(for notarization)
. Password Account(for secure secrets storage)

Setup Process

Step :Get certificates from [developer.apple.com](https://developer.apple.com/account)

Step :Run the setup helper:
```bash
./scripts/setup_signing.sh
```

Step :Configure Password:
- Create a vault named GitHub- Create an item named Icon Grabber Secrets- Add all fields shown by the setup script
- Create a Password service account with vault access

Step :Add to GitHub:
- Add only `OP_SERVICE_ACCOUNT_TOKEN` to repository secrets
- Settings Secrets and variables Actions New secret

Step :Create a release - it will be automatically signed!

See [RELEASE_SETUP.md](RELEASE_SETUP.md) for detailed instructions.

## Release Process Flow

```
Developer GitHub Actions End User
 
 git tag v1.0.0 
 git push origin v1.0.0 
 > 
 
 Build binary 
 Sign binary 
 Create PKG 
 Sign PKG 
 Notarize with Apple 
 Staple ticket 
 Create release 
 
 >
 Download PKG 
 
 Install
 (no warnings!)
```

## For Maintainers

First-Time Setup

. Setup Code Signing(optional but recommended)
 ```bash
 ./scripts/setup_signing.sh
 ```
 Follow the prompts to export certificates and get field values.

. Configure Password - Create GitHubvault (if needed)
 - Create Icon Grabber Secretsitem
 - Add each field shown by the setup script
 - Create a service account with vault access
 - Copy the service account token

. Add GitHub Secret - Go to repository Settings Secrets and variables Actions
 - Add `OP_SERVICE_ACCOUNT_TOKEN` with your service account token

. Test the Workflow ```bash
 Create a test release
 git tag v1.0.0-test
 git push origin v1.0.0-test
 ```
 See [TESTING_RELEASES.md](TESTING_RELEASES.md) for comprehensive testing.

. Create Your First Production Release ```bash
 git tag v1.0.0 git push origin v1.0.0 ```

Regular Release Process

. Update code and commit. Update CHANGELOG.md. Tag the release ```bash
 git tag v1.0.0 git push origin v1.0.0 ```
. Wait for workflow to complete(~-minutes with notarization)
. Download and test the release. Announce the release
Manual Release Trigger

Alternative to tagging:

. Go to Actions Release. Click "Run workflow". Enter version (e.g., `..`)
. Click "Run workflow"
## Troubleshooting

Workflow Fails

. Check Actions logs- Very detailed error messages
. Common issues: - Signing: Certificate secrets not configured correctly
 - Notarization: Apple ID credentials invalid
 - Build: Swift code doesn't compile

Workflow Succeeds but PKG is Unsigned

- Secrets are not configured in Password
- Or service account doesn't have vault access
- Workflow still completes successfully
- Creates unsigned builds (users must bypass Gatekeeper)

Notarization Takes Forever

- Normal: -minutes
- If >minutes: Check Apple Developer account status
- Try again: Sometimes Apple's servers are slow

Users Report Gatekeeper Issues

. Verify PKG is signed: `pkgutil --check-signature file.pkg`
. Verify notarization: `xcrun stapler validate file.pkg`
. Check workflow logs for any skipped steps

See detailed troubleshooting in [RELEASE_SETUP.md](RELEASE_SETUP.md).

## Additional Resources

Apple Documentation
- [Code Signing Guide](https://developer.apple.com/support/code-signing/)
- [Notarizing mac OS Software](https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution)
- [Developer ID Certificates](https://developer.apple.com/account/resources/certificates/list)

GitHub Documentation
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Encrypted Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [GitHub Releases](https://docs.github.com/en/repositories/releasing-projects-on-github)

Project Documentation
- [Main README](../README.md)
- [Contributing Guide](../CONTRIBUTING.md)
- [Changelog](../CHANGELOG.md)
- [Scripts README](../scripts/README.md)

## Tips

- Test without signing first- Simpler to debug
- Use test tags- `v1.0.0-test` for testing
- Monitor first release- Watch Actions tab closely
- Keep certificates safe- Never commit Pfiles
- Update changelog- Keep users informed
- Verify releases- Always download and test

## Quick Links

- [Actions](https://github.com/kitzy/icongrabber/actions)
- [Releases](https://github.com/kitzy/icongrabber/releases)
- [Settings Secrets](https://github.com/kitzy/icongrabber/settings/secrets/actions)
- [Apple Developer](https://developer.apple.com/account)
- [Apple App-Specific Passwords](https://appleid.apple.com)

---

Questions?See the individual documentation files above, or open an issue on GitHub.
