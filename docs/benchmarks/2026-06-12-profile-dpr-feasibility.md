# 2026-06-12 Profile DPR Feasibility Audit

This note answers a narrow question for the macOS profile harness: can the
current Tagflow benchmark path explicitly pin device-pixel-ratio, or can it
only qualify the live host display environment?

## Status

- Date: 2026-06-12
- Scope: `examples/tagflow` profile benchmark harness on macOS
- Classification: requires broader benchmark harness design
- Immediate posture: keep DPR as observed-and-qualified metadata for reference
  runs; do not add a silent DPR override

## Current Harness Evidence

- [`examples/tagflow/macos/Runner/Base.lproj/MainMenu.xib`](../../examples/tagflow/macos/Runner/Base.lproj/MainMenu.xib)
  creates the benchmark window at `800 x 600`.
- [`examples/tagflow/macos/Runner/MainFlutterWindow.swift`](../../examples/tagflow/macos/Runner/MainFlutterWindow.swift)
  preserves that frame and does not set display scale or DPR.
- [`examples/tagflow/integration_test/tagflow_perf_test.dart`](../../examples/tagflow/integration_test/tagflow_perf_test.dart)
  records `tester.view.physicalSize` and `tester.view.devicePixelRatio` into
  report data before benchmark capture. It does not call
  `tester.view.devicePixelRatio = ...`, `tester.view.physicalSize = ...`, or
  `binding.setSurfaceSize(...)`.
- [`packages/tagflow_benchmarks/lib/src/profile/profile_baseline_runner.dart`](../../packages/tagflow_benchmarks/lib/src/profile/profile_baseline_runner.dart)
  and
  [`packages/tagflow_benchmarks/lib/src/profile/profile_baseline_cli_options.dart`](../../packages/tagflow_benchmarks/lib/src/profile/profile_baseline_cli_options.dart)
  only plumb renderer, fixture, device, profile-memory, and hold-open options.
  There is no existing DPR or viewport override input.
- [`packages/tagflow_benchmarks/lib/src/profile/profile_baseline_check.dart`](../../packages/tagflow_benchmarks/lib/src/profile/profile_baseline_check.dart)
  can qualify a run against expected viewport metadata, including DPR, but it
  only checks what was recorded.

## Flutter SDK Evidence

Local SDK used for this audit:

- Flutter `3.45.0-0.1.pre`
- Channel `master`
- Framework revision `6af38a904a3ff944cd35b0ebacf4d95b8f42391e`

In this SDK:

- `IntegrationTestWidgetsFlutterBinding` extends
  `LiveTestWidgetsFlutterBinding` and overrides `setSurfaceSize(...)`.
- `setSurfaceSize(...)` changes the logical test surface size used for the
  render view configuration. It does not itself provide a separate DPR control.
- `TestFlutterView.devicePixelRatio` and `TestFlutterView.physicalSize` are
  mutable in test code, but Flutter documents them as test-only emulation of
  view configuration rather than a framework-level mutation of the real host
  display.

That means the current Flutter APIs are not blocked. A test can emulate a
different view DPR or physical size before capture. The problem is benchmark
semantics, not API absence.

## Why This Is Not A Tiny Safe Fix

Adding a new env var and wiring:

- `tester.view.devicePixelRatio = requestedDpr`
- `tester.view.physicalSize = Size(logicalWidth * requestedDpr, ...)`

would be mechanically small, but it would change the meaning of the current
profile artifacts:

- today the harness records observed host viewport metadata;
- after such a patch the harness would record test-emulated viewport metadata;
- the macOS window and host display scale would still need separate reviewer
  treatment if the policy is supposed to qualify a real reference target.

That is too much semantic change for a tiny unreviewed benchmark fix. It would
need an explicit harness mode and policy language such as:

- observed host viewport qualification, or
- synthetic test viewport mode with separate requested and observed metadata.

## Recommended Next Action

Short term:

- Keep `docs/benchmarks/policies/profile-reference-runner-policy.json` as a
  qualification guard on observed viewport metadata.
- Refresh repeat runs only on a reviewed macOS target that is known to produce
  the expected DPR, or revise the policy after review.

If explicit DPR pinning is still wanted later:

- design a separate harness mode that records both requested test overrides and
  observed host viewport metadata. The proposed design is now tracked in
  [`2026-06-12-synthetic-viewport-profile-design.md`](2026-06-12-synthetic-viewport-profile-design.md);
- decide whether reference-runner policy is meant to qualify a real display
  target or an emulated test viewport;
- only then add CLI/env plumbing for DPR and physical/logical size.

## Coordinator Guidance

- Recommended coordinator action: treat the current macOS path as
  qualification-only for DPR and display scale.
- Should a profile rerun wait: yes. A rerun on the same local `1.0x` display is
  not expected to satisfy the current `2.0x` reference-runner policy.
