# Tagflow Native Rich Content Runtime Master Plan

> **Master thread:** Coordinates workstreams, reviews worker outputs, assigns
> implementation waves, and keeps release gates explicit.

## Goal

Evolve Tagflow from a Flutter HTML renderer into a native rich content runtime
for Flutter apps. HTML remains a first-class adapter, but the central contract is
a safe, theme-aware document model that can render AI, CMS, and app-authored
structured content as native Flutter widgets.

## Release Target

The native runtime architecture is shipping through the `1.0.0-alpha.x`
prerelease line. The line is intentionally breaking because current public usage
appears low and the package is still internally driven. Stable `1.0.0` should
wait until a real internal Flutter app has integrated the new model and
benchmark results are strong enough for public claims.

Current published prerelease: `tagflow` `1.0.0-alpha.3`.

`1.0.0-alpha.3` keeps the data-only trusted native JSON transport from alpha.2,
then adds contract hardening, benchmark gate documentation, and first-class
semantic disclosure rendering for HTML `details` / `summary`. It does not claim
a CMS sync protocol or public performance result. `tagflow_table` remains a
separate first-party extension at `1.0.0-alpha.1`.

Next coordination target: `1.0.0-alpha.4` or a pre-beta planning slice, not
`1.0.0-beta.0` yet. The alpha.3 release proved the hosted package line can be
consumed downstream, and the current coordinator branch has resolved the
reviewed style and table public-surface blockers. Beta still needs reviewed
memory/allocation evidence, pushed and merged downstream production-route
evidence, supported-target profile evidence, and final release-gate approval.

## Coordinator Snapshot

- Branch: `codex/tagflow-native-runtime-master`
- Latest integrated coordinator commits include
  `de2d9ec docs(benchmarks): record ios physical signing blocker`,
  `246e33a docs(specs): decide patch result semantics`,
  `fb9e20e docs(specs): reconcile native runtime current state`,
  `20456e1 docs(plans): sequence native runtime follow-up slices`, and
  `9491aa5 docs(benchmarks): document profile dpr qualification`.
- Latest integrated implementation commits include
  `3eb7b9b feat(benchmarks): emit memory evidence checkpoints`,
  `a4861dd refactor(table): narrow public table exports`,
  `42e6c7a refactor(api): promote shared style primitives`,
  `ffbb9bd feat(benchmarks): add profile checkpoint hold mode`,
  `4d1aeca fix(runtime): keep disclosure summaries inline`, and
  `c2053a5 feat(runtime): render html disclosure nodes`.
- Alpha acceptance status: all `1.0.0-alpha.1` runtime criteria in
  `docs/plans/2026-06-11-tagflow-v1-alpha-acceptance-status.md` are marked
  done.
- Release posture: `tagflow` is published as `1.0.0-alpha.3` from tag
  `tagflow-v1.0.0-alpha.3`, and `tagflow_table` remains published at
  `1.0.0-alpha.1`. Package descriptions, changelogs, READMEs, roadmap, and the
  alpha migration guide frame the package as a native rich content runtime.
  The alpha3 handoff and publish evidence live in
  `docs/plans/2026-06-12-tagflow-alpha3-release-handoff.md`.
- Package discovery posture: the native runtime line is prerelease-only. The
  2026-06-12 pub.dev API checks still report stable `tagflow` `0.0.8` and
  stable `tagflow_table` `0.0.4+5` as each package's default `latest` release.
  The same checks list `tagflow` prereleases `1.0.0-alpha.1` and
  `1.0.0-alpha.3`, and `tagflow_table` prerelease `1.0.0-alpha.1`, so pub.dev
  search/default package-page metadata can still look HTML-first or
  table-plugin-first. Downstream app validation must explicitly request
  `tagflow: ^1.0.0-alpha.3` and `tagflow_table: ^1.0.0-alpha.1`; this discovery
  mismatch is not a reason to skip beta/stable evidence gates.
- Benchmark posture: parser and widget-render microbenchmarks are committed;
  the deterministic corpus now includes `table_stress`; the example app has a
  profile-mode benchmark harness with renderer, fixture, and device selection
  through environment variables, plus landed `flutter_html` and core-backed
  `flutter_widget_from_html` competitor adapters. The markdown-only comparison
  lane now has `flutter_markdown_plus` and `markdown_widget` adapters, an
  explicit `ai_answer_rich_md` fixture, source-type compatibility checks, and
  passing macOS profile smokes for both markdown renderers. A
  reference-baseline runner can now execute a selected renderer/fixture matrix
  and preserve copied profile JSON artifacts under ignored workspace-root build
  output. A
  profile-baseline summarizer, completeness gate, Melos summary/check aliases,
  capped macOS reference note, and complete repeat-5 macOS matrix note now turn
  raw profile JSON into reviewed internal stabilization evidence. A
  machine-readable report-only checker policy now records the candidate
  repeat-count and viewport guard without introducing timing thresholds. The
  complete
  run `2026-06-11T08-14-32-397331Z` passed all `60 / 60` profile cells and the
  `TAGFLOW_PROFILE_MIN_REPEATS=5` completeness gate. The macOS integration-test
  plugin warning has a narrow benchmark-script suppression while preserving
  JSON output, and the separate CocoaPods/SPM migration warning has been
  removed from the macOS example host. The native block JSON transport now has
  a report-only microbenchmark lane, `benchmark:native-transport`, with smoke
  evidence recorded in
  `docs/benchmarks/baselines/2026-06-11-native-transport-smoke.md`. The
  alpha.2 candidate rerun reports package version `1.0.0-alpha.2` for the same
  native transport smoke surface. Static profile artifacts now also separate
  `coldInitialRender`, `warmRebuild`, and `warmScroll` frame summaries while
  remaining report-only evidence. The HTML adapter now also supports
  authored node ID strategies for controlled dynamic content through
  `TagflowHtmlNodeIdStrategy.attribute()`, which reads `data-tagflow-id` by
  default while preserving path IDs as the compatibility fallback.
