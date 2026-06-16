# 2026-06-12 Authored-Insertion Control Multi-Checkpoint Retained Paths

This note records a same-process retained-path review for the authored-
insertion control lane across all control checkpoints:

- `before_first_update`
- `after_first_update`
- `after_final_update`
- `after_scroll`

It is report-only evidence. It does not prove leak freedom, does not replace
raw DevTools heap snapshots or heap diffs, and does not support public memory
or allocation claims.

Raw JSON artifacts stayed under ignored `build/` output.

## Scope

- Branch context: `codex/tagflow-native-runtime-master`
- Collection commit:
  `ad6545b5f502d46a17b75f7a5529cd015aafb068`
- Device: local `macos` profile target
- `tagflow` version: `1.0.0-alpha.3`
- Flutter SDK: `3.45.0-0.1.pre (master)`
- Dart SDK: `3.11.0-81.0.dev`
- Host OS: `macOS 27.0 (26A5353q)`
- Repeat count: `1`
- Hold-open seconds: `45`
- Selection mode: explicit ordered pair list with one control cell
- Exact lane: `tagflow_semantic:streaming_ai_authored_insertions`
- Run id:
  `2026-06-12-memory-authored-insertion-control-multi-checkpoint-retained-paths-r1`

This note closes the control-side retained-path gap left after the existing
patch-lane review in
[`2026-06-12-authored-insertion-patch-multi-checkpoint-retained-paths.md`](2026-06-12-authored-insertion-patch-multi-checkpoint-retained-paths.md).
Public memory/allocation wording remains blocked until raw DevTools heap/diff
review is also captured and reviewed.

## Commands

The profile run used a local watcher keyed off the streamed VM service URI and
the control checkpoint attach markers. The watcher exported retained-path
evidence during each live hold window rather than rerunning the harness for
each checkpoint.

Watcher-driven profile run:

```bash
RUN_ID=2026-06-12-memory-authored-insertion-control-multi-checkpoint-retained-paths-r1
OUT=build/benchmarks/profile-memory-evidence
PATH=/Users/arya/fvm/cache.git/bin:$PATH
export TAGFLOW_MEMORY_EVIDENCE_RETAINING_CLASSES=TagflowDocumentNode,TagflowDocument
export TAGFLOW_MEMORY_EVIDENCE_RETAINING_SAMPLE_LIMIT=1
export TAGFLOW_MEMORY_EVIDENCE_RETAINING_PATH_LIMIT=20

(
  TAGFLOW_PROFILE_DEVICE=macos \
  TAGFLOW_PROFILE_PAIR=tagflow_semantic:streaming_ai_authored_insertions \
  TAGFLOW_PROFILE_REPEAT=1 \
  TAGFLOW_PROFILE_RUN_ID="$RUN_ID" \
  TAGFLOW_PROFILE_OUTPUT_DIR="$OUT" \
  TAGFLOW_PROFILE_CONTINUE_ON_FAILURE=true \
  TAGFLOW_PROFILE_MEMORY=true \
  TAGFLOW_PROFILE_HOLD_OPEN=true \
  TAGFLOW_PROFILE_HOLD_OPEN_SECONDS=45 \
  dart run melos run benchmark:profile:baselines 2>&1
) | tee "$OUT/$RUN_ID/watcher.log" | while IFS= read -r line; do
  printf '%s\n' "$line"
  if [[ "$line" =~ 'VMServiceFlutterDriver: Connecting to Flutter application at ' ]]; then
    VM_URI="${line##* at }"
  fi
  if [[ "$line" == *"[tagflow-profile-checkpoint] renderer=tagflow_semantic fixture=streaming_ai_authored_insertions checkpoint="*" action=attach-devtools"* ]]; then
    checkpoint_part="${line#*checkpoint=}"
    checkpoint="${checkpoint_part%% *}"
    automated_checkpoint="tagflow_semantic-streaming_ai_authored_insertions-repeat-01-$checkpoint"
    TAGFLOW_MEMORY_EVIDENCE_VM_SERVICE_URI="$VM_URI" \
    TAGFLOW_MEMORY_EVIDENCE_CHECKPOINT="$automated_checkpoint" \
    TAGFLOW_MEMORY_EVIDENCE_OUTPUT_DIR="$OUT/$RUN_ID/devtools" \
    dart run melos run benchmark:memory-evidence:export
  fi
done
```

