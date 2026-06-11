# Tagflow Reference Runner Qualification

## Status

- Date: 2026-06-12
- Scope: public performance-claim qualification after `tagflow`
  `1.0.0-alpha.3`
- Current posture: report-only internal evidence; no public speed, ranking, or
  regression-threshold claim is qualified

## Purpose

Tagflow now has enough benchmark plumbing to collect repeatable local evidence:
fixture checks, parser/render microbenchmarks, profile-mode matrix collection,
competitor adapters, native transport timings, native JSON profile smoke, and
dynamic update attribution. That is still not enough for public performance
copy. This document defines the exact gates that must be true before any
external claim can cite benchmark numbers.

This is intentionally stricter than the alpha release gates. Alpha gates can
use collection completeness. Public claims require qualified reference targets,
fixture review, memory/allocation review, and an explicit comparison policy.

## Current Evidence Classification

| Lane | Current state | Classification | Claim limit |
| --- | --- | --- | --- |
| Fixture validity | `benchmark:fixtures` validates shared benchmark fixtures. | Smoke gate. | Proves fixture loading only. |
| Parser microbench | `benchmark:micro` emits fixture-level JSON through a Flutter-capable harness. | Smoke gate. | Not claim-grade parser speed evidence. |
| Widget render microbench | `benchmark:render` emits conversion/build samples, stats, input bytes, and node counts. | Smoke gate. | Internal trend data only. |
| Default macOS profile matrix | `2026-06-11-macos-reference-profile-baseline-repeat5.md` records `60 / 60` cells across three renderers and four HTML fixtures. | Local stabilization evidence. | Not claim-grade because the environment is not a promoted stable reference target. |
| Profile checker policy | `profile-reference-runner-policy.json` requires five repeats and `800x600 @ 2.0x` viewport metadata while keeping thresholds `report_only`. | Collection-quality gate. | Cannot enforce timing thresholds. |
| Competitor adapters | `flutter_html` and `flutter_widget_from_html` lanes exist in the profile matrix. | Fairness input. | Needs explicit feature-support and configuration review before comparisons. |
| Native transport microbench | `benchmark:native-transport` and `2026-06-11-native-transport-smoke.md` measure JSON decode/adapt/patch phases. | Report-only smoke. | Measures transport overhead, not rendered frame performance. |
| Native JSON profile lane | `tagflow_native_json:native_ai_answer` renders native block JSON and emits cold/warm profile summaries. | Report-only smoke. | Not yet repeat-based or fixture-comparable to HTML. |
| Dynamic patch/update lanes | Semantic streaming and authored insertion pair baselines record update attribution. | Report-only diagnostic evidence. | GC/raster outliers must be explained before dynamic-content claims. |
| Kite real-app probe | Kite evidence proves real app reachability and hosted alpha3 compatibility; debug profile probe is diagnostic. | Integration evidence. | Not a supported profile benchmark or public performance baseline. |

## Public Claim Qualification Gates

Before Tagflow can publish a benchmark claim, every item below must have current
reviewed evidence:

1. Stable reference target
   - Flutter is on a stable channel with exact Flutter and Dart revisions
     recorded.
   - Host OS is a stable release, not a prerelease seed.
   - Hardware model, CPU/GPU, memory, power source, thermal state, and display
     placement are recorded.
   - Desktop runs pin logical viewport and DPR, currently `800x600 @ 2.0x`
     unless a reviewed policy changes it.
2. Device matrix
   - At least one physical iOS and one physical Android target are qualified,
     or the claim explicitly says it is desktop-only.
   - New targets first run with `TAGFLOW_PROFILE_CONTINUE_ON_FAILURE=true` so
     install, launch, scroll, and artifact failures are captured as evidence.
3. Repeat policy
   - Every claimed cell has at least five successful repeats.
   - `profile-baseline-summary.json` has no failed runs.
   - `benchmark:profile:check` passes with
     `docs/benchmarks/policies/profile-reference-runner-policy.json`.
4. Fixture policy
   - Claimed fixture set records input bytes, node count, table dimensions
     where relevant, update chunk count where relevant, and feature coverage.
   - Any excluded unsupported feature is documented before competitor
     comparison.
5. Cold/warm phase policy
   - Claims distinguish app launch, first render, warm rebuild, warm scroll,
     and dynamic update phases.
   - Current static profile summaries can report `coldInitialRender`,
     `warmRebuild`, and `warmScroll` as report-only inputs, but app launch
     still needs explicit attribution before that phase can be claimed.
6. Memory/allocation policy
   - GC counts in profile summaries are reviewed.
   - DevTools Memory captures or equivalent allocation evidence exist for
     `large_article`, `table_stress`, and the dynamic patch lane.
   - Old-gen GC or allocation outliers are explained before dynamic update or
     large-document claims.
7. Competitor fairness policy
   - Renderer versions and configuration are recorded.
   - Enabled feature sets are stated, including table support and unsupported
     HTML behavior.
   - Claims compare only fixture behavior that all named renderers actually
     support.
8. Threshold and comparison policy
   - A separate committed policy defines the exact metric, threshold, and
     comparison rule.
   - The current `report_only` policy must not be reinterpreted as a timing
     gate.

## Local Repeat-5 Reference Pass

Use this when refreshing local stabilization evidence for the default HTML
profile matrix:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_DEVICE=macos \
TAGFLOW_PROFILE_REPEAT=5 \
TAGFLOW_PROFILE_RUN_ID=<run-id> \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-reference \
dart run melos run benchmark:profile:baselines
```

Summarize:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=<run-id> \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-reference \
dart run melos run benchmark:profile:summarize
```