- Alpha3 benchmark posture remains collection-gate only. The current evidence
  includes report-only native transport microbenchmarks plus a cold/warm native
  JSON profile smoke lane; it must not be used for public performance ranking
  or speed claims until the reference-runner qualification gates in
  `docs/benchmarks/2026-06-12-reference-runner-qualification.md` are satisfied
  and a separate threshold/comparison policy is reviewed.
- Follow-up benchmark commits through `d919d45`, `19e0fc4`, `11c644a`,
  `4e190ea`, and the earlier memory-manifest/exporter work clarify the current
  memory/allocation boundary.
  The repeated profile runner
  can now request per-cell `--profile-memory` artifacts with
  `TAGFLOW_PROFILE_MEMORY=true`, record VM service URIs, replay named
  checkpoint holds for DevTools attachment, and emit a
  `memory-evidence-manifest.json` checklist with expected manual export paths.
  `benchmark:memory-evidence:export` can now connect to a live hold-open VM
  service URI and write `getAllocationProfile(gc: true)` JSON, a compact
  class-level heap snapshot summary, and bounded `getRetainingPath` samples.
  The authored-insertion control/patch pair now has named-checkpoint
  VM-service allocation-profile and class-level heap-summary exports, plus a
  report-only class-growth review. That review found no same-process patch
  aggregate growth from `before_first_patch` to `after_scroll`, with
  package-level Tagflow growth limited to one `TagflowDocumentNode` and one
  `TagflowDocument`. A follow-up patch-only `after_scroll` run exported live
  retained paths for those classes; the sampled paths flowed through the live
  `Tagflow` widget and Flutter widget tree. The patch lane now also has
  same-process retained-path exports for `before_first_patch`,
  `after_first_patch`, `after_final_patch`, and `after_scroll`, with stable
  high-level retaining-path shape through the live `Tagflow` widget and Flutter
  keep-alive wrappers. The paired control lane now has same-process
  retained-path exports for `before_first_update`, `after_first_update`,
  `after_final_update`, and `after_scroll`, with stable high-level path shape
  through the live `Tagflow` widget and active Flutter scroll tree. The exporter
  now de-duplicates repeated retained-path class targets before export. Later
  raw VM-service heap snapshot/class-diff evidence covers the authored-insertion
  control/patch pair, `large_article`, and `table_stress`; the reviewed
  interpretation keeps that evidence as local macOS report-only input, not
  leak-free, allocation, or public memory proof.
- Post-alpha stabilization in progress: stable reference-environment selection,
  physical iOS or Android profile qualification, real-app production-route
  profile evidence, and approved wording for any memory/allocation language.
  Threshold policy is documented, but no benchmark claim should be promoted
  until the reference environment and evidence gates are satisfied together. The
  attribution-enabled authored-ID ordered-insertion repeat-5 rerun completed
  with no report-only outliers and remains bounded report-only evidence.
- Latest gate refresh: `ssh -T git@gitlab.zerodha.tech` still fails DNS
  resolution, `flutter devices` still lists physical iOS candidates only in
  the wireless bucket, `xctrace` still lists those same UDIDs under
  `Devices Offline`, and `adb devices -l` with platform-tools on `PATH` reports
  no attached Android devices. The bounded one-repeat iOS native JSON probe
  reached Xcode signing and produced a failed manifest, but no install,
  launch, integration artifact, or runtime metrics; see
  `docs/benchmarks/baselines/2026-06-12-ios-physical-signing-blocked.md`.
- Kite validation evidence now covers both the proof-only local override path
  and the clean hosted-alpha dependency path. The proof run demonstrated the
  native `TagflowDocument` path and controlled HTML adapter policy inside Kite.
  The clean branch `codex/kite-tagflow-alpha-runtime` at `d9682aec` updates only
  hosted `tagflow`/`tagflow_table` `1.0.0-alpha.1` constraints plus the two IPO
  legacy imports; it reached the real `IPOInstrumentSheet` through the
  authenticated Bids -> IPO route in Kite's in-app Dark theme, with screenshot
  evidence under `docs/validation/evidence/2026-06-11-kite-alpha-ipo-real-*`.
  A debug VM timeline attribution probe exists, but it is not release-grade
  performance evidence. A physical iPhone profile attempt is documented as a
  supported-target blocker because the phone was wireless-only from Flutter's
  perspective and stalled before install/launch; see
  `docs/validation/evidence/2026-06-11-kite-alpha-profile-blocker-summary.md`.
- A focused Kite native JSON transport probe confirmed the alpha2 release need:
  hosted `1.0.0-alpha.1` lacked `TagflowNativeBlockCodec` and
  `TagflowNativeBlockAdapter`, while a temporary local override to the
  coordinator Tagflow checkout passed a test-only decode/adapt/patch-apply
  path. Hosted alpha3 validation thread `019eb836-f538-7182-aeed-59550ad3e9a0`
  completed in isolated Kite worktree `/Users/arya/.codex/worktrees/cf2b/kite`
  at `be97da15 test(ipo): validate hosted tagflow alpha3`. That slice resolved
  hosted `tagflow` `1.0.0-alpha.3` and hosted `tagflow_table`
  `1.0.0-alpha.1`, because the older `tagflow_table 0.0.4+5` constrained
  `tagflow ^0.0.4`. It added a real Afcons IPO fixture and focused widget
  coverage for the existing IPO render path plus converter-free built-in
  `details` / `summary` disclosure through
  `Tagflow.html(..., registry: TagflowComponentRegistry(extensions:
  [tagflowTableComponents(...)]))`. `fvm flutter test
  test/ipos/ipo_tagflow_render_test.dart` passed two tests, and focused
  analysis passed. Limitation: Kite production IPO rendering still uses the
  legacy converter bridge for stability; the built-in disclosure path is proven
  in a Kite test harness, not yet in a live backend IPO payload.
