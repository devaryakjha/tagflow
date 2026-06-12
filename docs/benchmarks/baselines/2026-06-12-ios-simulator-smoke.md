# iOS Simulator Native JSON Smoke

## Status

- Date: 2026-06-12 Asia/Kolkata
- Commit: `006c3936504fbea4f4d47698729f04a77ee89ec1`
- Branch context: `codex/tagflow-native-runtime-master`
- Posture: route smoke only, not profile benchmark qualification

## Purpose

Record what the iOS Simulator can and cannot prove for the native runtime
benchmark gate.

The simulator is useful for quick launch/render evidence after the Simulator
app is restarted. It is not a replacement for physical-device or qualified
runner evidence because Flutter does not support profile or release iOS
Simulator builds.

## Simulator Restart And Discovery

Commands:

```bash
killall Simulator 2>/dev/null || true
xcrun simctl shutdown all 2>/dev/null || true
open -a Simulator
sleep 8
PATH=/Users/arya/fvm/cache.git/bin:$PATH flutter devices
xcrun simctl list devices booted
```

Observed output summary:

- Flutter found booted iOS Simulator:
  `iPhone 17` `3BA9E377-4B6F-49A7-83FA-F640060D6442`.
- Flutter also found `macOS` and `Chrome`.
- Flutter found two wireless physical iOS candidates:
  `00008150-00110C960186401C` and `00008120-0006395208E14032`.
- Flutter continued to emit LAN discovery / Developer Mode recovery messages
  for other cached wireless iOS devices.
- `xcrun simctl list devices booted` confirmed:
  `iPhone 17 (3BA9E377-4B6F-49A7-83FA-F640060D6442) (Booted)`.

## Profile-Mode Probe

Command:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_DEVICE=3BA9E377-4B6F-49A7-83FA-F640060D6442 \
TAGFLOW_PROFILE_PAIR=tagflow_native_json:native_ai_answer \
TAGFLOW_PROFILE_REPEAT=1 \
TAGFLOW_PROFILE_CONTINUE_ON_FAILURE=true \
TAGFLOW_PROFILE_RUN_ID=2026-06-12-ios-simulator-native-json-smoke \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-simulator-smoke \
dart run melos run benchmark:profile:baselines
```

Persisted raw artifacts:

- `build/benchmarks/profile-simulator-smoke/2026-06-12-ios-simulator-native-json-smoke/profile-baseline-manifest.json`
- `build/benchmarks/profile-simulator-smoke/2026-06-12-ios-simulator-native-json-smoke/tagflow_native_json/native_ai_answer/repeat-01.log`

Observed result:

- Manifest result:
  `totalRuns=1`, `successfulRuns=0`, `runStatusCounts.failed=1`.
- The run failed before launch because Flutter attempted an iOS
  profile-mode build for Simulator.
- Xcode/Flutter emitted:
  `release/profile builds are only supported for physical devices. attempted to build for simulator.`
- No integration response artifact was produced.

## Debug-Mode Route Smoke

Command:

```bash
cd examples/tagflow
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
flutter test integration_test/tagflow_perf_test.dart \
  -d 3BA9E377-4B6F-49A7-83FA-F640060D6442 \
  --dart-define=INTEGRATION_TEST_SHOULD_REPORT_RESULTS_TO_NATIVE=false \
  --dart-define=TAGFLOW_RENDERER=tagflow_native_json \
  --dart-define=TAGFLOW_FIXTURE=native_ai_answer
```

Observed result:

- Xcode debug build completed.
- Integration test `scrolls a Tagflow benchmark fixture` passed.
- Final output: `All tests passed!`

## Interpretation

The Simulator restart path is valid for local smoke evidence. It proves that the
native JSON renderer can launch, render, and scroll the `native_ai_answer`
fixture on the booted iOS Simulator in debug mode.

This does not satisfy the physical-target qualification gate. The profile
benchmark gate still needs either:

1. a physical iOS device that can build/install/run profile-mode Flutter, or
2. a qualified non-simulator reference target documented as acceptable for the
benchmark gate.

GitLab access is unrelated to this simulator evidence. It was only relevant to
one possible downstream real-app route check for Kite; an approved equivalent
real Flutter app route can replace that evidence path.
