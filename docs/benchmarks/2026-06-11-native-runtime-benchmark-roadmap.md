# Tagflow Native Runtime Benchmark Roadmap

## Status

- Date: 2026-06-11
- Scope: performance evidence audit, benchmark tiers, and alpha.2/alpha.3
  command plan
- Release posture: honest internal measurement, not public performance claims

## Purpose

Tagflow now has enough benchmark plumbing to collect repeatable evidence for
the native rich content runtime, but the evidence is not yet strong enough for
ranking copy or hard timing gates. This roadmap defines what the current lanes
prove, what they do not prove, and which checks can be used for alpha releases
without overstating the data.

The existing report-only policy remains the source of truth for profile
threshold posture:
[`policies/profile-reference-runner-policy.json`](policies/profile-reference-runner-policy.json).

## Current Evidence Inventory

| Lane | Current evidence | What it proves | Gate posture |
| --- | --- | --- | --- |
| Fixture validity | `benchmark:fixtures` in `packages/tagflow_benchmarks` | Shared fixtures load and stay deterministic enough for harness use. | Smoke gate. |
| HTML parser microbench | `benchmark:micro` | Parser runner emits fixture-level JSON from Flutter tests. The plain Dart CLI path previously hit Flutter-only import boundaries, so this lane should stay under the Flutter-capable harness until parser-only imports are isolated. | Smoke gate for emission only. |
| Widget render microbench | `benchmark:render` | Widget-test conversion/build samples exist with warmups, sample stats, node counts, and fixture metadata. | Smoke gate for completion only. |
| macOS profile default matrix | [`baselines/2026-06-11-macos-reference-profile-baseline-repeat5.md`](baselines/2026-06-11-macos-reference-profile-baseline-repeat5.md) | The macOS profile harness collected `60 / 60` cells for `tagflow`, `flutter_html`, and `flutter_widget_from_html` across four HTML fixtures with five repeats. | Local stabilization evidence, not a timing threshold. |
| Profile policy | [`policies/profile-reference-runner-policy.json`](policies/profile-reference-runner-policy.json) | The checker can require five repeats and `800x600 @ 2.0x` viewport metadata. | Collection-quality gate only. |
| Semantic streaming pair | [`baselines/2026-06-11-semantic-streaming-pair-repeat5.md`](baselines/2026-06-11-semantic-streaming-pair-repeat5.md) | Full-reparse semantic streaming and semantic patch streaming are measurable as an ordered pair. Patch lane GC and raster outliers remain diagnostic. | Report-only. |
| Authored insertion patch pair | [`baselines/2026-06-11-authored-insertion-ordered-repeat5-attribution.md`](baselines/2026-06-11-authored-insertion-ordered-repeat5-attribution.md) | Authored-ID insertion and ordered patch paths complete five repeats with update-frame attribution. | Report-only. |
| Native JSON transport smoke | [`baselines/2026-06-11-native-transport-smoke.md`](baselines/2026-06-11-native-transport-smoke.md) | Native block JSON decode, adapt, patch decode, patch adapt, patch apply, and total transport phases are recorded for the alpha.2 candidate fixture. | Report-only smoke. |
| Kite profile probe | [`baselines/2026-06-11-kite-ipo-debug-profile-probe.md`](baselines/2026-06-11-kite-ipo-debug-profile-probe.md) | Real-app attribution probing exists, but the documented run is debug/probe evidence rather than a supported profile benchmark. | Diagnostic only. |

## Benchmark Tiers

### Tier 0: Smoke

Purpose: prove that the harness, fixture, renderer, and artifact path still
work.

Required properties:

- one or more selected cells complete without exception, overflow, OOM, or
  missing JSON artifact
- command output is captured in ignored `build/` output
- reviewed notes do not claim faster/slower behavior

Allowed alpha gate:

- yes, for harness health and release handoff completeness
- no numeric timing thresholds

### Tier 1: Local Reference

Purpose: collect repeatable local stabilization evidence on a named machine.

Required properties:

- five successful repeats per selected cell
- `profile-baseline-summary.json` has no failed runs
- checker passes with `TAGFLOW_PROFILE_MIN_REPEATS=5`
- viewport guard passes when the target is expected to be `800x600 @ 2.0x`
- reviewed note records commit, package versions, Flutter/Dart versions, host
  OS, hardware, display, power, renderer ids, fixture ids, run id, and command

Allowed alpha gate:

- yes, for collection quality on the chosen reference environment
- no public ranking or threshold claim

### Tier 2: Release Gate

Purpose: decide whether a prerelease can be cut without known benchmark
regression risk.

Alpha.2 and alpha.3 release gates should be collection gates only:

