# 2026-06-12 Authored-Insertion Raw Heap Diff Evidence

This note records the first paired authored-insertion raw heap snapshot and
class-diff evidence collected from the live VM-service exporter added in
`8dec66e feat(benchmarks): export raw heap snapshots`.

It is report-only evidence. It does not prove leak freedom, does not replace
retained-object interpretation, and does not support public memory or
allocation claims by itself.

Raw JSON artifacts stayed under ignored `build/` output.

## Scope

- Branch context: `codex/tagflow-native-runtime-master`
- Collection commit:
  `8dec66e64dba51d9d47c4a40f13f67ffa58145ab`
- Device: local `macos` profile target
- `tagflow` version: `1.0.0-alpha.3`
- Flutter SDK: `3.45.0-0.1.pre (master)`
- Dart SDK: `3.11.0-81.0.dev`
- Host OS: `macOS 27.0 (26A5353q)`
- Repeat count: `1`
- Hold-open seconds: `30`
- Selection mode: explicit ordered pair list
- Exact lanes:
  - `tagflow_semantic:streaming_ai_authored_insertions`
  - `tagflow_semantic_patch:streaming_ai_authored_insertion_patches`
- Run id:
  `2026-06-12-memory-authored-insertion-raw-heap-diff-r1`

This note closes the authored-insertion raw heap/diff collection gap called
out in the roadmap after the earlier retained-path and class-growth reviews:

- [`2026-06-12-authored-insertion-control-multi-checkpoint-retained-paths.md`](2026-06-12-authored-insertion-control-multi-checkpoint-retained-paths.md)
- [`2026-06-12-authored-insertion-patch-multi-checkpoint-retained-paths.md`](2026-06-12-authored-insertion-patch-multi-checkpoint-retained-paths.md)
- [`2026-06-12-authored-insertion-class-growth-review.md`](2026-06-12-authored-insertion-class-growth-review.md)

Broader beta memory wording still remains blocked until the reviewed scope is
decided for the other required HTML lanes.

## Commands

Watcher-driven paired profile run:

```bash
RUN_ID=2026-06-12-memory-authored-insertion-raw-heap-diff-r1
OUT=build/benchmarks/profile-memory-evidence
PATH=/Users/arya/fvm/cache.git/bin:$PATH
export TAGFLOW_MEMORY_EVIDENCE_RETAINING_CLASSES=TagflowDocumentNode,TagflowDocument
export TAGFLOW_MEMORY_EVIDENCE_RETAINING_SAMPLE_LIMIT=1
export TAGFLOW_MEMORY_EVIDENCE_RETAINING_PATH_LIMIT=20
export TAGFLOW_MEMORY_EVIDENCE_WRITE_RAW_HEAP=true

(
  TAGFLOW_PROFILE_DEVICE=macos \
  TAGFLOW_PROFILE_PAIR=tagflow_semantic:streaming_ai_authored_insertions,tagflow_semantic_patch:streaming_ai_authored_insertion_patches \
  TAGFLOW_PROFILE_REPEAT=1 \
  TAGFLOW_PROFILE_RUN_ID="$RUN_ID" \
  TAGFLOW_PROFILE_OUTPUT_DIR="$OUT" \
  TAGFLOW_PROFILE_CONTINUE_ON_FAILURE=true \
  TAGFLOW_PROFILE_MEMORY=true \
  TAGFLOW_PROFILE_HOLD_OPEN=true \
  TAGFLOW_PROFILE_HOLD_OPEN_SECONDS=30 \
  dart run melos run benchmark:profile:baselines 2>&1
) | tee "$OUT/$RUN_ID/watcher.log" | while IFS= read -r line; do
  printf '%s\n' "$line"
  if [[ "$line" == *"VMServiceFlutterDriver: Connecting to Flutter application at "* ]]; then
    VM_URI="${line##* at }"
    continue
  fi
  if [[ "$line" == *"[tagflow-profile-checkpoint]"* && "$line" == *"action=attach-devtools"* ]]; then
    renderer_part="${line#*renderer=}"
    renderer="${renderer_part%% *}"
    fixture_part="${line#*fixture=}"
    fixture="${fixture_part%% *}"
    checkpoint_part="${line#*checkpoint=}"
    checkpoint="${checkpoint_part%% *}"
    automated_checkpoint="${renderer}-${fixture}-repeat-01-${checkpoint}"
    TAGFLOW_MEMORY_EVIDENCE_VM_SERVICE_URI="$VM_URI" \
    TAGFLOW_MEMORY_EVIDENCE_CHECKPOINT="$automated_checkpoint" \
    TAGFLOW_MEMORY_EVIDENCE_OUTPUT_DIR="$OUT/$RUN_ID/devtools" \
    TAGFLOW_MEMORY_EVIDENCE_WRITE_RAW_HEAP=true \
    dart run melos run benchmark:memory-evidence:export
  fi
done
```

