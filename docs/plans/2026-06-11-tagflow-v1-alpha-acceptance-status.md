# Tagflow v1 Alpha Acceptance Status

This tracker records the coordination state for the `1.0.0-alpha.1` native
rich content runtime line.

Snapshot:

- Branch: `codex/tagflow-native-runtime-master`
- Latest validated coordinator commit before this status refresh:
  `42feeff docs(benchmarks): record ordered insertion patch baseline`
- Latest validated implementation commits: `8ed0686 fix(table): preserve HTML
  table captions`, `74a9c9c bench(profile): record viewport metadata`,
  `c137a7b bench(profile): support custom baseline output dirs`,
  `3df1b5a bench(profile): detect flutter version in manifests`,
  `34ea827 feat(bench): add opt-in viewport gate`, `d4135c7 bench(profile):
  use ordered insert patches for authored stream`
- Spec source: `docs/specs/2026-06-11-native-rich-content-runtime.md`
- Status date: 2026-06-11

## Acceptance Criteria

| # | Criterion | Current Status | Evidence / Owner |
| ---: | --- | --- | --- |
| 1 | Public `TagflowDocument` model exists and is canonical renderer input. | Done | `TagflowDocument` powers `Tagflow.document(...)`; `b889b15` routes built-in HTML entry points through the same document/runtime render path. |
| 2 | Public `TagflowHtmlAdapter` exists and is canonical HTML entry point. | Done | `TagflowHtmlAdapter` exists; `Tagflow.html(...)` and legacy `Tagflow(html: ...)` parse through it before semantic rendering, with a deliberate legacy-converter compatibility path. |
| 3 | `Tagflow.html(...)` renders through the new document runtime for the built-in supported feature set. | Done | HTML entry points now parse through `TagflowHtmlAdapter` into `TagflowDocument` and render built-ins through `TagflowComponentRegistry.builtIn`; focused widget tests cover semantic routing, inline semantics, render boundaries, and custom legacy converter compatibility. |
| 4 | Built-in feature set covers headings, paragraphs, emphasis, links, lists, blockquotes, code, images, and tables. | Done | `26200be` adds semantic renderer coverage for the built-in feature set; `e7898f3` adds first-class `TagflowInlineSemantic` presentation for emphasis/strong and related inline semantics while preserving legacy fallback hints. |
| 5 | Public `TagflowContentPolicy` exists with safe defaults and tests. | Done | Content policy and unsafe-content tests exist from the adapter/policy slice, and HTML entry points now use the adapter path by default. |
| 6 | Semantic `TagflowComponentRegistry` exists and can override a built-in renderer. | Done | Registry exists, is public, and `Tagflow.document(..., registry:)` tests prove override behavior. |
| 7 | Render-boundary behavior still works for HTML input. | Done | `da6de66` adds `Tagflow.html(..., renderBoundary: ...)` coverage and proves legacy `TagflowOptions(renderBoundary: ...)` still works. |
| 8 | Public API separates runtime view options from HTML-adapter options. | Done | `da6de66` adds `TagflowViewOptions`, keeps `TagflowOptions` as a compatibility wrapper, and removes `renderBoundary` from the runtime view-options surface. |
| 9 | Package exports are curated so new adopters do not import internals accidentally. | Done | `packages/tagflow/lib/tagflow.dart` now exports the alpha-facing runtime API, while parser/converter/core compatibility surfaces moved to `package:tagflow/legacy.dart`; `test/src/public_api/export_test.dart` covers both barrels. |
| 10 | Migration document exists from `0.0.x` HTML-first usage to alpha runtime. | Done | `docs/migration/2026-06-11-tagflow-v1-alpha-migration.md`. |

## Benchmark Status

Current reviewed profile baseline evidence is recorded in
`docs/benchmarks/baselines/2026-06-11-macos-reference-profile-baseline-repeat5.md`.
The earlier capped subset remains in
`docs/benchmarks/baselines/2026-06-11-macos-reference-profile-baseline-capped.md`
as historical evidence for why the repeat-5 gate was added.
The first real-app attribution probe is recorded in
`docs/benchmarks/baselines/2026-06-11-kite-ipo-debug-profile-probe.md`.

Passed commands on this branch:

