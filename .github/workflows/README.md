# GitHub Actions Workflows

This directory contains automated workflows for building, testing, and releasing Icon Grabber.

## Workflows

### 1. CI Tests (`ci.yml`)

**Triggers:**
- Push to `main` or `development` branches
- Pull requests to `main` or `development` branches
- Manual trigger via workflow dispatch

**What it does:**
- Builds the icongrabber binary
- Runs integration tests
- Verifies the man page exists
- Uploads build artifacts for testing

**Use case:** Automated testing for every code change to ensure quality.

---

### 2. Release (`release.yml`)

**Triggers:**
- Push of version tags (e.g., `v1.0.0`)
- Manual trigger via workflow dispatch

**What it does:**
- Builds an optimized release binary
- **Signs the binary** with Developer ID Application certificate
- Creates a signed installer package (`.pkg`)
- **Notarizes the package** with Apple
- **Staples the notarization ticket** to the package
- Creates source tarball
- Generates SHA-256 checksums
- Creates a GitHub Release with all artifacts

**Security Features:**
- Binary signed with hardened runtime
- Package signed with Developer ID Installer certificate
- Notarized by Apple for Gatekeeper approval
- Stapled for offline verification

---

## Required Secrets

The following secrets must be configured in the GitHub repository settings:

### 1. `APP_CERTIFICATES_P12_MAOS`
Base64-encoded P12 certificate file for signing the application binary.

**Certificate Type:** Developer ID Application

**How to create:**
```bash
# Export from Keychain Access as .p12 file, then:
base64 -i certificate.p12 | pbcopy
```

### 2. `APP_CERTIFICATES_P12_PASSWORD_MAOS`
Password for the application certificate P12 file.

### 3. `PKG_CERTIFICATES_P12_MAOS`
Base64-encoded P12 certificate file for signing installer packages.

**Certificate Type:** Developer ID Installer

**How to create:**
```bash
# Export from Keychain Access as .p12 file, then:
base64 -i installer-cert.p12 | pbcopy
```

### 4. `PKG_CERTIFICATES_P12_PASSWORD_MAOS`
Password for the installer certificate P12 file.

### 5. `NOTARY_APP_PASSWORD_MAOS`
App-specific password for notarization.

**How to create:**
1. Go to https://appleid.apple.com
2. Sign in with `opensource@macadmins.io`
3. Generate an app-specific password
4. Save it securely

---

## Setting Up Secrets

1. Go to repository **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret**
3. Add each secret listed above
4. Ensure the secret names match exactly

---

## Team and Identity

- **Team ID:** `T4SK8ZXCXG`
- **Apple ID:** `opensource@macadmins.io`
- **Organization:** Mac Admins Open Source
- **Application Signing Identity:** `Developer ID Application: Mac Admins Open Source (T4SK8ZXCXG)`
- **Installer Signing Identity:** `Developer ID Installer: Mac Admins Open Source (T4SK8ZXCXG)`

---

## Creating a Release

### Method 1: Git Tag (Recommended)

```bash
# Tag the commit
git tag -a v1.0.0 -m "Release version 1.0.0"

# Push the tag
git push origin v1.0.0
```

This will automatically trigger the release workflow.

### Method 2: Manual Dispatch

1. Go to **Actions** tab in GitHub
2. Select **Release** workflow
3. Click **Run workflow**
4. Enter the version number (e.g., `1.0.0`)
5. Click **Run workflow**

---

## Release Process

When a release is triggered:

1. ✅ Code is checked out
2. ✅ Certificates are imported into temporary keychain
3. ✅ Binary is compiled with optimizations
4. ✅ Binary is signed with hardened runtime
5. ✅ Installer package is created
6. ✅ Package is signed
7. ✅ Package is submitted to Apple for notarization
8. ✅ Workflow waits for notarization approval (~5-10 minutes)
9. ✅ Notarization ticket is stapled to package
10. ✅ Checksums are generated
11. ✅ GitHub Release is created with all artifacts

---

## Verifying Releases

### Check Binary Signature
```bash
codesign -vvv --deep --strict /usr/local/bin/icongrabber
```

### Check Package Signature
```bash
pkgutil --check-signature icongrabber-1.0.0.pkg
```

### Check Notarization
```bash
spctl --assess --verbose --type install icongrabber-1.0.0.pkg
```

### Verify Checksums
```bash
shasum -a 256 -c checksums.txt
```

---

## Troubleshooting

### Notarization Fails

Check the notarization log:
```bash
xcrun notarytool log <submission-id> --keychain-profile "icongrabber-notary"
```

Common issues:
- Binary not signed with hardened runtime
- Missing entitlements
- Invalid certificate
- Expired certificate

### Signing Fails

- Verify secrets are correctly set in GitHub
- Check certificate expiration dates
- Ensure P12 passwords are correct
- Verify Team ID matches certificates

### Build Fails

- Check Swift version compatibility (requires Swift 5.9+)
- Verify macOS runner version (macos-14)
- Review build logs for compilation errors

---

## Updating Workflows

When modifying workflows:

1. Test changes on a feature branch first
2. Create a PR to review changes
3. Merge to main after approval
4. Monitor the workflow runs

---

## References

- [Apple Code Signing Guide](https://developer.apple.com/library/archive/documentation/Security/Conceptual/CodeSigningGuide/)
- [Apple Notarization Guide](https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Nudge Build Process](https://github.com/macadmins/nudge/blob/main/.github/workflows/build_nudge_release.yml)
