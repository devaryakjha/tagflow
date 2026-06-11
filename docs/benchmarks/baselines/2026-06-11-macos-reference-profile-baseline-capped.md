# 2026-06-11 macOS Reference Profile Baseline (Capped)

This note records reviewed profile-mode benchmark evidence collected on
2026-06-11 for the Tagflow `1.0.0-alpha.1` stabilization line.

The original goal was the full reference matrix:

- renderers: `tagflow`, `flutter_html`, `flutter_widget_from_html`
- fixtures: `ai_answer_rich`, `table_dense`, `large_article`,
  `table_stress`
- repeats: `5`

That full `3 x 4 x 5` run was started and then capped after the first
14 minutes 34 seconds because only 2 artifacts had completed. This note
therefore reviews the largest defensible subset finished in this turn:

- `tagflow` across all four fixtures with `repeat=1`
- competitor comparison on `ai_answer_rich` with `repeat=1`
- the first two completed `tagflow/ai_answer_rich` repeats from the
  aborted `repeat=5` attempt

Raw benchmark JSON remains ignored under the existing runner location
`build/benchmarks/profile/...`. The runner does not currently write under
`packages/tagflow_benchmarks/build/...`.

## Reference Environment

- Runtime line: `codex/tagflow-native-runtime-master` snapshot from
  `docs/plans/2026-06-11-tagflow-v1-alpha-acceptance-status.md`
- Collection commit: `fa2112bbf6ededad779a828a5fad9ddb01499f04`
- `tagflow` version: `1.0.0-alpha.1`
- `tagflow_table` version: `1.0.0-alpha.1`
- Flutter SDK: `3.45.0-0.1.pre` on `master`
- Flutter revision: `6af38a904a`
- Dart SDK: `3.11.0-81.0.dev`
- Melos version: `7.8.2`
- Host OS: `macOS 27.0 (26A5353q)`
- Hardware: `MacBook Pro (Mac16,5)`, `Apple M4 Max`, `48 GB RAM`
- Power state during collection: AC attached, battery `80%`,
  `powermode 0`
- Flutter device id: `macos`
- Display caveat: the host had both the built-in `3456 x 2234` display and
  an external `2560 x 1440 @ 75 Hz` display attached
- Window caveat: the benchmark app window was observed at `800 x 632`,
  but the harness does not pin window size or display selection in code

## Commands

All commands used:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH
FLUTTER_VERSION="$(flutter --version | head -n 1 | sed 's/^Flutter //')"
```

Aborted full-matrix attempt:

```bash
cd packages/tagflow_benchmarks
dart run bin/run_profile_baselines.dart \
  --repeat=5 \
  --run-id=2026-06-11-macos-reference-repeat5
```

Completed capped runs:

```bash
cd <tagflow-repo-root>
cd packages/tagflow_benchmarks
dart run bin/run_profile_baselines.dart \
  --renderer=tagflow \
  --repeat=1 \
  --run-id=2026-06-11-macos-tagflow-all-fixtures-r1

dart run bin/run_profile_baselines.dart \
  --renderer=flutter_html,flutter_widget_from_html \
  --fixture=ai_answer_rich \
  --repeat=1 \
  --run-id=2026-06-11-macos-ai-answer-competitors-r1

cd <tagflow-repo-root>
TAGFLOW_PROFILE_RUN_ID=2026-06-11-macos-tagflow-all-fixtures-r1 \
  dart run melos run benchmark:profile:summarize
TAGFLOW_PROFILE_RUN_ID=2026-06-11-macos-ai-answer-competitors-r1 \
  dart run melos run benchmark:profile:summarize
TAGFLOW_PROFILE_RUN_ID=2026-06-11-macos-tagflow-all-fixtures-r1 \
  TAGFLOW_PROFILE_MIN_REPEATS=1 \
  dart run melos run benchmark:profile:check
TAGFLOW_PROFILE_RUN_ID=2026-06-11-macos-ai-answer-competitors-r1 \
  TAGFLOW_PROFILE_MIN_REPEATS=1 \
  dart run melos run benchmark:profile:check
