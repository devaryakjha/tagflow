# 2026-06-12 Target Availability CoreDevice Refresh

## Status

- Date: 2026-06-12 Asia/Kolkata
- Branch: `codex/tagflow-native-runtime-master`
- Run id: `2026-06-12-current-machine-r4`
- Related gate: `physical-observed-profile`
- Posture: target-audit refresh and tooling hardening only; no profile run and
  no gate closure

## Purpose

Refresh the physical target preflight after the earlier Simulator relaunch
check, and preserve the CoreDevice summary-table signal that was previously
hidden by the target-audit parser.

This does not weaken the physical profile gate. A target still needs credible
agreement from Flutter wired visibility and Instruments, without CoreDevice
blocking state.

## Commands

Focused parser regression:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
cd packages/tagflow_benchmarks && \
flutter test test/target_availability_audit_test.dart
```

Target refresh:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_TARGET_AUDIT_RUN_ID=2026-06-12-current-machine-r4 \
TAGFLOW_TARGET_AUDIT_OUTPUT_DIR=build/benchmarks/target-availability \
dart run melos run benchmark:profile:target-audit
```

Ignored raw artifact:

```text
build/benchmarks/target-availability/2026-06-12-current-machine-r4/target-availability-audit.json
```

## Result

The audit completed successfully and still reported no credible physical
profile target:

```text
canRunPhysicalProfileProbe=false
summary=No credible physical profile target is available.
credibleProfileTargets=0
flutterConnectedPhysicalIos=0
flutterIosSimulators=1
flutterWirelessIos=2
xctraceOnlinePhysicalIos=0
xctraceOfflinePhysicalIos=7
coreDeviceAvailableIos=2
coreDeviceBlockingIds=7
adbAttachedAndroid=0
```

CoreDevice summary now records two available paired iOS devices:

```text
Aryakumar Jha's iPad
Arya's Iphone 17
```

Those signals still do not qualify the physical profile gate. Flutter reports
both devices in its wireless section, Instruments reports Arya's Iphone 17
offline, and CoreDevice verbose state includes the matching UDIDs in the
blocking set.

## Interpretation

The current machine has useful local Apple device signals, but not a credible
physical profile target. The blocker is not the iOS Simulator app state. The
blocking evidence is cross-tool disagreement:

- Flutter has no connected physical iOS target outside the wireless section.
- `xcrun xctrace list devices` has no online physical iOS target.
- CoreDevice verbose state still marks the relevant physical UDIDs blocked.
- ADB is available through the fallback SDK path but has no attached Android
  device.

No profile benchmark was run from this audit. This note does not support public
benchmark claims, frame-budget claims, memory claims, beta/stable release
wording, or package publishing.

The `physical-observed-profile` gate remains open until a credible physical
iOS or Android target passes target audit and repeat profile collection, an
owner-approved observed host passes policy, or an explicit owner waiver is
recorded for the release profile.
