# 2026-06-12 Kite IPO Native Route Local Migration

## Status

- Date: 2026-06-12 Asia/Kolkata
- Related gate: #73 real-app route evidence
- Downstream repo: `/Users/arya/projects/kite`
- Downstream branch: `codex/tagflow-ipo-native-route`
- Downstream commits:
  - `355c79d6 feat(ipo): render IPO content through tagflow registry`
  - `e9a86803 test(ipo): cover tagflow sheet registry path`
- Posture: local supporting code evidence only; not #73 closure

## Purpose

Record the local Kite production-route migration and supporting production
sheet widget evidence prepared for the Tagflow native-runtime real-app gate.

This evidence moves the strongest known downstream candidate closer to the #73
contract: Kite's IPO sheet production rich-content route no longer depends on
`package:tagflow/legacy.dart` in the changed file and now renders through the
hosted/current `Tagflow.html(..., registry: ...)` public path.

It does not close #73 because the route is not pushed or reviewable through
Kite's intended GitLab path from this machine, and the migrated route has not
yet been opened through the real app navigation path with live app data/auth
constraints.

## Local Change

Changed downstream production file:

```text
/Users/arya/projects/kite/lib/screens/ipos/ipo_instrument_sheet.dart
```

Summary of the local Kite commit:

- replaces `import 'package:tagflow/legacy.dart';` with
  `import 'package:tagflow/tagflow.dart';`;
- adds a `TagflowComponentRegistry` with `tagflowTableComponents(...)`;
- migrates the IPO excerpt renderer from legacy `Tagflow(...)` plus
  `TagflowSummaryConverter` / `TagflowDetailsConverter` to
  `Tagflow.html(..., registry: tagflowRegistry())`;
- migrates the main IPO content renderer from legacy `Tagflow(...)` plus
  selector converters to `Tagflow.html(..., registry: tagflowRegistry())`;
- preserves the mobile render boundary using
  `TagflowRenderBoundary.comment(start: '[start-of-mobile]', end:
  '[end-of-mobile]')`;
- preserves main-content link handling through
  `TagflowViewOptions.linkTapCallback`.

The old Kite legacy converter component still exists elsewhere in the app, but
the changed IPO production sheet route no longer imports or calls it.

Added supporting downstream test coverage:

```text
/Users/arya/projects/kite/test/ipos/tagflow_hosted_alpha3_test.dart
```

The new test seeds `KiteStore` from the real `docs/ipo-info.md` payload, pumps
the production `IPOInstrumentSheet` under `StoreKeeper`, cancels the
`GetIPOInfo` network mutation to keep the harness deterministic, and verifies
that the real IPO content and table extension render through the sheet's
production `Tagflow.html(..., registry: tagflowRegistry())` path.

This is stronger than the direct `Tagflow.html` fixture test because it
exercises the migrated sheet code. It is still widget-harness evidence, not
real app-route qualification.

## Verification

Focused hosted-alpha widget/native transport validation passed after the local
production-sheet migration and supporting sheet-path test:

```bash
cd /Users/arya/projects/kite
PATH=/Users/arya/fvm/default/bin:$PATH \
  flutter test test/ipos/tagflow_hosted_alpha3_test.dart
```

Result:

```text
00:00 +3: All tests passed!
```

Focused analysis also passed:

```bash
cd /Users/arya/projects/kite
PATH=/Users/arya/fvm/default/bin:$PATH \
  flutter analyze \
    lib/screens/ipos/ipo_instrument_sheet.dart \
    test/ipos/tagflow_hosted_alpha3_test.dart
```

Result:

```text
No issues found!
```

Both commands emitted Flutter plugin warnings about packages that do not yet
support Swift Package Manager. Those warnings were not caused by this change
and did not fail validation.

## Review

A delegated read-only review checked the production migration diff against the
#73 route migration scope and reported file-level PASS:

- IPO sheet imports `package:tagflow/tagflow.dart`;
- excerpt and main content both use `Tagflow.html(..., registry: ...)`;
- table extension wiring uses `tagflowTableComponents(...)`;
- mobile render boundary and link handling are preserved;
- no `legacy`, `converters:`, or legacy converter references remain in
  `ipo_instrument_sheet.dart`.

The same review flagged medium overclaim risk if this were presented as closing
#73. This note keeps it as supporting evidence only.

A second delegated read-only review checked the supporting test diff and
reported PASS with caveats:

- the test pumps the real `IPOInstrumentSheet`;
- the test seeds `KiteStore` with real IPO payload fields from `docs/ipo-info.md`;
- the test lets `IPOInstrumentSheet.initState()` attempt `GetIPOInfo()` and
  cancels that mutation through a `StoreKeeper` interceptor;
- the test exercises both migrated production sheet render sites that call
  `Tagflow.html(..., registry: tagflowRegistry())`;
- the review explicitly warned not to claim network fetch, route navigation,
  bottom-sheet behavior, profile performance, or #73 closure from this evidence.

## Remaining #73 Gaps

The gate remains open until all of these are true:

- Kite branch is pushed, merged, or otherwise reviewable through Kite's
  intended source-control path;
- the intended IPO sheet route is opened through the real app path with real
  fixture/data/auth constraints;
- package resolution is rechecked from the downstream app state with no local
  Tagflow path overrides;
- Tagflow PR/docs describe the result factually and without performance claims.

Current GitLab status from this machine remains blocked:

```bash
GIT_SSH_COMMAND='ssh -o BatchMode=yes -o ConnectTimeout=10' \
  git -C /Users/arya/projects/kite ls-remote --heads origin HEAD
```

Result:

```text
ssh: Could not resolve hostname gitlab.zerodha.tech: nodename nor servname provided, or not known
fatal: Could not read from remote repository.
```

GitLab access is not a Tagflow requirement. It is only relevant if Kite remains
the selected downstream route. An approved equivalent real Flutter app route can
still satisfy #73.
