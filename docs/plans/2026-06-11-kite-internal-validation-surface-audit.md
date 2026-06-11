# Kite Internal Validation Surface Audit

**Status:** audited with isolated Kite proof and real IPO sheet evidence
**Date:** 2026-06-11
**Primary app candidate:** `/Users/arya/projects/kite`
**Primary surface:** IPO details sheet
**Backup surface:** Bulletins and notification detail cards

## Decision

Use Kite's IPO details sheet as the first real internal-app validation surface
for Tagflow's native rich content runtime.

This is the best low-blast-radius target because it already renders
server-authored rich content through Tagflow in one contained screen:

- summary/excerpt HTML
- long-form company content HTML
- links
- tables
- app-owned theme styling
- render-boundary handling
- limited navigation scope inside one bottom sheet flow

The backup surface is Bulletins. It is lower-risk from a product-flow
perspective, but it currently uses Kite's custom link-only markdown parser and
Home preview cards flatten the content to plain text, so it is a weaker first
runtime validation.

## Files Inspected

### Tagflow planning context

- `docs/plans/2026-06-11-internal-app-validation-plan.md`
- `docs/specs/2026-06-11-native-rich-content-runtime.md`
- `docs/plans/2026-06-11-tagflow-v1-alpha-acceptance-status.md`

### Kite app and dependency shape

- `/Users/arya/projects/kite/pubspec.yaml`
- `/Users/arya/projects/kite/analysis_options.yaml`
- `/Users/arya/projects/kite/.fvmrc`
- `/Users/arya/projects/kite/.fvm/flutter_sdk`

### Primary surface: IPO details

- `/Users/arya/projects/kite/lib/screens/ipos/ipo_instrument_sheet.dart`
- `/Users/arya/projects/kite/lib/component/tagflow_details_converter.dart`
- `/Users/arya/projects/kite/lib/mutations/ipo.dart`
- `/Users/arya/projects/kite/lib/models/ipo_info.dart`

### Backup surface: Bulletins

- `/Users/arya/projects/kite/lib/screens/bulletins.dart`
- `/Users/arya/projects/kite/lib/component/bulletin.dart`
- `/Users/arya/projects/kite/lib/screens/home/home_bulletins_section.dart`
- `/Users/arya/projects/kite/lib/models/bulletins.dart`
- `/Users/arya/projects/kite/lib/component/markdown.dart`
- `/Users/arya/projects/kite/lib/component/markdown_dialog.dart`
- `/Users/arya/projects/kite/lib/framework/navigation.dart`
- `/Users/arya/projects/kite/lib/utils/markdown.dart`

### Debug-only validation surface

- `/Users/arya/projects/kite/lib/screens/diagnostics.dart`
- `/Users/arya/projects/kite/lib/main_local.dart`

## Why IPO Details Wins

`/Users/arya/projects/kite/lib/screens/ipos/ipo_instrument_sheet.dart`
already uses Tagflow twice:

- `store.ipoInfo.excerpt` renders in the upper summary section.
- `store.ipoInfo.content` renders in the detailed company section with
  `TagflowOptions(renderBoundary: ...)`, link callbacks, and table converters.

The content contract is explicit in
`/Users/arya/projects/kite/lib/models/ipo_info.dart`:

- `excerpt`
- `content`
- `financials`

The fetch path is already isolated in
`/Users/arya/projects/kite/lib/mutations/ipo.dart` through `GetIPOInfo`.

That makes the validation target real, server-authored, and already app-owned
without needing to invent a new production surface.

## Why Bulletins Is Backup Only

Bulletins are real app content, but the current renderer is a minimal custom
markdown implementation:

- `/Users/arya/projects/kite/lib/component/markdown.dart` only detects
  `[label](url)` links and otherwise renders plain text.
- `/Users/arya/projects/kite/lib/component/bulletin.dart` renders bulletin
  bodies through that parser in popup, sticky, list, and promo cards.
- `/Users/arya/projects/kite/lib/screens/home/home_bulletins_section.dart`
  strips markdown into plain text for Home cards.

That makes Bulletins a good fallback migration target, but a weaker first trial
for validating headings, lists, tables, unsupported content, and native
document/runtime behavior.

## Safe Proof Decision

A tiny proof in Kite was safe because there was already an existing debug-only
surface:

- `/Users/arya/projects/kite/lib/screens/diagnostics.dart`

The proof stayed isolated to that diagnostics UI plus local dependency
overrides. No production route or live content path was widened.

## Kite Proof Applied

The following uncommitted Kite changes were made to prove the path:

