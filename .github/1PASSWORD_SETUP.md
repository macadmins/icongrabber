Password Setup Guide

Quick visual guide for configuring Password to work with the Icon Grabber release workflow.

Architecture

```
┌─────────────────────────────────────────────────────────────┐
│ PASSWORD │
│ │
│ Vault: GitHub │
│ ┌──────────────────────────────────────────────────────┐ │
│ │ Item: Icon Grabber Secrets (Secure Note) │ │
│ │ │ │
│ │ Fields: │ │
│ │ • APPLE_CERTIFICATE_BASE│ │
│ │ • APPLE_CERTIFICATE_PASSWORD │ │
│ │ • APPLE_SIGNING_IDENTITY │ │
│ │ • APPLE_INSTALLER_SIGNING_IDENTITY │ │
│ │ • APPLE_ID │ │
│ │ • APPLE_TEAM_ID │ │
│ │ • APPLE_APP_PASSWORD │ │
│ └──────────────────────────────────────────────────────┘ │
│ │
│ Service Account: "GitHub Actions - Icon Grabber" │
│ • Access: GitHub vault (read-only) │
│ • Token: ops_xxxxxxxxxxxxxxxxxxxxxxxxxx │
└──────────────────┬───────────────────────────────────────────┘
 │
 │ Service Account Token
 ▼
┌─────────────────────────────────────────────────────────────┐
│ GITHUB REPOSITORY │
│ │
│ Repository Secrets (Only secret needed!) │
│ ┌──────────────────────────────────────────────────────┐ │
│ │ OP_SERVICE_ACCOUNT_TOKEN = ops_xxxx... │ │
│ └──────────────────────────────────────────────────────┘ │
└──────────────────┬───────────────────────────────────────────┘
 │
 │ Workflow runs
 ▼
┌─────────────────────────────────────────────────────────────┐
│ GITHUB ACTIONS WORKFLOW │
│ │
│ . Load secrets from Password using service token │
│ . Build and sign binary │
│ . Create and sign PKG │
│ . Notarize with Apple │
│ . Create release │
└─────────────────────────────────────────────────────────────┘
```

Step-by-Step Setup

. Create Password Vault Structure

```
Password
└── Vaults
 └── GitHub (vault)
 └── Icon Grabber Secrets (secure note)
 ├── APPLE_CERTIFICATE_BASE(text field)
 ├── APPLE_CERTIFICATE_PASSWORD (password field)
 ├── APPLE_SIGNING_IDENTITY (text field)
 ├── APPLE_INSTALLER_SIGNING_IDENTITY (text field)
 ├── APPLE_ID (text field)
 ├── APPLE_TEAM_ID (text field)
 └── APPLE_APP_PASSWORD (password field)
```

. Get Values for Password

Run the setup script to get all values:

```bash
./scripts/setup_signing.sh
```

This will output all the values you need to add to Password.

. Create Password Item

