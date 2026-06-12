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
The public-claim qualification checklist and operating runbook now live in
[`2026-06-12-reference-runner-qualification.md`](2026-06-12-reference-runner-qualification.md).
Threshold promotion and reference-environment rules are centralized in
[`2026-06-12-threshold-reference-policy.md`](2026-06-12-threshold-reference-policy.md).

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
| Native JSON profile lane | [`baselines/2026-06-12-native-json-repeat5-local-baseline.md`](baselines/2026-06-12-native-json-repeat5-local-baseline.md) | The example-app profile harness collected `15 / 15` native JSON cells for `native_ai_answer`, `native_table_dense`, and `native_large_article` with five repeats. Static summaries include `coldInitialRender`, `warmRebuild`, `warmScroll`, and macOS local-runner launch attribution. | Local stabilization evidence, not a timing threshold. |
| Memory evidence probe | [`baselines/2026-06-12-memory-allocation-evidence-probe.md`](baselines/2026-06-12-memory-allocation-evidence-probe.md) | `flutter drive --profile-memory` produced bounded DevTools memory JSON for `tagflow_native_json:native_large_article` and `tagflow_semantic_patch:streaming_ai_authored_insertion_patches`. | Feasibility evidence only. |
| Memory repeat-5 local status | [`baselines/2026-06-12-memory-allocation-repeat5-local-status.md`](baselines/2026-06-12-memory-allocation-repeat5-local-status.md) | Required macOS repeat-5 profile baselines now exist for `tagflow:large_article`, `tagflow:table_stress`, and the authored-insertion control/patch pair, with bounded `--profile-memory` JSON captured for those lanes plus optional `tagflow_native_json:native_large_article`. | Report-only memory evidence; allocation claims still blocked by missing snapshots and diffs. |
| Memory snapshot blocker | [`baselines/2026-06-12-memory-allocation-snapshot-blocker.md`](baselines/2026-06-12-memory-allocation-snapshot-blocker.md) | The repeated profile runner can now request per-cell bounded `--profile-memory` files, record any VM service URI printed by Flutter, and optionally replay named hold-open checkpoints for DevTools attachment. Heap snapshots, class allocation diffs, and retained-object review still require manual export. | Allocation evidence still blocked. |
| Checkpoint hold smoke | [`baselines/2026-06-12-checkpoint-hold-smoke.md`](baselines/2026-06-12-checkpoint-hold-smoke.md) | A one-repeat local macOS `tagflow:large_article` run with `TAGFLOW_PROFILE_HOLD_OPEN_SECONDS=1` passed, captured bounded memory JSON, recorded a VM service URI, and emitted named checkpoint attach markers. | Harness smoke only; DevTools exports still pending. |
| Memory evidence manifest smoke | [`baselines/2026-06-12-memory-evidence-manifest-smoke.md`](baselines/2026-06-12-memory-evidence-manifest-smoke.md) | A real one-repeat local macOS `tagflow:large_article` hold-open run wrote `memory-evidence-manifest.json`, linked it from the profile manifest, recorded expected DevTools export paths, and passed summary/check after the summary was generated. | Harness smoke only; manual heap snapshots, allocation diffs, and retained-object review still pending. |
| VM-service memory export helper | [`baselines/2026-06-12-memory-vm-service-exporter-smoke.md`](baselines/2026-06-12-memory-vm-service-exporter-smoke.md) plus retained-path exporter support added after it | A live hold-open VM service URI can now be used to export `getAllocationProfile(gc: true)` JSON, a class-level heap snapshot summary, and optional bounded `getRetainingPath` samples for selected classes through the VM service protocol. Generated manifests include per-checkpoint helper command metadata, and the first live smoke exported real JSON artifacts from a local `tagflow:large_article` run before retained-path sampling was added. | Report-only review input; retained-path exports are now proven on the authored-insertion patch lane, but raw DevTools heap/diff exports remain manual when needed. |
| Streamed profile output smoke | [`baselines/2026-06-12-streamed-profile-output-smoke.md`](baselines/2026-06-12-streamed-profile-output-smoke.md) | The profile baseline runner now streams child `benchmark:profile` output while preserving manifest/log capture. A one-repeat `tagflow:large_article` hold-open smoke showed the VM service URI and checkpoint markers before the runner returned. | Harness smoke only; enables named-checkpoint exporter use without process-table discovery. |
| Authored insertion checkpoint memory exports | [`baselines/2026-06-12-authored-insertion-checkpoint-memory-evidence.md`](baselines/2026-06-12-authored-insertion-checkpoint-memory-evidence.md) | A one-repeat local macOS authored-insertion control/patch profile pass exported VM-service allocation profiles and class-level heap summaries for all named control and patch checkpoints, with one supplemental control-only run used for the missed control `after_scroll` export. | Report-only allocation review input; retained-object interpretation and raw DevTools heap/diff exports remain pending. |
| Authored insertion patch retained paths | [`baselines/2026-06-12-authored-insertion-patch-after-scroll-retained-paths.md`](baselines/2026-06-12-authored-insertion-patch-after-scroll-retained-paths.md) | A one-repeat local macOS patch-only hold-open run exported a live `getRetainingPath` sample at patch `after_scroll` for `TagflowDocumentNode` and `TagflowDocument`. The sampled paths flowed through the live `Tagflow` widget and Flutter widget tree rather than showing a detached orphan object in isolation. | Report-only retained-object review input; same-process heap diffs and broader retained-object review remain pending. |
| Authored insertion patch multi-checkpoint retained paths | [`baselines/2026-06-12-authored-insertion-patch-multi-checkpoint-retained-paths.md`](baselines/2026-06-12-authored-insertion-patch-multi-checkpoint-retained-paths.md) | A one-repeat local macOS patch-only hold-open run used a streamed-output watcher to export retained-path JSON for `TagflowDocumentNode` and `TagflowDocument` at `before_first_patch`, `after_first_patch`, `after_final_patch`, and `after_scroll` from the same live process. Path shape stayed rooted through the live `Tagflow` widget and Flutter keep-alive wrappers across all four checkpoints. | Report-only retained-object review input; raw DevTools heap/diff review and any paired control-lane retained-path attribution remain pending. |
| Authored insertion control multi-checkpoint retained paths | [`baselines/2026-06-12-authored-insertion-control-multi-checkpoint-retained-paths.md`](baselines/2026-06-12-authored-insertion-control-multi-checkpoint-retained-paths.md) | A one-repeat local macOS control-only hold-open run used a streamed-output watcher to export retained-path JSON for `TagflowDocumentNode` and `TagflowDocument` at `before_first_update`, `after_first_update`, `after_final_update`, and `after_scroll` from the same live process. Path shape stayed rooted through the live `Tagflow` widget and active Flutter scroll tree across all four checkpoints. | Report-only retained-object review input; raw DevTools heap/diff review for the paired control/patch lane still remains pending. |
| Authored insertion class-growth review | [`baselines/2026-06-12-authored-insertion-class-growth-review.md`](baselines/2026-06-12-authored-insertion-class-growth-review.md) | Existing VM-service exports were reviewed for class-level growth. Same-process patch aggregate object count and heap-summary shallow size did not grow from `before_first_patch` to `after_scroll`; package-level Tagflow growth was limited to one `TagflowDocumentNode` and one `TagflowDocument`. | Report-only class-growth interpretation only; retained-object proof and public claims remain blocked without raw DevTools retained paths or heap diffs. |
| Physical target probe | [`baselines/2026-06-12-physical-target-availability-refresh.md`](baselines/2026-06-12-physical-target-availability-refresh.md), superseding the earlier [`baselines/2026-06-12-physical-target-usb-probe-stalled.md`](baselines/2026-06-12-physical-target-usb-probe-stalled.md) probe note | Current read-only discovery sees the iPhone 17 only in Flutter's wireless bucket while CoreDevice reports a paired local-network session with disconnected tunnel and unavailable DDI services; `xctrace` still lists the device offline. Android tooling was present with no attached target. | Negative qualification evidence; physical baseline still pending. |
| Kite profile probe | [`baselines/2026-06-11-kite-ipo-debug-profile-probe.md`](baselines/2026-06-11-kite-ipo-debug-profile-probe.md) | Real-app attribution probing exists, but the documented run is debug/probe evidence rather than a supported profile benchmark. | Diagnostic only. |
| Kite hosted-alpha app evidence | Kite evidence commit `be97da15`, adopted locally on `feat/dashboard` as `80160401` (`test(ipo): validate hosted tagflow alpha3`) | A focused Kite widget test consumes hosted `tagflow: ^1.0.0-alpha.3` and `tagflow_table: ^1.0.0-alpha.1`, renders checked-in IPO HTML fixture content through `Tagflow.html(..., registry: ...)` with `tagflowTableComponents(...)`, and validates native block document/patch decode-adapt-apply. The local adoption commit is not pushed while `gitlab.zerodha.tech` DNS is unavailable. | App-integration evidence only; not profile evidence. |
| Kite profile blocker | [`baselines/2026-06-12-kite-ipo-profile-evidence-blocked.md`](baselines/2026-06-12-kite-ipo-profile-evidence-blocked.md) | Kite now has hosted-alpha widget evidence, but no credible production profile capture is available because the main app branch is not pushed, no deterministic production fixture opener exists, and physical target tooling is inconsistent. A content-only production migration has been prepared in isolated Kite branch `codex/ipo-tagflow-registry-content` as `e26a14e6`, then beta-aligned with test cleanup `6d0d29f8` so downstream coverage avoids low-level table widget exports. The branch is not merged or profile evidence. | Negative qualification evidence; real-app profile baseline still pending. |

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

