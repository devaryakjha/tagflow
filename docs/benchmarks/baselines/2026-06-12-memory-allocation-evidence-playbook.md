# 2026-06-12 Memory and Allocation Evidence Playbook

This note is a practical capture guide for Tagflow benchmark qualification.
It is intentionally report-only: the profile harness can already summarize GC
counts and frame timings, but memory allocation claims still need manual
DevTools evidence and a reviewed baseline note before they can be used for any
public claim.

## What The Current Summaries Record

Profile summaries already preserve:

- `runId`
- `runDirectory`
- `manifestPath`
- `cellSummaries[].newGenGcCount`
- `cellSummaries[].oldGenGcCount`
- `cellSummaries[].viewports`
- `cellSummaries[].framePhaseSummaries`
- `cellSummaries[].updateSummary`
- `cellSummaries[].outlierRepeats`
- per-run `artifactPath` and `logPath`

That is enough to prove collection completeness and to review GC churn. It does
not record heap snapshots, allocation profiles, retained-object diffs, or any
DevTools Memory export.

`benchmark:profile:check` surfaces two report-only memory-readiness findings
from the summary JSON:

- `memory_allocation_evidence_required` for lanes listed in this playbook
  after GC summaries are present
- `old_gen_gc_review_required` when a summarized cell records any old-gen GC

These findings do not make the checker fail. They are reminders that summary
GC counts are only review inputs; they do not replace DevTools Memory exports,
allocation profiles, snapshot diffs, or a reviewed baseline note.

## Evidence Lanes

Capture memory/allocation evidence for these lanes:

- `tagflow:large_article`
- `tagflow:table_stress`
- `tagflow_semantic_patch:streaming_ai_authored_insertion_patches`
- optional native-runtime evidence: `tagflow_native_json:native_large_article`

For the patch lane, keep the full-reparse control run in the same baseline pass:

- `tagflow_semantic:streaming_ai_authored_insertions`

## Standard Collection Flow

Use a stable run id. Do not rely on an auto-generated id when the goal is a
reviewed baseline note.

### 1. Collect the profile baseline

Large article:

```bash
RUN_ID=2026-06-12-memory-large-article-repeat5
OUT=build/benchmarks/profile-memory-evidence
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_DEVICE=macos \
TAGFLOW_PROFILE_PAIR=tagflow:large_article \
TAGFLOW_PROFILE_REPEAT=5 \
TAGFLOW_PROFILE_RUN_ID="$RUN_ID" \
TAGFLOW_PROFILE_OUTPUT_DIR="$OUT" \
TAGFLOW_PROFILE_CONTINUE_ON_FAILURE=true \
TAGFLOW_PROFILE_MEMORY=true \
dart run melos run benchmark:profile:baselines
```

Table stress:

```bash
RUN_ID=2026-06-12-memory-table-stress-repeat5
OUT=build/benchmarks/profile-memory-evidence
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_DEVICE=macos \
TAGFLOW_PROFILE_PAIR=tagflow:table_stress \
TAGFLOW_PROFILE_REPEAT=5 \
TAGFLOW_PROFILE_RUN_ID="$RUN_ID" \
TAGFLOW_PROFILE_OUTPUT_DIR="$OUT" \
TAGFLOW_PROFILE_CONTINUE_ON_FAILURE=true \
TAGFLOW_PROFILE_MEMORY=true \
dart run melos run benchmark:profile:baselines
```

Dynamic patch pair:

```bash
RUN_ID=2026-06-12-memory-authored-insertion-repeat5
OUT=build/benchmarks/profile-memory-evidence
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_DEVICE=macos \
TAGFLOW_PROFILE_PAIR=tagflow_semantic:streaming_ai_authored_insertions,tagflow_semantic_patch:streaming_ai_authored_insertion_patches \
TAGFLOW_PROFILE_REPEAT=5 \
TAGFLOW_PROFILE_RUN_ID="$RUN_ID" \
TAGFLOW_PROFILE_OUTPUT_DIR="$OUT" \
TAGFLOW_PROFILE_CONTINUE_ON_FAILURE=true \
TAGFLOW_PROFILE_MEMORY=true \
dart run melos run benchmark:profile:baselines
```

