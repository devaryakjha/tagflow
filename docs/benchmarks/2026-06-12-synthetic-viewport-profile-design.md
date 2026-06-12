# Synthetic Viewport Profile Design

## Status

- Date: 2026-06-12 Asia/Kolkata
- Scope: Tagflow example-app profile benchmark harness
- Classification: design candidate for review
- Related gate: #74 qualified native runtime benchmark evidence
- Current posture: not implemented; no benchmark evidence is promoted by this
  document

## Purpose

The current profile reference policy can qualify a real observed viewport such
as `800x600 @ 2.0x`. On the current local display, the one-repeat probe at
`1c20746` observed `800x600 @ 1.0x`, so the policy correctly stopped the
repeat-5 macOS matrix.

Issue #74 allows an alternate path: a reviewed synthetic viewport design that
records requested and observed metadata separately. This document defines that
design before any implementation so a DPR override cannot silently change the
meaning of existing artifacts.

## Design Principles

1. Synthetic viewport mode is opt-in.
2. Host-observed viewport metadata stays visible.
3. Requested synthetic viewport metadata is recorded separately.
4. Checker policy must distinguish observed-host and synthetic modes.
5. Synthetic mode can prove harness stability only. It cannot prove a real
   hardware/display reference target.
6. Timing and memory values remain report-only unless a later threshold policy
   explicitly qualifies the exact synthetic mode.

## Terminology

- Observed host viewport: the view metadata Flutter reports before any test
  override is applied. This represents the live target environment.
- Requested synthetic viewport: the logical size and DPR requested by the
  benchmark run through explicit env or CLI configuration.
- Applied synthetic viewport: the view metadata Flutter reports after the
  benchmark harness applies the requested override and before measurement.
- Effective benchmark viewport: the viewport used for the measured render and
  scroll phases. In synthetic mode this should equal the applied synthetic
  viewport.

## Proposed Artifact Shape

The existing profile artifacts store one viewport payload under:

```text
<renderer>_<fixture>_viewport
```

Keep that key as the effective benchmark viewport for compatibility, then add a
new metadata key:

```text
<renderer>_<fixture>_viewport_mode
```

Suggested JSON shape:

```json
{
  "schemaVersion": 1,
  "mode": "synthetic",
  "requested": {
    "logicalWidth": 800.0,
    "logicalHeight": 600.0,
    "devicePixelRatio": 2.0
  },
  "observedHostBeforeOverride": {
    "logicalWidth": 800.0,
    "logicalHeight": 600.0,
    "physicalWidth": 800.0,
    "physicalHeight": 600.0,
    "devicePixelRatio": 1.0
  },
  "applied": {
    "logicalWidth": 800.0,
    "logicalHeight": 600.0,
    "physicalWidth": 1600.0,
    "physicalHeight": 1200.0,
    "devicePixelRatio": 2.0
  },
  "caveats": [
    "test_view_override",
    "not_real_display_scale",
    "not_public_reference_target"
  ]
}
```

For default observed-host mode:

```json
{
  "schemaVersion": 1,
  "mode": "observedHost",
  "requested": null,
  "observedHostBeforeOverride": {
    "logicalWidth": 800.0,
    "logicalHeight": 600.0,
    "physicalWidth": 800.0,
    "physicalHeight": 600.0,
    "devicePixelRatio": 1.0
  },
  "applied": null,
  "caveats": []
}
```

## Proposed Configuration

Use explicit profile-only inputs:

```text
TAGFLOW_PROFILE_VIEWPORT_MODE=observed_host|synthetic
TAGFLOW_PROFILE_SYNTHETIC_LOGICAL_SIZE=800x600
TAGFLOW_PROFILE_SYNTHETIC_DEVICE_PIXEL_RATIO=2.0
```

Default:

```text
TAGFLOW_PROFILE_VIEWPORT_MODE=observed_host
```

Validation rules:

- `observed_host` rejects synthetic size and DPR inputs.
- `synthetic` requires both logical size and DPR.
- Logical width, logical height, and DPR must be greater than zero.
- The harness records host metadata before applying any synthetic override.
- The measured viewport must match the requested synthetic viewport.

## Proposed Implementation Slices

### Slice 1: Artifact Metadata Only

Files:

- `examples/tagflow/integration_test/tagflow_perf_test.dart`
- `packages/tagflow_benchmarks/lib/src/profile/profile_baseline_summary.dart`
- focused summary tests

Behavior:

- Record `viewport_mode` metadata in observed-host mode.
- Keep the existing `viewport` payload unchanged.
- No synthetic override yet.

Acceptance:

- Existing profile summary tests pass.
- New test proves `viewport_mode.mode == observedHost`.
- No benchmark command behavior changes.

### Slice 2: Synthetic Override Plumbing

Files:

- `examples/tagflow/integration_test/tagflow_perf_test.dart`
- `packages/tagflow_benchmarks/lib/src/profile/profile_baseline_cli_options.dart`
- `packages/tagflow_benchmarks/lib/src/profile/profile_baseline_runner.dart`
- focused CLI/runner tests

Behavior:

- Parse the three env variables.
- Pass synthetic viewport inputs into `flutter drive` as `--dart-define`
  values.
