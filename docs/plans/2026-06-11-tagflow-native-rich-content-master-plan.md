# Tagflow Native Rich Content Runtime Master Plan

> **Master thread:** Coordinates workstreams, reviews worker outputs, assigns
> implementation waves, and keeps release gates explicit.

## Goal

Evolve Tagflow from a Flutter HTML renderer into a native rich content runtime
for Flutter apps. HTML remains a first-class adapter, but the central contract is
a safe, theme-aware document model that can render AI, CMS, and app-authored
structured content as native Flutter widgets.

## Release Target

Target the new architecture as `1.0.0-alpha.1`.

This should be a clean breaking line because current public usage appears low
and the package is still internally driven. Stable `1.0.0` should wait until a
real internal Flutter app has integrated the new model and benchmark results are
published.

## Coordinator Snapshot

- Branch: `codex/tagflow-native-runtime-master`
- Latest integrated coordinator commit before this status refresh:
  `42feeff docs(benchmarks): record ordered insertion patch baseline`
- Latest integrated implementation commits include `d0494f8 docs(benchmarks):
  record semantic streaming pair baseline`, `34ea827 feat(bench): add
  opt-in viewport gate`, `3df1b5a bench(profile): detect flutter version in
  manifests`, `c137a7b bench(profile): support custom baseline output dirs`,
  `74a9c9c bench(profile): record viewport metadata`, and `8ed0686 fix(table):
  preserve HTML table captions`.
- Alpha acceptance status: all `1.0.0-alpha.1` runtime criteria in
  `docs/plans/2026-06-11-tagflow-v1-alpha-acceptance-status.md` are marked
  done.
- Release posture: `tagflow` and `tagflow_table` are both published as
  `1.0.0-alpha.1` prereleases. Package descriptions, changelogs, READMEs,
  roadmap, and the alpha migration guide have been updated for the native rich
  content runtime line.
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
  removed from the macOS example host. The HTML adapter now also supports
  authored node ID strategies for controlled dynamic content through
  `TagflowHtmlNodeIdStrategy.attribute()`, which reads `data-tagflow-id` by
  default while preserving path IDs as the compatibility fallback.
- Post-alpha stabilization in progress: remaining table styling parity beyond
  normalized uniform table and horizontal-alignment hints, stable
  reference-environment selection, numeric regression threshold policy for
  benchmark claims, stronger repeat-5 reference-runner evidence for the landed
  authored-ID ordered-insertion pair, and profile-mode evidence on a supported
  real-app target.
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

## Current Constraints

- Repo is a Melos 7-managed Flutter monorepo with workspace and Melos
  configuration declared in the root `pubspec.yaml`.
- Root SDK constraint is `>=3.9.0 <4.0.0`.
- There is no `docs/` convention yet, so master coordination uses
  `docs/specs/` and `docs/plans/`.
- Existing public exports are broad; the alpha line must either preserve them
  deliberately or clearly mark new public API boundaries.
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
- Alpha ships HTML as the only first-party adapter; Markdown and JSON/native
  serialization are explicitly post-alpha.
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
- Whether unsupported content defaults to dropping nodes or preserving debug
  placeholders.
- Whether `TagflowOptions` is renamed to `TagflowViewOptions` during alpha.
- How much class-based styling the HTML adapter should preserve in alpha.

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
  describe the alpha runtime line and both publishable packages are versioned
  `1.0.0-alpha.1`.
- Package changelogs contain `1.0.0-alpha.1` entries.
- `docs/migration/2026-06-11-tagflow-v1-alpha-migration.md` documents the
  `0.0.x` to alpha migration.
- Melos has a `version:alpha` lane and non-interactive publish dry-run lane.

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
  repeat-3 ordered-insertion review note is now recorded in
  `docs/benchmarks/baselines/2026-06-11-authored-insertion-ordered-repeat3.md`.
  Keep the result report-only: it is bounded evidence, not a threshold update
  or faster/slower claim, and repeat-5 remains the next stronger reference
  rerun.
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
  append, and remove operations. Patch-based streaming benchmark smoke evidence
  has landed; HTML adapter authored-ID strategy has landed for controlled
  dynamic HTML; the authored-ID ordered-insertion benchmark pair and bounded
  repeat-3 review note have landed; document caching, citations, callouts, and
  optional actions remain later work unless internal app integration proves
  they are required before beta.

### Wave 4: Migration and Internal App Trial

- Integrate the alpha API into one internal Flutter app content surface.
- Record missing primitives, performance issues, and awkward API points.
- Update migration docs based on the real integration.
- Do not graduate to stable until this trial is complete.

### Wave 5: Release Hardening

- Status: alpha prerelease review-ready, not stable-ready.
- `dart run melos run validate` and `dart run melos run publish:dry-run` have
  passed on the coordinator branch.
- Local benchmark baseline exists.
- Do not treat profile timings as a release gate until reference-runner
  baselines exist.

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
  baseline and report-only checker policy exist. Stable reference-machine
  selection and numeric regression thresholds are still in progress.
- `1.0.0-alpha.1` can be treated as a prerelease candidate after release review,
  but stable `1.0.0` must wait for internal app validation.