```bash
dart format --set-exit-if-changed packages/tagflow/lib/src/render/component_registry.dart packages/tagflow/test/src/render/component_registry_test.dart packages/tagflow/lib/src/adapters/html_adapter.dart packages/tagflow/lib/src/tagflow_options.dart packages/tagflow/lib/src/tagflow_widget.dart packages/tagflow/test/src/runtime/html_adapter_widget_test.dart packages/tagflow/test/src/tagflow_options_test.dart
flutter analyze
flutter test test/src/render test/src/runtime test/src/tagflow_options_test.dart
flutter test
cd ../tagflow_table && flutter analyze && flutter test
cd ../tagflow_benchmarks && flutter analyze && flutter test
dart run melos run benchmark:fixtures
dart run melos run benchmark:micro
dart run melos run benchmark:render
dart run melos run publish:dry-run
dart run melos run validate
```

The benchmark harness is real but still alpha-grade:

- parser and widget-test render benchmarks are reproducible locally
- generated parser/render microbenchmark JSON artifacts stay ignored under
  `packages/tagflow_benchmarks/build/`
- profile baseline artifacts stay ignored under workspace-root
  `build/benchmarks/profile/`
- direct Dart CLI execution is not valid yet because the benchmark package
  imports Flutter-facing Tagflow code and plain Dart has no `dart:ui`
- profile-mode frame timing is automated enough for repeatable local and
  reference-runner collection, but remains report-only until a reviewed
  reference machine baseline exists
- `docs/benchmarks/policies/profile-reference-runner-policy.json` now codifies
  the candidate alpha reference-runner policy as report-only: five successful
  repeats plus `800x600 @ 2.0 DPR` viewport metadata, with timing thresholds
  explicitly rejected by the policy parser. The older repeat-5 baseline
  predates viewport metadata, so it remains valid historical completion
  evidence but does not satisfy the newer policy without a fresh collection.

## Current Integration Queue

1. Benchmark-gating worker landed `34ea827`, adding an opt-in viewport and
   device-pixel-ratio guard to the profile baseline check. The default alpha
   collection-completeness gate remains unchanged.
2. Benchmark-policy worker landed `e373018`, adding a machine-readable
   report-only reference-runner policy and Melos checker wiring. A new
   reference collection must be run before claiming the policy is satisfied by
   a repeat-5 matrix.
3. The package-specific alpha tags have been pushed and the publish workflows
   succeeded:
   `tagflow-v1.0.0-alpha.1` and `tagflow_table-v1.0.0-alpha.1`.
   pub.dev now contains `1.0.0-alpha.1` for both packages, although each
   package's default latest version still points at the prior stable `0.0.x`
   line because these are prereleases.
4. Kite alpha-dependency branch preparation is complete on isolated branch
   `codex/kite-tagflow-alpha-runtime` at `d9682aec`. The branch updates only
   the two hosted package constraints, the two IPO legacy imports, and the
   regenerated lockfile, with no diagnostics proof scaffolding or local path
   overrides.
5. Clean hosted-alpha real-route validation has now reached Kite's real
   `IPOInstrumentSheet` from an authenticated normal app session in Kite's
   in-app Dark theme, and named dark-mode screenshot artifacts now exist.
   Release-grade physical or otherwise qualified profile evidence is still
   missing.

## Release Prep Status

- `packages/tagflow` is set to `1.0.0-alpha.1` and describes Tagflow as a
  native rich content runtime with HTML support through a first-party adapter.
- `packages/tagflow_table` is set to `1.0.0-alpha.1` because it is a
  publishable first-party extension constrained to the breaking alpha core line.
- Workspace consumers in `examples/tagflow` and `packages/tagflow_benchmarks`
  use `^1.0.0-alpha.1` constraints.
- `publish:dry-run` runs `dart run melos publish --no-private --yes`, keeping
  publish validation non-interactive while still using Melos dry-run mode.
- Fresh coordinator evidence: `dart run melos run publish:dry-run`, with
  `/Users/arya/fvm/cache.git/bin` on `PATH`, validates both `tagflow` and
  `tagflow_table` with 0 warnings.
- Fresh coordinator evidence: `dart run melos run validate`, with
  `/Users/arya/fvm/cache.git/bin` on `PATH`, passes analysis, format checks,
  and coverage tests for `tagflow`, `tagflow_table`, and
  `tagflow_benchmarks`.
