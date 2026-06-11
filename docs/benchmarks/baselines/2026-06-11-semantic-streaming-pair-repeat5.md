# 2026-06-11 Semantic Streaming Pair Baseline (Repeat 5)

This note records a report-only paired profile run comparing the semantic
full-reparse streaming lane with the semantic document-patch streaming lane.
It is evidence for Tagflow's dynamic-content direction, not a public
performance claim.

Raw profile artifacts remain ignored under:

```text
build/benchmarks/profile-pair/2026-06-11-semantic-streaming-pair-repeat5/
```

The run was collected in an isolated coordinator worker checkout. This reviewed
note is the committed evidence handoff.

## Scope

- Run id: `2026-06-11-semantic-streaming-pair-repeat5`
- Collection commit: `67b778474834cb8787e8b89b4d7d323f29ad4273`
- Device: `macos`
- Selection mode: `pairs`
- Repeats: `5`
- Completion: `10 / 10` passed
- Pair 1: `tagflow_semantic` with `streaming_ai_chunks`
- Pair 2: `tagflow_semantic_patch` with `streaming_ai_patches`

## Environment

- Branch: `codex/tagflow-native-runtime-master`
- `tagflow` version: `1.0.0-alpha.1`
- Dart SDK: `3.11.0-81.0.dev`
- Flutter SDK: `3.45.0-0.1.pre (master)`
- Host OS: `macOS 27.0 (26A5353q)`
- Flutter device id: `macos`
- Recorded viewport: `800 x 600` logical, `1600 x 1200` physical,
  device-pixel-ratio `2.0`

## Commands

Collection:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_PAIR=tagflow_semantic:streaming_ai_chunks,tagflow_semantic_patch:streaming_ai_patches \
TAGFLOW_PROFILE_REPEAT=5 \
TAGFLOW_PROFILE_RUN_ID=2026-06-11-semantic-streaming-pair-repeat5 \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-pair \
TAGFLOW_PROFILE_CONTINUE_ON_FAILURE=true \
dart run melos run benchmark:profile:baselines
```

Summary:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=2026-06-11-semantic-streaming-pair-repeat5 \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-pair \
dart run melos run benchmark:profile:summarize
```

Completeness and viewport check:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
dart run packages/tagflow_benchmarks/bin/check_profile_baseline.dart \
  --run-id=2026-06-11-semantic-streaming-pair-repeat5 \
  --output-dir=build/benchmarks/profile-pair \
  --min-repeats=5 \
  --expected-logical-size=800x600 \
  --expected-device-pixel-ratio=2
```

Check output:

```json
{
  "minRepeats": 5,
  "passed": true,
  "issues": []
}
```

## Summary Results

Values below are means across five repeats unless otherwise noted. They are
profile harness measurements for review, not pass/fail thresholds.

| Renderer | Fixture | Repeats | P90 build mean ms | P90 raster mean ms | Worst raster max ms | Missed build total | Missed raster total | Outlier repeats |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| `tagflow_semantic` | `streaming_ai_chunks` | 5 | 0.192 | 2.189 | 11.410 | 0 | 0 | 0 |
| `tagflow_semantic_patch` | `streaming_ai_patches` | 5 | 0.239 | 2.318 | 16.563 | 0 | 1 | 5 |

GC observations:

- `tagflow_semantic` recorded `2` new-gen GC events per repeat and no old-gen
  GC events.
- `tagflow_semantic_patch` recorded `4` new-gen GC events and `2` old-gen GC
  events per repeat.
- Every patch-lane repeat was marked as an outlier for `old_gen_gc`.
- Patch repeat 5 also recorded one missed raster-budget frame with
  `16.563 ms` worst raster time.

## Review

This run proves the paired baseline runner can collect a complete repeat-5
macOS comparison for the two intended dynamic-content lanes without weakening
fixture compatibility. The manifest records `selectionMode: pairs` and the
ordered pair list, so the run is not a misleading renderer-by-fixture matrix.

The patch lane is functionally complete under the harness, but the old-gen GC
pattern means this run should be treated as a diagnostic signal. It does not
support a claim that patch streaming is faster than full reparsing. The useful
takeaway is narrower: the patch lane is measurable, complete, and now has
repeat-based evidence showing where to profile next.

## Suitability

Suitable for:

- dynamic-content stabilization evidence
- validating the paired baseline runner and summary/check workflow
- identifying GC and raster-spike follow-up work for the patch lane

Not suitable for:

- external benchmark claims
- hard threshold policy
- stable `1.0.0` performance claims
- claims that document patches are faster than full HTML reparses

## Follow-Up

1. Profile the patch lane's old-gen GC behavior before any public dynamic
   performance claim.
2. Repeat this paired run after HTML adapter authored-ID support lands, because
   stable source IDs should make future dynamic fixtures more realistic.
3. Keep `tagflow_semantic_patch` report-only until the reference environment and
   dynamic-content regression policy are reviewed.
