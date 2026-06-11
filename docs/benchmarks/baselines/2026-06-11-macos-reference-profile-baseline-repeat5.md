# 2026-06-11 macOS Reference Profile Baseline (Repeat 5)

This note records the first complete local macOS profile baseline matrix for
the Tagflow `1.0.0-alpha.1` stabilization line.

Raw profile artifacts remain ignored under
`build/benchmarks/profile/2026-06-11T08-14-32-397331Z/`. This reviewed note is
the committed evidence handoff.

## Scope

- Run id: `2026-06-11T08-14-32-397331Z`
- Collection commit: `ae5fd01fa6297a5e205cf7b4471a0026072ea753`
- Device: `macos`
- Renderers: `tagflow`, `flutter_html`, `flutter_widget_from_html`
- Fixtures: `ai_answer_rich`, `table_dense`, `large_article`,
  `table_stress`
- Repeats: `5`
- Matrix size: `3 x 4 x 5 = 60` profile runs
- Completion: `60 / 60` passed

## Environment

- Branch: `codex/tagflow-native-runtime-master`
- `tagflow` version: `1.0.0-alpha.1`
- `tagflow_table` version: `1.0.0-alpha.1`
- Flutter SDK: `3.45.0-0.1.pre` on `master`
- Flutter revision: `6af38a904a`
- Dart SDK: `3.11.0-81.0.dev`
- DevTools: `2.51.0`
- Melos version: `7.8.2` from the workspace `pubspec.lock`
- Host OS: `macOS 27.0 (26A5353q)`
- Hardware: `MacBook Pro (Mac16,5)`, `Apple M4 Max`, `16` CPU cores
  (`12` performance, `4` efficiency), `40` GPU cores, `48 GB` RAM
- Power state: AC power, battery `80%`, no thermal or performance warning
  recorded by `pmset`
- Displays attached: built-in `3456 x 2234` Retina display and external
  `2560 x 1440 @ 75 Hz` display

The manifest recorded `flutterVersion: unknown` because, at collection time,
the runner only read `FLUTTER_VERSION`; the Flutter version above was verified
manually with:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH flutter --version
```

Follow-up status: this runner gap was fixed after the baseline was collected.
A later one-cell smoke run,
`build/benchmarks/profile/2026-06-11T08-39-14-109697Z/`, recorded
`flutterVersion: 3.45.0-0.1.pre (master)` without setting `FLUTTER_VERSION`.

## Commands

Collection:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_DEVICE=macos \
TAGFLOW_PROFILE_REPEAT=5 \
dart run melos run benchmark:profile:baselines
```

Summary:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=2026-06-11T08-14-32-397331Z \
dart run melos run benchmark:profile:summarize
```

Completeness gate:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=2026-06-11T08-14-32-397331Z \
TAGFLOW_PROFILE_MIN_REPEATS=5 \
dart run melos run benchmark:profile:check
```

Gate output:

```json
{
  "summaryPath": "/Users/arya/projects/tagflow/build/benchmarks/profile/2026-06-11T08-14-32-397331Z/profile-baseline-summary.json",
  "minRepeats": 5,
  "passed": true,
  "issues": []
}
```

## Summary Results

Values below are means across the five repeats for p90 build/raster timings,
plus the maximum observed worst raster time for the cell.

| Renderer | Fixture | Repeats | P90 build mean ms | P90 raster mean ms | Worst raster max ms | Missed build | Missed raster | Outlier repeats |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| `tagflow` | `ai_answer_rich` | 5 | 0.162 | 1.465 | 8.271 | 0 | 0 | 5 |
| `tagflow` | `large_article` | 5 | 0.281 | 1.720 | 11.743 | 0 | 0 | 0 |
| `tagflow` | `table_dense` | 5 | 0.172 | 0.948 | 7.167 | 0 | 0 | 0 |
| `tagflow` | `table_stress` | 5 | 0.523 | 1.748 | 8.067 | 0 | 0 | 0 |
| `flutter_html` | `ai_answer_rich` | 5 | 0.239 | 0.778 | 9.262 | 0 | 0 | 0 |
| `flutter_html` | `large_article` | 5 | 0.304 | 0.887 | 12.242 | 0 | 0 | 5 |
| `flutter_html` | `table_dense` | 5 | 0.190 | 0.903 | 44.632 | 0 | 1 | 1 |
| `flutter_html` | `table_stress` | 5 | 0.267 | 0.780 | 10.607 | 0 | 0 | 5 |
| `flutter_widget_from_html` | `ai_answer_rich` | 5 | 0.292 | 1.063 | 13.056 | 0 | 0 | 5 |
| `flutter_widget_from_html` | `large_article` | 5 | 0.370 | 1.538 | 16.384 | 0 | 1 | 5 |
| `flutter_widget_from_html` | `table_dense` | 5 | 0.287 | 1.061 | 9.385 | 0 | 0 | 5 |
| `flutter_widget_from_html` | `table_stress` | 5 | 0.355 | 0.977 | 11.501 | 0 | 0 | 5 |

## Review

This run is stronger than the earlier capped baseline because the full default
matrix completed and passed the machine-readable repeat-5 completeness gate.
It proves the current profile harness can collect complete local macOS matrix
evidence for the alpha branch.

Tagflow-specific observations:

- All Tagflow cells completed with no missed build-budget or raster-budget
  frames.
- `table_stress` is the heaviest Tagflow build case in this matrix, with
  `0.523 ms` mean p90 build and `1.748 ms` mean p90 raster.
- `ai_answer_rich` records five outlier repeats because each repeat reported
  old-gen GC, but it still had no missed frame-budget counts.
- `large_article`, `table_dense`, and `table_stress` had no outlier repeats
  under the current summary rules.

Competitor observations:

- `flutter_html/table_dense` had one raster-budget miss and a
  `44.632 ms` worst-raster spike.
- `flutter_widget_from_html/large_article` had one raster-budget miss.
- Many competitor cells are marked as outliers due to old-gen GC. That makes
  the run useful for comparative internal review, not for public ranking copy.

## Suitability

Suitable for:

- alpha stabilization evidence
- proving the baseline runner, summarizer, and repeat-5 completeness gate work
  on a local macOS target
- comparing renderer behavior directionally inside this fixture set
- choosing which cells deserve deeper profiling before stable `1.0.0`

Not suitable for:

- external benchmark claims
- hard performance threshold claims
- CI regression thresholds
- stable `1.0.0` performance claims

Reasons:

- The environment uses Flutter `master` prerelease bits and prerelease macOS.
- The app window size and display selection are not pinned by the harness.
- This is a desktop reference target, not the real internal Flutter app target.
- Physical-device or supported real-app profile evidence is still missing.

## Follow-Up

1. Pin or record benchmark window size and display placement.
2. Repeat the matrix on the chosen stable reference machine after Flutter and
   macOS versions are intentionally selected.
3. Collect supported-target profile evidence in Kite or another internal app
   before stable `1.0.0`.
