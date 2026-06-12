# Tagflow Node Interaction Callbacks SPEC

**Status:** Implemented first slice; follow-ups open
**Last Updated:** 2026-06-12
**Target Release Line:** post-`1.0.0-alpha.3` stabilization
**Primary Audience:** Tagflow runtime, renderer, adapter, and example-app
workers

## Implementation Status

The first node-tap slice landed on the coordinator branch in
`848f1fc feat(runtime): add node tap callbacks`:

- `TagflowNodeTapCallback` and `TagflowNodeTapDetails` are public through
  `package:tagflow/tagflow.dart`.
- `TagflowViewOptions` now carries `nodeTapCallback` and `tapTargetKinds`.
- Legacy `TagflowOptions` mirrors those fields through
  `fromViewOptions(...)`, `toViewOptions()`, `copyWith(...)`, equality props,
  and `TagflowScope`.
- `TagflowComponentRegistry.render(...)` wraps rendered output for opted-in
  non-link node kinds, after built-in, extension, or app override dispatch.
- `TagflowNodeKind.link` preserves the existing `linkTapCallback` path and
  does not fire both link and node callbacks in this first slice.
- Opted-in non-link node tap targets expose button-like semantics while
  preserving child labels and dispatching semantics tap actions through the
  same view-owned callback.
- Focused tests cover default inert non-link nodes, opted-in
  `Tagflow.document(...)` nodes, semantics-action activation for opted-in
  document and HTML-adapted nodes, opted-in `Tagflow.html(...)` nodes with
  authored IDs and metadata, link behavior preservation, legacy option
  conversion, and public export reachability.
- The roadmap item `Custom tap handlers per element type` is checked. Long
  press, broader gesture recognition, selection, copy/paste, and a unified
  action disposition model remain open.

## 1. Problem Statement

Tagflow now renders a source-agnostic `TagflowDocument` through semantic node
kinds. That makes it useful for AI, CMS, and app-authored rich content, but the
runtime still exposes only one built-in interaction callback: link taps.

Flutter apps need richer native behavior without pushing executable callbacks
into content payloads. Common examples:

- tapping a `callout` or `container` node to open an app sheet
- tapping a paragraph or heading to reveal actions
- tapping app-authored table/list nodes for diagnostics or navigation
- treating AI-produced structured blocks as native UI targets instead of HTML
  anchors

The interaction model must stay runtime-owned and Flutter-native. Documents,
HTML, native block JSON, and patches remain data-only.

## 2. Decision

Add a first-class node tap callback to `TagflowViewOptions`, gated by an
explicit set of semantic node kinds.

The callback is view-owned:

- `TagflowDocumentNode` does not store callbacks.
- `TagflowNativeBlock` and native JSON transport do not encode callbacks.
- HTML adapter metadata can help identify source tags, but it does not install
  executable behavior.
- Apps opt into tappable node kinds per `Tagflow` view.

The renderer wraps matching nodes after registry dispatch, so app overrides,
extension components, and built-in components all share the same interaction
surface.

## 3. Goals

- Support custom tap handlers per semantic node kind.
- Keep document and adapter payloads immutable, serializable, and data-only.
- Preserve existing `linkTapCallback` behavior.
- Make node identity available to the callback through the tapped
  `TagflowDocumentNode`.
- Keep the first slice narrow enough to validate with widget tests.
- Avoid a general action system until real app integration proves the required
  disposition, async, and accessibility semantics.

## 4. Non-Goals

- Long press, drag, hover, focus, selection, or copy/paste.
- Encoding executable actions in native JSON or HTML metadata.
- A navigation/router abstraction.
- A command registry, action disposition model, or async event pipeline.
- Changing link tap callback semantics.
- Making every node tappable by default.

## 5. Public API Shape

The first implementation slice should add these public concepts:

