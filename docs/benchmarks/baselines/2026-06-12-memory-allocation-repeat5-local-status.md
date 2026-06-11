# 2026-06-12 Memory/Allocation Repeat-5 Local Status

This note records the current macOS memory/allocation evidence slice for the
native runtime benchmark plan. It is report-only evidence for local
stabilization. It does not set thresholds, does not support a public memory or
allocation claim, and does not replace the reviewed capture sequence in
[`2026-06-12-memory-allocation-evidence-playbook.md`](2026-06-12-memory-allocation-evidence-playbook.md).

Raw manifests, summaries, per-repeat logs, per-repeat artifacts, and bounded
DevTools memory JSON stayed only under ignored `build/` output:

```text
build/benchmarks/profile-memory-evidence/2026-06-12-memory-large-article-repeat5/
build/benchmarks/profile-memory-evidence/2026-06-12-memory-table-stress-repeat5/
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-repeat5/
build/benchmarks/profile-memory-evidence/2026-06-12-memory-native-large-article-repeat5/
```

## Status

- Repeat-5 profile evidence was collected for the required macOS lanes:
  `tagflow:large_article`, `tagflow:table_stress`, and the ordered authored
  insertion pair
  `tagflow_semantic:streaming_ai_authored_insertions,tagflow_semantic_patch:streaming_ai_authored_insertion_patches`.
- Bounded `flutter drive --profile-memory` JSON was collected for:
  `tagflow:large_article`, `tagflow:table_stress`,
  `tagflow_semantic:streaming_ai_authored_insertions`,
  `tagflow_semantic_patch:streaming_ai_authored_insertion_patches`, and the
  optional native-support lane `tagflow_native_json:native_large_article`.
- Heap snapshots, class allocation diffs, retained-object review, and explicit
  before/after checkpoint exports are still pending.

## Scope

- Collection commit:
  `ab7e0446a6c734c29aae5ff9541d92a2e39e84c2`
- Branch context: `codex/tagflow-native-runtime-master`
- Device: `macos`
- Selection mode:
  - required lanes collected as explicit pairs
  - optional native lane collected separately as an explicit pair

Run ids:

- `2026-06-12-memory-large-article-repeat5`
- `2026-06-12-memory-table-stress-repeat5`
- `2026-06-12-memory-authored-insertion-repeat5`
- `2026-06-12-memory-native-large-article-repeat5`

## Environment

- `tagflow` version: `1.0.0-alpha.3`
- `tagflow_table` version: `1.0.0-alpha.1`
- Flutter SDK: `3.45.0-0.1.pre (master)`
- Flutter revision: `6af38a904a3ff944cd35b0ebacf4d95b8f42391e`
- Engine revision: `3a0828c8d5942264423ab564b6bdb65ea243b606`
- Dart SDK: `3.11.0-81.0.dev`
- DevTools: `2.51.0`
- Host OS: `macOS 27.0 (26A5353q)`, `arm64`
- Hardware: `MacBook Pro (Mac16,5)`, `Apple M4 Max`, `16` CPU cores
  (`12` performance, `4` efficiency), `40` GPU cores, `48 GB` RAM
- Power state: AC connected, battery `80%`, not charging
- Display attached: built-in `3456 x 2234` Retina display
- Recorded viewport for every summarized lane: `800 x 600` logical,
  `1600 x 1200` physical, device-pixel-ratio `2.0`

## Harness Notes

- The repeat runner in `packages/tagflow_benchmarks` reuses
  `dart run melos run benchmark:profile` and copies only
  `examples/tagflow/build/integration_response_data.json` after each repeat.
- The current runner does not thread a `--profile-memory` output path through
  the repeated harness and does not preserve a durable VM service URI for
  reviewed snapshot checkpointing.
- Because of that runner shape, this worker used the documented direct
  `flutter drive --profile-memory=<file>` path for bounded JSON capture.
- `dart devtools --record-memory-profile` remained available locally, but it
  was not paired here because the short-lived benchmark sessions and repeated
  runner shape were not reliable for a reviewed checkpoint workflow.

## Commands

Repeat-5 baselines used this command shape from the repository root:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_DEVICE=macos \
TAGFLOW_PROFILE_PAIR=<renderer:fixture[,renderer:fixture...]> \
TAGFLOW_PROFILE_REPEAT=5 \
TAGFLOW_PROFILE_RUN_ID=<run-id> \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-memory-evidence \
TAGFLOW_PROFILE_CONTINUE_ON_FAILURE=true \
dart run melos run benchmark:profile:baselines
```

Every repeat-5 run was then summarized and checked with:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=<run-id> \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-memory-evidence \
dart run melos run benchmark:profile:summarize
```

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=<run-id> \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-memory-evidence \
TAGFLOW_PROFILE_CHECK_POLICY=docs/benchmarks/policies/profile-reference-runner-policy.json \
dart run melos run benchmark:profile:check
```

Run selections:

- `2026-06-12-memory-large-article-repeat5`:
  `tagflow:large_article`
- `2026-06-12-memory-table-stress-repeat5`:
  `tagflow:table_stress`
- `2026-06-12-memory-authored-insertion-repeat5`:
  `tagflow_semantic:streaming_ai_authored_insertions,tagflow_semantic_patch:streaming_ai_authored_insertion_patches`
- `2026-06-12-memory-native-large-article-repeat5`:
  `tagflow_native_json:native_large_article`

Bounded memory capture used this command shape from `examples/tagflow`:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
flutter drive \
  --driver=test_driver/perf_driver.dart \
  --target=integration_test/tagflow_perf_test.dart \
  -d macos \
  --profile \
  --dart-define=INTEGRATION_TEST_SHOULD_REPORT_RESULTS_TO_NATIVE=false \
  --dart-define=TAGFLOW_RENDERER=<renderer> \
  --dart-define=TAGFLOW_FIXTURE=<fixture> \
  --profile-memory=<absolute-output-file>
```

