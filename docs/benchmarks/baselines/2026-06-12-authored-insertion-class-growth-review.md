# 2026-06-12 Authored-Insertion Class-Growth Review

This note reviews the VM-service allocation-profile and class-level heap-summary
exports from
[`2026-06-12-authored-insertion-checkpoint-memory-evidence.md`](2026-06-12-authored-insertion-checkpoint-memory-evidence.md).

It is a report-only class-growth review. It does not prove retained-object
ownership, does not include raw DevTools retained paths, and does not support
public memory or allocation claims.

## Scope

- Source collection commit:
  `3b4fb028401758f2f478b450319a08b295e19420`
- Local review commit base:
  `4f5ce73493bfdc4fd7336fd87a8bb0c3d9b66b2a`
- Primary run id:
  `2026-06-12-memory-authored-insertion-checkpoints`
- Supplemental run id:
  `2026-06-12-memory-authored-insertion-control-after-scroll`
- Device: local `macos` profile target
- Repeat count: `1`
- Evidence type:
  - VM-service `getAllocationProfile(gc: true)` JSON
  - VM-service heap snapshot class summaries
  - no raw DevTools heap snapshots
  - no retained-object path export
  - no interactive class allocation diff export

Exact reviewed lanes:

- Control: `tagflow_semantic:streaming_ai_authored_insertions`
- Patch: `tagflow_semantic_patch:streaming_ai_authored_insertion_patches`

## Reviewed Artifacts

Primary raw artifact root:

```text
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-checkpoints/
```

Supplemental raw artifact root:

```text
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-control-after-scroll/
```

Primary checkpoint exports:

```text
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-checkpoints/devtools/tagflow_semantic-streaming_ai_authored_insertions-repeat-01-before_first_update-heap-summary.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-checkpoints/devtools/tagflow_semantic-streaming_ai_authored_insertions-repeat-01-before_first_update-allocation-profile.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-checkpoints/devtools/tagflow_semantic-streaming_ai_authored_insertions-repeat-01-after_first_update-heap-summary.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-checkpoints/devtools/tagflow_semantic-streaming_ai_authored_insertions-repeat-01-after_first_update-allocation-profile.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-checkpoints/devtools/tagflow_semantic-streaming_ai_authored_insertions-repeat-01-after_final_update-heap-summary.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-checkpoints/devtools/tagflow_semantic-streaming_ai_authored_insertions-repeat-01-after_final_update-allocation-profile.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-checkpoints/devtools/tagflow_semantic_patch-streaming_ai_authored_insertion_patches-repeat-01-before_first_patch-heap-summary.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-checkpoints/devtools/tagflow_semantic_patch-streaming_ai_authored_insertion_patches-repeat-01-before_first_patch-allocation-profile.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-checkpoints/devtools/tagflow_semantic_patch-streaming_ai_authored_insertion_patches-repeat-01-after_first_patch-heap-summary.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-checkpoints/devtools/tagflow_semantic_patch-streaming_ai_authored_insertion_patches-repeat-01-after_first_patch-allocation-profile.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-checkpoints/devtools/tagflow_semantic_patch-streaming_ai_authored_insertion_patches-repeat-01-after_final_patch-heap-summary.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-checkpoints/devtools/tagflow_semantic_patch-streaming_ai_authored_insertion_patches-repeat-01-after_final_patch-allocation-profile.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-checkpoints/devtools/tagflow_semantic_patch-streaming_ai_authored_insertion_patches-repeat-01-after_scroll-heap-summary.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-checkpoints/devtools/tagflow_semantic_patch-streaming_ai_authored_insertion_patches-repeat-01-after_scroll-allocation-profile.json
```

Supplemental control `after_scroll` exports:

```text
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-control-after-scroll/devtools/tagflow_semantic-streaming_ai_authored_insertions-repeat-01-after_scroll-heap-summary.json
build/benchmarks/profile-memory-evidence/2026-06-12-memory-authored-insertion-control-after-scroll/devtools/tagflow_semantic-streaming_ai_authored_insertions-repeat-01-after_scroll-allocation-profile.json
```

## Compact Checkpoint Table

The top-class column lists the five largest shallow-size classes from each
class-level heap summary.

| Lane | Checkpoint | Objects | Classes | Shallow bytes | Heap usage | Heap capacity | Top shallow classes |
| --- | --- | ---: | ---: | ---: | ---: | ---: | --- |
| Control | `before_first_update` | `198127` | `1122` | `23802144` | `12599280` | `16760832` | `InstructionsSection 5531296`, `Code 3873600`, `_OneByteString 2937152`, `CodeSourceMap 2233984`, `Function 1898160` |
| Control | `after_first_update` | `196415` | `1119` | `23661120` | `12587728` | `14204928` | `InstructionsSection 5531296`, `Code 3873600`, `_OneByteString 2936736`, `CodeSourceMap 2233984`, `Function 1898160` |
| Control | `after_final_update` | `197180` | `1121` | `23711040` | `12634928` | `15777792` | `InstructionsSection 5531296`, `Code 3873600`, `_OneByteString 2938000`, `CodeSourceMap 2233984`, `Function 1898160` |
| Control | `after_scroll` supplemental | `198144` | `1120` | `23803072` | `12600208` | `15777792` | `InstructionsSection 5531296`, `Code 3873600`, `_OneByteString 2937424`, `CodeSourceMap 2233984`, `Function 1898160` |
| Patch | `before_first_patch` | `198170` | `1124` | `23805712` | `12602800` | `15253504` | `InstructionsSection 5531296`, `Code 3873600`, `_OneByteString 2937440`, `CodeSourceMap 2233984`, `Function 1898160` |
| Patch | `after_first_patch` | `196616` | `1121` | `23674016` | `12600576` | `14204928` | `InstructionsSection 5531296`, `Code 3873600`, `_OneByteString 2937504`, `CodeSourceMap 2233984`, `Function 1898160` |
| Patch | `after_final_patch` | `197185` | `1124` | `23712432` | `12638992` | `14729216` | `InstructionsSection 5531296`, `Code 3873600`, `_OneByteString 2937632`, `CodeSourceMap 2233984`, `Function 1898160` |
| Patch | `after_scroll` | `197197` | `1123` | `23713136` | `12639696` | `15253504` | `InstructionsSection 5531296`, `Code 3873600`, `_OneByteString 2937728`, `CodeSourceMap 2233984`, `Function 1898160` |

