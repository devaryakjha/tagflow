# 2026-06-12 Physical Target Availability Refresh

## Status

- Date: 2026-06-12 06:51 IST
- Coordinator commit: `0267505d276a4520668f9e995f101e38be3773c4`
- Worker checkout: detached `0267505d276a4520668f9e995f101e38be3773c4`,
  contained by `codex/tagflow-native-runtime-master`
- Posture: read-only target availability audit; no profile probe, threshold,
  or performance claim

## Purpose

Refresh the physical target evidence from current local tooling before any
Tagflow device profile qualification run. A one-repeat physical probe is only
credible when the selected physical target is visible through the Flutter
device list and the platform profiling/build tooling as a normal connected
target, not only as a remembered, wireless, local-network, or offline device.

## Commands

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH flutter devices -v
```

```bash
xcrun xctrace list devices
```

```bash
xcrun devicectl list devices
```

```bash
xcrun devicectl list devices --verbose
```

```bash
if command -v adb >/dev/null 2>&1; then
  adb devices -l
elif [ -x /Users/arya/Library/Android/sdk/platform-tools/adb ]; then
  /Users/arya/Library/Android/sdk/platform-tools/adb devices -l
else
  echo 'adb: command not found'
fi
```

```bash
system_profiler SPUSBDataType |
  grep -Ei -A 18 -B 6 \
    'iPhone|iPad|Apple Mobile|Android|Pixel|Samsung|00008150|00008120'
```

## Observed State

### iOS

Flutter reported three connected devices, none of them a physical iPhone or
iPad:

- `iPhone 17` simulator
  `3BA9E377-4B6F-49A7-83FA-F640060D6442`
- `macOS`
- `Chrome`

Flutter reported two wirelessly connected iOS devices:

- `Arya's Iphone 17 (wireless)` `00008150-00110C960186401C`
- `Aryakumar Jha's iPad (wireless)` `00008120-0006395208E14032`

During the same `flutter devices -v` scan, the underlying Apple `xcdevice`
record again surfaced `Arya's Iphone 17` as a physical `iphoneos` device with
`interface: usb` and `available: true`. That lower-level metadata did not
translate into a credible profile target because Flutter's final device
summary still placed the phone in the wireless bucket.

`xcrun devicectl list devices` reported:

- `Arya's Iphone 17` as `available (paired)`
- `Aryakumar Jha's iPad` as `available (paired)`
- older remembered iOS devices as `unavailable`

Verbose CoreDevice state still showed the active iPhone and iPad sessions as
local-network sessions rather than ready USB profiling sessions:

- `pairingState: paired`
- `transportType: localNetwork`
- `tunnelState: disconnected`
- `ddiServicesAvailable: false`
- `developerModeStatus: enabled`

`xcrun xctrace list devices` listed every physical iOS device under
`Devices Offline`, including:

- `Arya's Iphone 17 (27.0)` `00008150-00110C960186401C`
- `Aryakumar Jha's iPad (27.0)` `00008120-0006395208E14032`

The bounded USB report search returned no iPhone, iPad, Apple Mobile, Android,
Pixel, Samsung, or matching UDID rows.

### Android

`adb devices -l` was available and returned only:

```text
List of devices attached
```

No Android target was attached.

## Qualification Result

No credible one-repeat physical Tagflow profile probe is available right now.

- iOS is not credible because Flutter still exposes the candidate phone and
  iPad only as wirelessly connected devices, verbose CoreDevice state still
  shows local-network transport with a disconnected tunnel and unavailable DDI
  services, and `xctrace` still lists those physical devices offline. The
  transient `xcdevice` `interface: usb` metadata is not enough by itself to
  qualify profile mode.
- Android is not credible because no physical Android device is attached.
- No profile command was run from this audit because the target state did not
  meet the minimum availability bar.

## Next Step

Before retrying a Tagflow physical probe, make the chosen device visible as a
normal connected physical target to both Flutter and platform profiling
tooling. For iOS, the phone or iPad should no longer appear only under
Flutter's wireless bucket, CoreDevice should not report a disconnected
local-network tunnel for the active session, and `xctrace` should not list the
device under `Devices Offline`.

If iOS remains inconsistent, attach a physical Android target and rerun this
availability audit before attempting a one-repeat profile baseline.