Summary:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=2026-06-12-memory-authored-insertion-control-multi-checkpoint-retained-paths-r1 \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-memory-evidence \
dart run melos run benchmark:profile:summarize
```

Result: passed and wrote `profile-baseline-summary.json`.

Check:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=2026-06-12-memory-authored-insertion-control-multi-checkpoint-retained-paths-r1 \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-memory-evidence \
TAGFLOW_PROFILE_MIN_REPEATS=1 \
dart run melos run benchmark:profile:check
```

Result: passed with no blocking issues and no report-only findings.

## Streamed Same-Process Evidence

The live run recorded one VM service URI for the control process:

```text
VMServiceFlutterDriver: Connecting to Flutter application at http://127.0.0.1:55474/JWbTqAvYX14=/
```

The same run log then emitted all four checkpoint attach markers in order:

```text
flutter: [tagflow-profile-checkpoint] renderer=tagflow_semantic fixture=streaming_ai_authored_insertions checkpoint=before_first_update hold_open_seconds=45 action=attach-devtools
flutter: [tagflow-profile-checkpoint] renderer=tagflow_semantic fixture=streaming_ai_authored_insertions checkpoint=after_first_update hold_open_seconds=45 action=attach-devtools
flutter: [tagflow-profile-checkpoint] renderer=tagflow_semantic fixture=streaming_ai_authored_insertions checkpoint=after_final_update hold_open_seconds=45 action=attach-devtools
flutter: [tagflow-profile-checkpoint] renderer=tagflow_semantic fixture=streaming_ai_authored_insertions checkpoint=after_scroll hold_open_seconds=45 action=attach-devtools
```

All four automated exports completed against that same live URI:
`http://127.0.0.1:55474/JWbTqAvYX14=/`.

## Profile Result

- `1 / 1` profile cells passed
- bounded `--profile-memory` JSON was captured
- `newGenGcCount.total: 2`
- `oldGenGcCount.total: 0`
- viewport: `800 x 600 @ 2.0x`
- update chunks observed: `4`
- `updateSummary.maxElapsedMillis: 119.033`
- worst attributed update frame:
  `buildMillis 2.748`, `rasterMillis 7.972`
- `outlierRepeats: []`

## Artifacts

Run-level artifacts:

```text
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-control-multi-checkpoint-retained-paths-r1/profile-baseline-manifest.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-control-multi-checkpoint-retained-paths-r1/profile-baseline-summary.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-control-multi-checkpoint-retained-paths-r1/memory-evidence-manifest.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-control-multi-checkpoint-retained-paths-r1/watcher.log
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-control-multi-checkpoint-retained-paths-r1/tagflow_semantic/streaming_ai_authored_insertions/repeat-01.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-control-multi-checkpoint-retained-paths-r1/tagflow_semantic/streaming_ai_authored_insertions/repeat-01-memory.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-control-multi-checkpoint-retained-paths-r1/tagflow_semantic/streaming_ai_authored_insertions/repeat-01.log
```

Checkpoint export artifacts:

```text
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-control-multi-checkpoint-retained-paths-r1/devtools/tagflow_semantic-streaming_ai_authored_insertions-repeat-01-before_first_update-heap-summary.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-control-multi-checkpoint-retained-paths-r1/devtools/tagflow_semantic-streaming_ai_authored_insertions-repeat-01-before_first_update-allocation-profile.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-control-multi-checkpoint-retained-paths-r1/devtools/tagflow_semantic-streaming_ai_authored_insertions-repeat-01-before_first_update-retaining-paths.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-control-multi-checkpoint-retained-paths-r1/devtools/tagflow_semantic-streaming_ai_authored_insertions-repeat-01-after_first_update-heap-summary.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-control-multi-checkpoint-retained-paths-r1/devtools/tagflow_semantic-streaming_ai_authored_insertions-repeat-01-after_first_update-allocation-profile.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-control-multi-checkpoint-retained-paths-r1/devtools/tagflow_semantic-streaming_ai_authored_insertions-repeat-01-after_first_update-retaining-paths.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-control-multi-checkpoint-retained-paths-r1/devtools/tagflow_semantic-streaming_ai_authored_insertions-repeat-01-after_final_update-heap-summary.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-control-multi-checkpoint-retained-paths-r1/devtools/tagflow_semantic-streaming_ai_authored_insertions-repeat-01-after_final_update-allocation-profile.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-control-multi-checkpoint-retained-paths-r1/devtools/tagflow_semantic-streaming_ai_authored_insertions-repeat-01-after_final_update-retaining-paths.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-control-multi-checkpoint-retained-paths-r1/devtools/tagflow_semantic-streaming_ai_authored_insertions-repeat-01-after_scroll-heap-summary.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-control-multi-checkpoint-retained-paths-r1/devtools/tagflow_semantic-streaming_ai_authored_insertions-repeat-01-after_scroll-allocation-profile.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-control-multi-checkpoint-retained-paths-r1/devtools/tagflow_semantic-streaming_ai_authored_insertions-repeat-01-after_scroll-retaining-paths.json
```

