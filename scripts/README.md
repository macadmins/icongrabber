# Scripts Directory

This directory contains helper scripts for Icon Grabber development and release management.

## Setup Scripts

### `setup_signing.sh`

Interactive helper script to export your Apple Developer certificates for GitHub Actions.

**Usage:**
```bash
./scripts/setup_signing.sh
```

**What it does:**
1. Finds your Developer ID certificates in Keychain
2. Guides you through exporting them as P12
3. Converts to base64 for GitHub Secrets
4. Displays all the secrets you need to configure
5. Extracts your Team ID automatically

**Prerequisites:**
- macOS with Xcode Command Line Tools
- Apple Developer account
- Developer ID Application certificate installed
- Developer ID Installer certificate installed

**Output:**
All the GitHub secrets values you need for the release workflow, ready to copy and paste.

---

For more information on setting up releases, see [Release Guide](../.github/RELEASE_GUIDE.md).
