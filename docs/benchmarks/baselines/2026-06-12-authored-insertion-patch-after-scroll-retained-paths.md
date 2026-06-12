# 2026-06-12 Authored-Insertion Patch `after_scroll` Retained Paths

This note records the first live retained-path export for the authored-
insertion patch lane at the patch `after_scroll` checkpoint.

It is report-only evidence. It does not prove leak freedom, does not replace
raw DevTools heap snapshots or heap diffs, and does not support public memory
or allocation claims.

Raw JSON artifacts stayed under ignored `build/` output.

## Scope

- Branch context: `codex/tagflow-native-runtime-master`
- Collection commit:
  `6e3c3c144761334eec081a2f6198f29595e9b355`
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
- Exact checkpoint:
  `tagflow_semantic_patch-streaming_ai_authored_insertion_patches-repeat-01-after_scroll`

Tradeoff:

- This run was patch-only rather than a control/patch pair because the target
  evidence gap was the patch-lane retained path at `after_scroll`.
- The harness accepts a single explicit `renderer:fixture` pair, so widening to
  a control lane was unnecessary for this capture.
- This note does not claim a paired retained-path comparison.

## Commands

Live patch-lane hold-open profile run:

```bash
RUN_ID=2026-06-12-memory-authored-insertion-patch-after-scroll-retained-paths-r2
OUT=build/benchmarks/profile-memory-evidence
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
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

The export was triggered by a local watcher when the streamed `after_scroll`
attach marker appeared. Effective export command:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_MEMORY_EVIDENCE_VM_SERVICE_URI=http://127.0.0.1:50706/0jAePKngCW0=/ \
TAGFLOW_MEMORY_EVIDENCE_CHECKPOINT=tagflow_semantic_patch-streaming_ai_authored_insertion_patches-repeat-01-after_scroll \
TAGFLOW_MEMORY_EVIDENCE_OUTPUT_DIR=build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-patch-after-scroll-retained-paths-r2/devtools \
TAGFLOW_MEMORY_EVIDENCE_RETAINING_CLASSES=TagflowDocumentNode,TagflowDocument \
TAGFLOW_MEMORY_EVIDENCE_RETAINING_SAMPLE_LIMIT=1 \
TAGFLOW_MEMORY_EVIDENCE_RETAINING_PATH_LIMIT=20 \
dart run melos run benchmark:memory-evidence:export
```

Summary and check:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=2026-06-12-memory-authored-insertion-patch-after-scroll-retained-paths-r2 \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-memory-evidence \
dart run melos run benchmark:profile:summarize
```

Result: passed.

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=2026-06-12-memory-authored-insertion-patch-after-scroll-retained-paths-r2 \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-memory-evidence \
TAGFLOW_PROFILE_MIN_REPEATS=1 \
dart run melos run benchmark:profile:check
```

Result: passed with the expected report-only
`memory_allocation_evidence_required` finding for the patch lane.

## Streamed URI Evidence

From
`build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-patch-after-scroll-retained-paths-r2/tagflow_semantic_patch/streaming_ai_authored_insertion_patches/repeat-01.log`:

```text
VMServiceFlutterDriver: Connecting to Flutter application at http://127.0.0.1:50706/0jAePKngCW0=/
flutter: [tagflow-profile-checkpoint] renderer=tagflow_semantic_patch fixture=streaming_ai_authored_insertion_patches checkpoint=after_scroll hold_open_seconds=45 action=attach-devtools
```

The same log also recorded a benign host warning before the VM service attach:
`Failed to foreground app; open returned 1`. The run still passed, exported the
retained-path JSON during the live hold, and completed all tests.

## Profile Result

Run id:
`2026-06-12-memory-authored-insertion-patch-after-scroll-retained-paths-r2`

- `1 / 1` profile cells passed
- bounded `--profile-memory` JSON was captured
- `newGenGcCount.total: 2`
- `oldGenGcCount.total: 0`
- viewport: `800 x 600 @ 2.0x`
- `outlierRepeats: []`
- update chunks observed: `4`
- patch `updateSummary.maxElapsedMillis: 116.694`
- worst attributed patch frame:
  `buildMillis 3.672`, `rasterMillis 11.355`

## Artifacts

Run-level artifacts:

