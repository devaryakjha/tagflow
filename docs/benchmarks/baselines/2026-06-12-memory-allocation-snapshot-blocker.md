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

The repeat runner in
`packages/tagflow_benchmarks/lib/src/profile/profile_baseline_runner.dart`
reuses `dart run melos run benchmark:profile` for each selected cell. The
runner now has an opt-in `TAGFLOW_PROFILE_MEMORY=true` path that sets
`TAGFLOW_PROFILE_MEMORY_FILE` per cell, lets the root Melos script pass
`--profile-memory=<file>` to `flutter drive`, and records the expected memory
profile path plus any VM service URI found in stdout/stderr. It also now has
an opt-in checkpoint replay mode via `TAGFLOW_PROFILE_HOLD_OPEN=true` and
`TAGFLOW_PROFILE_HOLD_OPEN_SECONDS=<n>`, which replays named checkpoints after
measurement and keeps each checkpoint alive for bounded DevTools attachment.
Hold-open runs write a machine-readable `memory-evidence-manifest.json` with
checkpoint names, expected DevTools export paths, and headless
`dart devtools --record-memory-profile` command templates when a VM service URI
is available.

That support preserves bounded memory sample artifacts for repeated runs. It
does not export heap snapshots, class allocation diffs, or retained-object
analysis automatically. A reviewer still has to connect DevTools and export
those artifacts manually while the checkpoint is held open.

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

The next playbook-complete slice is an interactive DevTools Memory session
attached to a hold-open benchmark run, with exported checkpoint snapshots and
allocation diffs under
`build/benchmarks/profile-memory-evidence/<run-id>/devtools/`.

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
TAGFLOW_PROFILE_MEMORY=true \
TAGFLOW_PROFILE_HOLD_OPEN=true \
TAGFLOW_PROFILE_HOLD_OPEN_SECONDS=120 \
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

The benchmark terminal now prints named checkpoint lines while the replay hold
is active. Use those messages plus the generated `memory-evidence-manifest.json`
to decide when and where to export each DevTools snapshot or allocation diff,
and treat the manual exports as the remaining blocker.

## Validation

The original scoping pass did not run another Flutter profile command because
the already-committed bounded sample lanes cover the feasible non-interactive
memory sample path, while the next missing evidence requires snapshot/diff
export support.

The follow-up tooling slice added a generated memory evidence manifest and was
validated with the focused profile baseline runner test. It still does not
export heap snapshots, allocation diffs, or retained-object analysis.
