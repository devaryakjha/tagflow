# 2026-06-13 Target Availability Refresh

## Status

- Date: 2026-06-13 Asia/Kolkata
- Branch: `codex/tagflow-native-runtime-master`
- Run id: `2026-06-13-current-machine-r1`
- Related gate: `physical-observed-profile`
- Posture: target-audit refresh only; no profile run and no gate closure

## Purpose

Refresh the physical target preflight after the PR #72 head moved to
`a1ecfdd`. This is a target-availability check only. It does not weaken the
physical profile gate and does not support public performance claims.

## Command

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_TARGET_AUDIT_RUN_ID=2026-06-13-current-machine-r1 \
TAGFLOW_TARGET_AUDIT_OUTPUT_DIR=build/benchmarks/target-availability \
dart run melos run benchmark:profile:target-audit
```

Ignored raw artifact:

```text
build/benchmarks/target-availability/2026-06-13-current-machine-r1/target-availability-audit.json
```

## Result

The audit completed and still reported no credible physical profile target:

```text
canRunPhysicalProfileProbe=false
summary=No credible physical profile target is available.
credibleProfileTargets=0
flutterConnectedPhysicalIos=0
flutterIosSimulators=1
flutterWirelessIos=2
flutterConnectedAndroid=0
xctraceOnlinePhysicalIos=0
xctraceOfflinePhysicalIos=7
coreDeviceAvailableIos=2
coreDeviceBlockingIds=7
adbAttachedAndroid=0
```

## Interpretation

The current machine still has local Apple device signals, but not a credible
physical profile target. Flutter reports no connected physical iOS device,
Instruments reports no online physical iOS device, CoreDevice still contributes
blocking IDs, and ADB has no attached Android device.

No profile benchmark was run from this audit. This note does not support public
benchmark claims, frame-budget claims, memory claims, beta/stable release
wording, package publishing, or gate closure.

The `physical-observed-profile` gate remains open until a credible physical
iOS or Android target passes target audit and repeat profile collection, an
owner-approved observed host passes policy, or an explicit owner waiver is
recorded for the release profile.
