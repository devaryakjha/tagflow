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

## Profile-Mode Frame Smoke Run

Harness settings from `benchmark:profile`:

- command target: `examples/tagflow/integration_test/tagflow_perf_test.dart`
- driver: `examples/tagflow/test_driver/perf_driver.dart`
- device: `macos`
- Flutter mode: `--profile`
- fixture: `ai_answer_rich`
- renderer: `tagflow`

| Metric | Value |
| --- | ---: |
| frame count | 23 |
| average build ms | 0.185 |
| p90 build ms | 0.288 |
| p99 build ms | 0.498 |
| worst build ms | 0.498 |
| missed build budget count | 0 |
| average raster ms | 2.772 |
| p90 raster ms | 11.668 |
| p99 raster ms | 18.955 |
| worst raster ms | 18.955 |
| missed raster budget count | 1 |
| new-gen GC count | 2 |
| old-gen GC count | 0 |

## Limitations

- These are local smoke baselines, not release gates.
- The render suite uses `flutter_test`, so it measures conversion plus widget
  build work in a test host. The profile suite now records app frame timings,
  but only for the initial `ai_answer_rich` Tagflow fixture.
- The sample counts are deliberately low for CI friendliness. Larger local
  sample runs should be added before publishing performance claims.
- Running `dart run bin/run_parser_benchmarks.dart ...` directly currently
  fails because the benchmark package imports Flutter-facing Tagflow code and a
  plain Dart VM has no `dart:ui`. Use the Melos/Flutter test-hosted benchmark
  commands above until the runner is split or hosted differently.
- The profile `flutter drive` run currently emits Flutter's
  `integration_test plugin was not detected` warning even though the driver
  returns success and writes `integration_response_data.json`; that should be
  investigated before treating profile data as a release gate.
