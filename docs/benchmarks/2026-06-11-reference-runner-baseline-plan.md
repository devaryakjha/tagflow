# Tagflow Reference Runner Baseline Plan

## Status

- Date: 2026-06-11
- Scope: reference-runner methodology plus a small profile matrix runner
- Current evidence level: repeatable local collection, not publishable claims

## Goal

Move profile-mode benchmark evidence from one-off smoke snapshots to repeated,
reviewable runs from a named reference environment. Raw run artifacts stay under
ignored `build/` output. Only reviewed methodology and curated baseline notes
belong in `docs/benchmarks/baselines/`.

## Reference Environment Fields

Every reviewed reference baseline must record:

- repo commit SHA
- package versions for `tagflow` and `tagflow_table`
- Dart SDK version
- Flutter SDK version and channel
- Melos version
- host OS name and version
- hardware model, CPU, memory, and power mode
- Flutter device id passed to `flutter drive -d`
- display scale and window size when desktop frame timings are collected
- benchmark command, renderer id, fixture id, repeat count, and run timestamp

The new profile matrix runner writes the fields it can detect automatically:
Tagflow version, Dart version, optional `FLUTTER_VERSION`, host OS/version, git
commit, Flutter device id, renderer id, fixture id, repeat count, and artifact
paths. Hardware model, power state, Flutter channel, Melos version, display
state, and reviewer notes still need to be added to the reviewed baseline
document before any external performance claim is made.

## Collection Command

Tiny smoke run:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_RENDERER=tagflow \
TAGFLOW_FIXTURE=ai_answer_rich \
TAGFLOW_PROFILE_REPEAT=1 \
dart run melos run benchmark:profile:baselines
```

Reference run candidate:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_REPEAT=5 \
dart run melos run benchmark:profile:baselines
```

Unsupported-target probe:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_DEVICE=<physical-device-id> \
TAGFLOW_PROFILE_REPEAT=1 \
TAGFLOW_PROFILE_CONTINUE_ON_FAILURE=true \
dart run melos run benchmark:profile:baselines
```

Use `TAGFLOW_PROFILE_CONTINUE_ON_FAILURE=true` when validating a new physical
device, simulator, or CI runner. The runner will keep a manifest entry for
failed or missing-artifact cells instead of losing the failure as terminal
output.

The Melos command delegates each cell to the existing profile harness:

```bash
dart run melos run benchmark:profile
```

`benchmark:profile` continues to run `flutter drive --profile` against
`examples/tagflow/integration_test/tagflow_perf_test.dart` and writes the raw
integration response to
`examples/tagflow/build/integration_response_data.json`.

## Runner Matrix

Default renderer matrix:

- `tagflow`
- `flutter_html`
- `flutter_widget_from_html`

Default fixture matrix:

- `ai_answer_rich`
- `table_dense`
- `large_article`
- `table_stress`

The runner accepts comma-separated overrides through CLI flags or environment
variables:

- `--renderer=tagflow,flutter_html` or `TAGFLOW_RENDERER=tagflow`
- `--fixture=ai_answer_rich,table_dense` or `TAGFLOW_FIXTURE=ai_answer_rich`
- `--repeat=5` or `TAGFLOW_PROFILE_REPEAT=5`
- `--device=macos` or `TAGFLOW_PROFILE_DEVICE=macos`
- `--continue-on-failure=true` or
  `TAGFLOW_PROFILE_CONTINUE_ON_FAILURE=true`

## Artifact Naming

The runner writes ignored output under:

```text
build/benchmarks/profile/<run-id>/
```

Each raw response is copied to:

```text
<renderer>/<fixture>/repeat-NN.json
```

Each cell also writes a process log:

```text
<renderer>/<fixture>/repeat-NN.log
```

The run manifest is:

```text
profile-baseline-manifest.json
```

The manifest records the command, matrix, repeat count, environment fields, and
relative artifact paths. Failed or missing-artifact cells are recorded with a
`status` field and a `logPath`; successful cells are recorded with
`status: passed` and an `artifactPath`. The manifest is the handoff point for a
later reviewed baseline document.

The summary command:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=<run-id> \
dart run melos run benchmark:profile:summarize
```

writes `profile-baseline-summary.json` next to the manifest. In addition to
metric distributions for passed artifacts, the summary reports `successfulRuns`,
`runStatusCounts`, and `failedRuns` with log paths. Reviewers should treat any
non-empty `failedRuns` list as a target qualification or benchmark collection
failure until the logs are inspected and the run is repeated successfully.

The check command turns collection completeness into a machine-readable gate:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=<run-id> \
TAGFLOW_PROFILE_MIN_REPEATS=5 \
dart run melos run benchmark:profile:check
```

This gate intentionally checks only profile collection completeness today: no
failed or missing runs, `successfulRuns == totalRuns`, at least one successful
renderer/fixture cell, and the requested successful repeat count per cell. It
does not enforce frame-time thresholds until a named reference machine has a
reviewed baseline and regression policy.

The underlying package CLIs remain available for direct use:

```bash
cd packages/tagflow_benchmarks
dart run bin/summarize_profile_baselines.dart --run-id=<run-id>
dart run bin/check_profile_baseline.dart --run-id=<run-id> --min-repeats=5
```

## Metrics Policy

Report-only today:

- frame count
- average, p90, p99, and worst build duration
- average, p90, p99, and worst raster duration
- missed build and raster budget counts
- new-gen and old-gen GC counts
- scroll completion behavior

Reference-runner gates can be introduced only after at least one reviewed
baseline has been collected on a stable machine. Candidate gates for the same
reference environment:

- no test exceptions, overflows, OOMs, or missing JSON artifacts
- every selected cell has `status: passed` in the manifest
- `profile-baseline-summary.json` has an empty `failedRuns` list and
  `successfulRuns == totalRuns`
- `check_profile_baseline.dart --min-repeats=5` passes for the selected
  reference-runner matrix
- standard fixtures keep build p90 and raster p90 under the reviewed baseline
  regression threshold
- `table_stress` remains visible and scrollable without crash
- dropped or missed-frame counts do not regress beyond the reviewed threshold

Hosted CI frame timings remain report-only until the hosted runner proves stable
enough for trend comparison. A single local Mac run must not be described as
statistically significant.

## Remaining Work Before Publishing Claims

- choose and document the physical reference machine
- pin the Flutter channel and record `flutter --version`
- run the default matrix with at least five repeats per cell
- run `--continue-on-failure=true` once for each new target before treating it
  as a candidate reference runner
- inspect raw artifacts for outliers and failed scrolls
- create a reviewed baseline note under `docs/benchmarks/baselines/`
- decide regression thresholds only after the reviewed baseline exists
