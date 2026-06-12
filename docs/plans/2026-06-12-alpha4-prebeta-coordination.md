# Alpha.4 / Pre-Beta Coordination

## Status

- Date: 2026-06-12 Asia/Kolkata
- Branch: `codex/tagflow-native-runtime-master`
- Draft review PR: https://github.com/devaryakjha/tagflow/pull/72
- Current reviewed PR head: `f044844`
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
  result=failed as expected
  expectationPassed=true through gate:native-runtime:beta-preapproval-known-open
  blockers=[
    real-app-route,
    physical-observed-profile
  ]

beta-candidate:
  result=failed as expected
  blockers=[
    real-app-route,
    physical-observed-profile,
    release-approval
  ]
```

Current owner-review packet:

- `docs/plans/2026-06-12-beta-preapproval-packet-draft.md`

That packet is not gate evidence until the owner decisions it names are
recorded.

## Alpha.4 / Pre-Beta Scope

Alpha.4 or pre-beta work should stay focused on:

- coordinating owner decisions for the remaining beta-preapproval blockers;
- preserving a clear difference between alpha stabilization evidence and
  beta/stable release evidence;
- unblocking real-app route review through Kite or an approved equivalent real
  Flutter app route;
- unblocking physical or qualified observed-host profile evidence when target
  state changes;
- maintaining docs and tests that keep the current native-runtime API shape
  auditable.

Do not add broad runtime or public API scope unless it directly resolves a
documented beta-shape blocker in the public API freeze review, native runtime
SPECs, or gate manifest.

The native JSON example and current reference path should stay as-is unless
new real-app evidence shows a contract gap. The node-tap semantics follow-up
now has a focused package slice: opted-in non-link tap targets expose
button-like semantics while preserving child labels and the view-owned callback
model.

## Open Decisions

### Real-App Route

The `real-app-route` gate remains open.

Owner decision request:

- `docs/validation/evidence/2026-06-12-kite-non-gitlab-owner-acceptance-request.md`

Acceptable close paths:

- the owner accepts the Kite non-GitLab review packet as the #73 source-review
  artifact for the `IPOInstrumentSheet` route;
- Kite GitLab/source-control access returns and the route is pushed or
  otherwise reviewed through the intended app path;
- the owner approves a different qualifying real Flutter app route.

Until one of those decisions is recorded, keep #73 open and keep
`real-app-route.status=open`.

### Physical/Observed Profile

The `physical-observed-profile` gate remains open.

Owner decision request:

- Tracker: https://github.com/devaryakjha/tagflow/issues/75
- `docs/benchmarks/baselines/2026-06-12-physical-observed-profile-owner-decision-request.md`

Acceptable pre-beta paths:

- collect fresh repeat-5 evidence on a credible physical iOS or Android target
  that passes target audit and profile collection;
- collect fresh repeat-5 evidence on an owner-approved observed-host target
  that passes the native JSON observed-host policy;
- record an explicit beta-preapproval-only waiver while keeping public
  benchmark, frame-budget, memory, comparative, stable, publishing, and package
  claim boundaries blocked.

The current observed-host repeat-5 run is local stabilization evidence only:
it passed repeat completeness but reported `800x600 @ 1.0x`, while the current
native JSON observed-host policy expects `800x600 @ 2.0x`.

The latest target-audit refresh after CoreDevice summary parsing hardening
still reports `canRunPhysicalProfileProbe=false` for
`2026-06-12-current-machine-r4`: one iOS Simulator signal, two wireless iOS
signals, no connected physical iOS target in Flutter, no xctrace-online
physical iOS target, seven xctrace-offline physical iOS targets, two
CoreDevice available-paired summary signals, seven CoreDevice blocking ids, and
no attached Android device.

## Allowed Next Actions

- Prepare owner-review wording and packet updates without marking gates
  satisfied.
- Rerun `benchmark:profile:target-audit` only when target state changes.
- Qualify one physical iOS/Android target, or an approved observed host, before
  collecting any new repeat-5 physical/observed-host profile baseline.
- If a credible target appears, run a bounded one-repeat native JSON probe
  before any repeat-5 collection.
- Refresh docs when PR #72 head, CI, gate output, or owner decisions change.
- Use `gate:native-runtime:beta-preapproval-known-open` for the current
  expected-open beta-preapproval check while #73 and #75 remain open.
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
  dart run melos run gate:native-runtime:beta-preapproval-known-open
jq empty docs/plans/native-runtime-gate-status.json
```

Expected result:

- `git diff --check` passes;
- `pr72-draft` gate passes;
- `beta-preapproval` reports `expectationPassed=true` for the known open
  `real-app-route` and `physical-observed-profile` blockers, unless explicit
  owner decisions have been recorded;
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

Do not mark `real-app-route` satisfied without explicit owner acceptance,
normal source-review evidence, or an approved equivalent real app route.

Do not mark `physical-observed-profile` satisfied from local stabilization
evidence, Simulator smoke, or an observed host that fails the native JSON
observed-host policy.

Do not weaken `docs/benchmarks/policies/profile-reference-runner-policy.json`
or `docs/benchmarks/policies/profile-native-json-observed-policy.json` to match
this machine without an owner-approved target decision and fresh repeat-5
evidence.

Do not remove `real-app-route` or `physical-observed-profile` from the
`beta-preapproval` profile to make the gate pass.

Do not publish, tag, bump versions, undraft PR #72, or add beta/stable package
copy from this coordination note.