```

## Artifact Sets

Completed run directories:

- `build/benchmarks/profile/2026-06-11-macos-tagflow-all-fixtures-r1/`
- `build/benchmarks/profile/2026-06-11-macos-ai-answer-competitors-r1/`

Generated reviewed helper artifacts:

- `build/benchmarks/profile/2026-06-11-macos-tagflow-all-fixtures-r1/profile-baseline-summary.json`
- `build/benchmarks/profile/2026-06-11-macos-ai-answer-competitors-r1/profile-baseline-summary.json`

Aborted raw-only partial run:

- `build/benchmarks/profile/2026-06-11-macos-reference-repeat5/tagflow/ai_answer_rich/repeat-01.json`
- `build/benchmarks/profile/2026-06-11-macos-reference-repeat5/tagflow/ai_answer_rich/repeat-02.json`

The aborted `repeat=5` attempt was interrupted before the runner finished,
so it did not emit `profile-baseline-manifest.json`.

Completeness gate status:

- `2026-06-11-macos-tagflow-all-fixtures-r1` passes with
  `TAGFLOW_PROFILE_MIN_REPEATS=1`.
- `2026-06-11-macos-ai-answer-competitors-r1` passes with
  `TAGFLOW_PROFILE_MIN_REPEATS=1`.
- No run in this worktree passes the reference-runner repeat-count
  completeness check at `TAGFLOW_PROFILE_MIN_REPEATS=5`; the checked Tagflow
  all-fixtures run fails with `insufficient_repeats` on all four fixtures.
- A passing `TAGFLOW_PROFILE_MIN_REPEATS=5` check would still be insufficient
  for publishable or stable performance claims until the reference-machine,
  window/display, and regression-threshold follow-up work below is completed.

## Completed Capped Results

### Tagflow Across All Fixtures

Single-repeat internal baseline:

| Fixture | Frames | Avg build ms | P90 build ms | Avg raster ms | P90 raster ms | Worst raster ms | Missed raster | GC notes |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| `ai_answer_rich` | 23 | 0.289 | 0.426 | 1.533 | 2.550 | 10.577 | 0 | new-gen `2` |
| `table_dense` | 24 | 0.201 | 0.501 | 0.909 | 1.874 | 3.698 | 0 | none |
| `large_article` | 26 | 0.369 | 0.662 | 1.841 | 3.664 | 13.992 | 0 | new-gen `2`, old-gen `2` |
| `table_stress` | 25 | 0.604 | 1.019 | 1.946 | 2.632 | 13.671 | 0 | new-gen `2` |

High-level read:

- All four Tagflow fixtures completed without crashes, overflows, or missing
  JSON artifacts.
- No completed Tagflow capped-run cell missed the frame raster budget.
- `table_stress` is the heaviest completed Tagflow case in this subset, but
  still stayed below a worst raster of `13.671 ms` in its single repeat.
- `large_article` showed old-gen GC activity in its single repeat, so it is
  stable enough for internal review but not strong enough yet for a release
  regression threshold.

### `ai_answer_rich` Competitor Comparison

Single-repeat comparison on the same fixture:

| Renderer | Frames | Avg build ms | P90 build ms | Avg raster ms | P90 raster ms | Worst raster ms | Missed raster | GC notes |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| `tagflow` | 23 | 0.289 | 0.426 | 1.533 | 2.550 | 10.577 | 0 | new-gen `2` |
| `flutter_html` | 24 | 0.335 | 0.497 | 1.253 | 1.273 | 11.259 | 0 | new-gen `2` |
| `flutter_widget_from_html` | 24 | 0.301 | 0.545 | 1.431 | 1.252 | 17.599 | 1 | new-gen `2`, old-gen `2` |

Interpretation:

- `tagflow` and `flutter_html` both completed this fixture without a budget
  miss in the capped run.
- `flutter_widget_from_html` hit one raster-budget miss and a
  `17.599 ms` worst raster spike, so the comparison is useful for
  directional stabilization work but not for external ranking claims.
- Because each renderer has only one completed comparison run here, the
  numbers should be read as spot measurements rather than stable medians.

## Aborted Full-Matrix Attempt

The runner began the full `repeat=5` matrix with run id
`2026-06-11-macos-reference-repeat5` and was stopped manually after
`14:34.41` total wall-clock time because only two artifacts had completed:

| Repeat | Frames | Avg build ms | P90 build ms | Avg raster ms | P90 raster ms | Worst raster ms | Missed raster | GC notes |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| `tagflow / ai_answer_rich / repeat-01` | 23 | 0.155 | 0.267 | 0.874 | 1.511 | 7.073 | 0 | new-gen `2` |
| `tagflow / ai_answer_rich / repeat-02` | 23 | 0.393 | 0.657 | 1.902 | 2.513 | 16.234 | 1 | new-gen `2` |

Why the matrix was reduced:

- The first complete artifact did not land until several minutes into the
  run because `flutter drive --profile` had to rebuild the macOS benchmark
  host.
- After `14:34.41`, only `2 / 60` cells were complete, so continuing the
  full matrix was not practical for this turn.
- A capped run with completed artifact sets is more reviewable than an
  unfinished matrix with only early partial data.

## Review Notes

Outliers and caveats worth carrying forward:

- `tagflow/large_article` showed `old_gen_gc_count=2` in its capped single
  repeat.
- `flutter_widget_from_html/ai_answer_rich` showed one raster-budget miss and
  old-gen GC activity.
- The partial `tagflow/ai_answer_rich` repeat-02 from the aborted full matrix
  also showed one raster-budget miss, which suggests at least some variance in
  warm-run macOS profile timings even before cross-renderer comparison.
- The benchmark host currently depends on Flutter `master` prerelease bits and
  an unpinned desktop window/display configuration. That is acceptable for
  internal stabilization evidence, not for publishable claims.

## Suitability

This evidence is suitable for:

- proving the reference runner works on a real macOS device
- reviewing Tagflow profile behavior across all four current fixtures
- comparing same-fixture renderer behavior directionally on
  `ai_answer_rich`
- identifying where repeat-based follow-up is still needed before adding
  regression gates

This evidence is not suitable for:

- external benchmark claims
- renderer ranking claims
- hard release thresholds
- CI gating thresholds

Follow-up before external claims or regression gates:

1. Pin a single reference display/window configuration in code or launch
   setup.
2. Re-run the capped subsets with at least `repeat=5`.
3. Re-attempt the full matrix only after confirming a materially faster or
   more predictable per-cell cadence.
