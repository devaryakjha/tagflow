# 2026-06-11 Authored Insertion Ordered-Patch Baseline (Repeat 5)

This note records a bounded, report-only rerun for the authored-ID insertion
pair after the benchmark fidelity fix that switched the patch lane to ordered
`insertBefore(...)` updates and normalized descendant fallback IDs within the
stream snapshots. It is evidence collection only. It does not set thresholds
or support any faster/slower claim between the full-reparse and patch lanes.

Raw artifacts were written only under ignored `build/` output:

```text
build/benchmarks/profile-authored-ordered-repeat5/2026-06-11-authored-insertion-ordered-repeat5/
```

## Scope

- Run id: `2026-06-11-authored-insertion-ordered-repeat5`
- Collection commit: `42feeffba755b36eaa88eecda6a188694d148b5d`
- Branch context: detached `HEAD` from `codex/tagflow-native-runtime-master`
- Device: `macos`
- Selection mode: `pairs`
- Ordered cells:
  1. `tagflow_semantic:streaming_ai_authored_insertions`
  2. `tagflow_semantic_patch:streaming_ai_authored_insertion_patches`
- Repeats: `5`
- Manifest status counts: `passed=10`
- Summary status counts: `passed=10`

## Environment

- `tagflow` version: `1.0.0-alpha.1`
- Dart SDK: `3.11.0-81.0.dev`
- Flutter SDK: `3.45.0-0.1.pre (master)`
- Host OS: `macOS 27.0 (26A5353q)`
- Recorded viewport: `800 x 600` logical, `1600 x 1200` physical,
  device-pixel-ratio `2.0`

## Methodology

- Used the paired baseline runner with the authored insertion pair only, in the
  required order.
- Kept the run bounded at `TAGFLOW_PROFILE_REPEAT=5`.
- Wrote manifest, logs, repeat JSON, summary JSON, and check output only under
  ignored `build/`.
- Generated the baseline summary from the collected manifest.
- Ran the checker with the existing report-only viewport policy and an explicit
  `--min-repeats=5` override, matching the policy file's current repeat
  expectation.

## Commands

Collection:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_PAIR=tagflow_semantic:streaming_ai_authored_insertions,tagflow_semantic_patch:streaming_ai_authored_insertion_patches \
TAGFLOW_PROFILE_REPEAT=5 \
TAGFLOW_PROFILE_RUN_ID=2026-06-11-authored-insertion-ordered-repeat5 \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-authored-ordered-repeat5 \
TAGFLOW_PROFILE_CONTINUE_ON_FAILURE=true \
dart run melos run benchmark:profile:baselines
```

Summary:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
dart run packages/tagflow_benchmarks/bin/summarize_profile_baselines.dart \
  --run-id=2026-06-11-authored-insertion-ordered-repeat5 \
  --output-dir=build/benchmarks/profile-authored-ordered-repeat5
```

Check:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
dart run packages/tagflow_benchmarks/bin/check_profile_baseline.dart \
  --run-id=2026-06-11-authored-insertion-ordered-repeat5 \
  --output-dir=build/benchmarks/profile-authored-ordered-repeat5 \
  --policy=docs/benchmarks/policies/profile-reference-runner-policy.json \
  --min-repeats=5
