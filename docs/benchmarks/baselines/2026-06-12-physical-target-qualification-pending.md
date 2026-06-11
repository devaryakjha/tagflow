# Physical Target Qualification Pending

## Status

- Date: 2026-06-12 Asia/Kolkata
- Commit: `0a6a0c2cf03f4a7bbf38c02fa458c504c7facc85`
- Branch: `codex/tagflow-native-runtime-master`
- Posture: evidence note only, not a benchmark claim or threshold change

## Purpose

Record the current physical iOS/Android target audit for the Tagflow native
runtime benchmark qualification flow.

This note exists because the repo toolchain did not expose a usable physical
target for the required one-repeat probe. It does not alter benchmark
thresholds, public performance claims, or package versions.

## Device Audit

Command:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH flutter devices
```

Observed output summary:

- Connected devices listed by Flutter:
  - `iPhone 17` simulator `3BA9E377-4B6F-49A7-83FA-F640060D6442`
  - `macOS` desktop `macos`
  - `Chrome` web `chrome`
- Wirelessly connected devices listed by Flutter:
  - `Arya’s Iphone 17 (wireless)` `00008150-00110C960186401C`
  - `Aryakumar Jha’s iPad (wireless)` `00008120-0006395208E14032`
- Flutter reported LAN discovery errors for the wireless iOS devices and
  similar entries:
  - `Browsing on the local area network ...`
  - `The device must be opted into Developer Mode to connect wirelessly.`
  - exit code `-27`

The coordinator checkout re-ran the same command before integration and saw
the same usable-device classification: no wired physical iOS or Android target
was available for the profile probe.

## Qualification Result

No physical iOS or Android target was usable for a profile-mode probe:

- device missing: no wired physical iOS or Android target was listed as usable
- wireless-only iOS: the visible wireless iOS devices were blocked by LAN
  discovery / Developer Mode errors
- install failure: not reached, because no usable physical target was available
- app launch timeout: not reached
- missing `integration_response_data.json`: not reached
- failed scroll: not reached
- OOM or process termination: not reached
- missing viewport or frame metadata: not reached

## Interpretation

Physical-target qualification remains pending until a real iOS or Android
device is available and Flutter can launch the profile harness on it. The next
benchmark slice should start with the required one-repeat probe and then a
`TAGFLOW_PROFILE_MIN_REPEATS=1` check only after the device is actually usable.