### Tier 2: Release Candidate Gate

Purpose: decide whether a prerelease can be cut without known benchmark
collection or stability blockers.

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
  qualified yet. The latest physical refresh saw the iPhone 17 only in
  Flutter's wireless bucket, with CoreDevice reporting a disconnected
  local-network tunnel and `xctrace` listing the device offline. Simulator
  profile mode has known limitations and should not be promoted without a
  fresh tooling check.
- Real-app profile: hosted-alpha widget evidence exists in Kite, including
  hosted `Tagflow.html(..., registry: ...)`, `tagflow_table` registry
  extension, and native block document/patch transport coverage. No credible
  production IPO profile-mode capture exists yet because the main Kite branch
  is not pushed, no deterministic production fixture opener exists, and
  physical-device tooling is inconsistent. A narrower content-only production
  migration slice exists as Kite branch `codex/ipo-tagflow-registry-content`
  with production migration commit `e26a14e6` and beta-aligned test cleanup
  commit `6d0d29f8`, but it is not profile evidence until merged and
  validated on a supported target.
- Reference environment: the complete macOS repeat-5 run used Flutter master
  prerelease bits and prerelease macOS, so it is not claim-grade.
- Cold versus warm: static profile artifacts now capture first fixture render,
  warmed rebuild, and warmed scroll as `coldInitialRender`, `warmRebuild`, and
  `warmScroll` in `profile-baseline-summary.json`. App cold start and warmed
  update-path separation are still follow-up work.
