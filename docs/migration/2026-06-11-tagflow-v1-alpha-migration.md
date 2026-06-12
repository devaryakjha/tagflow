# Tagflow v1 Alpha Migration Guide

This guide covers the docs-facing migration from the `0.0.x` HTML-first API to
the `1.0.0-alpha.x` runtime direction. The alpha line is intentionally breaking:
Tagflow is becoming a native rich content runtime for Flutter apps, with HTML as
one adapter into that runtime.

Release posture: keep this as one breaking `1.0.0` prerelease line rather than
parallel compatibility and runtime lines. A future `1.0.0-beta.x` or
`1.0.0-pre.x` label should mean the public runtime, adapter, compatibility, and
first-party extension surfaces are close to frozen; it should not be used only
to repair package discovery or marketing copy. Stable `1.0.0` should wait until
the beta API freeze review is complete, benchmark evidence gates are credible
and still report-only unless separately promoted, and at least one hosted
real-app validation path has been pushed, merged, and exercised through the
intended app route.

Current-state note: this guide keeps the original alpha.1 migration framing,
but the implemented runtime on the native-runtime branch is later than that
initial target. `Tagflow.html(..., registry: ...)` is already part of the
shipped HTML-origin semantic path, while controller and parser/adapter cache
APIs remain deferred.

## Why This Alpha Breaks

Earlier Tagflow releases treated HTML tags as the center of the public model:
apps passed HTML to `Tagflow`, custom behavior was usually expressed through
HTML selectors, and table support extended HTML rendering directly.

The alpha runtime moves the source of truth to `TagflowDocument` and semantic
`TagflowDocumentNode` values. That gives Flutter apps a native model for rich
content while keeping HTML available through `TagflowHtmlAdapter`.

Breaking changes should be expected around parser internals, converter
internals, broad public exports, and selector-based extension points.

Parser, converter, legacy HTML node models, and selector-based extension APIs
are available from `package:tagflow/legacy.dart` during the alpha transition.
New code should import `package:tagflow/tagflow.dart` and use
`Tagflow.document(...)`, `Tagflow.html(...)`, `TagflowHtmlAdapter`, and
`TagflowComponentRegistry`.

Shared style primitives such as `Display`, `SizeValue`, `SizeUnit`,
`FlexDirection`, `JustifyContent`, and `AlignItems` remain available from
`package:tagflow/tagflow.dart`. They support the public styling APIs and are
not legacy-only imports even though their main use remains HTML/CSS
compatibility styling during the transition.

## HTML-First Usage

Existing code may look like this:

```dart
Tagflow(
  html: htmlContent,
  theme: theme,
  options: options,
);
```

For alpha docs and new code, prefer the explicit HTML constructor:

```dart
Tagflow.html(
  html: htmlContent,
  theme: theme,
  viewOptions: viewOptions,
  renderBoundary: TagflowRenderBoundary.comment(end: 'end-of-mobile'),
);
```

`Tagflow.html(...)` is the compatibility path for apps that still receive HTML.
It parses through `TagflowHtmlAdapter` and renders the resulting
`TagflowDocument`.

`TagflowViewOptions` is the new runtime-view API for links, view-owned node
taps, selection, image loading, image errors, cache behavior, and error
widgets. `TagflowOptions` remains available as an alpha compatibility wrapper
for existing code, and it still carries legacy HTML-only `renderBoundary`
configuration during the transition.

## Compatibility Support Windows

The alpha line keeps compatibility surfaces available so existing HTML renderer
integrations can move toward the native runtime in reviewable steps. These
surfaces are not the preferred API for new code.

### `TagflowOptions`

`TagflowOptions` remains available through the alpha line and should remain
available through the `1.0.0-beta.x` line unless a later beta-readiness review
explicitly changes that plan.

New code should use `TagflowViewOptions`. The old `TagflowOptions` wrapper is
for migration from the HTML-first widget API, and its `renderBoundary` field is
HTML-only compatibility behavior. `renderBoundary` should not be treated as a
source-agnostic native document feature.

