# Tagflow v1 Alpha Acceptance Status

This tracker records the coordination state for the `1.0.0-alpha.1` native
rich content runtime line.

Snapshot:

- Branch: `codex/tagflow-native-runtime-master`
- Snapshot commit: `b889b15 feat(tagflow): route html entrypoints through semantic runtime`
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
```

The benchmark harness is real but still alpha-grade:

- parser and widget-test render benchmarks are reproducible locally
- generated JSON artifacts stay ignored under `packages/tagflow_benchmarks/build/`
- direct Dart CLI execution is not valid yet because the benchmark package
  imports Flutter-facing Tagflow code and plain Dart has no `dart:ui`
- profile-mode frame timing and competitor comparisons remain later benchmark
  slices

## Current Integration Queue

1. Review the `1.0.0-alpha.1` release-prep metadata/docs slice.
2. Before any publish tag, re-run publish dry-run validation from the final
   release branch.
3. Push only the package-specific release tags after the final release review
   accepts the alpha package metadata.

## Known Non-Completion Points

- Custom legacy converters passed to HTML entry points still intentionally use
  the compatibility legacy bridge after `TagflowHtmlAdapter` parsing, so apps
  with converter extensions keep their existing behavior while built-in HTML
  uses the semantic runtime.
- Root full validation has a known unrelated issue when the empty
  `examples/tagflow/test/` directory causes Melos to select the example package
  for coverage without test files.