- Follow-up Kite hosted-alpha3 reconciliation thread
  `019eb906-47fd-7543-a6b2-5349f2e5aa00` completed with
  `DONE_WITH_CONCERNS`. The main Kite checkout is still at local commit
  `80160401 test(ipo): validate hosted tagflow alpha3` on `feat/dashboard`,
  one commit ahead of `origin/feat/dashboard`; a single push retry failed with
  `ssh: Could not resolve hostname gitlab.zerodha.tech: nodename nor servname
  provided, or not known`. The worker reran
  `fvm flutter test test/ipos/tagflow_hosted_alpha3_test.dart` and focused
  analysis over `lib/screens/ipos/ipo_instrument_sheet.dart`,
  `lib/component/tagflow_details_converter.dart`, and
  `test/ipos/tagflow_hosted_alpha3_test.dart`; both passed. No new Kite patch
  was made.
- The production-safe Kite migration candidate has been prepared locally as
  isolated branch `codex/ipo-tagflow-registry-content`. Commit `e26a14e6`
  moves only the real `store.ipoInfo.content` render in
  `lib/screens/ipos/ipo_instrument_sheet.dart` to
  `Tagflow.html(..., registry: ...)` with `tagflowTableComponents(...)`, while
  keeping `store.ipoInfo.excerpt` on the legacy path. Follow-up commit
  `6d0d29f8` keeps the focused test aligned with the beta table public barrel by
  asserting rendered table content instead of low-level table widget exports.
  This branch remains local while GitLab DNS is unavailable and is not profile
  evidence until pushed, merged, and validated through a real route on a
  supported target.
- The example app now includes a `Native JSON Transport` screen that decodes
  trusted app-controlled JSON through `TagflowNativeBlockCodec`, renders via
  `Tagflow.document(...)`, and applies a four-operation patch envelope through
  `TagflowNativeBlockAdapter.adaptPatches(...)`.

## Current Constraints

- Repo is a Melos 7-managed Flutter monorepo with workspace and Melos
  configuration declared in the root `pubspec.yaml`.
- Root SDK constraint is `>=3.9.0 <4.0.0`.
- Master coordination uses `docs/specs/`, `docs/plans/`, and
  `docs/benchmarks/` as the current source-of-truth locations.
- Current public exports have an alpha/beta posture review in
  `docs/specs/2026-06-12-beta-public-api-freeze-review.md`; broad legacy
  compatibility remains deliberate rather than accidental.
- Current tests exist for parser, converter, style, table, options, and widgets.
- CI and publish workflows exist under `.github/workflows/`.
- Existing local change in `.vscode/settings.json` is treated as user-owned.
- Release-audit worker `019eb4f5-b537-7f40-bd1c-1fc301265129` reported
  `DONE` after `git diff --check`, `dart run melos run validate`, and
  `dart run melos run publish:dry-run` passed with no files changed in the
  audit worktree.

## Current Architecture Audit

Completed by thread `019eb48b-9061-7f12-bf4c-19119874521a`.

Highest-risk findings:

- `packages/tagflow/lib/tagflow.dart` exports broad `src/` internals. The alpha
  line must define an intentional public API instead of accidentally freezing
  parser/model/converter/style internals.
- The current runtime is HTML-shaped end-to-end: `Tagflow(html: ...)`,
  `TagflowParser`, raw tag strings, and synthetic `div` fallback roots. The new
  document model must invert that relationship so HTML is an adapter.
- Core `tagflow` and `tagflow_table` both provide table paths. Alpha must choose
  a canonical table renderer before implementation work spreads.
- Converter selector support and theme selector support do not match. The v1
  style/registry contract must choose one explicit selector story.
- Several style/parser behaviors are partial or misleading for a general rich
  content runtime, including relative units, selector support, and image options.
- Current tests are solid at unit level but weak at end-to-end runtime
  semantics, golden coverage, and benchmarking.

Audit-recommended implementation order:

1. Freeze the public boundary for alpha.
2. Define a source-agnostic native rich-content document model.
3. Split HTML import/source nodes from runtime rendering nodes.
4. Move style resolution onto the runtime model with an explicit selector story.
5. Pick one table architecture.
6. Add caching around parse/adapt, style resolution, and converter lookup.
7. Build the HTML adapter on top of the runtime model.
8. Keep `Tagflow(html: ...)` as a compatibility facade if feasible.

## Architecture SPEC

Drafted by thread `019eb48b-33d4-7803-a91c-3fcd7440e197` and copied into the
master branch at `docs/specs/2026-06-11-native-rich-content-runtime.md`.

Accepted master-thread direction:

- `TagflowDocument` becomes the canonical renderer input.
- `Tagflow.html(...)` becomes a convenience wrapper over `TagflowHtmlAdapter`
  plus the document runtime.
- `Tagflow({required html, ...})` may stay as a deprecated compatibility alias
  in alpha.
- Alpha shipped HTML as the first first-party adapter. The later native block
  transport slice adds trusted data-only JSON document and patch-envelope
  decoding for app-controlled producers, without introducing arbitrary widget
  serialization or a CMS sync protocol.
- A `TagflowContentPolicy` with safe defaults is required in alpha.
- A semantic `TagflowComponentRegistry` is required in alpha and must support
  app-owned renderer overrides.
- Render-boundary behavior remains, but as an HTML-adapter concern.
- Public exports must be curated before alpha publication.

