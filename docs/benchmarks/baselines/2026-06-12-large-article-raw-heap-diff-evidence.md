# 2026-06-12 Large Article Raw Heap Diff Evidence

This note records a one-repeat local macOS `tagflow:large_article` raw heap
snapshot and class-diff evidence slice collected from the live VM-service
exporter. It is report-only evidence. It does not prove leak freedom, does
not support public memory/allocation claims, and does not close the broader
memory wording gate while `tagflow:table_stress` remains pending.

Raw JSON artifacts stayed under ignored `build/` output.

## Scope

- Branch context: `codex/tagflow-native-runtime-master`
- Collection commit:
  `7e9c267caec24b6bcd9a9b136a3b7047268fa006`
- Device: local `macos` profile target
- `tagflow` version: `1.0.0-alpha.3`
- Flutter SDK: `3.45.0-0.1.pre (master)`
- Dart SDK: `3.11.0-81.0.dev`
- Host OS: `macOS 27.0 (26A5353q)`
- Repeat count: `1`
- Hold-open seconds: `30`
- Lane: `tagflow:large_article`
- Run id: `2026-06-12-memory-large-article-raw-heap-diff-r1`
- Verified checkpoints:
  - `before_first_render`
  - `after_first_render`
  - `after_scroll`
- Retaining-path class targets:
  - `TagflowDocumentNode`
  - `TagflowDocument`

## Commands

Watcher-driven profile run:

```bash
RUN_ID=2026-06-12-memory-large-article-raw-heap-diff-r1
OUT=build/benchmarks/profile-memory-evidence
PATH=/Users/arya/fvm/cache.git/bin:$PATH
export TAGFLOW_MEMORY_EVIDENCE_RETAINING_CLASSES=TagflowDocumentNode,TagflowDocument
export TAGFLOW_MEMORY_EVIDENCE_RETAINING_SAMPLE_LIMIT=1
export TAGFLOW_MEMORY_EVIDENCE_RETAINING_PATH_LIMIT=20
export TAGFLOW_MEMORY_EVIDENCE_WRITE_RAW_HEAP=true

(
  TAGFLOW_PROFILE_DEVICE=macos \
  TAGFLOW_PROFILE_PAIR=tagflow:large_article \
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

Raw heap snapshot diff generation:

```bash
RUN_ID=2026-06-12-memory-large-article-raw-heap-diff-r1
ROOT=/Users/arya/.codex/worktrees/1994/tagflow
DEVTOOLS="$ROOT/build/benchmarks/profile-memory-evidence/$RUN_ID/devtools"
PATH=/Users/arya/fvm/cache.git/bin:$PATH
cd packages/tagflow_benchmarks

dart run bin/export_memory_evidence.dart \
  --diff-base="$DEVTOOLS/tagflow-large_article-repeat-01-before_first_render-heap-snapshot.json" \
  --diff-head="$DEVTOOLS/tagflow-large_article-repeat-01-after_first_render-heap-snapshot.json" \
  --diff-output="$DEVTOOLS/tagflow-large_article-repeat-01-before_first_render-to-after_first_render-allocation-diff.json" \
  --diff-classes=TagflowDocumentNode,TagflowDocument

dart run bin/export_memory_evidence.dart \
  --diff-base="$DEVTOOLS/tagflow-large_article-repeat-01-before_first_render-heap-snapshot.json" \
  --diff-head="$DEVTOOLS/tagflow-large_article-repeat-01-after_scroll-heap-snapshot.json" \
  --diff-output="$DEVTOOLS/tagflow-large_article-repeat-01-before_first_render-to-after_scroll-allocation-diff.json" \
  --diff-classes=TagflowDocumentNode,TagflowDocument
```

Summary:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=2026-06-12-memory-large-article-raw-heap-diff-r1 \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-memory-evidence \
dart run melos run benchmark:profile:summarize
```

Result: passed and wrote `profile-baseline-summary.json`.

Check:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=2026-06-12-memory-large-article-raw-heap-diff-r1 \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-memory-evidence \
TAGFLOW_PROFILE_MIN_REPEATS=1 \
dart run melos run benchmark:profile:check
```

Result: passed with no blocking issues. Report-only findings remained for:

- `outlier_repeat_present`: repeat 1 had two missed raster-budget frames and
  `worstRasterMillis: 68.484`.
- `memory_allocation_evidence_required`: expected for this playbook lane even
  after raw exports, because reviewer interpretation is still required.

## Run Result

- `1 / 1` profile cell passed.
- The cell captured bounded `--profile-memory` JSON.
- The manifest recorded VM service URI
  `http://127.0.0.1:60216/-cQdaOyG8z8=/`.
