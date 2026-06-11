# Tagflow v1 Alpha Benchmark Spec

## Status

- Date: 2026-06-11
- Scope: planning only, no harness implementation in this worker
- Audience: Tagflow maintainers preparing v1 alpha performance validation

## Repo Facts This Plan Assumes

- The workspace is a Melos monorepo declared in the root [pubspec.yaml](../../pubspec.yaml) with three members today: `packages/tagflow`, `packages/tagflow_table`, and `examples/tagflow`.
- CI currently runs dependency install, `dart run melos bootstrap`, and `dart run melos run validate` on `ubuntu-latest` from [`.github/workflows/ci.yml`](../../.github/workflows/ci.yml).
- The example app already has multiple routed demo screens in [examples/tagflow/lib/utils/router.dart](../../examples/tagflow/lib/utils/router.dart) and is the obvious host for profile-mode rendering scenarios.
- The roadmap already calls out unchecked items for performance benchmarks and a performance profiling page in [ROADMAP.md](../../ROADMAP.md).

## Goal

Make Tagflow performance measurable, reproducible, and comparable for the product it is actually becoming: a native rich-content runtime for Flutter apps rendering AI, CMS, and server-authored content.

## Non-Goals

- Chasing arbitrary browser-fidelity benchmarks.
- Publishing a single vanity number such as "X% faster".
- Treating WebView as a direct parser/converter competitor.
- Gating alpha releases on noisy hosted-runner frame timings.

## Recommendation

Use a combination, not a single location:

1. A new internal workspace package for deterministic fixtures, adapters, result schema, and microbench runners.
2. The existing example app for profile-mode frame and scroll benchmarks.
3. `integration_test` plus a `test_driver` for machine-readable profile results.
4. DevTools manual playbooks for memory and CPU deep dives that are too noisy or invasive to make CI-gated in alpha.

This split keeps pure parsing/conversion benchmarks fast and deterministic while still measuring real Flutter frame behavior in a host app.

## Proposed Layout

### New internal package

Create `packages/tagflow_benchmarks` as a non-publishable Flutter package and add it to the root workspace.

Proposed files:

- `packages/tagflow_benchmarks/pubspec.yaml`
- `packages/tagflow_benchmarks/lib/src/fixtures/fixture_manifest.dart`
- `packages/tagflow_benchmarks/lib/src/fixtures/html/`
- `packages/tagflow_benchmarks/lib/src/fixtures/markdown/`
- `packages/tagflow_benchmarks/lib/src/results/benchmark_result.dart`
- `packages/tagflow_benchmarks/lib/src/renderers/`
- `packages/tagflow_benchmarks/bin/run_parser_benchmarks.dart`
- `packages/tagflow_benchmarks/bin/run_competitor_microbenchmarks.dart`
- `packages/tagflow_benchmarks/test/widget_build_benchmark_test.dart`
- `packages/tagflow_benchmarks/test/fixture_validity_test.dart`

Responsibilities:

- Shared benchmark fixtures.
- Deterministic parser and converter microbenchmarks.
- Renderer adapters so Tagflow and competitors consume the same logical fixture.
- JSON result output for later comparison tooling.

### Existing example app

Extend `examples/tagflow` rather than creating another app.

Proposed files:

- `examples/tagflow/lib/screens/benchmark_screen.dart` (landed)
- `examples/tagflow/lib/benchmarks/benchmark_host.dart` (landed)
- `examples/tagflow/lib/benchmarks/renderer_registry.dart` (landed)
- `examples/tagflow/lib/benchmarks/fixtures.dart` (landed)
- `examples/tagflow/integration_test/tagflow_perf_test.dart` (landed)
- `examples/tagflow/integration_test/tagflow_competitor_perf_test.dart`
- `examples/tagflow/test_driver/perf_driver.dart` (landed)

Responsibilities:

- Host real widgets in profile mode.
- Exercise scroll, build, layout, and raster behavior.
- Produce machine-readable `Timeline` or `watchPerformance` output.
- Offer a manual benchmark route for DevTools inspection.

## Fixture Corpus

All fixtures must be deterministic:

- No network images.
- No remote CSS, JS, or iframe fetches.
- No async media loading in the benchmark path.
- Stable fonts and theme.
- Local link handler stub only.

Recommended fixtures:

1. `smoke_short_html`
   - 1-2 KB
   - Simple paragraphs, headings, inline emphasis, one link
   - Purpose: sanity and lowest-noise parser baseline

