# Cold/Warm Native JSON Profile Smoke

## Status

- Date: 2026-06-12 Asia/Kolkata
- Commit: `64617e8338007d99ee8e0c9c4ba40b9c55feaf13`
- Package: `tagflow` `1.0.0-alpha.2`
- Run id: `cold-warm-native-json-smoke`
- Device: macOS profile target
- Fixture pair: `tagflow_native_json:native_ai_answer`
- Repeat count: `1`
- Posture: report-only smoke, not a threshold or public performance claim

## Purpose

Verify that the profile harness emits separate static first-render and warmed
scroll payloads after the cold/warm split:

- `tagflow_native_json_native_ai_answer_initial_render`
- `tagflow_native_json_native_ai_answer_scroll`
- `tagflow_native_json_native_ai_answer_viewport`

This proves artifact wiring and summary support for the new phase labels. It
does not prove a performance regression threshold, renderer ranking, or stable
device baseline.

## Commands

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_PAIR=tagflow_native_json:native_ai_answer \
TAGFLOW_PROFILE_REPEAT=1 \
TAGFLOW_PROFILE_RUN_ID=cold-warm-native-json-smoke \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-cold-warm-smoke \
dart run melos run benchmark:profile:baselines
```

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=cold-warm-native-json-smoke \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-cold-warm-smoke \
dart run melos run benchmark:profile:summarize
```

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=cold-warm-native-json-smoke \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-cold-warm-smoke \
TAGFLOW_PROFILE_MIN_REPEATS=1 \
dart run melos run benchmark:profile:check
```

## Result

- `benchmark:profile:baselines`: passed, wrote one successful artifact.
- `benchmark:profile:summarize`: passed, wrote
  `profile-baseline-summary.json`.
- `benchmark:profile:check`: passed with `minRepeats: 1`, no issues, no
  report-only findings.
- Summary contained `framePhaseSummaries.warmScroll`.
- Summary contained `framePhaseSummaries.coldInitialRender`.
- Viewport metadata was `800x600 @ 2.0x`.

Observed smoke values:

| Phase | Frames | Worst build ms | Worst raster ms | Missed raster budget |
| --- | ---: | ---: | ---: | ---: |
| `coldInitialRender` | 2 | 7.068 | 19.415 | 1 |
| `warmScroll` | 24 | 0.414 | 12.459 | 0 |

## Interpretation

The cold/warm split is wired end to end for the native JSON profile lane. The
single repeat is useful for harness validation only. A release-quality local
reference run still needs the normal repeat count, target qualification, and
reviewed environment notes.
