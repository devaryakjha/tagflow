# 2026-06-12 Native JSON Profile Baseline (Repeat 5)

This note records the native JSON profile lane at repeat 5 on the local macOS
runner after the launch-attribution and cold/warm summary fields were in
place. It is report-only evidence for local stabilization. It does not set a
threshold, support a public performance claim, or justify ranking language.

Raw artifacts were written only under ignored `build/` output:

```text
build/benchmarks/profile-native-json/2026-06-12-native-json-repeat5-local-baseline/
```

## Scope

- Run id: `2026-06-12-native-json-repeat5-local-baseline`
- Collection commit: `94af01feeb48b345151e6e6543a4873e8da39b86`
- Branch context: `codex/tagflow-native-runtime-master`
- Device: `macos`
- Selection mode: `pairs`
- Ordered cells:
  1. `tagflow_native_json:native_ai_answer`
  2. `tagflow_native_json:native_table_dense`
  3. `tagflow_native_json:native_large_article`
- Repeats: `5`
- Manifest status counts: `passed=15`
- Summary status counts: `passed=15`

## Environment

- `tagflow` version: `1.0.0-alpha.3`
- `tagflow_table` version: `1.0.0-alpha.1`
- Dart SDK: `3.11.0-81.0.dev`
- Flutter SDK: `3.45.0-0.1.pre (master)`
- Flutter revision: `6af38a904a`
- Engine revision: `3a0828c8d5942264423ab564b6bdb65ea243b606`
- DevTools: `2.51.0`
- Host OS: `macOS 27.0 (26A5353q)`
- Hardware: `MacBook Pro (Mac16,5)`, `Apple M4 Max`, `16` CPU cores
  (`12` performance, `4` efficiency), `40` GPU cores, `48 GB` RAM
- Power state: AC power, battery `80%`, not charging
- Display attached: built-in `3456 x 2234` Retina display
- Recorded viewport: `800 x 600` logical, `1600 x 1200` physical,
  device-pixel-ratio `2.0`

## Methodology

- Ran only the native JSON cells listed above.
- Kept the run bounded at `TAGFLOW_PROFILE_REPEAT=5`.
- Wrote manifest, repeat JSON, repeat logs, summary JSON, and check output only
  under ignored `build/`.
- Generated the reviewed summary from the collected manifest.
- Applied the committed report-only checker policy only after the summary
  confirmed the expected `800x600 @ 2.0x` viewport.
- Kept the result report-only; no threshold or comparison policy was added.

## Commands

Collection:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_PAIR=tagflow_native_json:native_ai_answer,tagflow_native_json:native_table_dense,tagflow_native_json:native_large_article \
TAGFLOW_PROFILE_REPEAT=5 \
TAGFLOW_PROFILE_RUN_ID=2026-06-12-native-json-repeat5-local-baseline \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-native-json \
dart run melos run benchmark:profile:baselines
```

Summary:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=2026-06-12-native-json-repeat5-local-baseline \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-native-json \
dart run melos run benchmark:profile:summarize
```

Check:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=2026-06-12-native-json-repeat5-local-baseline \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-native-json \
TAGFLOW_PROFILE_MIN_REPEATS=5 \
TAGFLOW_PROFILE_CHECK_POLICY=docs/benchmarks/policies/profile-reference-runner-policy.json \
dart run melos run benchmark:profile:check
```

## Summary Results

Every cell recorded `coldInitialRender`, `warmRebuild`, and `warmScroll`.
There were no failed runs, no missing phase summaries, no old-gen GC events,
and no outlier repeats in the summary.

Phase means below are the summary means across the five repeats for the
requested per-phase p90 values.

| Fixture | Repeats | Cold p90 build mean ms | Cold p90 raster mean ms | Cold raster misses | Warm rebuild p90 build mean ms | Warm rebuild p90 raster mean ms | Warm scroll p90 build mean ms | Warm scroll p90 raster mean ms |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| `native_ai_answer` | 5 | 3.514 | 11.668 | 1 | 0.719 | 6.873 | 0.212 | 0.836 |
| `native_table_dense` | 5 | 4.806 | 11.689 | 1 | 1.034 | 5.808 | 0.259 | 0.990 |
| `native_large_article` | 5 | 7.442 | 11.495 | 1 | 1.532 | 6.354 | 0.376 | 0.994 |

Collection-integrity details:

| Fixture | Worst raster max ms | Missed build total | Missed raster total | New-gen GC mean | Old-gen GC mean | Outlier repeats |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| `native_ai_answer` | 10.452 | 0 | 0 | 2.0 | 0.0 | 0 |
| `native_table_dense` | 14.031 | 0 | 0 | 2.0 | 0.0 | 0 |
| `native_large_article` | 15.216 | 0 | 0 | 2.0 | 0.0 | 0 |

Notes:

- The single raster-budget miss per fixture occurred in `coldInitialRender`,
  not in `warmRebuild` or `warmScroll`.
- The heaviest cold build phase in this run was `native_large_article`.
- The heaviest warm scroll raster spike in this run was
  `native_large_article` at `15.216 ms`, still with zero warm-phase budget
  misses in the summary.

## Launch Attribution

All three cells reported `launchAttribution.status: available` with
provenance `macos_app_delegate_uptime_markers_v1` and scope
`local_runner_only`.

| Fixture | Did finish launching mean ms | Flutter view ready mean ms | Integration test request mean ms |
| --- | ---: | ---: | ---: |
| `native_ai_answer` | 249.791 | 197.936 | 1246.028 |
| `native_table_dense` | 267.118 | 211.694 | 1234.772 |
| `native_large_article` | 259.898 | 208.047 | 1207.355 |

These values describe explicit macOS local-runner markers only. They are not
generic app cold-start metrics.

## Check Result

Direct check output:

```json
{
  "summaryPath": "/Users/arya/.codex/worktrees/d7ac/tagflow/build/benchmarks/profile-native-json/2026-06-12-native-json-repeat5-local-baseline/profile-baseline-summary.json",
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

## Caveats

- This remains local macOS runner evidence and report-only benchmark output.
- The lane renders trusted native block JSON as `TagflowDocument`; it is not a
  direct HTML parser/render comparison and should not be presented as one.
- Launch attribution is explicitly scoped to macOS local-runner markers and is
  not a generic process or app cold-start metric.
- The environment still uses Flutter `master` prerelease bits and prerelease
  macOS, so this is not claim-grade reference-target evidence.
- GC counts in the summary are useful review inputs only; they are not enough
  for memory or allocation claims without the separate memory-evidence
  playbook.

## Review

This run promotes the native JSON profile lane from one-repeat smoke to a
reviewed repeat-5 local baseline. The strongest supported conclusion is
narrow: the native JSON lane now has complete repeat-based macOS evidence with
all three static phases present, policy-compliant viewport metadata, available
local-runner launch markers, and clean collection integrity at the summary
level.

The note should still be read conservatively. Cold first-render raster work
remains the only place that recorded budget misses in this run, and the lane
is still native-only evidence on a prerelease desktop stack. That makes it
useful for local stabilization and follow-up profiling, not for public
performance claims or timing thresholds.