Before `1.0.0` stable, the project must decide whether `TagflowOptions` stays
as a long-term compatibility alias or receives a formal deprecation window.

### `package:tagflow/legacy.dart`

`package:tagflow/legacy.dart` remains available through all `1.0.0-beta.x`
releases. It contains compatibility exports for legacy parser, converter,
model, parser utility, reusable widget, and HTML-renderer customization APIs.
Transitional bridge APIs such as `TagflowHtmlDocumentBridge` also live here
rather than in the primary `package:tagflow/tagflow.dart` runtime barrel.

New integrations should prefer `TagflowDocument`, `TagflowHtmlAdapter`,
`TagflowNativeBlockAdapter`, and `TagflowComponentRegistry`. Legacy custom
converters remain useful during migration, but they are not the future
extension model for native rich content.

During beta, `legacy.dart` should receive compatibility fixes, documentation
updates, and critical bug or security fixes. New feature work should target the
native document, adapter, and registry APIs unless there is a clear migration
need.

Before `1.0.0` stable, the project must decide whether `legacy.dart` remains
inside `package:tagflow`, moves to a separate compatibility package, or enters
a formal deprecation window.

### `TagflowDocument(...)`

The default `TagflowDocument(...)` constructor remains permissive through the
`1.0.0-beta.x` line. This preserves alpha source compatibility and keeps an
explicit-validation path available for callers that construct intermediate
documents before running `validateUniqueNodeIds()`.

New app-authored, CMS-authored, or AI-authored native documents should use
`TagflowDocument.validated(...)` when duplicate IDs should fail before
rendering or patch application. Use `TagflowDocument.copyWithValidated(...)`
for the same fail-fast boundary during structural updates.

Before `1.0.0` stable, the project may revisit whether the permissive
constructor needs a deprecation, rename, or stricter alternative, but beta
should not change constructor failure behavior without real hosted-app evidence.

### `tagflow_table`

`tagflow_table` remains a separate first-party extension package through beta.
The core package keeps its basic built-in table renderer, while high-fidelity
table rendering belongs in the table extension and its semantic registry
fragment:

```dart
final registry = TagflowComponentRegistry(
  extensions: [
    tagflowTableComponents(),
  ],
);
```

This split is intentional. It validates the `TagflowComponentRegistry`
extension model without coupling the core runtime freeze to the full table
renderer. The package may also keep HTML table converter compatibility through
`package:tagflow/legacy.dart` during the same support window.

The beta-facing `package:tagflow_table/tagflow_table.dart` barrel should stay
focused on `tagflowTableComponents(...)`, `TagflowTableBorder`, and the legacy
converter pair. Low-level widget and render-object classes remain package
internals rather than part of the beta extension contract.

For `1.0.0-beta.0`, release `tagflow_table` in lockstep with `tagflow` so the
first beta validates core runtime, package constraint, and first-party table
registry compatibility together. After `beta.0`, `tagflow_table` may publish
independent patch or minor prereleases for table-only fixes or additive
renderer improvements, but only while its `tagflow` dependency constraint
remains compatible with the current beta runtime and the semantic registry API
tests remain green.

## Native Document Usage

Use `Tagflow.document(...)` when content is already in Tagflow's native runtime
model:

```dart
final document = TagflowDocument.validated(
  id: 'article-42',
  children: [
    TagflowDocumentNode.heading(
      id: 'article-42.title',
      level: 1,
      children: [
        TagflowDocumentNode.text(
          id: 'article-42.title.text',
          text: 'Native rich content',
        ),
      ],
    ),
    TagflowDocumentNode.paragraph(
      id: 'article-42.intro',
      children: [
        TagflowDocumentNode.text(
          id: 'article-42.intro.text',
          text: 'HTML is now an adapter, not the runtime model.',
        ),
      ],
    ),
  ],
);

Tagflow.document(document);
```

Use `TagflowDocument.validated(...)` for app-authored, CMS-authored, or
AI-authored native documents that should fail fast on duplicate node IDs before
rendering or patch application. Plain `TagflowDocument(...)` remains available
through beta when callers need explicit validation control or alpha source
compatibility.

