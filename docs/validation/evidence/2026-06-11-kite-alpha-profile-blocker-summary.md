## Kite alpha profile blocker summary

Date: 2026-06-11
Repo under test: `/Users/arya/.codex/worktrees/8f02/kite`
Target: physical iPhone 17 profile launch for real `IPOInstrumentSheet`
Outcome: no release-grade supported-target profile evidence captured

### Verified setup

- `git status --short --branch` reported a clean detached `HEAD`.
- `git log --oneline -n 3` started with `d9682aec chore(deps): trial tagflow alpha runtime`.
- No `pubspec_overrides.yaml` existed in the Kite worktree.
- `pubspec.lock` resolved both `tagflow` and `tagflow_table` from hosted `1.0.0-alpha.1` with no path source.
- The worktree has `.fvmrc` pinned to Flutter `3.41.4`, but no `.fvm/flutter_sdk` symlink. The effective repo-local command path was `fvm flutter ...`.

### Reachability findings

- `fvm flutter devices -v` found the physical target only as `Found 1 wirelessly connected device`.
- `xcrun xctrace list devices` listed the same physical target under `Devices Offline`.
- `system_profiler SPUSBDataType` did not show an attached iPhone entry during this investigation.
- `xcrun devicectl list devices --filter ...` still showed the paired target as `available (paired)`, which is consistent with a remembered/pairable device, not proof of an active wired session.

### Bounded profile run

Command shape used:

```sh
fvm flutter run --profile -d <physical-ios-udid> --no-pub --dart-define=KITE_ENABLE_DEV_SESSION_TOOLS=true -v
```

Observed behavior:

- Flutter completed device enumeration and did not report a USB-connected iOS target.
- The run then invoked:

```text
xcodebuild -project ios/Runner.xcodeproj -scheme Runner -configuration Profile -destination id=<physical-ios-udid> -showBuildSettings BUILD_DIR=.../build/ios
```

- That `xcodebuild` step timed out after about 58.9 seconds and never advanced to a credible install, app launch, or attachable profile session.
- No profile artifact, frame timing capture, or real-device `IPOInstrumentSheet` observation was produced from the physical phone.

### Precise blocker

The current physical-target route is wireless-only from Flutter's perspective, and the profile launch stalls before install/launch while resolving build settings against that paired wireless destination. This is not credible supported-target profile evidence.

### Smallest next step

Use a truly active wired iPhone session that is visible to both macOS USB enumeration and Flutter as a normal connected iOS device, then rerun the same profile command and navigate the already-proven route to `IPOInstrumentSheet`.
