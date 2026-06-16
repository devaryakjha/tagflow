# Tagflow 1.0.0-beta.0 Release Approval

## Status

- Date: 2026-06-16 Asia/Kolkata
- Release lane: beta prerelease
- Package scope: `tagflow`, `tagflow_table`
- Candidate base commit: `9060564a11ebff63e74f867bb13f0c5535f5ac54`
- Stable branch before merge: `origin/stable` at
  `cf75452df2a835e4917f4d5d5c2208e8ed8db200`
- PR: https://github.com/devaryakjha/tagflow/pull/72

## Owner Decision

The owner approved moving the native runtime line forward as the beta / first
feature-rich prerelease, after preserving the previous stable `main` state on
the `stable` branch and merging PR #72 into `main`.

Approved package versions:

- `tagflow` `1.0.0-beta.0`
- `tagflow_table` `1.0.0-beta.0`

This approval authorizes the beta prerelease package version bump, release
notes, tags, and pub.dev prerelease publication for the packages above.

## Claim Boundary

This approval does not authorize a stable `1.0.0` release, stable package-page
wording, or public faster/slower, lower-memory, leak-free, ranking, or
frame-budget performance claims.

The `stable` branch remains the Git channel for the pre-native-runtime stable
line. `main` carries the native runtime prerelease line.