Optional native JSON lane:

```bash
RUN_ID=2026-06-12-memory-native-large-article-repeat5
OUT=build/benchmarks/profile-memory-evidence
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_DEVICE=macos \
TAGFLOW_PROFILE_PAIR=tagflow_native_json:native_large_article \
TAGFLOW_PROFILE_REPEAT=5 \
TAGFLOW_PROFILE_RUN_ID="$RUN_ID" \
TAGFLOW_PROFILE_OUTPUT_DIR="$OUT" \
TAGFLOW_PROFILE_CONTINUE_ON_FAILURE=true \
TAGFLOW_PROFILE_MEMORY=true \
dart run melos run benchmark:profile:baselines
```

### 2. Summarize and check the run

Use the same `RUN_ID` and `OUT` values immediately after collection:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID="$RUN_ID" \
TAGFLOW_PROFILE_OUTPUT_DIR="$OUT" \
dart run melos run benchmark:profile:summarize
```

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID="$RUN_ID" \
TAGFLOW_PROFILE_OUTPUT_DIR="$OUT" \
TAGFLOW_PROFILE_CHECK_POLICY=docs/benchmarks/policies/profile-reference-runner-policy.json \
dart run melos run benchmark:profile:check
```

### 3. Confirm the run id and raw artifact paths

The run id is the top-level `runId` in the manifest and summary. Confirm it
directly:

```bash
jq -r '.runId' "$OUT/$RUN_ID/profile-baseline-manifest.json"
jq -r '.runId' "$OUT/$RUN_ID/profile-baseline-summary.json"
```

For the raw integration-test artifact tied to a specific cell, inspect the
manifest. Example for the large article lane:

```bash
jq -r '.runs[] | select(.renderer=="tagflow" and .fixture=="large_article" and .repeat==1) | .artifactPath' \
  "$OUT/$RUN_ID/profile-baseline-manifest.json"
```

Example for the patch cell:

```bash
jq -r '.runs[] | select(.renderer=="tagflow_semantic_patch" and .fixture=="streaming_ai_authored_insertion_patches" and .repeat==1) | .artifactPath' \
  "$OUT/$RUN_ID/profile-baseline-manifest.json"
```

## DevTools Memory Capture

Use the raw profile artifact and the VM service URI from the benchmark run to
pair the baseline with DevTools Memory evidence.

When `TAGFLOW_PROFILE_MEMORY=true`, the repeated profile runner requests a
per-cell `flutter drive --profile-memory` file and records the expected memory
profile path plus any VM service URI printed by Flutter in
`profile-baseline-manifest.json`. This bounded file is useful evidence, but it
does not replace the checkpoint snapshots or allocation diffs below.

Two supported capture modes exist:

- headless memory recording with `dart devtools --record-memory-profile`
- automated VM-service evidence export with
  `benchmark:memory-evidence:export`
- interactive DevTools Memory snapshots or allocation profile diffs

For checkpoint snapshots or class allocation diffs, the harness now supports an
opt-in replay hold path:

- `TAGFLOW_PROFILE_HOLD_OPEN=true`
- `TAGFLOW_PROFILE_HOLD_OPEN_SECONDS=<n>`

When enabled, each selected profile cell replays named benchmark checkpoints
after the measured run and keeps each checkpoint alive for the requested number
of seconds. This does not replace manual export from DevTools; it only keeps
the VM service alive long enough to attach and export.

Hold-open runs also write
`<run-dir>/memory-evidence-manifest.json` and link it from
`profile-baseline-manifest.json` as `memoryEvidenceManifestPath`. That file is
a reviewer checklist: it records the VM service URI seen for each run, the
expected DevTools export paths under `<run-dir>/devtools/`, the headless
`dart devtools --record-memory-profile` command when a URI is available, and
the checkpoint names that should be captured. It is not memory evidence by
itself.