Architecture open decisions:

- Whether legacy `converters:` stays on `Tagflow` as a bridged alpha path or
  moves behind a separate legacy API.
- Whether `tagflow_table` remains separate through beta or folds into core after
  the semantic registry exists.
- How much class-based styling the HTML adapter should preserve in alpha.
- The native block adapter foundation has landed, including direct semantic
  table block mapping, callout normalization, and operation-shaped native block
  patch adaptation into `TagflowDocumentPatch`. The adapter-side
  `TagflowNativeBlockCodec` and `TagflowNativeBlockPatchEnvelope` transport
  slice has also landed for data-only JSON documents and ordered patch payloads.
  Unknown producer block kinds, unknown patch operations, and future schema
  versions remain strict codec failures through beta; placeholders are only for
  reviewed policy rejections on known blocks. Native adapter beta surface is
  typed-model plus explicit JSON codec, policy reuses `TagflowContentPolicy`,
  callouts stay container-normalized, native tables keep captions and extra
  hints as metadata, and `image` is the only reviewed native media kind until
  app evidence proves otherwise. Broader storage/sync protocol decisions remain
  tracked in
  `docs/specs/2026-06-11-native-block-adapter-contract.md`.

## Release and Docs Direction

Completed by thread `019eb48b-c767-73b3-bb77-d3ef726b13f7`.

Accepted messaging:

- Keep the name `Tagflow`.
- Lead copy: "Tagflow is a native rich content runtime for Flutter apps. Render
  controlled HTML, CMS, and server-authored content into native widgets."
- Package description for `tagflow`: "Native rich content runtime for Flutter
  apps. Render controlled HTML and server-authored content into native widgets."
- Package description for `tagflow_table`: "Table extension for Tagflow's
  native rich content runtime."

Completed docs/release changes for the alpha line:

- Root `README.md` now frames Tagflow as a native rich content runtime instead
  of a generic HTML rendering engine.
- `packages/tagflow/README.md` documents `Tagflow.html(...)`,
  `Tagflow.document(...)`, `TagflowViewOptions`, `TagflowHtmlAdapter`,
  `TagflowContentPolicy`, `TagflowComponentRegistry`, and
  `package:tagflow/legacy.dart`.
- `packages/tagflow_table/README.md` describes the package as a first-party
  runtime table extension while preserving legacy converter guidance.
- `packages/tagflow/pubspec.yaml` and `packages/tagflow_table/pubspec.yaml`
  describe the alpha runtime line. `tagflow` is published as
  `1.0.0-alpha.3`; `tagflow_table` remains `1.0.0-alpha.1` because the native
  JSON transport and disclosure slices did not require a table package release.
- Package changelogs contain `1.0.0-alpha.1`, `1.0.0-alpha.2`, and
  `1.0.0-alpha.3` entries where applicable.
- `docs/migration/2026-06-11-tagflow-v1-alpha-migration.md` documents the
  `0.0.x` to alpha migration.
- Melos has a `version:alpha` lane and non-interactive publish dry-run lane.
- The `1.0.0-alpha.2` notes document `TagflowNativeBlockCodec`,
  `TagflowNativeBlockPatchEnvelope`, the native JSON document
  decode/adapt/render path, the patch envelope decode/adapt/apply path, and
  the report-only `benchmark:native-transport` lane.
- The `1.0.0-alpha.3` notes document stricter native schema/patch failures,
  unsupported-native HTML adapter behavior, compatibility support windows,
  benchmark gate posture, and first-class HTML disclosure widgets.

Claims to avoid in alpha:

- arbitrary webpage rendering
- full CSS support
- flexbox/grid/media-query completeness
- generalized plugin registry maturity
- migration stability beyond the explicitly documented alpha surface

## Benchmark SPEC

Drafted by thread `019eb48b-6673-74b2-89ed-d935756f7c4e` and copied into the
master branch at
`docs/benchmarks/2026-06-11-tagflow-v1-alpha-benchmark-spec.md`.

Accepted benchmark architecture:

- Add a non-publishable internal `packages/tagflow_benchmarks` package for
  deterministic fixtures, result schemas, parser microbenches, converter
  microbenches, and competitor renderer adapters.
- Extend the existing `examples/tagflow` app for profile-mode frame, scroll, and
  render benchmarks instead of creating another benchmark app.
- Use `integration_test` and a `test_driver` for machine-readable profile
  results.
- Keep PR CI focused on deterministic microbenches and fixture validity.
- Keep hosted-runner frame timings report-only until a stable reference runner
  exists.
- Use `docs/benchmarks/2026-06-12-reference-runner-qualification.md` as the
  public-claim gate: repeat-5 collection, physical-device or scoped desktop
  target qualification, fixture coverage, memory/allocation review, competitor
  fairness review, and an explicit threshold/comparison policy are required
  before citing benchmark numbers externally.
- Treat WebView as a UX baseline only, not a native renderer competitor.

Benchmark fixture corpus:

- `smoke_short_html`
- `ai_answer_rich` with paired HTML and Markdown
- `table_dense`
- `table_stress`
- `large_article`
- `deep_nested_lists`
- `streaming_ai_chunks`

Benchmark implementation order:

1. Add `docs/benchmarks/baselines/.gitkeep` and create
   `packages/tagflow_benchmarks`.
2. Add shared fixtures and fixture validity tests.
3. Implement parser and converter microbench runners for Tagflow only.
4. Add benchmark route plus `integration_test` and `perf_driver` to the example
   app.
5. Implement profile-mode Tagflow frame tests for `ai_answer_rich`,
   `table_dense`, and `large_article`.