2. `ai_answer_rich`
   - 8-15 KB
   - Heading, intro paragraph, callout blockquote, ordered list, unordered list, inline code, fenced code, citations footer, one compact comparison table
   - Keep paired sources:
     - `ai_answer_rich.html`
     - `ai_answer_rich.md`
   - Purpose: primary product-shaped benchmark

3. `table_dense`
   - 25 rows x 8 columns, mixed inline styles, header rows, numeric alignment
   - Purpose: standard table load

4. `table_stress`
   - 100 rows x 20 columns, rowspan/colspan cases, nested text styling
   - Purpose: large-table ceiling behavior

5. `large_article`
   - 50-100 KB
   - Repeated sections, nested lists, inline styling, code blocks, quotes
   - Purpose: large-document parse/build/scroll behavior

6. `deep_nested_lists`
   - 6+ levels mixed `ol`/`ul`
   - Purpose: selector matching, text scaling, and tree depth stress

7. `streaming_ai_chunks`
   - Four incremental payloads: 25%, 50%, 75%, 100% of `ai_answer_rich`
   - Purpose: measure full reparses now, incremental work later

## Benchmark Matrix

| Suite | Renderers | Fixtures | Metrics | Automation tier | Expected command | Pass / fail for alpha |
| --- | --- | --- | --- | --- | --- | --- |
| Parser microbench | Tagflow only | `smoke_short_html`, `ai_answer_rich`, `table_dense`, `large_article`, `deep_nested_lists`, `table_stress` | median us/op, p95 us/op, coefficient of variation, nodes/sec | PR CI + local | `dart run melos exec --scope=tagflow_benchmarks -- dart run bin/run_parser_benchmarks.dart --output=build/benchmarks/parser.json` | Pass if every fixture emits JSON, warmup is used, and CV is <= 10%. After baseline exists, fail on > 15% median regression on the same environment label. |
| Converter microbench | Tagflow only | parsed versions of all HTML fixtures | median us/op for `TagflowConverter.convert`, widget count, element count | PR CI + local | `flutter test packages/tagflow_benchmarks/test/widget_build_benchmark_test.dart --reporter expanded` | Pass if conversion succeeds for all fixtures with no exceptions and <= 15% regression after baseline. |
| Full build benchmark | Tagflow only | `ai_answer_rich`, `table_dense`, `large_article` | first stable pump ms, total build/layout ms, rebuild ms after theme noop, rebuild ms after content change | PR CI + local | `flutter test packages/tagflow_benchmarks/test/widget_build_benchmark_test.dart --dart-define=TAGFLOW_BENCH_MODE=full-build` | Pass if results emit for every fixture and no fixture exceeds 2x its stored baseline. No absolute frame budget gate in hosted CI. |
| Native frame + scroll benchmark | Tagflow, `flutter_html`, `flutter_widget_from_html` | `ai_answer_rich`, `large_article`, `table_dense` | `FrameTiming` build p50/p90/p99/worst, raster p50/p90/p99/worst, GC counts, dropped-frame count, scroll completion time | Local profile run, optional nightly CI on a stable runner | `TAGFLOW_RENDERER=tagflow TAGFLOW_FIXTURE=ai_answer_rich dart run melos run benchmark:profile` | On the reference device, pass if standard fixtures show build p90 < 8 ms, raster p90 < 8 ms, worst frame < 16 ms, and dropped frames = 0. On hosted CI, record only. |
| Table stress frame benchmark | Tagflow, `flutter_html`, `flutter_widget_from_html` | `table_stress` | same as above plus first-content-visible ms | Local profile run | `TAGFLOW_RENDERER=tagflow TAGFLOW_FIXTURE=table_stress dart run melos run benchmark:profile` | Pass if no overflow, exception, or OOM occurs and first content is visible within 1500 ms on the reference device. Treat this as release-significant. |
| Markdown product-shape comparison | Tagflow, `flutter_markdown_plus`, `markdown_widget` | `ai_answer_rich.md` | first stable pump ms, build p90, raster p90, text selection behavior check | Local + optional report CI | `TAGFLOW_RENDERER=markdown_widget TAGFLOW_FIXTURE=ai_answer_rich_md dart run melos run benchmark:profile` after markdown fixtures land | Pass if Tagflow stays within 1.5x of the fastest markdown renderer on median build time for this fixture. If slower, open an issue; do not block alpha automatically. |
| Large document stability | Tagflow, `flutter_html`, `flutter_widget_from_html` | `large_article` | peak elapsed time to first content, scroll completion, exceptions, memory notes, GC churn | Local profile + manual DevTools | `TAGFLOW_RENDERER=tagflow TAGFLOW_FIXTURE=large_article dart run melos run benchmark:profile` | Pass if the document fully renders, remains scrollable end-to-end, and shows no crash or unbounded memory growth in manual validation. |
| Streaming / incremental updates | Tagflow only for alpha | `streaming_ai_chunks` | update latency per chunk, scroll position preservation, rebuild duration, GC counts | Local only | `flutter drive --driver=examples/tagflow/test_driver/perf_driver.dart --target=examples/tagflow/integration_test/tagflow_perf_test.dart -d macos --profile --dart-define=TAGFLOW_FIXTURE=streaming_ai_chunks` | Non-gating in alpha. Pass if every chunk applies without exception and update latency is captured. |