This is the canonical runtime entry point for alpha.

### View-Owned Node Taps

The interaction model stays on the Flutter view side instead of becoming part
of `TagflowDocument`, HTML metadata, or native JSON payloads:

```dart
Tagflow.document(
  document,
  viewOptions: TagflowViewOptions(
    nodeTapCallback: (details) {
      final node = details.node;
      // Route app-owned actions from node.id, node.kind, or node.metadata.
    },
    tapTargetKinds: const {
      TagflowNodeKind.container,
      TagflowNodeKind.listItem,
    },
  ),
);
```

Use `tapTargetKinds` to opt specific semantic node kinds into tap handling.
`TagflowNodeKind.link` keeps the existing `linkTapCallback` path in this first
slice. HTML-origin nodes adapted through `Tagflow.html(...)` can still surface
authored IDs and metadata through `TagflowNodeTapDetails.node`.

## Native JSON Transport

Use the native block transport when content is already trusted structured data
from your app, backend, CMS, or AI pipeline. This path keeps semantic block IDs
and data-only attributes without forcing the payload through an HTML string.

```dart
const codec = TagflowNativeBlockCodec();
const adapter = TagflowNativeBlockAdapter();

final nativePayload = codec.decodeDocument({
  'id': 'announcement-42',
  'schemaVersion': 1,
  'revision': 'cms-rev-7',
  'blocks': [
    {
      'id': 'announcement-42.title',
      'kind': 'heading',
      'attributes': {'level': 1},
      'children': [
        {
          'id': 'announcement-42.title.text',
          'kind': 'text',
          'text': 'Structured update',
        },
      ],
    },
  ],
});

final document = adapter.adapt(nativePayload);

Tagflow.document(document);
```

`schemaVersion` is intentionally strict through beta. Documents and patch
envelopes must use `schemaVersion: 1`; other values fail during
`TagflowNativeBlockCodec` decode until real producer evidence justifies a
reviewed compatibility policy. Do not emit future schema versions
speculatively.

Unknown native JSON `kind` values and unknown patch `op` values also fail
during codec decode. `TagflowUnsupportedBehavior` applies after decode to
known blocks rejected by adapter policy. A known link block whose URL policy
rejects the source degrades to a neutral container, preserves already-adapted
children, and records the policy reason in metadata. A known image block whose
URL policy rejects the source is dropped by default. When
`preservePlaceholder` is configured, the image block becomes a runtime
`unsupported` node and the built-in renderer shows a neutral "Unsupported
content" placeholder without exposing the rejected source payload. No other
current native block kind has a URL-bearing field consumed by the adapter.

Native table payloads use the same minimal semantic table model as the runtime:
`table`, `tableRow`, and `tableCell` nodes, with `header`, `rowSpan`, and
`colSpan` promoted on cells. Captions and other producer-specific table hints
are preserved as native block metadata until a renderer or app integration
needs a generic field. `image` is the reviewed native media kind for beta;
video, audio, or media-group producer kinds should not be emitted until a
future SPEC adds them.

Patch envelopes decode into `TagflowNativeBlockPatchEnvelope` values containing
ordered native operations. Apps should adapt those operations and then use the
runtime document patch API:

```dart
final envelope = codec.decodePatchEnvelope(patchJson);
final updatedDocument = document.applyPatches(
  adapter.adaptPatches(envelope.operations),
);
```

Revision matching and conflict handling still belong to app or backend code.
Tagflow intentionally does not reject or queue patches based on
`baseRevision`/`revision`; it only exposes those tokens and applies the
ordered operations you choose to accept.

Native tap routing remains view-owned in the same way. Apps should read stable
adapter metadata from the tapped runtime node and then hand off to their own
navigation or action layer:

```dart
Tagflow.document(
  document,
  viewOptions: TagflowViewOptions(
    nodeTapCallback: (details) {
      final actionId =
          details.node.nativeBlockAttributes['actionId'] as String?;
      if (actionId == null) return;

      // Route through app-owned navigation or command handling.
      openAction(actionId);
    },
    tapTargetKinds: const {
      TagflowNodeKind.container,
      TagflowNodeKind.listItem,
    },
  ),
);
```

