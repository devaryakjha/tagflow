# 2026-06-12 Target Availability Audit Tooling

## Status

- Date: 2026-06-12
- Branch: `codex/tagflow-native-runtime-master`
- Run id: `2026-06-12-current-machine-r1`
- Posture: benchmark preflight tooling and report-only availability evidence;
  no profile run and no performance claim

## Purpose

Add a repeatable machine-readable preflight before any physical Tagflow profile
benchmark probe. The audit checks whether Flutter and platform tooling agree on
a connected physical target before the benchmark runner attempts
`flutter drive --profile`.

This replaces hand-written device discovery as the first step, but it does not
replace a real profile baseline, frame-budget review, memory review, or public
benchmark policy.

## New Command

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_TARGET_AUDIT_RUN_ID=2026-06-12-current-machine-r1 \
dart run melos run benchmark:profile:target-audit
```

The command writes ignored raw JSON under:

```text
build/benchmarks/target-availability/2026-06-12-current-machine-r1/target-availability-audit.json
```

The JSON records raw command output, parsed target signals, and the conservative
`canRunPhysicalProfileProbe` decision.

Follow-up signal refresh:

- `docs/benchmarks/baselines/2026-06-12-target-availability-simulator-signal-refresh.md`
- the audit now records iOS Simulator candidates under
  `signals.flutterIosSimulators`;
- simulators remain excluded from `credibleProfileTargets`.

## Current Machine Result

The audit returned:

```text
canRunPhysicalProfileProbe=false
summary=No credible physical profile target is available.
flutterWirelessIos=1
flutterConnectedPhysicalIos=0
xctraceOnlinePhysicalIos=0
xctraceOfflinePhysicalIos=7
coreDeviceBlockingIds=7
adbAttachedAndroid=0
```

ADB was found through the fallback path:

```text
/Users/arya/Library/Android/sdk/platform-tools/adb
```

No profile command was run because the audit found no credible physical target.

## Classification Rules

The first implementation is intentionally conservative:

- iOS requires a physical iOS target seen by Flutter as connected, not
  wireless-only;
- iOS also requires the same target to be online in `xcrun xctrace list
  devices`;
- CoreDevice disconnected, unavailable, local-network-only, or
  DDI-unavailable state blocks the target;
- Android requires the same target to appear in Flutter and ADB;
- Android emulators are excluded even when both Flutter and ADB report them;
- iOS Simulator UUID-shaped targets are recorded as simulator signals and
  excluded from physical target qualification.

The CLI has an opt-in failure mode for future gates:

```bash
TAGFLOW_TARGET_AUDIT_REQUIRE_CREDIBLE_TARGET=true \
dart run melos run benchmark:profile:target-audit
```

With that flag, the command exits non-zero when no credible physical target is
available.

## Verification

Focused test:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
flutter test packages/tagflow_benchmarks/test/target_availability_audit_test.dart
```

Result: passed.

Regression coverage includes:

- current wireless/offline iOS blocker shape;
- credible wired iOS when Flutter and Instruments agree;
- credible physical Android when Flutter and ADB agree;
- Android emulator exclusion;
- Flutter wireless-section parsing even when the row does not repeat
  `(wireless)`;
- command start failures recorded as audit data instead of throwing.

## Claim Boundary

This evidence only proves that the target-audit preflight is wired and that the
current machine still has no credible physical profile target. It does not
qualify a physical iOS or Android benchmark run, does not make memory claims,
and does not support public faster/slower wording.
