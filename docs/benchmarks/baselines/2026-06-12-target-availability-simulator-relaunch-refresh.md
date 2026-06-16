# 2026-06-12 Target Availability Simulator Relaunch Refresh

## Status

- Date: 2026-06-12 Asia/Kolkata
- Branch: `codex/tagflow-native-runtime-master`
- Run id: `2026-06-12-current-machine-r3`
- Related gate: `physical-observed-profile`
- Posture: target-audit refresh only; no profile run and no gate closure

## Purpose

Refresh the target-audit state after force-quitting and relaunching Simulator.
This checks the owner's suggested Simulator recovery path without treating an
iOS Simulator as physical profile evidence.

## Commands

Simulator relaunch:

```bash
osascript -e 'quit app "Simulator"' || true
open -a Simulator
```

Target refresh:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_TARGET_AUDIT_RUN_ID=2026-06-12-current-machine-r3 \
dart run melos run benchmark:profile:target-audit
```

Ignored raw artifact:

```text
build/benchmarks/target-availability/2026-06-12-current-machine-r3/target-availability-audit.json
```

## Result

The audit completed successfully and still reported no credible physical
profile target:

```text
canRunPhysicalProfileProbe=false
summary=No credible physical profile target is available.
credibleProfileTargets=0
flutterIosSimulators=1
flutterWirelessIos=2
flutterConnectedPhysicalIos=0
xctraceOnlinePhysicalIos=0
xctraceOfflinePhysicalIos=7
coreDeviceAvailableIos=0
coreDeviceBlockingIds=7
adbAttachedAndroid=0
```

The booted Simulator remains visible as a Simulator signal:

```text
id=3BA9E377-4B6F-49A7-83FA-F640060D6442
name=iPhone 17 (mobile)
blockingReasons=simulator
```

ADB was found through the fallback SDK path, but no Android device was
attached.

## Interpretation

Relaunching Simulator restores or preserves useful local debug-smoke state, but
it does not create a credible physical iOS or Android profile target. Flutter
profile-mode iOS Simulator builds remain disallowed, so this refresh does not
advance `physical-observed-profile` beyond target availability evidence.

The gate remains open until one of these happens:

- a credible physical iOS or Android target passes target audit and repeat
  profile collection;
- an owner-approved observed host passes the native JSON observed-host policy;
  or
- an explicit owner waiver is recorded for the relevant release profile.

This note does not support public benchmark claims, frame-budget claims, memory
claims, beta/stable release wording, or package publishing.
