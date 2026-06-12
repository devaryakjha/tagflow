# 2026-06-12 Physical Observed Profile Owner Decision Request

## Status

- Date: 2026-06-12 Asia/Kolkata
- Related gate: `physical-observed-profile`
- Gate manifest: `docs/plans/native-runtime-gate-status.json`
- Native JSON observed-host policy:
  `docs/benchmarks/policies/profile-native-json-observed-policy.json`
- Posture: owner decision request; not gate closure until accepted

## Purpose

Make the remaining profile-evidence decision explicit for beta preapproval.
Current local evidence is good enough for harness health and local
stabilization, but it does not satisfy the written physical or qualified
observed-host profile gate.

This note does not approve beta/stable release wording, public benchmark
claims, numeric frame-budget claims, memory claims, or package publishing.

## Current Evidence

Physical target audit:

```text
canRunPhysicalProfileProbe=false
summary=No credible physical profile target is available.
flutterIosSimulators=1
flutterWirelessIos=1
flutterConnectedPhysicalIos=0
xctraceOnlinePhysicalIos=0
xctraceOfflinePhysicalIos=7
coreDeviceBlockingIds=7
adbAttachedAndroid=0
```

Supporting docs:

- `docs/benchmarks/baselines/2026-06-12-target-availability-audit-tooling.md`
- `docs/benchmarks/baselines/2026-06-12-target-availability-simulator-signal-refresh.md`

Observed-host repeat-5 native JSON run:

```text
runId=2026-06-12-observed-host-native-json-repeat5-timeout-r1
rendererFixture=tagflow_native_json:native_ai_answer
successfulRuns=5/5
timedOutRuns=0/5
minRepeats=5 check=passed
observedViewport=800x600 @ 1.0x
```

Supporting doc:

- `docs/benchmarks/baselines/2026-06-12-observed-host-native-json-repeat5-timeout.md`

## Why The Gate Remains Open

The current reference-runner policy expects:

```json
{
  "logicalWidth": 800,
  "logicalHeight": 600,
  "devicePixelRatio": 2
}
```

The repeat-5 observed-host run reported:

```json
{
  "logicalWidth": 800.0,
  "logicalHeight": 600.0,
  "physicalWidth": 800.0,
  "physicalHeight": 600.0,
  "devicePixelRatio": 1.0
}
```

The collection-quality check passes with `minRepeats=5`, but the
native JSON observed-host policy check fails on `unexpected_viewport`. The
current host therefore remains a local stabilization host, not the configured
qualified observed-host target.

After profile-policy matrix enforcement, the default HTML reference policy at
`docs/benchmarks/policies/profile-reference-runner-policy.json` intentionally
does not qualify `tagflow_native_json:native_ai_answer`. Native JSON profile
checks should use
`docs/benchmarks/policies/profile-native-json-observed-policy.json`, which keeps
the same `800x600 @ 2.0x` observed-host guard.

The physical target audit also says no physical iOS or Android target is
credible for profile-mode collection on this machine.

## Owner Decision Options

### Option A: Provide A Qualifying Target

Use this option if beta preapproval should require physical or qualified
observed-host evidence.

Required next evidence:

- attach a credible physical iOS or Android target that passes
  `benchmark:profile:target-audit`, then collect a repeat-5 profile run; or
- update `docs/benchmarks/policies/profile-native-json-observed-policy.json` to
  an owner-approved observed-host target, then collect fresh repeat-5 evidence
  on that target and pass the updated policy check.

Acceptance text:

```text
I do not waive physical-observed-profile. Beta preapproval requires a fresh
repeat-5 profile run on a credible physical device or on the approved observed
host described by
docs/benchmarks/policies/profile-native-json-observed-policy.json. Do not mark
physical-observed-profile satisfied until that run passes the collection-quality
and policy checks.
```

### Option B: Waive For Beta Preapproval Only

Use this option if the current local stabilization evidence is enough for a
beta approval packet, while keeping all performance and public-claim boundaries
blocked.

Waiver text:

```text
I waive physical-observed-profile for beta preapproval only. I accept the
current local observed-host repeat-5 native JSON run
2026-06-12-observed-host-native-json-repeat5-timeout-r1 as local stabilization
evidence, despite the reference-runner viewport mismatch and lack of physical
device evidence. This waiver does not approve public benchmark claims,
frame-budget claims, memory claims, comparative performance wording, stable
release wording, or package publishing.
```

If this waiver is recorded, keep `physical-observed-profile.status=open` unless
the owner explicitly instructs that the gate should be marked satisfied for a
specific release profile. Prefer recording the waiver in the beta approval
packet rather than weakening the benchmark gate globally.

## Stop Rules

Do not mark `physical-observed-profile` satisfied if any of these remain true
without explicit owner acceptance:

- no credible physical iOS or Android profile target is available;
- observed-host evidence fails the configured reference-runner policy;
- the decision only says local stabilization evidence is useful, not that it is
  accepted for beta preapproval;
- public benchmark, frame-budget, memory, or faster/slower wording would depend
  on this evidence.

Until Option A evidence exists or Option B waiver text is recorded,
`beta-preapproval` must continue to fail on `physical-observed-profile`.
