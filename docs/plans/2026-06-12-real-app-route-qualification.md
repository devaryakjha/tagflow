# Real App Route Qualification Plan

## Status

- Date: 2026-06-13 Asia/Kolkata
- Branch: `codex/tagflow-native-runtime-master`
- Draft review PR: https://github.com/devaryakjha/tagflow/pull/72
- Gate tracker: https://github.com/devaryakjha/tagflow/issues/73
- Scope: qualify a public, reviewable Flutter route for native-runtime alpha
  evidence

This plan does not authorize publishing, tagging, package-version changes,
beta wording, performance claims, or private downstream app changes.

## Goal

Prove that Tagflow's native-runtime API can render app-owned rich content
through a real Flutter navigation route that reviewers can inspect from this
repository.

The owner clarified that proprietary downstream app code must not be used as
the public review artifact for this package. The qualifying route is therefore
the package-owned `examples/tagflow` route at `/reference-app-route`.

## Qualification Contract

The public route qualifies when all of these are true:

- the route is reachable through normal Flutter app navigation;
- content is app-authored and deterministic, not copied from private app data;
- rendering uses `Tagflow.document(...)` or `Tagflow.html(...)` with the
  semantic registry path instead of `package:tagflow/legacy.dart`;
- app-owned link, media, unsupported-content, and extension behavior is visible;
- a runtime document update path is covered;
- tests exercise the route and its expected app-owned interactions;
- evidence is recorded without benchmark or memory claims unless separate
  qualified benchmark evidence exists.

## Selected Route

Route:

```text
examples/tagflow -> /reference-app-route
```

Source:

```text
examples/tagflow/lib/screens/reference_app_route_screen.dart
examples/tagflow/test/reference_app_route_test.dart
```

Evidence:

```text
docs/validation/evidence/2026-06-13-reference-app-route.md
```

The route renders a neutral release-readiness brief with:

- structured `TagflowDocument` content;
- semantic table extension rendering through `tagflowTableComponents(...)`;
- app-owned link handling;
- app-owned media placeholders;
- unsupported-content placeholders;
- controlled HTML with policy restrictions;
- a `TagflowDocumentPatch` CMS update from `cms-rev-1` to `cms-rev-2`.

## Private App Boundary

Do not rely on proprietary downstream app changes, screenshots, route logs, or
source-control packets as public Tagflow gate evidence.

Private downstream validation can still inform owner confidence, but it must
not be required for PR #72 review, package publication, or public release notes
unless the owner explicitly approves a sanitized public artifact.

## Reporting

When the route validates, update #73 with:

- route name and path;
- source and test files;
- exact validation command and result;
- statement that the route is package-owned and contains no proprietary app
  code;
- explicit statement that performance evidence is separate from #73.

## Stop Rules

Do not reopen proprietary app integration as the default #73 path.

Do not mark #75, release approval, beta/stable wording, public benchmark
claims, frame-budget claims, memory claims, publishing, PR #72 undraft, or PR
merge as satisfied from this route.