The native JSON transport is intentionally data-only. It does not execute
JavaScript, render arbitrary webpages, serialize Flutter widgets, or define a
complete CMS sync protocol. Benchmark evidence for this path is available from
the report-only `benchmark:native-transport` lane; it should not be used as a
public performance claim.

## HTML Adapter and Content Policy

Use `TagflowHtmlAdapter` directly when an app wants to parse once, inspect the
document, hold the resulting `TagflowDocument` in app state, or configure HTML
input policy:

```dart
const adapter = TagflowHtmlAdapter(
  policy: TagflowContentPolicy(
    allowRemoteImages: false,
    allowDataImages: false,
    allowedSchemes: {'https', 'mailto'},
    unsupportedBehavior: TagflowUnsupportedBehavior.preservePlaceholder,
  ),
);

final document = adapter.parse(htmlContent);

Tagflow.document(document);
```

The default policy rejects browser-dependent or executable elements such as
`script`, `style`, `iframe`, forms, and unsafe URL schemes. Use explicit policy
configuration when product requirements need stricter input rules.

Controlled HTML can migrate onto the same callback path. Keep stable
`data-tagflow-id` values, attach view-owned taps, and read sanitized authored
attributes from the adapted runtime node:

```dart
Tagflow.html(
  html: '''
<section
  data-tagflow-id="promo-card"
  data-action-id="open-promo-sheet">
  Promo content
</section>
''',
  adapter: const TagflowHtmlAdapter(
    nodeIdStrategy: TagflowHtmlNodeIdStrategy.attribute(
      fallbackToPath: false,
    ),
  ),
  viewOptions: TagflowViewOptions(
    nodeTapCallback: (details) {
      final actionId = details.node.htmlAttributes['data-action-id'];
      if (actionId == null) return;

      // Route through app-owned navigation or command handling.
      openAction(actionId);
    },
    tapTargetKinds: const {TagflowNodeKind.container},
  ),
);
```

## Component Registry Overrides

New runtime extension work should target semantic node kinds instead of HTML
selectors:

```dart
final registry = TagflowComponentRegistry(
  overrides: {
    TagflowNodeKind.paragraph: (context, node) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: DefaultTextStyle.merge(
          style: const TextStyle(fontSize: 16, height: 1.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: context.renderChildren(node),
          ),
        ),
      );
    },
  },
);

Tagflow.document(document, registry: registry);

Tagflow.html(
  html: htmlContent,
  registry: registry,
);
```

The registry is the alpha direction for renderer customization.
`Tagflow.html(..., registry: registry)` applies the same semantic registry
override path to HTML-origin runtime documents. Legacy `ElementConverter` and
selector-based customizations may remain during the alpha transition, and custom
HTML converters continue to use the legacy bridge instead of the semantic
registry. They are not the long-term extension contract.

First-party extension packages should expose registry fragments. For example,
`tagflow_table` can render native document table nodes through its custom table
render object:

```dart
final registry = TagflowComponentRegistry(
  extensions: [
    tagflowTableComponents(
      columnSpacing: 8,
      rowSpacing: 4,
    ),
  ],
);

Tagflow.document(document, registry: registry);
```

The legacy table converter remains available for HTML-converter compatibility,
but new native document integrations should prefer the semantic registry
fragment.

## What Alpha Does Not Promise

The alpha line does not promise:

- browser parity or arbitrary CSS support
- JavaScript execution or DOM mutation APIs
- rich text editing APIs
- streaming HTML parsing or viewport virtualization
- a CMS sync protocol for native JSON patches
- public performance claims from report-only native transport smoke evidence
- a separate published `tagflow_html` package
- permanent source compatibility for parser/converter internals
- selector-based custom converters as the long-term plugin model
- exact export layout compatibility with `0.0.x`

Alpha docs should describe HTML as a first-party adapter and
`Tagflow.document(...)` as the native runtime API. They should not describe
Tagflow as only an HTML rendering engine.
