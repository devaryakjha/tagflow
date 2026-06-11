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
| `smoke_short_html` | 356 | 19 | 434 | 550 | 445.3 | 0.182 |
| `ai_answer_rich` | 2059 | 68 | 2115 | 2639 | 2246.0 | 0.126 |
| `table_dense` | 1741 | 226 | 2301 | 3625 | 2656.7 | 0.261 |
| `large_article` | 4529 | 120 | 1618 | 1800 | 1583.7 | 0.121 |
| `deep_nested_lists` | 1139 | 37 | 381 | 558 | 438.3 | 0.193 |

## Render Benchmark

Harness settings from `benchmark:render`:

- warmup iterations: `1`
- timed samples: `2`
- measurement: widget conversion plus `pumpWidget` in Flutter test

| Fixture | Input bytes | Nodes | Median us | p95 us | Mean us | CoV |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| `smoke_short_html` | 356 | 19 | 20816 | 20816 | 14886.0 | 0.398 |
| `ai_answer_rich` | 2059 | 68 | 28897 | 28897 | 24552.0 | 0.177 |
| `table_dense` | 1741 | 226 | 44904 | 44904 | 41308.0 | 0.087 |
| `large_article` | 4529 | 120 | 25404 | 25404 | 24370.0 | 0.042 |
| `deep_nested_lists` | 1139 | 37 | 16940 | 16940 | 16394.0 | 0.033 |

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
