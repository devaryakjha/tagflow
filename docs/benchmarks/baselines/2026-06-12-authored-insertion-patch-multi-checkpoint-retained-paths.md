# 2026-06-12 Authored-Insertion Patch Multi-Checkpoint Retained Paths

This note records a same-process retained-path review for the authored-
insertion patch lane across all patch checkpoints:

- `before_first_patch`
- `after_first_patch`
- `after_final_patch`
- `after_scroll`

It is report-only evidence. It does not prove leak freedom, does not replace
raw DevTools heap snapshots or heap diffs, and does not support public memory
or allocation claims.

Raw JSON artifacts stayed under ignored `build/` output.

## Scope

- Branch context: `codex/tagflow-native-runtime-master`
- Collection commit:
  `389b08050390597361f313096d58ce19e8aaec6a`
- Device: local `macos` profile target
- `tagflow` version: `1.0.0-alpha.3`
- Flutter SDK: `3.45.0-0.1.pre (master)`
- Dart SDK: `3.11.0-81.0.dev`
- Host OS: `macOS 27.0 (26A5353q)`
- Repeat count: `1`
- Hold-open seconds: `45`
- Selection mode: explicit ordered pair list with one patch cell
- Exact lane:
  `tagflow_semantic_patch:streaming_ai_authored_insertion_patches`
- Run id:
  `2026-06-12-memory-authored-insertion-patch-multi-checkpoint-retained-paths-r1`

## Commands

The profile run used a local watcher keyed off the streamed VM service URI and
the patch checkpoint attach markers. The watcher exported retained-path
evidence during each live hold window rather than rerunning the harness for
each checkpoint.

Watcher-driven profile run:

```bash
RUN_ID=2026-06-12-memory-authored-insertion-patch-multi-checkpoint-retained-paths-r1
OUT=build/benchmarks/profile-memory-evidence
PATH=/Users/arya/fvm/cache.git/bin:$PATH

TAGFLOW_PROFILE_DEVICE=macos \
TAGFLOW_PROFILE_PAIR=tagflow_semantic_patch:streaming_ai_authored_insertion_patches \
TAGFLOW_PROFILE_REPEAT=1 \
TAGFLOW_PROFILE_RUN_ID="$RUN_ID" \
TAGFLOW_PROFILE_OUTPUT_DIR="$OUT" \
TAGFLOW_PROFILE_CONTINUE_ON_FAILURE=true \
TAGFLOW_PROFILE_MEMORY=true \
TAGFLOW_PROFILE_HOLD_OPEN=true \
TAGFLOW_PROFILE_HOLD_OPEN_SECONDS=45 \
dart run melos run benchmark:profile:baselines
```

Watcher export command shape, triggered once per checkpoint after the streamed
`action=attach-devtools` marker appeared:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_MEMORY_EVIDENCE_VM_SERVICE_URI=http://127.0.0.1:53771/MJfRMm_lVd8=/ \
TAGFLOW_MEMORY_EVIDENCE_CHECKPOINT=<patch-checkpoint-label> \
TAGFLOW_MEMORY_EVIDENCE_OUTPUT_DIR=build/benchmarks/profile-memory-evidence/$RUN_ID/devtools \
TAGFLOW_MEMORY_EVIDENCE_RETAINING_CLASSES=TagflowDocumentNode,TagflowDocument \
TAGFLOW_MEMORY_EVIDENCE_RETAINING_SAMPLE_LIMIT=1 \
TAGFLOW_MEMORY_EVIDENCE_RETAINING_PATH_LIMIT=20 \
dart run melos run benchmark:memory-evidence:export
```

Summary:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=2026-06-12-memory-authored-insertion-patch-multi-checkpoint-retained-paths-r1 \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-memory-evidence \
dart run melos run benchmark:profile:summarize
```

Result: passed and wrote `profile-baseline-summary.json`.