- fixture, parser, render, and native transport smoke commands complete
- selected profile matrix or pair completes at the requested repeat count
- checker policy passes for repeat count and viewport
- reviewed baseline note explicitly says report-only when thresholds are absent
- any exception, OOM, missing artifact, unsupported target, or failed scroll is
  treated as release-significant until explained

Numeric timing gates can be introduced only after a stable reference
environment and reviewed regression policy are committed.

### Tier 3: Public Claim Qualification

Purpose: support external benchmark language.

Required before any public performance claim:

- stable Flutter channel and exact Flutter/Dart revisions
- stable host OS, not prerelease seed software
- physical iOS and Android profile evidence, or a written reason the claim is
  desktop-only
- real internal app profile evidence for the supported production surface
- pinned display/window conditions for desktop
- cold and warm runs separated
- repeat count and outlier policy justified in the reviewed note
- fixture sizes and feature coverage documented
- memory, GC, and allocation evidence reviewed for the claimed path
- competitor renderer configuration and feature support documented
- threshold and comparison policy committed before the claim is made

Until this tier exists, allowed wording is limited to internal evidence such as
"the alpha harness collected a complete local repeat-5 matrix."

## Current Gaps

- Device matrix: no supported physical iOS or Android profile baseline is
  qualified yet. Simulator profile mode has known limitations and should not be
  promoted without a fresh tooling check.
- Reference environment: the complete macOS repeat-5 run used Flutter master
  prerelease bits and prerelease macOS, so it is not claim-grade.
- Cold versus warm: the current profile matrix does not cleanly separate app
  cold start, first fixture render, warmed scroll, and warmed update paths.
- Repeat counts: profile lanes have useful repeat-5 evidence, but native
  transport smoke uses tiny samples and render microbench samples are still
  alpha-sized.
- Fixture sizes: fixtures cover smoke, rich answer, dense table, stress table,
  large article, nested lists, and streaming, but fixture byte sizes should be
  recorded in every reviewed note before claims.
- Dynamic updates: semantic patch lanes are measurable, but old-gen GC and
  raster outliers keep them diagnostic.
- Native JSON versus HTML: native transport measures JSON decode/adapt/patch
  overhead only. HTML parse/render lanes are separate and do not currently have
  an equivalent patch-envelope comparator.
- Memory/allocation: GC counts are captured in profile summaries, but heap
  snapshots and allocation profiles are still manual follow-up work.
- Frame attribution: update-frame attribution exists for streaming updates,
  but static first-render attribution and cold-start attribution are not yet
  split.
- Regression thresholds: no numeric performance thresholds are justified yet.
  The current policy intentionally blocks numeric regression gates.

## Alpha.2 Command Plan

Alpha.2 is centered on native JSON transport. Treat the release benchmark
surface as smoke plus report-only handoff evidence.

Run from the repository root:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH dart run melos run benchmark:fixtures
```

Capture:

- fixture validity pass/fail
- any asset or manifest error

Interpretation:

- any failure blocks benchmark handoff until fixed

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH dart run melos run benchmark:micro
```

Capture:

- emitted parser fixture results
- median, p95, mean, coefficient of variation, input bytes, node count

Interpretation:

- complete JSON emission is a smoke gate
- do not enforce parser timing deltas yet

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH dart run melos run benchmark:render
```

Capture:

- conversion/build samples, median, p95, mean, CV
- fixture ids, input bytes, node counts

Interpretation:

- completion is a smoke gate
- timing values are internal trend data only

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH dart run melos run benchmark:native-transport
```

Capture:

- document JSON bytes
- patch JSON bytes
- runtime node count after patches
- patch operation count
- per-phase samples, median, p95, min, max, mean, CV for
  `decodeDocument`, `adaptDocument`, `decodePatchEnvelope`, `adaptPatches`,
  `applyPatches`, and `totalTransport`
- `tagflow` package version

Interpretation:

- completion and phase-level output qualify alpha.2 smoke evidence
- no faster/slower claim versus HTML
- no numeric threshold

Optional alpha.2 profile sanity:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_RENDERER=tagflow \
TAGFLOW_FIXTURE=ai_answer_rich \
TAGFLOW_PROFILE_REPEAT=1 \
TAGFLOW_PROFILE_RUN_ID=alpha2-profile-smoke \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-alpha2-smoke \
dart run melos run benchmark:profile:baselines
```

Then summarize and check:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=alpha2-profile-smoke \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-alpha2-smoke \
dart run melos run benchmark:profile:summarize
```

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=alpha2-profile-smoke \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-alpha2-smoke \
TAGFLOW_PROFILE_MIN_REPEATS=1 \
dart run melos run benchmark:profile:check
```

Interpretation:

- useful for proving the profile harness still runs after release prep
- not a release timing gate

## Alpha.3 Command Plan

Alpha.3 should raise confidence by collecting repeat-based local reference
evidence for the native runtime and dynamic update paths.

Default HTML reference matrix:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_DEVICE=macos \
TAGFLOW_PROFILE_REPEAT=5 \
TAGFLOW_PROFILE_RUN_ID=alpha3-macos-html-repeat5 \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-alpha3 \
dart run melos run benchmark:profile:baselines
```