- added `/Users/arya/projects/kite/pubspec_overrides.yaml` pointing
  `tagflow` and `tagflow_table` to this Tagflow worktree
- added `/Users/arya/projects/kite/lib/screens/tagflow_validation_preview.dart`
  with a deterministic native-document fixture plus a controlled HTML probe
- added a diagnostics tab in
  `/Users/arya/projects/kite/lib/screens/diagnostics.dart`
- added local-only IPO/RHP fixture handlers in
  `/Users/arya/projects/kite/lib/main_local.dart`
- added a diagnostics-only `Open IPO sheet fixture` action that seeds Kite's
  real `IPOInstrument` and `IPOInfoResponse` models and opens
  `IPOInstrumentSheet`
- switched Kite's legacy custom-converter imports from
  `package:tagflow/tagflow.dart` to `package:tagflow/legacy.dart` in:
  - `/Users/arya/projects/kite/lib/component/tagflow_details_converter.dart`
  - `/Users/arya/projects/kite/lib/screens/ipos/ipo_instrument_sheet.dart`

That import switch is important: the alpha line curates `tagflow.dart` around
the runtime API and keeps selector/converter internals behind `legacy.dart`.
Kite's existing IPO integration still depends on those legacy converter types.

## Validation Commands

### Requested shared FVM path

This was requested for Dart/Flutter commands:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH flutter pub get
```

Observed result in this environment:

- failed
- `flutter` resolved to a master/pre-release toolchain
- Dart reported `3.11.0-81.0.dev`
- Kite requires `sdk: ">=3.11.0 <4.0.0"`

Because pre-release `3.11.0-81.0.dev` sorts before stable `3.11.0`, version
solving failed.

### Repo-local validation path

Used the actual repo-local SDK instead:

```bash
/Users/arya/projects/kite/.fvm/flutter_sdk/bin/flutter pub get
/Users/arya/projects/kite/.fvm/flutter_sdk/bin/flutter analyze \
  lib/screens/diagnostics.dart \
  lib/screens/tagflow_validation_preview.dart \
  lib/screens/ipos/ipo_instrument_sheet.dart \
  lib/component/tagflow_details_converter.dart
```

Results:

- `flutter pub get`: passed
- `flutter analyze ...`: passed after the `legacy.dart` compatibility import fix

Lockfile confirmation:

```bash
rg -n "tagflow|tagflow_table|source: path" /Users/arya/projects/kite/pubspec.lock
```

Confirmed:

- `tagflow` resolved from
  `/Users/arya/projects/tagflow/packages/tagflow`
- `tagflow_table` resolved from
  `/Users/arya/projects/tagflow/packages/tagflow_table`

### Coordinator iOS simulator validation

The coordinator reran the proof against the main Tagflow checkout and captured
real Kite UI evidence.

Commands:

```bash
/Users/arya/projects/kite/.fvm/flutter_sdk/bin/flutter pub get
/Users/arya/projects/kite/.fvm/flutter_sdk/bin/flutter analyze \
  lib/main_local.dart \
  lib/screens/diagnostics.dart \
  lib/screens/tagflow_validation_preview.dart \
  lib/screens/ipos/ipo_instrument_sheet.dart \
  lib/component/tagflow_details_converter.dart
/Users/arya/projects/kite/.fvm/flutter_sdk/bin/flutter run \
  -d 3BA9E377-4B6F-49A7-83FA-F640060D6442 \
  -t lib/main_local.dart
