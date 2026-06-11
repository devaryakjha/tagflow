# Tagflow v1 Alpha Migration Guide

This guide covers the docs-facing migration from the `0.0.x` HTML-first API to
the `1.0.0-alpha.1` runtime direction. The alpha line is intentionally breaking:
Tagflow is becoming a native rich content runtime for Flutter apps, with HTML as
one adapter into that runtime.

## Why This Alpha Breaks

Earlier Tagflow releases treated HTML tags as the center of the public model:
apps passed HTML to `Tagflow`, custom behavior was usually expressed through
HTML selectors, and table support extended HTML rendering directly.

The alpha runtime moves the source of truth to `TagflowDocument` and semantic
`TagflowDocumentNode` values. That gives Flutter apps a native model for rich
content while keeping HTML available through `TagflowHtmlAdapter`.

Breaking changes should be expected around parser internals, converter
internals, broad public exports, and selector-based extension points.

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

`TagflowViewOptions` is the new runtime-view API for links, selection, image
loading, image errors, cache behavior, and error widgets. `TagflowOptions`
remains available as an alpha compatibility wrapper for existing code, and it
still carries legacy HTML-only `renderBoundary` configuration during the
transition.

## Native Document Usage

Use `Tagflow.document(...)` when content is already in Tagflow's native runtime
model:

```dart
final document = TagflowDocument(
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

This is the canonical runtime entry point for alpha.

## HTML Adapter and Content Policy

Use `TagflowHtmlAdapter` directly when an app wants to parse once, inspect the
document, cache the result, or configure HTML input policy:

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
```

The registry is the alpha direction for renderer customization. Legacy
`ElementConverter` and selector-based customizations may remain during the alpha
transition, but they are not the long-term extension contract.

## What Alpha Does Not Promise

The alpha line does not promise:

- browser parity or arbitrary CSS support
- JavaScript execution or DOM mutation APIs
- rich text editing APIs
- streaming HTML parsing or viewport virtualization
- a separate published `tagflow_html` package
- permanent source compatibility for parser/converter internals
- selector-based custom converters as the long-term plugin model
- exact export layout compatibility with `0.0.x`

Alpha docs should describe HTML as a first-party adapter and
`Tagflow.document(...)` as the native runtime API. They should not describe
Tagflow as only an HTML rendering engine.