6. Add `flutter_html` and `flutter_widget_from_html` comparison adapters.
7. Add `flutter_markdown_plus` and `markdown_widget` markdown-only adapters.
   Done in `e21e573 feat(benchmarks): add markdown renderer lane`.
8. Add `webview_flutter` only after native baselines exist, and keep it
   report-only.
9. Establish reviewed baselines on one reference machine before regression
   thresholds become meaningful.

## Workstreams

### 1. Architecture and SPEC

Owner: architecture/SPEC worker thread.

Thread:

- ID: `019eb48b-33d4-7803-a91c-3fcd7440e197`
- Worktree: `/Users/arya/.codex/worktrees/1563/tagflow`

Output:

- `docs/specs/YYYY-MM-DD-...md` architecture SPEC.
- Public API proposal for `TagflowDocument`, adapters, policy, registry, and
  rendering options.
- Clear alpha vs later-phase scope.
- Risks requiring master-thread review.

Master review gate:

- The document model must not be HTML-shaped internally.
- HTML must remain easy to use through a dedicated adapter or constructor.
- The alpha scope must be implementable without building a full browser,
  editor, or arbitrary webpage renderer.

### 2. Benchmarking and Performance

Owner: benchmarking worker thread.

Thread:

- ID: `019eb48b-6673-74b2-89ed-d935756f7c4e`
- Worktree: `/Users/arya/.codex/worktrees/0cc4/tagflow`

Output:

- Benchmark SPEC or plan under `docs/specs/` or `docs/benchmarks/`.
- Fixture matrix for article, AI answer, lists, code, tables, large documents,
  and incremental content.
- Metrics for parse cost, conversion/build cost, frame/render cost, and memory
  or allocation signals where practical.
- Competitor comparison plan covering `flutter_html`,
  `flutter_widget_from_html`, Markdown renderers, and WebView where fair.

Master review gate:

- Benchmarks must be reproducible locally with documented commands.
- CI benchmarks must be scoped to avoid noisy performance assertions.
- Comparative claims must be generated from real fixtures, not README language.

### 3. Current Code Audit

Owner: current-code audit worker thread.

Thread:

- ID: `019eb48b-9061-7f12-bf4c-19119874521a`
- Worktree: `/Users/arya/.codex/worktrees/72c9/tagflow`

Output:

- Current public API inventory.
- Parser/style/converter architecture map.
- Risk list with file references.
- Suggested implementation order and first test gaps.

Master review gate:

- Implementation sequence must start from existing code boundaries.
- Any proposed public API break must be intentional and documented.
- Table extension migration must be accounted for, not left as an afterthought.

### 4. Release, Docs, and Positioning

Owner: release/docs worker thread.

Thread:

- ID: `019eb48b-c767-73b3-bb77-d3ef726b13f7`
- Worktree: `/Users/arya/.codex/worktrees/aff3/tagflow`

Output:

- Recommended `1.0.0-alpha.1` package description and README framing.
- Migration note structure from `0.0.x` to `1.0.0-alpha.1`.
- Changelog and versioning sequence.
- Explicit list of claims to avoid in alpha.

Master review gate:

- Tagflow keeps its name.
- The tagline shifts from HTML renderer to native rich content runtime.
- Docs must not imply arbitrary webpage or full CSS support.

## Implementation Waves

### Wave 0: SPEC and Baseline

- Status: complete.
- Worker SPECs are merged into the master branch.
- Benchmark plan and local alpha baseline are committed.
- `docs/specs/`, `docs/plans/`, and `docs/benchmarks/` are the current
  coordination locations.

### Wave 1: Public Contract Skeleton

- Status: complete for alpha.
- `TagflowDocument`, `TagflowDocumentNode`, `TagflowHtmlAdapter`,
  `TagflowContentPolicy`, `TagflowComponentRegistry`, `TagflowViewOptions`,
  `Tagflow.html(...)`, and `Tagflow.document(...)` are implemented and tested.
- Legacy parser/converter/core surfaces are available from
  `package:tagflow/legacy.dart`.

### Wave 2: Benchmark Harness

- Status: in progress.
- Fixtures, parser microbenchmarks, widget render microbenchmarks, and the
  profile-mode example harness are committed.
- The profile harness supports renderer and fixture selection.
- The deterministic fixture corpus now includes `table_stress`, with local
  parser/render benchmark evidence and a Tagflow profile smoke run.
- The example profile harness now registers `streaming_ai_chunks` as a
  Tagflow-only dynamic-content scenario that renders 25%, 50%, 75%, and 100%
  chunks of `ai_answer_rich` and records update latency before the final scroll
  measurement.
- The example profile harness now has separate `tagflow` compatibility and
  `tagflow_semantic` native-runtime renderer ids, so dynamic-content profiling
  can target `TagflowDocument` plus semantic table components instead of only
  the legacy converter bridge.
- The immutable runtime patch API has landed through `TagflowDocumentPatch` and
  `TagflowDocumentUpdates.applyPatch(...)`, so the next benchmark step can
  measure semantic document patch updates against full HTML reparse behavior.
- The example profile harness now has a report-only `tagflow_semantic_patch`
  renderer plus `streaming_ai_patches` fixture. It parses the rich AI-answer
  HTML once into a semantic document, applies `TagflowDocumentPatch` updates
  over the same four streaming fractions, and emits viewport, update,
  update-latency, and scroll payloads for apples-to-apples local comparison
  against the full-reparse `tagflow_semantic` lane.
- The HTML adapter now supports `TagflowHtmlNodeIdStrategy.attribute()` for
  controlled producers that can emit stable `data-tagflow-id` values, plus a
  strict no-fallback mode that fails on unannotated nodes instead of silently
  mixing authored and path IDs.
