# 2026-06-12 Checkpoint Hold Smoke

This note records a bounded local smoke of the profile checkpoint hold path
added for memory/allocation evidence capture. It is harness evidence only. It
does not include exported DevTools heap snapshots, class allocation diffs, or
retained-object review, and it does not support public memory or performance
claims.

## Scope

- Coordinator commit: `f6a18553002c426662cb62209b900cd3adc70c8c`
- Run id: `2026-06-12-checkpoint-hold-smoke`
- Output directory: `build/benchmarks/profile-checkpoint-smoke`
- Device: local macOS profile target
- Renderer/fixture: `tagflow:large_article`
- Repeat count: `1`
- Hold-open duration: `1` second per checkpoint
- Raw artifacts: ignored under
  `build/benchmarks/profile-checkpoint-smoke/2026-06-12-checkpoint-hold-smoke/`

## Command

```bash
RUN_ID=2026-06-12-checkpoint-hold-smoke
OUT=build/benchmarks/profile-checkpoint-smoke
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_DEVICE=macos \
TAGFLOW_PROFILE_PAIR=tagflow:large_article \
TAGFLOW_PROFILE_REPEAT=1 \
TAGFLOW_PROFILE_RUN_ID="$RUN_ID" \
TAGFLOW_PROFILE_OUTPUT_DIR="$OUT" \
TAGFLOW_PROFILE_CONTINUE_ON_FAILURE=true \
TAGFLOW_PROFILE_MEMORY=true \
TAGFLOW_PROFILE_HOLD_OPEN=true \
TAGFLOW_PROFILE_HOLD_OPEN_SECONDS=1 \
dart run melos run benchmark:profile:baselines
```

Summary and check:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=2026-06-12-checkpoint-hold-smoke \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-checkpoint-smoke \
dart run melos run benchmark:profile:summarize
```

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=2026-06-12-checkpoint-hold-smoke \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-checkpoint-smoke \
TAGFLOW_PROFILE_MIN_REPEATS=1 \
dart run melos run benchmark:profile:check
```

## Result

The profile run passed:

- `totalRuns`: `1`
- `successfulRuns`: `1`
- run status: `passed`
- `memoryProfileStatus`: `captured`
- `profileHoldOpen`: `true`
- `profileHoldOpenSeconds`: `1`
- `vmServiceUri`: recorded in the manifest
- `benchmark:profile:check`: `passed: true` with `minRepeats: 1`

The run log captured the expected checkpoint attach markers:

- `checkpoint=before_first_render ... action=attach-devtools`
- `checkpoint=after_first_render ... action=attach-devtools`
- `checkpoint=after_scroll ... action=attach-devtools`

Each checkpoint also emitted a matching `hold_complete=true` line.

## Interpretation

This proves the opt-in hold-open path can run through the real macOS
`flutter drive --profile` harness, preserve a per-cell memory profile artifact,
record the VM service URI, and keep named checkpoints alive long enough for a
manual DevTools attach attempt.

The checker still emitted the expected report-only finding:
`memory_allocation_evidence_required`. That finding is correct. This smoke did
not export heap snapshots, allocation profiles, class allocation diffs, or a
retained-object review.

## Remaining Work

- Run the playbook flow with a human or tool attached to DevTools while the
  checkpoints are held open.
- Export heap snapshots or allocation diffs for the required lanes.
- Commit a reviewed baseline note that names the raw DevTools exports and
  interprets retained allocations.
- Keep memory/allocation wording report-only until that evidence exists.