- Repeat counts: profile lanes have useful repeat-5 evidence, but native
  transport smoke uses tiny samples and render microbench samples are still
  alpha-sized.
- Fixture sizes: fixtures cover smoke, rich answer, dense table, stress table,
  large article, nested lists, and streaming. New profile artifacts emit
  per-cell `inputSummary.inputBytes` and `inputSummary.inputLength`; older
  reviewed notes that predate this schema still need fixture-size annotation
  before claims.
- Dynamic updates: semantic patch lanes are measurable, but old-gen GC and
  raster outliers keep them diagnostic.
- Native JSON versus HTML: native transport measures JSON decode/adapt/patch
  overhead only. The native JSON profile lane renders decoded native blocks in
  Flutter, but it is still a separate fixture path and is not an equivalent
  HTML comparator or patch-envelope comparator.
- Memory/allocation: GC counts are captured in profile summaries, and a bounded
  `--profile-memory` capture now exists for the required macOS HTML lanes, the
  authored-insertion control/patch pair, and one optional native-support lane.
  Reviewed repeat-5 baselines also exist for those lanes. Heap snapshots,
  allocation diffs, retained-object review, and promotion from bounded samples
  to reviewed allocation evidence remain follow-up work. The harness can now
  replay named hold-open checkpoints for DevTools attachment, generate a
  `memory-evidence-manifest.json` checklist, and export report-only
  VM-service allocation profiles plus class-level heap summaries from a live
  checkpoint. The exporter can now also collect bounded `getRetainingPath`
  samples for named classes such as `TagflowDocumentNode` and
  `TagflowDocument`. The authored-insertion patch lane now has a live
  `after_scroll` retained-path export recorded in
  [`docs/benchmarks/baselines/2026-06-12-authored-insertion-patch-after-scroll-retained-paths.md`](baselines/2026-06-12-authored-insertion-patch-after-scroll-retained-paths.md).
  It also now has a same-process multi-checkpoint retained-path review across
  `before_first_patch`, `after_first_patch`, `after_final_patch`, and
  `after_scroll` recorded in
  [`docs/benchmarks/baselines/2026-06-12-authored-insertion-patch-multi-checkpoint-retained-paths.md`](baselines/2026-06-12-authored-insertion-patch-multi-checkpoint-retained-paths.md).
  The paired control lane now also has a same-process multi-checkpoint
  retained-path review across `before_first_update`,
  `after_first_update`, `after_final_update`, and `after_scroll` recorded in
  [`docs/benchmarks/baselines/2026-06-12-authored-insertion-control-multi-checkpoint-retained-paths.md`](baselines/2026-06-12-authored-insertion-control-multi-checkpoint-retained-paths.md).
  Raw DevTools heap/diff exports still have to be captured or reviewed
  manually when needed before any public memory/allocation wording can be
  promoted. Use
  [`docs/benchmarks/baselines/2026-06-12-memory-allocation-evidence-playbook.md`](baselines/2026-06-12-memory-allocation-evidence-playbook.md)
  for the capture sequence and reviewed note requirements. The current
  non-device scoping blocker is recorded in
  [`docs/benchmarks/baselines/2026-06-12-memory-allocation-snapshot-blocker.md`](baselines/2026-06-12-memory-allocation-snapshot-blocker.md).
  The latest real-harness manifest smoke is recorded in
  [`docs/benchmarks/baselines/2026-06-12-memory-evidence-manifest-smoke.md`](baselines/2026-06-12-memory-evidence-manifest-smoke.md).
  The authored-insertion control/patch pair now has named-checkpoint
  VM-service allocation-profile and class-level heap-summary exports recorded
  in
  [`docs/benchmarks/baselines/2026-06-12-authored-insertion-checkpoint-memory-evidence.md`](baselines/2026-06-12-authored-insertion-checkpoint-memory-evidence.md),
  plus a report-only class-growth review in
  [`docs/benchmarks/baselines/2026-06-12-authored-insertion-class-growth-review.md`](baselines/2026-06-12-authored-insertion-class-growth-review.md).
  Raw retained-object paths and DevTools heap/diff exports remain pending, so
  public memory/allocation wording remains blocked.
