# 2026-06-13 Reference App Route Evidence

## Status

- Date: 2026-06-13 Asia/Kolkata
- Related gate: #73 real-app route evidence
- Route: `examples/tagflow` -> `/reference-app-route`
- Source file:
  `examples/tagflow/lib/screens/reference_app_route_screen.dart`
- Test file:
  `examples/tagflow/test/reference_app_route_test.dart`
- Posture: public package-owned route evidence only; no proprietary app code,
  private screenshots, beta/stable release approval, publishing approval, or
  performance claim

## Purpose

Replace proprietary downstream app evidence with a reviewable route inside the
Tagflow example app. This route is intentionally app-shaped: it has Flutter
navigation, app-owned rich content, app-owned link handling, image and
unsupported-content overrides, semantic table extension rendering, controlled
HTML policy, and a runtime content update.

This route is not performance evidence. Physical-device, observed-host,
frame-budget, memory, beta/stable, and comparative claims remain governed by
their separate gates.

## Route Contract

The route exercises the native runtime public surface through:

- `Tagflow.document(...)` for app-authored structured content;
- `Tagflow.html(..., registry: ...)` for controlled legacy HTML content;
- `TagflowComponentRegistry` with `tagflowTableComponents(...)`;
- app-owned overrides for links, images, and unsupported content;
- `TagflowDocumentPatch` updates to simulate a CMS revision;
- routed access through the example app home screen.

The content is neutral demo content owned by this package. It does not depend
on confidential downstream app source code or private screenshots.

## Validation

Focused validation command:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
  flutter test examples/tagflow/test/reference_app_route_test.dart
```

Expected coverage:

- the home route opens `Reference App Route`;
- the page renders the initial `cms-rev-1` document;
- the semantic table, media placeholder, and unsupported placeholder render;
- app-owned link taps are recorded;
- the CMS update action applies a document patch and advances to `cms-rev-2`.

## Gate Interpretation

This evidence is sufficient for #73 because the owner rejected using
proprietary downstream app changes as public review evidence and directed the
package to provide a detailed example app route instead.

This route evidence is not #75 profile evidence and does not authorize public
performance claims, package publishing, beta/stable wording, or PR #72
undraft/merge by itself.
