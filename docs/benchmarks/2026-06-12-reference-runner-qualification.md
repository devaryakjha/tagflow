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
competitor adapters, native transport timings, native JSON profile baselines,
and dynamic update attribution. That is still not enough for public
performance copy. This document defines the exact gates that must be true
before any external claim can cite benchmark numbers.

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
| Native JSON profile lane | `2026-06-12-native-json-repeat5-local-baseline.md` records `15 / 15` cells for `tagflow_native_json` across `native_ai_answer`, `native_table_dense`, and `native_large_article`. | Local stabilization evidence. | Native-only evidence; not fixture-comparable to HTML renderers or claim-grade reference-target evidence. |
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
   - GC counts in profile summaries are reviewed, but they are not enough by
     themselves for allocation claims.
   - Manual DevTools Memory captures or equivalent allocation evidence exist
     for `large_article`, `table_stress`, and the dynamic patch lane.
   - Use the reviewed baseline playbook in
     [`docs/benchmarks/baselines/2026-06-12-memory-allocation-evidence-playbook.md`](baselines/2026-06-12-memory-allocation-evidence-playbook.md)
     before promoting any memory or allocation wording.
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
TAGFLOW_PROFILE_PAIR=tagflow_native_json:native_ai_answer,tagflow_native_json:native_table_dense,tagflow_native_json:native_large_article \
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
lanes report-only. Dynamic authored-insertion still needs explained GC/raster
behavior before any update-path claim, and native JSON still lacks a promoted
stable reference target plus any comparison policy against HTML lanes.

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

- device missing or not listed by Flutter
- wireless-only iOS stall before install or launch
- Developer Mode disabled or unavailable on the physical target
- install, signing, developer disk image, or permission failure
- app launch timeout or destination-availability timeout
- missing `integration_response_data.json`
- scroll did not complete
- overflow, exception, OOM, or process termination
- profile artifact was produced but lacks viewport or frame summary metadata

A physical target becomes a candidate reference target only after a probe
passes and a repeat-5 run passes the same summarize/check flow.

## Memory And Allocation Playbook

Use the reviewed playbook at
[`docs/benchmarks/baselines/2026-06-12-memory-allocation-evidence-playbook.md`](baselines/2026-06-12-memory-allocation-evidence-playbook.md)
for the exact lane-by-lane collection commands, DevTools Memory capture steps,
and reviewed baseline note requirements.

That playbook is the source of truth for:

- `tagflow:large_article`
- `tagflow:table_stress`
- `tagflow_semantic_patch:streaming_ai_authored_insertion_patches`
- optional native-runtime evidence for `tagflow_native_json:native_large_article`

The key rule remains the same: summary GC counts are useful review inputs, but
they do not qualify allocation claims on their own.

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
- "Tagflow uses less memory than the control lane."
- "The patch lane has a lower allocation footprint."
- "Native JSON is faster than HTML parsing."
- "Dynamic patch rendering avoids jank in production."

## Follow-Up Implementation Threads

1. Extend app-launch attribution beyond the current macOS local-runner slice:
   capture app first-frame markers and physical iOS/Android launch markers
   before promoting any process cold-start metric. The current summary schema
   distinguishes the Flutter-drive command envelope, native macOS markers,
   and `coldInitialRender` fixture render, all with a
   `not_process_cold_start` caveat; see
   [`2026-06-12-app-launch-attribution-scope.md`](2026-06-12-app-launch-attribution-scope.md).
2. Re-run the native JSON fixture matrix on the eventual promoted stable
   reference target after physical-target qualification and reference
   environment decisions are complete.
3. Add an Android physical-device qualification note with a real
   `flutter devices` target id, one-repeat probe result, and failure
   classification if it fails.
4. Add an iOS physical-device qualification note after the paired physical
   target produces a one-repeat manifest and integration artifact.
5. Capture DevTools Memory summaries for `large_article`, `table_stress`, and
   authored-insertion patch lanes.
6. Draft a numeric threshold proposal only after a stable reference target has
   a fresh reviewed repeat-5 baseline.
