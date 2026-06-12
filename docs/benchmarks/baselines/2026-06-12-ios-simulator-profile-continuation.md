# 2026-06-12 iOS Simulator Profile Continuation

## Status

- Date: 2026-06-12 Asia/Kolkata
- Branch: `codex/tagflow-native-runtime-master`
- Commit: `40a0318e40fcd6f511db6dbf4d9fcddcd8cdc7da`
- Related gate: `physical-observed-profile`
- Posture: simulator recovery and profile limitation evidence only; no gate
  closure

## Purpose

Refresh the iOS Simulator path after the owner noted that Simulator can be
force-quit and relaunched. This checks whether the currently bootable Simulator
can advance the physical or observed-host profile gate.

It cannot. Flutter exposes the booted Simulator as a target, but profile-mode
iOS Simulator builds are rejected before benchmark collection.

## Simulator Recovery

Commands:

```bash
osascript -e 'quit app "Simulator"' || true
xcrun simctl boot 3BA9E377-4B6F-49A7-83FA-F640060D6442 || true
open -a Simulator
xcrun simctl bootstatus 3BA9E377-4B6F-49A7-83FA-F640060D6442 -b
PATH=/Users/arya/fvm/cache.git/bin:$PATH flutter devices
```

Observed result:

```text
iPhone 17 (mobile) | 3BA9E377-4B6F-49A7-83FA-F640060D6442 | ios |
com.apple.CoreSimulator.SimRuntime.iOS-26-5 (simulator)
```

Flutter also saw `macOS`, `Chrome`, and one wireless iPad. Cached physical iOS
devices continued to report LAN browsing / Developer Mode recovery errors.

## Target Audit With Booted Simulator

Command:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_TARGET_AUDIT_RUN_ID=2026-06-12-current-continuation-r2 \
TAGFLOW_TARGET_AUDIT_OUTPUT_DIR=build/benchmarks/target-availability \
dart run melos run benchmark:profile:target-audit
```

Ignored raw artifact:

```text
build/benchmarks/target-availability/2026-06-12-current-continuation-r2/target-availability-audit.json
```

Reviewed result:

```text
canRunPhysicalProfileProbe=false
summary=No credible physical profile target is available.
flutterIosSimulators=1
flutterWirelessIos=1
flutterConnectedPhysicalIos=0
xctraceOnlinePhysicalIos=0
adbAttachedAndroid=0
```

Simulator signal:

```text
id=3BA9E377-4B6F-49A7-83FA-F640060D6442
name=iPhone 17 (mobile)
blockingReasons=simulator
```

## Profile Build Probe

The first attempt used the profile baseline runner:

```bash
TAGFLOW_PROFILE_DEVICE=3BA9E377-4B6F-49A7-83FA-F640060D6442 \
TAGFLOW_PROFILE_PAIR=tagflow_native_json:native_ai_answer \
TAGFLOW_PROFILE_REPEAT=1 \
TAGFLOW_PROFILE_RUN_TIMEOUT_SECONDS=300 \
TAGFLOW_PROFILE_CONTINUE_ON_FAILURE=true \
TAGFLOW_PROFILE_RUN_ID=2026-06-12-ios-simulator-native-json-probe-r1 \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-ios-simulator \
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
dart run melos run benchmark:profile:baselines
```

That run reached the expected iOS Simulator profile-build failure, then hung
inside the Flutter Driver connection path and was interrupted. Generated iOS
project upgrade side effects were reverted.

To capture the limitation without the driver hang, the direct build probe was:

```bash
cd examples/tagflow
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
flutter build ios --simulator --profile --no-pub
```

Ignored raw log:

```text
build/benchmarks/profile-ios-simulator/2026-06-12-ios-simulator-native-json-probe-r1/flutter-build-ios-simulator-profile.log
```

Observed result:

```text
EXIT:1
Profile mode is not supported for simulators.
```

The profile baseline runner also emitted the lower-level Xcode/Flutter failure:

```text
Target aot_assembly_profile failed: Exception: release/profile builds are only
supported for physical devices. attempted to build for simulator.
```

## Interpretation

The Simulator recovery path is useful for local debug smoke, but it cannot
produce Flutter profile-mode benchmark evidence. A booted iOS Simulator remains
a non-credible target for `physical-observed-profile`.

The gate remains open. Beta preapproval still requires one of:

- a credible physical iOS or Android profile target that passes target audit
  and repeat profile collection; or
- an explicit owner waiver or owner-approved observed-host policy update.

This note does not support public benchmark claims, frame-budget claims, memory
claims, beta/stable release wording, or package publishing.
