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
public package-owned reference app route. The #75 physical profile gate is now
satisfied by repeat-5 Time Profiler traces on the wired iPhone 17.

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
TAGFLOW_NATIVE_RUNTIME_GATE_PROFILE=beta-preapproval \
  dart run melos run gate:native-runtime

profile=beta-preapproval
passed=true
issues=[]
requiredOpenGates=[]
```

Current beta candidate gate:

```text
TAGFLOW_NATIVE_RUNTIME_GATE_PROFILE=beta-candidate \
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
  dart run melos run gate:native-runtime

profile=beta-candidate
passed=false
issues=[
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
- repeat-5 physical iPhone profile:
  `docs/benchmarks/baselines/2026-06-13-iphone17-time-profiler-repeat5.md`
- latest policy-matrix enforcement note:
  `docs/benchmarks/baselines/2026-06-12-profile-policy-matrix-enforcement.md`
- Native JSON observed-host policy:
  `docs/benchmarks/policies/profile-native-json-observed-policy.json`

Current evidence summary:

```text
historical physical target audit:
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

qualified wired iPhone 17 check:
  device=00008150-00110C960186401C
  flutterDevice="Arya's Iphone 17"
  flutterInterface=usb
  coreDeviceTransport=wired
  coreDeviceAvailability=connected
  xctraceState=online

physical iPhone Time Profiler repeat-5:
  traceRuns=5/5
  process=Tagflow
  template=Time Profiler
  timeLimit=10 seconds
  endReason="Time limit reached"
```

The physical iPhone path required Xcode-beta, iOS deployment target `15.0`,
Flutter's UIScene host migration, and the owner's signing team configuration.
After those changes, the app builds, signs, installs, launches, and records
repeat-5 Time Profiler traces. Flutter's VM-service attach path still fails on
this Mac because the checked-out Flutter SDK bundles an x86_64-only `iproxy`
and Rosetta is not installed; direct Xcode Instruments collection is therefore
the physical profile evidence for #75.

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

- keep #75 linked to
  `docs/benchmarks/baselines/2026-06-13-iphone17-time-profiler-repeat5.md`;
- keep `physical-observed-profile.status=satisfied` unless new evidence
  invalidates the physical-device collection;
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

Do not reinterpret the satisfied `physical-observed-profile` gate as a public
performance claim, frame-budget claim, memory claim, or release approval.

Do not weaken
`docs/benchmarks/policies/profile-native-json-observed-policy.json` or
`docs/benchmarks/policies/profile-reference-runner-policy.json` to fit this
machine or the local Flutter `iproxy` state.

Do not treat local stabilization profile evidence as public performance
evidence.

Do not publish, tag, bump versions, or undraft PR #72 from this packet.