## Repeat-5 Profile Results

| Run id | Lane | Passed runs | Check result | GC summary | Exact caveats |
| --- | --- | ---: | --- | --- | --- |
| `2026-06-12-memory-large-article-repeat5` | `tagflow:large_article` | `5 / 5` | passed with `4` report-only outlier repeats | new-gen GC mean `2.0`, old-gen GC mean `0.0` | `coldInitialRender` recorded `3` missed build-budget frames and `5` missed raster-budget frames; checker outliers came from repeat-level raster over-budget findings |
| `2026-06-12-memory-table-stress-repeat5` | `tagflow:table_stress` | `5 / 5` | passed cleanly | new-gen GC mean `2.0`, old-gen GC mean `0.0` | `coldInitialRender` recorded `5` missed build-budget frames and `2` missed raster-budget frames even though the checker had no repeat-level outlier finding |
| `2026-06-12-memory-authored-insertion-repeat5` | `tagflow_semantic:streaming_ai_authored_insertions` | `5 / 5` | passed with `3` report-only outlier repeats | new-gen GC mean `2.0`, old-gen GC mean `0.0` | dynamic update summary recorded mean missed-raster count `0.6`; worst attributed update raster reached `17.412 ms` |
| `2026-06-12-memory-authored-insertion-repeat5` | `tagflow_semantic_patch:streaming_ai_authored_insertion_patches` | `5 / 5` | passed with `4` report-only outlier repeats | new-gen GC mean `2.0`, old-gen GC mean `0.0` | dynamic update summary recorded mean missed-raster count `0.8`; worst attributed update raster reached `17.633 ms` |
| `2026-06-12-memory-native-large-article-repeat5` | `tagflow_native_json:native_large_article` | `5 / 5` | passed cleanly | new-gen GC mean `2.0`, old-gen GC mean `0.0` | optional native-support lane only; `coldInitialRender` recorded `3` missed raster-budget frames |

Collection-integrity notes:

- All required repeat-5 runs completed without failed manifest entries.
- Every summarized lane reported `launchAttribution.status: available`.
- No summarized lane recorded any old-generation GC event in this pass.
- The dynamic authored-insertion baseline stayed paired inside the same run, so
  the control and patch path share one environment snapshot and one reviewed
  run id.

## Bounded Memory JSON

| Lane | Memory file | DevTools sample count | Command outcome |
| --- | --- | ---: | --- |
| `tagflow:large_article` | `build/benchmarks/profile-memory-evidence/2026-06-12-memory-large-article-repeat5/devtools/large-article-memory-profile.json` | `22` | `flutter drive` passed |
| `tagflow:table_stress` | `build/benchmarks/profile-memory-evidence/2026-06-12-memory-table-stress-repeat5/devtools/table-stress-memory-profile.json` | `35` | `flutter drive` passed |
| `tagflow_semantic:streaming_ai_authored_insertions` | `build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-repeat5/devtools/authored-insertion-control-memory-profile.json` | `14` | `flutter drive` passed |
| `tagflow_semantic_patch:streaming_ai_authored_insertion_patches` | `build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-repeat5/devtools/authored-insertion-patch-memory-profile.json` | `14` | `flutter drive` passed |
| `tagflow_native_json:native_large_article` | `build/benchmarks/profile-memory-evidence/2026-06-12-memory-native-large-article-repeat5/devtools/native-large-article-memory-profile.json` | `23` | `flutter drive` passed |

Command notes:

- Every direct memory capture printed `Failed to foreground app; open returned
  1`, but the benchmark session continued, produced the memory JSON file, and
  finished with `All tests passed.`
- `large_article` and the authored-insertion control capture also printed the
  engine warning `Reported frame time is older than the last one; clamping`.
- No direct memory capture failed to write its requested JSON file.

## Interpretation Limits

- This note proves that the current macOS runner can pair reviewable repeat-5
  benchmark baselines with bounded DevTools memory sample JSON for the required
  HTML lanes, the authored-insertion control/patch pair, and one optional
  native-support lane.
- This note does not prove allocation behavior. The bounded JSON exports do not
  replace before/after heap snapshots, class allocation diffs, or retained
  growth review.
- The native-support lane remains a separate `TagflowDocument` fixture path. It
  must not be compared directly with the HTML lanes as if it were the same
  parser/render workload.
- The environment is still prerelease Flutter on prerelease macOS, so this is
  not claim-grade reference-target evidence.

## Remaining Blockers Before Memory/Allocation Claims

1. Capture and export interactive DevTools checkpoints for the playbook stages:
   before render, after first render, after warm scroll, and after final patch
   for the patch lane.
2. Add class allocation diffs or equivalent retained-object review for
   `large_article`, `table_stress`, and the authored-insertion patch lane.
3. Review the dynamic update raster outliers before using any dynamic-content
   memory wording, even though old-gen GC remained `0.0` in this pass.
4. Promote the evidence only on a qualified stable reference environment and a
   qualified physical target set if the claim is not explicitly desktop-only.

## Review

This worker completed the smallest useful local memory evidence slice that the
current harness could support without inventing allocation claims. The repeat-5
profile baselines now exist for every required lane, and bounded DevTools
memory JSON exists for every required lane plus the optional native-support
lane. That is enough to replace the earlier feasibility-only posture for local
documentation.

The review boundary remains strict. What exists now is bounded sample capture
paired with repeat-based benchmark artifacts, not reviewed heap-state evidence.
Until the missing snapshots and allocation diffs are collected, any memory or
allocation statement must stay report-only and caveated.