- The watcher exported raw heap snapshots, class-level heap summaries,
  allocation profiles, and retained-path JSON at all three static
  checkpoints.
- No old-gen GC was summarized for the cell.
- New-gen GC count was `2`.
- The fixture input was `4529` bytes from
  `packages/tagflow_benchmarks/fixtures/html/large_article.html`.
- The viewport was `800x600 @ 1.0x`.

## Artifacts

Run-level artifacts:

```text
build/benchmarks/profile-memory-evidence/2026-06-12-memory-large-article-raw-heap-diff-r1/profile-baseline-manifest.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-large-article-raw-heap-diff-r1/profile-baseline-summary.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-large-article-raw-heap-diff-r1/memory-evidence-manifest.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-large-article-raw-heap-diff-r1/watcher.log
build/benchmarks/profile-memory-evidence/2026-06-12-memory-large-article-raw-heap-diff-r1/tagflow/large_article/repeat-01.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-large-article-raw-heap-diff-r1/tagflow/large_article/repeat-01-memory.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-large-article-raw-heap-diff-r1/tagflow/large_article/repeat-01.log
```

Checkpoint export stems written under
`build/benchmarks/profile-memory-evidence/2026-06-12-memory-large-article-raw-heap-diff-r1/devtools/`:

```text
tagflow-large_article-repeat-01-before_first_render
tagflow-large_article-repeat-01-after_first_render
tagflow-large_article-repeat-01-after_scroll
```

Each checkpoint stem wrote these suffixes:

- `-allocation-profile.json`
- `-heap-summary.json`
- `-heap-snapshot.json`
- `-retaining-paths.json`

Generated raw heap diff artifacts:

```text
build/benchmarks/profile-memory-evidence/2026-06-12-memory-large-article-raw-heap-diff-r1/devtools/tagflow-large_article-repeat-01-before_first_render-to-after_first_render-allocation-diff.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-large-article-raw-heap-diff-r1/devtools/tagflow-large_article-repeat-01-before_first_render-to-after_scroll-allocation-diff.json
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
| `before_first_render` | 228152 | 25784624 | 16912 |
| `after_first_render` | 229598 | 25839552 | 16880 |
| `after_scroll` | 232398 | 25999056 | 16912 |

Selected class deltas, `before_first_render -> after_first_render`:

- `TagflowDocumentNode`: `118 -> 236`, delta `+118` instances and `+18880`
  shallow bytes.
- `TagflowDocument`: `1 -> 2`, delta `+1` instance and `+48` shallow bytes.
- Largest positive class deltas were `_List +304`, `_Map +356`,
  `_Uint32List +355`, `UnmodifiableMapView +354`, and
  `_OneByteString +210`.

Selected class deltas, `before_first_render -> after_scroll`:

- `TagflowDocumentNode`: `118 -> 354`, delta `+236` instances and `+37760`
  shallow bytes.
- `TagflowDocument`: `1 -> 3`, delta `+2` instances and `+96` shallow bytes.
- Largest positive class deltas were `_List +713`, `_Map +712`,
  `_Uint32List +712`, `UnmodifiableMapView +708`, and
  `_OneByteString +454`.

The retained-path samples for both selected Tagflow classes were rooted through
the live `_TagflowState` and Flutter element tree at all three checkpoints.
The static hold-open replay pumps the benchmark app at each checkpoint, so the
selected Tagflow document growth is interpreted as replay-stage residency
inside the live benchmark widget tree, not as leak-free proof or detached
orphan proof.

## Interpretation

This run closes the raw heap snapshot/class-diff collection gap for the
`tagflow:large_article` lane at the report-only evidence level:

- all three expected static checkpoints were exported from one live process;
- both generated class diffs came from raw heap snapshots and were complete
  for class-count and shallow-size comparison;
- bounded retained-path samples were captured for the selected Tagflow
  document classes;
- summary/check passed with `TAGFLOW_PROFILE_MIN_REPEATS=1`.

The evidence remains local macOS, one-repeat, report-only data. The single
repeat also recorded a raster outlier, so it should not be used for timing
claims. Broader beta memory wording remains blocked until `tagflow:table_stress`
raw heap/diff evidence is collected and the coordinator decides the reviewed
interpretation scope for the required HTML memory lanes.
