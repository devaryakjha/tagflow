# 2026-06-12 Streamed Profile Output Smoke

This note records a one-repeat local macOS smoke after changing the profile
baseline runner to stream child process stdout/stderr while preserving the
captured `ProcessResult` used for logs and manifest parsing.

It is harness validation only. It does not support public performance or memory
claims.

## Scope

- Run id: `2026-06-12-streamed-profile-output-smoke`
- Branch context: `codex/tagflow-native-runtime-master`
- Review baseline before this patch: `f40c299`
- Renderer/fixture: `tagflow:large_article`
- Device: local macOS profile target
- Repeat count: `1`
- Hold-open seconds: `1`
- Raw artifact policy: generated files stayed under ignored `build/`

## Collection Command

```bash
RUN_ID=2026-06-12-streamed-profile-output-smoke
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

## Streaming Evidence

The terminal showed child `benchmark:profile` output before the runner returned,
including the live VM-service connection line and checkpoint markers:

```text
VMServiceFlutterDriver: Connecting to Flutter application at http://127.0.0.1:58160/VBjBzDpODzw=/
flutter: [tagflow-profile-checkpoint] renderer=tagflow fixture=large_article checkpoint=before_first_render hold_open_seconds=1 action=attach-devtools
flutter: [tagflow-profile-checkpoint] renderer=tagflow fixture=large_article checkpoint=after_first_render hold_open_seconds=1 action=attach-devtools
flutter: [tagflow-profile-checkpoint] renderer=tagflow fixture=large_article checkpoint=after_scroll hold_open_seconds=1 action=attach-devtools
```

The profile manifest still captured the VM service URI after process exit:

```json
{
  "runId": "2026-06-12-streamed-profile-output-smoke",
  "gitCommit": "f40c299f8c0d6ea7293a1805c4c6b248a8557739",
  "profileHoldOpenSeconds": 1,
  "memoryEvidenceManifestPath": "build/benchmarks/profile-memory-evidence/2026-06-12-streamed-profile-output-smoke/memory-evidence-manifest.json",
  "runs": [
    {
      "renderer": "tagflow",
      "fixture": "large_article",
      "status": "passed",
      "vmServiceUri": "http://127.0.0.1:58160/VBjBzDpODzw=/",
      "memoryProfileStatus": "captured"
    }
  ]
}
```

The memory evidence manifest also recorded the corrected top-level `gitCommit`
and generated three checkpoint export plans:

- `before_first_render`
- `after_first_render`
- `after_scroll`

## Summary and Check

Summary command:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=2026-06-12-streamed-profile-output-smoke \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-memory-evidence \
dart run melos run benchmark:profile:summarize
```

Check command:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=2026-06-12-streamed-profile-output-smoke \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-memory-evidence \
TAGFLOW_PROFILE_MIN_REPEATS=1 \
dart run melos run benchmark:profile:check
```

The first check attempt raced summary generation and failed because
`profile-baseline-summary.json` did not exist yet. The sequential check passed
with no blocking issues.

Report-only findings:

- `outlier_repeat_present`: one warm-scroll raster frame exceeded budget
  (`worstRasterMillis: 22.653`, `missedRasterBudgetCount: 1`)
- `memory_allocation_evidence_required`: expected for `tagflow:large_article`

## Decision

The profile baseline runner now exposes child process output while a hold-open
run is still active. This removes the process-table discovery workaround used
in `2026-06-12-memory-vm-service-exporter-smoke.md`.

The next memory evidence slice should use the streamed VM service URI plus the
generated `memory-evidence-manifest.json` checkpoint metadata to export
VM-service heap summaries and allocation profiles at every named checkpoint for
the authored-insertion control/patch pair.
