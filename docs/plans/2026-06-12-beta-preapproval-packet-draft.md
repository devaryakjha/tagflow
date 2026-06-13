# Beta Preapproval Packet Draft

## Status

- Date: 2026-06-13 Asia/Kolkata
- Draft review PR: https://github.com/devaryakjha/tagflow/pull/72
- Branch: `codex/tagflow-native-runtime-master`
- Gate manifest: `docs/plans/native-runtime-gate-status.json`
- Posture: draft packet only; no beta, stable, publish, tag, version bump, or
  public claim approval

## Purpose

Assemble the current beta-preapproval decision surface in one place. This
packet is useful for owner review, but it does not satisfy any open gate by
itself.

The owner clarified that proprietary downstream app changes must not be used as
the public Tagflow review artifact. The #73 route is therefore satisfied by the
public package-owned reference app route, and the remaining non-owner-approval
beta-preapproval blocker is `physical-observed-profile`.

The beta-candidate state still includes the deferred owner-only
`release-approval` gate.

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
  physical-observed-profile: open
]
requiredOpenGates=[
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
  physical-observed-profile: open,
  release-approval: deferred
]
```

## Evidence Already Satisfied

These gates are already satisfied in
`docs/plans/native-runtime-gate-status.json`:

- `runtime-surface`: canonical `TagflowDocument` runtime input,
  `Tagflow.document(...)`, semantic `Tagflow.html(...)`, strict native block
  JSON document and patch transport, node taps with semantics-action coverage,
  example-app native block activation coverage, and adapter metadata helpers;
- `coordinator-validation`: local validation and PR #72 CI evidence;
- `pr72-benchmark-gate`: internal synthetic report-only benchmark gate for
  PR #72, tracked separately from physical, observed-host, memory,
  frame-budget, beta/stable, and comparative performance claims;
- `real-app-route`: public package-owned route at
  `examples/tagflow` -> `/reference-app-route`;
- `memory-allocation-review`: local report-only macOS memory/allocation review
  with public claim boundaries.

Do not reinterpret any satisfied gate as approval for beta/stable release
wording, package publishing, or public performance claims.

## Reference App Route Evidence

Current #73 evidence:

- `docs/plans/2026-06-12-real-app-route-qualification.md`
- `docs/validation/evidence/2026-06-13-reference-app-route.md`
- `examples/tagflow/lib/screens/reference_app_route_screen.dart`
- `examples/tagflow/test/reference_app_route_test.dart`

The route renders package-owned rich content through:

- `Tagflow.document(...)`;
- `Tagflow.html(..., registry: ...)`;
- `tagflowTableComponents(...)`;
- app-owned link, image, and unsupported-content overrides;
- a `TagflowDocumentPatch` CMS update from `cms-rev-1` to `cms-rev-2`.

This evidence is intentionally public and neutral. It replaces the prior
private downstream app path for #73.

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
- direct iPhone profile probe:
  `docs/benchmarks/baselines/2026-06-13-iphone17-profile-signing-blocked.md`
- latest policy-matrix enforcement note:
  `docs/benchmarks/baselines/2026-06-12-profile-policy-matrix-enforcement.md`
- Native JSON observed-host policy:
  `docs/benchmarks/policies/profile-native-json-observed-policy.json`

Current evidence summary:

```text
physical target audit:
  canRunPhysicalProfileProbe=false
  latest checked runId=2026-06-13-iphone-mirroring-r1
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

ios simulator recovery:
  bootedSimulator=iPhone 17 3BA9E377-4B6F-49A7-83FA-F640060D6442
  flutterSeesSimulator=true
  profileBuildResult=failed
  profileBuildMessage="Profile mode is not supported for simulators."
```

iPhone Mirroring is useful for visual/manual QA, but the current tooling state
still reports the physical iPhone as wireless in Flutter and offline in
`xctrace`; it does not satisfy this profile gate.

A direct `flutter run --profile --no-resident` probe against the iPhone 17
did select the physical device and begin an Xcode profile build, but it failed
before installation because this Mac lacks an Xcode account/provisioning
profile for team `7573STCA2W` and bundle id `dev.aryak.tagflow`.

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

Use this block only after replacing `<candidate-sha>` with the current reviewed
PR head:

```text
For Tagflow PR #72 at commit <candidate-sha>, I accept the public reference app
route at examples/tagflow -> /reference-app-route as the #73 review artifact.

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

- update #75 with the recorded physical/observed-profile decision;
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

Do not mark `physical-observed-profile` satisfied from this packet alone.

Do not remove `physical-observed-profile` from `beta-preapproval` to make the
profile pass.

Do not weaken
`docs/benchmarks/policies/profile-native-json-observed-policy.json` or
`docs/benchmarks/policies/profile-reference-runner-policy.json` to match this
machine without an owner-approved observed-host target decision and fresh
repeat-5 evidence.

Do not treat local stabilization profile evidence as public performance
evidence.

Do not publish, tag, bump versions, or undraft PR #72 from this packet.