- The local alpha benchmark baseline now reports package version
  `1.0.0-alpha.1`.
- Independent release-audit worker `019eb4f5-b537-7f40-bd1c-1fc301265129`
  refreshed to `4df25cd` and reported `DONE` / `ready`: `git status
  --short --branch`, `git diff --check`, `dart run melos run validate`, and
  `dart run melos run publish:dry-run` all passed, with both packages
  validating at 0 warnings and no files changed in the audit worktree.
- Release tags `tagflow-v1.0.0-alpha.1` and
  `tagflow_table-v1.0.0-alpha.1` were pushed at coordinator commit `619c5f2`.
  GitHub Actions publish runs `27336082485` (`Publish tagflow`) and
  `27336081061` (`Publish tagflow_table`) both completed successfully.
  The pub.dev package APIs include `1.0.0-alpha.1` in both package version
  lists.
- Kite alpha dependency trial branch `codex/kite-tagflow-alpha-runtime` was
  prepared in isolated worktree `/Users/arya/.codex/worktrees/f4d8/kite` at
  `d9682aec chore(deps): trial tagflow alpha runtime`. Focused validation
  passed with Kite's repo-local Flutter SDK: `flutter pub get`, then
  `flutter analyze` for `lib/screens/ipos/ipo_instrument_sheet.dart` and
  `lib/component/tagflow_details_converter.dart`.

## `1.0.0-alpha.2` Native Transport Prep

Status: core-only alpha.2 candidate metadata is prepared. The Melos
`version:alpha` lane could not run in the coordinator checkout because the
local branch has no upstream tracking branch and Melos tried to execute
`git pull --tags -f`; the coordinator avoided attaching this branch to
`origin/main` and applied a reviewed manual version bump instead.

Public API surface to call out in `1.0.0-alpha.2`:

- `TagflowNativeBlockCodec`
- `TagflowNativeBlockPatchEnvelope`
- native JSON document decode/adapt/render path:
  `decodeDocument(...)` -> `TagflowNativeBlockAdapter.adapt(...)` ->
  `Tagflow.document(...)`
- patch envelope decode/adapt/apply path:
  `decodePatchEnvelope(...)` ->
  `TagflowNativeBlockAdapter.adaptPatches(...)` ->
  `TagflowDocument.applyPatches(...)`
- report-only native transport benchmark lane:
  `dart run melos run benchmark:native-transport`

Release scope boundaries:

- Alpha only; APIs can still change before stable `1.0.0`.
- Native JSON transport is data-only and for trusted/app-controlled producers.
- Benchmark evidence is report-only local smoke evidence.
- Do not claim arbitrary CMS sync, JavaScript execution, arbitrary webpage
  rendering, Flutter widget serialization, or public performance wins.
- `tagflow` is bumped to `1.0.0-alpha.2`.
- Workspace consumers in `examples/tagflow` and `packages/tagflow_benchmarks`
  use `^1.0.0-alpha.2`.
- `tagflow_table` remains `1.0.0-alpha.1`; it has no required package change
  for the native JSON transport slice.
- Real-app consumption evidence from Kite confirms the publish need: hosted
  `tagflow` `1.0.0-alpha.1` cannot compile against
  `TagflowNativeBlockCodec` or `TagflowNativeBlockAdapter`, while a temporary
  local override to the coordinator Tagflow checkout passed the test-only
  decode/adapt/patch-apply path. Kite should not commit a native transport
  fixture or production integration until a hosted prerelease exposes those
  symbols.

Coordinator publish gap before alpha.2:

1. Run the branch gate:

   ```bash
   PATH=/Users/arya/fvm/cache.git/bin:$PATH \
   dart run melos run validate
   ```

2. Run publish validation without publishing:

   ```bash
   PATH=/Users/arya/fvm/cache.git/bin:$PATH \
   dart run melos run publish:dry-run
   ```

3. Publish only after the version/changelog diff, validation gate, and dry-run
   output are reviewed by the coordinator.

## Post-Alpha Stabilization Progress

- `tagflow_table` now exposes `tagflowTableComponents(...)`, a first-party
  semantic registry fragment for rendering native `TagflowDocument` table nodes
  through the package's custom `TagflowTable` render object. The legacy HTML
  converter bridge remains available during alpha.
