# 2026-06-12 Input Summary Profile Smoke

This note records the first reviewed local smoke after commit `81db55e`
started emitting profile input-size metadata into
`profile-baseline-summary.json`. It is report-only collection evidence for the
example-app macOS harness. It does not add a timing threshold or support a
public performance claim.

Raw artifacts were written only under ignored `build/` output:

```text
build/benchmarks/profile-input-summary-smoke/2026-06-12-input-summary-profile-smoke/
```

## Scope

- Run id: `2026-06-12-input-summary-profile-smoke`
- Collection commit: `81db55efacf95ca0ccc859ff5d2db58387e9d59c`
- Device: `macos`
- Renderer: `tagflow`
- Fixture: `ai_answer_rich`
- Repeats: `1`
- Manifest status counts: `passed=1`
- Summary status counts: `passed=1`

## Commands

Collection:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_RENDERER=tagflow \
TAGFLOW_FIXTURE=ai_answer_rich \
TAGFLOW_PROFILE_REPEAT=1 \
TAGFLOW_PROFILE_RUN_ID=2026-06-12-input-summary-profile-smoke \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-input-summary-smoke \
TAGFLOW_PROFILE_CONTINUE_ON_FAILURE=true \
dart run melos run benchmark:profile:baselines
```

Summary:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=2026-06-12-input-summary-profile-smoke \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-input-summary-smoke \
dart run melos run benchmark:profile:summarize
```

Completeness check:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=2026-06-12-input-summary-profile-smoke \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-input-summary-smoke \
TAGFLOW_PROFILE_MIN_REPEATS=1 \
dart run melos run benchmark:profile:check
```

## Observed Input Summary

The summarized cell
`tagflow:ai_answer_rich` recorded `cellSummaries[].inputSummary` with:

- `observedRepeats: 1`
- `inputBytes: min=max=mean=median=2059`
- `inputLength: min=max=mean=median=2059`
- `sourceTypes: ["html"]`
- `assetPaths: ["packages/tagflow_benchmarks/fixtures/html/ai_answer_rich.html"]`

The same summary also recorded:

- viewport `800x600` logical, `1600x1200` physical, `devicePixelRatio=2.0`
- `failedRuns: []`
- check result `passed: true` with `minRepeats: 1`

## Review

This smoke confirms the new input-size metadata survives the full local
profile baseline path: profile collection, manifest persistence, summary
generation, and completeness checking. The strongest supported conclusion is
narrow: reviewed notes can now cite fixture size directly from
`profile-baseline-summary.json` for this lane without copying raw profile JSON.
