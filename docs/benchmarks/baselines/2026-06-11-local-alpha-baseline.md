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
| `smoke_short_html` | 356 | 19 | 403 | 671 | 485.0 | 0.272 |
| `ai_answer_rich` | 2059 | 68 | 2431 | 3170 | 2628.3 | 0.148 |
| `table_dense` | 1741 | 226 | 2059 | 2572 | 2174.7 | 0.133 |
| `large_article` | 4529 | 120 | 1688 | 2078 | 1745.0 | 0.144 |
| `deep_nested_lists` | 1139 | 37 | 455 | 556 | 468.3 | 0.143 |

## Render Benchmark

Harness settings from `benchmark:render`:

- warmup iterations: `1`
- timed samples: `2`
- measurement: widget conversion plus `pumpWidget` in Flutter test

| Fixture | Input bytes | Nodes | Median us | p95 us | Mean us | CoV |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| `smoke_short_html` | 356 | 19 | 22046 | 22046 | 17240.0 | 0.279 |
| `ai_answer_rich` | 2059 | 68 | 28601 | 28601 | 24899.5 | 0.149 |
| `table_dense` | 1741 | 226 | 46398 | 46398 | 43491.0 | 0.067 |
| `large_article` | 4529 | 120 | 25491 | 25491 | 24964.5 | 0.021 |
| `deep_nested_lists` | 1139 | 37 | 17903 | 17903 | 17049.0 | 0.050 |

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