- The `tagflow_table` semantic registry now preserves inline table-cell runs
  instead of stacking all cell children vertically, closing a concrete native
  runtime parity gap for mixed text/emphasis/link-like cell content.
- The `tagflow_table` semantic registry now applies normalized native
  presentation hints for row/cell `backgroundColor` and cell `padding`, reducing
  dependence on the legacy HTML table converter for styled semantic table cells.
- The HTML adapter now normalizes semantic table presentation hints for
  `border`, `cellpadding`, `cellspacing`, `border-spacing`,
  `border-collapse: collapse`, and row/cell inline `background-color` or
  `padding` styles. The `tagflow_table` semantic registry consumes those hints
  to render native borders, spacing, and cell padding without re-parsing
  HTML-shaped table state.
- The HTML adapter now normalizes row/cell horizontal alignment hints from
  `align` attributes and `text-align` inline styles. The semantic table
  registry consumes those hints with cell-level alignment taking precedence
  over row-level alignment.
- The example app now has a Tagflow-only benchmark route plus
  `integration_test`/`flutter drive --profile` scaffold. The profile harness
  accepts `TAGFLOW_RENDERER` and `TAGFLOW_FIXTURE` environment variables so
  competitor adapters can plug into the same result path. `dart run melos run
  benchmark:profile` passed locally on macOS and wrote ignored frame timing
  output to `examples/tagflow/build/integration_response_data.json`.
- Competitor profile adapters have landed for `flutter_html` and
  `flutter_widget_from_html`. The `flutter_html` lane uses
  `flutter_html_table` for the shared `ai_answer_rich` table fixture, and the
  `flutter_widget_from_html` lane intentionally uses
  `flutter_widget_from_html_core` because the shared alpha fixtures do not need
  the enhanced package's media or iframe mixins. Local `benchmark:profile`
  smoke runs passed for `TAGFLOW_RENDERER=tagflow`,
  `TAGFLOW_RENDERER=flutter_html`, and
  `TAGFLOW_RENDERER=flutter_widget_from_html`.
- The deterministic benchmark corpus now includes `table_stress`, registered
  with fixture validity coverage and exercised by parser and widget render
  benchmark lanes. A Tagflow-only profile smoke run for
  `TAGFLOW_FIXTURE=table_stress` passed locally on macOS.
- The profile harness now includes a Tagflow-only `streaming_ai_chunks`
  scenario for dynamic AI-answer updates. It renders four progressively larger
  chunks of `ai_answer_rich`, records per-chunk update latencies, and then runs
  the existing scroll measurement on the final document. A local macOS profile
  smoke run passed and emitted viewport, update, update-latency, and scroll
  payloads.
- The example benchmark renderer registry now separates `tagflow` compatibility
  measurements from `tagflow_semantic` native-runtime measurements. The
  semantic lane parses HTML through `TagflowHtmlAdapter`, renders
  `TagflowDocument` through semantic components, and uses the first-party
  `tagflow_table` semantic registry extension for tables. A local
  `TAGFLOW_RENDERER=tagflow_semantic TAGFLOW_FIXTURE=streaming_ai_chunks`
  macOS profile smoke passed and emitted viewport, update, update-latency, and
  scroll payloads; the result remains report-only.
- The runtime now exposes immutable `TagflowDocumentPatch` updates for
  replace-node, append-children, and remove-node operations through the public
  runtime barrel. Focused runtime coverage proves missing-target failure,
  duplicate-ID failure, replacement-ID validation, ordered patch application,
  and untouched branch identity preservation. No document controller or adapter
  cache has landed yet.
- The example profile harness now includes a report-only semantic document
  patch lane: `TAGFLOW_RENDERER=tagflow_semantic_patch` with
  `TAGFLOW_FIXTURE=streaming_ai_patches`. It adapts the rich AI-answer HTML
  fixture into a `TagflowDocument` once, applies `TagflowDocumentPatch`
  append-child updates over four stream steps, and emits the same viewport,
  update, update-latency, and final scroll payload families as the full-reparse
  streaming lane.
- The authored-ID ordered-insertion benchmark pair is now also landed and
  documented. The patch lane uses ordered `insertBefore(...)` updates for
  authored sibling insertions, and the bounded repeat-3 and repeat-5 review
  notes live under `docs/benchmarks/baselines/`.
  This remains report-only completion evidence, not a threshold update or
  faster/slower claim. The repeat-5 run completed and passed the direct check,
  but still surfaced report-only update-path outliers in both lanes.
