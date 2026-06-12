# 2026-06-12 Kite IPO Profile Evidence Blocked

This note records the current state of real-app profile evidence for Tagflow in
Kite's production IPO surface. It is blocker evidence, not a benchmark result.

The source audit was performed in the Kite worktree
`/Users/arya/.codex/worktrees/4776/kite` and committed there as
`93881038d1b9bfa924762d2b09bf6dadd849c5a9`. That commit was not pushed or
integrated into Kite; this Tagflow note captures the coordinator-relevant
benchmark conclusion.

## Status

- No credible real-app production IPO profile capture exists from this pass.
- The current Kite checkout used for the audit was stale relative to the hosted
  alpha validation slice:
  - `pubspec.yaml` declared hosted `tagflow: 0.0.8`
  - `pubspec.yaml` declared hosted `tagflow_table: 0.0.4+5`
  - `pubspec.lock` resolved those same hosted versions
- The earlier hosted-alpha validation slice exists in Kite history at
  `be97da15 test(ipo): validate hosted tagflow alpha3`, where the app resolved
  hosted `tagflow 1.0.0-alpha.3` and `tagflow_table 1.0.0-alpha.1`.
- Kite's current production IPO sheet still renders through the legacy
  converter bridge, not a converter-free native runtime production path.

## Surface Separation

The audit separated four surfaces that must not be conflated:

1. Hosted alpha dependency and widget-test evidence exists from Kite commit
   `be97da15`.
2. Production IPO rendering in the audited checkout still uses
   `Tagflow(html: ...)` with legacy custom converters.
3. Converter-free built-in `details` / `summary` evidence exists in the Kite
   widget-test harness from `be97da15`.
4. Real-app profile-mode evidence for the production IPO surface is still
   missing.

## Blockers

### Stale Dependency State

The audited Kite checkout did not include the hosted-alpha dependency update or
the focused IPO widget tests from `be97da15`. A profile pass intended to measure
the hosted alpha line must first restore the minimal hosted-alpha dependency
slice.

### Production Path Still Uses Legacy Bridge

The production IPO sheet renders `store.ipoInfo.excerpt` and
`store.ipoInfo.content` through `Tagflow(html: ...)` plus custom legacy
converters for summary, details, table, and table cells. Any profile capture on
that production path should be described as legacy-bridge evidence unless a
separate migration task changes the production surface.

### No Deterministic Production Fixture Opener

The audited checkout did not contain a committed production-route tool that
opens a reviewed IPO fixture inside the real app. The credible route remains:
authenticate into the real app, open IPOs, select a production IPO instrument,
and open `IPOInstrumentSheet`.

### Physical Target Tooling Is Not Stable Enough

Observed target audit:

- `fvm flutter devices -v` saw a booted simulator and physical iPhone/iPad
  targets only as wireless devices.
- `xcrun xctrace list devices` listed the same physical devices under
  `Devices Offline`.
- `xcrun xcdevice list` and `xcrun devicectl list devices` saw the iPhone as
  available/booted, but `devicectl` reported `transportType: localNetwork` and
  `ddiServicesAvailable: false`.

The simulator is not credible iOS profile evidence for this task, and the
physical target path is not yet stable across Flutter and Instruments.

## Required Next Run

The next credible profile attempt should:

1. Restore only the minimal hosted-alpha dependency/test slice from Kite commit
   `be97da15` if the target is hosted `tagflow 1.0.0-alpha.3`.
2. Use the real app entrypoint, not `lib/main_local.dart`.
3. Run on a physical iPhone visible to both Flutter and Instruments, preferably
   over a stable wired session.
4. Start from a real authenticated app session or a reviewed dev-session import.
5. Navigate to a real production IPO instrument and open `IPOInstrumentSheet`.
6. Label the result as legacy-bridge profile evidence unless the production IPO
   rendering path is migrated in a separate change.

## Interpretation

This blocker narrows the real-app performance evidence gap. It does not replace
the older debug probe, and it does not support any public performance claim.

## Coordinator Recheck

After the coordinator branch reached `ee32ef5`, the master thread rechecked the
current local Kite and external gate state.

Current Kite state is no longer the stale dependency state from the original
audit:

- `/Users/arya/projects/kite` is on `feat/dashboard` at local commit
  `80160401 test(ipo): validate hosted tagflow alpha3`, one commit ahead of
  `origin/feat/dashboard`.
- Local branch `codex/ipo-tagflow-registry-content` points at
  `6d0d29f8 test(ipo): avoid tagflow table internals` and contains
  `e26a14e6 feat(ipo): render ipo content through tagflow registry`.
- That branch is still local-only. `gitlab.zerodha.tech` DNS resolution still
  fails with `gaierror: [Errno 8] nodename nor servname provided, or not known`.

Current profile blockers remain:

- The registry content branch is not pushed, merged, or validated through a
  real route.
- Physical iOS tooling still lists physical devices under `Devices Offline`,
  and `Arya's Iphone 17` still appears through CoreDevice as local-network with
  a disconnected tunnel and unavailable DDI services.
- No physical Android target is attached.

Therefore the next credible Kite profile run is still gated on GitLab access,
real-route validation of the registry-content branch, and a supported profile
target. Widget-test evidence and local branch preparation are not production
profile evidence.
