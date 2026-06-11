# App Launch Attribution Scope

## Status

- Date: 2026-06-12
- Scope: profile baseline app/process launch attribution
- Posture: macOS local-runner markers implemented; evidence remains report-only
  and must not be generalized across platforms

## Verdict

The current Flutter drive/profile runner still cannot honestly claim generic
app or process cold-start duration.

Current profile artifacts can summarize:

- `coldInitialRender`: first benchmark fixture render inside the already running
  integration-test process
- `warmRebuild`: second render of the same fixture in the same process
- `warmScroll`: scroll interaction after fixture render
- `launchAttribution`: explicit native macOS local-runner markers when the
  example host provides them

The new launch payload is deliberately narrower than a cross-platform cold-start
metric. It records app-delegate and Flutter-window milestones from the macOS
example host only, and the summary/check layer marks missing or unsupported
launch attribution explicitly.

## Current Artifact Audit

`benchmark:profile` runs `flutter drive --profile` against
`examples/tagflow/integration_test/tagflow_perf_test.dart`.

The integration test creates each static phase with
`IntegrationTestWidgetsFlutterBinding.watchPerformance()` after the test has
started:

- initial render wraps `tester.pumpWidget()` and `pumpAndSettle()`
- warm rebuild wraps a second `tester.pumpWidget()` and `pumpAndSettle()`
- warm scroll wraps `tester.fling()` and `pumpAndSettle()`

The persisted `examples/tagflow/build/integration_response_data.json` payload
still contains Flutter frame summaries for test-controlled phases only.

It now also writes a dedicated `launch_attribution` payload per renderer/fixture
cell:

- macOS: local-runner-only native uptime markers beginning at `AppDelegate`
  init and continuing through Flutter view-controller readiness and the first
  integration-test launch-marker request handled on the native side
- other targets or missing bridges: explicit `status: unavailable` with a
  reason such as `platform_not_supported` or
  `missing_launch_attribution_payload`

`ProfileBaselineRunner` also records `startedAt` and `finishedAt` around the
child process command:

```text
dart run melos run benchmark:profile
```

That elapsed time includes Melos process startup, `flutter drive` orchestration,
build/install/launch work, test execution, artifact writing, and local file
copying. It is useful for diagnosing harness failures, but it is not a
defensible app-launch metric.

The summary model now preserves that boundary explicitly:

- `framePhaseSummaries.coldInitialRender`, `warmRebuild`, and `warmScroll`
  remain unchanged and are not reinterpreted as launch time
- `launchAttribution.status` is `available`, `partial`, or `unavailable`
- `benchmark:profile:check` emits report-only findings when launch attribution
  is missing or partial

## Remaining Limits

This slice still does not justify cross-platform or public cold-start claims.

It does not measure:

- process exec before `AppDelegate` initialization
- first Flutter frame from a native launch origin
- iOS or Android launch timing
- any thresholded regression gate

## Required Runner Change

A truthful app-launch slice needs explicit launch instrumentation before the
integration test starts measuring fixture phases.

Minimum viable design:

1. Add native host launch markers for supported targets.
   - macOS: record at app delegate entry and at main Flutter window/controller
     setup.
   - iOS: record at `application(_:didFinishLaunchingWithOptions:)` and when
     the Flutter view/controller is ready.
   - Android: record at activity `onCreate` and when the Flutter engine/view is
     ready.
2. Bridge those markers into the Dart/integration-test report payload with a
   stable schema such as `launchAttribution`.
3. Summarize only named intervals with clear provenance, for example
   `appDelegateInitToFlutterViewControllerReady`.
4. Keep all values report-only until physical-device and stable-runner evidence
   is reviewed.

The summary parser should accept the launch payload only when its provenance is
explicit. Missing launch payloads should not be inferred from old artifacts.

## Validation Plan

For the first implementation slice:

- macOS one-cell smoke:
  `TAGFLOW_PROFILE_PAIR=tagflow:ai_answer_rich`
- summary JSON contains explicit `launchAttribution` status for every cell
- existing `framePhaseSummaries.coldInitialRender`, `warmRebuild`, and
  `warmScroll` remain unchanged
- no timing thresholds, ranking copy, or public performance claims are added
- `benchmark:profile:check` remains a collection-quality gate only

Before any cold-start claim:

- repeat on a stable macOS reference target
- run at least one physical iOS probe and one physical Android probe with
  `TAGFLOW_PROFILE_CONTINUE_ON_FAILURE=true`
- review launch-marker availability and failure classes per target
- document fixture id, renderer id, device id, Flutter/Dart version, OS,
  viewport, power/thermal notes, and run id
