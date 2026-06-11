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
- A worker validation pass in `/Users/arya/.codex/worktrees/72c9/tagflow`
  passed `flutter pub get`, `dart run melos bootstrap`, and
  `dart run melos run validate`.

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

Docs/release changes required before `1.0.0-alpha.1`:

- Rewrite root `README.md` away from "Flutter HTML rendering engine" framing.
- Rewrite `packages/tagflow/README.md` around alpha positioning, current install
  instructions, and migration notes.
- Rewrite `packages/tagflow_table/README.md` as an extension package for the
  runtime.
- Update `packages/tagflow/pubspec.yaml` and
  `packages/tagflow_table/pubspec.yaml` descriptions.
- Split `ROADMAP.md` into alpha scope, post-alpha, and not-promised-yet.
- Add `1.0.0-alpha.1` entries to root and package changelogs when release work
  starts.
- Add Makefile/Melos lanes for alpha/beta/rc versioning; `dev` and `stable`
  lanes are not enough for this release line.

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

- Merge worker SPECs into a single master architecture decision.
- Add a benchmark plan before any performance claims.
- Run current validation commands and record baseline failures, if any.
- Decide whether `docs/specs/` remains the canonical SPEC location.

### Wave 1: Public Contract Skeleton

- Introduce public document/content types behind tests.
- Add HTML adapter entry point while keeping old `Tagflow(html: ...)` behavior
  as a compatibility shim if feasible.
- Define content policy interfaces without overbuilding sanitization.
- Add registry boundaries for app-owned components and existing converters.

### Wave 2: Benchmark Harness

- Add fixtures and first local benchmark commands.
- Measure current Tagflow before major rewrites.
- Add competitor harness only where automated comparison is fair.
- Publish benchmark methodology in docs before publishing results.

### Wave 3: Runtime Features for Alpha

- Implement policy enforcement for tags, attributes, URL schemes, and image
  handling.
- Add document caching by content hash or caller-supplied cache key.
- Add AI/CMS-oriented primitives only if represented in the document model:
  callouts, citations, code blocks, tables, links, and optional actions.
- Keep streaming/incremental rendering narrow: append block-level content before
  attempting arbitrary partial HTML.

### Wave 4: Migration and Internal App Trial

- Integrate the alpha API into one internal Flutter app content surface.
- Record missing primitives, performance issues, and awkward API points.
- Update migration docs based on the real integration.
- Do not graduate to stable until this trial is complete.

### Wave 5: Release Hardening

- Run `melos run validate`.
- Run benchmark suite and record output.
- Update README, package README, ROADMAP, CHANGELOG, and pubspec descriptions.
- Publish `1.0.0-alpha.1` only after docs and benchmark methodology are in repo.

## Branch and Thread Policy

- Master thread owns planning, review gates, and final integration choices.
- Worker threads use worktrees and must not edit unrelated files.
- Worker outputs should be docs/memos first unless explicitly assigned code.
- Implementation threads should have disjoint file ownership.
- Use conventional commits for committed work.

## Active Implementation Threads

### Runtime Contract Skeleton

- Thread ID: `019eb492-a270-74c0-a723-dd6716a25f06`
- Worktree: `/Users/arya/.codex/worktrees/d5cb/tagflow`
- Ownership: new runtime/document/policy API skeleton under
  `packages/tagflow/lib/src/`, exports, and focused tests under
  `packages/tagflow/test/src/`.
- Exclusions: docs, benchmark package, example app, release metadata, broad
  parser/converter rewrites.

### Benchmark Foundation

- Thread ID: `019eb492-ea8a-74e3-ba81-178120b0bb5f`
- Worktree: `/Users/arya/.codex/worktrees/576f/tagflow`
- Ownership: `packages/tagflow_benchmarks/**`, benchmark fixture corpus, parser
  microbench runner, `docs/benchmarks/baselines/.gitkeep`, and root workspace
  benchmark scripts only as needed.
- Exclusions: runtime API implementation files, existing package source, release
  docs, and example app.

## Alpha Decisions

- The primary alpha APIs are constructor-based:
  `Tagflow.html(...)` for HTML adapter input and `Tagflow.document(...)` for
  native runtime documents.
- `TagflowDocument` and `TagflowDocumentNode` are the alpha runtime model.
  Legacy `TagflowNode` remains available through `package:tagflow/legacy.dart`.
- Table rendering remains a separate first-party package for the alpha line,
  with compatibility through the legacy converter bridge.
- Benchmark fixtures, parser microbenchmarks, and widget render benchmarks are
  local alpha harnesses. Production benchmark claims still need later
  profile-mode and comparison work.
- Internal app validation remains a release gate before promoting beyond alpha.

## Master Acceptance Criteria

- A committed architecture SPEC exists.
- A committed benchmark SPEC exists.
- A current-code audit has been reviewed.
- A release/docs plan exists.
- First implementation wave has a task-level plan with tests and validation.
- Benchmark harness records baseline Tagflow numbers before major rewrites.
- `1.0.0-alpha.1` is not published until internal app validation is complete.