- The macOS `benchmark:profile` script now passes
  `INTEGRATION_TEST_SHOULD_REPORT_RESULTS_TO_NATIVE=false`, suppressing the
  Flutter `integration_test plugin was not detected` warning while preserving
  the VM-service JSON result path used by `integrationDriver()`.
- The example macOS benchmark host no longer carries legacy CocoaPods
  integration files, so the separate Flutter CocoaPods/SPM migration warning is
  no longer expected during benchmark dependency/build preparation.
- `benchmark:profile:baselines` now runs a selected profile renderer/fixture
  matrix, copies each raw profile JSON artifact under ignored workspace-root
  `build/benchmarks/profile/<run-id>/`, and writes a manifest with toolchain,
  OS, git commit, device, renderer, fixture, repeat, exit code, and artifact
  paths.
- `docs/benchmarks/2026-06-11-reference-runner-baseline-plan.md` defines the
  reference-runner workflow and keeps frame timings report-only until a named
  reference machine has run the default matrix with repeated passes and reviewed
  outliers.
- `docs/benchmarks/policies/profile-reference-runner-policy.json` makes that
  report-only posture executable for future reference collections. It enforces
  repeat count and viewport metadata when opted in, but rejects timing gates
  until a stable machine and numeric threshold review exist.
- `docs/plans/2026-06-11-internal-app-validation-plan.md` now describes the
  first internal app trial path, including local dependency overrides, content
  selection, rendering fidelity, interaction, performance, theming, failure
  policy, rollback, and evidence capture. The example app also exposes a
  deterministic internal-app validation screen that exercises app-authored
  `TagflowDocument` content, app-owned link handling, controlled HTML policy,
  image fallback, and table content.
- `docs/plans/2026-06-11-kite-internal-validation-surface-audit.md` records the
  first real app trial evidence from Kite. The coordinator validated local path
  overrides against `/Users/arya/projects/tagflow`, launched Kite's
  `main_local.dart` on an iPhone 17 simulator, captured the diagnostics
  `TagflowDocument` proof, and captured the real `IPOInstrumentSheet` rendering
  Tagflow-backed excerpt/content, local RHP JSON, mobile render-boundary
  content, financials, links, ordered lists, and table content.
- The Kite proof patch has been cleaned out of `/Users/arya/projects/kite`.
  The app checkout is clean again on `feat/dashboard...origin/feat/dashboard`
  and remains on hosted `tagflow: 0.0.8` / `tagflow_table: 0.0.4+5`. The next
  Kite alpha migration can now land as a separate dependency branch with only
  the hosted alpha constraint update, the two `legacy.dart` IPO converter
  imports, regenerated lockfile, and fresh focused app validation.
- The clean Kite alpha dependency branch now exists as
  `codex/kite-tagflow-alpha-runtime` at `d9682aec`. Its committed scope is
  exactly `pubspec.yaml`, `pubspec.lock`,
  `lib/screens/ipos/ipo_instrument_sheet.dart`, and
  `lib/component/tagflow_details_converter.dart`. The lockfile resolves hosted
  `tagflow` and `tagflow_table` to `1.0.0-alpha.1`; no
  `pubspec_overrides.yaml`, absolute path source, diagnostics preview, local
  fixture route, or broad dependency churn was committed.
- A follow-up clean-branch validation worker launched
  `lib/main_local.dart` from `d9682aec` on the iPhone 17 simulator and captured
  Home screenshots under
  `docs/validation/evidence/2026-06-11-kite-alpha-home-dark-launch.jpg` and
  `docs/validation/evidence/2026-06-11-kite-alpha-home-after-dark-toggle.jpg`.
  The branch passed dependency, focused analyzer, patch-scope, and no-override
  gates, but the clean app-local data path did not reach `IPOInstrumentSheet`:
  existing handlers returned multiple `500` responses, a watchlist
  deserialization exception appeared, and the simulator remained visually light
  after the dark-appearance toggle. This is evidence that the branch is clean
  and launchable, not IPO dark-mode or release-grade profile evidence.
