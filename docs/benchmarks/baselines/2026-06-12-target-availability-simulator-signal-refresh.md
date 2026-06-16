# 2026-06-12 Target Availability Simulator Signal Refresh

## Status

- Date: 2026-06-12
- Branch: `codex/tagflow-native-runtime-master`
- Run id: `2026-06-12-current-machine-r2`
- Posture: target-audit signal refresh only; no profile run and no
  performance claim

## Purpose

Record the follow-up target audit after the preflight parser started preserving
iOS Simulator candidates as an explicit signal. Simulators are useful for debug
smoke checks, but they are not credible physical profile targets.

This complements
`docs/benchmarks/baselines/2026-06-12-ios-simulator-smoke.md`, which records
that Flutter can run the native JSON route in debug mode on the booted
Simulator, while profile-mode iOS Simulator builds are rejected by Flutter.

## Command

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_TARGET_AUDIT_RUN_ID=2026-06-12-current-machine-r2 \
dart run melos run benchmark:profile:target-audit
```

The command writes ignored raw JSON under:

```text
build/benchmarks/target-availability/2026-06-12-current-machine-r2/target-availability-audit.json
```

## Current Machine Result

The audit returned:

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

Recorded simulator signal:

```text
name=iPhone 17 (mobile)
id=3BA9E377-4B6F-49A7-83FA-F640060D6442
source=flutter
blockingReasons=simulator
```

## Interpretation

The target audit now separates three different facts:

- an iOS Simulator is visible to Flutter and can support local debug smoke;
- a wireless physical iOS candidate is visible to Flutter but does not qualify
  as a profile target;
- no physical iOS or Android target is currently credible for profile-mode
  benchmark collection.

The physical or observed-host profile gate remains open. This evidence does not
qualify frame-budget, memory, beta/stable, public benchmark, or faster/slower
claims.