Check:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=2026-06-12-memory-authored-insertion-patch-multi-checkpoint-retained-paths-r1 \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-memory-evidence \
TAGFLOW_PROFILE_MIN_REPEATS=1 \
dart run melos run benchmark:profile:check
```

Result: passed when run after summary generation. One earlier parallelized
check attempt failed with `PathNotFoundException` because
`profile-baseline-summary.json` did not exist yet.

## Streamed Same-Process Evidence

The live run recorded one VM service URI for the patch process:

```text
VMServiceFlutterDriver: Connecting to Flutter application at http://127.0.0.1:53771/MJfRMm_lVd8=/
```

The same run log then emitted all four checkpoint attach markers in order:

```text
flutter: [tagflow-profile-checkpoint] renderer=tagflow_semantic_patch fixture=streaming_ai_authored_insertion_patches checkpoint=before_first_patch hold_open_seconds=45 action=attach-devtools
flutter: [tagflow-profile-checkpoint] renderer=tagflow_semantic_patch fixture=streaming_ai_authored_insertion_patches checkpoint=after_first_patch hold_open_seconds=45 action=attach-devtools
flutter: [tagflow-profile-checkpoint] renderer=tagflow_semantic_patch fixture=streaming_ai_authored_insertion_patches checkpoint=after_final_patch hold_open_seconds=45 action=attach-devtools
flutter: [tagflow-profile-checkpoint] renderer=tagflow_semantic_patch fixture=streaming_ai_authored_insertion_patches checkpoint=after_scroll hold_open_seconds=45 action=attach-devtools
```

All four automated exports completed against that same live URI:
`http://127.0.0.1:53771/MJfRMm_lVd8=/`.

## Profile Result

- `1 / 1` profile cells passed
- bounded `--profile-memory` JSON was captured
- `newGenGcCount.total: 2`
- `oldGenGcCount.total: 0`
- viewport: `800 x 600 @ 2.0x`
- update chunks observed: `4`
- `updateSummary.maxElapsedMillis: 118.359`
- worst attributed update frame:
  `buildMillis 5.35`, `rasterMillis 21.995`

The sequential checker pass returned no blocking issues and recorded two
report-only findings:

- `outlier_repeat_present`
- `memory_allocation_evidence_required`

## Artifacts

Run-level artifacts:

```text
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-patch-multi-checkpoint-retained-paths-r1/profile-baseline-manifest.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-patch-multi-checkpoint-retained-paths-r1/profile-baseline-summary.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-patch-multi-checkpoint-retained-paths-r1/memory-evidence-manifest.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-patch-multi-checkpoint-retained-paths-r1/tagflow_semantic_patch/streaming_ai_authored_insertion_patches/repeat-01.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-patch-multi-checkpoint-retained-paths-r1/tagflow_semantic_patch/streaming_ai_authored_insertion_patches/repeat-01-memory.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-patch-multi-checkpoint-retained-paths-r1/tagflow_semantic_patch/streaming_ai_authored_insertion_patches/repeat-01.log
```

Checkpoint export artifacts:

```text
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-patch-multi-checkpoint-retained-paths-r1/devtools/tagflow_semantic_patch-streaming_ai_authored_insertion_patches-repeat-01-before_first_patch-heap-summary.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-patch-multi-checkpoint-retained-paths-r1/devtools/tagflow_semantic_patch-streaming_ai_authored_insertion_patches-repeat-01-before_first_patch-allocation-profile.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-patch-multi-checkpoint-retained-paths-r1/devtools/tagflow_semantic_patch-streaming_ai_authored_insertion_patches-repeat-01-before_first_patch-retaining-paths.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-patch-multi-checkpoint-retained-paths-r1/devtools/tagflow_semantic_patch-streaming_ai_authored_insertion_patches-repeat-01-after_first_patch-heap-summary.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-patch-multi-checkpoint-retained-paths-r1/devtools/tagflow_semantic_patch-streaming_ai_authored_insertion_patches-repeat-01-after_first_patch-allocation-profile.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-patch-multi-checkpoint-retained-paths-r1/devtools/tagflow_semantic_patch-streaming_ai_authored_insertion_patches-repeat-01-after_first_patch-retaining-paths.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-patch-multi-checkpoint-retained-paths-r1/devtools/tagflow_semantic_patch-streaming_ai_authored_insertion_patches-repeat-01-after_final_patch-heap-summary.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-patch-multi-checkpoint-retained-paths-r1/devtools/tagflow_semantic_patch-streaming_ai_authored_insertion_patches-repeat-01-after_final_patch-allocation-profile.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-patch-multi-checkpoint-retained-paths-r1/devtools/tagflow_semantic_patch-streaming_ai_authored_insertion_patches-repeat-01-after_final_patch-retaining-paths.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-patch-multi-checkpoint-retained-paths-r1/devtools/tagflow_semantic_patch-streaming_ai_authored_insertion_patches-repeat-01-after_scroll-heap-summary.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-patch-multi-checkpoint-retained-paths-r1/devtools/tagflow_semantic_patch-streaming_ai_authored_insertion_patches-repeat-01-after_scroll-allocation-profile.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-patch-multi-checkpoint-retained-paths-r1/devtools/tagflow_semantic_patch-streaming_ai_authored_insertion_patches-repeat-01-after_scroll-retaining-paths.json
```

