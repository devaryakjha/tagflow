# 2026-06-11 Authored Insertion Ordered-Patch Baseline (Repeat 5, Attribution)

This note records a bounded, report-only rerun for the authored-ID insertion
pair after the update-frame attribution schema landed in
`5d8b8ed feat(benchmarks): attribute update frames to chunks`. It is evidence
collection only. It does not set thresholds or support any faster/slower claim
between the full-reparse and patch lanes.

Raw artifacts were written only under ignored `build/` output:

```text
build/benchmarks/profile-authored-ordered-repeat5-attribution/2026-06-11-authored-insertion-ordered-repeat5-attribution/
```

## Scope

- Run id: `2026-06-11-authored-insertion-ordered-repeat5-attribution`
- Collection commit: `5d8b8ed0ab7fc0ed2ce56aafc98c6a77960d9f0b`
- Branch context: `codex/tagflow-native-runtime-master`
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
  `--min-repeats=5` override.
- This run uses the update-frame attribution schema added after the earlier
  ordered repeat-5 triage note, so the summary now captures both
  `updateSummary.phaseMaxima` and `worstAttributedFrame` when present.

## Commands

Collection:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_PAIR=tagflow_semantic:streaming_ai_authored_insertions,tagflow_semantic_patch:streaming_ai_authored_insertion_patches \
TAGFLOW_PROFILE_REPEAT=5 \
TAGFLOW_PROFILE_RUN_ID=2026-06-11-authored-insertion-ordered-repeat5-attribution \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-authored-ordered-repeat5-attribution \
TAGFLOW_PROFILE_CONTINUE_ON_FAILURE=true \
dart run melos run benchmark:profile:baselines
```

Summary:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
dart run packages/tagflow_benchmarks/bin/summarize_profile_baselines.dart \
  --run-id=2026-06-11-authored-insertion-ordered-repeat5-attribution \
  --output-dir=build/benchmarks/profile-authored-ordered-repeat5-attribution
```

Check:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
dart run packages/tagflow_benchmarks/bin/check_profile_baseline.dart \
  --run-id=2026-06-11-authored-insertion-ordered-repeat5-attribution \
  --output-dir=build/benchmarks/profile-authored-ordered-repeat5-attribution \
  --policy=docs/benchmarks/policies/profile-reference-runner-policy.json \
  --min-repeats=5
```

## Summary Results

`profile-baseline-summary.json` includes `updateSummary.phaseMaxima` and
`worstAttributedFrame` for both dynamic cells.

| Renderer | Fixture | Repeats | maxElapsedMicros | applyPatch max us | pumpWidget max us | settle max us | Worst attributed frame |
| --- | --- | ---: | ---: | ---: | ---: | ---: | --- |
| `tagflow_semantic` | `streaming_ai_authored_insertions` | 5 | 133,503 | n/a | 18,970 | 119,959 | repeat 3, chunk 2, fraction `0.5`, phase `settle`, build `4.43` ms, raster `14.461` ms |
| `tagflow_semantic_patch` | `streaming_ai_authored_insertion_patches` | 5 | 117,210 | 20 | 11,932 | 108,029 | repeat 5, chunk 2, fraction `0.5`, phase `settle`, build `3.628` ms, raster `12.779` ms |

Phase maxima details:

- `tagflow_semantic`
  - `pumpWidgetMicros`: repeat 4, chunk 3, fraction `0.75`, input length `251`
  - `settleMicros`: repeat 5, chunk 4, fraction `1.0`, input length `290`
- `tagflow_semantic_patch`
  - `applyPatchMicros`: repeat 1, chunk 3, fraction `0.75`, input length `251`
  - `pumpWidgetMicros`: repeat 5, chunk 1, fraction `0.25`, input length `132`
  - `settleMicros`: repeat 1, chunk 2, fraction `0.5`, input length `208`

## Check Result

Direct check output:

```json
{
  "summaryPath": "/Users/arya/.codex/worktrees/c501/tagflow/build/benchmarks/profile-authored-ordered-repeat5-attribution/2026-06-11-authored-insertion-ordered-repeat5-attribution/profile-baseline-summary.json",
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
  "reportOnlyFindings": []
}
```

The explicit `--min-repeats=5` check passed, and every successful cell matched
the expected `800x600 @ 2.0x` viewport metadata.

## Caveats

- This remains a bounded local runner result and report-only evidence. It is
  not a regression gate.
- This note is not a threshold update.
- It does not support ranking claims or any faster/slower conclusion between
  the full-reparse and patch lanes.
- The update-frame attribution fields are useful for ownership hints, but they
  do not convert this run into a public performance claim.

## Observations

- Unlike the earlier ordered repeat-5 triage run, this attribution-enabled rerun
  produced no report-only outlier repeats in either lane.
- Attribution still identified the worst observed update-owned frame in both
  cells, and in both cases the owning phase was `settle`, not `unknown`.
- The worst attributed frame in the full-reparse lane was repeat 3, chunk 2,
  fraction `0.5`; the patch lane's worst attributed frame was repeat 5,
  chunk 2, fraction `0.5`.
- Patch application itself remained negligible in this run, with a measured
  `applyPatchMicros` maximum of `20` microseconds.

## Review

This rerun is useful as narrow internal evidence that the authored insertion
pair now records complete repeat-5 data with the newer update-frame attribution
schema. The strongest factual conclusion is limited: both lanes completed
cleanly, the report-only check passed at `--min-repeats=5`, and the added
attribution fields were populated with concrete chunk, fraction, and phase
ownership for the worst observed update-owned frames.

That is enough for report-only evidence collection. It is not enough for a
performance claim, and it does not justify a threshold update.