```dart
typedef TagflowNodeTapCallback =
    void Function(TagflowNodeTapDetails details);

final class TagflowNodeTapDetails {
  const TagflowNodeTapDetails({
    required this.context,
    required this.node,
  });

  final BuildContext context;
  final TagflowDocumentNode node;
}

final class TagflowViewOptions {
  const TagflowViewOptions({
    ...
    this.nodeTapCallback,
    this.tapTargetKinds = const {},
  });

  final TagflowNodeTapCallback? nodeTapCallback;
  final Set<TagflowNodeKind> tapTargetKinds;
}
```

`TagflowOptions` should mirror these fields as the legacy compatibility wrapper,
and `TagflowOptions.fromViewOptions(...)` / `toViewOptions()` must preserve
them.

Naming can change during implementation review if a clearer Dart API emerges,
but these constraints are normative:

- the callback receives the full runtime node
- the callback receives a Flutter `BuildContext`
- tapping is opt-in by `TagflowNodeKind`
- default options preserve current behavior exactly

## 6. Rendering Semantics

`TagflowComponentRegistry.render(...)` is the right wrapper boundary because it
sees every semantic node, including app override output and extension registry
output.

A node is tappable when:

- `TagflowViewOptions.nodeTapCallback` is non-null
- `TagflowViewOptions.tapTargetKinds` contains `node.kind`
- the node kind is safe for the first slice

For the first slice, `TagflowNodeKind.link` must continue to use the existing
link component and `linkTapCallback`. If an app includes `link` in
`tapTargetKinds`, the implementation should prefer preserving existing link tap
behavior over firing both callbacks. A unified action-disposition API can revisit
link/node composition later.

Recommended wrapper behavior:

- wrap the rendered node with `GestureDetector`
- use `HitTestBehavior.translucent`
- add `MouseRegion(cursor: SystemMouseCursors.click)` for pointer platforms
- add basic button-like semantics when doing so does not destroy child
  semantics; widget tests must prove the resulting semantics tap action reaches
  the same `TagflowNodeTapCallback`

## 7. Adapter Semantics

HTML adapter:

- `<div data-tagflow-id="card">...</div>` can become a `container` node with a
  stable ID.
- Apps can opt into `TagflowNodeKind.container` taps and inspect
  `details.node.metadata['htmlAttributes']` when needed.
- HTML attributes must not define callbacks or executable behavior.

Native block adapter:

- `TagflowNativeBlock.container(...)` and existing semantic blocks adapt into
  the same runtime nodes.
- Tap behavior is attached by the view, not by the native block payload.
- Native JSON remains JSON-like only.

Patches:

- Replacing or moving a node changes only the runtime document.
- Tap behavior follows node kind and the current `TagflowViewOptions`.
- No patch operation carries callbacks.

## 8. Tests Required

The first implementation slice must include focused tests proving:

- default `TagflowViewOptions` do not make non-link nodes tappable
- `Tagflow.document(...)` invokes `nodeTapCallback` for an opted-in semantic
  node kind and passes the tapped node
- semantics tap actions on opted-in non-link tap targets invoke
  `nodeTapCallback` with the same tapped document or HTML-adapted node
- `Tagflow.html(...)` can tap an HTML-adapted node by semantic kind while
  preserving stable node ID and metadata for the callback
- `linkTapCallback` still handles links as before
- `TagflowOptions` legacy conversion preserves the new fields
- `tagflow.dart` exports the new callback details type

## 9. Roadmap Impact

When the first slice lands, check only:

- `Interactive Features > Advanced Interaction > Custom tap handlers per
  element type`

Do not check long press, gesture recognition, selection, or copy/paste.

## 10. Open Follow-Ups

- Long press callback shape.
- Whether a future callback should return a handled/ignored disposition.
- Whether link taps and node taps should compose through a unified action model.
- Broader accessibility review beyond the first button-like role/label and
  semantics-tap coverage on app-defined tap targets.
- Example-app plugin showcase demonstrating node taps on app-authored native
  blocks.