```text
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-patch-after-scroll-retained-paths-r2/profile-baseline-manifest.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-patch-after-scroll-retained-paths-r2/profile-baseline-summary.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-patch-after-scroll-retained-paths-r2/memory-evidence-manifest.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-patch-after-scroll-retained-paths-r2/tagflow_semantic_patch/streaming_ai_authored_insertion_patches/repeat-01.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-patch-after-scroll-retained-paths-r2/tagflow_semantic_patch/streaming_ai_authored_insertion_patches/repeat-01-memory.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-patch-after-scroll-retained-paths-r2/tagflow_semantic_patch/streaming_ai_authored_insertion_patches/repeat-01.log
```

Live `after_scroll` export artifacts:

```text
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-patch-after-scroll-retained-paths-r2/devtools/tagflow_semantic_patch-streaming_ai_authored_insertion_patches-repeat-01-after_scroll-heap-summary.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-patch-after-scroll-retained-paths-r2/devtools/tagflow_semantic_patch-streaming_ai_authored_insertion_patches-repeat-01-after_scroll-allocation-profile.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-patch-after-scroll-retained-paths-r2/devtools/tagflow_semantic_patch-streaming_ai_authored_insertion_patches-repeat-01-after_scroll-retaining-paths.json
```

## Retained-Path Summary

Heap/allocation snapshot at the exported `after_scroll` checkpoint:

- heap summary objects: `198155`
- heap summary classes: `1123`
- heap summary shallow bytes: `23805392`
- heap summary capacity: `25766720`
- allocation profile heap usage: `12602480`
- allocation profile heap capacity: `14729216`
- top shallow-size classes remained VM/runtime dominated:
  `InstructionsSection`, `Code`, `_OneByteString`, `CodeSourceMap`,
  `Function`

Targeted retained-path export settings:

- requested classes: `TagflowDocumentNode`, `TagflowDocument`
- sample limit: `1`
- path limit: `20`

The retained-path JSON lists each requested class twice because the melos
script forwards `--retaining-path-classes` and the binary also reads
`TAGFLOW_MEMORY_EVIDENCE_RETAINING_CLASSES`. The duplicated entries were
identical in class counts and path shape, so this review treats them as one
sampled class each.

Reviewed class results:

- `TagflowDocumentNode`
  - library:
    `package:tagflow/src/runtime/document_node.dart`
  - current instances: `14`
  - current bytes: `2240`
  - sampled instance id: `objects/541/0`
  - retaining path length: `75`
  - GC root type: `user global`
  - first path hops:
    `TagflowDocumentNode -> _ImmutableList -> TagflowDocument -> Tagflow -> KeyedSubtree -> RepaintBoundary -> IndexedSemantics -> _SelectionKeepAlive`
- `TagflowDocument`
  - library:
    `package:tagflow/src/runtime/document.dart`
  - current instances: `3`
  - current bytes: `144`
  - sampled instance id: `objects/570/0`
  - retaining path length: `73`
  - GC root type: `user global`
  - first path hops:
    `TagflowDocument -> Tagflow -> KeyedSubtree -> RepaintBoundary -> IndexedSemantics -> _SelectionKeepAlive -> NotificationListener -> _AutomaticKeepAliveState`

## Interpretation

This run closes the specific authored-insertion patch `after_scroll`
retained-path export gap:

- The requested live patch checkpoint stayed open long enough for a real
  `getRetainingPath` export.
- The sampled `TagflowDocumentNode` path flowed through its parent
  `TagflowDocument`, then through the live `Tagflow` widget and normal Flutter
  widget tree wrappers.
- The sampled `TagflowDocument` path also flowed through the live `Tagflow`
  widget and scrollable widget tree wrappers.

That is consistent with active retained UI state during the held
`after_scroll` checkpoint. It is not proof that all retained objects are
expected, and it does not replace raw same-process heap snapshot diffs across:

- `before_first_patch`
- `after_first_patch`
- `after_final_patch`
- `after_scroll`

## Remaining Blockers

Public memory/allocation wording remains blocked:

- no raw DevTools heap snapshots or snapshot diffs were reviewed here
- no same-process retained-path comparison across all patch checkpoints was
  reviewed
- no control-lane retained-path export was captured in this note
- the duplicated `classTargets` entries are exporter noise that should be fixed
  before wider retained-path collection
