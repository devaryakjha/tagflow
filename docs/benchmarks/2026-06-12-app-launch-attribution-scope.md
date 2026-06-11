# App Launch Attribution Scope

## Status

- Date: 2026-06-12
- Scope: profile baseline app/process launch attribution
- Posture: blocked for timing summary implementation; current evidence remains
  report-only and in-process

## Verdict

The current Flutter drive/profile runner cannot honestly capture app or process
cold-start duration.

Current profile artifacts can summarize:

- `coldInitialRender`: first benchmark fixture render inside the already running
  integration-test process
- `warmRebuild`: second render of the same fixture in the same process
- `warmScroll`: scroll interaction after fixture render

They do not measure process start, native app launch, Flutter engine startup,
plugin registration, first Dart isolate entry, or time to first Flutter frame
from a native launch origin.

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
therefore contains Flutter frame summaries for test-controlled phases only.

`ProfileBaselineRunner` also records `startedAt` and `finishedAt` around the
child process command:

```text
dart run melos run benchmark:profile
```

That elapsed time includes Melos process startup, `flutter drive` orchestration,
build/install/launch work, test execution, artifact writing, and local file
copying. It is useful for diagnosing harness failures, but it is not a
defensible app-launch metric.

The macOS example host currently has stock Flutter app/window setup and no
native timestamp bridge. There is no committed native marker for application
entry, window creation, engine attachment, first Flutter frame, or first test
callback.

## Blocker

Adding a parser/model summary today would require naming one of these existing
values as launch time:

- profile runner wall-clock process duration
- `flutter drive` log text
- `coldInitialRender`

None of those values isolates app/process cold start. Reporting any of them as
`appLaunch`, `coldStart`, or equivalent would overstate the evidence.

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
3. Record Dart-side markers for integration-test start and the first
   post-launch Flutter frame observed by the test harness.
4. Summarize only named intervals with clear provenance, for example
   `nativeEntryToFlutterViewReady`, `nativeEntryToFirstFlutterFrame`, and
   `testStartToFirstFixtureRender`.
5. Keep all values report-only until physical-device and stable-runner evidence
   is reviewed.

The summary parser should accept the launch payload only when its provenance is
explicit. Missing launch payloads should not be inferred from old artifacts.

## Validation Plan

For the first implementation slice:

- macOS one-cell smoke:
  `TAGFLOW_PROFILE_PAIR=tagflow:ai_answer_rich`
- summary JSON contains `launchAttribution` only for artifacts with native
  launch markers
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
