# 2026-06-12 Observed-Host Native JSON Repeat-5 Timeout-Bounded Run

## Status

- Date: 2026-06-12 Asia/Kolkata
- Collection commit: `f73a158a74b6c9ef1dd14fe6dfd3afbd9b6c79a9`
- Branch context: `codex/tagflow-native-runtime-master`
- Run id: `2026-06-12-observed-host-native-json-repeat5-timeout-r1`
- Posture: local observed-host repeat-5 stabilization evidence; not
  reference-runner, physical-device, public benchmark, beta, stable, memory, or
  comparative performance evidence

## Purpose

Re-run the native JSON observed-host lane after adding per-repeat profile
timeouts. The previous repeat-5 attempt stalled after driver connection and
produced no artifacts. This run verifies whether the lane can complete five
profile repeats when every repeat is bounded by a 180 second process timeout.

## Raw Artifacts

Raw artifacts were written only under ignored `build/` output:

```text
build/benchmarks/profile-observed-host/2026-06-12-observed-host-native-json-repeat5-timeout-r1/
```

Key artifact paths:

- `profile-baseline-manifest.json`
- `profile-baseline-summary.json`
- `tagflow_native_json/native_ai_answer/repeat-01.json`
- `tagflow_native_json/native_ai_answer/repeat-02.json`
- `tagflow_native_json/native_ai_answer/repeat-03.json`
- `tagflow_native_json/native_ai_answer/repeat-04.json`
- `tagflow_native_json/native_ai_answer/repeat-05.json`
- `tagflow_native_json/native_ai_answer/repeat-01.log`
- `tagflow_native_json/native_ai_answer/repeat-02.log`
- `tagflow_native_json/native_ai_answer/repeat-03.log`
- `tagflow_native_json/native_ai_answer/repeat-04.log`
- `tagflow_native_json/native_ai_answer/repeat-05.log`

## Commands

Collection:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_DEVICE=macos \
TAGFLOW_PROFILE_PAIR=tagflow_native_json:native_ai_answer \
TAGFLOW_PROFILE_REPEAT=5 \
TAGFLOW_PROFILE_CONTINUE_ON_FAILURE=true \
TAGFLOW_PROFILE_RUN_TIMEOUT_SECONDS=180 \
TAGFLOW_PROFILE_RUN_ID=2026-06-12-observed-host-native-json-repeat5-timeout-r1 \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-observed-host \
dart run melos run benchmark:profile:baselines
```

Summary:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=2026-06-12-observed-host-native-json-repeat5-timeout-r1 \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-observed-host \
dart run melos run benchmark:profile:summarize
```

Completeness check:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=2026-06-12-observed-host-native-json-repeat5-timeout-r1 \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-observed-host \
TAGFLOW_PROFILE_MIN_REPEATS=5 \
dart run melos run benchmark:profile:check
```

Native JSON observed-host policy check:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=2026-06-12-observed-host-native-json-repeat5-timeout-r1 \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-observed-host \
TAGFLOW_PROFILE_CHECK_POLICY=docs/benchmarks/policies/profile-native-json-observed-policy.json \
TAGFLOW_PROFILE_MIN_REPEATS=5 \
dart run melos run benchmark:profile:check
```

## Observed Result

Collection result:

- Device: `macos`
- Renderer/fixture: `tagflow_native_json:native_ai_answer`
- Viewport mode: `observed_host`
- Timeout: `180` seconds per repeat
- Repeats: `5`
- Successful runs: `5 / 5`
- Timed-out runs: `0 / 5`
- Flutter printed `Failed to foreground app; open returned 1` for each repeat,
  but the driver connected to the VM service and the integration test passed
  for every repeat.

Summary result:

- `totalRuns=5`
- `successfulRuns=5`
- `failedRuns=[]`
- `runStatusCounts={passed: 5}`
- `observedRepeats=5`
- Input source type: `nativeJson`
- Input asset:
  `packages/tagflow_benchmarks/fixtures/native/native_ai_answer.json`
- Input bytes: `4239`
- Frames per warm scroll repeat: `24`
- Warm scroll average build median: `0.171 ms`
- Warm scroll p90 build median: `0.313 ms`
- Warm scroll worst build median: `0.395 ms`
- Warm scroll average raster median: `1.108 ms`
- Warm scroll p90 raster median: `1.125 ms`
- Warm scroll worst raster median: `12.946 ms`
- Missed warm scroll build budget count: `0`
- Missed warm scroll raster budget count: `0`
- New-generation GC count: `2` per repeat
- Old-generation GC count: `0` per repeat
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

Completeness check:

- Exit status: passed
- `passed=true`
- `issues=[]`
- `minRepeats=5`

Native JSON observed-host policy check:

- Exit status: failed as expected
- `passed=false`
- Issue: `unexpected_viewport`
- Policy expected: `800x600 @ 2.0x`
- Observed: `800x600 @ 1.0x`

## Interpretation

This run proves the current macOS host can collect five successful
timeout-bounded observed-host profile artifacts for the native JSON runtime
path. It supersedes the previous stalled repeat-5 attempt for local harness
health and local stabilization discussion.

It does not qualify the current host as the reference runner because the device
pixel ratio does not match
`docs/benchmarks/policies/profile-native-json-observed-policy.json`.

After policy matrix enforcement, this native JSON run is intentionally outside
`docs/benchmarks/policies/profile-reference-runner-policy.json`, which describes
the default HTML renderer/fixture matrix. Use
`docs/benchmarks/policies/profile-native-json-observed-policy.json` for future
observed-host native JSON profile checks.

The physical or qualified observed-host profile gate remains open. This
evidence does not support physical-device readiness, public benchmark ranking,
comparative performance wording, frame-budget readiness, memory wording, beta
promotion, or stable release claims.
