# 2026-06-11 Native Transport Microbenchmark Smoke

This note records the first bounded smoke run for the native block JSON
transport benchmark lane added in
`5887c17 feat(benchmarks): add native transport benchmark lane`.

It is report-only evidence. It does not set thresholds, does not create a
release gate, and does not support any faster/slower claim against HTML parser
or renderer lanes. The lane measures native transport overhead only: JSON map
decode, native block adaptation, patch envelope decode, patch adaptation, and
runtime patch application.

Raw output was written only under ignored `build/` output:

```text
packages/tagflow_benchmarks/build/benchmarks/native_transport.json
```

## Scope

- Suite: `native_transport`
- Fixture: `native_ai_answer_patch`
- Collection commit: `5887c17 feat(benchmarks): add native transport benchmark lane`
- Branch context: `codex/tagflow-native-runtime-master`
- Generated at: `2026-06-11T17:36:00.889157Z`
- Host OS: `macos`
- `tagflow` version: `1.0.0-alpha.1`
- Dart SDK: `3.11.0-81.0.dev`
- Flutter SDK detected by this plain benchmark runner: `unknown`
- Warmup iterations: `1`
- Timed samples: `3`
- Document payload: `2165` bytes
- Patch payload: `749` bytes
- Runtime node count after patches: `24`
- Patch operation count: `4`

## Command

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
dart run melos run benchmark:native-transport
```

The Melos alias ran:

```bash
flutter test test/run_native_transport_benchmarks_test.dart
```

## Results

| Phase | Samples us | Median us | p95 us | Min us | Max us | Mean us | CV |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| `decodeDocument` | `208, 197, 166` | 197 | 208 | 166 | 208 | 190.33 | 0.093 |
| `adaptDocument` | `101, 123, 93` | 101 | 123 | 93 | 123 | 105.67 | 0.120 |
| `decodePatchEnvelope` | `45, 75, 41` | 45 | 75 | 41 | 75 | 53.67 | 0.283 |
| `adaptPatches` | `25, 36, 26` | 26 | 36 | 25 | 36 | 29.00 | 0.171 |
| `applyPatches` | `106, 102, 100` | 102 | 106 | 100 | 106 | 102.67 | 0.024 |
| `totalTransport` | `489, 535, 430` | 489 | 535 | 430 | 535 | 484.67 | 0.089 |

## Validation

Coordinator validation passed after integrating the lane:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
flutter test \
  test/benchmark_result_test.dart \
  test/native_transport_benchmark_suite_test.dart \
  test/run_native_transport_benchmarks_test.dart
```

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
flutter analyze . --fatal-infos
```

```bash
git diff --check
```

## Caveats

- This is a smoke run through a Flutter test harness, not a profile-mode app
  benchmark.
- The sample count is intentionally tiny (`3`) and only proves the lane runs
  and records phase-level microsecond data.
- The benchmark uses in-memory JSON-like Dart maps, not network fetch,
  persistence, CMS sync, isolates, or Flutter rendering.
- HTML comparison is intentionally separate because the current HTML lanes do
  not have an equivalent native patch-envelope path.
- The detected Flutter version is `unknown` in this plain benchmark runner; the
  profile baseline harness remains the stronger source for renderer/device
  environment metadata.

## Review

This smoke is enough to prove the native transport lane is runnable from the
repo's documented Melos command and captures useful phase-level evidence for
the current native JSON document and four-operation patch envelope. It is not
enough to make a public performance claim or set a regression threshold.

## Alpha.2 Candidate Rerun

After the `tagflow` package metadata was bumped to `1.0.0-alpha.2`, the
coordinator reran the same report-only smoke command:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
dart run melos run benchmark:native-transport
```

Scope:

- Generated at: `2026-06-11T17:53:58.460718Z`
- `tagflow` version: `1.0.0-alpha.2`
- Fixture: `native_ai_answer_patch`
- Document payload: `2165` bytes
- Patch payload: `749` bytes
- Runtime node count after patches: `24`
- Patch operation count: `4`

Results:

| Phase | Samples us | Median us | p95 us | Min us | Max us | Mean us | CV |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| `decodeDocument` | `215, 166, 164` | 166 | 215 | 164 | 215 | 181.67 | 0.130 |
| `adaptDocument` | `96, 114, 94` | 96 | 114 | 94 | 114 | 101.33 | 0.089 |
| `decodePatchEnvelope` | `42, 94, 44` | 44 | 94 | 42 | 94 | 60.00 | 0.401 |
| `adaptPatches` | `27, 39, 26` | 27 | 39 | 26 | 39 | 30.67 | 0.193 |
| `applyPatches` | `107, 103, 101` | 103 | 107 | 101 | 107 | 103.67 | 0.024 |
| `totalTransport` | `490, 519, 431` | 490 | 519 | 431 | 519 | 480.00 | 0.076 |

This rerun keeps the same caveats as the first smoke run: it proves the lane
runs and records phase-level evidence for the alpha.2 candidate, but it is not
a profile-mode benchmark or a public performance claim.
