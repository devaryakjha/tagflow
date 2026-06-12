# Beta Preapproval Packet Draft

## Status

- Date: 2026-06-12 Asia/Kolkata
- Draft review PR: https://github.com/devaryakjha/tagflow/pull/72
- Recorded CI-validated PR anchor: `01149ac`
- Latest live-state refresh:
  `docs/plans/2026-06-13-pr72-live-state-refresh.md`
- Branch: `codex/tagflow-native-runtime-master`
- Gate manifest: `docs/plans/native-runtime-gate-status.json`
- Posture: draft packet only; no beta, stable, publish, tag, version bump, or
  public claim approval

## Purpose

Assemble the current beta-preapproval decision surface in one place. This
packet is useful for owner review, but it does not satisfy any open gate by
itself.

The current beta-preapproval state has two unresolved non-owner-approval gates:

- `real-app-route`;
- `physical-observed-profile`.

The beta-candidate state has the same two unresolved gates plus the deferred
owner-only `release-approval` gate.

## Gate Snapshot

Current draft PR gate:

```text
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
  dart run melos run gate:native-runtime

profile=pr72-draft
passed=true
```

Current beta preapproval gate:

```text
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
  dart run melos run gate:native-runtime:beta-preapproval-known-open

profile=beta-preapproval
passed=false
expectationPassed=true
issues=[
  real-app-route: open,
  physical-observed-profile: open
]
requiredOpenGates=[
  real-app-route,
  physical-observed-profile
]
```

Current beta candidate gate:

```text
TAGFLOW_NATIVE_RUNTIME_GATE_PROFILE=beta-candidate \
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
  dart run melos run gate:native-runtime

profile=beta-candidate
passed=false
issues=[
  real-app-route: open,
  physical-observed-profile: open,
  release-approval: deferred
]
```

Recorded anchored coordinator validation evidence:

```text
commit=01149ac

PATH=/Users/arya/fvm/cache.git/bin:$PATH dart run melos run validate
result=passed locally

GitHub CI / Validate
result=passed
run=https://github.com/devaryakjha/tagflow/actions/runs/27436534000
```

Latest live PR/tracker refresh:

```text
commit=1f9813b

GitHub CI / Validate
result=passed
run=https://github.com/devaryakjha/tagflow/actions/runs/27436837906

PR #72 state=draft/open
issue #73 state=open
issue #75 state=open
```

## Evidence Already Satisfied

These gates are already satisfied in
`docs/plans/native-runtime-gate-status.json`:

- `runtime-surface`: canonical `TagflowDocument` runtime input,
  `Tagflow.document(...)`, semantic `Tagflow.html(...)`, strict native block
  JSON document and patch transport, node taps with first button-like semantics
  plus semantics-action coverage on opted-in non-link document and
  HTML-adapted targets, example-app native block activation coverage, and
  adapter metadata helpers;
- `coordinator-validation`: local validation and PR #72 CI evidence;
- `pr72-benchmark-gate`: internal synthetic report-only benchmark gate for
  PR #72, tracked separately from physical, observed-host, memory,
  frame-budget, beta/stable, and comparative performance claims;
- `memory-allocation-review`: local report-only macOS memory/allocation review
  with public claim boundaries.

Do not reinterpret any satisfied gate as approval for beta/stable release
wording, package publishing, or public performance claims.

## Real-App Route Decision

Current best real-app route evidence is the Kite IPO route packet.

Decision request:

- `docs/validation/evidence/2026-06-12-kite-non-gitlab-owner-acceptance-request.md`
- Related tracker: https://github.com/devaryakjha/tagflow/issues/73

The unresolved decision is whether the owner accepts the non-GitLab packet as
the review artifact for the Kite route while Kite's normal GitLab remote is not
reachable from this machine.

GitHub state checked for this packet at PR head `01149ac`, and refreshed at
live PR head `1f9813b`:

- issue #73 remains open;
- issue #73 body now records the non-GitLab Kite packet as an acceptable
  substitute review artifact only after explicit owner acceptance of the packet
  and local debug fixture/auth constraints;
- no issue or PR comment records the owner acceptance text below;
- `real-app-route` therefore remains open in
  `docs/plans/native-runtime-gate-status.json`.

Owner acceptance text:

```text
I accept the Kite non-GitLab review packet at
/Users/arya/projects/tagflow/build/validation/kite-non-gitlab-review-packet/2026-06-12-ipo-native-route
as the review artifact for the IPOInstrumentSheet Tagflow native-runtime route
in #73. I accept the local debug fixture/auth constraints recorded for the
Bids -> IPO -> AFCONS -> IPOInstrumentSheet route smoke. This acceptance is
for the #73 real-app route gate only and does not approve beta/stable release,
publishing, or public performance claims.
```

Until that decision is recorded, keep `real-app-route.status=open` and keep
#73 open.

## Physical/Observed Profile Decision

Current best profile evidence is local stabilization evidence, not qualified
physical or observed-host evidence.

Decision request:

- Tracker: https://github.com/devaryakjha/tagflow/issues/75
- `docs/benchmarks/baselines/2026-06-12-physical-observed-profile-owner-decision-request.md`
- latest simulator recovery note:
  `docs/benchmarks/baselines/2026-06-12-ios-simulator-profile-continuation.md`
- latest target-audit refresh:
  `docs/benchmarks/baselines/2026-06-13-target-availability-refresh.md`
- latest policy-matrix enforcement note:
  `docs/benchmarks/baselines/2026-06-12-profile-policy-matrix-enforcement.md`
