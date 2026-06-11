# 2026-06-12 Physical Target USB Probe Stalled

## Status

- Date: 2026-06-12 Asia/Kolkata
- Coordinator commit: `62fa47717b06bb76f15bf6e9bd38026e7b7019f2`
- Worker probe base: `66f39d331a9faeca80ab15e478d7f49bd0eb365f`
- Branch context: `codex/tagflow-native-runtime-master`
- Posture: negative qualification evidence; no benchmark threshold or
  performance claim

## Purpose

This note refreshes the older physical-target pending evidence after the local
device state changed. The machine now exposes a paired physical iPhone 17
through Flutter/CoreDevice, but the attempted one-repeat profile probe still did
not produce a benchmark manifest or `integration_response_data.json`.

## Device Discovery

Commands:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH flutter devices -v
```

```bash
xcrun xctrace list devices
```

```bash
xcrun devicectl list devices
```

```bash
PATH=/Users/arya/Library/Android/sdk/platform-tools:$PATH adb devices -l
```

Observed summary:

- `flutter devices -v` reported `Arya's Iphone 17`
  `00008150-00110C960186401C` as a physical `iphoneos` target with
  `interface: usb`, `available: true`, model `iPhone 17`, and iOS `27.0`.
- `xcrun devicectl list devices` reported `Arya's Iphone 17` as
  `available (paired)`.
- `xcrun xctrace list devices` still listed the same physical iPhone under
  `Devices Offline`, so Apple tooling is not fully consistent for profiling.
- `adb devices -l` reported no attached Android targets.
- `system_profiler SPUSBDataType` did not return an iPhone/iPad match in the
  bounded search, so the USB attachment is visible through CoreDevice/Flutter
  rather than the checked USB report.

## Probe Attempt

Command attempted from the worker checkout:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_DEVICE=00008150-00110C960186401C \
TAGFLOW_RENDERER=tagflow \
TAGFLOW_FIXTURE=ai_answer_rich \
TAGFLOW_PROFILE_REPEAT=1 \
TAGFLOW_PROFILE_CONTINUE_ON_FAILURE=true \
TAGFLOW_PROFILE_RUN_ID=2026-06-12-physical-usb-probe \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-device-probe \
dart run melos run benchmark:profile
```

Observed result:

- The run entered `flutter drive` and `xcodebuild` for the physical device.
- No `profile-baseline-manifest.json`, `profile-baseline-summary.json`, or
  `integration_response_data.json` was produced under the checked build output
  paths before the probe exited.
- The probe dirtied generated iOS host files in the isolated worker worktree;
  those files were treated as Flutter/CocoaPods side effects and intentionally
  excluded from integration.

## Qualification Result

No physical target is qualified yet.

This is an improvement over the previous wireless-only evidence because the
iPhone 17 is now visible as a paired and available physical target to Flutter.
It is still not profile-qualified because a valid probe must produce the
benchmark manifest and integration JSON before the target can advance to a
repeat-count gate.

Current blockers:

- iOS target visibility is inconsistent across Flutter/CoreDevice and
  `xctrace`.
- The one-repeat profile probe did not persist a manifest or integration JSON.
- No physical Android target is attached.
- No repeat-5 physical baseline exists.

## Next Step

Retry only after confirming the physical iPhone is unlocked, trusted, and
available in Xcode's device window. The next probe should keep
`TAGFLOW_PROFILE_CONTINUE_ON_FAILURE=true`, preserve raw output under ignored
`build/benchmarks/profile-device-probe/`, and stop after the first concrete
manifest or failure artifact.
