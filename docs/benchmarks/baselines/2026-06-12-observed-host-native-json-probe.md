# 2026-06-12 Observed-Host Native JSON Probe

## Status

- Date: 2026-06-12 Asia/Kolkata
- Collection commit: `4c636a92edc4e88a2502ce601df743db9fa313ef`
- Branch context: `codex/tagflow-native-runtime-master`
- Run id: `2026-06-12-observed-host-native-json-probe-r1`
- Posture: one-repeat observed-host profile probe; not reference-runner,
  physical-device, public benchmark, beta, stable, or frame-budget evidence

## Purpose

Record a current macOS observed-host profile probe for the native JSON runtime
path. This checks whether the runner can collect profile-mode frame artifacts
without synthetic viewport overrides, then applies the existing reference-runner
policy to avoid overclaiming this machine as a qualified target.

## Raw Artifacts

Raw artifacts were written only under ignored `build/` output:

```text
build/benchmarks/profile-observed-host/2026-06-12-observed-host-native-json-probe-r1/
```

Key artifact paths:

- `profile-baseline-manifest.json`
- `profile-baseline-summary.json`
- `tagflow_native_json/native_ai_answer/repeat-01.json`
- `tagflow_native_json/native_ai_answer/repeat-01.log`

## Commands

Collection:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_DEVICE=macos \
TAGFLOW_PROFILE_PAIR=tagflow_native_json:native_ai_answer \
TAGFLOW_PROFILE_REPEAT=1 \
TAGFLOW_PROFILE_CONTINUE_ON_FAILURE=true \
TAGFLOW_PROFILE_RUN_ID=2026-06-12-observed-host-native-json-probe-r1 \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-observed-host \
dart run melos run benchmark:profile:baselines
```

Summary:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=2026-06-12-observed-host-native-json-probe-r1 \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-observed-host \
dart run melos run benchmark:profile:summarize
```

Loose one-repeat completeness check:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=2026-06-12-observed-host-native-json-probe-r1 \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-observed-host \
TAGFLOW_PROFILE_MIN_REPEATS=1 \
dart run melos run benchmark:profile:check
```

Reference-runner policy check:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=2026-06-12-observed-host-native-json-probe-r1 \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-observed-host \
TAGFLOW_PROFILE_CHECK_POLICY=docs/benchmarks/policies/profile-reference-runner-policy.json \
TAGFLOW_PROFILE_MIN_REPEATS=1 \
dart run melos run benchmark:profile:check
```

## Observed Result

Collection result:

- Device: `macos`
- Renderer/fixture: `tagflow_native_json:native_ai_answer`
- Viewport mode: `observed_host`
- Repeats: `1`
- Successful runs: `1 / 1`
- Flutter built the macOS profile app and the driver connected.
- Flutter printed `Failed to foreground app; open returned 1`, but the driver
  still connected to the VM service and the integration test passed.

Summary result:

- `totalRuns=1`
- `successfulRuns=1`
- `failedRuns=[]`
- `observedRepeats=1`
- Input source type: `nativeJson`
- Input asset:
  `packages/tagflow_benchmarks/fixtures/native/native_ai_answer.json`
- Observed viewport:
  - logical: `800x600`
  - physical: `800x600`
  - device pixel ratio: `1.0`
- Launch attribution:
  - `status=available`
  - provenance: `macos_app_delegate_uptime_markers_v1`
  - scope: `local_runner_only`
  - caveats:
    `not_process_cold_start`,
    `command_envelope_includes_melos_flutter_drive_and_artifact_copy`,
    `cold_initial_render_is_first_fixture_render_inside_integration_test`

Loose completeness check:

- Exit status: passed
- `passed=true`
- `issues=[]`

Reference-runner policy check:

- Exit status: failed as expected
- `passed=false`
- Issue: `unexpected_viewport`
- Policy expected: `800x600 @ 2.0x`
- Observed: `800x600 @ 1.0x`

## Interpretation

This run proves the current macOS host can collect one successful observed-host
profile artifact for the native JSON runtime path. It does not qualify the host
as the reference runner because the device pixel ratio does not match
`docs/benchmarks/policies/profile-reference-runner-policy.json`.

The physical or observed-host profile gate remains open. This evidence does not
support physical-device readiness, public benchmark ranking, comparative
performance wording, frame-budget readiness, memory wording, beta promotion, or
stable release claims.