## Same-Process Movement

The control `after_scroll` export came from the supplemental run. Treat it as a
shape check only, not a retained-growth delta against the primary control
process.

Primary control process, `before_first_update` to `after_final_update`:

- Objects: `198127 -> 197180`, delta `-947`
- Classes: `1122 -> 1121`, delta `-1`
- Heap-summary shallow bytes: `23802144 -> 23711040`, delta `-91104`
- Allocation-profile heap usage: `12599280 -> 12634928`, delta `+35648`
- Largest positive top-class shallow delta:
  `_OneByteString +848` bytes, `+21` instances
- Largest negative top-class shallow delta:
  `_GrowableList -31424` bytes, `-982` instances
- Package `tagflow` allocation-profile totals:
  `189 -> 189` current instances, `9520 -> 9520` bytes

Primary patch process, `before_first_patch` to `after_scroll`:

- Objects: `198170 -> 197197`, delta `-973`
- Classes: `1124 -> 1123`, delta `-1`
- Heap-summary shallow bytes: `23805712 -> 23713136`, delta `-92576`
- Allocation-profile heap usage: `12602800 -> 12639696`, delta `+36896`
- Largest positive top-class shallow delta:
  `_OneByteString +288` bytes, `+6` instances
- Largest negative top-class shallow delta:
  `_GrowableList -31424` bytes, `-982` instances
- Package `tagflow` allocation-profile totals:
  `195 -> 197` current instances, `9920 -> 10128` bytes
- Package `tagflow` positive class deltas:
  `TagflowDocumentNode +1` instance and `+160` bytes,
  `TagflowDocument +1` instance and `+48` bytes

## Package-Level Review

The `package:tagflow` classes are not among the top shallow-size classes in the
heap summaries. They are visible in the full allocation profiles:

| Lane | Checkpoint | `package:tagflow` classes | Current instances | Current bytes | Largest Tagflow classes |
| --- | --- | ---: | ---: | ---: | --- |
| Control | `before_first_update` | `82` | `189` | `9520` | `TagflowDocumentNode 1920`, `TagflowStyle 1824`, `TagflowSourceInfo 832` |
| Control | `after_first_update` | `82` | `154` | `7392` | `TagflowStyle 1824`, `TagflowDocumentNode 800`, `TagflowNodeKind 544` |
| Control | `after_final_update` | `82` | `189` | `9520` | `TagflowDocumentNode 1920`, `TagflowStyle 1824`, `TagflowSourceInfo 832` |
| Control | `after_scroll` supplemental | `82` | `189` | `9520` | `TagflowDocumentNode 1920`, `TagflowStyle 1824`, `TagflowSourceInfo 832` |
| Patch | `before_first_patch` | `82` | `195` | `9920` | `TagflowDocumentNode 2080`, `TagflowStyle 1824`, `TagflowSourceInfo 832` |
| Patch | `after_first_patch` | `82` | `197` | `10128` | `TagflowDocumentNode 2240`, `TagflowStyle 1824`, `TagflowSourceInfo 832` |
| Patch | `after_final_patch` | `82` | `197` | `10128` | `TagflowDocumentNode 2240`, `TagflowStyle 1824`, `TagflowSourceInfo 832` |
| Patch | `after_scroll` | `82` | `197` | `10128` | `TagflowDocumentNode 2240`, `TagflowStyle 1824`, `TagflowSourceInfo 832` |

The patch path's same-process package-level increase is small and explainable
at class level: one additional `TagflowDocumentNode` and one additional
`TagflowDocument` remain current after the final patch/scroll checkpoint. That
is not by itself evidence of a leak or retained-growth regression.

## Verdict

The existing VM-service exports are sufficient for a report-only class-growth
review:

- Same-process patch aggregate object count and heap-summary shallow size did
  not grow from `before_first_patch` to `after_scroll`.
- Top shallow-size classes stayed dominated by VM/runtime structures
  (`InstructionsSection`, `Code`, `_OneByteString`, `CodeSourceMap`,
  `Function`) rather than Tagflow document/runtime classes.
- The largest package-level patch growth was `+208` current bytes across
  `TagflowDocumentNode` and `TagflowDocument`.
- No class-level retained-growth spike is visible in these exports.

The exports are not sufficient for retained-object proof:

- They do not include raw object references or retaining paths.
- They do not include DevTools heap snapshot diffs.
- They do not show why the remaining `TagflowDocumentNode` or
  `TagflowDocument` instances are retained.
- The control `after_scroll` checkpoint is from a supplemental process, so it
  cannot be used as a strict delta endpoint for the primary control process.

## Remaining Blocker

Public memory/allocation wording remains blocked. The next DevTools action, if
promotion is desired, is an interactive or exported heap snapshot diff for the
patch lane in one live process:

- `before_first_patch`
- `after_first_patch`
- `after_final_patch`
- `after_scroll`

The review should inspect retained paths for the package-level classes that
remained current here, especially `TagflowDocumentNode` and `TagflowDocument`,
and any larger Flutter text/rendering classes if they appear in a raw snapshot
diff.
