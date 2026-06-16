# 2026-06-12 Synthetic Viewport Repeat-5 Collection

## Status

- Date: 2026-06-12 Asia/Kolkata
- Collection commit: `0c02756354bca8e874ab0e04e7048080ee59f46c`
- Branch context: `codex/tagflow-native-runtime-master`
- Related gate: #74
- Posture: repeat-5 synthetic harness-stability evidence only; no
  observed-host, real-display, public benchmark, timing-threshold, comparison,
  beta, stable, lower-memory, leak-free, or frame-budget claim

## Purpose

Record the Slice 5 repeat-5 synthetic viewport collection after the formal
one-repeat synthetic policy probe passed.

This run proves that the profile harness can collect five successful
`tagflow:ai_answer_rich` macOS profile repeats with an explicitly requested
synthetic viewport, preserve the host-observed viewport separately, and satisfy
the synthetic report-only checker with `minRepeats=5`. It does not qualify
this Mac as a real `2.0x` reference target.

## Raw Artifacts

Raw artifacts were written only under ignored `build/` output:

```text
build/benchmarks/profile-synthetic/2026-06-12-synthetic-viewport-repeat5-r1/
```

Tracked summary note only; raw JSON and logs remain untracked.

Key artifact paths:

- `profile-baseline-manifest.json`
- `profile-baseline-summary.json`
- `tagflow/ai_answer_rich/repeat-01.json`
- `tagflow/ai_answer_rich/repeat-01.log`
- `tagflow/ai_answer_rich/repeat-02.json`
- `tagflow/ai_answer_rich/repeat-02.log`
- `tagflow/ai_answer_rich/repeat-03.json`
- `tagflow/ai_answer_rich/repeat-03.log`
- `tagflow/ai_answer_rich/repeat-04.json`
- `tagflow/ai_answer_rich/repeat-04.log`
- `tagflow/ai_answer_rich/repeat-05.json`
- `tagflow/ai_answer_rich/repeat-05.log`

## Commands

Collection:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_DEVICE=macos \
TAGFLOW_PROFILE_PAIR=tagflow:ai_answer_rich \
TAGFLOW_PROFILE_VIEWPORT_MODE=synthetic \
TAGFLOW_PROFILE_SYNTHETIC_LOGICAL_SIZE=800x600 \
TAGFLOW_PROFILE_SYNTHETIC_DEVICE_PIXEL_RATIO=2.0 \
TAGFLOW_PROFILE_REPEAT=5 \
TAGFLOW_PROFILE_CONTINUE_ON_FAILURE=true \
TAGFLOW_PROFILE_RUN_ID=2026-06-12-synthetic-viewport-repeat5-r1 \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-synthetic \
dart run melos run benchmark:profile:baselines
```

Summary:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=2026-06-12-synthetic-viewport-repeat5-r1 \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-synthetic \
dart run melos run benchmark:profile:summarize
```

Synthetic policy check with repeat-5 enforcement:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=2026-06-12-synthetic-viewport-repeat5-r1 \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-synthetic \
TAGFLOW_PROFILE_CHECK_POLICY=docs/benchmarks/policies/profile-synthetic-viewport-policy.json \
TAGFLOW_PROFILE_MIN_REPEATS=5 \
dart run melos run benchmark:profile:check
```

Observed-host policy refusal check:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=2026-06-12-synthetic-viewport-repeat5-r1 \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-synthetic \
TAGFLOW_PROFILE_CHECK_POLICY=docs/benchmarks/policies/profile-reference-runner-policy.json \
TAGFLOW_PROFILE_MIN_REPEATS=1 \
dart run melos run benchmark:profile:check
```

## Observed Result

Collection result:

- Run id: `2026-06-12-synthetic-viewport-repeat5-r1`
- Device: `macos`
- Renderer/fixture: `tagflow:ai_answer_rich`
- Selection mode: `pairs`
- Repeats: `5`
- Manifest status counts: `passed=5`
- Flutter built the macOS profile app for each repeat and the driver
  connected.
- Flutter printed `Failed to foreground app; open returned 1` for each repeat,
  but the driver still connected to the VM service and the integration test
  completed each time.

Summary result:

- `totalRuns=5`
- `successfulRuns=5`
- `failedRuns=[]`
- `observedRepeats=5`
- `outlierRepeats=[]`
- Effective benchmark viewport:
  - logical: `800x600`
  - physical: `1600x1200`
  - device pixel ratio: `2.0`
- Synthetic viewport mode metadata:
  - `mode=synthetic`
  - requested viewport: `800x600 @ 2.0x`
  - observed host before override: `800x600 @ 1.0x`
  - applied viewport: `800x600 @ 2.0x`
  - caveats:
    `test_view_override`, `not_real_display_scale`,
    `not_public_reference_target`
- Input summary:
  - `inputBytes=2059`
  - `inputLength=2059`
  - `sourceTypes=["html"]`
  - asset:
    `packages/tagflow_benchmarks/fixtures/html/ai_answer_rich.html`
- Memory and GC data are not used for any claim in this note. This run did not
  request `--profile-memory`, and phase-level GC values require separate memory
  evidence review before any memory wording can be promoted.
- Launch attribution:
  - `status=available`
  - scope: `local_runner_only`
  - caveats:
    `not_process_cold_start`,
    `command_envelope_includes_melos_flutter_drive_and_artifact_copy`,
    `cold_initial_render_is_first_fixture_render_inside_integration_test`

Selected report-only frame summaries:

- Warm scroll:
  - frame count median: `23`
  - p90 build median: `0.393ms`
  - worst build median: `0.559ms`
  - missed build budget total: `0`
  - missed raster budget total: `0`
- Cold initial render:
  - frame count median: `2`
  - p90 build median: `17.321ms`
  - worst build median: `17.321ms`
  - missed build budget total: `4`
  - missed raster budget total: `0`
- Warm rebuild:
  - frame count median: `1`
  - worst build median: `4.017ms`
  - missed build budget total: `0`
  - missed raster budget total: `0`

Synthetic policy-check result:

- Exit status: passed
- Effective `minRepeats=5`
- `passed=true`
- `issues=[]`
- Report-only finding:
  `synthetic_viewport_not_reference_target`

Observed-host policy-check result:

- Exit status: failed as expected
- `passed=false`
- Issue: `synthetic_viewport_not_allowed`
- This refusal is required because observed-host policies cannot qualify
  synthetic viewport artifacts.

## Interpretation

This run satisfies Slice 5 of the synthetic viewport profile design for the
selected `tagflow:ai_answer_rich` cell. It is useful for internal alpha
stabilization of the synthetic profile harness.

The cold initial render summary recorded missed build-budget counts, so this
note explicitly does not support frame-budget readiness or performance
promotion. All timing values remain report-only.

This note does not support:

- claiming this Mac is a real `2.0x` reference target;
- comparing synthetic timing numbers against observed-host runs;
- public faster/slower or benchmark-ranking claims;
- lower-memory, leak-free, frame-budget, beta, or stable promotion claims.
