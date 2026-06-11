# 2026-06-11 Kite IPO Debug Profile Probe

This note records the first real-app runtime attribution probe for Tagflow
inside Kite's IPO details sheet.

It is intentionally classified as debug evidence, not a production benchmark.
The capture proves the local alpha override can render the real app surface and
that Flutter's debug timeline can attribute part of the sheet-open work to
Tagflow widgets/render objects. It does not establish release-mode frame timing
or a publishable performance claim.

## Scenario

- App: `/Users/arya/projects/kite`
- Entry point: `lib/main_local.dart`
- Device: iPhone 17 simulator `3BA9E377-4B6F-49A7-83FA-F640060D6442`
- Flow: Diagnostics -> Tagflow -> Open IPO sheet fixture
- Tagflow packages: local path override to `/Users/arya/projects/tagflow`
- Captured at: `2026-06-11T07:34:00Z`
- Mode: Flutter debug with widget-build, render-layout, and render-paint
  profiling service extensions enabled

Committed evidence artifacts:

- `docs/validation/evidence/2026-06-11-kite-ipo-debug-profile-summary.json`
- `docs/validation/evidence/2026-06-11-kite-ipo-debug-profile-reduced-timeline.json`
- `docs/validation/evidence/2026-06-11-kite-ipo-debug-profile-sheet-open.jpg`

The raw `6.4 MB` VM timeline remains local in the Kite checkout at
`/Users/arya/projects/kite/kite-devtools-exports/tagflow-ipo-sheet-debug-20260611-profiled/vm-timeline.json`.

## Collection Commands

Profile mode was attempted first:

```bash
/Users/arya/projects/kite/.fvm/flutter_sdk/bin/flutter run \
  --profile \
  -d 3BA9E377-4B6F-49A7-83FA-F640060D6442 \
  -t lib/main_local.dart
```

Flutter rejected that mode for this target:

```text
Profilemode is not supported by iPhone 17.
```

The worker then collected debug-mode attribution:

```bash
/Users/arya/projects/kite/.fvm/flutter_sdk/bin/flutter run \
  -d 3BA9E377-4B6F-49A7-83FA-F640060D6442 \
  -t lib/main_local.dart
```

The capture enabled Flutter service extensions for widget build, user widget
build, render-object layout, and render-object paint profiling, cleared the VM
timeline immediately before opening the IPO sheet fixture, then exported the VM
timeline after the sheet rendered.

An Xcode Animation Hitches trace was also attempted by attaching Instruments to
the running Kite simulator process. Instruments attached, but reported that the
Hitches instrument is not supported on this simulator/runtime combination, so
the hitch trace is not used as evidence.

## Debug Timeline Summary

The profiled debug timeline contains:

- `24,263` trace events
- `11,646` reduced duration events
- `15,330` Dart-category events
- `2,722` Embedder-category events
- `236` GC-category events

Top sheet-open duration events included two long frame/build windows:

- `Animator::BeginFrame`: max `31.430 ms`
- `BUILD`: max `17.294 ms`
- `IPOInstrumentSheet`: max `15.189 ms`

Tagflow-labelled debug events:

| Event | Count | Total | Max |
| --- | ---: | ---: | ---: |
| `IPOInstrumentSheet` | 2 | `19.549 ms` | `15.189 ms` |
| `Tagflow` | 2 | `7.927 ms` | `5.332 ms` |
| `TagflowScope` | 2 | `5.792 ms` | `4.038 ms` |
| `TagflowThemeProvider` | 2 | `5.698 ms` | `3.995 ms` |
| `RenderTagflowTable` | 2 | `2.404 ms` | `1.638 ms` |
| `TagflowTable` | 1 | `1.343 ms` | `1.343 ms` |
| `TableCell` | 11 | `1.292 ms` | `0.151 ms` |
| `_TagflowDetailsSection` | 1 | `1.216 ms` | `1.216 ms` |

## Interpretation

This is useful for:

- proving the real Kite IPO sheet can be opened with the Tagflow alpha path
  override
- confirming the VM timeline can attribute work to Tagflow, `TagflowTable`, and
  Kite's sheet widget names
- identifying the next measurement path without adding production
  instrumentation to Kite

This is not suitable for:

- release-mode frame-timing claims
- renderer ranking claims
- regression thresholds
- publishing as a benchmark result

## Next Measurement Gate

The next defensible performance gate is a profile-mode capture on a supported
target:

1. Run the same local alpha override on a physical iOS device or supported
   Android profile target.
2. Open the same Diagnostics -> Tagflow -> Open IPO sheet fixture flow.
3. Capture frame timings plus Xcode Instruments `Time Profiler` or
   `Animation Hitches` where supported.
4. Keep the debug VM timeline as attribution evidence only; use profile/release
   artifacts for performance decisions.