## Competitor Comparison Policy

### Automate now

- `flutter_html` for HTML-native comparison.
- `flutter_widget_from_html` for HTML-native comparison.
- `flutter_markdown_plus` for markdown-only comparison.
- `markdown_widget` for markdown-only comparison.

### Manual or optional

- `webview_flutter` as a platform-view baseline only.
  - Use it only for:
    - first-content-visible
    - scroll smoothness
    - large-document behavior
  - Do not use it for:
    - parser cost
    - converter cost
    - native widget tree comparison

### Avoid or de-prioritize

- `flutter_markdown` itself as a baseline.
  - It is being discontinued.
- `flutter_markdown_community`.
  - It exists, but `flutter_markdown_plus` is the better maintained continuation to benchmark first.

### What would be unfair

- Comparing markdown packages against HTML fixtures that rely on inline HTML or CSS features those packages never claimed to support.
- Measuring WebView network or browser startup and calling it "HTML renderer speed".
- Leaving network images enabled for one renderer and disabled for another.
- Comparing cold, first-run JIT numbers against warmed profile-mode native runs.

## Exact Dependencies and Tools To Use

### Bench package dependencies

Recommend pinning these when implementation starts:

- `benchmark_harness: ^2.4.0`
- `flutter_html: ^3.0.0`
- `flutter_widget_from_html: ^0.17.2`
- `flutter_markdown_plus: ^1.0.7`
- `markdown_widget: ^2.3.2+8`

SDK dependencies:

- `flutter`
- `flutter_test`
- `integration_test`

Optional later:

- `webview_flutter: ^4.13.1`
- `vm_service` if heap or allocation snapshots need automation beyond DevTools

### Flutter tooling

- Use `integration_test` for real app performance tests.
- Use `IntegrationTestWidgetsFlutterBinding.watchPerformance()` for `FrameTiming` summaries.
- Keep a `flutter drive ... --profile` path for exported perf JSON.
- Use DevTools Performance view and Memory view for manual deep dives on reference devices.

## Recommended Commands

These should become Melos scripts after the first harness lands:

```bash
dart run melos run benchmark:micro
dart run melos run benchmark:render
dart run melos run benchmark:profile
TAGFLOW_RENDERER=tagflow TAGFLOW_FIXTURE=large_article dart run melos run benchmark:profile
dart run melos run benchmark:compare -- --renderer=all --fixture=ai_answer_rich
```

Suggested first concrete script bodies:

```bash
dart run melos exec --scope=tagflow_benchmarks -- dart run bin/run_parser_benchmarks.dart --output=build/benchmarks/parser.json

flutter test packages/tagflow_benchmarks/test/widget_build_benchmark_test.dart

flutter drive \
  --driver=examples/tagflow/test_driver/perf_driver.dart \
  --target=examples/tagflow/integration_test/tagflow_perf_test.dart \
  -d macos \
  --profile \
  --dart-define=TAGFLOW_RENDERER=tagflow \
  --dart-define=TAGFLOW_FIXTURE=ai_answer_rich
```

