# 2026-06-12 Authored-Insertion Checkpoint Memory Evidence

This note records the first named-checkpoint VM-service memory exports for the
authored-insertion control/patch pair in the native rich-content benchmark
harness.

It is report-only evidence. It does not set thresholds, does not support public
memory or allocation claims, and does not replace retained-object review or raw
DevTools heap/diff exports.

Raw profile artifacts, bounded `--profile-memory` JSON, heap summaries, and
allocation profiles stayed under ignored `build/` output.

## Scope

- Branch context: `codex/tagflow-native-runtime-master`
- Collection commit:
  `3b4fb028401758f2f478b450319a08b295e19420`
- Device: local `macos` profile target
- `tagflow` version: `1.0.0-alpha.3`
- Flutter SDK: `3.45.0-0.1.pre (master)`
- Dart SDK: `3.11.0-81.0.dev`
- Host OS: `macOS 27.0 (26A5353q)`
- Repeat count: `1`
- Hold-open seconds: `45`
- Selection mode: explicit ordered pairs

Exact supported authored-insertion pair:

- Control: `tagflow_semantic:streaming_ai_authored_insertions`
- Patch: `tagflow_semantic_patch:streaming_ai_authored_insertion_patches`

Checkpoint names:

- Control: `before_first_update`, `after_first_update`,
  `after_final_update`, `after_scroll`
- Patch: `before_first_patch`, `after_first_patch`, `after_final_patch`,
  `after_scroll`

## Commands

Primary paired profile run:

```bash
RUN_ID=2026-06-12-memory-authored-insertion-checkpoints
OUT=build/benchmarks/profile-memory-evidence
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_DEVICE=macos \
TAGFLOW_PROFILE_PAIR=tagflow_semantic:streaming_ai_authored_insertions,tagflow_semantic_patch:streaming_ai_authored_insertion_patches \
TAGFLOW_PROFILE_REPEAT=1 \
TAGFLOW_PROFILE_RUN_ID="$RUN_ID" \
TAGFLOW_PROFILE_OUTPUT_DIR="$OUT" \
TAGFLOW_PROFILE_CONTINUE_ON_FAILURE=true \
TAGFLOW_PROFILE_MEMORY=true \
TAGFLOW_PROFILE_HOLD_OPEN=true \
TAGFLOW_PROFILE_HOLD_OPEN_SECONDS=45 \
dart run melos run benchmark:profile:baselines
```

Primary run summary/check:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=2026-06-12-memory-authored-insertion-checkpoints \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-memory-evidence \
dart run melos run benchmark:profile:summarize
```

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=2026-06-12-memory-authored-insertion-checkpoints \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-memory-evidence \
TAGFLOW_PROFILE_MIN_REPEATS=1 \
dart run melos run benchmark:profile:check
```

The primary check passed with no issues. It emitted the expected report-only
`memory_allocation_evidence_required` finding for
`tagflow_semantic_patch:streaming_ai_authored_insertion_patches`.

Supplemental control-only run for the missed control `after_scroll` export:

```bash
RUN_ID=2026-06-12-memory-authored-insertion-control-after-scroll
OUT=build/benchmarks/profile-memory-evidence
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_DEVICE=macos \
TAGFLOW_PROFILE_PAIR=tagflow_semantic:streaming_ai_authored_insertions \
TAGFLOW_PROFILE_REPEAT=1 \
TAGFLOW_PROFILE_RUN_ID="$RUN_ID" \
TAGFLOW_PROFILE_OUTPUT_DIR="$OUT" \
TAGFLOW_PROFILE_CONTINUE_ON_FAILURE=true \
TAGFLOW_PROFILE_MEMORY=true \
TAGFLOW_PROFILE_HOLD_OPEN=true \
TAGFLOW_PROFILE_HOLD_OPEN_SECONDS=45 \
dart run melos run benchmark:profile:baselines
```

Supplemental summary/check both passed after rerunning the check sequentially.
The first check attempt raced summary generation and failed because
`profile-baseline-summary.json` did not exist yet.

