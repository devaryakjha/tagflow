# 2026-06-12 Physical Target Current Tool State

## Status

- Date: 2026-06-12 08:01 IST
- Worker commit: `c1595a26f71eeeb28d9d7d59e112fa4880fef70a`
- Branch context: contained by `codex/tagflow-native-runtime-master`
- Posture: negative qualification evidence only; no profile probe, threshold,
  or performance claim

## Purpose

Refresh the physical-target qualification blocker using the exact discovery
commands requested by the coordinator and the current local tool state.

A one-repeat physical profile probe is only credible when Flutter exposes a
real physical target as a normal connected device and the Apple or Android
profiling toolchain can treat that same target as available for install,
launch, and artifact collection.

## Commands

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH flutter devices
```

```bash
xcrun xctrace list devices
```

```bash
xcrun devicectl list devices
```

```bash
adb devices -l
```

## Observed State

### iOS

`flutter devices` reported only three connected targets:

- `iPhone 17` simulator `3BA9E377-4B6F-49A7-83FA-F640060D6442`
- `macOS`
- `Chrome`

The same command then reported two wireless-only iOS targets:

- `Arya’s Iphone 17 (wireless)` `00008150-00110C960186401C`
- `Aryakumar Jha’s iPad (wireless)` `00008120-0006395208E14032`

`flutter devices` also emitted repeated local-network browsing failures for
cached wireless devices and said those devices must be unlocked, cabled, or on
the same LAN with Developer Mode enabled.

`xcrun devicectl list devices` reported:

- `Arya’s Iphone 17` as `available (paired)`
- `Aryakumar Jha’s iPad` as `available (paired)`

`xcrun xctrace list devices` still listed both of those physical devices under
`Devices Offline`:

- `Arya’s Iphone 17 (27.0)` `00008150-00110C960186401C`
- `Aryakumar Jha’s iPad (27.0)` `00008120-0006395208E14032`

This is still inconsistent physical-device state. Flutter can remember the
UDIDs over wireless, and CoreDevice shows paired availability, but Apple’s
profiling tool still does not surface the same targets as online devices.

### Android

The exact required Android discovery command failed immediately:

```text
zsh:1: command not found: adb
```

No Android physical-target qualification evidence was produced from the
required command because `adb` is not on `PATH` in the current shell.

## Qualification Result

No credible one-repeat physical Tagflow profile probe should be run from this
state.

- iOS is not credible because Flutter still exposes the candidate iPhone and
  iPad only in its wireless bucket while `xctrace` still lists the same UDIDs
  under `Devices Offline`.
- CoreDevice `available (paired)` is not enough by itself to qualify a profile
  run when the profiling stack still disagrees about device availability.
- Android is not credible because the exact `adb devices -l` command is
  unavailable in the current environment, so no attached physical Android
  target can be qualified from this shell.
- No profile command was run. No `profile-baseline-manifest.json` was
  attempted or produced.

## Next Required Human Or Device Action

1. Connect the intended iPhone or iPad over USB, unlock it, trust this Mac,
   and keep Developer Mode enabled on-device.
2. Re-run the same discovery commands only after `flutter devices` lists the
   chosen iOS target under connected devices instead of only under the
   wireless bucket.
3. Confirm `xcrun xctrace list devices` no longer places that same UDID under
   `Devices Offline` before attempting any Tagflow profile probe.
4. If Android is the fallback path, add Android platform-tools to `PATH`,
   attach a real Android device, and re-run the exact `adb devices -l`
   command before any Tagflow benchmark run.

Until one platform satisfies those checks and can produce a normal
`profile-baseline-manifest.json`, Tagflow still has no supported physical
profile baseline.