```

## Summary Results

`profile-baseline-summary.json` includes `updateSummary.phaseMaxima` for both
dynamic cells.

| Renderer | Fixture | Repeats | maxElapsedMicros | applyPatch max us | pumpWidget max us | settle max us | Update missed build | Update missed raster |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| `tagflow_semantic` | `streaming_ai_authored_insertions` | 5 | 128,097 | n/a | 24,749 | 111,186 | 0 | 1 |
| `tagflow_semantic_patch` | `streaming_ai_authored_insertion_patches` | 5 | 120,292 | 29 | 12,812 | 111,048 | 0 | 1 |

Phase maxima details:

- `tagflow_semantic`
  - `pumpWidgetMicros`: repeat 1, chunk 2, fraction `0.5`, input length `208`
  - `settleMicros`: repeat 3, chunk 1, fraction `0.25`, input length `132`
- `tagflow_semantic_patch`
  - `applyPatchMicros`: repeat 3, chunk 2, fraction `0.5`, input length `208`
  - `pumpWidgetMicros`: repeat 3, chunk 1, fraction `0.25`, input length `132`
  - `settleMicros`: repeat 1, chunk 1, fraction `0.25`, input length `132`

## Caveats

- This remains a bounded local runner result and report-only evidence. It is
  not a regression gate.
- This note is not a threshold update.
- It does not support ranking claims or any faster/slower conclusion between
  the full-reparse and patch lanes.
- `phaseMaxima` is per phase, not a promise that all maxima came from the same
  update step. Reviewers should read it as attribution evidence, not as a
  single-step phase decomposition.
- The direct check passed with `--min-repeats=5`, which matches the current
  policy file, but it still emitted report-only outlier findings for one repeat
  in each lane.

## Observations

- The earlier severe patch-lane stall did not reproduce in this rerun.
- The patch lane completed all five repeats without a multi-minute first-update
  anomaly; its worst observed update latency was `120,292` microseconds.
- Both lanes still produced one report-only update outlier repeat with a single
  missed raster-budget frame in update-path metrics:
  - `tagflow_semantic`: repeat 1, max update latency `128,097` microseconds,
    update worst raster `19.725` ms
  - `tagflow_semantic_patch`: repeat 4, max update latency `120,292`
    microseconds, update worst raster `16.939` ms
- In both cells, the dominant measured phase was `settleMicros`; patch
  application itself remained negligible at `29` microseconds maximum.

## Check Result

Direct check output:

```json
{
  "summaryPath": "/Users/arya/.codex/worktrees/8d3f/tagflow/build/benchmarks/profile-authored-ordered-repeat5/2026-06-11-authored-insertion-ordered-repeat5/profile-baseline-summary.json",
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
  "issues": [],
  "reportOnlyFindings": [
    {
      "code": "outlier_repeat_present",
      "renderer": "tagflow_semantic",
      "fixture": "streaming_ai_authored_insertions",
      "repeat": 1,
      "reasons": [
        "update_missed_raster_budget",
        "update_worst_raster_over_budget"
      ]
    },
    {
      "code": "outlier_repeat_present",
      "renderer": "tagflow_semantic_patch",
      "fixture": "streaming_ai_authored_insertion_patches",
      "repeat": 4,
      "reasons": [
        "update_missed_raster_budget",
        "update_worst_raster_over_budget"
      ]
    }
  ]
}
```

## Review

This rerun confirms the authored insertion pair completed under the ordered
patch benchmark path after the `insertBefore(...)` fidelity fix and descendant
fallback-ID normalization. The useful conclusion is narrow: the patch lane now
collects complete repeat-5 evidence with the expected viewport metadata, and
the earlier severe patch-lane stall did not reproduce here.

That is enough for report-only evidence collection. It is not enough for a
performance claim, and it does not justify a threshold update. The direct
check passed at the reference policy's repeat count, but the report-only
outlier findings mean update-path stability still deserves coordinator review
before anyone treats this as stronger than internal evidence.

## Outlier Triage

A follow-up read-only triage inspected the raw repeat JSON and logs for the two
report-only findings:

- `tagflow_semantic` repeat 1
- `tagflow_semantic_patch` repeat 4

The outliers do not implicate patch application cost. In the patch lane,
`applyPatchMicros` stayed negligible across all repeats; the flagged repeat's
chunk-1 patch application cost was `13` microseconds. The outliers also do not
show a GC signature. The full-reparse lane reported `new_gen_gc_count=2` and
`old_gen_gc_count=0` across all repeats, and the patch lane reported
`new_gen_gc_count=0` and `old_gen_gc_count=0` across all repeats.

The evidence instead points to update-path frame variance near the first
measured updates:

- `tagflow_semantic` repeat 1 had an unusual chunk-2 update:
  `pumpWidgetMicros=24,749`, `settleMicros=103,347`, and
  `elapsedMicros=128,097`.
- Nearby full-reparse repeats for the same chunk had much lower pump times,
  such as repeat 2 at `8,840` microseconds and repeat 3 at `8,860`
  microseconds.
- `tagflow_semantic_patch` repeat 4's flagged chunk-1 update was
  `applyPatchMicros=13`, `pumpWidgetMicros=9,831`,
  `settleMicros=110,447`, and `elapsedMicros=120,292`.
- Nearby patch repeats had similar settle times without necessarily crossing
  the raster-budget boundary.

## Attribution Follow-up

Subsequent harness instrumentation now records per-update
`frameTimingAttribution` when Flutter emits `FrameTiming` callbacks during the
dynamic update path. That lets later summaries/report-only findings point to a
worst observed update frame by repeat, chunk, fraction, and a conservative
phase window.

The phase window is intentionally narrow:

- `pumpWidget`
- `settle`
- `unknown`

If a frame timing callback arrives outside the active `pumpWidget` or `settle`
window, the harness records that frame as `unknown` instead of guessing. This
improves attribution for over-budget update frames, but it still does not prove
single-cause ownership for every slow frame.

The warning lines in the logs were not unique to the flagged repeats. The
semantic timestamp-clamp warning also appeared in a non-outlier repeat, and the
patch foregrounding warning appeared in neighboring non-outlier repeats.

The practical gap is attribution detail. Current artifacts expose per-update
latency phases and an aggregate update-frame array for each repeat, but they do
not map the over-budget frame back to a specific update chunk or whether it
happened during `pumpWidget` or `settle`.

Recommended next benchmark action:

- do not broad-rerun this pair yet
- add targeted update-frame attribution first
- record update-frame timing per chunk/fraction
- capture frame index to chunk mapping and phase ownership where possible
- rerun only this authored-insertion pair after that instrumentation lands
