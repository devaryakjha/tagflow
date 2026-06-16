# 2026-06-11 Authored Insertion Pair Baseline (Repeat 5)

This note records a report-only paired profile run for the newly added
authored-ID insertion benchmark slice. It compares the semantic full-reparse
lane against the semantic document-patch lane for controlled HTML snapshots
that preserve authored `data-tagflow-id` values while inserting new siblings
before existing ones.

This is internal benchmark evidence, not a public performance claim. Raw
profile artifacts remain ignored under:

```text
build/benchmarks/profile-authored-pair/2026-06-11-authored-insertion-pair-repeat5/
```

## Scope

- Run id: `2026-06-11-authored-insertion-pair-repeat5`
- Collection commit: `00b2705c8f3e8fc09de339373943d01376f41c17`
- Device: `macos`
- Selection mode: `pairs`
- Repeats: `5`
- Completion: `10 / 10` passed
- Pair 1: `tagflow_semantic` with `streaming_ai_authored_insertions`
- Pair 2: `tagflow_semantic_patch` with
  `streaming_ai_authored_insertion_patches`
- Status: report-only baseline evidence

## Environment

- Branch context: detached `HEAD` from
  `codex/tagflow-native-runtime-master`
- `tagflow` version: `1.0.0-alpha.1`
- Dart SDK: `3.11.0-81.0.dev`
- Flutter SDK: `3.45.0-0.1.pre (master)`
- Melos: `7.8.2`
- Host OS: `macOS 27.0 (26A5353q)`
- Hardware: `MacBook Pro (Mac16,5)`, Apple `M4 Max`, `48 GB` RAM
- Power state: `AC attached; not charging`
- Flutter device id: `macos`
- Recorded viewport: `800 x 600` logical, `1600 x 1200` physical,
  device-pixel-ratio `2.0`

## Methodology

- Used the paired baseline runner so the run stayed restricted to the authored
  insertion full-reparse and patch cells in that exact order.
- Collected `5` repeats per cell on the same local macOS reference setup.
- Wrote raw manifest, logs, and JSON artifacts only under ignored `build/`
  output.
- Summarized the run with `summarize_profile_baselines.dart`.
- Validated repeat completeness and viewport metadata with the direct
  `check_profile_baseline.dart` CLI using the report-only policy. No timing
  thresholds were added.

## Commands

Collection:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_PAIR=tagflow_semantic:streaming_ai_authored_insertions,tagflow_semantic_patch:streaming_ai_authored_insertion_patches \
TAGFLOW_PROFILE_REPEAT=5 \
TAGFLOW_PROFILE_RUN_ID=2026-06-11-authored-insertion-pair-repeat5 \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-authored-pair \
TAGFLOW_PROFILE_CONTINUE_ON_FAILURE=true \
dart run melos run benchmark:profile:baselines
```

Summary:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=2026-06-11-authored-insertion-pair-repeat5 \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-authored-pair \
dart run melos run benchmark:profile:summarize
```

Completeness and viewport check:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
dart run packages/tagflow_benchmarks/bin/check_profile_baseline.dart \
  --run-id=2026-06-11-authored-insertion-pair-repeat5 \
  --output-dir=build/benchmarks/profile-authored-pair \
  --policy=docs/benchmarks/policies/profile-reference-runner-policy.json
```

Direct check output:

```json
{
  "summaryPath": "/Users/arya/.codex/worktrees/39a4/tagflow/build/benchmarks/profile-authored-pair/2026-06-11-authored-insertion-pair-repeat5/profile-baseline-summary.json",
  "minRepeats": 5,
  "policy": {
    "id": "tagflow-alpha-macos-reference-report-only",
    "minRepeats": 5,
    "expectedViewport": {
      "logicalWidth": 800.0,
      "logicalHeight": 600.0,
      "devicePixelRatio": 2.0
    },
    "thresholdMode": "report_only"
  },
  "passed": true,
  "issues": []
}
```

## Run Status

- Manifest run status counts: `passed=10`
- Summary run status counts: `passed=10`
- Failed runs recorded in summary: none
- Observed repeats per cell: `5`
- Viewport metadata observed across successful repeats:
  `800x600` logical, `1600x1200` physical, DPR `2.0`

## Summary Results

These values come from `profile-baseline-summary.json`. They reflect the
current summary pipeline, which aggregates the final benchmark cell metrics and
not a full wall-clock duration ranking for the entire run.

| Renderer | Fixture | Repeats | P90 build mean ms | P90 raster mean ms | Worst raster max ms | Missed build total | Missed raster total | New-gen GC total | Old-gen GC total |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| `tagflow_semantic` | `streaming_ai_authored_insertions` | 5 | 0.236 | 0.789 | 8.681 | 0 | 0 | 10 | 0 |
| `tagflow_semantic_patch` | `streaming_ai_authored_insertion_patches` | 5 | 0.196 | 0.664 | 5.667 | 0 | 0 | 8 | 0 |

## Caveats

- This run is report-only. It does not support a public claim that the patch
  lane is faster or slower than the full-reparse lane.
- The patch lane had a real repeat-level anomaly outside the summary table:
  `repeat-02.json` recorded a chunk-1 update latency of `249,327,401` micro-
  seconds, while the other patch repeats stayed near `110,118` to `116,790`
  microseconds per update step.
- That same patch repeat recorded one update-phase missed raster-budget frame
  with `21.132 ms` worst update raster time. The final scroll-phase summary for
  the cell still showed `0` missed raster-budget frames, so reviewers should
  not treat the summary alone as the full story for update-path stability.
- The full-reparse lane did not show a comparable update-latency spike in this
  run. Its per-update latencies stayed in the narrow `108,829` to `117,087`
  microsecond range.
- The packaged Melos wrapper for `benchmark:profile:check` did not work with
  this custom output directory because it resolved the summary path under
  `packages/tagflow_benchmarks/build/...` instead of the workspace-root
  `build/...` path. The direct CLI check above succeeded and is the reliable
  validation result for this run.

## Review

This run proves the authored insertion pair can collect a complete repeat-5
baseline with the intended ordered cell list and expected viewport metadata on
local macOS. It also provides a first paired evidence set for controlled HTML
snapshots that preserve authored IDs across sibling insertions.

The narrow, useful observation is not a ranking claim. It is that the authored
insertion full-reparse and patch lanes are both measurable under the paired
runner, and the patch lane still needs follow-up because one repeat showed a
large first-update latency spike that the current summary/check path does not
surface as a failed run.

## Suitability

Suitable for:

- internal dynamic-content evidence
- authored-ID insertion fixture handoff
- reference-runner methodology review
- identifying patch-lane update-path follow-up work

Not suitable for:

- public benchmark claims
- stable `1.0.0` performance claims
- timing thresholds or regression gates
- claims that patch streaming is categorically faster than full reparsing

## Follow-Up

1. Inspect why patch repeat 2 spent about `249.3 s` on the first update step
   even though the run still completed and the final scroll summary stayed
   normal.
2. Decide whether the summary/check tooling should surface update-phase
   anomalies separately from final scroll metrics before the baseline format is
   treated as sufficient for dynamic-content claims.
3. Keep the authored insertion pair report-only until the patch-lane update
   anomaly is understood on the intended reference environment.
