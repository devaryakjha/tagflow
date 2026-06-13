# 2026-06-13 iPhone 17 Profile Signing Blocked

## Status

- Date: 2026-06-13 Asia/Kolkata
- Related gate: `physical-observed-profile`
- Device requested: `00008150-00110C960186401C`
- Flutter label: `Arya's Iphone 17 (wireless)`
- Posture: direct physical-device profile probe; no profile evidence collected

## Purpose

Check the owner-reported iPhone Mirroring / connected iPhone path directly
instead of relying only on the target-audit preflight.

## Command

```bash
cd examples/tagflow
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
  flutter run --profile --no-resident \
  -d 00008150-00110C960186401C \
  --no-pub
```

## Observed Result

Flutter selected the real iPhone and started a profile build:

```text
Launching lib/main.dart on Arya's Iphone 17 (wireless) in profile mode...
Automatically signing iOS for device deployment using specified development
team in Xcode project: 7573STCA2W
Running Xcode build...
```

The build failed before installation because signing is not configured for the
example app:

```text
No Account for Team "7573STCA2W". Add a new account in Accounts settings or
verify that your accounts have valid credentials.

No profiles for 'dev.aryak.tagflow' were found: Xcode couldn't find any iOS
App Development provisioning profiles matching 'dev.aryak.tagflow'.
```

Generated iOS project upgrade side effects from the failed probe were reverted.

## Interpretation

The iPhone 17 path is more promising than the target audit alone suggested:
Flutter can select the physical iPhone and begin a profile-mode device build.

The gate still remains open because no app was installed, launched, driven, or
profiled. The next unblock is signing/provisioning for the example app bundle
identifier or a bundle identifier/team configuration that this Mac can sign for
the physical iPhone.

This evidence does not support public benchmark claims, frame-budget claims,
memory claims, comparative performance wording, beta/stable wording, package
publishing, or PR #72 undraft/merge.
