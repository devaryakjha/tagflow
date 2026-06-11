# Tagflow v1 Alpha Acceptance Status

This tracker records the coordination state for the `1.0.0-alpha.1` native
rich content runtime line.

Snapshot:

- Branch: `codex/tagflow-native-runtime-master`
- Snapshot commit: `da6de66 feat(tagflow): split view options from html boundaries`
- Spec source: `docs/specs/2026-06-11-native-rich-content-runtime.md`
- Status date: 2026-06-11

## Acceptance Criteria

| # | Criterion | Current Status | Evidence / Owner |
| ---: | --- | --- | --- |
| 1 | Public `TagflowDocument` model exists and is canonical renderer input. | Mostly done | `TagflowDocument` and `Tagflow.document(...)` exist; document path renders through `TagflowComponentRegistry`. |
| 2 | Public `TagflowHtmlAdapter` exists and is canonical HTML entry point. | Mostly done | `TagflowHtmlAdapter` exists; docs now steer new HTML usage to `Tagflow.html(...)` and adapter parsing. |
| 3 | `Tagflow.html(...)` renders through the new document runtime for the built-in supported feature set. | Incomplete | Compatibility path still preserves legacy HTML rendering for safety. Needs semantic runtime parity before switching built-ins fully. |
| 4 | Built-in feature set covers headings, paragraphs, emphasis, links, lists, blockquotes, code, images, and tables. | Mostly done | `26200be` adds semantic renderer tests for emphasis hints, links, ordered/unordered lists, blockquote/code treatment, image option wiring, and simple tables. Emphasis still relies on adapter hints instead of a first-class runtime model. |
| 5 | Public `TagflowContentPolicy` exists with safe defaults and tests. | Mostly done | Content policy and unsafe-content tests exist from the adapter/policy slice. |
| 6 | Semantic `TagflowComponentRegistry` exists and can override a built-in renderer. | Done | Registry exists, is public, and `Tagflow.document(..., registry:)` tests prove override behavior. |
| 7 | Render-boundary behavior still works for HTML input. | Done | `da6de66` adds `Tagflow.html(..., renderBoundary: ...)` coverage and proves legacy `TagflowOptions(renderBoundary: ...)` still works. |
| 8 | Public API separates runtime view options from HTML-adapter options. | Mostly done | `da6de66` adds `TagflowViewOptions`, keeps `TagflowOptions` as a compatibility wrapper, and removes `renderBoundary` from the runtime view-options surface. |
| 9 | Package exports are curated so new adopters do not import internals accidentally. | Incomplete | Export curation was intentionally deferred to keep the API/options checkpoint reviewable. `packages/tagflow/lib/tagflow.dart` still exports broad internals. |
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

1. Curate package exports and add a deliberate legacy barrel so alpha adopters
   do not import parser/converter internals by accident.
2. Decide whether emphasis/strong should become first-class runtime semantics
   or remain an adapter-hint bridge for `1.0.0-alpha.1`.
3. Switch `Tagflow.html(...)` from the compatibility legacy bridge to semantic
   registry rendering once the built-in parity decision is accepted.
4. Re-run package-level validation and benchmarks after export/runtime routing
   changes.
5. Re-audit criteria 3, 4, and 9 before any alpha version bump.

## Known Non-Completion Points

- `Tagflow.html(...)` still renders through the legacy bridge for compatibility
  after parsing into `TagflowDocument`; semantic registry rendering is proven
  for `Tagflow.document(...)`.
- Semantic inline emphasis needs either first-class runtime representation or a
  deliberately documented adapter-hint bridge.
- Public API curation is not complete until `tagflow.dart` stops exporting broad
  parser/converter/core internals directly.
- Root full validation has a known unrelated issue when the empty
  `examples/tagflow/test/` directory causes Melos to select the example package
  for coverage without test files.
