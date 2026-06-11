# 2026-06-11 Local Alpha Benchmark Baseline

This is a local evidence snapshot for the Tagflow native-runtime alpha branch.
It records the current benchmark harness output without committing generated
JSON artifacts from `packages/tagflow_benchmarks/build/`.

## Environment

- Branch: `codex/tagflow-native-runtime-master`
- Package version reported by harness: `0.0.8`
- Dart version reported by harness: `3.11.0-81.0.dev`
- Flutter version reported by harness: `unknown`
- OS reported by harness: `macos`
- Commands used `PATH=/Users/arya/fvm/cache.git/bin:$PATH`

## Commands

```bash
dart run melos run benchmark:fixtures
dart run melos run benchmark:micro
dart run melos run benchmark:render
```

All three commands passed on this branch.

Generated artifacts were written locally to:

- `packages/tagflow_benchmarks/build/benchmarks/parser.json`
- `packages/tagflow_benchmarks/build/benchmarks/render.json`

Those files are intentionally ignored by `.gitignore`.

## Parser Microbenchmark

Harness settings from `benchmark:micro`:

- warmup iterations: `1`
- timed samples: `3`

| Fixture | Input bytes | Nodes | Median us | p95 us | Mean us | CoV |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| `smoke_short_html` | 356 | 19 | 456 | 526 | 450.3 | 0.143 |
| `ai_answer_rich` | 2059 | 68 | 2141 | 3977 | 2713.3 | 0.330 |
| `table_dense` | 1741 | 226 | 2226 | 2629 | 2267.3 | 0.123 |
| `large_article` | 4529 | 120 | 1652 | 1765 | 1644.0 | 0.062 |
| `deep_nested_lists` | 1139 | 37 | 417 | 584 | 467.3 | 0.177 |

## Render Benchmark

Harness settings from `benchmark:render`:

- warmup iterations: `1`
- timed samples: `2`
- measurement: widget conversion plus `pumpWidget` in Flutter test

| Fixture | Input bytes | Nodes | Median us | p95 us | Mean us | CoV |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| `smoke_short_html` | 356 | 19 | 22499 | 22499 | 15392.0 | 0.462 |
| `ai_answer_rich` | 2059 | 68 | 28684 | 28684 | 25373.0 | 0.130 |
| `table_dense` | 1741 | 226 | 45048 | 45048 | 43343.0 | 0.039 |
| `large_article` | 4529 | 120 | 26680 | 26680 | 25990.0 | 0.027 |
| `deep_nested_lists` | 1139 | 37 | 17510 | 17510 | 17099.5 | 0.024 |

## Limitations

- These are local smoke baselines, not release gates.
- The render suite uses `flutter_test`, so it measures conversion plus widget
  build work in a test host, not profile-mode frame timings in an app.
- The sample counts are deliberately low for CI friendliness. Larger local
  sample runs should be added before publishing performance claims.
- Running `dart run bin/run_parser_benchmarks.dart ...` directly currently
  fails because the benchmark package imports Flutter-facing Tagflow code and a
  plain Dart VM has no `dart:ui`. Use the Melos/Flutter test-hosted benchmark
  commands above until the runner is split or hosted differently.
