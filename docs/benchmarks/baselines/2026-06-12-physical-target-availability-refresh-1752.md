# 2026-06-12 Physical Target Availability Refresh 17:52

## Status

- Date: 2026-06-12 17:52 IST
- Coordinator commit: `10dfc6961af73d9cc90b28acfcd4ea6a7ba940fc`
- Branch: `codex/tagflow-native-runtime-master`
- Posture: read-only target availability audit; no profile probe, threshold,
  or performance claim

## Purpose

Refresh physical target availability before attempting any Tagflow supported
device profile qualification. A profile probe is only credible when the target
is visible as a normal connected physical device to Flutter and to platform
profiling tooling. Simulator debug route evidence, remembered wireless
devices, and offline CoreDevice records are not sufficient.

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

### Flutter

Flutter reported three connected devices:

- `iPhone 17` simulator
  `3BA9E377-4B6F-49A7-83FA-F640060D6442`
- `macOS`
- `Chrome`

Flutter reported one wirelessly connected iOS device:

- `Aryakumar Jha's iPad (wireless)` `00008120-0006395208E14032`

During the same scan, lower-level Apple discovery emitted repeated code `-27`
local-network browsing errors for remembered physical iOS devices, including
`Arya's Iphone 17`, `Dhanush's iPhone 12`, `Anup's iPad`,
`Arya's Iphone 15 Plus`, `Arya's iPhone`, and `Suny's iPhone`.

The `xcdevice` record for `Arya's Iphone 17`
`00008150-00110C960186401C` showed `platform: iphoneos`, `interface: usb`,
and `available: false`. It did not appear in Flutter's final connected-device
list.

### Xcode Instruments

`xcrun xctrace list devices` listed every physical iOS device under
`Devices Offline`, including:

- `Arya's Iphone 17 (27.0)` `00008150-00110C960186401C`
- `Aryakumar Jha's iPad (27.0)` `00008120-0006395208E14032`
- `Arya's Iphone 15 Plus (26.2)` `00008120-000849A00269A01E`
- `Arya's iPhone (18.7.2)` `00008020-0011493126B9002E`
- `Dhanush's iPhone 12 (17.4.1)` `00008101-000828640C63003A`
- `Suny's iPhone (26.3)` `00008120-001C58AE22A2201E`

Only the Mac appeared in the `Devices` section.

### CoreDevice

`xcrun devicectl list devices` reported:

- `Aryakumar Jha's iPad` as `available (paired)`
- `Arya's Iphone 17` as `unavailable`
- the remaining remembered physical devices as `unavailable`

Verbose CoreDevice state for the available iPad still showed it as a
local-network session rather than a ready USB profiling target:

- `transportType: localNetwork`
- `tunnelState: disconnected`
- `ddiServicesAvailable: false`
- `developerModeStatus: enabled`

Verbose CoreDevice state for `Arya's Iphone 17` showed:

- `pairingState: paired`
- no active `transportType`
- `tunnelState: unavailable`
- `ddiServicesAvailable: false`
- `developerModeStatus: enabled`

### Android And USB

`adb devices -l` returned only:

```text
List of devices attached
```

No Android target was attached.

The bounded USB report search returned no matching iPhone, iPad, Apple Mobile,
Android, Pixel, Samsung, or matching UDID rows.

## Qualification Result

No credible physical Tagflow profile probe is available from this machine at
this time.

- iOS is not credible because Flutter exposes no connected physical iPhone or
  iPad, `xctrace` lists every physical iOS device offline, the only
  CoreDevice-available iPad is a disconnected local-network session, and
  `Arya's Iphone 17` is unavailable in CoreDevice despite lower-level remembered
  USB metadata.
- Android is not credible because no physical Android target is attached.
- No profile command was run because the target state did not meet the minimum
  availability bar.

## Next Step

Do not run another physical Tagflow profile probe until a selected target is
visible as connected through both Flutter and platform profiling tooling.

For iOS, that means:

- the device appears in Flutter's connected physical-device list, not only as a
  wireless device or an `xcdevice` remembered record;
- `xcrun xctrace list devices` does not list the device under
  `Devices Offline`;
- CoreDevice does not report a disconnected local-network tunnel or unavailable
  DDI services for the active target.

If iOS remains inconsistent, attach a physical Android target and rerun this
availability audit before attempting a one-repeat profile baseline.
