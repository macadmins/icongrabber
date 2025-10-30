Release Workflow Architecture

Process Flow

```
┌─────────────────────────────────────────────────────────────────┐
│ TRIGGER RELEASE │
│ │
│ Option : Push tag Option : Manual trigger │
│ git tag v1.0.0Actions → Run workflow │
│ git push origin v1.0.0Enter version number │
└──────────────────────────┬───────────────────────────────────────┘
 │
 ▼
┌─────────────────────────────────────────────────────────────────┐
│ BUILD PHASE │
│ │
│ . Checkout code from repository │
│ . Determine version number │
│ . Compile Swift binary with optimizations │
│ . Strip debug symbols │
│ . Verify binary architecture │
└──────────────────────────┬───────────────────────────────────────┘
 │
 ▼
┌─────────────────────────────────────────────────────────────────┐
│ SIGNING PHASE │
│ (if secrets configured) │
│ │
│ . Import Pcertificate to temporary keychain │
│ . Sign binary with Developer ID Application │
│ - Runtime hardening enabled │
│ - Secure timestamp added │
│ . Verify code signature │
│ . Display signing details │
└──────────────────────────┬───────────────────────────────────────┘
 │
 ▼
┌─────────────────────────────────────────────────────────────────┐
│ PACKAGE CREATION │
│ │
│ . Create package directory structure: │
│ pkgroot/usr/local/bin/icongrabber │
│ pkgroot/usr/local/share/man/man/icongrabber.│
│ │
│ . Create postinstall script │
│ . Build component package │
│ . Create distribution XML │
│ . Build product archive (.pkg) │
└──────────────────────────┬───────────────────────────────────────┘
 │
 ▼
┌─────────────────────────────────────────────────────────────────┐
│ PKG SIGNING PHASE │
│ (if secrets configured) │
│ │
│ . Sign PKG with Developer ID Installer │
│ . Add secure timestamp │
│ . Verify PKG signature │
│ . Display certificate chain │
└──────────────────────────┬───────────────────────────────────────┘
 │
 ▼
┌─────────────────────────────────────────────────────────────────┐
│ NOTARIZATION PHASE │
│ (if Apple ID credentials configured) │
│ │
│ . Submit PKG to Apple notarization service │
│ . Wait for Apple to scan and approve (~-min) │
│ . Staple notarization ticket to PKG │
│ . Verify stapling successful │
│ │
│ Result: PKG trusted by Gatekeeper worldwide │
└──────────────────────────┬───────────────────────────────────────┘
 │
 ▼
┌─────────────────────────────────────────────────────────────────┐
│ DISTRIBUTION PREPARATION │
│ │
│ . Create binary tarball: │
│ - Copy binary │
│ - Include README, LICENSE │
│ - Compress as .tar.gz │
│ │
│ . Generate SHA-checksums │
│ . Create release notes │
│ - Installation instructions │
│ - Usage examples │
│ - Changelog │
│ - Checksums │
└──────────────────────────┬───────────────────────────────────────┘
 │
 ▼
┌─────────────────────────────────────────────────────────────────┐
│ GITHUB RELEASE │
│ │
│ Create release with: │
│ │
│ icongrabber-...pkg │
│ - Signed with Developer ID │
│ - Notarized by Apple │
│ - Ready for distribution │
│ │
│ icongrabber-..-macos-binary.tar.gz │
│ - For manual installation │
│ - Includes documentation │
│ │
│ checksums.txt │
│ - SHA-verification │
│ │
│ Release notes with full instructions │
└──────────────────────────┬───────────────────────────────────────┘
 │
 ▼
┌─────────────────────────────────────────────────────────────────┐
│ CLEANUP │
│ │
│ . Delete temporary keychain │
│ . Remove build artifacts │
│ . Workflow complete │
└─────────────────────────────────────────────────────────────────┘
```

Security Architecture

```
┌──────────────────────────────────────────────────────────────┐
│ GITHUB REPOSITORY │
│ │
│ Source Code (Public) Secrets (Encrypted) │
│ ├── main.swift ├── APPLE_CERTIFICATE_BASE│
│ ├── Makefile ├── APPLE_CERTIFICATE_PASSWORD │
│ └── workflows/release.yml ├── APPLE_SIGNING_IDENTITY │
│ ├── APPLE_INSTALLER_SIGNING... │
│ ├── APPLE_ID │
│ ├── APPLE_TEAM_ID │
│ └── APPLE_APP_PASSWORD │
└────────────┬─────────────────────────┬──────────────────────────┘
 │ │
 │ │ (Decrypted only in runner)
 ▼ ▼
┌─────────────────────────────────────────────────────────────────┐
│ GITHUB ACTIONS RUNNER (mac OS) │
│ │
│ ┌────────────────────────────────────────────────────────┐ │
│ │ TEMPORARY KEYCHAIN (Session only) │ │
│ │ │ │
│ │ ┌──────────────────────────────────────────────┐ │ │
│ │ │ Developer ID Application Certificate │ │ │
│ │ │ - Used to sign binary │ │ │
│ │ │ - Enables runtime hardening │ │ │
│ │ └──────────────────────────────────────────────┘ │ │
│ │ │ │
│ │ ┌──────────────────────────────────────────────┐ │ │
│ │ │ Developer ID Installer Certificate │ │ │
│ │ │ - Used to sign PKG │ │ │
│ │ │ - Verifies package integrity │ │ │
│ │ └──────────────────────────────────────────────┘ │ │
│ │ │ │
│ │ Auto-destroyed after workflow completes │ │
│ └────────────────────────────────────────────────────────┘ │
│ │
│ Communicates with: │
│ - Apple Notary Service (notarization) │
│ - Apple Timestamp Server (secure timestamps) │
└─────────────────────────────────────────────────────────────────┘
```

