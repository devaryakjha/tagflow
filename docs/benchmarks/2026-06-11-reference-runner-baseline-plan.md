# Tagflow Reference Runner Baseline Plan

## Status

- Date: 2026-06-11
- Scope: reference-runner methodology plus a small profile matrix runner
- Current evidence level: complete repeat-5 local macOS collection plus a
  report-only checker policy, not publishable claims

## Goal

Move profile-mode benchmark evidence from one-off smoke snapshots to repeated,
reviewable runs from a named reference environment. Raw run artifacts stay under
ignored `build/` output. Only reviewed methodology and curated baseline notes
belong in `docs/benchmarks/baselines/`.

## Gate Tier Map

| Tier | Purpose | Required evidence | Allowed decision |
| --- | --- | --- | --- |
| Smoke | Prove a lane is wired and artifacts are produced. | One selected cell or fixture completes, writes the expected JSON artifact, and the note records report-only posture. | Harness health only. A smoke pass can unblock follow-up implementation, not a performance claim. |
| Local reference | Prove collection quality on a named local environment. | Repeat count is met for every selected cell, `profile-baseline-summary.json` has no failed runs, viewport guard passes when configured, and the reviewed note records the toolchain, host, display, run id, commit, fixtures, and renderer ids. | Release-handoff confidence for that environment. Timing numbers remain local stabilization evidence. |
| Release candidate gate | Decide whether a prerelease has known benchmark collection or stability blockers. | Fixture validity, parser/render/native-transport smoke, selected profile baseline summary/check, and explicit review of any exception, OOM, overflow, missing artifact, failed scroll, or outlier finding. | Block or proceed based on collection/stability failures only. No numeric frame or relative-speed threshold. |
| Public claim qualification | Support external benchmark language. | Promoted stable reference environment, repeated matrix on physical devices or a stated desktop-only scope, cold/warm separation, fixture sizes and feature coverage, memory/allocation review, competitor fairness review, and a committed threshold/comparison policy. | Public copy may cite only the claim covered by the reviewed evidence and policy. |

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

The profile matrix runner writes the fields it can detect automatically:
Tagflow version, Dart version, Flutter version/channel from `FLUTTER_VERSION`
or `flutter --version --machine`, host OS/version, git commit, Flutter device
id, renderer id, fixture id, repeat count, artifact paths, and Flutter viewport
size/device-pixel-ratio metadata. Hardware model, power state, Melos version,
display identity/placement, and reviewer notes still need to be added to the
reviewed baseline document before any external performance claim is made.

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
- `--pair=tagflow_semantic:streaming_ai_chunks,tagflow_semantic_patch:streaming_ai_patches`
  or `TAGFLOW_PROFILE_PAIR=tagflow_semantic:streaming_ai_chunks,...`
- `--repeat=5` or `TAGFLOW_PROFILE_REPEAT=5`
- `--device=macos` or `TAGFLOW_PROFILE_DEVICE=macos`
- `--output-dir=build/benchmarks/profile-candidate` or
  `TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-candidate`
- `--continue-on-failure=true` or
  `TAGFLOW_PROFILE_CONTINUE_ON_FAILURE=true`

When `--pair` or `TAGFLOW_PROFILE_PAIR` is set, the runner executes exactly that
ordered renderer/fixture cell list instead of expanding a renderer by fixture
cross-product. Use paired mode for fixture-scoped lanes where the compatibility
guard should remain strict.

Semantic streaming report-only comparison:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_PAIR=tagflow_semantic:streaming_ai_chunks,tagflow_semantic_patch:streaming_ai_patches \
TAGFLOW_PROFILE_REPEAT=1 \
dart run melos run benchmark:profile:baselines
```

This compares the full-reparse semantic HTML stream with the semantic document
patch stream as two explicit cells. It is report-only: summarize and review the
manifest/artifacts, but do not treat either timing result as a pass/fail gate.

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
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile \
dart run melos run benchmark:profile:summarize
```

writes `profile-baseline-summary.json` next to the manifest. In addition to
metric distributions for passed artifacts, the summary reports `successfulRuns`,
`runStatusCounts`, and `failedRuns` with log paths. Reviewers should treat any
non-empty `failedRuns` list as a target qualification or benchmark collection
failure until the logs are inspected and the run is repeated successfully.
For artifacts collected after the viewport metadata change, each cell summary
also reports unique logical/physical viewport sizes and device-pixel-ratio
values observed across successful repeats.
For artifacts collected after the input metadata change, each cell summary also
reports `inputSummary.inputBytes`, `inputSummary.inputLength`, source types, and
asset paths so reviewed notes can tie timing evidence to fixture size.
For static profile artifacts collected after the cold/warm split, each cell
summary also reports `framePhaseSummaries.warmScroll` and optional
`framePhaseSummaries.coldInitialRender`. These fields are report-only evidence;
the checker still enforces collection completeness rather than timing
thresholds.

The check command turns collection completeness into a machine-readable gate:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=<run-id> \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile \
TAGFLOW_PROFILE_MIN_REPEATS=5 \
dart run melos run benchmark:profile:check
```

This gate intentionally checks only profile collection completeness today: no
failed or missing runs, `successfulRuns == totalRuns`, at least one successful
renderer/fixture cell, and the requested successful repeat count per cell. It
does not enforce frame-time thresholds until a named reference machine has a
reviewed baseline and regression policy.

The current report-only policy fixture lives at
`docs/benchmarks/policies/profile-reference-runner-policy.json`. It sets the
default alpha policy to five successful repeats, the candidate pinned macOS
viewport of `800x600` at device-pixel-ratio `2`, and
`thresholdPolicy.mode: report_only`.

Direct checker usage with the policy:

```bash
cd packages/tagflow_benchmarks
dart run bin/check_profile_baseline.dart \
  --run-id=<run-id> \
  --policy=../../docs/benchmarks/policies/profile-reference-runner-policy.json