If the local Flutter/Dart toolchain still depends on the FVM cache shim in this repo setup, prepend:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH
```

## CI Strategy

### PR CI

Keep this fast and deterministic:

- fixture validity test
- parser microbench
- converter microbench
- full build benchmark in test environment
- JSON artifact upload

Do not gate PRs on hosted-runner frame timing budgets yet.

### Nightly or reference-runner CI

Add only after the local harness is stable:

- profile-mode example app perf runs
- artifact retention for timeline summaries
- trend comparison against a checked-in baseline or previous nightly

### Local reference runs

Primary recommendation for alpha:

- `macos` profile mode first

Optional second wave:

- iOS Simulator profile mode
- one physical Android device for sanity

## Result Storage

- Raw run artifacts: `build/benchmarks/<platform>/<timestamp>/`
- Reviewed baseline snapshots: `docs/benchmarks/baselines/`
- Human-readable notes: append to `docs/benchmarks/README.md` later if needed

Do not commit every raw run. Commit only approved baseline files and benchmark methodology changes.

## Risks And Unknowns

1. Hosted CI frame timings will be noisy.
   - Mitigation: gate only deterministic microbenches in PR CI; keep frame tests local or nightly at first.

2. Tagflow currently reparses on every `html` change.
   - Mitigation: keep streaming benchmarks non-gating in alpha and use them to justify incremental parsing work later.

3. Competitors do not support the same feature surface.
   - Mitigation: split HTML-native and markdown-native comparison tracks.

4. WebView is not a fair native-renderer comparator.
   - Mitigation: treat it only as a UX baseline for first-content-visible and scroll smoothness.

5. Images and async media can dominate the numbers.
   - Mitigation: benchmark text/table/code heavy fixtures first and keep media out of the deterministic suite.

6. Font loading can distort first-frame timings in the example app.
   - Mitigation: preload fonts before benchmark start and exclude app bootstrap from fixture measurements.

7. Table stress cases can hide layout bugs instead of pure perf regressions.
   - Mitigation: validate correctness first, then profile those fixtures.

## Alpha Implementation Order

1. Add `docs/benchmarks/baselines/.gitkeep` and create the new internal `packages/tagflow_benchmarks` package.
2. Add the shared fixture corpus with paired HTML and Markdown sources plus fixture validity tests.
3. Implement parser microbench and converter microbench runners for Tagflow only.
4. Add a benchmark route to the existing example app and wire `integration_test` plus `perf_driver`. (landed for Tagflow-only)
5. Implement profile-mode Tagflow frame tests for `ai_answer_rich`, `table_dense`, and `large_article`. (`ai_answer_rich` landed first)
6. Add `flutter_html` and `flutter_widget_from_html` adapters for HTML-native comparison.
7. Add `flutter_markdown_plus` and `markdown_widget` adapters for markdown-only comparison.
8. Add `webview_flutter` only after the native baselines exist, and keep it report-only.
9. Establish reviewed baselines on one reference machine and only then introduce regression thresholds.

## External References

- Flutter performance metrics: [docs.flutter.dev/perf/metrics](https://docs.flutter.dev/perf/metrics)
- Flutter profile benchmarking recipe: [docs.flutter.dev/cookbook/testing/integration/profiling](https://docs.flutter.dev/cookbook/testing/integration/profiling)
- Flutter integration testing overview: [docs.flutter.dev/cookbook/testing/integration/introduction](https://docs.flutter.dev/cookbook/testing/integration/introduction)
- Flutter `watchPerformance()`: [api.flutter.dev](https://api.flutter.dev/flutter/package-integration_test_integration_test/IntegrationTestWidgetsFlutterBinding/watchPerformance.html)
- DevTools Performance view: [docs.flutter.dev/tools/devtools/performance](https://docs.flutter.dev/tools/devtools/performance)
- DevTools Memory view: [docs.flutter.dev/tools/devtools/memory](https://docs.flutter.dev/tools/devtools/memory)
- `benchmark_harness`: [pub.dev/packages/benchmark_harness](https://pub.dev/packages/benchmark_harness)
- `flutter_html`: [pub.dev/packages/flutter_html](https://pub.dev/packages/flutter_html)
- `flutter_widget_from_html`: [pub.dev/packages/flutter_widget_from_html](https://pub.dev/packages/flutter_widget_from_html)
- `flutter_markdown_plus`: [pub.dev/packages/flutter_markdown_plus](https://pub.dev/packages/flutter_markdown_plus)
- `markdown_widget`: [pub.dev/packages/markdown_widget](https://pub.dev/packages/markdown_widget)
- `webview_flutter`: [pub.dev/packages/webview_flutter](https://pub.dev/packages/webview_flutter)
