# 2026-06-12 Memory Evidence Manifest Smoke

This note records a one-repeat local macOS smoke of the generated
`memory-evidence-manifest.json` path. It is harness evidence only. It does not
include heap snapshots, allocation diffs, retained-object review, or any
memory/allocation claim.

## Scope

- Run id: `2026-06-12-memory-manifest-smoke`
- Branch context: `codex/tagflow-native-runtime-master`
- Review commit: `3eb7b9b11e0ac22ca1044d14ce056d0875415a08`
- Device: local macOS profile target
- Renderer/fixture: `tagflow:large_article`
- Repeat count: `1`
- Raw artifact policy: generated files stayed under ignored `build/`

## Commands

Collection:

```bash
RUN_ID=2026-06-12-memory-manifest-smoke
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
TAGFLOW_PROFILE_HOLD_OPEN_SECONDS=1 \
dart run melos run benchmark:profile:baselines
```

Summary:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=2026-06-12-memory-manifest-smoke \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-memory-evidence \
dart run melos run benchmark:profile:summarize
```

Check:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=2026-06-12-memory-manifest-smoke \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-memory-evidence \
TAGFLOW_PROFILE_MIN_REPEATS=1 \
dart run melos run benchmark:profile:check
```

The first check attempt was started in parallel with summary generation and
failed because `profile-baseline-summary.json` did not exist yet. Re-running
the check sequentially after the summary completed passed.

## Artifact Review

Generated files:

- `build/benchmarks/profile-memory-evidence/2026-06-12-memory-manifest-smoke/profile-baseline-manifest.json`
- `build/benchmarks/profile-memory-evidence/2026-06-12-memory-manifest-smoke/profile-baseline-summary.json`
- `build/benchmarks/profile-memory-evidence/2026-06-12-memory-manifest-smoke/memory-evidence-manifest.json`
- `build/benchmarks/profile-memory-evidence/2026-06-12-memory-manifest-smoke/tagflow/large_article/repeat-01-memory.json`
- `build/benchmarks/profile-memory-evidence/2026-06-12-memory-manifest-smoke/tagflow/large_article/repeat-01.log`

The profile manifest linked the memory checklist:

```json
{
  "runId": "2026-06-12-memory-manifest-smoke",
  "device": "macos",
  "repeatCount": 1,
  "profileMemory": true,
  "profileHoldOpen": true,
  "profileHoldOpenSeconds": 1,
  "memoryEvidenceManifestPath": "build/benchmarks/profile-memory-evidence/2026-06-12-memory-manifest-smoke/memory-evidence-manifest.json"
}
```

The top-level `gitCommit` field in this manifest was `null`; the environment
block recorded the actual commit as
`3eb7b9b11e0ac22ca1044d14ce056d0875415a08`.
This was a harness schema mismatch, not a missing Git probe; future manifests
mirror `environment.gitCommit` into top-level `gitCommit`.

The memory evidence manifest recorded:

```json
{
  "runId": "2026-06-12-memory-manifest-smoke",
  "status": "manualExportsRequired",
  "profileHoldOpenSeconds": 1,
  "manualExportsRequired": [
    "heapSnapshot",
    "allocationProfileOrClassDiff",
    "retainedObjectReview"
  ]
}
```

For `tagflow:large_article` repeat 1, it also recorded:

- VM service URI:
  `http://127.0.0.1:52010/2Vu4UM2pM9g=/`
- bounded memory sample status: `captured`
- headless memory profile target:
  `build/benchmarks/profile-memory-evidence/2026-06-12-memory-manifest-smoke/devtools/tagflow-large_article-repeat-01-memory-profile.json`
- manual checkpoints:
  - `before_first_render`
  - `after_first_render`
  - `after_scroll`

The summary recorded one successful run and no failed runs. The fixture input
was `4529` bytes from
`packages/tagflow_benchmarks/fixtures/html/large_article.html`, with viewport
`800x600 @ 2.0x`. The summarized phases were `coldInitialRender`,
`warmRebuild`, and `warmScroll`.

## Check Result

The sequential checker pass returned:

```json
{
  "minRepeats": 1,
  "passed": true,
  "issues": []
}
```

It also emitted the expected report-only
`memory_allocation_evidence_required` finding for `tagflow:large_article`.
That finding is correct: GC counts and bounded memory samples are review
inputs only. They do not replace DevTools heap snapshots, allocation-profile
diffs, or retained-object review.

## Decision

The harness now has a verified end-to-end path for producing a
machine-readable memory evidence checklist from a real profile run. The next
memory/allocation slice is still an interactive or otherwise export-capable
DevTools session that captures the checkpoint heap snapshots, allocation
diffs, and retained-object notes listed in the generated manifest.
