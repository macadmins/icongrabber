Release Workflow Setup Guide

This guide explains how to set up code signing and notarization for the Icon Grabber release workflow using Password for secure secrets management.

Overview

The release workflow (`release.yml`) will:
. Build an optimized release binary
. Sign the binary with your Developer ID Application certificate
. Create a `.pkg` installer
. Sign the `.pkg` with your Developer ID Installer certificate
. Notarize the package with Apple
. Create a GitHub release with both the signed `.pkg` and a binary tarball

Secrets are securely stored in Password and accessed via the Password GitHub Action.

Prerequisites

- Apple Developer account ($/year) to sign and notarize mac OS applications
- Password account with ability to create service accounts
- GitHub repository access

Step : Generate Certificates

.Developer ID Application Certificate

This certificate is used to sign the binary itself.

. Go to [Apple Developer Certificates](https://developer.apple.com/account/resources/certificates/list)
. Click the "+" button to create a new certificate
. Select "Developer ID Application". Follow the instructions to create a Certificate Signing Request (CSR) using Keychain Access
. Upload the CSR and download the certificate
. Double-click the downloaded certificate to install it in your Keychain

.Developer ID Installer Certificate

This certificate is used to sign the `.pkg` installer.

. Go to [Apple Developer Certificates](https://developer.apple.com/account/resources/certificates/list)
. Click the "+" button to create a new certificate
. Select "Developer ID Installer". Follow the instructions to create a CSR and download the certificate
. Install it in your Keychain

Step : Export Certificates for GitHub

.Export as PFile

. Open Keychain Access. Select My Certificatesin the left sidebar
. Find your "Developer ID Application"certificate
. Right-click and select "Export". Choose `.p` format
. Set a strong password (you'll need this for GitHub secrets)
. Save the file (e.g., `Developer ID_Application.p`)

Note:The Pfile contains both certificates (Application and Installer) if they're in the same keychain. You only need to export once.

.Convert to Base
```bash
Navigate to where you saved the Pfile
base-i Developer ID_Application.p| pbcopy
```

This copies the base-encoded certificate to your clipboard.

.Get Your Certificate Identity

```bash
List your signing identities
security find-identity -v -p codesigning

Look for lines like:
) ABCDEF... "Developer ID Application: Your Name (TEAM_ID)"
) ABCDEF... "Developer ID Installer: Your Name (TEAM_ID)"
```

Copy the full identity strings (including quotes).

Step : Get Your Apple Team ID

```bash
Your Team ID is in the certificate name or you can find it at:
https://developer.apple.com/account (Membership Details)
```

Step : Create App-Specific Password

. Go to [appleid.apple.com](https://appleid.apple.com)
. Sign in with your Apple Developer account
. Go to Security→ App-Specific Passwords. Click "+" to generate a new password
. Name it (e.g., "GitHub Notarization")
. Copy the generated password (you won't be able to see it again)

Step : Configure Password

.Create a Password Vault (if needed)

. Open Password
. Create a vault named "GitHub"(or use an existing vault)

.Create an Item for Icon Grabber Secrets

. In Password, go to the GitHubvault
. Click New Item→ Secure Note. Name it: Icon Grabber Secrets. Add the following fields (click "+ add more" for each):

| Field Name | Value | Notes |
|------------|-------|-------|
| `APPLE_CERTIFICATE_BASE` | `<basestring>` | From Step .|
| `APPLE_CERTIFICATE_PASSWORD` | `<password>` | Password you set when exporting P|
| `APPLE_SIGNING_IDENTITY` | `Developer ID Application: Your Name (TEAM_ID)` | Full identity string |
| `APPLE_INSTALLER_SIGNING_IDENTITY` | `Developer ID Installer: Your Name (TEAM_ID)` | Full identity string |
| `APPLE_ID` | `your.email@example.com` | Your Apple Developer email |
| `APPLE_TEAM_ID` | `ABCDE` | Your -character Team ID |
| `APPLE_APP_PASSWORD` | `xxxx-xxxx-xxxx-xxxx` | App-specific password from Step |

. Save the item

.Create a Password Service Account

. Go to [Password.com](https://password.com) and sign in
. Navigate to Developer Tools→ Service Accounts. Click Create Service Account. Name it: GitHub Actions - Icon Grabber. Grant access to the GitHubvault (read-only is sufficient)
. Save the service account
. Copy the service account token(you'll only see this once!)
 - Format: `ops_xxxxxxxxxxxxxxxxxxxxxxxxxxxx`

.Add Service Account Token to GitHub

This is the ONLY secret stored in GitHub:

. Go to your GitHub repository: https://github.com/kitzy/icongrabber
. Navigate to Settings→ Secrets and variables→ Actions. Click New repository secret. Name: `OP_SERVICE_ACCOUNT_TOKEN`
. Value: `ops_xxxxxxxxxxxxxxxxxxxxxxxxxxxx` (from step .)
. Click Add secret
Step : Verify Password Secret References

The workflow uses Password secret references with this format:
```
op://GitHub/Icon Grabber Secrets/FIELD_NAME
```

Make sure your Password structure matches:
- Vault name:`GitHub`
- Item name:`Icon Grabber Secrets`
- Field names:Match exactly as shown in step .
Step : Test the Workflow

Option : Create a Release Tag

```bash
Create and push a version tag
git tag v1.0.0
git push origin v1.0.0```

This will automatically trigger the release workflow.

Option : Manual Trigger

. Go to Actions→ Release. Click Run workflow. Enter a version number (e.g., `..`)
. Click Run workflow
Workflow Behavior

With All Secrets Configured in Password
- Binary is signed
- PKG is signed
- PKG is notarized with Apple
- Users can install without Gatekeeper warnings

Without Secrets (Unsigned)
-  Binary is unsigned
-  PKG is unsigned
-  Users will need to bypass Gatekeeper
- Workflow still completes and creates a release

Troubleshooting

"No identity found" Error

Make sure your certificate identities exactly match what's in your keychain:
```bash
security find-identity -v -p codesigning
security find-identity -v -p basic
```

Also verify the field names in Password match exactly.

Notarization Fails

. Check that your Apple ID and App-Specific Password are correct in Password
. Verify your Team ID matches your Apple Developer account
. Check the notarization logs in the GitHub Actions output

Password Secret Loading Fails

. Verify `OP_SERVICE_ACCOUNT_TOKEN` is set correctly in GitHub Secrets
. Check that the service account has access to the GitHub vault
. Verify the vault name is exactly `GitHub`
. Verify the item name is exactly `Icon Grabber Secrets`
. Check that field names match exactly (case-sensitive)

Certificate Import Fails

. Verify the Ppassword in Password is correct
. Check that the baseencoding is complete (no line breaks)
```bash
Re-encode without line breaks
base-i Developer ID_Application.p| tr -d '\n' | pbcopy
```

Cannot Access Password Vault

. Ensure the service account has read access to the GitHub vault
. Check that the vault name matches exactly in the workflow file
. Verify the service account token hasn't expired

Gatekeeper Still Blocks the App

If users report Gatekeeper issues:
. Verify the package shows as "signed and notarized" in the workflow logs
. Check that stapling succeeded: `xcrun stapler validate icongrabber-...pkg`
. The first time a user downloads, they may need to right-click → Open (this is normal for new developer IDs)

Local Testing

You can test signing locally before pushing:

```bash
Build
make build

Sign the binary (use your actual identity)
codesign --force \
 --sign "Developer ID Application: Your Name (TEAM_ID)" \
 --options runtime \
 --timestamp \
 bin/icongrabber

Verify
codesign --verify --verbose=bin/icongrabber
codesign --display --verbose=bin/icongrabber

Test it works
./bin/icongrabber --help
```

Security Best Practices

. Never commit certificates or passwordsto the repository
. Use Password service accountswith minimal required permissions (read-only to specific vault)
. Rotate app-specific passwordsperiodically in both Apple ID and Password
. Use separate certificatesfor different projects if possible
. Revoke certificatesimmediately if compromised
. Keep your Pfile secure- it's like a password to your identity
. Limit service account access- only grant access to the vaults needed
. Monitor service account usage- review access logs in Password regularly

Resources

- [Password Service Accounts](https://developer.password.com/docs/service-accounts/)
- [Password GitHub Action](https://github.com/password/load-secrets-action)
- [Apple Code Signing Guide](https://developer.apple.com/support/code-signing/)
- [Notarization Documentation](https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution)
- [Creating Distribution-Signed Code](https://developer.apple.com/documentation/xcode/distributing-your-app-for-beta-testing-and-releases)

Getting Help

If you encounter issues:
. Check the GitHub Actions logs for detailed error messages
. Review Apple's notarization logs if notarization fails
. Verify all secrets are correctly configured in Password
. Check that the service account has proper vault access
. Test signing locally first to isolate issues

---

Note:You can skip the signing setup and still use the workflow. It will create unsigned builds that work locally, but users will need to bypass Gatekeeper.
