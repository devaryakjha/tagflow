# Alpha.4 / Pre-Beta Coordination

## Status

- Date: 2026-06-12 Asia/Kolkata
- Branch: `codex/tagflow-native-runtime-master`
- Draft review PR: https://github.com/devaryakjha/tagflow/pull/72
- Recorded CI-validated PR anchor: `01149ac`
- Point-in-time live-state refresh:
  `docs/plans/2026-06-13-pr72-live-state-refresh.md`
- Gate manifest: `docs/plans/native-runtime-gate-status.json`
- Posture: planning and coordination only; no publish, tag, version bump,
  beta/stable wording, package-page claim, public benchmark claim, or PR
  undraft authorization

## Purpose

Keep alpha.4 and pre-beta work aligned while the remaining beta-preapproval
gates require owner decisions or external target changes.

This note is an index and cutline for coordinator work. It is not release
evidence, and it does not satisfy any gate by itself.

## Current Gate State

Current gate truth is in `docs/plans/native-runtime-gate-status.json`.

```text
pr72-draft:
  result=passed

beta-preapproval:
  result=passed

beta-candidate:
  result=failed as expected
  blockers=[
    release-approval
  ]
```

Current owner-review packet:

- `docs/plans/2026-06-12-beta-preapproval-packet-draft.md`

That packet is not gate evidence until the owner decisions it names are
recorded.

A point-in-time PR/tracker state is summarized in
`docs/plans/2026-06-13-pr72-live-state-refresh.md`. That note records a
captured PR #72 draft/open state before the reference-app-route pivot. Use live
PR checks, not the captured commit in that note, for the current branch head.

## Alpha.4 / Pre-Beta Scope

Alpha.4 or pre-beta work should stay focused on:

- coordinating owner decisions for release approval;
- preserving a clear difference between alpha stabilization evidence and
  beta/stable release evidence;
- preserving the public reference-app route as the #73 reviewable Flutter route;
- preserving the iPhone 17 physical profile evidence boundaries;
- maintaining docs and tests that keep the current native-runtime API shape
  auditable.

Do not add broad runtime or public API scope unless it directly resolves a
documented beta-shape blocker in the public API freeze review, native runtime
SPECs, or gate manifest.

The native JSON example and current reference path should stay as-is unless
new real-app evidence shows a contract gap. The node-tap semantics follow-up
now has a focused package slice: opted-in non-link tap targets expose
button-like semantics while preserving child labels, and semantics-action
activation is covered for document and HTML-adapted targets through the
view-owned callback model. The example app also covers app-authored native
block activation through that same view-owned model.

## Open Decisions

### Reference App Route

The `real-app-route` gate is satisfied by a public package-owned route.

Current evidence:

- `docs/plans/2026-06-12-real-app-route-qualification.md`
- `docs/validation/evidence/2026-06-13-reference-app-route.md`
- `examples/tagflow/lib/screens/reference_app_route_screen.dart`
- `examples/tagflow/test/reference_app_route_test.dart`

The owner clarified that proprietary downstream app changes should not be the
public Tagflow gate artifact. Keep #73 tied to the package-owned example route
unless the owner explicitly approves a different sanitized public route.

### Physical/Observed Profile

The `physical-observed-profile` gate is satisfied.

Owner decision request:

- Tracker: https://github.com/devaryakjha/tagflow/issues/75
- `docs/benchmarks/baselines/2026-06-12-physical-observed-profile-owner-decision-request.md`

Current physical evidence:

- `docs/benchmarks/baselines/2026-06-13-iphone17-time-profiler-repeat5.md`

The historical target-audit refresh reported
`canRunPhysicalProfileProbe=false` for
`2026-06-13-current-machine-r1`: one iOS Simulator signal, two wireless iOS
signals, no connected physical iOS target in Flutter, no xctrace-online
physical iOS target, seven xctrace-offline physical iOS targets, two
CoreDevice available-paired summary signals, seven CoreDevice blocking ids,
and no attached Android device.

A later explicit wired-device check found the iPhone 17
`00008150-00110C960186401C` as USB/wired and available in Flutter/CoreDevice,
while `xctrace` still listed the same UDID offline. A direct profile build
selected that device, then failed before installation because this Mac lacks an
Xcode account/provisioning profile for team `7573STCA2W` and bundle id
`dev.aryak.tagflow`.

The owner then disabled iPhone Mirroring, installed Xcode-beta, and fixed the
example-app signing team. With Xcode-beta selected, Flutter, CoreDevice, and
`xctrace` all saw the wired iPhone 17. The example app also needed the current
Flutter UIScene host migration and iOS deployment target `15.0` for Xcode 27.
After those fixes, repeat-5 Time Profiler traces were collected through
Instruments on the physical device.

## Allowed Next Actions

- Prepare owner-review wording and packet updates without expanding public
  benchmark claims.
- Rerun `benchmark:profile:target-audit` only when target state changes.
- Keep the current physical profile evidence tied to local collection only; do
  not convert it into frame-budget, memory, comparative, beta/stable, package,
  or public performance claims.
- Refresh docs when PR #72 head, CI, gate output, or owner decisions change.
- Use `gate:native-runtime` with `TAGFLOW_NATIVE_RUNTIME_GATE_PROFILE=beta-preapproval`
  for the current beta-preapproval check.
- Keep `tagflow_example` inside the root `melos run test` coverage lane because
  it hosts the routed native JSON example and benchmark-control widgets.
- Keep raw benchmark artifacts under ignored `build/benchmarks/`.

## Non-Goals

- No package version changes.
- No release notes or changelog promotion.
- No README or package-page claim changes.
- No publishing.
- No tags.
- No beta/stable wording.
- No public faster/slower, lower-memory, leak-free, frame-budget, ranking, or
  comparative performance claims.
- No PR #72 undraft or merge authorization.
- No removal of required beta-preapproval gates.

## Validation

For docs-only alpha.4/pre-beta coordination changes, run:

```bash
git diff --check
PATH=/Users/arya/fvm/cache.git/bin:$PATH dart run melos run gate:native-runtime
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_NATIVE_RUNTIME_GATE_PROFILE=beta-preapproval \
  dart run melos run gate:native-runtime
jq empty docs/plans/native-runtime-gate-status.json
```

Expected result:

- `git diff --check` passes;
- `pr72-draft` gate passes;
- `beta-preapproval` gate passes;
- the gate manifest remains valid JSON.

Optionally run the beta-candidate profile when release posture changes:

```bash
TAGFLOW_NATIVE_RUNTIME_GATE_PROFILE=beta-candidate \
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
  dart run melos run gate:native-runtime
```

Until owner approval exists, it should continue to fail on
`release-approval` in addition to any unresolved preapproval blockers.

## Stop Rules

Do not add this note to `native-runtime-gate-status.json` as gate evidence.

Do not replace the public reference-app route with proprietary downstream app
evidence unless the owner explicitly approves a sanitized public artifact.

Do not mark `physical-observed-profile` satisfied from local stabilization
evidence, Simulator smoke, or an observed host that fails the native JSON
observed-host policy.

Do not weaken `docs/benchmarks/policies/profile-reference-runner-policy.json`
or `docs/benchmarks/policies/profile-native-json-observed-policy.json` to match
this machine without an owner-approved target decision and fresh repeat-5
evidence.

Do not remove `physical-observed-profile` from the `beta-preapproval` profile
to make the gate pass.

Do not publish, tag, bump versions, undraft PR #72, or add beta/stable package
copy from this coordination note.
