# 2026-06-12 Observed-Host Native JSON Repeat-5 Stall

## Status

- Date: 2026-06-12 Asia/Kolkata
- Collection commit: `ebc13572811e8bc4d2763596882c8d5b5bc2475b`
- Branch context: `codex/tagflow-native-runtime-master`
- Run id: `2026-06-12-observed-host-native-json-repeat5-r1`
- Posture: stalled diagnostic attempt; not observed-host profile evidence,
  reference-runner evidence, physical-device evidence, beta evidence, stable
  evidence, or frame-budget evidence

## Purpose

Attempt to strengthen the one-repeat observed-host native JSON profile probe
with a repeat-5 collection on the current macOS host, without promoting the
host to reference-runner status.

## Command

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_DEVICE=macos \
TAGFLOW_PROFILE_PAIR=tagflow_native_json:native_ai_answer \
TAGFLOW_PROFILE_REPEAT=5 \
TAGFLOW_PROFILE_CONTINUE_ON_FAILURE=true \
TAGFLOW_PROFILE_RUN_ID=2026-06-12-observed-host-native-json-repeat5-r1 \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-observed-host \
dart run melos run benchmark:profile:baselines
```

## Observed Result

- The first repeat built the macOS profile app.
- The integration driver connected to the Flutter application.
- The run then stopped producing benchmark output after:

```text
flutter: 00:00 +0: scrolls a Tagflow benchmark fixture
VMServiceFlutterDriver: Connected to Flutter application.
```

- The run was interrupted after approximately three minutes with exit status
  `130`.
- No files were produced under:

```text
build/benchmarks/profile-observed-host/2026-06-12-observed-host-native-json-repeat5-r1/
```

- A follow-up process check found no stale profile app, profile driver, Melos
  benchmark, or Flutter drive processes for this run.

## Interpretation

This attempt does not count as observed-host profile evidence. The only
successful observed-host native JSON profile evidence currently remains the
one-repeat probe recorded in
`docs/benchmarks/baselines/2026-06-12-observed-host-native-json-probe.md`.

The physical or observed-host profile gate remains open. This stalled attempt
does not support physical-device readiness, reference-runner readiness, public
benchmark ranking, comparative performance wording, frame-budget readiness,
memory wording, beta promotion, or stable release claims.

Recommended next diagnostics:

1. Re-run a one-repeat observed-host probe before attempting repeat-5 again.
2. Add profile-runner stall detection or a per-repeat timeout before relying on
   unattended repeat-5 observed-host collection.
3. Keep current host evidence report-only unless the run satisfies the
   reference-runner policy or an owner-approved observed-host waiver is added.
