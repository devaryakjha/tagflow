# Tagflow v1 Alpha Acceptance Status

This tracker records the coordination state for the `1.0.0-alpha.1` native
rich content runtime line.

Snapshot:

- Branch: `codex/tagflow-native-runtime-master`
- Snapshot commit: `b2e7d81 docs(benchmarks): record local alpha baseline`
- Spec source: `docs/specs/2026-06-11-native-rich-content-runtime.md`
- Status date: 2026-06-11

## Acceptance Criteria

| # | Criterion | Current Status | Evidence / Owner |
| ---: | --- | --- | --- |
| 1 | Public `TagflowDocument` model exists and is canonical renderer input. | Mostly done | `TagflowDocument` and `Tagflow.document(...)` exist; document path renders through `TagflowComponentRegistry`. |
| 2 | Public `TagflowHtmlAdapter` exists and is canonical HTML entry point. | Mostly done | `TagflowHtmlAdapter` exists; docs now steer new HTML usage to `Tagflow.html(...)` and adapter parsing. |
| 3 | `Tagflow.html(...)` renders through the new document runtime for the built-in supported feature set. | Incomplete | Compatibility path still preserves legacy HTML rendering for safety. Needs semantic runtime parity before switching built-ins fully. |
| 4 | Built-in feature set covers headings, paragraphs, emphasis, links, lists, blockquotes, code, images, and tables. | In progress | Renderer-parity worker `019eb4c7-0ce9-7093-81b3-1ab58558bef2` owns this slice. Emphasis is still a known model gap if represented only through adapter hints. |
| 5 | Public `TagflowContentPolicy` exists with safe defaults and tests. | Mostly done | Content policy and unsafe-content tests exist from the adapter/policy slice. |
| 6 | Semantic `TagflowComponentRegistry` exists and can override a built-in renderer. | Done | Registry exists, is public, and `Tagflow.document(..., registry:)` tests prove override behavior. |
| 7 | Render-boundary behavior still works for HTML input. | Needs re-verification | Legacy HTML path should preserve it. API/options worker is moving boundary responsibility to HTML-only surfaces. |
| 8 | Public API separates runtime view options from HTML-adapter options. | In progress | API worker `019eb4c6-bcde-76c1-8665-8b0e96e33851` owns `TagflowViewOptions` plus HTML-only render boundary separation. |
| 9 | Package exports are curated so new adopters do not import internals accidentally. | In progress | API worker owns main barrel curation and deliberate legacy export path. |
| 10 | Migration document exists from `0.0.x` HTML-first usage to alpha runtime. | Done | `docs/migration/2026-06-11-tagflow-v1-alpha-migration.md`. |

## Benchmark Status

Current local benchmark evidence is recorded in
`docs/benchmarks/baselines/2026-06-11-local-alpha-baseline.md`.

Passed commands on this branch:

```bash
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

1. Integrate API/options/export cleanup after worker verification.
2. Integrate semantic renderer parity after worker verification.
3. Run package-level `flutter analyze` and `flutter test` after both slices.
4. Re-run benchmark fixture, parser, and render scripts.
5. Re-audit criteria 3, 4, 7, 8, and 9 from current source before any alpha
   version bump.

## Known Non-Completion Points

- `Tagflow.html(...)` is not yet proven to render the full built-in feature set
  through the semantic runtime.
- Semantic inline emphasis needs either first-class runtime representation or a
  deliberately documented adapter-hint bridge.
- Public API curation is not complete until `tagflow.dart` stops exporting broad
  parser/converter/core internals directly.
- Root full validation has a known unrelated issue when the empty
  `examples/tagflow/test/` directory causes Melos to select the example package
  for coverage without test files.
