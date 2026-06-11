# 2026-06-12 Memory Allocation Snapshot Blocker

This note records the next non-device memory/allocation evidence boundary for
Tagflow's native rich-content runtime benchmark plan. It is report-only scoping
evidence. It does not add memory data, does not set thresholds, and does not
support public memory or allocation claims.

## Scope

- Review commit: `8fa61b7d`
- Branch context: `codex/tagflow-native-runtime-master`
- Worktree: `/Users/arya/.codex/worktrees/0945/tagflow`
- Device scope: local macOS only; no physical-device profiling attempted
- Raw artifact policy: keep generated files under ignored `build/`

## Committed Evidence Inventory

Current committed docs already cover the narrow local memory sample slice:

| Evidence | Current state | Remaining limit |
| --- | --- | --- |
| Memory feasibility probe | `2026-06-12-memory-allocation-evidence-probe.md` records bounded `flutter drive --profile-memory` JSON for `tagflow_native_json:native_large_article` and `tagflow_semantic_patch:streaming_ai_authored_insertion_patches`. | Feasibility only; no repeat-5 baseline, snapshots, or allocation diffs in that probe. |
| Required macOS memory lanes | `2026-06-12-memory-allocation-repeat5-local-status.md` records repeat-5 profile baselines for `tagflow:large_article`, `tagflow:table_stress`, and the authored-insertion control/patch pair. | Report-only local stabilization evidence, not claim-grade reference evidence. |
| Bounded DevTools memory samples | The repeat-5 status note records bounded `--profile-memory` JSON for every required lane plus optional `tagflow_native_json:native_large_article`. | Bounded samples do not replace heap snapshots, class allocation diffs, or retained-object review. |
| Roadmap posture | `2026-06-11-native-runtime-benchmark-roadmap.md` already classifies memory/allocation as blocked on snapshots, allocation diffs, and retained-object review. | No memory/allocation wording can be promoted until those artifacts exist and are reviewed. |

There is no missing required macOS bounded-memory lane in the committed
documentation. Re-running a single `--profile-memory` capture would duplicate
existing report-only evidence and would not close the playbook allocation gap.

## Current Tooling Boundary

The playbook requires DevTools Memory checkpoints and allocation evidence:

- before first render
- after first render settles
- after warm scroll completes
- after final patch for the patch lane
- class allocation diffs or equivalent retained-object review

The current repeat runner in
`packages/tagflow_benchmarks/lib/src/profile/profile_baseline_runner.dart`
reuses `dart run melos run benchmark:profile` and copies only
`examples/tagflow/build/integration_response_data.json` into the run directory.
It does not pass a `--profile-memory` output path through the repeated harness
and does not preserve a durable VM service URI for checkpointed DevTools
snapshot export.

The local SDK exposes headless DevTools memory sampling:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH dart devtools --help
```

The help output includes `--record-memory-profile=<file>`. That path can write
memory samples when connected to a live VM service URI, but it is still not the
same as the playbook-required before/after heap snapshots, class allocation
diffs, or retained-object review.

## Decision

Do not run another bounded `flutter drive --profile-memory` lane in this
worktree as the next evidence slice. The smallest useful non-device progress is
to record this blocker and leave the next commands explicit.

The next playbook-complete slice needs either:

1. an interactive DevTools Memory session attached to a kept-alive benchmark
   run, with exported checkpoint snapshots and allocation diffs under
   `build/benchmarks/profile-memory-evidence/<run-id>/devtools/`, or
2. a harness change that keeps the benchmark VM service URI available and
   automates snapshot/diff export without weakening the existing repeat-5
   manifest/check flow.

Either path must keep raw exports ignored under `build/` and commit only a
reviewed baseline note with filenames, run ids, commands, and reviewer
interpretation.

## Recommended Next Commands

If a human reviewer can drive DevTools interactively, start with the existing
required dynamic pair because it is the highest-risk memory/allocation lane:

```bash
RUN_ID=2026-06-12-memory-authored-insertion-snapshots
OUT=build/benchmarks/profile-memory-evidence
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_DEVICE=macos \
TAGFLOW_PROFILE_PAIR=tagflow_semantic:streaming_ai_authored_insertions,tagflow_semantic_patch:streaming_ai_authored_insertion_patches \
TAGFLOW_PROFILE_REPEAT=1 \
TAGFLOW_PROFILE_RUN_ID="$RUN_ID" \
TAGFLOW_PROFILE_OUTPUT_DIR="$OUT" \
TAGFLOW_PROFILE_CONTINUE_ON_FAILURE=true \
dart run melos run benchmark:profile:baselines
```

Then open DevTools while the target VM service is still live:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH dart devtools
```

Export the control and patch checkpoints listed in the playbook. If the
benchmark process exits before the snapshots can be exported, stop and treat
that as a harness blocker rather than substituting another bounded memory
sample.

If automating this instead, the smallest code slice should first prove the
runner can persist the benchmark VM service URI and a `--profile-memory` output
path per cell without changing package versions or public benchmark claims.

## Validation

This was a docs-only scoping pass. No Flutter profile command was run because
the already-committed bounded sample lanes cover the feasible non-interactive
memory sample path, while the next missing evidence requires snapshot/diff
export support.