Each checkpoint export used this command shape with the streamed VM service URI
and the checkpoint label shown in the export table:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_MEMORY_EVIDENCE_VM_SERVICE_URI=<streamed-vm-service-uri> \
TAGFLOW_MEMORY_EVIDENCE_CHECKPOINT=<checkpoint-label> \
TAGFLOW_MEMORY_EVIDENCE_OUTPUT_DIR=<run-dir>/devtools \
dart run melos run benchmark:memory-evidence:export
```

## Streamed URI Evidence

The primary run streamed the control VM service URI before the control
checkpoint markers:

```text
VMServiceFlutterDriver: Connecting to Flutter application at http://127.0.0.1:59390/rn-f80Z9bQQ=/
flutter: [tagflow-profile-checkpoint] renderer=tagflow_semantic fixture=streaming_ai_authored_insertions checkpoint=before_first_update hold_open_seconds=45 action=attach-devtools
```

The primary run streamed the patch VM service URI before the patch checkpoint
markers:

```text
VMServiceFlutterDriver: Connecting to Flutter application at http://127.0.0.1:60324/PhOBUCCY0Y8=/
flutter: [tagflow-profile-checkpoint] renderer=tagflow_semantic_patch fixture=streaming_ai_authored_insertion_patches checkpoint=before_first_patch hold_open_seconds=45 action=attach-devtools
```

The supplemental run streamed the control VM service URI used for the final
control `after_scroll` export:

```text
VMServiceFlutterDriver: Connecting to Flutter application at http://127.0.0.1:60769/bFvLjEs7cHo=/
flutter: [tagflow-profile-checkpoint] renderer=tagflow_semantic fixture=streaming_ai_authored_insertions checkpoint=after_scroll hold_open_seconds=45 action=attach-devtools
```

One primary control `after_scroll` export attempt failed with
`SocketException: Connection refused` after the hold had already completed. The
supplemental control-only run above captured that checkpoint successfully.

## Profile Results

Primary run id:
`2026-06-12-memory-authored-insertion-checkpoints`

- `2 / 2` profile cells passed.
- Both cells wrote bounded `--profile-memory` JSON.
- Both cells recorded `newGenGcCount.total: 2` and `oldGenGcCount.total: 0`.
- Both cells recorded `800 x 600` logical viewport at device-pixel-ratio `2.0`.
- Both cells had no `outlierRepeats`.

Primary raw artifact paths:

```text
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-checkpoints/profile-baseline-manifest.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-checkpoints/profile-baseline-summary.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-checkpoints/memory-evidence-manifest.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-checkpoints/tagflow_semantic/streaming_ai_authored_insertions/repeat-01.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-checkpoints/tagflow_semantic/streaming_ai_authored_insertions/repeat-01-memory.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-checkpoints/tagflow_semantic/streaming_ai_authored_insertions/repeat-01.log
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-checkpoints/tagflow_semantic_patch/streaming_ai_authored_insertion_patches/repeat-01.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-checkpoints/tagflow_semantic_patch/streaming_ai_authored_insertion_patches/repeat-01-memory.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-checkpoints/tagflow_semantic_patch/streaming_ai_authored_insertion_patches/repeat-01.log
```

Supplemental run id:
`2026-06-12-memory-authored-insertion-control-after-scroll`

- `1 / 1` control cell passed.
- The run exists only to provide a live VM-service export for control
  `after_scroll` after the primary export was missed.

## VM-Service Exports

| Lane | Checkpoint | Run id | Export status | Heap summary | Allocation profile |
| --- | --- | --- | --- | --- | --- |
| Control | `before_first_update` | `2026-06-12-memory-authored-insertion-checkpoints` | passed | `devtools/tagflow_semantic-streaming_ai_authored_insertions-repeat-01-before_first_update-heap-summary.json` | `devtools/tagflow_semantic-streaming_ai_authored_insertions-repeat-01-before_first_update-allocation-profile.json` |
| Control | `after_first_update` | `2026-06-12-memory-authored-insertion-checkpoints` | passed | `devtools/tagflow_semantic-streaming_ai_authored_insertions-repeat-01-after_first_update-heap-summary.json` | `devtools/tagflow_semantic-streaming_ai_authored_insertions-repeat-01-after_first_update-allocation-profile.json` |
| Control | `after_final_update` | `2026-06-12-memory-authored-insertion-checkpoints` | passed | `devtools/tagflow_semantic-streaming_ai_authored_insertions-repeat-01-after_final_update-heap-summary.json` | `devtools/tagflow_semantic-streaming_ai_authored_insertions-repeat-01-after_final_update-allocation-profile.json` |
| Control | `after_scroll` | `2026-06-12-memory-authored-insertion-control-after-scroll` | passed | `devtools/tagflow_semantic-streaming_ai_authored_insertions-repeat-01-after_scroll-heap-summary.json` | `devtools/tagflow_semantic-streaming_ai_authored_insertions-repeat-01-after_scroll-allocation-profile.json` |
| Patch | `before_first_patch` | `2026-06-12-memory-authored-insertion-checkpoints` | passed | `devtools/tagflow_semantic_patch-streaming_ai_authored_insertion_patches-repeat-01-before_first_patch-heap-summary.json` | `devtools/tagflow_semantic_patch-streaming_ai_authored_insertion_patches-repeat-01-before_first_patch-allocation-profile.json` |
| Patch | `after_first_patch` | `2026-06-12-memory-authored-insertion-checkpoints` | passed | `devtools/tagflow_semantic_patch-streaming_ai_authored_insertion_patches-repeat-01-after_first_patch-heap-summary.json` | `devtools/tagflow_semantic_patch-streaming_ai_authored_insertion_patches-repeat-01-after_first_patch-allocation-profile.json` |
| Patch | `after_final_patch` | `2026-06-12-memory-authored-insertion-checkpoints` | passed | `devtools/tagflow_semantic_patch-streaming_ai_authored_insertion_patches-repeat-01-after_final_patch-heap-summary.json` | `devtools/tagflow_semantic_patch-streaming_ai_authored_insertion_patches-repeat-01-after_final_patch-allocation-profile.json` |
| Patch | `after_scroll` | `2026-06-12-memory-authored-insertion-checkpoints` | passed | `devtools/tagflow_semantic_patch-streaming_ai_authored_insertion_patches-repeat-01-after_scroll-heap-summary.json` | `devtools/tagflow_semantic_patch-streaming_ai_authored_insertion_patches-repeat-01-after_scroll-allocation-profile.json` |

All export commands returned exit status `0` except the intentionally recorded
missed primary control `after_scroll` attempt.

## Reviewed Heap/Allocation Summary

The VM-service exporter requested service GC before `getAllocationProfile` and
then wrote a class-level heap summary for each checkpoint. Across the eight
successful checkpoint exports:

- Heap summary `objectCount`: `196415` to `198170`
- Heap summary `classCount`: `1119` to `1124`
- Heap summary `shallowSize`: `23661120` to `23805712`
- Heap summary `capacity`: `25242384` to `26815248`
- Allocation profile `memoryUsage.heapUsage`: `12587728` to `12639696`
- Allocation profile `memoryUsage.heapCapacity`: `14204928` to `16760832`
- Allocation profile `memoryUsage.externalUsage`: `880` or `976`
- Allocation profile class heap-stat entries: `3956`
- Largest shallow-size class in every heap summary:
  `InstructionsSection`, `2` instances, `5531296` shallow bytes

Checkpoint details:

| Export | Objects | Shallow size | Heap usage |
| --- | ---: | ---: | ---: |
| `control/before_first_update` | `198127` | `23802144` | `12599280` |
| `control/after_first_update` | `196415` | `23661120` | `12587728` |
| `control/after_final_update` | `197180` | `23711040` | `12634928` |
| `control/after_scroll` | `198144` | `23803072` | `12600208` |
| `patch/before_first_patch` | `198170` | `23805712` | `12602800` |
| `patch/after_first_patch` | `196616` | `23674016` | `12600576` |
| `patch/after_final_patch` | `197185` | `23712432` | `12638992` |
| `patch/after_scroll` | `197197` | `23713136` | `12639696` |

## Interpretation

- This closes the immediate local harness gap for named-checkpoint VM-service
  exports on the authored-insertion control/patch pair.
- The primary paired timing run is complete and checked, but one control memory
  export came from a supplemental control-only run because the first
  `after_scroll` export missed the active hold window.
- The class-level summaries are stable enough to review as report-only local
  evidence, but they are not allocation diffs and do not identify retained
  growth.
- The environment is prerelease Flutter on prerelease macOS, so it remains
  unsuitable for public benchmark claims.

## Remaining Gaps Before Claims

- Capture retained-object review or raw DevTools heap/diff exports where
  class-level VM-service summaries are insufficient.
- Repeat the evidence on a qualified stable reference environment.
- Collect qualified physical iOS and Android profile evidence if the claim is
  not explicitly desktop-only.
- Keep dynamic update wording report-only until repeat counts, outlier policy,
  and memory evidence are promoted through the threshold/reference policy.
