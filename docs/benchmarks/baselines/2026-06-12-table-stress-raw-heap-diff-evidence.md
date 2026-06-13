# 2026-06-12 Table Stress Raw Heap Diff Evidence

This note records a one-repeat local macOS `tagflow:table_stress` raw heap
snapshot and class-diff evidence slice collected from the live VM-service
exporter. It is report-only evidence. It does not prove leak freedom, does
not support public memory/allocation claims, and does not by itself promote
broader beta memory wording without coordinator review.

Raw JSON artifacts stayed under ignored `build/` output.

## Scope

- Branch context: `codex/tagflow-native-runtime-master`
- Collection commit:
  `0bb3a01d74ffd8e01febed7fb34c2def7c127395`
- Device: local `macos` profile target
- `tagflow` version: `1.0.0-alpha.3`
- Flutter SDK: `3.45.0-0.1.pre (master)`
- Dart SDK: `3.11.0-81.0.dev`
- Host OS: `macOS 27.0 (26A5353q)`
- Repeat count: `1`
- Hold-open seconds: `30`
- Lane: `tagflow:table_stress`
- Run id: `2026-06-12-memory-table-stress-raw-heap-diff-r1`
- Verified checkpoints:
  - `before_first_render`
  - `after_first_render`
  - `after_scroll`
- Retaining-path class targets:
  - `TagflowDocumentNode`
  - `TagflowDocument`

The static checkpoint labels were verified in
`examples/tagflow/integration_test/tagflow_perf_test.dart` and in the
generated `memory-evidence-manifest.json`. No additional table-specific
retaining-path class target was added: the reviewed raw diff top deltas were
generic Dart containers plus Tagflow runtime source/presentation classes, not
`tagflow_table` classes.

## Commands

Watcher-driven profile run:

```bash
RUN_ID=2026-06-12-memory-table-stress-raw-heap-diff-r1
OUT=build/benchmarks/profile-memory-evidence
PATH=/Users/arya/fvm/cache.git/bin:$PATH
export TAGFLOW_MEMORY_EVIDENCE_RETAINING_CLASSES=TagflowDocumentNode,TagflowDocument
export TAGFLOW_MEMORY_EVIDENCE_RETAINING_SAMPLE_LIMIT=1
export TAGFLOW_MEMORY_EVIDENCE_RETAINING_PATH_LIMIT=20
export TAGFLOW_MEMORY_EVIDENCE_WRITE_RAW_HEAP=true

(
  TAGFLOW_PROFILE_DEVICE=macos \
  TAGFLOW_PROFILE_PAIR=tagflow:table_stress \
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
    automated_checkpoint="$renderer-$fixture-repeat-01-$checkpoint"
    TAGFLOW_MEMORY_EVIDENCE_VM_SERVICE_URI="$VM_URI" \
    TAGFLOW_MEMORY_EVIDENCE_CHECKPOINT="$automated_checkpoint" \
    TAGFLOW_MEMORY_EVIDENCE_OUTPUT_DIR="$OUT/$RUN_ID/devtools" \
    TAGFLOW_MEMORY_EVIDENCE_WRITE_RAW_HEAP=true \
    dart run melos run benchmark:memory-evidence:export
  fi
done
```

Result: passed. The watcher pipeline exited with status `0 0 0`.

Raw heap snapshot diff generation:

```bash
RUN_ID=2026-06-12-memory-table-stress-raw-heap-diff-r1
DEVTOOLS=/Users/arya/.codex/worktrees/3000/tagflow/build/benchmarks/profile-memory-evidence/$RUN_ID/devtools
PATH=/Users/arya/fvm/cache.git/bin:$PATH
cd packages/tagflow_benchmarks

dart run bin/export_memory_evidence.dart \
  --diff-base="$DEVTOOLS/tagflow-table_stress-repeat-01-before_first_render-heap-snapshot.json" \
  --diff-head="$DEVTOOLS/tagflow-table_stress-repeat-01-after_first_render-heap-snapshot.json" \
  --diff-output="$DEVTOOLS/tagflow-table_stress-repeat-01-before_first_render-to-after_first_render-allocation-diff.json" \
  --diff-classes=TagflowDocumentNode,TagflowDocument

dart run bin/export_memory_evidence.dart \
  --diff-base="$DEVTOOLS/tagflow-table_stress-repeat-01-before_first_render-heap-snapshot.json" \
  --diff-head="$DEVTOOLS/tagflow-table_stress-repeat-01-after_scroll-heap-snapshot.json" \
  --diff-output="$DEVTOOLS/tagflow-table_stress-repeat-01-before_first_render-to-after_scroll-allocation-diff.json" \
  --diff-classes=TagflowDocumentNode,TagflowDocument
```

Summary:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=2026-06-12-memory-table-stress-raw-heap-diff-r1 \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-memory-evidence \
dart run melos run benchmark:profile:summarize
```

Result: passed and wrote `profile-baseline-summary.json`.

Check:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=2026-06-12-memory-table-stress-raw-heap-diff-r1 \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-memory-evidence \
TAGFLOW_PROFILE_MIN_REPEATS=1 \
dart run melos run benchmark:profile:check
```

