# Tagflow v1 Alpha Acceptance Status

This tracker records the coordination state for the `1.0.0-alpha.1` native
rich content runtime line.

Snapshot:

- Branch: `codex/tagflow-native-runtime-master`
- Snapshot commit: `226ea22 feat(benchmarks): add profile benchmark scaffold`
- Spec source: `docs/specs/2026-06-11-native-rich-content-runtime.md`
- Status date: 2026-06-11

## Acceptance Criteria

| # | Criterion | Current Status | Evidence / Owner |
| ---: | --- | --- | --- |
| 1 | Public `TagflowDocument` model exists and is canonical renderer input. | Done | `TagflowDocument` powers `Tagflow.document(...)`; `b889b15` routes built-in HTML entry points through the same document/runtime render path. |
| 2 | Public `TagflowHtmlAdapter` exists and is canonical HTML entry point. | Done | `TagflowHtmlAdapter` exists; `Tagflow.html(...)` and legacy `Tagflow(html: ...)` parse through it before semantic rendering, with a deliberate legacy-converter compatibility path. |
| 3 | `Tagflow.html(...)` renders through the new document runtime for the built-in supported feature set. | Done | HTML entry points now parse through `TagflowHtmlAdapter` into `TagflowDocument` and render built-ins through `TagflowComponentRegistry.builtIn`; focused widget tests cover semantic routing, inline semantics, render boundaries, and custom legacy converter compatibility. |
| 4 | Built-in feature set covers headings, paragraphs, emphasis, links, lists, blockquotes, code, images, and tables. | Done | `26200be` adds semantic renderer coverage for the built-in feature set; `e7898f3` adds first-class `TagflowInlineSemantic` presentation for emphasis/strong and related inline semantics while preserving legacy fallback hints. |
| 5 | Public `TagflowContentPolicy` exists with safe defaults and tests. | Done | Content policy and unsafe-content tests exist from the adapter/policy slice, and HTML entry points now use the adapter path by default. |
| 6 | Semantic `TagflowComponentRegistry` exists and can override a built-in renderer. | Done | Registry exists, is public, and `Tagflow.document(..., registry:)` tests prove override behavior. |
| 7 | Render-boundary behavior still works for HTML input. | Done | `da6de66` adds `Tagflow.html(..., renderBoundary: ...)` coverage and proves legacy `TagflowOptions(renderBoundary: ...)` still works. |
| 8 | Public API separates runtime view options from HTML-adapter options. | Done | `da6de66` adds `TagflowViewOptions`, keeps `TagflowOptions` as a compatibility wrapper, and removes `renderBoundary` from the runtime view-options surface. |
| 9 | Package exports are curated so new adopters do not import internals accidentally. | Done | `packages/tagflow/lib/tagflow.dart` now exports the alpha-facing runtime API, while parser/converter/core compatibility surfaces moved to `package:tagflow/legacy.dart`; `test/src/public_api/export_test.dart` covers both barrels. |
| 10 | Migration document exists from `0.0.x` HTML-first usage to alpha runtime. | Done | `docs/migration/2026-06-11-tagflow-v1-alpha-migration.md`. |

## Benchmark Status

Current local benchmark evidence is recorded in
`docs/benchmarks/baselines/2026-06-11-local-alpha-baseline.md`.

Passed commands on this branch:

```bash
dart format --set-exit-if-changed packages/tagflow/lib/src/render/component_registry.dart packages/tagflow/test/src/render/component_registry_test.dart packages/tagflow/lib/src/adapters/html_adapter.dart packages/tagflow/lib/src/tagflow_options.dart packages/tagflow/lib/src/tagflow_widget.dart packages/tagflow/test/src/runtime/html_adapter_widget_test.dart packages/tagflow/test/src/tagflow_options_test.dart
flutter analyze
flutter test test/src/render test/src/runtime test/src/tagflow_options_test.dart
flutter test
cd ../tagflow_table && flutter analyze && flutter test
cd ../tagflow_benchmarks && flutter analyze && flutter test
dart run melos run benchmark:fixtures
dart run melos run benchmark:micro
dart run melos run benchmark:render
dart run melos run publish:dry-run
dart run melos run validate
```