- In the integration test, capture host metadata first, apply the requested
  synthetic `TestFlutterView` logical size and DPR, then capture applied
  metadata before measurements.
- Persist requested, observed-host, applied, and caveats.

Acceptance:

- CLI rejects partial synthetic configuration.
- Runner passes synthetic defines only in synthetic mode.
- Widget/integration test helpers prove requested/applied metadata is recorded.
- Existing observed-host behavior stays unchanged.

### Slice 3: Checker Policy Mode

Files:

- `docs/benchmarks/policies/profile-reference-runner-policy.json`
- optionally a second synthetic policy JSON
- `packages/tagflow_benchmarks/lib/src/profile/profile_baseline_check.dart`
- focused checker tests

Behavior:

- Add policy-level viewport mode handling.
- `observedHost` policy checks existing `cellSummaries[].viewports` and
  rejects any cell whose viewport-mode metadata says `mode=synthetic`.
- `synthetic` policy checks both:
  - requested synthetic viewport matches policy
  - applied synthetic viewport matches policy
- Synthetic policy must report a finding such as
  `synthetic_viewport_not_reference_target`.

Acceptance:

- Observed-host policy keeps current behavior.
- Observed-host policy fails if synthetic viewport-mode metadata is present.
- Synthetic policy fails if requested metadata is missing.
- Synthetic policy fails if applied metadata differs from requested metadata.
- Synthetic policy fails if host metadata is absent.
- Synthetic policy passes collection quality when repeat count, failed runs,
  requested metadata, applied metadata, and host metadata are complete.

### Slice 4: One-Repeat Synthetic Probe

Commands:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_DEVICE=macos \
TAGFLOW_RENDERER=tagflow \
TAGFLOW_FIXTURE=ai_answer_rich \
TAGFLOW_PROFILE_VIEWPORT_MODE=synthetic \
TAGFLOW_PROFILE_SYNTHETIC_LOGICAL_SIZE=800x600 \
TAGFLOW_PROFILE_SYNTHETIC_DEVICE_PIXEL_RATIO=2.0 \
TAGFLOW_PROFILE_REPEAT=1 \
TAGFLOW_PROFILE_CONTINUE_ON_FAILURE=true \
TAGFLOW_PROFILE_RUN_ID=<probe-run-id> \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-synthetic-probe \
dart run melos run benchmark:profile:baselines
```

Then summarize and check with the reviewed synthetic policy and minimum repeat
count `1`.

Acceptance:

- One selected cell emits a manifest, summary, raw repeat artifact, and log.
- The synthetic policy passes with `minRepeats=1`.
- Observed-host policy fails or refuses the same run because it is synthetic.
- The tracked note records this as synthetic harness smoke only.

### Slice 5: Repeat-5 Synthetic Collection

Commands:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_DEVICE=macos \
TAGFLOW_PROFILE_VIEWPORT_MODE=synthetic \
TAGFLOW_PROFILE_SYNTHETIC_LOGICAL_SIZE=800x600 \
TAGFLOW_PROFILE_SYNTHETIC_DEVICE_PIXEL_RATIO=2.0 \
TAGFLOW_PROFILE_REPEAT=5 \
TAGFLOW_PROFILE_RUN_ID=<run-id> \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-synthetic \
dart run melos run benchmark:profile:baselines
```

Then summarize and check with the reviewed synthetic policy.

Acceptance:

- Raw artifacts stay under ignored `build/benchmarks/`.
- `profile-baseline-summary.json` records both host and synthetic metadata.
- Checker passes only the synthetic collection policy.
- Repeat-5 collection starts only after the one-repeat synthetic probe passes.
- Tracked note states this is synthetic harness evidence, not observed-host or
  public reference-target evidence.

## Policy Wording

Allowed after implementation and collection:

- "The profile harness can collect repeat-5 synthetic viewport evidence for
  internal alpha stabilization."
- "Synthetic viewport artifacts record requested, applied, and host-observed
  viewport metadata separately."

Blocked:

- "The local Mac is a qualified `2.0x` reference target."
- "Synthetic viewport evidence proves real display-scale performance."
- "Synthetic results are public benchmark results."
- "Synthetic results qualify beta or stable performance claims."
- "Synthetic results can be compared with historical observed-host runs without
  separate policy."

## Open Review Questions

1. Should synthetic mode be allowed for the default HTML renderer matrix only,
   or for native JSON and dynamic patch lanes too?
2. Should the synthetic policy live beside the current observed-host policy as
   a separate JSON file to avoid accidental policy mixing?
3. Should the profile summary surface `viewportModes` as a first-class field on
   each cell summary, or should the checker read raw artifact metadata directly?
4. Should synthetic mode be barred from memory/allocation lanes until retained
   path and heap evidence semantics are reviewed?
5. Should synthetic mode require a stable Flutter channel before it can be used
   as release-candidate collection evidence?

## Recommendation

Implement slices 1 through 3 before collecting any synthetic run. Then run the
one-repeat synthetic probe in slice 4 before attempting the repeat-5 matrix in
slice 5. Until then, #74 remains open and the current macOS `1.0x` display
should continue to stop at the observed-host one-repeat probe.