Check collection completeness and viewport policy:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=<run-id> \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-reference \
TAGFLOW_PROFILE_CHECK_POLICY=docs/benchmarks/policies/profile-reference-runner-policy.json \
dart run melos run benchmark:profile:check
```

The default profile matrix currently covers:

- renderers: `tagflow`, `flutter_html`, `flutter_widget_from_html`
- fixtures: `ai_answer_rich`, `table_dense`, `large_article`, `table_stress`
- expected policy repeat count: `5`
- expected policy viewport: `800x600 @ 2.0x`

Passing this sequence qualifies collection completeness for the configured
local target only. It still does not qualify public performance copy.

## Native Runtime Repeat Passes

Native JSON profile lane:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_PAIR=tagflow_native_json:native_ai_answer \
TAGFLOW_PROFILE_REPEAT=5 \
TAGFLOW_PROFILE_RUN_ID=<native-json-run-id> \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-native-json \
dart run melos run benchmark:profile:baselines
```

Dynamic authored-insertion pair:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_PAIR=tagflow_semantic:streaming_ai_authored_insertions,tagflow_semantic_patch:streaming_ai_authored_insertion_patches \
TAGFLOW_PROFILE_REPEAT=5 \
TAGFLOW_PROFILE_RUN_ID=<dynamic-run-id> \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-dynamic \
TAGFLOW_PROFILE_CONTINUE_ON_FAILURE=true \
dart run melos run benchmark:profile:baselines
```

Run the same summarize/check sequence for each output directory. Keep both
lanes report-only until GC, raster, and phase-attribution notes are reviewed.

## Physical Target Qualification

Start every new physical target with one repeat and failure continuation:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_DEVICE=<physical-ios-device-id> \
TAGFLOW_PROFILE_REPEAT=1 \
TAGFLOW_PROFILE_CONTINUE_ON_FAILURE=true \
TAGFLOW_PROFILE_RUN_ID=<ios-probe-run-id> \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-device-probe \
dart run melos run benchmark:profile:baselines
```

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_DEVICE=<physical-android-device-id> \
TAGFLOW_PROFILE_REPEAT=1 \
TAGFLOW_PROFILE_CONTINUE_ON_FAILURE=true \
TAGFLOW_PROFILE_RUN_ID=<android-probe-run-id> \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-device-probe \
dart run melos run benchmark:profile:baselines
```

Then summarize the run and inspect failures before increasing repeat count:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=<probe-run-id> \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-device-probe \
dart run melos run benchmark:profile:summarize
```

Classify failures as target qualification blockers, not timing regressions:

- device not listed by Flutter
- wireless-only iOS stall before install or launch
- Android signing, permission, or install failure
- app launch timeout
- missing `integration_response_data.json`
- scroll did not complete
- overflow, exception, OOM, or process termination
- profile artifact was produced but lacks viewport or frame summary metadata

A physical target becomes a candidate reference target only after a probe
passes and a repeat-5 run passes the same summarize/check flow.

## Memory And Allocation Playbook

Profile summaries already record new-gen and old-gen GC counts. That is not
enough for allocation claims. For each promoted reference target, capture manual
DevTools evidence for:

- `tagflow:large_article`
- `tagflow:table_stress`
- `tagflow_semantic_patch:streaming_ai_authored_insertion_patches`

Minimum capture notes:

1. exact commit, package versions, Flutter/Dart version, device id, and run id;
2. DevTools Memory snapshot before first render;
3. snapshot after first render settles;
4. snapshot after warm scroll completes;
5. snapshot after dynamic patch sequence completes when applicable;
6. allocation profile or class allocation diff for large retained objects;
7. GC event counts from `profile-baseline-summary.json`;
8. reviewer decision for any old-gen GC or retained-growth outlier.

Store raw DevTools exports under ignored local output. Commit only a reviewed
summary under `docs/benchmarks/baselines/` if it affects release or public
claim decisions.

## Allowed And Blocked Language

Allowed now:

- "Tagflow has a report-only benchmark harness for local alpha stabilization."
- "The alpha harness can collect a complete repeat-5 local macOS profile
  matrix."
- "Native JSON rendering and dynamic patch lanes have smoke/report-only
  evidence."

Blocked until all qualification gates pass:

- "Tagflow is faster than `flutter_html`."
- "Tagflow is the fastest Flutter rich-content renderer."
- "Tagflow meets a stable frame-time budget."
- "Native JSON is faster than HTML parsing."
- "Dynamic patch rendering avoids jank in production."

## Follow-Up Implementation Threads

1. Add app-launch phase attribution to the profile harness so static
   `coldInitialRender`, `warmRebuild`, and `warmScroll` phases are not
   mistaken for process cold-start evidence. Current runner artifacts do not
   expose a defensible launch metric; see
   [`2026-06-12-app-launch-attribution-scope.md`](2026-06-12-app-launch-attribution-scope.md).
2. Expand `tagflow_native_json` from `native_ai_answer` smoke to a repeat-based
   fixture matrix with larger server-authored document shapes.
3. Add an Android physical-device qualification note with a real
   `flutter devices` target id, one-repeat probe result, and failure
   classification if it fails.
4. Add an iOS physical-device qualification note after the device is wired and
   not wireless-only from Flutter's perspective.
5. Capture DevTools Memory summaries for `large_article`, `table_stress`, and
   authored-insertion patch lanes.
6. Draft a numeric threshold proposal only after a stable reference target has
   a fresh reviewed repeat-5 baseline.
