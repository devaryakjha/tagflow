# 2026-06-12 HTML Memory Evidence Interpretation Scope

This note reviews the now-collected raw VM-service heap snapshot,
class-diff, allocation-profile, heap-summary, and retained-path evidence for
the required non-device HTML memory lanes.

It is a report-only interpretation note. It does not publish a memory,
allocation, leak-free, speed, ranking, or regression-threshold claim.

## Reviewed Inputs

- [`2026-06-12-authored-insertion-raw-heap-diff-evidence.md`](2026-06-12-authored-insertion-raw-heap-diff-evidence.md)
- [`2026-06-12-large-article-raw-heap-diff-evidence.md`](2026-06-12-large-article-raw-heap-diff-evidence.md)
- [`2026-06-12-table-stress-raw-heap-diff-evidence.md`](2026-06-12-table-stress-raw-heap-diff-evidence.md)
- [`../2026-06-11-native-runtime-benchmark-roadmap.md`](../2026-06-11-native-runtime-benchmark-roadmap.md)
- [`../2026-06-12-reference-runner-qualification.md`](../2026-06-12-reference-runner-qualification.md)
- [`../2026-06-12-threshold-reference-policy.md`](../2026-06-12-threshold-reference-policy.md)

Raw JSON under ignored `build/` output was not re-inspected for this review.
The reviewed scope is based on the committed evidence notes and their recorded
commands, artifact lists, summary/check results, and class-diff excerpts.

## Collection Coverage

The required non-device HTML memory lanes now have collection coverage:

| Lane | Coverage now recorded | Narrow classification |
| --- | --- | --- |
| `tagflow_semantic:streaming_ai_authored_insertions` | one-repeat local macOS control lane, raw snapshots at all four control checkpoints, retained-path samples, and raw-snapshot class diffs from `before_first_update` to `after_final_update` and `after_scroll` | Report-only control input for dynamic update review. |
| `tagflow_semantic_patch:streaming_ai_authored_insertion_patches` | one-repeat local macOS patch lane, raw snapshots at all four patch checkpoints, retained-path samples, and raw-snapshot class diffs from `before_first_patch` to `after_final_patch` and `after_scroll` | Report-only patch input for dynamic update review. |
| `tagflow:large_article` | one-repeat local macOS static lane, raw snapshots at `before_first_render`, `after_first_render`, and `after_scroll`, retained-path samples, and raw-snapshot class diffs for both before-to-after spans | Report-only large-document input. |
| `tagflow:table_stress` | one-repeat local macOS static lane, raw snapshots at `before_first_render`, `after_first_render`, and `after_scroll`, retained-path samples, and raw-snapshot class diffs for both before-to-after spans | Report-only table-stress input. |

The collection gap for raw snapshot/class-diff artifacts is closed for these
HTML lanes at the local report-only level. The optional native JSON lane remains
separate support evidence and is not required for an HTML memory interpretation.

## Narrow Supported Interpretation

The committed evidence supports these statements:

- The required non-device HTML lanes have same-run or same-process raw
  VM-service heap snapshot coverage at their named hold-open checkpoints.
- The generated class diffs for the reviewed spans use raw heap snapshots and
  are complete for class instance counts and shallow-size comparison.
- The selected retained-path samples for `TagflowDocumentNode` and
  `TagflowDocument` are compatible with live widget-tree residency: the notes
  record paths rooted through the live `Tagflow` / `_TagflowState` and Flutter
  element tree, including keep-alive or active scroll wrappers where relevant.
- The large article and table stress selected Tagflow document growth is
  compatible with checkpoint replay-stage residency inside the live benchmark
  widget tree.
- The authored-insertion patch lane shows smaller selected Tagflow class
  before-to-after growth than the full-reparse control lane in this one local
  run, while both lanes ended with lower total object counts and shallow bytes
  than their corresponding before checkpoints.
- The evidence is useful as reviewer input for deciding whether beta docs may
  mention that local report-only memory evidence was collected and reviewed.

## Unsupported Interpretation

The committed evidence does not support these statements:

- Tagflow is leak-free.
- Detached objects were exhaustively ruled out.
- The patch lane uses less memory or allocates less than the control lane.
- Large documents or table-heavy documents have bounded memory in production.
- Current macOS memory behavior is representative of physical iOS or Android.
- The evidence is a public benchmark result.
- Any memory, allocation, GC, timing, speed, ranking, or threshold gate can be
  enforced from these notes.

The retained-path samples are bounded samples, not full ownership proofs. The
class diffs are class-count and shallow-size comparisons, not object-lifetime
proofs. The hold-open replay pumps the benchmark app through named checkpoints,
so live retained paths are expected while the rendered content is resident.

## Remaining Blockers

Public or beta-facing memory/allocation wording remains blocked by:

- physical-device profile and memory evidence for supported iOS and Android
  targets, unless the wording is explicitly desktop-only;
- real-app production-surface profile evidence, including the Kite route once
  pushed, merged, opened deterministically, and profiled on a supported target;
- stable reference environment selection, because the current local data used
  prerelease Flutter master and prerelease macOS;
- repeat policy for memory interpretation, because the raw snapshot/class-diff
  evidence is one-repeat local macOS data even where related profile baselines
  have repeat-5 frame/GC evidence;
- reviewer policy for translating raw snapshot/class-diff observations into
  allowed release wording;
- explanation of any old-gen GC, raster, missed-frame, or retained-growth
  outlier before using that lane for a claim;
- a committed threshold/comparison policy before any numeric gate or
  comparative wording is introduced.

## Coordinator Recommendation

Update roadmap and beta-freeze wording from "raw heap/diff capture pending" to
"raw heap/diff collection is complete for the required non-device HTML lanes,
but interpretation is report-only and public/beta memory wording remains
blocked by target, repeat, real-app, reference-environment, and wording-policy
gates."
