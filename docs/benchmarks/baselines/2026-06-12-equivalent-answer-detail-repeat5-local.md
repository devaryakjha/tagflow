# 2026-06-12 Equivalent Answer Detail Profile Baseline (Repeat 5)

This note records the first report-only repeat-5 local profile collection for
the transport-equivalent `answer_detail_equivalent_v1` fixture family across
the three first-party Tagflow cells:

- `tagflow:answer_detail_equivalent_v1`
- `tagflow_semantic:answer_detail_equivalent_v1`
- `tagflow_native_json:answer_detail_equivalent_v1_native`

It is internal benchmark evidence only. It does not set thresholds, justify
ranking language, or support public performance or memory claims.

## Status

- Date: 2026-06-12 Asia/Kolkata
- Run id: `2026-06-12-equivalent-answer-detail-repeat5-local`
- Collection commit: `a314875677a4405d0550fd466f694f8a2b4f4196`
- Branch context: detached `HEAD` at the same commit as
  `codex/tagflow-native-runtime-master`
- Device: `macos`
- Selection mode: `pairs`
- Repeats: `5`
- Manifest status counts: `passed=15`
- Summary status counts: `passed=15`
- Check result: failed policy guard on viewport metadata

## Raw Artifacts

Raw artifacts were written only under ignored `build/` output:

```text
build/benchmarks/profile-equivalent-answer-detail-repeat5/2026-06-12-equivalent-answer-detail-repeat5-local/
```

Generated paths reviewed for this note:

- `build/benchmarks/profile-equivalent-answer-detail-repeat5/2026-06-12-equivalent-answer-detail-repeat5-local/profile-baseline-manifest.json`
- `build/benchmarks/profile-equivalent-answer-detail-repeat5/2026-06-12-equivalent-answer-detail-repeat5-local/profile-baseline-summary.json`
- `build/benchmarks/profile-equivalent-answer-detail-repeat5/2026-06-12-equivalent-answer-detail-repeat5-local/tagflow/answer_detail_equivalent_v1/`
- `build/benchmarks/profile-equivalent-answer-detail-repeat5/2026-06-12-equivalent-answer-detail-repeat5-local/tagflow_semantic/answer_detail_equivalent_v1/`
- `build/benchmarks/profile-equivalent-answer-detail-repeat5/2026-06-12-equivalent-answer-detail-repeat5-local/tagflow_native_json/answer_detail_equivalent_v1_native/`

## Commands

Collection:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_PAIR=tagflow:answer_detail_equivalent_v1,tagflow_semantic:answer_detail_equivalent_v1,tagflow_native_json:answer_detail_equivalent_v1_native \
TAGFLOW_PROFILE_REPEAT=5 \
TAGFLOW_PROFILE_RUN_ID=2026-06-12-equivalent-answer-detail-repeat5-local \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-equivalent-answer-detail-repeat5 \
dart run melos run benchmark:profile:baselines
```

Summary:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=2026-06-12-equivalent-answer-detail-repeat5-local \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-equivalent-answer-detail-repeat5 \
dart run melos run benchmark:profile:summarize
```

Policy check:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=2026-06-12-equivalent-answer-detail-repeat5-local \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-equivalent-answer-detail-repeat5 \
TAGFLOW_PROFILE_CHECK_POLICY=docs/benchmarks/policies/profile-reference-runner-policy.json \
dart run melos run benchmark:profile:check
```

Direct checker confirmation:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
dart run packages/tagflow_benchmarks/bin/check_profile_baseline.dart \
  --run-id=2026-06-12-equivalent-answer-detail-repeat5-local \
  --output-dir=build/benchmarks/profile-equivalent-answer-detail-repeat5 \
  --policy=docs/benchmarks/policies/profile-reference-runner-policy.json
```

## Collection Result

All three requested cells completed repeat `5`:

- `tagflow:answer_detail_equivalent_v1`
- `tagflow_semantic:answer_detail_equivalent_v1`
- `tagflow_native_json:answer_detail_equivalent_v1_native`

The manifest recorded `15` successful runs and no failed runs. The summary
recorded `15` successful runs, no failed runs, and `5` observed repeats for
each cell.

## Summary Result

The summary recorded the expected phase families for all three cells:
`coldInitialRender`, `warmRebuild`, and `warmScroll`.

