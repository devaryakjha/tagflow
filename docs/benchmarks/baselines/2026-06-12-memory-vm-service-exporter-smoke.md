# 2026-06-12 Memory VM-Service Exporter Smoke

This note records the first live smoke of
`benchmark:memory-evidence:export` against a hold-open Tagflow profile run. It
is report-only evidence tooling validation. It does not support public memory
or allocation claims.

## Scope

- Run id: `2026-06-12-memory-exporter-large-article-smoke`
- Branch context: `codex/tagflow-native-runtime-master`
- Review commit: `de1425bf47cff20f29d5745470a43e9431f4096d`
- Renderer/fixture: `tagflow:large_article`
- Device: local macOS profile target
- Repeat count: `1`
- Hold-open seconds: `60`
- Raw artifact policy: generated files stayed under ignored `build/`

## Collection Command

```bash
RUN_ID=2026-06-12-memory-exporter-large-article-smoke
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
TAGFLOW_PROFILE_HOLD_OPEN_SECONDS=60 \
dart run melos run benchmark:profile:baselines
```

The profile run completed successfully and wrote:

- `profile-baseline-manifest.json`
- `profile-baseline-summary.json`
- `memory-evidence-manifest.json`
- `tagflow/large_article/repeat-01.json`
- `tagflow/large_article/repeat-01-memory.json`
- `tagflow/large_article/repeat-01.log`

The profile manifest recorded:

```json
{
  "runId": "2026-06-12-memory-exporter-large-article-smoke",
  "gitCommit": "de1425bf47cff20f29d5745470a43e9431f4096d",
  "device": "macos",
  "repeatCount": 1,
  "profileMemory": true,
  "profileHoldOpen": true,
  "profileHoldOpenSeconds": 60,
  "memoryEvidenceManifestPath": "build/benchmarks/profile-memory-evidence/2026-06-12-memory-exporter-large-article-smoke/memory-evidence-manifest.json"
}
```

## Export Command

While the profile process was still holding checkpoints open, the app VM
service URI was discovered from the live process table:

```text
http://127.0.0.1:56683/dQxv7cxemwY=/
```

Then the exporter was run:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_MEMORY_EVIDENCE_VM_SERVICE_URI=http://127.0.0.1:56683/dQxv7cxemwY=/ \
TAGFLOW_MEMORY_EVIDENCE_CHECKPOINT=tagflow-large_article-repeat-01-live_process_probe \
TAGFLOW_MEMORY_EVIDENCE_OUTPUT_DIR=build/benchmarks/profile-memory-evidence/2026-06-12-memory-exporter-large-article-smoke/devtools \
dart run melos run benchmark:memory-evidence:export
```

The exporter returned:

```json
{
  "vmServiceUri": "http://127.0.0.1:56683/dQxv7cxemwY=/",
  "isolateId": "isolates/2151489728005875",
  "checkpoint": "tagflow-large_article-repeat-01-live_process_probe",
  "heapSummaryPath": "/Users/arya/projects/tagflow/build/benchmarks/profile-memory-evidence/2026-06-12-memory-exporter-large-article-smoke/devtools/tagflow-large_article-repeat-01-live_process_probe-heap-summary.json",
  "allocationProfilePath": "/Users/arya/projects/tagflow/build/benchmarks/profile-memory-evidence/2026-06-12-memory-exporter-large-article-smoke/devtools/tagflow-large_article-repeat-01-live_process_probe-allocation-profile.json"
}
```

Generated exporter artifacts:

- `devtools/tagflow-large_article-repeat-01-live_process_probe-heap-summary.json`
  (`5.0K`)
- `devtools/tagflow-large_article-repeat-01-live_process_probe-allocation-profile.json`
  (`3.8M`)

## Exported Evidence Summary

The heap summary recorded:

```json
{
  "type": "tagflow.memory.heapSummary",
  "name": "main",
  "objectCount": 228070,
  "classCount": 1197,
  "shallowSize": 25778640,
  "capacity": 32057328,
  "externalSize": 16912,
  "referenceCount": 1368303
}
```

Largest shallow-size classes in this single snapshot:

| Class | Library | Instances | Shallow size |
| --- | --- | ---: | ---: |
| `InstructionsSection` | empty | `2` | `5531296` |
| `Code` | empty | `24382` | `3873600` |
| `_OneByteString` | `dart:core` | `39283` | `2957248` |
| `CodeSourceMap` | empty | `19083` | `2233984` |
| `_List` | `dart:core` | `23011` | `2075936` |

The allocation profile recorded `MemoryUsage`:

```json
{
  "externalUsage": 16912,
  "heapCapacity": 21020672,
  "heapUsage": 14574560
}
```

It contained `3956` class heap-stat entries. The run requested service GC and
recorded `dateLastServiceGC`.

## Summary and Check

Summary command:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=2026-06-12-memory-exporter-large-article-smoke \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-memory-evidence \
dart run melos run benchmark:profile:summarize
```

Check command:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=2026-06-12-memory-exporter-large-article-smoke \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-memory-evidence \
TAGFLOW_PROFILE_MIN_REPEATS=1 \
dart run melos run benchmark:profile:check
```

The summary recorded `totalRuns: 1`, `successfulRuns: 1`, and no failed runs.
The checker passed with no blocking issues and emitted the expected report-only
`memory_allocation_evidence_required` finding for `tagflow:large_article`.

## Limitations

- This is one local macOS repeat on Flutter master and prerelease macOS; it is
  not a claim-grade reference environment.
- The exporter captured one live process-table probe, not all named
  `before_first_render`, `after_first_render`, and `after_scroll` checkpoints.
- The generated `memory-evidence-manifest.json` was written after the profile
  process exited, so its per-checkpoint helper commands could not be used
  during this same run. The live URI had to be discovered from `ps`.
- This run's `memory-evidence-manifest.json` predates the follow-up fix that
  mirrors `gitCommit` into the memory evidence manifest. The profile manifest
  did record the commit correctly.
- The heap summary is class-level. Retained-object interpretation and raw
  DevTools heap/diff exports are still reviewer work when class-level summaries
  are not enough.

## Decision

The VM-service exporter is validated against a real hold-open profile target.
It can produce useful report-only allocation-profile and heap-summary artifacts
without the DevTools UI.

The next harness improvement is to stream child profile process output, or
otherwise expose the VM service URI before the run exits, so the generated
`memory-evidence-manifest.json` commands can be used at the intended named
checkpoints instead of relying on process-table discovery.
