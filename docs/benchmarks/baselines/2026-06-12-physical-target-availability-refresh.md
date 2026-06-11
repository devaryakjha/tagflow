# 2026-06-12 Physical Target Availability Refresh

## Status

- Date: 2026-06-12 Asia/Kolkata
- Coordinator commit: `26166fe2ae45a43e16658098ff231f2f6e3dd875`
- Worker checkout: detached `ff3188bcf1d8a7a19a755f4d8b23cce6a0bda80b`,
  contained by `codex/tagflow-native-runtime-master`
- Posture: read-only target availability audit; no profile probe, threshold,
  or performance claim

## Purpose

Refresh the physical target evidence after the previous USB probe note. This
audit did not run a Tagflow profile baseline. It only rechecked whether the
current machine exposes a credible physical iOS or Android target for the
required one-repeat qualification probe.

## Commands

```bash
git branch --show-current
git status --short --branch
git rev-parse HEAD
git branch --contains HEAD
```

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH flutter devices -v
```

```bash
xcrun devicectl list devices
xcrun devicectl list devices --verbose
xcrun xctrace list devices
```

```bash
if command -v adb >/dev/null 2>&1; then
  adb devices -l
elif [ -x /Users/arya/Library/Android/sdk/platform-tools/adb ]; then
  /Users/arya/Library/Android/sdk/platform-tools/adb devices -l
else
  echo "adb: command not found"
fi
```

## Observed State

### iOS

Flutter reported three connected devices, none of them a physical iPhone:

- `iPhone 17` simulator
  `3BA9E377-4B6F-49A7-83FA-F640060D6442`
- `macOS`
- `Chrome`

Flutter reported two wirelessly connected iOS devices:

- `Arya's Iphone 17 (wireless)` `00008150-00110C960186401C`
- `Aryakumar Jha's iPad (wireless)` `00008120-0006395208E14032`

CoreDevice still reported `Arya's Iphone 17` as available and paired, but the
verbose record showed the session was not a reliable local profiling target:

- `pairingState: paired`
- `transportType: localNetwork`
- `tunnelState: disconnected`
- `ddiServicesAvailable: false`
- `developerModeStatus: enabled`

`xcrun xctrace list devices` still listed `Arya's Iphone 17 (27.0)`
`00008150-00110C960186401C` under `Devices Offline`.

### Android

`adb devices -l` was available and returned only:

```text
List of devices attached
```

No Android target was attached.

## Qualification Result

No credible one-repeat physical Tagflow profile probe is available right now.

- iOS is not credible because Flutter sees the phone only in the wireless
  bucket, CoreDevice reports a local-network session with disconnected tunnel
  and unavailable DDI services, and `xctrace` lists the same phone offline.
- Android is not credible because no physical Android device is attached.
- No profile command was run from this audit because the target state did not
  meet the minimum availability bar.

## Next Step

Before retrying a Tagflow physical probe, make the chosen device visible as a
normal connected physical target to both Flutter and Apple profiling tooling.
For iOS, that means the phone should no longer appear only under Flutter's
wireless bucket, `devicectl --verbose` should not show a disconnected tunnel
for the active session, and `xctrace` should not list the device under
`Devices Offline`.

If iOS remains inconsistent, attach a physical Android target and rerun this
availability audit before attempting a one-repeat profile baseline.
