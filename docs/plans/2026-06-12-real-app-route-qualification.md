# Real App Route Qualification Plan

## Status

- Date: 2026-06-12
- Branch: `codex/tagflow-native-runtime-master`
- Draft review PR: https://github.com/devaryakjha/tagflow/pull/72
- Gate tracker: https://github.com/devaryakjha/tagflow/issues/73
- Scope: qualify one real Flutter app route for the hosted native-runtime alpha

This plan does not authorize publishing, tagging, package-version changes,
beta wording, performance claims, or a local-path downstream validation.

## Goal

Prove that the hosted Tagflow native-runtime alpha can render a real app-owned
rich-content route through the intended app path, with real data/auth
constraints and a reviewable source-control trail.

This gate is intentionally narrower than general compatibility testing. Widget
tests, example-app routes, adapter packages, and simulator smoke evidence can
support the decision, but they do not close the gate by themselves.

## Current Read

Latest coordinator audit found no route satisfying #73 as-is.

- Kite is the strongest candidate. It depends on hosted
  `tagflow ^1.0.0-alpha.3` and `tagflow_table ^1.0.0-alpha.1`. A local
  supporting branch now migrates the production IPO sheet file off
  `package:tagflow/legacy.dart` and onto `Tagflow.html(..., registry: ...)`,
  with a supporting production-sheet widget test that pumps
  `IPOInstrumentSheet` using real IPO fixture content. That branch is still not
  pushed or reviewable through Kite's intended source-control path. Its
  intended GitLab review path is not reachable from this machine because
  `gitlab.zerodha.tech` DNS fails.
- Varsity has real rich-content routes, but it is still on old
  `tagflow ^0.0.7`, so it does not validate the current hosted native runtime.
- Seisei provides package-adapter evidence, not a real downstream app route
  with an intended user path.

The Kite hosted-alpha widget/native-transport tests are useful supporting
evidence, including the production-sheet widget harness. They prove the hosted
packages can decode and render targeted fixtures and that the migrated sheet
code can render seeded real IPO content in a harness; #73 requires an approved
real app path.

The local Kite production-file migration is recorded in
`docs/validation/evidence/2026-06-12-kite-ipo-native-route-local.md`. It is
supporting code evidence only and does not close #73.

## Qualification Contract

One route qualifies only when all of these are true:

- the owner approves the route or provides an equivalent real Flutter app
  route;
- the app resolves `tagflow` and any first-party extension packages from the
  hosted prerelease line, not from `dependency_overrides` or local paths;
- the route uses the native-runtime public path, such as `Tagflow.document(...)`
  or `Tagflow.html(...)` with the semantic registry path, rather than
  `package:tagflow/legacy.dart`;
- the route opens through the intended app navigation path with real fixture,
  auth, or data constraints documented;
- any behavior deltas from the current production renderer are reviewed and
  either fixed or explicitly accepted;
- the integration is pushed, merged, or otherwise reviewable through the app's
  intended source-control path;
- evidence is recorded without benchmark or memory claims unless separate
  qualified benchmark evidence exists.

## Kite Candidate Slice

If Kite is approved, keep the integration slice focused on the IPO sheet.

Implementation scope:

- use the local Kite branch `codex/tagflow-ipo-native-route` and commits
  `355c79d6` plus `e9a86803` as the starting point;
- push or recreate that focused change through Kite's normal source-control
  path;
- keep the production IPO sheet off `package:tagflow/legacy.dart`;
- keep the IPO rich-content body on hosted
  `Tagflow.html(..., registry: ...)` or an equivalent `TagflowDocument` path
  using
  `tagflowTableComponents(...)` where table behavior is required;
- preserve the existing app-owned link handling, theme constraints, loading
  states, and unsupported-content policy unless a behavior delta is accepted;
- keep the current hosted-alpha widget/native-transport tests as supporting
  evidence, not as the route gate itself;
- verify the lockfile resolves hosted `tagflow 1.0.0-alpha.3` and
  `tagflow_table 1.0.0-alpha.1` without local overrides.

Route evidence to capture:

- route name and navigation path;
- package-resolution proof from `pubspec.lock`;
- command output for the focused app validation used by Kite;
- screenshot or log evidence showing the real IPO sheet path rendered through
  the migrated code;
- source-control link once GitLab/DNS access is available.

## Equivalent App Route

If Kite remains blocked, another real Flutter app route can satisfy #73 when it
meets the same qualification contract.

The replacement route should be app-owned content with low release blast radius,
such as a help article, product update, AI answer detail, announcement, or
controlled CMS body. It should include enough structure to exercise paragraphs,
headings, inline emphasis, links, lists, and at least one extension-backed or
unsupported block if the production surface uses those features.

## Stop Rules

Stop and leave #73 open if any of these are true:

- the route is only a widget test, diagnostics page, package adapter, or
  Tagflow example-app route;
- the app uses local path overrides for Tagflow;
- production rendering still depends on `package:tagflow/legacy.dart`;
- source data is dummy content when the gate claims real fixture/data coverage;
- app source control cannot be reached and no equivalent reviewable route is
  approved;
- the only available evidence is simulator/profile smoke without a real app
  route.

## Reporting

When a route qualifies, update #73 with:

- approved route and app;
- hosted package versions;
- source-control link;
- exact validation commands and results;
- fixture/data/auth constraints;
- screenshots or logs if captured;
- any accepted behavior deltas;
- explicit statement that performance evidence is tracked separately in #74.

Until then, PR #72 should remain draft and should describe #73 as open.
