# Kite Internal Validation Surface Audit

**Status:** audited with isolated Kite proof
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
  `/Users/arya/.codex/worktrees/3476/tagflow/packages/tagflow`
- `tagflow_table` resolved from
  `/Users/arya/.codex/worktrees/3476/tagflow/packages/tagflow_table`

## Integration Steps For The Real Trial

1. Keep the debug-only diagnostics proof only as a local smoke screen.
2. Validate the real IPO details sheet with the local path overrides still in
   place.
3. Capture light and dark screenshots of:
   - excerpt section
   - long-form content section
   - table rendering
   - link handling
4. Confirm the render-boundary markers still isolate the intended mobile
   section in `store.ipoInfo.content`.
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
- The diagnostics fixture is deterministic and useful for smoke testing, but it
  is not a substitute for a live IPO payload capture.
- The shared `/Users/arya/fvm/cache.git/bin` path is currently unsuitable for
  Kite validation on this machine because it resolves to a pre-release Flutter
  toolchain.