- The authored-ID insertion scenario has landed for controlled dynamic HTML.
  It compares identity-preserving full reparses against equivalent ordered
  document patch updates on the same semantic benchmark surface, and the
  repeat-3, repeat-5, and attribution-enabled repeat-5 ordered-insertion review
  notes are now recorded under `docs/benchmarks/baselines/`.
  Keep the result report-only: it is bounded evidence, not a threshold update
  or faster/slower claim. The first repeat-5 run surfaced report-only
  update-path outliers in both lanes; the attribution-enabled rerun completed
  without report-only findings and identified concrete `settle`-phase worst
  attributed frames.
- Fair native competitor adapters for `flutter_html` plus
  `flutter_html_table`, and `flutter_widget_from_html` through
  `flutter_widget_from_html_core`, are committed with local smoke evidence.
- The `integration_test plugin was not detected` warning is suppressed for the
  `flutter drive` profile harness with
  `INTEGRATION_TEST_SHOULD_REPORT_RESULTS_TO_NATIVE=false`; benchmark JSON still
  comes from the VM-service `integrationDriver()` response path.

### Wave 3: Runtime Features for Alpha

- Status: alpha runtime complete, post-alpha stabilization open.
- Policy enforcement, semantic rendering, links, lists, code, blockquotes,
  images, and tables exist for the alpha supported set.
- The first-party table package now has a semantic registry fragment, inline
  cell-flow parity, normalized presentation hints, and horizontal cell
  alignment, but legacy HTML/CSS styling parity remains incomplete.
- The first immutable document patch-update slice has landed for replace,
  append, remove, and ordered insertion operations. Patch-based streaming
  benchmark smoke evidence has landed; HTML adapter authored-ID strategy has
  landed for controlled dynamic HTML; the authored-ID ordered-insertion
  benchmark pair and bounded repeat-3/repeat-5 attribution evidence have
  landed. Native block patch adaptation now maps replace, append-children,
  insert-before, and remove operations into the same immutable runtime patch
  model for app/CMS/AI producers with stable block IDs. Native JSON patch
  envelopes now decode through `TagflowNativeBlockPatchEnvelope` and adapt
  through `TagflowNativeBlockAdapter.adaptPatches(...)`. Document caching,
  citations, optional actions, broader serializer helpers, CMS sync, and any
  dedicated callout renderer remain later work. They are not beta blockers
  without new real-app evidence.

### Wave 4: Migration and Internal App Trial

- Integrate the alpha API into one internal Flutter app content surface.
- Record missing primitives, performance issues, and awkward API points.
- Update migration docs based on the real integration.
- Do not graduate to stable until this trial is complete.

### Wave 5: Release Hardening

- Status: alpha.3 published, pre-beta hardening active, not stable-ready.
- `dart run melos run validate` has passed on the coordinator branch after the
  post-alpha3 API and benchmark documentation updates. `publish:dry-run` passed
  for the alpha3 release handoff before publication.
- Local benchmark baselines and repeat-5 profile summaries exist.
- Do not treat profile timings, bounded memory files, or local desktop runs as
  release claims until reference-runner baselines, memory snapshot review, and
  threshold policy are promoted together.

### Wave 6: Alpha.4 / Pre-Beta Hardening

- Status: active coordination.
- The pauseable profile benchmark checkpoint path is implemented. Local macOS
  memory/allocation evidence now includes named hold-open checkpoint exports,
  retained-path samples, and raw heap/class-diff reviews for the scoped
  authored-insertion, `large_article`, and `table_stress` lanes. This remains
  report-only until physical-target, real-app, reference-environment, repeat,
  and wording-policy gates are reviewed together.
- The beta public API freeze review is refreshed against the current
  coordinator exports from `package:tagflow/tagflow.dart`,
  `package:tagflow/legacy.dart`, and the first-party `tagflow_table`
  extension. The reviewed style and table export blockers are resolved; live
  production-route and supported-target evidence remain open.
- Keep Kite hosted-alpha validation as downstream evidence, but do not count
  the current local Kite commit as pushed or release-grade profile evidence
  while GitLab DNS/network and physical-device profile blockers remain open.
- Keep physical-device profile work to one-repeat qualification probes until a
  target can be signed, installed, launched, and shown to produce the copied
  integration artifact. The latest iOS probe is a signing blocker, not a
  performance result.
- Do not publish, tag, or bump versions from this wave without a separate
  release gate review.

## Branch and Thread Policy

- Master thread owns planning, review gates, and final integration choices.
- Worker threads use worktrees and must not edit unrelated files.
- Worker outputs should be docs/memos first unless explicitly assigned code.
- Implementation threads should have disjoint file ownership.
- Use conventional commits for committed work.

## Active Implementation Threads

### Competitor Benchmark Adapters

- Thread ID: `019eb525-170f-7380-a753-62f242cb02f0`
- Worktree: `/Users/arya/.codex/worktrees/5829/tagflow`
- Status: `flutter_html` landed in `1437d95 feat(benchmarks): add flutter_html
  profile adapter`; `flutter_widget_from_html` now lands through
  `flutter_widget_from_html_core` for the current deterministic HTML fixtures.
- Remaining follow-up: revisit the full enhanced package only if benchmark
  fixtures adopt audio, video, SVG, or iframe content that requires those
  mixins for a fair comparison.

### Broader Benchmark Fixtures

- Thread ID: `019eb53c-12a1-7223-847a-41a12817b025`
- Worktree: `/Users/arya/.codex/worktrees/7bf4/tagflow`
- Status: integrated in the table-stress fixture baseline slice.
- Result: `table_stress` is registered in the benchmark manifest and example
  profile fixture list; fixture, parser, render, and Tagflow profile smoke
  commands passed on the coordinator branch after macOS SPM cleanup.

### Profile Benchmark Warning Diagnosis