```

Melos usage with the policy:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=<run-id> \
TAGFLOW_PROFILE_CHECK_POLICY=docs/benchmarks/policies/profile-reference-runner-policy.json \
dart run melos run benchmark:profile:check
```

Explicit `TAGFLOW_PROFILE_MIN_REPEATS`,
`TAGFLOW_PROFILE_EXPECTED_LOGICAL_SIZE`, and
`TAGFLOW_PROFILE_EXPECTED_DEVICE_PIXEL_RATIO` values override the policy for
ad hoc checks. The policy parser rejects any mode other than `report_only` so
timing gates cannot be introduced by configuration alone.

When a stable reference machine is intentionally pinned, the same check command
can also enforce the expected logical viewport size and device-pixel ratio:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=<run-id> \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile \
TAGFLOW_PROFILE_MIN_REPEATS=5 \
TAGFLOW_PROFILE_EXPECTED_LOGICAL_SIZE=800x600 \
TAGFLOW_PROFILE_EXPECTED_DEVICE_PIXEL_RATIO=2 \
dart run melos run benchmark:profile:check
```

Equivalent direct CLI usage:

```bash
cd packages/tagflow_benchmarks
dart run bin/check_profile_baseline.dart \
  --run-id=<run-id> \
  --min-repeats=5 \
  --expected-logical-size=800x600 \
  --expected-device-pixel-ratio=2
```

This viewport guard remains opt-in unless a policy with `expectedViewport` is
provided. If the expected logical size or device-pixel ratio is not configured,
viewport metadata stays report-only so existing alpha artifacts are not
retroactively failed.

The underlying package CLIs remain available for direct use:

```bash
cd packages/tagflow_benchmarks
dart run bin/summarize_profile_baselines.dart --run-id=<run-id>
dart run bin/check_profile_baseline.dart --run-id=<run-id> --min-repeats=5
```

When a run was collected with a non-default output directory, pass the same
`--output-dir` or `TAGFLOW_PROFILE_OUTPUT_DIR` value to summarize and check.
The summary library resolves artifact paths from the workspace root rather than
from a fixed folder depth, so explicit manifests under custom output locations
remain valid.

## Metrics Policy

Report-only today:

- frame count
- logical/physical viewport size and device-pixel ratio
- average, p90, p99, and worst build duration
- average, p90, p99, and worst raster duration
- missed build and raster budget counts
- new-gen and old-gen GC counts
- scroll completion behavior

Current machine-readable gate:

- no test exceptions, overflows, OOMs, or missing JSON artifacts
- every selected cell has `status: passed` in the manifest
- `profile-baseline-summary.json` has an empty `failedRuns` list and
  `successfulRuns == totalRuns`
- `check_profile_baseline.dart --min-repeats=5` passes for the selected
  reference-runner matrix
- `check_profile_baseline.dart --min-repeats=5 --expected-logical-size=... \
  --expected-device-pixel-ratio=...` passes for the selected stable reference
  machine

These checks qualify collection quality only. They prove that a run is complete
and comparable within the same configured viewport; they do not prove that one
renderer is faster than another or that a future commit has regressed.

Reference-runner performance gates can be introduced only after a stable
environment is promoted. Candidate gates for the same promoted reference
environment:

- standard fixtures keep build p90 and raster p90 under the reviewed baseline
  regression threshold
- `table_stress` remains visible and scrollable without crash
- dropped or missed-frame counts do not regress beyond the reviewed threshold

Hosted CI frame timings remain report-only until the hosted runner proves stable
enough for trend comparison. A single local Mac run must not be described as
statistically significant.

## Reference Promotion Policy

Benchmark evidence has three levels:

1. Smoke evidence: one-off local runs that prove the harness, fixture, and
   renderer path work. These may be cited in internal planning only.
2. Stabilization evidence: a complete repeat-5 matrix on a named local
   environment, with a reviewed baseline note and a passing completeness check.
   The current macOS repeat-5 baseline is in this category.
3. Claim-grade evidence: a promoted reference environment with pinned toolchain,
   pinned viewport/display conditions, a complete repeat-5 matrix, and an
   explicit threshold review committed after the baseline.

A reference environment can be promoted only when the reviewed note records:

- stable Flutter channel and exact Flutter/Dart revisions
- stable host OS release, not a prerelease seed
- hardware model, CPU/GPU, memory, power source, and thermal state
- display identity, display placement, logical viewport size, and device pixel
  ratio
- default matrix renderer ids, fixture ids, repeat count, run id, and commit SHA
- a passing `benchmark:profile:check` command with `TAGFLOW_PROFILE_MIN_REPEATS`
  and viewport guard variables
- reviewer decision that names the thresholds to enforce for future runs

Until those conditions are met, benchmark copy must use cautious language:

- allowed: "the local alpha harness collected a complete repeat-5 macOS
  stabilization matrix"
- allowed: "this run found no missed frame-budget counts for Tagflow cells"
- not allowed: "Tagflow is faster than package X"
- not allowed: "Tagflow meets the stable performance budget"
- not allowed: "these numbers are representative of production devices"

## Remaining Work Before Publishing Claims

- choose and document the physical reference machine
- pin the Flutter channel and record `flutter --version`
- repeat the default matrix with at least five repeats per cell on the chosen
  stable reference machine
- run `--continue-on-failure=true` once for each new target before treating it
  as a candidate reference runner
- inspect raw artifacts for outliers and failed scrolls
- create or refresh a reviewed stable-runner baseline note under
  `docs/benchmarks/baselines/`
- decide regression thresholds only after the reviewed baseline exists