```

Results:

- `flutter pub get`: passed with local path overrides to the coordinator
  Tagflow checkout.
- focused `flutter analyze`: passed.
- iOS simulator run: launched on iPhone 17 simulator
  `3BA9E377-4B6F-49A7-83FA-F640060D6442`.
- macOS run was attempted separately and failed at Apple provisioning:
  no Mac App Development profile for `com.zerodha.kite3`; this was not a
  Tagflow compile failure.
- local `main_local.dart` still returns unrelated 500s for holdings,
  preferences, positions, bulletins, screener, and FCM; these do not block the
  diagnostics or IPO sheet proof.

Evidence:

- `docs/validation/evidence/2026-06-11-kite-tagflow-diagnostics-initial.jpg`
- `docs/validation/evidence/2026-06-11-kite-tagflow-diagnostics-link-tap.jpg`
- `docs/validation/evidence/2026-06-11-kite-tagflow-diagnostics-html-probe.jpg`
- `docs/validation/evidence/2026-06-11-kite-tagflow-diagnostics-button.jpg`
- `docs/validation/evidence/2026-06-11-kite-ipo-sheet-excerpt.jpg`
- `docs/validation/evidence/2026-06-11-kite-ipo-sheet-financials-content.jpg`
- `docs/validation/evidence/2026-06-11-kite-ipo-sheet-table.jpg`

### Debug timeline attribution probe

A profiling worker captured a second simulator run with Flutter debug timeline
profiling extensions enabled after the IPO sheet rendering path was already
visually validated.

Committed compact artifacts:

- `docs/validation/evidence/2026-06-11-kite-ipo-debug-profile-summary.json`
- `docs/validation/evidence/2026-06-11-kite-ipo-debug-profile-reduced-timeline.json`
- `docs/validation/evidence/2026-06-11-kite-ipo-debug-profile-sheet-open.jpg`

The raw `6.4 MB` VM timeline remains local in the Kite checkout under
`kite-devtools-exports/tagflow-ipo-sheet-debug-20260611-profiled/`.

Conservative read:

- the timeline contains `24,263` trace events and `11,646` reduced duration
  events
- Tagflow-labelled debug events include `Tagflow` total `7.927 ms`, max
  `5.332 ms`; `RenderTagflowTable` total `2.404 ms`, max `1.638 ms`; and
  `TableCell` total `1.292 ms`, max `0.151 ms`
- the whole `IPOInstrumentSheet` debug build window was observed at max
  `15.189 ms`

Limitations:

- `flutter run --profile` was rejected for the iPhone 17 simulator because
  Flutter profile mode is unsupported there.
- Xcode Animation Hitches attached to the Kite simulator process but reported
  that the instrument is unsupported on this platform/runtime.
- This debug timeline is useful for attribution and repeatability planning. It
  is not a production performance benchmark.

Verified behavior:

- native `TagflowDocument` rendering works inside Kite diagnostics with app
  theme inheritance, strong inline content, links, nested lists, a semantic
  table, code block, image placeholder, and unsupported-content placeholder.
- HTML adapter policy blocks unsupported/unsafe content in the controlled probe
  while preserving safe links and table rendering.
- the real `IPOInstrumentSheet` renders Tagflow-backed excerpt content through
  Kite's legacy `details`/`summary` converters.
- the real `IPOInstrumentSheet` fetches local RHP JSON through `GetIPOInfo`,
  renders financials, and applies the existing mobile render-boundary markers
  before rendering long-form content, ordered lists, links, and a table.

## Next Integration Steps

1. Discard the current proof-only Kite scaffolding now that visual and debug
   attribution evidence exists in Tagflow docs, unless Kite deliberately wants
   to productize a developer-only diagnostics screen.
2. If Kite moves to the Tagflow alpha dependency line, land only a clean
   dependency update plus the two `package:tagflow/legacy.dart` import switches;
   do not commit the absolute-path `pubspec_overrides.yaml`, current lockfile
   churn, diagnostics preview, or local IPO fixture as-is.
3. Capture dark-mode screenshots of:
   - excerpt section
   - long-form content section
   - table rendering
   - link handling
4. Capture profile evidence for the IPO sheet on a supported physical iOS
   device or Android profile target. The current simulator debug timeline is
   path-attribution evidence only.
5. Confirm the custom `details` and `summary` converter behavior still matches
   product expectations while Kite remains on the alpha compatibility path.
6. Only after the real IPO flow is acceptable should Bulletins be considered as
   a second migration candidate.

## Rollback Plan

If the Kite trial should be removed cleanly:

1. Delete `/Users/arya/projects/kite/pubspec_overrides.yaml`.
2. Delete
   `/Users/arya/projects/kite/lib/screens/tagflow_validation_preview.dart`.
3. Remove the diagnostics tab from
   `/Users/arya/projects/kite/lib/screens/diagnostics.dart`.
4. Revert the two `package:tagflow/legacy.dart` import changes if Kite is going
   back to published `0.0.x` packages only.
5. Run `flutter pub get` again from the Kite root and confirm `pubspec.lock`
   points back to hosted package sources.

## Open Risks

- The chosen production surface is still on the alpha compatibility bridge,
  not pure `Tagflow.document(...)` runtime usage.
- The IPO flow depends on custom `details` and `summary` legacy converters, so
  this trial validates compatibility and native rendering, but not a full
  removal of legacy converter usage.
- The diagnostics and IPO fixtures are deterministic and useful for smoke
  testing, but they are not substitutes for a live server payload capture.
- The shared `/Users/arya/fvm/cache.git/bin` path is currently unsuitable for
  Kite validation on this machine because it resolves to a pre-release Flutter
  toolchain.
- The local Kite proof currently depends on uncommitted app changes and should
  either be cleaned into a deliberate developer feature or removed after the
  Tagflow evidence is no longer needed.