- Thread ID: `019eb530-0400-7c62-8211-834b5e8fe0f3`
- Worktree: `/Users/arya/.codex/worktrees/bdde/tagflow`
- Status: integrated as `daf32d8 fix(benchmarks): suppress macos integration
  warning`.
- Follow-up: the separate CocoaPods/SPM migration warning was resolved by
  `564709b fix(benchmarks): remove macos CocoaPods integration`.

### macOS SPM/CocoaPods Warning Diagnosis

- Thread ID: `019eb53c-5f21-7df0-828b-9dcba2373bf7`
- Worktree: `/Users/arya/.codex/worktrees/0b21/tagflow`
- Status: integrated as `564709b fix(benchmarks): remove macos CocoaPods
  integration`.
- Result: the example macOS host now follows the generated Swift Package plugin
  path only; `flutter pub get`, example analysis, and a profile benchmark run
  passed in the worker, and the CocoaPods/SPM warning was not observed.

### Markdown Benchmark Lane

- Thread ID: `019eb61c-8f87-7090-99c9-eea06bb25588`
- Worktree: `/Users/arya/.codex/worktrees/1f3a/tagflow`
- Status: integrated as `e21e573 feat(benchmarks): add markdown renderer lane`.
- Result: the example benchmark harness now models fixture source type
  explicitly, exposes `ai_answer_rich_md`, filters manual renderer choices by
  compatible source type, and rejects invalid renderer/fixture pairs with a
  direct `StateError`.
- Validation: example analysis passed; focused benchmark fixture, registry,
  host, and screen tests passed; profile-mode macOS smokes passed for
  `TAGFLOW_RENDERER=flutter_markdown_plus TAGFLOW_FIXTURE=ai_answer_rich_md`
  and `TAGFLOW_RENDERER=markdown_widget TAGFLOW_FIXTURE=ai_answer_rich_md`.

### Reference Runner Policy

- Status: collection-completeness and viewport-guard gates exist, while
  performance thresholds remain intentionally inactive.
- Decision: the current macOS repeat-5 matrix is stabilization evidence, not
  claim-grade evidence. Claim-grade performance copy requires a promoted stable
  reference environment, pinned viewport/display conditions, and an explicit
  threshold review after a complete repeat-5 matrix.
- Policy home:
  `docs/benchmarks/2026-06-11-reference-runner-baseline-plan.md`.

### Memory Checkpoint Harness

- Pending worktree: `local:43f33e18-8a59-4457-8028-4732d9071c13`
- Thread ID: `019eb905-172d-74a0-9a65-de8a56597f80`
- Status: integrated as
  `ffbb9bd feat(benchmarks): add profile checkpoint hold mode`; archived after
  handoff.
- Result: the profile baseline runner now supports opt-in checkpoint holds via
  `TAGFLOW_PROFILE_HOLD_OPEN=true`, `TAGFLOW_PROFILE_HOLD_OPEN_SECONDS=<n>`,
  `--profile-hold-open=true`, and `--profile-hold-open-seconds=<n>`. The
  example profile harness replays named post-measurement checkpoints so
  DevTools can attach to a still-live VM service for manual snapshot or
  allocation-diff export.
- Constraints: default profile benchmark behavior must remain unchanged; output
  stays under ignored `build/`; all interpretation remains report-only.

### Memory Evidence Manifest Automation

- Status: integrated as
  `3eb7b9b feat(benchmarks): emit memory evidence checkpoints`, with the
  real-harness smoke recorded as
  `fe28a17 docs(benchmarks): record memory manifest smoke`.
- Result: hold-open profile runs now write
  `memory-evidence-manifest.json` and link it from the profile manifest as
  `memoryEvidenceManifestPath`. The manifest records VM service URIs, bounded
  memory sample status, headless DevTools memory-profile command targets, named
  checkpoints, and expected manual export filenames for heap snapshots,
  allocation diffs, and retained-object notes. It now also includes
  per-checkpoint `benchmark:memory-evidence:export` command metadata for
  report-only VM-service allocation profiles and heap class summaries.
- Latest smoke: `2026-06-12-memory-manifest-smoke` ran
  `tagflow:large_article` once on local macOS with
  `TAGFLOW_PROFILE_MEMORY=true`, `TAGFLOW_PROFILE_HOLD_OPEN=true`, and
  `TAGFLOW_PROFILE_HOLD_OPEN_SECONDS=1`. Summary generation and the sequential
  `TAGFLOW_PROFILE_MIN_REPEATS=1` check passed. The checker still emitted the
  expected report-only `memory_allocation_evidence_required` finding.
- Constraint: the generated manifest is a capture checklist, not memory
  evidence. Heap snapshots, allocation diffs, and retained-object review remain
  manual exports under ignored `build/`.
- Follow-up resolved: future profile manifests mirror
  `environment.gitCommit` into the top-level `gitCommit` field so reviewed
  artifacts do not lose commit identity at the manifest summary level.
- Latest live exporter smoke:
  `2026-06-12-memory-vm-service-exporter-smoke.md` validates
  `benchmark:memory-evidence:export` against a real hold-open
  `tagflow:large_article` profile target. The remaining harness friction is
  addressed by streaming child process output from the profile baseline
  runner, so future hold-open runs can expose VM service URIs while checkpoint
  holds are still active instead of requiring process-table discovery. The
  streaming smoke is recorded in
  `2026-06-12-streamed-profile-output-smoke.md`.

### Beta API Freeze Delta Review

- Pending worktree: `local:12f4b669-48b4-4602-8451-cc52bf2e2264`
- Thread ID: `019eb905-188b-78f3-9086-ab95002753c8`
- Status: integrated as `697f5b2 docs(spec): refresh beta api freeze review`;
  archived after handoff.