Certificate Trust Chain

```
Apple Root CA
 │
 ├── Apple Worldwide Developer Relations CA
 │ │
 │ ├── Developer ID Application Certificate
 │ │ └── Signs: icongrabber binary
 │ │
 │ └── Developer ID Installer Certificate
 │ └── Signs: icongrabber-...pkg
 │
 └── Apple Notary Service
 └── Validates & Notarizes: icongrabber-...pkg
 │
 └── Stapled Ticket (embedded in PKG)

End User's Mac
 │
 ├── Gatekeeper checks:
 │ . Valid signature from Developer ID
 │ . Notarization ticket present
 │ . Certificate not revoked
 │ . Code hasn't been tampered with
 │
 └── If all checks pass: Install without warnings 
```

Data Flow

```
Developer's Machine GitHub Actions End User's Mac
┌──────────────┐ ┌────────────┐ ┌──────────────┐
│ │ │ │ │ │
│ git tag │────────────────────▶│ Workflow │ │ │
│ v1.0.0│ │ Triggered │ │ │
│ │ │ │ │ │
└──────────────┘ └─────┬──────┘ └──────────────┘
 │
 ▼
 ┌────────────┐
 │ Build │
 │ Binary │
 └─────┬──────┘
 │
 ▼
 ┌────────────┐
 │ Sign │
 │ Binary │
 └─────┬──────┘
 │
 ▼
 ┌────────────┐
 │ Create │
 │ PKG │
 └─────┬──────┘
 │
 ▼
 ┌────────────┐
 │ Sign │
 │ PKG │
 └─────┬──────┘
 │
 ▼
 ┌────────────┐ ┌──────────────┐
 │ Notarize │─────────────▶│ Apple │
 │ with │ │ Notary │
 │ Apple │◀─────────────│ Service │
 └─────┬──────┘ └──────────────┘
 │ Approval
 ▼
 ┌────────────┐
 │ Staple │
 │ Ticket │
 └─────┬──────┘
 │
 ▼
 ┌────────────┐
 │ GitHub │
 │ Release │
 └─────┬──────┘
 │
 │ Download
 ▼
 ┌──────────────┐
 │ Download │
 │ PKG │
 └──────┬───────┘
 │
 ▼
 ┌──────────────┐
 │ Gatekeeper │
 │ Verifies │
 └──────┬───────┘
 │
 ▼
 ┌──────────────┐
 │ Install │
 │ Success! │
 └──────────────┘
```

File Structure After Release

```
GitHub Release Page
├── icongrabber-...pkg (signed & notarized)
│ └── Contains:
│ ├── usr/local/bin/icongrabber (signed binary)
│ ├── usr/local/share/man/man/icongrabber.│ └── postinstall script
│
├── icongrabber-..-macos-binary.tar.gz
│ └── Contains:
│ ├── icongrabber (signed binary)
│ ├── README.md
│ └── LICENSE
│
└── checksums.txt
 └── SHA-hashes for verification
```

Conditional Execution Paths

```
Start Workflow
 │
 ├─── Secrets Configured? ───┐
 │ YES │ NO
 │ │ │
 │ ▼ ▼
 │ Sign Binary Skip Signing
 │ │ │
 │ ▼ │
 │ Sign PKG Skip PKG Signing
 │ │ │
 │ ▼ │
 │ Apple ID Set? ────┐ │
 │ YES NO │ │
 │ │ │ │ │
 │ ▼ │ │ │
 │ Notarize │ │ │
 │ │ │ │ │
 │ └─────┬───────┘ │ │
 │ │ │ │
 │ ▼ ▼ ▼
 │ Create Release (Signed & Notarized)
 │
 └── Create Release (Unsigned)
```

---

This architecture ensures:
- Secure handling of certificates
- No secrets in code
- Works with or without signing
- Full Apple compliance
- Zero Gatekeeper issues for users