## Retained-Path Review

Top shallow-size classes stayed VM/runtime dominated at every checkpoint:
`InstructionsSection`, `Code`, `_OneByteString`, `CodeSourceMap`, and
`Function`.

Checkpoint summary:

| Checkpoint | Objects | Shallow bytes | Heap usage | `TagflowDocumentNode` | `TagflowDocument` |
| --- | ---: | ---: | ---: | ---: | ---: |
| `before_first_patch` | `198153` | `23804480` | `12601568` | `13` / `2080` bytes | `2` / `96` bytes |
| `after_first_patch` | `196679` | `23678912` | `12602752` | `14` / `2240` bytes | `3` / `144` bytes |
| `after_final_patch` | `197226` | `23717856` | `12644416` | `15` / `2400` bytes | `4` / `192` bytes |
| `after_scroll` | `197286` | `23721312` | `12645152` | `15` / `2400` bytes | `4` / `192` bytes |

Same-process aggregate movement from `before_first_patch` to `after_scroll`:

- object count: `198153 -> 197286`, delta `-867`
- heap-summary shallow bytes: `23804480 -> 23721312`, delta `-83168`
- allocation-profile heap usage: `12601568 -> 12645152`, delta `+43584`
- `TagflowDocumentNode`: `13 -> 15`, delta `+2` instances and `+320` bytes
- `TagflowDocument`: `2 -> 4`, delta `+2` instances and `+96` bytes

Retaining-path shape was stable across all four checkpoint samples.

`TagflowDocumentNode` review:

- library:
  `package:tagflow/src/runtime/document_node.dart`
- sampled instance ids:
  `objects/541/0`, `objects/1137/0`, `objects/1735/0`, `objects/2333/0`
- GC root type: `user global` at every checkpoint
- retaining path lengths: `133`, `87`, `116`, `116`
- first path hops:
  `TagflowDocumentNode -> _ImmutableList -> TagflowDocument -> Tagflow -> KeyedSubtree -> RepaintBoundary -> IndexedSemantics -> _SelectionKeepAlive`

`TagflowDocument` review:

- library:
  `package:tagflow/src/runtime/document.dart`
- sampled instance ids:
  `objects/569/0`, `objects/1166/0`, `objects/1764/0`, `objects/2362/0`
- GC root type: `user global` at every checkpoint
- retaining path lengths: `131`, `85`, `114`, `114`
- first path hops:
  `TagflowDocument -> Tagflow -> KeyedSubtree -> RepaintBoundary -> IndexedSemantics -> _SelectionKeepAlive -> NotificationListener -> _AutomaticKeepAliveState`

## Interpretation

This closes the patch-lane same-process retained-path comparison gap that
remained after the earlier single-checkpoint `after_scroll` note:

- all four patch checkpoints exported retained-path JSON from one live process
- the retained paths kept the same high-level shape across checkpoints
- sampled `TagflowDocumentNode` and `TagflowDocument` instances remained rooted
  through the live `Tagflow` widget and normal Flutter keep-alive wrappers
  rather than appearing as detached orphan objects
- aggregate heap-summary object count and shallow size still declined from
  `before_first_patch` to `after_scroll` even though the sampled package-level
  document classes increased modestly

This is still not retained-object proof:

- the review is bounded to one sampled instance per target class per checkpoint
- there are no raw DevTools heap snapshots or heap diffs here
- there is no same-process control-lane retained-path comparison in this note
- the environment remains prerelease Flutter on prerelease macOS

## Remaining Blockers

Public memory/allocation wording remains blocked:

- raw DevTools heap snapshots or snapshot diffs still need manual review
- control-lane retained-path comparison is still separate work if paired
  retained-object attribution is desired
- this run does not prove that every retained object at every checkpoint is
  expected
- repeat counts and reference-environment qualification are still unresolved
