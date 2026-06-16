# Physical Target Qualification Pending

## Status

- Date: 2026-06-12 Asia/Kolkata
- Commit: `01312e55de15c030ecb23e54a0921b09c3593129`
- Branch context: `codex/tagflow-native-runtime-master`
- Posture: evidence note only, not a benchmark claim or threshold change

## Purpose

Record the current physical iOS/Android target audit for the Tagflow native
runtime benchmark qualification flow.

This note exists because the repo toolchain exposed only an ambiguous
wireless-only iOS candidate and no Android device, then the required one-repeat
probe failed before the app bundle or integration artifact was produced. It
does not alter benchmark thresholds, public performance claims, or package
versions.

## Device Audit

Commands:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH flutter devices -v
```

```bash
xcrun xctrace list devices
```

```bash
PATH=/Users/arya/Library/Android/sdk/platform-tools:$PATH adb devices -l
```

Observed output summary:

- Connected devices listed by Flutter:
  - `iPhone 17` simulator `3BA9E377-4B6F-49A7-83FA-F640060D6442`
  - `macOS` desktop `macos`
  - `Chrome` web `chrome`
- Wirelessly connected devices listed by Flutter:
  - `Arya’s Iphone 17 (wireless)` `00008150-00110C960186401C`
  - `Aryakumar Jha’s iPad (wireless)` `00008120-0006395208E14032`
- Flutter also emitted LAN discovery / wireless Developer Mode recovery errors
  for other cached iOS devices, including:
  - `Dhanush’s iPhone 12`
  - `Anup’s iPad`
  - `Arya’s Iphone 15 Plus`
  - `Arya’s iPhone`
  - `Suny’s iPhone`
- `xctrace` listed every physical iOS device under `Devices Offline`,
  including the same `Arya’s Iphone 17 (27.0)` and `Aryakumar Jha’s iPad`
  identifiers that Flutter reported as wireless candidates.
- Android tooling was present at
  `/Users/arya/Library/Android/sdk/platform-tools/adb`, but `adb devices -l`
  reported `List of devices attached` with no physical Android targets.

## One-Repeat Probe

Command:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_DEVICE=00008150-00110C960186401C \
TAGFLOW_PROFILE_PAIR=tagflow:ai_answer_rich \
TAGFLOW_PROFILE_REPEAT=1 \
TAGFLOW_PROFILE_CONTINUE_ON_FAILURE=true \
TAGFLOW_PROFILE_RUN_ID=2026-06-12-ios-wireless-qualification-probe \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-device-probe \
dart run melos run benchmark:profile:baselines
```

Summary:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=2026-06-12-ios-wireless-qualification-probe \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-device-probe \
dart run melos run benchmark:profile:summarize
```

Check:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=2026-06-12-ios-wireless-qualification-probe \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-device-probe \
TAGFLOW_PROFILE_MIN_REPEATS=1 \
dart run melos run benchmark:profile:check
```

Observed probe result summary:

- Run id:
  `2026-06-12-ios-wireless-qualification-probe`
- Device:
  `00008150-00110C960186401C`
- Selected cell:
  `tagflow:ai_answer_rich`
- Manifest result:
  `totalRuns=1`, `successfulRuns=0`, `runStatusCounts.failed=1`
- Checker result:
  failed with `failed_runs_present`, `successful_runs_mismatch`, and
  `no_cell_summaries`
- Artifact result:
  no `integration_response_data.json` copy was produced under the run
  directory
- Per-run failure details from the persisted log:
  - Flutter warned that wireless debugging on iOS 27 may be slower than a USB
    connection.
  - Xcode timed out waiting for the requested destination to become available.
  - The available destination for `00008150-00110C960186401C` reported that
    the developer disk image could not be mounted on the device.
  - `flutter drive` then failed three launch attempts because no built
    `Runner.app` bundle became available for installation.

## Qualification Result

No physical iOS or Android target is currently qualified for a profile-mode
baseline:

- device missing:
  no physical Android device was attached, and no wired iOS device was listed
  as connected
- wireless-only iOS:
  the only physical iOS candidate attempted was wireless-only
- Developer Mode disabled:
  Flutter surfaced Developer Mode recovery guidance for multiple other cached
  wireless iOS devices, although the attempted `Arya’s Iphone 17` failure was
  a developer disk image / destination-availability problem rather than a
  confirmed Developer Mode disablement
- install failure:
  yes for the attempted wireless iPhone, because the developer disk image
  could not be mounted and no installable `Runner.app` was produced
- app launch timeout:
  yes for the attempted wireless iPhone, because Xcode timed out waiting for
  the destination to become available
- missing `integration_response_data.json`:
  yes, because the probe never reached a point where the example app emitted
  the integration artifact
- failed scroll:
  not reached
- OOM or process termination:
  not observed
- missing viewport or frame metadata:
  not reached, because no successful profile artifact existed

## Interpretation

Physical-target qualification remains pending. The repo now has concrete
negative evidence for one wireless iOS candidate: the benchmark harness can see
the device identifier, but the target is not stable enough for profile-mode
qualification because Xcode cannot turn it into an available install
destination and the benchmark never produces the required integration JSON.

The next human/device action should be concrete:

1. Reconnect a physical iPhone or iPad over USB, unlock it, and verify trust
   plus Developer Mode on-device.
2. Confirm in Xcode device tooling that the developer disk image mounts for
   the chosen UDID before rerunning the probe.
3. Rerun the same one-repeat probe with
   `TAGFLOW_PROFILE_CONTINUE_ON_FAILURE=true`.
4. Only after a successful probe should the coordinator run
   `TAGFLOW_PROFILE_MIN_REPEATS=1` and then move to a repeat-5 physical
   baseline.

If wired iOS is unavailable, the fallback is to qualify a real Android device
first. The current machine has Android tooling installed, but zero attached
Android targets.