In Password Desktop/Web:
. Open Password
. Navigate to the GitHubvault (create if it doesn't exist)
. Click New Item. Select Secure Note. Set title: `Icon Grabber Secrets`
. Add custom fields:

| Field Name | Type | Value |
|------------|------|-------|
| `APPLE_CERTIFICATE_BASE` | text | (long basestring) |
| `APPLE_CERTIFICATE_PASSWORD` | password | (your Ppassword) |
| `APPLE_SIGNING_IDENTITY` | text | `Developer ID Application: Your Name (TEAM)` |
| `APPLE_INSTALLER_SIGNING_IDENTITY` | text | `Developer ID Installer: Your Name (TEAM)` |
| `APPLE_ID` | text | `your@email.com` |
| `APPLE_TEAM_ID` | text | `ABCDE` |
| `APPLE_APP_PASSWORD` | password | `xxxx-xxxx-xxxx-xxxx` |

. Save the item

. Create Service Account

On Password.com:
. Go to https://password.com
. Sign in to your account
. Navigate to Developer Tools→ Service Accounts. Click Create Service Account. Name: `GitHub Actions - Icon Grabber`
. Description: `Service account for Icon Grabber release workflow`
. Grant permissions:
 - Select the GitHubvault
 - Permission: Read Items(not full access)
. Click Create. IMPORTANT:Copy the service account token now!
 - Format: `ops_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`
 - You'll only see this once
 - Save it temporarily (you'll add it to GitHub next)

. Add Service Account Token to GitHub

On GitHub:
. Go to https://github.com/kitzy/icongrabber
. Click Settings→ Secrets and variables→ Actions. Click New repository secret. Name: `OP_SERVICE_ACCOUNT_TOKEN`
. Secret: (paste the service account token from step )
. Click Add secret
Secret References in Workflow

The workflow uses this format to reference secrets:

```yaml
env:
 APPLE_CERTIFICATE_BASE: op://GitHub/Icon Grabber Secrets/APPLE_CERTIFICATE_BASE```

This breaks down as:
- `op://` - Password secret reference protocol
- `GitHub` - Vault name
- `Icon Grabber Secrets` - Item name
- `APPLE_CERTIFICATE_BASE` - Field name

Important:All names are case-sensitive and must match exactly!

Verification Checklist

Before running your first release:

- [ ] Password vault named exactly GitHubexists
- [ ] Item named exactly Icon Grabber Secretsexists
- [ ] All required fields are present with correct names
- [ ] Service account is created and has access to GitHub vault
- [ ] Service account token is added to GitHub as `OP_SERVICE_ACCOUNT_TOKEN`
- [ ] Field names match exactly (case-sensitive):
 - [ ] `APPLE_CERTIFICATE_BASE`
 - [ ] `APPLE_CERTIFICATE_PASSWORD`
 - [ ] `APPLE_SIGNING_IDENTITY`
 - [ ] `APPLE_INSTALLER_SIGNING_IDENTITY`
 - [ ] `APPLE_ID`
 - [ ] `APPLE_TEAM_ID`
 - [ ] `APPLE_APP_PASSWORD`

Testing the Setup

Test that Password integration works:

```bash
Create a test release
git tag v1.0.0-test
git push origin v1.0.0-test

Watch the workflow
Go to: https://github.com/kitzy/icongrabber/actions
```

Check the "Load secrets from Password" step in the workflow logs. It should succeed without errors.

Troubleshooting

"Failed to load secrets from Password"

Possible causes:- Service account token is incorrect
- Service account doesn't have access to the GitHub vault
- Service account has been revoked

Solution:. Verify `OP_SERVICE_ACCOUNT_TOKEN` in GitHub secrets
. Check service account still exists in Password
. Verify vault permissions

"Secret reference not found"

Possible causes:- Vault name is wrong (should be exactly `GitHub`)
- Item name is wrong (should be exactly `Icon Grabber Secrets`)
- Field name is wrong or misspelled

Solution:. Check vault name matches exactly
. Check item name matches exactly
. Verify all field names are correct (case-sensitive)

"Empty secret value"

Possible causes:- Field exists but has no value
- Field name in workflow doesn't match Password field

Solution:. Open the item in Password
. Verify all fields have values
. Check for typos in field names

Security Benefits

Using Password provides several advantages:

## Centralized Management- All secrets in one place
- Easy to update or rotate
- Audit trail of access

## Better Security- Password's encryption
- Fine-grained access control
- Can revoke service account instantly

## Team Friendly- Share vault with team members
- Service accounts for automation
- No need to share raw secrets

## Minimal GitHub Exposure- Only secret in GitHub (service token)
- Real secrets never touch GitHub
- Easier to rotate credentials

Secret Rotation

To rotate secrets:

. Update in Password- Change the field value
. No GitHub changes needed- Workflow automatically gets new value
. Instant effect- Next workflow run uses updated secret

To rotate service account:

. Create new service account in Password
. Update `OP_SERVICE_ACCOUNT_TOKEN` in GitHub
. Revoke old service account

Resources

- [Password Service Accounts](https://developer.password.com/docs/service-accounts/)
- [Password GitHub Action](https://github.com/password/load-secrets-action)
- [Password Secret References](https://developer.password.com/docs/cli/secret-references/)

---

Questions?See [RELEASE_SETUP.md](RELEASE_SETUP.md) for the complete setup guide.