Raw heap snapshot diff generation:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH
cd packages/tagflow_benchmarks

dart run bin/export_memory_evidence.dart \
  --diff-base=/Users/arya/.codex/worktrees/9425/tagflow/build/benchmarks/profile-memory-evidence/$RUN_ID/devtools/tagflow_semantic-streaming_ai_authored_insertions-repeat-01-before_first_update-heap-snapshot.json \
  --diff-head=/Users/arya/.codex/worktrees/9425/tagflow/build/benchmarks/profile-memory-evidence/$RUN_ID/devtools/tagflow_semantic-streaming_ai_authored_insertions-repeat-01-after_final_update-heap-snapshot.json \
  --diff-output=/Users/arya/.codex/worktrees/9425/tagflow/build/benchmarks/profile-memory-evidence/$RUN_ID/devtools/tagflow_semantic-streaming_ai_authored_insertions-repeat-01-before_first_update-to-after_final_update-allocation-diff.json \
  --diff-classes=TagflowDocumentNode,TagflowDocument

dart run bin/export_memory_evidence.dart \
  --diff-base=/Users/arya/.codex/worktrees/9425/tagflow/build/benchmarks/profile-memory-evidence/$RUN_ID/devtools/tagflow_semantic-streaming_ai_authored_insertions-repeat-01-before_first_update-heap-snapshot.json \
  --diff-head=/Users/arya/.codex/worktrees/9425/tagflow/build/benchmarks/profile-memory-evidence/$RUN_ID/devtools/tagflow_semantic-streaming_ai_authored_insertions-repeat-01-after_scroll-heap-snapshot.json \
  --diff-output=/Users/arya/.codex/worktrees/9425/tagflow/build/benchmarks/profile-memory-evidence/$RUN_ID/devtools/tagflow_semantic-streaming_ai_authored_insertions-repeat-01-before_first_update-to-after_scroll-allocation-diff.json \
  --diff-classes=TagflowDocumentNode,TagflowDocument

dart run bin/export_memory_evidence.dart \
  --diff-base=/Users/arya/.codex/worktrees/9425/tagflow/build/benchmarks/profile-memory-evidence/$RUN_ID/devtools/tagflow_semantic_patch-streaming_ai_authored_insertion_patches-repeat-01-before_first_patch-heap-snapshot.json \
  --diff-head=/Users/arya/.codex/worktrees/9425/tagflow/build/benchmarks/profile-memory-evidence/$RUN_ID/devtools/tagflow_semantic_patch-streaming_ai_authored_insertion_patches-repeat-01-after_final_patch-heap-snapshot.json \
  --diff-output=/Users/arya/.codex/worktrees/9425/tagflow/build/benchmarks/profile-memory-evidence/$RUN_ID/devtools/tagflow_semantic_patch-streaming_ai_authored_insertion_patches-repeat-01-before_first_patch-to-after_final_patch-allocation-diff.json \
  --diff-classes=TagflowDocumentNode,TagflowDocument