- Native JSON observed-host policy:
  `docs/benchmarks/policies/profile-native-json-observed-policy.json`

Current evidence summary:

```text
physical target audit:
  canRunPhysicalProfileProbe=false
  runId=2026-06-13-current-machine-r1
  credibleProfileTargets=0
  flutterIosSimulators=1
  flutterWirelessIos=2
  flutterConnectedPhysicalIos=0
  flutterConnectedAndroid=0
  xctraceOnlinePhysicalIos=0
  xctraceOfflinePhysicalIos=7
  coreDeviceAvailableIos=2
  coreDeviceBlockingIds=7
  adbAttachedAndroid=0

observed-host repeat-5 native JSON run:
  successfulRuns=5/5
  timedOutRuns=0/5
  minRepeats=5 check=passed
  observedViewport=800x600 @ 1.0x

native JSON observed-host policy:
  expectedViewport=800x600 @ 2.0x
  result=failed unexpected_viewport

policy matrix after checker enforcement:
  referencePolicyMatrix=default HTML renderer/fixture cells
  nativeJsonPolicyMatrix=tagflow_native_json/native_* cells
  nativeJsonCell=tagflow_native_json:native_ai_answer
  htmlReferencePolicyResult=failed cell_outside_policy_matrix
  nativeJsonPolicyResult=failed unexpected_viewport

ios simulator recovery:
  bootedSimulator=iPhone 17 3BA9E377-4B6F-49A7-83FA-F640060D6442
  flutterSeesSimulator=true
  profileBuildResult=failed
  profileBuildMessage="Profile mode is not supported for simulators."
```

The Simulator recovery path is useful debug-route smoke evidence, but it cannot
produce Flutter profile-mode benchmark evidence and does not satisfy this gate.

Owner option A requires qualifying evidence:

```text
I do not waive physical-observed-profile. Beta preapproval requires a fresh
repeat-5 profile run on a credible physical device or on the approved observed
host described by
docs/benchmarks/policies/profile-native-json-observed-policy.json. Do not mark
physical-observed-profile satisfied until that run passes the collection-quality
and policy checks.
```

Owner option B waives the gate for beta preapproval only:

```text
I waive physical-observed-profile for beta preapproval only. I accept the
current local observed-host repeat-5 native JSON run
2026-06-12-observed-host-native-json-repeat5-timeout-r1 as local stabilization
evidence, despite the native JSON observed-host policy viewport mismatch and
lack of physical device evidence. This waiver does not approve public
benchmark claims, frame-budget claims, memory claims, comparative performance
wording, stable release wording, or package publishing.
```

Unless option A evidence exists or option B waiver text is recorded, keep
`physical-observed-profile.status=open` and keep beta preapproval failing on
that gate.

## Consolidated Owner Decision Block

Use this block only after choosing the real-app route decision and profile
decision above, and after replacing `<candidate-sha>` with the current reviewed
PR head:

```text
For Tagflow PR #72 at commit <candidate-sha>, I accept the Kite non-GitLab review
packet at
/Users/arya/projects/tagflow/build/validation/kite-non-gitlab-review-packet/2026-06-12-ipo-native-route
as the #73 real-app route review artifact for the IPOInstrumentSheet route,
including the recorded local debug fixture/auth constraints.

For physical-observed-profile, I choose <option A: require qualifying evidence
before beta preapproval | option B: waive for beta preapproval only using the
local stabilization evidence>. This decision does not approve public benchmark
claims, frame-budget claims, memory claims, comparative performance wording,
stable release wording, publishing, tagging, or package-version changes.
```

This consolidated block is not a publish approval. Publishing still requires a
separate explicit owner go-ahead after release notes, package-page wording,
package scope, versions, and dry-run output are reviewed.

## Post-Decision Manifest Instructions

Only after explicit owner acceptance:

- update #73 with the recorded real-app route decision;
- if the Kite packet is accepted, set `real-app-route.status=satisfied` and add
  the accepted owner decision as evidence;
- if profile option A evidence exists, link the fresh qualifying repeat-5 run
  and set `physical-observed-profile.status=satisfied`;
- if profile option B is accepted, prefer recording the waiver in the approval
  packet while keeping `physical-observed-profile.status=open`, unless the
  owner explicitly instructs a release-profile-specific status change;
- keep `release-approval.status=deferred` until the full release approval
  packet is reviewed and accepted.

Do not add this draft packet as `release-approval` evidence in
`docs/plans/native-runtime-gate-status.json`. The release-approval gate should
only reference a reviewed approval packet after approval exists.

## Claim Boundaries

This packet does not support:

- public benchmark claims;
- faster/slower or comparative performance wording;
- lower-memory, leak-free, or allocation claims;
- frame-budget claims;
- production-ready, beta-ready, or stable-ready wording;
- package publishing;
- tag creation;
- package-version changes;
- README, changelog, or package-page promotional copy.

## Stop Rules

Do not mark any gate satisfied from this packet alone.

Do not remove `real-app-route` or `physical-observed-profile` from
`beta-preapproval` to make the profile pass.

Do not weaken
`docs/benchmarks/policies/profile-native-json-observed-policy.json` or
`docs/benchmarks/policies/profile-reference-runner-policy.json` to match this
machine without an owner-approved observed-host target decision and fresh
repeat-5 evidence.

Do not treat local stabilization profile evidence as public performance
evidence.

Do not treat the Kite non-GitLab packet as #73 closure until the owner accepts
it as the review substitute.

Do not publish, tag, bump versions, or undraft PR #72 from this packet.