- The next Kite alpha evidence path has been narrowed to the real authenticated
  app route rather than the local proof route: launch the normal app entrypoint
  on `codex/kite-tagflow-alpha-runtime`, use an existing authenticated session
  or dev-session import with
  `--dart-define=KITE_ENABLE_DEV_SESSION_TOOLS=true`, navigate Bids -> IPO,
  tap an IPO instrument, and capture the resulting real
  `IPOInstrumentSheet`. This uses the app's current
  `SelectIPOInstrument` / `SelectInvestorType` / `ShowIPOInstrumentSheet`
  flow. A local fallback, if auth blocks the run, should be a narrow
  uncommitted IPO-only handler set for `/ipo/instruments`,
  `/ipo/applications`, supported UPI handles, and the selected RHP JSON URL;
  it should not revive the diagnostics proof screen or broad `main_local.dart`
  fixture behavior.
- A real-route worker then ran the normal app entrypoint from the clean
  hosted-alpha dependency branch content at `d9682aec`, using detached worktree
  `/Users/arya/.codex/worktrees/2bc2/kite` because the branch was already
  checked out elsewhere. It reconfirmed hosted `1.0.0-alpha.1` lockfile
  resolution, no path overrides, `flutter pub get`, and focused analyzer
  success. The simulator had an authenticated session; Kite's own app theme was
  switched to Dark through Settings; Computer Use then reached Bids -> IPO and
  tapped an IPO row. The worker reported that the real `IPOInstrumentSheet` was
  reached for `UTKAL`, with logs showing `ShowIPOInstrumentSheet`,
  `IPOInstrumentSheet UTKAL`, and `GetIPOInfo` returning `200`, but no
  `docs/validation/evidence/2026-06-11-kite-alpha-ipo-real-*` screenshot
  artifacts were created before the bounded shutdown. This validates the route,
  not the final dark screenshot or profile evidence gate.
- A bounded follow-up worker repeated the same clean hosted-alpha authenticated
  route, captured the real dark-mode IPO sheet screenshots, and kept Kite clean:
  `docs/validation/evidence/2026-06-11-kite-alpha-ipo-real-route-context.jpg`,
  `docs/validation/evidence/2026-06-11-kite-alpha-ipo-real-excerpt.jpg`, and
  `docs/validation/evidence/2026-06-11-kite-alpha-ipo-real-content-table.jpg`.
  The coordinator visually checked these files; they show the live IPO list
  context, the top summary/excerpt area, and the lower company/financials/table
  area in Kite's in-app Dark theme. A bounded physical iPhone profile launch was
  attempted with:

  ```bash
  flutter run --profile -d 00008150-00110C960186401C --no-pub \
    --dart-define=KITE_ENABLE_DEV_SESSION_TOOLS=true
  ```

  That first run stayed pending until interrupted. No `flutter run` process
  remained afterward, and it was not counted as release-grade profile evidence.
- A focused profile-qualification worker then diagnosed that blocker more
  precisely and recorded
  `docs/validation/evidence/2026-06-11-kite-alpha-profile-blocker-summary.md`.
  The physical iPhone was only reachable as a wireless Flutter target, not as an
  actively USB-enumerated phone; Xcode listed the device under
  `Devices Offline`, and a verbose profile run stalled at the Xcode Profile
  build-settings step before credible install, app launch, VM/profile
  attachment, frame timing capture, or real-device `IPOInstrumentSheet`
  observation. This is a documented supported-target blocker, not release-grade
  profile evidence.
- `8ed0686` preserves HTML table captions across the adapter, built-in semantic
  renderer, first-party table extension, and legacy bridge. This closes a
  concrete table parity gap without removing the alpha compatibility bridge.
- A Kite debug VM timeline probe now attributes sheet-open work to
  `IPOInstrumentSheet`, `Tagflow`, `TagflowScope`, `TagflowThemeProvider`,
  `RenderTagflowTable`, `TagflowTable`, and `TableCell`. Because the simulator
  rejected Flutter profile mode and Xcode Animation Hitches was unsupported on
  this runtime, this is path-attribution evidence only, not release-grade
  performance evidence.
- The profile baseline runner can now preserve failed or unsupported target
  attempts in its manifest with per-cell logs when
  `TAGFLOW_PROFILE_CONTINUE_ON_FAILURE=true` or
  `--continue-on-failure=true` is used. This turns physical-device and CI
  target qualification failures into reviewable evidence instead of transient
  terminal output.
