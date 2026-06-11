# Kite Internal Validation Surface Audit

**Status:** audited with isolated Kite proof, real IPO sheet evidence, and
clean hosted-alpha dependency branch
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

## Cleanup Decision

The proof-only Kite changes have been removed after evidence capture. A
read-only status check on 2026-06-11 showed `/Users/arya/projects/kite` clean
on `feat/dashboard...origin/feat/dashboard`, with no `pubspec_overrides.yaml`
present.

Kite is therefore back on its hosted Tagflow dependency line:

- `tagflow: 0.0.8`
- `tagflow_table: 0.0.4+5`
- IPO files import `package:tagflow/tagflow.dart`, not
  `package:tagflow/legacy.dart`

This is the right post-proof state for the app checkout. The Tagflow evidence
remains in this repository, and no diagnostics fixture, absolute local path
override, or lockfile churn needs to live in Kite.

The clean Kite alpha integration now exists as a separate dependency branch,
not a continuation of the proof patch:

1. branch: `codex/kite-tagflow-alpha-runtime`
2. commit: `d9682aec chore(deps): trial tagflow alpha runtime`
3. changed files: `pubspec.yaml`, `pubspec.lock`,
   `lib/screens/ipos/ipo_instrument_sheet.dart`, and
   `lib/component/tagflow_details_converter.dart`
4. validation: repo-local `flutter pub get` passed, and focused analyzer passed
   for the two IPO Tagflow integration files
5. latest real-route result: an authenticated simulator session reached Bids ->
   IPO -> an IPO row -> the real `IPOInstrumentSheet` in Kite's in-app Dark
   theme
6. remaining: capture named dark-mode screenshots and profile-target evidence
   before considering the migration production-ready

## Clean Alpha Validation Route

The clean hosted-alpha branch should not regain the old diagnostics proof
screen. The next evidence pass should use Kite's real IPO flow first:

1. launch the normal app entrypoint from
   `codex/kite-tagflow-alpha-runtime`
2. use an existing authenticated session, or import a dev session with
   `--dart-define=KITE_ENABLE_DEV_SESSION_TOOLS=true` if a valid secret is
   available
3. navigate through Bids -> IPO
4. tap an IPO instrument row
5. let `SelectIPOInstrument`, `SelectInvestorType`, and the
   `ShowIPOInstrumentSheet` listener open the real bottom sheet

That route is grounded in the current app code:

- `/Users/arya/projects/kite/lib/screens/bids.dart` exposes the IPO tab under
  Bids.
- `/Users/arya/projects/kite/lib/screens/ipos/ipo_screen.dart` opens
  `IPOInstrumentSheet` from its `ShowIPOInstrumentSheet` mutation listener.
- `/Users/arya/projects/kite/lib/mutations/ipo.dart` sets
  `selectedIPOInstrument`, `selectedInvestorType`, and fetches IPO details.
- `/Users/arya/projects/kite/lib/screens/ipos/ipo_instrument_sheet.dart`
  renders the Tagflow-backed excerpt and content from the selected
  instrument's RHP JSON.

The clean `main_local.dart` path is intentionally not the preferred route for
release evidence. It is under-provisioned for a post-login app session and the
latest launch showed unrelated 500s plus a watchlist deserialization failure
before the IPO sheet could be reached. A local fallback should be considered
only if no authenticated session is available, and it should stay narrowly
scoped to IPO evidence: `/ipo/instruments`, `/ipo/applications`, supported UPI
handles, and the selected instrument's `rhp_link?format=json` response. It
should not re-add a diagnostics preview screen, broad local fixture behavior,
or path dependency overrides.

An isolated follow-up worker attempted this real authenticated route from
detached worktree `/Users/arya/.codex/worktrees/2bc2/kite` at the same
`d9682aec` content, because the branch was already checked out elsewhere.

The worker passed the clean-branch gates again:

- no `pubspec_overrides.yaml`, local path dependency, diagnostics preview, local
  IPO fixture, or broad lockfile churn
- lockfile resolved hosted `tagflow` and `tagflow_table` at `1.0.0-alpha.1`
- repo-local `flutter pub get`
- focused analyzer for `lib/screens/ipos/ipo_instrument_sheet.dart` and
  `lib/component/tagflow_details_converter.dart`

The worker then launched the normal app entrypoint, not `main_local.dart`, on
the iPhone 17 simulator with
`--dart-define=KITE_ENABLE_DEV_SESSION_TOOLS=true`. The simulator already had
an authenticated session. The worker set Kite's own stored theme to Dark via
Settings; this matters because Kite reads theme from app state, not simulator
appearance alone.

Real-route result:

