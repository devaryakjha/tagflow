# Tagflow v1 Alpha Acceptance Status

This tracker records the coordination state for the `1.0.0-alpha.1` native
rich content runtime line.

Snapshot:

- Branch: `codex/tagflow-native-runtime-master`
- Latest validated coordinator commit: `ed6f04f docs(validation): record kite
  proof cleanup`
- Latest validated implementation commits: `8ed0686 fix(table): preserve HTML
  table captions`, `2b2a809 bench(profile): add baseline summary gate`
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
`docs/benchmarks/baselines/2026-06-11-macos-reference-profile-baseline-capped.md`.
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

## Current Integration Queue

1. Release review can decide whether to push the package-specific alpha tags:
   `tagflow-v1.0.0-alpha.1` and `tagflow_table-v1.0.0-alpha.1`.
2. After tags are pushed, watch the package-specific GitHub Actions publish
   workflows and verify both packages appear on pub.dev.

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
  and remains on hosted `tagflow: 0.0.8` / `tagflow_table: 0.0.4+5`. A future
  Kite alpha migration should land as a separate dependency branch with only
  the hosted alpha constraint update, the two `legacy.dart` IPO converter
  imports, regenerated lockfile, and fresh focused app validation.
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
- Profile benchmarking is real but not production-grade yet: broader competitor
  coverage beyond the current HTML-native lanes, a committed reviewed baseline
  from a named reference machine, and repeated reference-device runs remain
  follow-up work before using frame timings as a release gate.
- Stable `1.0.0` still needs deeper internal-app validation before release:
  dark-mode screenshots, physical-device or supported-target profile evidence
  on the real app surface, and a deliberate Kite alpha-dependency migration
  branch if Kite is the first production consumer.
  The first iOS simulator proof and debug timeline have been captured but
  should not be treated as a full production rollout or benchmark.
