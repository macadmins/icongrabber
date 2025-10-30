Scripts Directory

This directory contains helper scripts for Icon Grabber development and release management.

Setup Scripts

`setup_signing.sh`

Interactive helper script to export your Apple Developer certificates for GitHub Actions.

Usage:```bash
./scripts/setup_signing.sh
```

What it does:. Finds your Developer ID certificates in Keychain
. Guides you through exporting them as P. Converts to basefor GitHub Secrets
. Displays all the secrets you need to configure
. Extracts your Team ID automatically

Prerequisites:- mac OS with Xcode Command Line Tools
- Apple Developer account
- Developer ID Application certificate installed
- Developer ID Installer certificate installed

Output:All the GitHub secrets values you need for the release workflow, ready to copy and paste.

---

For more information on setting up releases, see:
- [Release Setup Guide](../.github/RELEASE_SETUP.md)
- [Creating Releases](../.github/CREATING_RELEASES.md)