### One-repeat checkpoint capture flow

Use repeat `1` for interactive capture so the runner stops at one reviewed
cell instead of waiting through a repeat-5 matrix.

Dynamic patch pair:

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
TAGFLOW_PROFILE_HOLD_OPEN_SECONDS=120 \
dart run melos run benchmark:profile:baselines
```

Static large article:

```bash
RUN_ID=2026-06-12-memory-large-article-checkpoints
OUT=build/benchmarks/profile-memory-evidence
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_DEVICE=macos \
TAGFLOW_PROFILE_PAIR=tagflow:large_article \
TAGFLOW_PROFILE_REPEAT=1 \
TAGFLOW_PROFILE_RUN_ID="$RUN_ID" \
TAGFLOW_PROFILE_OUTPUT_DIR="$OUT" \
TAGFLOW_PROFILE_CONTINUE_ON_FAILURE=true \
TAGFLOW_PROFILE_MEMORY=true \
TAGFLOW_PROFILE_HOLD_OPEN=true \
TAGFLOW_PROFILE_HOLD_OPEN_SECONDS=120 \
dart run melos run benchmark:profile:baselines
```

### Headless memory profile

This is the most repeatable path when you want a machine-readable memory
artifact.

1. Start the profile baseline run.
2. Copy the VM service URI printed by the benchmark session, or use the
   per-run command in `memory-evidence-manifest.json`.
3. Record a memory profile file with DevTools:

```bash
RUN_ID=2026-06-12-memory-large-article-repeat5
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
dart devtools --record-memory-profile=build/benchmarks/profile-memory-evidence/$RUN_ID/devtools/large_article-memory-profile.json \
  <vm-service-uri>
```

The same command shape works for the other lanes. Replace the output file name
so it clearly identifies the lane and the checkpoint you recorded.

### Automated VM-service evidence export

The benchmark package also includes a small report-only exporter for live
hold-open sessions. It connects to the VM service URI from
`memory-evidence-manifest.json`, requests `getAllocationProfile(gc: true)`, and
requests a VM-service heap snapshot through the `HeapSnapshot` event stream.
It writes:

- `<checkpoint>-allocation-profile.json`
- `<checkpoint>-heap-summary.json`

The heap file is a compact class-level summary, not a raw DevTools heap export.
It is useful for before/after class growth review, but it still needs reviewer
interpretation before any memory wording can be promoted.

Example for one checkpoint:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_MEMORY_EVIDENCE_VM_SERVICE_URI=http://127.0.0.1:52010/2Vu4UM2pM9g=/ \
TAGFLOW_MEMORY_EVIDENCE_CHECKPOINT=after_first_patch \
TAGFLOW_MEMORY_EVIDENCE_OUTPUT_DIR=build/benchmarks/profile-memory-evidence/$RUN_ID/devtools \
dart run melos run benchmark:memory-evidence:export
```

Run the command while the target checkpoint is still held open. Repeat it for
each checkpoint listed in `memory-evidence-manifest.json`. The resulting JSON
files stay under ignored `build/` output; commit only a reviewed baseline note
with filenames, command, and interpretation.

### Interactive Memory snapshots