- Frame attribution: update-frame attribution exists for streaming updates, and
  static first-render, warm-rebuild, and warm-scroll phases are split. macOS
  local-runner launch markers are recorded separately as `launchAttribution`,
  but they are not generic app cold-start metrics.
- Regression thresholds: no numeric performance thresholds are justified yet.
  The current policy intentionally blocks numeric regression gates. Promotion
  from report-only evidence to advisory or gating thresholds must follow
  [`2026-06-12-threshold-reference-policy.md`](2026-06-12-threshold-reference-policy.md).

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

Native JSON profile local baseline:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_PAIR=tagflow_native_json:native_ai_answer,tagflow_native_json:native_table_dense,tagflow_native_json:native_large_article \
TAGFLOW_PROFILE_REPEAT=5 \
TAGFLOW_PROFILE_RUN_ID=alpha3-native-json-repeat5 \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-alpha3-native-json \
dart run melos run benchmark:profile:baselines
```

Capture:

- fixture ids `native_ai_answer`, `native_table_dense`, and
  `native_large_article`
- renderer id `tagflow_native_json`
- viewport metadata
- `coldInitialRender`, `warmRebuild`, and `warmScroll` phase summaries emitted
  by the profile summary
- `launchAttribution.status` and provenance/scope

Interpretation:

- completion proves the example app can render native block JSON through
  `TagflowDocument`
- this is a native-only fixture matrix, not a direct equivalent of the HTML
  fixture matrix
- this lane is separate from `benchmark:native-transport`, which still measures
  decode/adapt/patch overhead without Flutter rendering
- no numeric pass/fail threshold or public comparison against HTML lanes

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
- native JSON profile repeat baseline completes or records a reviewed blocker
- reviewed baseline notes list caveats and do not add numeric thresholds

Recommended:

- at least one successful physical-device qualification probe with
  `continue-on-failure`
- playbook-complete DevTools memory review for large article, table stress, and
  patch update paths

Blocked until a future threshold review:

- p90/p99 regression gate
- dropped-frame numeric gate
- competitor ranking copy

## Recommended Next Implementation Threads

1. Capture the first playbook-complete DevTools memory/allocation note from a
   hold-open run, starting with the authored-insertion control/patch pair in
   `2026-06-12-memory-allocation-snapshot-blocker.md`. Include
   `TAGFLOW_MEMORY_EVIDENCE_RETAINING_CLASSES=TagflowDocumentNode,TagflowDocument`
   on the patch `after_scroll` checkpoint so the exporter records bounded
   retained-path samples for the classes surfaced by the class-growth review.
   Do not substitute another bounded `--profile-memory` sample for the missing
   snapshot/diff evidence.
2. Run the authored-insertion control/patch pair with checkpoint holds and use
   the streamed VM service URI plus `memory-evidence-manifest.json` command
   metadata to export VM-service evidence at each named checkpoint, including
   retained-path samples for the reviewed Tagflow classes where requested.
3. Re-run physical-device qualification only after a USB iOS target appears as a
   normal connected target to Flutter and Apple tooling, or after an attached
   Android target is available. Stop after the first bounded failure and update
   the physical-target note.
4. Push, merge, and real-route validate the Kite
   `codex/ipo-tagflow-registry-content` branch before treating it as production
   surface evidence.
5. Record real-app profile-mode evidence for the hosted-alpha production
   surface after the production route is merged, separate from debug probes and
   converter-free widget tests.
6. Add or promote threshold policy only after a stable reference environment is
   selected and a fresh repeat-5 matrix plus memory/allocation review are
   complete.