Summary:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=alpha3-macos-html-repeat5 \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-alpha3 \
dart run melos run benchmark:profile:summarize
```

Completeness and viewport check:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=alpha3-macos-html-repeat5 \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-alpha3 \
TAGFLOW_PROFILE_CHECK_POLICY=docs/benchmarks/policies/profile-reference-runner-policy.json \
dart run melos run benchmark:profile:check
```

Capture:

- successful and failed run counts
- p50/p90/p99/worst build and raster timings
- missed build/raster counts
- frame count and scroll completion
- GC counts and outlier repeats
- viewport metadata
- renderer, fixture, repeat, commit, SDK, OS, hardware, power, and display
  context

Interpretation:

- passing check means complete local reference evidence
- any failed or missing cell blocks promotion of the run
- timing values remain report-only unless a separate threshold policy is
  reviewed and committed

Dynamic update pair:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_PAIR=tagflow_semantic:streaming_ai_authored_insertions,tagflow_semantic_patch:streaming_ai_authored_insertion_patches \
TAGFLOW_PROFILE_REPEAT=5 \
TAGFLOW_PROFILE_RUN_ID=alpha3-authored-insertion-repeat5 \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-alpha3-dynamic \
TAGFLOW_PROFILE_CONTINUE_ON_FAILURE=true \
dart run melos run benchmark:profile:baselines
```

Then summarize and check with the same output dir and `min-repeats=5`.

Capture:

- update latencies per chunk
- `applyPatchMicros`, `pumpWidgetMicros`, `settleMicros`
- worst attributed update frame, phase, chunk, and fraction
- update missed build/raster counts
- GC counts and outlier repeats

Interpretation:

- complete repeat-5 output is stabilization evidence
- patch application timings may be discussed as phase evidence
- do not claim patch streaming is faster until GC and raster behavior are
  explained across a promoted reference environment

Physical target probe:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_DEVICE=<physical-device-id> \
TAGFLOW_PROFILE_REPEAT=1 \
TAGFLOW_PROFILE_CONTINUE_ON_FAILURE=true \
TAGFLOW_PROFILE_RUN_ID=alpha3-physical-probe \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-alpha3-device-probe \
dart run melos run benchmark:profile:baselines
```

Interpretation:

- a supported target must install, launch, scroll, write JSON, summarize, and
  check before it can join the reference matrix
- failed installation, wireless-only device stalls, or missing artifacts are
  target-qualification blockers, not timing regressions

## Proposed Gates

### Alpha.2

Required:

- `benchmark:fixtures` passes
- `benchmark:micro` passes and emits results
- `benchmark:render` passes and emits results
- `benchmark:native-transport` passes and emits report-only phase results for
  the alpha.2 package version
- `git diff --check` passes for docs or code changes

Optional but recommended:

- one profile smoke cell completes and passes a `min-repeats=1` check

Blocked:

- native transport threshold
- public performance claim
- comparison against HTML parser/render lanes

### Alpha.3

Required:

- alpha.2 smoke gates still pass
- default macOS reference matrix completes five repeats per cell
- profile check passes with the report-only policy
- dynamic update pair completes five repeats or records a reviewed blocker
- reviewed baseline notes list caveats and do not add numeric thresholds

Recommended:

- at least one physical-device qualification probe with `continue-on-failure`
- DevTools memory review for large article, table stress, and patch update
  paths

Blocked until a future threshold review:

- p90/p99 regression gate
- dropped-frame numeric gate
- competitor ranking copy

## Recommended Next Implementation Threads

1. Add cold/warm phase separation to the profile harness so app launch,
   first render, warmed scroll, warmed rebuild, and update phases are reported
   independently.
2. Add a memory/allocation playbook with exact DevTools capture steps for
   `large_article`, `table_stress`, and dynamic patch lanes.
3. Add native JSON profile fixtures that render `TagflowDocument` from native
   transport data in the example app, while keeping transport microbench and
   render profile metrics separate.
4. Add physical-device qualification docs for iOS and Android, including
   install prerequisites and failure-classification language.
5. Add a threshold proposal document only after a stable reference environment
   is selected and a fresh repeat-5 matrix is reviewed.
