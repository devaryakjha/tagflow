<a href="https://zerodha.tech"><img src="https://zerodha.tech/static/images/github-badge.svg" align="right" /></a>

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://github.com/devaryakjha/tagflow/raw/main/assets/dark/logo.svg">
    <source media="(prefers-color-scheme: light)" srcset="https://github.com/devaryakjha/tagflow/raw/main/assets/light/logo.svg">
    <img alt="tagflow" src="https://github.com/devaryakjha/tagflow/raw/main/assets/dark/logo.svg" width="400">
  </picture>
</p>

[![pub package](https://img.shields.io/pub/v/tagflow.svg)](https://pub.dev/packages/tagflow)
[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)

> ⚠️ **Beta prerelease**: `1.0.0-beta.2` freezes the public API. Changes
> before the stable `1.0.0` release are bug fixes and the removal of options
> that `beta.2` deprecates.

# 🌊 tagflow

Tagflow is a native rich content runtime for Flutter apps. It renders semantic
`TagflowDocument` content with Flutter widgets and keeps HTML support through
the first-party `TagflowHtmlAdapter`.

## ✨ Features

- Render native `TagflowDocument` content with Flutter widgets
- Parse HTML through the first-party `TagflowHtmlAdapter`
- Render HTML `<details>` / `<summary>` as native expandable disclosure widgets
- Apply explicit `TagflowContentPolicy` rules to adapter input
- Override semantic node rendering through `TagflowComponentRegistry`
- Configure runtime behavior with `TagflowViewOptions`, including view-owned
  node taps
- Keep parser and converter compatibility through `package:tagflow/legacy.dart`

---

## Feature Highlights

### HTML Adapter

```dart
import 'package:flutter/widgets.dart';
import 'package:tagflow/tagflow.dart';

class ArticleBody extends StatelessWidget {
  const ArticleBody({required this.html, super.key});

  final String html;

  @override
  Widget build(BuildContext context) {
    return Tagflow.html(
      html: html,
      viewOptions: TagflowViewOptions(
        selectable: const TagflowSelectableOptions(enabled: true),
        linkTapCallback: (url, attributes) {
          // Open the URL with your app's navigation layer.
        },
      ),
    );
  }
}
```

Use the adapter directly when you want to parse once, inspect, cache, or apply
stricter HTML policy before rendering:

```dart
const adapter = TagflowHtmlAdapter(
  policy: TagflowContentPolicy(
    allowRemoteImages: false,
    allowedSchemes: {'https', 'mailto'},
  ),
);

final document = adapter.parse(htmlContent);

Tagflow.document(document);
```

### Content Policy and Limits

Every adapter (HTML, Markdown, native JSON and the Markdown stream) applies a
`TagflowContentPolicy`. Besides tags and URL schemes, the policy bounds how
much work one document can cost:

| Limit | Default | What happens over it |
| --- | --- | --- |
| `maxDepth` | 128 | Deeper content is cut off |
| `maxNodes` | 50000 | Content after the limit is cut off |
| `colspan` / `rowspan` | 1000 / 65534 | Clamped, as the HTML specification does |

Cut content follows `unsupportedBehavior`: it is removed under the default
`drop`, or one unsupported node with a `policyDecisionReason` of `maxDepth`
or `maxNodes` marks the cut under `preservePlaceholder`. Adapting never
throws because of a limit. Raise the limits only for trusted input:

```dart
const adapter = TagflowHtmlAdapter(
  policy: TagflowContentPolicy(maxDepth: 256, maxNodes: 200000),
);
```

Relative URLs need a base. Set `baseUrl` to the address the content came
from and relative or scheme-relative links and images are resolved, then
checked against the allowed schemes like any other URL. Without a base,
scheme-relative URLs (`//host/path`) and relative images are rejected, and
relative links reach your link callback as written.

```dart
final adapter = TagflowHtmlAdapter(
  policy: TagflowContentPolicy(
    baseUrl: Uri.parse('https://example.com/articles/'),
  ),
);
```

The default error widget shows the error text in debug and profile builds
and a neutral message in release builds. Pass `errorBuilder` to replace it.

### Markdown Adapter

Render Markdown, such as an AI answer, without converting it to HTML first.
GitHub Flavored Markdown tables, task lists, fenced code, strikethrough and
autolinks are supported:

```dart
Tagflow.markdown(markdown: answer);
```

Markdown adapts into a regular `TagflowDocument`, so content policy, custom
component registries and `tagflow_table` apply as they do for HTML. Each
top-level block gets a deterministic ID (`0.0`, `0.1`, ...), so re-adapting a
longer prefix of the same Markdown keeps earlier IDs stable.

Raw HTML inside Markdown goes through the HTML adapter and content policy by
default. Drop it, or keep it as literal text, with `rawHtml`:

```dart
const adapter = TagflowMarkdownAdapter(
  rawHtml: TagflowMarkdownRawHtmlBehavior.drop,
);

Tagflow.markdown(markdown: answer, markdownAdapter: adapter);

// Or parse once and render the document.
Tagflow.document(adapter.parse(answer));
```

### Live Updates

Pass a new `html:` or `markdown:` string to the same `Tagflow.html` or
`Tagflow.markdown` widget and it updates in place. The adapted document keeps
the same ID for the life of the widget, and each node is keyed by its ID, so
nodes that did not change keep their widget state (scroll position, selection,
expanded disclosures, loaded images). Pass a different `documentId:` when you
want a full remount on purpose.

The widget re-parses only when the source string, the adapter (compared by
value, so a new but equal `TagflowHtmlAdapter(...)` is fine), the document ID
or `viewOptions.debug` changes. Inline callbacks in `viewOptions` rebuild the
rendered tree without parsing again.

### Controlled Dynamic HTML

Use authored IDs when your HTML comes from a controlled CMS, AI pipeline, or
server formatter that can re-emit the same logical blocks across updates.
Default path IDs are fine for static HTML, but inserting a new block near the
top renumbers later siblings and makes existing widgets look new on a full
reparse.

```dart
const adapter = TagflowHtmlAdapter(
  nodeIdStrategy: TagflowHtmlNodeIdStrategy.attribute(),
);

final before = adapter.parse('''
<p data-tagflow-id="summary">Summary</p>
<p data-tagflow-id="details">Details</p>
''');

final after = adapter.parse('''
<p data-tagflow-id="callout">New callout</p>
<p data-tagflow-id="summary">Summary</p>
<p data-tagflow-id="details">Details</p>
''');
```

`summary` and `details` keep their authored IDs after the insertion. If every
dynamic node must be annotated, set `fallbackToPath: false` to fail fast on
missing IDs. Duplicate IDs fail during adaptation.

### Native Documents

```dart
import 'package:tagflow/tagflow.dart';

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
          text: 'HTML is an adapter, not the runtime model.',
        ),
      ],
    ),
  ],
);

Tagflow.document(document);
```

Use `TagflowDocument.validated(...)` for app-authored, AI-produced, or CMS
documents when you want duplicate node IDs to fail fast before rendering or
patch application. Plain `TagflowDocument(...)` remains available for lower-
level construction paths that want explicit validation control.

### View-Owned Node Taps

Node taps stay on the Flutter view side instead of becoming part of the
document or native JSON payload:

```dart
Tagflow.document(
  document,
  viewOptions: TagflowViewOptions(
    nodeTapCallback: (details) {
      final node = details.node;
      // Use node.id, node.kind, or node.metadata in app-owned behavior.
    },
    tapTargetKinds: const {
      TagflowNodeKind.container,
      TagflowNodeKind.listItem,
    },
  ),
);
```

Use this for app-owned interactions such as callouts, cards, or list items.
`TagflowNodeKind.link` keeps the existing `linkTapCallback` path, and
HTML-adapted nodes can still surface authored IDs and metadata through
`TagflowNodeTapDetails.node`.

### Code Blocks

Code blocks render as plain monospace text by default. Tagflow core does not
depend on a syntax highlighter; instead, pass a `TagflowCodeHighlighter`
function that turns the source into a `TextSpan`, and opt into a copy button:

```dart
Tagflow.document(
  document,
  viewOptions: TagflowViewOptions(
    codeBlock: TagflowCodeBlockOptions(
      highlighter: (context, request) {
        // request.language is normalized, so `language-dart` becomes `dart`.
        if (request.language != 'dart') return null; // plain fallback
        return TextSpan(
          style: request.style,
          children: myHighlighter.highlight(request.source),
        );
      },
      showCopyButton: true,
      onCopy: (details) {
        // details.source was written to the clipboard.
      },
    ),
  ),
);
```

Any Dart highlighting package that produces styled ranges or spans can be
plugged in this way, for example by mapping a package's tokens or nodes to
`TextSpan`s inside the highlighter. Returning `null` keeps the default plain
rendering for that block. For HTML input, the language comes from the `class`
of the `<pre>` element or of its `<code>` child.

### Native JSON Transport

Use `TagflowNativeBlockCodec` when a trusted app backend, CMS, or AI pipeline
already emits structured data and you do not want to route it through HTML.
The codec accepts a deliberately small data-only JSON shape, the adapter turns
that payload into a `TagflowDocument`, and the same document runtime renders it:

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
known blocks rejected by adapter policy, such as a known image block whose URL
policy rejects the source.

`TagflowDocument.version` is the in-process runtime document model version. It
is separate from native JSON `schemaVersion`; app, CMS, AI, or adapter producers
should keep payload schema and revision values in adapter metadata or native
block envelope fields instead of mapping them into `TagflowDocument.version`.

Patch envelopes use `TagflowNativeBlockPatchEnvelope`: decode the producer
envelope, adapt the ordered native operations, then apply runtime document
patches.

```dart
final envelope = codec.decodePatchEnvelope({
  'id': 'announcement-42',
  'schemaVersion': 1,
  'baseRevision': 'cms-rev-7',
  'revision': 'cms-rev-8',
  'operations': [
    {
      'op': 'insert-before',
      'siblingNodeId': 'announcement-42.title',
      'blocks': [
        {
          'id': 'announcement-42.notice',
          'kind': 'paragraph',
          'children': [
            {
              'id': 'announcement-42.notice.text',
              'kind': 'text',
              'text': 'This update came from trusted app JSON.',
            },
          ],
        },
      ],
    },
  ],
});

final updatedDocument = document.applyPatches(
  adapter.adaptPatches(envelope.operations),
);
```

The other operations are `replace` (`nodeId`, `block`), `append-children`
(`parentNodeId`, `blocks`), `append-root` (`blocks`, appended to the end of
the document, which suits streaming) and `remove` (`nodeId`).

Text and container blocks take inline semantics, so styled runs fit inside a
paragraph:

```dart
final textBlock = {
  'id': 'p.1',
  'kind': 'text',
  'text': 'bold and struck',
  'attributes': {'semantics': ['strong', 'deleted']},
};
```

This transport is for trusted, app-controlled structured content. It is not a
webpage renderer, JavaScript environment, arbitrary CMS sync layer, or generic
serializer for Flutter widgets and callbacks.

### Semantic Renderer Overrides

```dart
final registry = TagflowComponentRegistry(
  overrides: {
    TagflowNodeKind.paragraph: (context, node) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: context.renderChildren(node),
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

Use `Tagflow.html(..., registry: registry)` when HTML-origin content only needs
semantic render overrides. Use `TagflowHtmlAdapter` plus `Tagflow.document(...)`
when the app also needs authored IDs, strict HTML policy, inspection, or caching
before rendering.

### Compatibility Imports

Parser, converter, selector, and legacy node APIs are deprecated. They stay
available, unchanged, through every 1.x release and are removed in 2.0:

```dart
import 'package:tagflow/legacy.dart';
```

Use it only for existing `TagflowParser`, `ElementConverter`, `TagflowNode`, or
selector-based custom converter integrations. `TagflowOptions`, the
`converters:` parameter, and the default `Tagflow(html: ...)` constructor are
deprecated on the same schedule. New runtime code should use
`package:tagflow/tagflow.dart`, `Tagflow.document(...)`, `Tagflow.html(...)`,
`TagflowHtmlAdapter`, and `TagflowComponentRegistry`.

`dart fix --apply` (or the IDE quick fix) migrates the mechanical cases: the
default `Tagflow(html: ...)` constructor, `TagflowOptions(...)` without a
`renderBoundary`, `options:` arguments, `TagflowScope(options: ...)`, and
`ErrorWidgetBuilder`. Converter-based code and `TagflowOptions` with a
`renderBoundary` need a manual migration.

### Theming

The built-in components read a `TagflowRenderTheme`. Every field is optional,
and unset fields follow the ambient `Theme` (headings use the text theme's
headline and title styles, surfaces are tinted from the text colour), so dark
mode and app typography work with no setup:

```dart
Tagflow.html(
  html: articleContent,
  renderTheme: const TagflowRenderTheme(
    h1Style: TextStyle(fontSize: 28),
    linkStyle: TextStyle(color: Colors.teal),
    codeBackgroundColor: Color(0x14000000),
    paragraphSpacing: 12,
  ),
);

// Or for every Tagflow widget in a subtree:
TagflowRenderThemeScope(
  theme: const TagflowRenderTheme(blockSpacing: 16),
  child: child,
);
```

`theme: TagflowTheme(...)` keeps working: its default text style and the
`p`, `h1` to `h6`, `a`, `strong`, `em`, `code`, `pre`, `blockquote`, `th`
and `mark` styles are mapped onto the render theme. Class and nested
selectors only apply to the legacy converter pipeline.

```dart
Tagflow.html(
  html: articleContent,
  theme: TagflowTheme.fromTheme(
    Theme.of(context),
    h1Style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
  ),
);
```

#### Inline CSS

The HTML adapter keeps a safe subset of the `style` attribute: `color`,
`background-color`, `text-align`, `font-weight`, `font-style`,
`text-decoration` and `font-size` (`px`, `pt`, `rem`, `em`, `%`). Every other
property is ignored. Turn inline styles off with
`TagflowContentPolicy(allowInlineStyles: false)`.

## Installation

Add `tagflow` to your `pubspec.yaml`:

```yaml
dependencies:
  tagflow: ^1.0.0-beta.2
```

A caret constraint on a prerelease accepts every later prerelease. Production
apps should pin an exact version (`tagflow: 1.0.0-beta.2`) and read the
[changelog](CHANGELOG.md) before upgrading.

## Supported Features

- Native semantic document rendering
- Trusted native JSON document decode, adapt, and render flow
- Trusted native JSON patch envelope decode, adapt, and apply flow
- HTML adapter support for headings, paragraphs, emphasis, links, code,
  blockquotes, lists, images, and tables. The core table renderer draws a
  plain grid; register `tagflowTableComponents()` from `tagflow_table` for
  `rowspan` and `colspan` layout
- Content policy filtering for unsafe tags, URL schemes, and unsupported input
- Runtime view options for links, view-owned node taps, selection, image
  behavior, caching, and render errors
- HTML comment render boundaries for adapter input
- Legacy parser and converter compatibility for alpha migration

## Theme System

Tagflow's theme system integrates with Flutter's Material Design while
providing customization hooks for supported rich content:

- Material integration with app colors and typography
- Styles for supported semantic nodes, HTML tags, and classes
- Responsive units such as `rem`, `em`, percentages, viewport width, and
  viewport height where supported
- Color parsing and named color support

### Theme Configuration

```dart
TagflowTheme.fromTheme(
  Theme.of(context),
  baseFontSize: 16,
  h1Style: const TextStyle(fontSize: 32),
  codeBackground: Colors.grey.shade200,
);
```

On the runtime renderer, prefer `TagflowRenderTheme` (see
[Theming](#theming)); `TagflowTheme` selectors beyond the named styles only
affect the legacy converter pipeline.

## Documentation

Visit our [documentation](https://docs.arya.run/tagflow) for detailed guides and examples.

Moving from `0.0.8`? The
[0.0.8 to 1.0 migration guide](https://github.com/devaryakjha/tagflow/blob/main/docs/migration/2026-11-tagflow-0.0.8-to-1.0.md)
shows how to replace each kind of custom converter with a registry builder.
The [v1 alpha migration guide](https://github.com/devaryakjha/tagflow/blob/main/docs/migration/2026-06-11-tagflow-v1-alpha-migration.md)
explains the runtime design in more depth.
The example app also includes a `Native JSON Transport` screen that decodes
native block JSON, renders it with `Tagflow.document(...)`, and applies a patch
envelope through `TagflowNativeBlockAdapter.adaptPatches(...)`.
The native transport benchmark lane is available through
`dart run melos run benchmark:native-transport`; current results are
report-only local evidence, not public performance claims.

## Contributing

Contributions are welcome! Please read our [contributing guidelines](CONTRIBUTING.md) before submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
