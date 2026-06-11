# 2026-06-11 Local Alpha Benchmark Baseline

This is a local evidence snapshot for the Tagflow native-runtime alpha branch.
It records the current benchmark harness output without committing generated
JSON artifacts from `packages/tagflow_benchmarks/build/`.

## Environment

- Branch: `codex/tagflow-native-runtime-master`
- Package version reported by harness: `1.0.0-alpha.1`
- Dart version reported by harness: `3.11.0-81.0.dev`
- Flutter version reported by harness: `unknown`
- OS reported by harness: `macos`
- Commands used `PATH=/Users/arya/fvm/cache.git/bin:$PATH`

## Commands

```bash
dart run melos run benchmark:fixtures
dart run melos run benchmark:micro
dart run melos run benchmark:render
dart run melos run benchmark:profile
```

`benchmark:profile` now accepts renderer and fixture selection through shell
environment variables:

```bash
TAGFLOW_RENDERER=tagflow TAGFLOW_FIXTURE=ai_answer_rich \
  dart run melos run benchmark:profile

TAGFLOW_RENDERER=flutter_html TAGFLOW_FIXTURE=ai_answer_rich \
  dart run melos run benchmark:profile
```

All four commands passed on this branch.

Generated artifacts were written locally to:

- `packages/tagflow_benchmarks/build/benchmarks/parser.json`
- `packages/tagflow_benchmarks/build/benchmarks/render.json`
- `examples/tagflow/build/integration_response_data.json`

Those files are intentionally ignored by `.gitignore`.

## Parser Microbenchmark

Harness settings from `benchmark:micro`:

- warmup iterations: `1`
- timed samples: `3`

| Fixture | Input bytes | Nodes | Median us | p95 us | Mean us | CoV |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| `smoke_short_html` | 356 | 19 | 574 | 672 | 552.0 | 0.196 |
| `ai_answer_rich` | 2059 | 68 | 2398 | 3316 | 2559.7 | 0.220 |
| `table_dense` | 1741 | 226 | 2084 | 2342 | 2149.3 | 0.064 |
| `large_article` | 4529 | 120 | 1870 | 1955 | 1897.3 | 0.022 |
| `deep_nested_lists` | 1139 | 37 | 586 | 621 | 551.0 | 0.137 |

## Render Benchmark

Harness settings from `benchmark:render`:

- warmup iterations: `1`
- timed samples: `2`
- measurement: widget conversion plus `pumpWidget` in Flutter test

| Fixture | Input bytes | Nodes | Median us | p95 us | Mean us | CoV |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| `smoke_short_html` | 356 | 19 | 21270 | 21270 | 14571.0 | 0.460 |
| `ai_answer_rich` | 2059 | 68 | 19113 | 19113 | 16719.5 | 0.143 |
| `table_dense` | 1741 | 226 | 31823 | 31823 | 29778.5 | 0.069 |
| `large_article` | 4529 | 120 | 24415 | 24415 | 21305.0 | 0.146 |
| `deep_nested_lists` | 1139 | 37 | 7620 | 7620 | 7455.0 | 0.022 |

## Profile-Mode Frame Smoke Runs

Harness settings from `benchmark:profile`:

- command target: `examples/tagflow/integration_test/tagflow_perf_test.dart`
- driver: `examples/tagflow/test_driver/perf_driver.dart`
- device: `macos`
- Flutter mode: `--profile`
- fixture: `ai_answer_rich`

### Tagflow

Command used:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_RENDERER=tagflow \
TAGFLOW_FIXTURE=ai_answer_rich \
dart run melos run benchmark:profile
```

| Metric | Value |
| --- | ---: |
| frame count | 23 |
| average build ms | 0.219 |
| p90 build ms | 0.450 |
| p99 build ms | 0.500 |
| worst build ms | 0.500 |
| missed build budget count | 0 |
| average raster ms | 1.674 |
| p90 raster ms | 2.174 |
| p99 raster ms | 17.533 |
| worst raster ms | 17.533 |
| missed raster budget count | 1 |
| new-gen GC count | 2 |
| old-gen GC count | 0 |

### Flutter HTML

Command used:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_RENDERER=flutter_html \
TAGFLOW_FIXTURE=ai_answer_rich \
dart run melos run benchmark:profile
```

Adapter caveats:

- Enabled `flutter_html_table` so the shared fixture's `<table>` rendered
  instead of being dropped.
- Kept package-default styling; no extra theme tuning was added to match
  Tagflow output.

| Metric | Value |
| --- | ---: |
| frame count | 24 |
| average build ms | 0.285 |
| p90 build ms | 0.408 |
| p99 build ms | 0.587 |
| worst build ms | 0.587 |
| missed build budget count | 0 |
| average raster ms | 1.504 |
| p90 raster ms | 1.276 |
| p99 raster ms | 15.169 |
| worst raster ms | 15.169 |
| missed raster budget count | 0 |
| new-gen GC count | 2 |
| old-gen GC count | 0 |

## Limitations

- These are local smoke baselines, not release gates.
- The render suite uses `flutter_test`, so it measures conversion plus widget
  build work in a test host.
- The profile suite now records app frame timings for `ai_answer_rich` on the
  landed `tagflow` and `flutter_html` adapters only.
- The sample counts are deliberately low for CI friendliness. Larger local
  sample runs should be added before publishing performance claims.
- `flutter_widget_from_html` resolved locally but was deferred from this first
  adapter pass because the full package brings a much broader transitive
  media/webview stack than the current fixture comparison requires.
- Running `dart run bin/run_parser_benchmarks.dart ...` directly currently
  fails because the benchmark package imports Flutter-facing Tagflow code and a
  plain Dart VM has no `dart:ui`. Use the Melos/Flutter test-hosted benchmark
  commands above until the runner is split or hosted differently.
- The profile harness intentionally runs `flutter drive` on macOS instead of
  `flutter test integration_test/...` because it needs the
  `integration_test_driver.dart` response payload written to
  `examples/tagflow/build/integration_response_data.json`.
- On current Flutter desktop tooling, `flutter test integration_test/...`
  disables native result reporting automatically, but `flutter drive` does not.
  The benchmark script now passes
  `--dart-define=INTEGRATION_TEST_SHOULD_REPORT_RESULTS_TO_NATIVE=false` so
  `IntegrationTestWidgetsFlutterBinding` skips the macOS-native
  `allTestsFinished` plugin channel that is not registered in this app's
  generated macOS plugin list.
- This removes the warning without changing how `integrationDriver()`
  collects benchmark data. The JSON timing artifact still comes from the VM
  service `requestData` path, so these numbers remain acceptable as local
  smoke evidence. They are still not sufficient as release-gate evidence.