The benchmark harness is real but still alpha-grade:

- parser and widget-test render benchmarks are reproducible locally
- generated JSON artifacts stay ignored under `packages/tagflow_benchmarks/build/`
- direct Dart CLI execution is not valid yet because the benchmark package
  imports Flutter-facing Tagflow code and plain Dart has no `dart:ui`
- profile-mode frame timing and competitor comparisons remain later benchmark
  slices

## Current Integration Queue

1. Release review can decide whether to push the package-specific alpha tags:
   `tagflow-v1.0.0-alpha.1` and `tagflow_table-v1.0.0-alpha.1`.
2. After tags are pushed, watch the package-specific GitHub Actions publish
   workflows and verify both packages appear on pub.dev.

## Release Prep Status

- `packages/tagflow` is set to `1.0.0-alpha.1` and describes Tagflow as a
  native rich content runtime with HTML support through a first-party adapter.
- `packages/tagflow_table` is set to `1.0.0-alpha.1` because it is a
  publishable first-party extension constrained to the breaking alpha core line.
- Workspace consumers in `examples/tagflow` and `packages/tagflow_benchmarks`
  use `^1.0.0-alpha.1` constraints.
- `publish:dry-run` runs `dart run melos publish --no-private --yes`, keeping
  publish validation non-interactive while still using Melos dry-run mode.
- Fresh coordinator evidence: `dart run melos run publish:dry-run`, with
  `/Users/arya/fvm/cache.git/bin` on `PATH`, validates both `tagflow` and
  `tagflow_table` with 0 warnings.
- Fresh coordinator evidence: `dart run melos run validate`, with
  `/Users/arya/fvm/cache.git/bin` on `PATH`, passes analysis, format checks,
  and coverage tests for `tagflow`, `tagflow_table`, and
  `tagflow_benchmarks`.
- The local alpha benchmark baseline now reports package version
  `1.0.0-alpha.1`.
- Independent release-audit worker `019eb4f5-b537-7f40-bd1c-1fc301265129`
  refreshed to `4df25cd` and reported `DONE` / `ready`: `git status
  --short --branch`, `git diff --check`, `dart run melos run validate`, and
  `dart run melos run publish:dry-run` all passed, with both packages
  validating at 0 warnings and no files changed in the audit worktree.

## Post-Alpha Stabilization Progress

- `tagflow_table` now exposes `tagflowTableComponents(...)`, a first-party
  semantic registry fragment for rendering native `TagflowDocument` table nodes
  through the package's custom `TagflowTable` render object. The legacy HTML
  converter bridge remains available during alpha.
- The example app now has a Tagflow-only benchmark route plus
  `integration_test`/`flutter drive --profile` scaffold. The profile harness
  accepts `TAGFLOW_RENDERER` and `TAGFLOW_FIXTURE` environment variables so
  competitor adapters can plug into the same result path. `dart run melos run
  benchmark:profile` passed locally on macOS and wrote ignored frame timing
  output to `examples/tagflow/build/integration_response_data.json`.

## Known Non-Completion Points

- Custom legacy converters passed to HTML entry points still intentionally use
  the compatibility legacy bridge after `TagflowHtmlAdapter` parsing, so apps
  with converter extensions keep their existing behavior while built-in HTML
  uses the semantic runtime.
- The first-party table extension has a semantic registry fragment, but the
  legacy HTML converter bridge has not been fully removed or replaced.
- Profile benchmarking is real but not production-grade yet: competitor
  adapters, additional fixtures, nightly/reference-runner baselines, and the
  current Flutter `integration_test plugin was not detected` warning remain
  follow-up work before using frame timings as a release gate.