- `profile-baseline-summary.json` now carries `successfulRuns`,
  `runStatusCounts`, and `failedRuns`, so reviewed benchmark notes can reject a
  target or matrix from the summary artifact without manually mining the full
  manifest.
- `check_profile_baseline.dart` now provides a machine-readable profile
  collection gate for complete runs: no failed cells, `successfulRuns ==
  totalRuns`, at least one summarized cell, and a configurable minimum
  successful repeat count per renderer/fixture cell. It deliberately does not
  enforce frame-time thresholds before a reviewed reference baseline exists.
- Melos now exposes the baseline handoff as `benchmark:profile:summarize` and
  `benchmark:profile:check`, driven by `TAGFLOW_PROFILE_RUN_ID` and
  `TAGFLOW_PROFILE_MIN_REPEATS`, so reference-runner collection, summary, and
  completeness gating can be run from the workspace command surface.
- The macOS default profile matrix now has one complete repeat-5 reviewed run:
  `2026-06-11T08-14-32-397331Z` at commit `ae5fd01`, covering
  `tagflow`, `flutter_html`, and `flutter_widget_from_html` across
  `ai_answer_rich`, `table_dense`, `large_article`, and `table_stress`.
  All `60 / 60` profile runs passed, and
  `TAGFLOW_PROFILE_MIN_REPEATS=5 dart run melos run benchmark:profile:check`
  passed with no issues. This is alpha-grade internal stabilization evidence,
  not external benchmark copy.
- Future profile-baseline manifests now detect Flutter version/channel via
  `flutter --version --machine` when `FLUTTER_VERSION` is not set. A one-cell
  smoke run, `2026-06-11T08-39-14-109697Z`, recorded
  `flutterVersion: 3.45.0-0.1.pre (master)` automatically.
- Future profile artifacts and summaries now include Flutter viewport metadata.
  A one-cell smoke run, `viewport-smoke`, recorded
  `800.0 x 600.0` logical, `1600.0 x 1200.0` physical, and
  `devicePixelRatio=2.0` through the collect, summarize, and check handoff.
- `34ea827` adds an opt-in environment gate for profile baseline checks:
  `TAGFLOW_PROFILE_EXPECT_LOGICAL_WIDTH`,
  `TAGFLOW_PROFILE_EXPECT_LOGICAL_HEIGHT`, and
  `TAGFLOW_PROFILE_EXPECT_DEVICE_PIXEL_RATIO` can now require summarized
  viewport metadata to match a selected reference window. If these values are
  unset, viewport metadata remains report-only for alpha baseline handoff.

## Known Non-Completion Points

- Custom legacy converters passed to HTML entry points still intentionally use
  the compatibility legacy bridge after `TagflowHtmlAdapter` parsing, so apps
  with converter extensions keep their existing behavior while built-in HTML
  uses the semantic runtime.
- The first-party table extension has a semantic registry fragment, and caption
  preservation now works across semantic and compatibility paths. The legacy
  HTML converter bridge has not been fully removed or replaced. Remaining gaps
  are now mostly richer table-border fidelity beyond the normalized
  uniform/attribute-driven path, broader HTML table presentation coverage, and
  full package-wide proof that the legacy table bridge can be removed.
- Profile benchmarking is real but not production-grade yet: the macOS desktop
  default matrix now has a complete repeat-5 reviewed run, but stable
  performance claims still need an intentionally selected stable reference
  machine, a documented command that pins the desktop window before collection,
  broader target qualification, and threshold policy before using frame timings
  as a release gate. Future raw artifacts can now report the Flutter viewport
  size and device-pixel ratio, and the check command can enforce expected
  viewport values when explicitly configured, but the runner still does not set
  the desktop window or identify the physical display by itself.
- Stable `1.0.0` still needs deeper internal-app validation before release:
  physical-device or supported-target profile evidence on the real IPO surface,
  and a repeatable operating path for the clean Kite alpha-dependency branch
  that does not depend on proof-only diagnostics scaffolding.
  The first iOS simulator proof, real dark-mode screenshots, and debug timeline
  have been captured, but they should not be treated as a full production
  rollout or release-grade benchmark.