- authenticated Home opened in the real app
- Kite's in-app Dark theme was selected
- Computer Use exposed the bottom tab and IPO list accessibility tree after the
  semantic tap path failed to expose the tab bar
- Bids -> IPO was reached
- the first IPO row was tapped
- the real `IPOInstrumentSheet` was reached for `UTKAL`
- logs showed `ShowIPOInstrumentSheet`, `IPOInstrumentSheet UTKAL`, and
  `GetIPOInfo` returning `200`
- the Flutter session was stopped with `q` and reported `Application finished.`

No release evidence files were produced before the bounded worker shutdown, so
there are still no
`docs/validation/evidence/2026-06-11-kite-alpha-ipo-real-*` artifacts. Treat
this as route validation for the clean hosted-alpha branch, not screenshot or
profile evidence. The next pass should repeat the same authenticated route and
capture the named `IPOInstrumentSheet` screenshots before stopping. Profile-mode
evidence still needs a supported physical target or a captured target failure in
the benchmark manifest.

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

### Clean alpha branch validation attempt

A fresh validation worker ran the clean hosted-alpha branch content at
`d9682aec chore(deps): trial tagflow alpha runtime` from detached worktree
`/Users/arya/.codex/worktrees/854b/kite`. Detached HEAD was accepted because the
actual branch was already checked out in a separate Kite worktree and the commit
content matched exactly.

Validation gates that passed:

- commit scope check: exactly `pubspec.yaml`, `pubspec.lock`,
  `lib/screens/ipos/ipo_instrument_sheet.dart`, and
  `lib/component/tagflow_details_converter.dart`
- no `pubspec_overrides.yaml`, local path dependency, diagnostics preview,
  local IPO fixture, or broad lockfile churn
- repo-local `flutter pub get`
- focused analyzer for the two IPO Tagflow integration files
- `flutter devices` found a wireless physical iPhone as a profile-capable
  target candidate

The clean branch could launch `lib/main_local.dart` on the iPhone 17 simulator,
but could not produce a usable IPO-details validation route without
reintroducing proof-only fixture scaffolding. During launch, existing
`main_local.dart` data handlers returned multiple `500` responses, and a
watchlist deserialization exception appeared before the worker reached an IPO
details flow.

Captured evidence:

- `docs/validation/evidence/2026-06-11-kite-alpha-home-dark-launch.jpg`
- `docs/validation/evidence/2026-06-11-kite-alpha-home-after-dark-toggle.jpg`

Conservative read:

- these screenshots prove the clean alpha branch can launch the app to Home
  without the previous diagnostics fixture
- they do not validate the IPO Tagflow surface, because the existing clean app
  flow did not reach `IPOInstrumentSheet`
- the simulator remained visually light after the dark-appearance toggle, so no
  IPO dark-mode claim should be made from this attempt
- no release-grade profile evidence was captured; the profile-capable physical
  device still needs a reachable IPO flow before measurement

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

1. Keep the proof-only Kite scaffolding removed now that visual and debug
   attribution evidence exists in Tagflow docs, unless Kite deliberately wants
   to productize a developer-only diagnostics screen.
2. Continue validation from `codex/kite-tagflow-alpha-runtime`; do not re-add
   the absolute-path `pubspec_overrides.yaml`, current lockfile churn,
   diagnostics preview, or local IPO fixture as-is.
3. Capture dark-mode screenshots of:
   - excerpt section
   - long-form content section
   - table rendering
   - link handling
4. Restore or provide a non-production, non-committed way to reach
   `IPOInstrumentSheet` on the clean alpha branch without broad diagnostics
   scaffolding. The latest clean-branch attempt launched Home but did not reach
   IPO details because existing local data handlers returned `500` and
   watchlist decoding failed.
5. Capture profile evidence for the IPO sheet on a supported physical iOS
   device or Android profile target. The current simulator debug timeline is
   path-attribution evidence only.
6. Confirm the custom `details` and `summary` converter behavior still matches
   product expectations while Kite remains on the alpha compatibility path.
7. Only after the real IPO flow is acceptable should Bulletins be considered as
   a second migration candidate.

## Rollback Plan

The proof rollback has already effectively happened in the Kite checkout. If it
needs to be repeated after a future local proof:

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
- The main Kite checkout is clean and still on hosted `0.0.x` Tagflow packages.
  The alpha dependency migration is isolated on
  `codex/kite-tagflow-alpha-runtime`; the next risk is validating that branch
  against the real IPO surface in dark mode and on a profile-capable target
  without reintroducing proof scaffolding.
- The clean alpha branch can currently launch Home on the simulator, but the
  clean app-local data path does not reliably reach IPO details without the
  prior fixture. Any next proof should avoid committing diagnostics scaffolding
  while still giving validation a deterministic real `IPOInstrumentSheet` route.
