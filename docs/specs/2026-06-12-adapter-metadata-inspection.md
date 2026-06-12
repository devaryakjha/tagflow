# Tagflow Adapter Metadata Inspection SPEC

**Status:** Proposed narrow integration slice
**Last Updated:** 2026-06-12
**Target Release Line:** post-`1.0.0-alpha.3` stabilization
**Primary Audience:** Tagflow runtime, adapter, docs, and example-app workers

## 1. Problem Statement

The current native rich-content path is already good at rendering and patching:

- `TagflowNativeBlockCodec` decodes trusted JSON-like content
- `TagflowNativeBlockAdapter` maps that content into `TagflowDocument`
- `TagflowDocumentPatch` applies partial updates
- `TagflowViewOptions.nodeTapCallback` lets Flutter apps attach native tap
  behavior outside the payload

The remaining app-integration friction is not rendering. It is inspection.
Real apps still need to route actions, log diagnostics, and migrate controlled
HTML toward native content, but today they do that by reaching into raw
metadata maps with private string keys such as `blockAttributes`, `blockKind`,
`htmlAttributes`, and `policyDecisionReason`.

That is the wrong next abstraction to freeze:

- routing should stay app-owned, not move into Tagflow
- revision/conflict enforcement should stay app- or backend-owned
- content payloads must remain data-only
- adapter metadata should still be inspectable through stable public helpers

## 2. Audit Summary

### Routing actions

The current native JSON example stores app action identifiers in
`blockAttributes['actionId']` and routes them inside a view-owned tap callback.
That is the correct ownership boundary. Tagflow should not add a router,
command registry, or executable action payload model.

### Partial updates

Patch envelopes already carry `id`, `schemaVersion`, optional `baseRevision`,
optional `revision`, and ordered operations. Applying patches is covered.
Revision matching and conflict handling are still outside Tagflow and should
remain there for now.

### Selection and tap metadata

The current callback surface is sufficient: `BuildContext` plus the tapped
`TagflowDocumentNode`. The missing piece is a public way to inspect
adapter-origin metadata without stringly typed casts.

### Fallback semantics

Fallback behavior is already adapter-owned and data-only:

- HTML policy can drop or preserve an `unsupported` placeholder
- native block URL policy can preserve reason metadata on link/container or
  `unsupported` placeholder nodes
- renderer fallback is separate from transport compatibility

Apps need read-only access to those diagnostics, not a new fallback framework.

### Migration from HTML

Controlled HTML already has the right migration path:

- authored `data-tagflow-id` for stable IDs
- `TagflowHtmlNodeIdStrategy.attribute(...)` for fail-fast identity
- node taps attached at the view level

What is missing is a public helper for reading sanitized HTML attributes and
original HTML tags from the adapted runtime node.

## 3. Decision

Add adapter-scoped metadata inspectors as the smallest next integration slice.

This slice should expose read-only helpers for:

- native document schema/revision metadata
- native node block kind and block attributes
- HTML node tag and sanitized attributes
- policy decision diagnostics already preserved in metadata

This improves app integration while keeping routing, revision enforcement,
selection UX, and fallback presentation outside the core runtime API.

## 4. Non-Goals

- A router, command registry, or action disposition API
- Revision enforcement in `TagflowDocument.applyPatches(...)`
- Selection, copy/paste, or long-press APIs
- A generic metadata schema layered into the runtime core
- Executable callbacks inside HTML or native JSON payloads

## 5. Public API Shape

Illustrative shape:

```dart
extension TagflowNativeBlockDocumentMetadata on TagflowDocument {
  int? get nativeBlockSchemaVersion;
  String? get nativeBlockRevision;
}

extension TagflowNativeBlockNodeMetadata on TagflowDocumentNode {
  String? get nativeBlockKind;
  Map<String, Object?> get nativeBlockAttributes;
  String? get nativeBlockPolicyDecisionReason;
}

extension TagflowHtmlNodeMetadata on TagflowDocumentNode {
  String? get htmlTag;
  Map<String, String> get htmlAttributes;
  String? get blockedHtmlTag;
  String? get htmlPolicyDecisionReason;
}
```

Constraints:

- helpers are additive and read-only
- helpers do not move metadata into constructor fields on runtime nodes
- helpers stay adapter-owned rather than widening the generic runtime layer
- missing metadata returns `null` or `{}` instead of throwing

## 6. Acceptance Checks

- The native JSON example routes taps using `nativeBlockAttributes` rather than
  raw metadata key strings.
- Public API tests compile these helpers from `package:tagflow/tagflow.dart`.
- HTML adapter tests cover `htmlTag` / `htmlAttributes`.
- Native block adapter tests cover schema revision, original block kind, block
  attributes, and policy diagnostics.
- Docs state explicitly that routing and revision enforcement remain outside
  Tagflow.
