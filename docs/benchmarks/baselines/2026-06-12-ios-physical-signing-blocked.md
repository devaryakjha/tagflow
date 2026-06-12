# iOS Physical Target Signing Blocked

## Status

- Date: 2026-06-12 Asia/Kolkata
- Commit: `246e33abbb49a4b109eb5c314a31cbf493838546`
- Branch context: `codex/tagflow-native-runtime-master`
- Posture: negative qualification evidence only; no benchmark claim or
  threshold change

## Purpose

Record the bounded one-repeat physical iOS probe attempted after Flutter
listed `Arya's Iphone 17 (wireless)` as an available physical target.

The probe reached Xcode build/signing and produced a persisted failed run
manifest, but it did not install the app, launch the integration test, or
produce any runtime metric artifact.

## Command

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_DEVICE=00008150-00110C960186401C \
TAGFLOW_PROFILE_PAIR=tagflow_native_json:native_ai_answer \
TAGFLOW_PROFILE_REPEAT=1 \
TAGFLOW_PROFILE_CONTINUE_ON_FAILURE=true \
TAGFLOW_PROFILE_RUN_ID=2026-06-12-ios-physical-target-probe \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-device-probe \
dart run melos run benchmark:profile:baselines
```

## Persisted Runner Summary

- Run id:
  `2026-06-12-ios-physical-target-probe`
- Device:
  `00008150-00110C960186401C`
- Selected cell:
  `tagflow_native_json:native_ai_answer`
- Repeat count:
  `1`
- Manifest result:
  `totalRuns=1`, `successfulRuns=0`, `runStatusCounts.failed=1`
- Run result:
  `status=failed`, `exitCode=1`, `artifactPath=null`
- Memory profile:
  not requested
- Selection mode:
  `pairs`

Generated raw artifact paths:

```text
build/benchmarks/profile-device-probe/2026-06-12-ios-physical-target-probe/profile-baseline-manifest.json
build/benchmarks/profile-device-probe/2026-06-12-ios-physical-target-probe/profile-baseline-summary.json
build/benchmarks/profile-device-probe/2026-06-12-ios-physical-target-probe/tagflow_native_json/native_ai_answer/repeat-01.log
```

Those raw artifacts remain under ignored `build/benchmarks/` and are not part
of this docs note.

## Failure Details

The persisted run log shows the probe reached iOS build/signing and then failed
before installation:

- Flutter warned that wireless debugging on iOS 27 may be slower than USB.
- Flutter automatically selected development team `7573STCA2W`.
- Xcode reported no account for team `7573STCA2W`.
- Xcode reported no matching iOS App Development provisioning profile for
  bundle id `dev.aryak.tagflow`.
- Flutter could not find `build/ios/iphoneos/Runner.app` after the signing
  failure and did not run the integration test.

`flutter drive` also upgraded tracked iOS project files while preparing the
build. Those generated changes were treated as probe side effects and were not
accepted into the benchmark evidence branch.

## Qualification Result

Classification:
physical target listed, but install/launch/signing availability blocked.

The result is still useful because it proves the benchmark runner can target
the wireless iPhone UDID and persist a failed run manifest for the native JSON
pair. It is not a successful physical-device baseline. It contains no measured
render timing, frame, viewport, memory, or integration-response artifact.

## Next Required Action

Before any repeat-5 physical baseline:

1. Configure a valid Apple account or provisioning profile for team
   `7573STCA2W` and bundle id `dev.aryak.tagflow`, or update the example app to
   a signing configuration that is valid on this Mac.
2. Prefer USB for the first qualified iOS run, or explicitly accept wireless
   as a slower transport for a qualification probe.
3. Re-run the same one-repeat native JSON pair with
   `TAGFLOW_PROFILE_CONTINUE_ON_FAILURE=true`.
4. Move to repeat-5 only after a one-repeat probe installs, launches, and
   produces a successful integration artifact.
