# 2026-06-13 iPhone 17 Time Profiler Repeat-5

## Status

- Date: 2026-06-13 Asia/Kolkata
- Related gate: `physical-observed-profile`
- Device: `Arya's Iphone 17`
- UDID: `00008150-00110C960186401C`
- Device OS: iOS 27.0 `24A5355q`
- Host OS: macOS 27.0 `26A5353q`
- Xcode: `/Applications/Xcode-beta.app`, Xcode 27.0 `27A5194q`
- Posture: physical-device profile collection evidence for gate #75
- Claim boundary: local physical-device collection evidence only; no public
  performance threshold, frame-budget, faster/slower, memory, beta/stable, or
  package-page claim.

## App Host Fixes Required

The first Xcode-beta profile launch exposed two iOS host issues before usable
physical profile collection was possible:

- Xcode 27 rejected iOS deployment target `13.0`; the example app and pod
  targets were raised to iOS `15.0`.
- UIKit stopped the app with a runtime issue breakpoint for missing scene
  lifecycle adoption. The example app was migrated to Flutter's UIScene host
  shape:
  - `AppDelegate` now conforms to `FlutterImplicitEngineDelegate`;
  - plugin registration moved to `didInitializeImplicitFlutterEngine`;
  - `Info.plist` now declares `UIApplicationSceneManifest` with
    `UISceneDelegateClassName=FlutterSceneDelegate`.

The migration mirrors Flutter's own UIScene migrator and current Flutter docs
for `UIApplicationSceneManifest`.

## Device Qualification

With iPhone Mirroring disabled and Xcode-beta selected:

```text
flutter devices:
  Arya's Iphone 17 (mobile) - 00008150-00110C960186401C - ios - iOS 27.0 24A5355q

xcrun xctrace list devices:
  Arya's Iphone 17 (27.0) (00008150-00110C960186401C)

xcrun devicectl list devices:
  Arya's Iphone 17 - connected - iPhone 17 (iPhone18,3) - physical
```

## Flutter Run Result

`flutter run --profile` now builds, signs, installs, and launches the example
app without the earlier UIScene runtime breakpoint:

```bash
cd examples/tagflow
DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer \
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
  flutter run --profile --no-resident \
  -d 00008150-00110C960186401C \
  --no-pub
```

The remaining Flutter CLI failure is local toolchain infrastructure, not app
runtime failure: this Flutter checkout's bundled
`bin/cache/artifacts/libusbmuxd/iproxy` is x86_64-only, and Rosetta is not
installed on this Apple Silicon Mac. Flutter therefore cannot forward the
device VM service port after launch.

```text
Error: Flutter failed to run ".../libusbmuxd/iproxy ...".
The binary was built with the incorrect architecture to run on this machine.
```

Direct Xcode-beta device tooling was used for the physical profile evidence
below so the local `iproxy` architecture issue did not block collection.

## Install And Launch Evidence

```bash
mkdir -p build/benchmarks/device-probes/2026-06-13-iphone17-profile-r1

DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer \
  xcrun devicectl device install app \
  --device 00008150-00110C960186401C \
  examples/tagflow/build/ios/iphoneos/Runner.app \
  --json-output \
  build/benchmarks/device-probes/2026-06-13-iphone17-profile-r1/devicectl-install.json

DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer \
  xcrun devicectl device process launch \
  --device 00008150-00110C960186401C \
  --terminate-existing \
  --json-output \
  build/benchmarks/device-probes/2026-06-13-iphone17-profile-r1/devicectl-launch.json \
  dev.aryak.tagflow
```

Observed result:

```text
App installed:
  bundleID: dev.aryak.tagflow

Launched application with dev.aryak.tagflow bundle identifier.
```

## Repeat-5 Time Profiler Collection

Each run launched `dev.aryak.tagflow` through Instruments and recorded a
10-second Time Profiler trace on the physical iPhone.

```bash
out_dir=build/benchmarks/device-probes/2026-06-13-iphone17-profile-r1
for i in 1 2 3 4 5; do
  DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer \
    xcrun xctrace record \
    --template 'Time Profiler' \
    --device 00008150-00110C960186401C \
    --time-limit 10s \
    --output "$out_dir/tagflow-iphone17-time-profiler-launch-r${i}.trace" \
    --no-prompt \
    --launch -- dev.aryak.tagflow

  DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer \
    xcrun xctrace export \
    --input "$out_dir/tagflow-iphone17-time-profiler-launch-r${i}.trace" \
    --toc > "$out_dir/tagflow-iphone17-time-profiler-launch-r${i}-toc.xml"
done
```

Raw trace artifacts are intentionally under ignored `build/benchmarks/`.

TOC verification:

```text
r1: process=Tagflow pid=757 endReason="Time limit reached" duration=11.072852
r2: process=Tagflow pid=799 endReason="Time limit reached" duration=11.045138
r3: process=Tagflow pid=801 endReason="Time limit reached" duration=11.048843
r4: process=Tagflow pid=802 endReason="Time limit reached" duration=11.059180
r5: process=Tagflow pid=803 endReason="Time limit reached" duration=11.008906
```

All five TOCs identify:

```text
device platform=iOS
model=iPhone 17
name=Arya's Iphone 17
uuid=00008150-00110C960186401C
template-name=Time Profiler
time-limit=10 seconds
process type=launched
process name=Tagflow
return-exit-status=0
```

## Interpretation

The physical iPhone 17 path is now qualified for the `physical-observed-profile`
gate: the example app builds, signs, installs, launches, and records repeat-5
Time Profiler traces on the wired physical device through Xcode-beta.

This evidence does not make public benchmark claims. It also does not validate
the Flutter driver/VM-service profile harness on this Mac because Flutter's
bundled `iproxy` is x86_64-only and Rosetta is not installed.