Use the browser UI when you need a before/after snapshot or a class allocation
diff:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH dart devtools
```

Then connect DevTools to the running benchmark session using the VM service URI
from the benchmark terminal. Capture and export the following checkpoints:

- before first render
- after first render settles
- after warm scroll completes
- after the final patch step for the patch lane
- after the warm scroll for the native JSON lane, when collected

Export files under the same ignored run directory. Hold-open runs generate the
expected file names in `memory-evidence-manifest.json`; older runs can use this
shape:

- `build/benchmarks/profile-memory-evidence/<run-id>/devtools/<lane>-before.json`
- `build/benchmarks/profile-memory-evidence/<run-id>/devtools/<lane>-after-first-render.json`
- `build/benchmarks/profile-memory-evidence/<run-id>/devtools/<lane>-after-scroll.json`
- `build/benchmarks/profile-memory-evidence/<run-id>/devtools/<lane>-after-final-patch.json`

Watch the benchmark terminal while the run is active. The harness now prints
checkpoint lines like:

```text
[tagflow-profile-checkpoint] renderer=... fixture=... checkpoint=... action=attach-devtools
```

Use the VM service URI recorded in stdout and in
`profile-baseline-manifest.json` to connect DevTools to the live session while
that checkpoint is held open.

Manual exports still required from DevTools:

- raw heap snapshots for each required checkpoint, when class-level summaries
  are not sufficient
- class allocation diffs or equivalent allocation-profile export
- retained-object review notes for any suspicious class growth or old-gen GC

The hold-open mode does not export these artifacts for you. It only keeps the
session alive long enough to capture them.

## Lane-Specific Capture Notes

### `tagflow:large_article`

- Capture the before-render snapshot.
- Capture the after-first-render snapshot once the first pump has settled.
- Capture the after-scroll snapshot after the warm scroll completes.
- If the summary shows old-gen GC or a retained-growth spike, attach an
  allocation profile or class allocation diff and call out the largest retained
  classes in the reviewed note.

### `tagflow:table_stress`

- Capture the same three checkpoints as `large_article`.
- Pay attention to table-cell and text-span growth, not just total heap size.
- If the run is stable in frame timing but allocates materially more than
  `large_article`, note that as report-only until it is explained.

### `tagflow_semantic_patch:streaming_ai_authored_insertion_patches`

- Keep the full-reparse control lane in the same run.
- Capture before-render, after-first-patch, after-final-patch, and after-scroll
  evidence.
  The control lane replay emits `before_first_update`, `after_first_update`,
  `after_final_update`, and `after_scroll`; the patch lane replay emits
  `before_first_patch`, `after_first_patch`, `after_final_patch`, and
  `after_scroll`.
- Treat any old-gen GC outlier or retained-growth spike as a blocker for
  public dynamic-content language until the reviewer explains it.

### `tagflow_native_json:native_large_article`

- Keep this lane optional and report-only.
- Capture before-render and after-scroll evidence if you are using it as
  native-runtime support data.
- Do not compare it directly with the HTML renderer lanes; it is a separate
  evidence path.

## Acceptance Language

### Blocker

Treat the following as blockers for benchmark qualification:

- `benchmark:profile:summarize` or `benchmark:profile:check` fails
- a required raw artifact is missing
- a required DevTools export is missing for a promoted lane
- old-gen GC or a retained-growth spike is present and not reviewed
- the lane is being used for public performance wording before the reference
  environment is stable and repeat evidence exists

### Report-Only

Keep these report-only:

- frame timings from the summary
- GC counts from the summary
- raw DevTools Memory exports
- allocation profiles and class allocation diffs
- native JSON lane evidence until a qualified reference target exists

### Ignored

It is safe to ignore these in the reviewed note:

- raw files under `build/`
- benchmark run wall-clock time
- browser launch noise from DevTools
- exploratory exports that are not tied to the final reviewed run id

### Must Be Committed

Commit a reviewed baseline note under `docs/benchmarks/baselines/` only when
the note contains:

- exact run id
- exact commit SHA
- exact lane list and repeat count
- collection, summarize, and check commands
- summarize/check outputs or a concise JSON excerpt
- DevTools export filenames or memory profile filenames
- reviewer decision for each old-gen GC or retained-growth outlier

Do not commit raw DevTools exports. Keep them in ignored local output.

## Public Claim Block

Public wording stays blocked until all of the following are true:

- the target machine is a stable reference environment
- the lane has repeat evidence on that machine
- the GC summary and DevTools allocation evidence are reviewed together
- retained-growth or old-gen GC anomalies are explained in the reviewed note
- the note is committed and clearly marked report-only or qualification-only

Until then, avoid phrases like "uses less memory", "lighter heap", or
"allocation win" outside the reviewed baseline note.