Result: passed with no blocking issues. The expected report-only
`memory_allocation_evidence_required` finding remained because reviewer
interpretation is still required before memory wording can be promoted.

## Run Result

- `1 / 1` profile cell passed.
- The cell captured bounded `--profile-memory` JSON.
- The manifest recorded VM service URI
  `http://127.0.0.1:62104/kInVsak-l5A=/`.
- The watcher exported raw heap snapshots, class-level heap summaries,
  allocation profiles, and retained-path JSON at all three static
  checkpoints.
- The summary recorded `newGenGcCount: 2` and `oldGenGcCount: 0`.
- `outlierRepeats: []`.
- The fixture input was `14439` bytes from
  `packages/tagflow_benchmarks/fixtures/html/table_stress.html`.
- The viewport was `800x600 @ 1.0x`.

## Artifacts

Run-level artifacts:

```text
build/benchmarks/profile-memory-evidence/2026-06-12-memory-table-stress-raw-heap-diff-r1/profile-baseline-manifest.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-table-stress-raw-heap-diff-r1/profile-baseline-summary.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-table-stress-raw-heap-diff-r1/memory-evidence-manifest.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-table-stress-raw-heap-diff-r1/watcher.log
build/benchmarks/profile-memory-evidence/2026-06-12-memory-table-stress-raw-heap-diff-r1/tagflow/table_stress/repeat-01.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-table-stress-raw-heap-diff-r1/tagflow/table_stress/repeat-01-memory.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-table-stress-raw-heap-diff-r1/tagflow/table_stress/repeat-01.log
```

Checkpoint export stems written under
`build/benchmarks/profile-memory-evidence/2026-06-12-memory-table-stress-raw-heap-diff-r1/devtools/`:

```text
tagflow-table_stress-repeat-01-before_first_render
tagflow-table_stress-repeat-01-after_first_render
tagflow-table_stress-repeat-01-after_scroll
```

Each checkpoint stem wrote these suffixes:

- `-allocation-profile.json`
- `-heap-summary.json`
- `-heap-snapshot.json`
- `-retaining-paths.json`

Generated raw heap diff artifacts:

```text
build/benchmarks/profile-memory-evidence/2026-06-12-memory-table-stress-raw-heap-diff-r1/devtools/tagflow-table_stress-repeat-01-before_first_render-to-after_first_render-allocation-diff.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-table-stress-raw-heap-diff-r1/devtools/tagflow-table_stress-repeat-01-before_first_render-to-after_scroll-allocation-diff.json
```

## Raw Heap Diff Review

Both generated diff files used raw heap snapshot inputs and reported complete
coverage:

```json
{
  "base": "rawHeapSnapshot",
  "head": "rawHeapSnapshot",
  "complete": true
}
```

Heap summary totals:

| Checkpoint | Objects | Shallow bytes | External bytes |
| --- | ---: | ---: | ---: |
| `before_first_render` | 523548 | 43367360 | 147344 |
| `after_first_render` | 547273 | 44706336 | 147344 |
| `after_scroll` | 572243 | 46144096 | 147344 |

Selected class deltas, `before_first_render -> after_first_render`:

- `TagflowDocumentNode`: `1125 -> 2250`, delta `+1125` instances and
  `+180000` shallow bytes.
- `TagflowDocument`: `1 -> 2`, delta `+1` instance and `+48` shallow bytes.
- Largest positive class deltas were `_List +3350`, `_Uint32List +3392`,
  `_Map +3388`, `UnmodifiableMapView +3375`, and `_OneByteString +2271`.

Selected class deltas, `before_first_render -> after_scroll`:

- `TagflowDocumentNode`: `1125 -> 3375`, delta `+2250` instances and
  `+360000` shallow bytes.
- `TagflowDocument`: `1 -> 3`, delta `+2` instances and `+96` shallow bytes.
- Largest positive class deltas were `_List +6788`, `_Uint32List +6787`,
  `_Map +6776`, `UnmodifiableMapView +6750`, and `_OneByteString +4534`.

Bounded retained-path samples for both selected classes were rooted through
the live `_TagflowState` and Flutter element tree at all three checkpoints.
The static hold-open replay pumps the benchmark app at each checkpoint, so the
selected Tagflow document growth is interpreted as replay-stage residency
inside the live benchmark widget tree, not as leak-free proof or detached
orphan proof.

## Interpretation

This run closes the raw heap snapshot/class-diff collection gap for the
`tagflow:table_stress` lane at the report-only evidence level:

- all three expected static checkpoints were exported from one live process;
- both generated class diffs came from raw heap snapshots and were complete
  for class-count and shallow-size comparison;
- bounded retained-path samples were captured for the selected Tagflow
  document classes;
- summary/check passed with `TAGFLOW_PROFILE_MIN_REPEATS=1`.

The evidence remains local macOS, one-repeat, report-only data. It does not
support public memory/allocation claims. Broader beta memory wording can now
advance only after the coordinator reviews the collected HTML memory evidence
scope and decides the interpretation language.