## Retained-Path Review

Top shallow-size classes stayed VM/runtime dominated at every checkpoint:
`InstructionsSection`, `Code`, `_OneByteString`, `CodeSourceMap`, and
`Function`.

Checkpoint summary:

| Checkpoint | Objects | Shallow bytes | Heap usage | `TagflowDocumentNode` | `TagflowDocument` |
| --- | ---: | ---: | ---: | ---: | ---: |
| `before_first_update` | `198182` | `23806736` | `12601152` | `12` / `1920` bytes | `1` / `48` bytes |
| `after_first_update` | `196764` | `23685248` | `12611856` | `17` / `2720` bytes | `2` / `96` bytes |
| `after_final_update` | `197638` | `23743056` | `12669664` | `29` / `4640` bytes | `3` / `144` bytes |
| `after_scroll` | `197651` | `23743792` | `12670400` | `29` / `4640` bytes | `3` / `144` bytes |

Same-process aggregate movement from `before_first_update` to `after_scroll`:

- object count: `198182 -> 197651`, delta `-531`
- heap-summary shallow bytes: `23806736 -> 23743792`, delta `-62944`
- allocation-profile heap usage: `12601152 -> 12670400`, delta `+69248`
- `TagflowDocumentNode`: `12 -> 29`, delta `+17` instances and `+2720` bytes
- `TagflowDocument`: `1 -> 3`, delta `+2` instances and `+96` bytes

Retaining-path shape was stable across all four checkpoint samples.

`TagflowDocumentNode` review:

- library:
  `package:tagflow/src/runtime/document_node.dart`
- sampled instance ids:
  `objects/541/0`, `objects/1139/0`, `objects/1735/0`, `objects/2331/0`
- GC root type: `user global` at every checkpoint
- retaining path lengths: `167`, `114`, `114`, `114`
- first path hops:
  `TagflowDocumentNode -> _ImmutableList -> TagflowDocument -> Tagflow -> KeyedSubtree -> _GrowableList -> SliverChildListDelegate -> SliverList`

`TagflowDocument` review:

- library:
  `package:tagflow/src/runtime/document.dart`
- sampled instance ids:
  `objects/569/0`, `objects/1167/0`, `objects/1763/0`, `objects/2359/0`
- GC root type: `user global` at every checkpoint
- retaining path lengths: `165`, `112`, `112`, `112`
- first path hops:
  `TagflowDocument -> Tagflow -> KeyedSubtree -> _GrowableList -> SliverChildListDelegate -> SliverList -> SliverPadding -> _GrowableList`

## Interpretation

This closes the control-lane same-process retained-path gap that remained after
the earlier patch-lane note:

- all four control checkpoints exported retained-path JSON from one live
  process
- every sampled `TagflowDocumentNode` and `TagflowDocument` path stayed rooted
  through the live `Tagflow` widget and active Flutter scroll tree
- the control path's `TagflowDocumentNode` and `TagflowDocument` counts rose
  during the full-reparse update sequence, but they stabilized between
  `after_final_update` and `after_scroll`
- aggregate object count and heap-summary shallow bytes did not grow across the
  full same-process control span

This is still not enough for public memory or allocation language:

- the evidence is one-repeat local macOS only
- the exports are bounded retained-path samples, not complete ownership proof
- there is still no raw DevTools heap snapshot/diff review for the paired
  control/patch lane
- the existing patch note and this new control note are compatible retained-
  path inputs, but they remain report-only reviewer evidence

## Remaining Blocker

Public memory/allocation wording remains blocked. The next reviewer action, if
promotion is desired, is a raw DevTools heap snapshot/diff review that uses the
same named checkpoints already exported here and in the patch-lane note:

- control: `before_first_update`, `after_first_update`,
  `after_final_update`, `after_scroll`
- patch: `before_first_patch`, `after_first_patch`, `after_final_patch`,
  `after_scroll`

That follow-up should explain whether the small remaining live
`TagflowDocumentNode` and `TagflowDocument` populations are expected runtime
state, scroll-tree retention, or true retained-growth risk.