- Result: beta review now distinguishes published alpha.3 from coordinator
  `HEAD`, keeps hosted Kite evidence as widget-test evidence only, and
  initially named two public-surface blockers. Follow-up commits
  `42e6c7a refactor(api): promote shared style primitives` and
  `a4861dd refactor(table): narrow public table exports` resolve those blockers
  by promoting shared style primitives through the primary style surface and
  narrowing the `tagflow_table` barrel to the semantic extension surface,
  `TagflowTableBorder`, and legacy compatibility converters.
- Constraints: no beta release language, tags, package-version changes, or
  performance claims.

### Kite Hosted Alpha3 Reconciliation

- Pending worktree: `local:e200a636-dd09-4659-9fa6-45cc57dd1e1f`
- Thread ID: `019eb906-47fd-7543-a6b2-5349f2e5aa00`
- Status: complete; archived after handoff.
- Result: hosted-alpha3 validation remains clean locally, but GitLab push is
  blocked by DNS for `gitlab.zerodha.tech`. Recommended next Kite code slice is
  content-only IPO rendering through `Tagflow.html(..., registry: ...)` while
  leaving the excerpt path on the legacy bridge.
- Constraints: no local Tagflow path overrides, diagnostics screens, broad Kite
  rewrites, or release-grade profile claims while network and physical-device
  blockers remain open.

### Kite IPO Registry Content Branch

- Branch: `codex/ipo-tagflow-registry-content`
- Status: local branch tip `6d0d29f8 test(ipo): avoid tagflow table internals`;
  not pushed while `gitlab.zerodha.tech` DNS resolution is unavailable.
- Result: `e26a14e6 feat(ipo): render ipo content through tagflow registry`
  prepares the content-only production migration to
  `Tagflow.html(..., registry: ...)`; `6d0d29f8` keeps downstream test coverage
  on public behavior and public `tagflowTableComponents(...)` instead of
  low-level table widget exports.
- Constraints: not profile evidence until pushed, merged, opened through a real
  app route, and profiled on a supported physical or approved reference target.

### Physical Profile Qualification

- Status: blocked by current target/signing state, not by missing Tagflow
  harness code.
- Latest evidence:
  `0318a1c docs(benchmarks): refresh physical target status` recorded the
  wireless/offline iOS disagreement and missing Android target. Later
  `de2d9ec docs(benchmarks): record ios physical signing blocker` records a
  bounded one-repeat probe on `00008150-00110C960186401C` for
  `tagflow_native_json:native_ai_answer`; the runner wrote a failed manifest,
  but Xcode could not sign `dev.aryak.tagflow` for team `7573STCA2W`, no
  `Runner.app` was produced, and no integration artifact or runtime metric was
  collected.
- Current gate refresh:
  `flutter devices` still lists the iPhone 17 and iPad only as wireless
  targets, `xctrace` still lists those physical UDIDs offline, and
  `adb devices -l` reports no attached Android devices when platform-tools is
  placed on `PATH`.
- Next action: fix iOS signing/provisioning for `dev.aryak.tagflow` or attach a
  real Android profile target, then rerun the same bounded one-repeat native
  JSON probe. Do not run repeat-5 until the one-repeat probe installs, launches,
  and produces the copied integration artifact.

### Package Discovery Surface

- Status: documented as `e147dff docs(release): record pub discovery posture`.
- Result: pub.dev default discovery still points at stable `tagflow` `0.0.8`
  and `tagflow_table` `0.0.4+5`, so search/default package-page metadata can
  look HTML-first while the native runtime line is prerelease-only.
- Constraint: downstream validation must explicitly depend on
  `tagflow: ^1.0.0-alpha.3` and `tagflow_table: ^1.0.0-alpha.1`; do not promote
  beta or stable just to fix discovery.

## Alpha Decisions

- The primary alpha APIs are constructor-based:
  `Tagflow.html(...)` for HTML adapter input and `Tagflow.document(...)` for
  native runtime documents.
- `TagflowDocument` and `TagflowDocumentNode` are the alpha runtime model.
  Legacy `TagflowNode` remains available through `package:tagflow/legacy.dart`.
- Table rendering remains a separate first-party package for the alpha line,
  with compatibility through the legacy converter bridge. The native semantic
  table registry is the forward path, but full HTML/CSS styling parity is not
  complete yet.
- Benchmark fixtures, parser microbenchmarks, widget render benchmarks, and
  profile smoke runs are local alpha harnesses. The profile checker now has a
  report-only policy fixture for repeat count and candidate viewport
  invariants. Production benchmark claims still need a stable reference
  environment, supported real-app target evidence, and reviewed numeric
  thresholds.
- Internal app validation remains a release gate before promoting beyond alpha.

## Master Acceptance Criteria

- A committed architecture SPEC exists. Done.
- A committed benchmark SPEC exists. Done.
- A current-code audit has been reviewed. Done.
- A release/docs plan exists. Done.
- First implementation waves have tests and validation. Done for alpha.
- Benchmark harness records baseline Tagflow numbers before major rewrites.
  Done for parser/render/profile smoke; `flutter_html` and core-backed
  `flutter_widget_from_html` comparisons landed; the markdown-only
  `flutter_markdown_plus` and `markdown_widget` lane landed; `table_stress` is
  in the deterministic corpus; a complete local macOS repeat-5 reference
  baseline, report-only checker policy, and report-only HTML raw
  heap/class-diff interpretation exist. Stable reference-machine selection,
  supported physical targets, real-app production profiling, and numeric
  regression thresholds are still in progress.
- `1.0.0-alpha.3` is published and usable as the current native-runtime
  prerelease line. The next target is alpha.4 or pre-beta gate review; beta and
  stable still wait for the real-app, physical/reference-target benchmark, and
  wording-policy gates above.
