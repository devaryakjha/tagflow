# 2026-06-12 Synthetic Viewport Policy Probe

## Status

- Date: 2026-06-12 Asia/Kolkata
- Collection commit: `9f536bd668dae53ad099dbab127ef8b83a6a78ff`
- Branch context: `codex/tagflow-native-runtime-master`
- Related gate: #74
- Posture: synthetic harness-stability evidence only; no observed-host,
  real-display, timing-threshold, comparison, beta, stable, or public
  performance claim

## Purpose

Record the formal Slice 4 one-repeat synthetic viewport probe after the
synthetic checker policy landed.

This run proves that the profile harness can collect a single
`tagflow:ai_answer_rich` macOS profile artifact with an explicitly requested
synthetic viewport, preserve the host-observed viewport separately, and pass
the synthetic report-only checker policy. It does not qualify this Mac as a
real `2.0x` reference target.

## Raw Artifacts

Raw artifacts were written only under ignored `build/` output:

```text
build/benchmarks/profile-synthetic-probe/2026-06-12-synthetic-viewport-policy-probe-r1/
```

Tracked summary note only; raw JSON and logs remain untracked.

Key artifact paths:

- `profile-baseline-manifest.json`
- `profile-baseline-summary.json`
- `tagflow/ai_answer_rich/repeat-01.json`
- `tagflow/ai_answer_rich/repeat-01.log`

## Commands

Collection:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_DEVICE=macos \
TAGFLOW_PROFILE_PAIR=tagflow:ai_answer_rich \
TAGFLOW_PROFILE_VIEWPORT_MODE=synthetic \
TAGFLOW_PROFILE_SYNTHETIC_LOGICAL_SIZE=800x600 \
TAGFLOW_PROFILE_SYNTHETIC_DEVICE_PIXEL_RATIO=2.0 \
TAGFLOW_PROFILE_REPEAT=1 \
TAGFLOW_PROFILE_CONTINUE_ON_FAILURE=true \
TAGFLOW_PROFILE_RUN_ID=2026-06-12-synthetic-viewport-policy-probe-r1 \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-synthetic-probe \
dart run melos run benchmark:profile:baselines
```

Summary:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=2026-06-12-synthetic-viewport-policy-probe-r1 \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-synthetic-probe \
dart run melos run benchmark:profile:summarize
```

Synthetic policy check:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=2026-06-12-synthetic-viewport-policy-probe-r1 \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-synthetic-probe \
TAGFLOW_PROFILE_CHECK_POLICY=docs/benchmarks/policies/profile-synthetic-viewport-policy.json \
dart run melos run benchmark:profile:check
```

Observed-host policy refusal check:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=2026-06-12-synthetic-viewport-policy-probe-r1 \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-synthetic-probe \
TAGFLOW_PROFILE_CHECK_POLICY=docs/benchmarks/policies/profile-reference-runner-policy.json \
TAGFLOW_PROFILE_MIN_REPEATS=1 \
dart run melos run benchmark:profile:check
```

## Observed Result

Collection result:

- Run id: `2026-06-12-synthetic-viewport-policy-probe-r1`
- Device: `macos`
- Renderer/fixture: `tagflow:ai_answer_rich`
- Selection mode: `pairs`
- Repeats: `1`
- Manifest status counts: `passed=1`
- Flutter built the macOS profile app and the driver connected.
- Flutter printed `Failed to foreground app; open returned 1`, but the driver
  still connected to the VM service and the integration test completed.

Summary result:

- `totalRuns=1`
- `successfulRuns=1`
- `failedRuns=[]`
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
- Launch attribution:
  - `status=available`
  - scope: `local_runner_only`
  - caveats:
    `not_process_cold_start`,
    `command_envelope_includes_melos_flutter_drive_and_artifact_copy`,
    `cold_initial_render_is_first_fixture_render_inside_integration_test`

Synthetic policy-check result:

- Exit status: passed
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

This run satisfies Slice 4 of the synthetic viewport profile design. The next
#74 benchmark step can be repeat-5 synthetic collection under the same
synthetic policy.

This note does not support:

- claiming this Mac is a real `2.0x` reference target;
- comparing synthetic timing numbers against observed-host runs;
- public faster/slower or benchmark-ranking claims;
- lower-memory, leak-free, frame-budget, beta, or stable promotion claims.