dart run bin/export_memory_evidence.dart \
  --diff-base=/Users/arya/.codex/worktrees/9425/tagflow/build/benchmarks/profile-memory-evidence/$RUN_ID/devtools/tagflow_semantic_patch-streaming_ai_authored_insertion_patches-repeat-01-before_first_patch-heap-snapshot.json \
  --diff-head=/Users/arya/.codex/worktrees/9425/tagflow/build/benchmarks/profile-memory-evidence/$RUN_ID/devtools/tagflow_semantic_patch-streaming_ai_authored_insertion_patches-repeat-01-after_scroll-heap-snapshot.json \
  --diff-output=/Users/arya/.codex/worktrees/9425/tagflow/build/benchmarks/profile-memory-evidence/$RUN_ID/devtools/tagflow_semantic_patch-streaming_ai_authored_insertion_patches-repeat-01-before_first_patch-to-after_scroll-allocation-diff.json \
  --diff-classes=TagflowDocumentNode,TagflowDocument
```

Summary:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=2026-06-12-memory-authored-insertion-raw-heap-diff-r1 \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-memory-evidence \
dart run melos run benchmark:profile:summarize
```

Result: passed and wrote `profile-baseline-summary.json`.

Check:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=2026-06-12-memory-authored-insertion-raw-heap-diff-r1 \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-memory-evidence \
TAGFLOW_PROFILE_MIN_REPEATS=1 \
dart run melos run benchmark:profile:check
```

Result: passed with no blocking issues. One report-only finding remained for
the patch lane: `memory_allocation_evidence_required`.

## Run Result

- `2 / 2` profile cells passed
- both cells captured bounded `--profile-memory` JSON
- both cells recorded live VM-service URIs in
  `memory-evidence-manifest.json`
- both cells exported raw heap snapshots, class-level heap summaries,
  allocation profiles, and retained-path JSON at all named checkpoints
- no old-gen GC was summarized for either lane
- `outlierRepeats: []` for both cells

Recorded VM-service URIs:

- Control:
  `http://127.0.0.1:58876/H_3kj__GS1I=/`
- Patch:
  `http://127.0.0.1:59099/o7rtCevm17M=/`

## Artifacts

Run-level artifacts:

```text
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-raw-heap-diff-r1/profile-baseline-manifest.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-raw-heap-diff-r1/profile-baseline-summary.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-raw-heap-diff-r1/memory-evidence-manifest.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-raw-heap-diff-r1/watcher.log
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-raw-heap-diff-r1/tagflow_semantic/streaming_ai_authored_insertions/repeat-01.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-raw-heap-diff-r1/tagflow_semantic/streaming_ai_authored_insertions/repeat-01-memory.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-raw-heap-diff-r1/tagflow_semantic/streaming_ai_authored_insertions/repeat-01.log
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-raw-heap-diff-r1/tagflow_semantic_patch/streaming_ai_authored_insertion_patches/repeat-01.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-raw-heap-diff-r1/tagflow_semantic_patch/streaming_ai_authored_insertion_patches/repeat-01-memory.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-raw-heap-diff-r1/tagflow_semantic_patch/streaming_ai_authored_insertion_patches/repeat-01.log
```

Checkpoint export stems written under
`build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-raw-heap-diff-r1/devtools/`:

```text
tagflow_semantic-streaming_ai_authored_insertions-repeat-01-before_first_update
tagflow_semantic-streaming_ai_authored_insertions-repeat-01-after_first_update
tagflow_semantic-streaming_ai_authored_insertions-repeat-01-after_final_update
tagflow_semantic-streaming_ai_authored_insertions-repeat-01-after_scroll
tagflow_semantic_patch-streaming_ai_authored_insertion_patches-repeat-01-before_first_patch
tagflow_semantic_patch-streaming_ai_authored_insertion_patches-repeat-01-after_first_patch
tagflow_semantic_patch-streaming_ai_authored_insertion_patches-repeat-01-after_final_patch
tagflow_semantic_patch-streaming_ai_authored_insertion_patches-repeat-01-after_scroll
```

Each checkpoint stem wrote these exact suffixes:

- `-allocation-profile.json`
- `-heap-summary.json`
- `-heap-snapshot.json`
- `-retaining-paths.json`

Generated raw heap diff artifacts:

```text
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-raw-heap-diff-r1/devtools/tagflow_semantic-streaming_ai_authored_insertions-repeat-01-before_first_update-to-after_final_update-allocation-diff.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-raw-heap-diff-r1/devtools/tagflow_semantic-streaming_ai_authored_insertions-repeat-01-before_first_update-to-after_scroll-allocation-diff.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-raw-heap-diff-r1/devtools/tagflow_semantic_patch-streaming_ai_authored_insertion_patches-repeat-01-before_first_patch-to-after_final_patch-allocation-diff.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-raw-heap-diff-r1/devtools/tagflow_semantic_patch-streaming_ai_authored_insertion_patches-repeat-01-before_first_patch-to-after_scroll-allocation-diff.json
```

## Raw Heap Diff Review

All four generated diff files used raw heap snapshot inputs, so each diff
reported complete coverage:

```json
{
  "base": "rawHeapSnapshot",
  "head": "rawHeapSnapshot",
  "complete": true
}
```

Control lane, `before_first_update -> after_scroll`:

- heap-summary object count: `198134 -> 197616`, delta `-518`
- heap-summary shallow bytes: `23804080 -> 23740960`, delta `-63120`
- `TagflowDocumentNode`: `12 -> 29`, delta `+17` instances and `+2720`
  shallow bytes
- `TagflowDocument`: `1 -> 3`, delta `+2` instances and `+96` shallow bytes
- largest positive diff rows were runtime/core containers rather than Tagflow
  document classes:
  `_List +68`, `_Uint32List +65`, `_Map +65`, `UnmodifiableMapView +53`

Control lane, `before_first_update -> after_final_update` matched the same
selected Tagflow class deltas:

- `TagflowDocumentNode`: `+17` instances and `+2720` shallow bytes
- `TagflowDocument`: `+2` instances and `+96` shallow bytes

Patch lane, `before_first_patch -> after_scroll`:

- heap-summary object count: `198166 -> 197249`, delta `-917`
- heap-summary shallow bytes: `23806752 -> 23720464`, delta `-86288`
- `TagflowDocumentNode`: `13 -> 15`, delta `+2` instances and `+320`
  shallow bytes
- `TagflowDocument`: `2 -> 4`, delta `+2` instances and `+96` shallow bytes
- largest positive diff rows again stayed in runtime/core containers:
  `_List +8`, `_Uint32List +5`, `_Closure +6`, `_Map +5`

Patch lane, `before_first_patch -> after_final_patch` matched the same
selected Tagflow class deltas:

- `TagflowDocumentNode`: `+2` instances and `+320` shallow bytes
- `TagflowDocument`: `+2` instances and `+96` shallow bytes

## Interpretation

This run provides the previously missing authored-insertion raw heap/diff
evidence slice:

- The control and patch lanes both now have same-run raw heap snapshots at all
  named checkpoints.
- The paired diff files were generated from raw snapshot inputs rather than
  summary-only rows, so the diff coverage is complete for class-count and
  shallow-size comparison.
- The patch lane remains materially smaller than the control lane for the
  selected Tagflow classes in the before-to-after diff:
  `TagflowDocumentNode +2` for patch versus `+17` for control.
- Both lanes ended with lower total object counts and lower heap-summary
  shallow bytes than their corresponding before checkpoints, even though the
  selected Tagflow document classes increased modestly.

These exports still do not prove leak freedom or a promotion-ready memory
story:

- retained-path interpretation remains reviewer work, even though bounded
  retained-path JSON was exported alongside the raw snapshots
- the note only covers the authored-insertion control/patch pair
- the broader playbook still lists `tagflow:large_article` and
  `tagflow:table_stress` as required HTML memory/allocation lanes

## Remaining Blocker

The authored-insertion control/patch raw heap/diff gap is closed for local
macOS report-only review. Beta memory wording still should not advance as a
broader Tagflow claim until one of these happens:

- equivalent reviewed raw heap/diff evidence is collected for
  `tagflow:large_article` and `tagflow:table_stress`, or
- the intended wording is narrowed to the authored-insertion dynamic-update
  lane and reviewed accordingly