Phase means below are the summary means across the five repeats for the
requested per-phase p90 values.

| Cell | Repeats | Cold p90 build mean ms | Cold p90 raster mean ms | Warm rebuild p90 build mean ms | Warm rebuild p90 raster mean ms | Warm scroll p90 build mean ms | Warm scroll p90 raster mean ms |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| `tagflow:answer_detail_equivalent_v1` | 5 | 7.182 | 14.337 | 1.731 | 6.476 | 0.353 | 1.462 |
| `tagflow_semantic:answer_detail_equivalent_v1` | 5 | 4.318 | 10.848 | 1.454 | 16.097 | 0.356 | 0.983 |
| `tagflow_native_json:answer_detail_equivalent_v1_native` | 5 | 5.456 | 11.501 | 0.939 | 6.959 | 0.262 | 1.112 |

Reviewer-visible summary caveats:

- All three cells recorded viewport metadata as `800x600` logical,
  `800x600` physical, device-pixel-ratio `1.0`.
- `tagflow:answer_detail_equivalent_v1` recorded report-only old-gen GC in the
  summary with `total=8`, `mean=1.6`, and `4` outlier repeats
  (`repeat-02` through `repeat-05`).
- `tagflow_semantic:answer_detail_equivalent_v1` and
  `tagflow_native_json:answer_detail_equivalent_v1_native` recorded no
  outlier repeats and no old-gen GC in this run.

## Check Result

The policy check did not pass.

The sequential `benchmark:profile:check` run and the direct
`check_profile_baseline.dart` invocation returned the same result:

- `passed: false`
- `issues`: three `unexpected_viewport` findings, one for each requested cell
- `reportOnlyFindings`:
  - four `outlier_repeat_present` findings for
    `tagflow:answer_detail_equivalent_v1`
  - one `old_gen_gc_review_required` finding for
    `tagflow:answer_detail_equivalent_v1`

The blocking check issue was consistent across all three cells:

- policy expected viewport:
  `800x600` logical with device-pixel-ratio `2.0`
- observed viewport:
  `800x600` logical, `800x600` physical, device-pixel-ratio `1.0`

This means the repeat-completeness target was met, but the existing
reference-runner viewport guard was not.

## Viewport Policy Audit

This mismatch is a reference-runner qualification issue, not a fixture-specific
harness bug.

- The macOS example app pins the benchmark window to `800 x 600` logical size.
- The profile test records `tester.view.physicalSize` and
  `tester.view.devicePixelRatio` as observed; it does not override DPR.
- The repeated baseline runner exposes no collection flag that can force macOS
  DPR for `benchmark:profile:baselines`.

That means this run's `800x600` physical viewport at device-pixel-ratio `1.0`
came from the host display scale for this local collection, while the current
policy file describes a qualified `2.0x` reference target.

The smallest correct next action is documentation/policy qualification, not an
immediate rerun. Keep this run as local report-only evidence, and only apply
the `800x600 @ 2.0x` viewport policy to macOS runs collected on a reviewed
reference target that is known to provide that display scale. A cheap repeat of
the same local command is not expected to satisfy the policy unless the display
environment changes first.

## Interpretation

This run is useful as first-pass local equivalence-family evidence because it
proves the three intended first-party cells can all complete repeat `5` on the
same local profile harness with a clean manifest and a persisted summary.

It should still be read conservatively. The policy check is not green because
the observed viewport metadata does not satisfy the current reference-runner
guard, and the compatibility HTML cell recorded report-only old-gen GC and
repeat-level outlier flags. Those facts make this a reviewed local collection
result, not claim-ready benchmark evidence.

## Remaining Blockers Before Public Benchmark Wording

- Resolve or explicitly qualify the viewport-guard mismatch between the
  observed `1.0x` DPR run and the current policy's `2.0x` expectation.
- Review the old-gen GC and outlier-repeat findings on
  `tagflow:answer_detail_equivalent_v1` before using this fixture family for
  memory or dynamic-content narratives.
- Keep the result local and report-only until a qualified reference-runner or
  physical-target path exists for the same equivalence family.
- Do not turn this run into a faster/slower or lower-memory claim without the
  missing guard, allocation, and claim-policy follow-up work.
