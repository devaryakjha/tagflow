# 2026-06-12 macOS Reference Probe DPR Mismatch

## Status

- Date: 2026-06-12 Asia/Kolkata
- Collection commit: `15fdda247191e597ac2ae6231fa9bde641d1e673`
- Branch context: `codex/tagflow-native-runtime-master`
- Posture: negative reference-runner qualification evidence only; no timing
  threshold, comparison, beta, or public performance claim

## Purpose

Record the fresh one-repeat macOS reference probe requested before any
repeat-5 benchmark collection on a new or uncertain target.

This run confirms that the current machine can build, launch, drive, and emit
profile artifacts for the example-app benchmark harness. It does not satisfy
the active reference policy because the observed device pixel ratio is `1.0`,
while the policy requires `800x600 @ 2.0x`.

## Raw Artifacts

Raw artifacts were written only under ignored `build/` output:

```text
build/benchmarks/profile-reference-probe/2026-06-12-macos-reference-probe-15fdda2/
```

Tracked summary note only; raw JSON and logs remain untracked.

## Commands

Collection:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_RENDERER=tagflow \
TAGFLOW_FIXTURE=ai_answer_rich \
TAGFLOW_PROFILE_DEVICE=macos \
TAGFLOW_PROFILE_REPEAT=1 \
TAGFLOW_PROFILE_RUN_ID=2026-06-12-macos-reference-probe-15fdda2 \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-reference-probe \
TAGFLOW_PROFILE_CONTINUE_ON_FAILURE=true \
dart run melos run benchmark:profile:baselines
```

Summary:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=2026-06-12-macos-reference-probe-15fdda2 \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-reference-probe \
dart run melos run benchmark:profile:summarize
```

Policy check:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=2026-06-12-macos-reference-probe-15fdda2 \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-reference-probe \
TAGFLOW_PROFILE_CHECK_POLICY=docs/benchmarks/policies/profile-reference-runner-policy.json \
dart run melos run benchmark:profile:check
```

## Observed Result

Collection result:

- Run id: `2026-06-12-macos-reference-probe-15fdda2`
- Device: `macos`
- Renderer/fixture: `tagflow:ai_answer_rich`
- Repeats: `1`
- Manifest status counts: `passed=1`
- The macOS app build completed and the Flutter driver connected.
- Flutter printed `Failed to foreground app; open returned 1`, but the driver
  still connected to the VM service and the integration test completed.

Summary result:

- `totalRuns=1`
- `successfulRuns=1`
- `failedRuns=[]`
- Observed viewport:
  - logical: `800x600`
  - physical: `800x600`
  - device pixel ratio: `1.0`
- Input summary:
  - `inputBytes=2059`
  - `inputLength=2059`
  - `sourceTypes=["html"]`
  - asset:
    `packages/tagflow_benchmarks/fixtures/html/ai_answer_rich.html`
- Report-only outlier:
  - repeat `1`
  - reasons: `missed_raster_budget`, `worst_raster_over_budget`
  - worst raster: `47.841ms`
  - old-gen GC count: `0`

Policy-check result:

- Exit status: failed
- `insufficient_repeats` because the policy requires `5` repeats and this was
  the required one-repeat probe.
- `unexpected_viewport` because the policy expects `800x600 @ 2.0x`, but this
  run observed `800x600 @ 1.0x`.

## Stop Decision

Do not run the default repeat-5 macOS reference matrix on this current display
state. The full `3 renderers x 4 fixtures x 5 repeats` collection would be
expected to fail the same active viewport guard because the one-repeat probe
already recorded DPR `1.0`.

The benchmark gate remains open until one of these paths is available:

1. a macOS reference target that records the policy viewport
   `800x600 @ 2.0x`;
2. a physical iOS or Android target that passes the one-repeat probe and then
   emits repeat-5 artifacts; or
3. a reviewed synthetic viewport policy that records requested synthetic
   metadata separately from observed host metadata.

This note is evidence for target qualification and stop-rule handling only. It
does not support performance comparisons, frame-budget claims, lower-memory
claims, beta promotion, or stable release claims.
