# 2026-06-11 Authored Insertion Ordered-Patch Baseline (Repeat 3)

This note records a bounded, report-only rerun for the authored-ID insertion
pair after the benchmark fidelity fix that switched the patch lane to ordered
`insertBefore(...)` updates and normalized descendant fallback IDs within the
stream snapshots. It is evidence collection only. It does not set thresholds
or support any faster/slower claim between the full-reparse and patch lanes.

Raw artifacts were written only under ignored `build/` output:

```text
build/benchmarks/profile-authored-ordered/2026-06-11-authored-insertion-ordered-repeat3/
```

## Scope

- Run id: `2026-06-11-authored-insertion-ordered-repeat3`
- Collection commit: `d4135c7590c0ecc199463b715ad402ff095a72c9`
- Branch context: detached `HEAD` from `codex/tagflow-native-runtime-master`
- Device: `macos`
- Selection mode: `pairs`
- Ordered cells:
  1. `tagflow_semantic:streaming_ai_authored_insertions`
  2. `tagflow_semantic_patch:streaming_ai_authored_insertion_patches`
- Repeats: `3`
- Manifest status counts: `passed=6`
- Summary status counts: `passed=6`

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
- Kept the run bounded at `TAGFLOW_PROFILE_REPEAT=3`.
- Wrote manifest, logs, repeat JSON, summary JSON, and check output only under
  ignored `build/`.
- Generated the baseline summary from the collected manifest.
- Ran the checker with the existing report-only viewport policy and an explicit
  `--min-repeats=3` override so the bounded rerun could be validated for
  completeness without pretending it met the reference policy's repeat-5 bar.

## Commands

Collection:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_PAIR=tagflow_semantic:streaming_ai_authored_insertions,tagflow_semantic_patch:streaming_ai_authored_insertion_patches \
TAGFLOW_PROFILE_REPEAT=3 \
TAGFLOW_PROFILE_RUN_ID=2026-06-11-authored-insertion-ordered-repeat3 \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-authored-ordered \
TAGFLOW_PROFILE_CONTINUE_ON_FAILURE=true \
dart run melos run benchmark:profile:baselines
```

Summary:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
dart run packages/tagflow_benchmarks/bin/summarize_profile_baselines.dart \
  --run-id=2026-06-11-authored-insertion-ordered-repeat3 \
  --output-dir=build/benchmarks/profile-authored-ordered
```

Check:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
dart run packages/tagflow_benchmarks/bin/check_profile_baseline.dart \
  --run-id=2026-06-11-authored-insertion-ordered-repeat3 \
  --output-dir=build/benchmarks/profile-authored-ordered \
  --policy=docs/benchmarks/policies/profile-reference-runner-policy.json \
  --min-repeats=3
```

## Summary Results

`profile-baseline-summary.json` includes `updateSummary.phaseMaxima` for both
dynamic cells.

| Renderer | Fixture | Repeats | maxElapsedMicros | applyPatch max us | pumpWidget max us | settle max us | Update missed build | Update missed raster |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| `tagflow_semantic` | `streaming_ai_authored_insertions` | 3 | 117,151 | n/a | 11,044 | 109,267 | 0 | 0 |
| `tagflow_semantic_patch` | `streaming_ai_authored_insertion_patches` | 3 | 121,618 | 13 | 17,349 | 108,908 | 0 | 0 |

Phase maxima details:

- `tagflow_semantic`
  - `pumpWidgetMicros`: repeat 1, chunk 1, fraction `0.25`, input length `132`
  - `settleMicros`: repeat 2, chunk 2, fraction `0.5`, input length `208`
- `tagflow_semantic_patch`
  - `applyPatchMicros`: repeat 2, chunk 4, fraction `1.0`, input length `290`
  - `pumpWidgetMicros`: repeat 2, chunk 2, fraction `0.5`, input length `208`
  - `settleMicros`: repeat 2, chunk 1, fraction `0.25`, input length `132`

## Caveats

- This remains repeat-3 and report-only. It is not a regression gate.
- This note is not a threshold update.
- It does not support ranking claims or any faster/slower conclusion between
  the full-reparse and patch lanes.
- The checker passed for this bounded rerun with `--min-repeats=3`, but the
  referenced policy file still declares a `minRepeats` expectation of `5`.
- `phaseMaxima` is per phase, not a promise that all maxima came from the same
  update step. Reviewers should read it as attribution evidence, not as a
  single-step phase decomposition.

## Observations

- The earlier severe patch-lane stall did not reproduce in this rerun.
- The patch lane's first repeat looked idle long enough to merit inspection,
  but it completed successfully in `107.380` seconds with a passing artifact
  and no missed-frame counts. That is evidence of a slow repeat, not a stuck
  run.
- The largest observed update latencies were `117,151` microseconds for the
  full-reparse lane and `121,618` microseconds for the patch lane.
- In both cells, the dominant measured phase was `settleMicros`; patch
  application itself remained negligible at `13` microseconds maximum.
- No outlier repeats were surfaced by the summary for either cell.

## Check Result

Direct check output:

```json
{
  "summaryPath": "/Users/arya/.codex/worktrees/2fb1/tagflow/build/benchmarks/profile-authored-ordered/2026-06-11-authored-insertion-ordered-repeat3/profile-baseline-summary.json",
  "minRepeats": 3,
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

## Review

This rerun confirms the authored insertion pair completed under the ordered
patch benchmark path after the `insertBefore(...)` fidelity fix and descendant
fallback-ID normalization. The useful conclusion is narrow: the patch lane now
collects complete repeat-3 evidence with trusted `phaseMaxima` attribution, and
the earlier severe patch-lane stall did not reproduce here.

That is enough for report-only evidence collection. It is not enough for a
performance claim, and it does not replace the need for a repeat-5 rerun if
the coordinator still needs stronger confidence against the reference policy.
