<a href="https://zerodha.tech"><img src="https://zerodha.tech/static/images/github-badge.svg" align="right" /></a>

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://github.com/devaryakjha/tagflow/raw/main/assets/dark/logo.svg">
    <source media="(prefers-color-scheme: light)" srcset="https://github.com/devaryakjha/tagflow/raw/main/assets/light/logo.svg">
    <img alt="tagflow" src="https://github.com/devaryakjha/tagflow/raw/main/assets/dark/logo.svg" width="400">
  </picture>
</p>

[![pub package](https://img.shields.io/pub/v/tagflow.svg)](https://pub.dev/packages/tagflow)
[![codecov](https://codecov.io/gh/devaryakjha/tagflow/graph/badge.svg)](https://codecov.io/gh/devaryakjha/tagflow)
[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)

> ⚠️ **Alpha prerelease**: `1.0.0-alpha.1` is the first native rich
> content runtime line. APIs may change before the stable `1.0.0` release.

# 🌊 tagflow

Tagflow is a native rich content runtime for Flutter apps. It renders semantic
`TagflowDocument` content with Flutter widgets and keeps HTML support through
the first-party `TagflowHtmlAdapter`.

## ✨ Features

- Render native `TagflowDocument` content with Flutter widgets
- Parse HTML through the first-party `TagflowHtmlAdapter`
- Apply explicit `TagflowContentPolicy` rules to adapter input
- Override semantic node rendering through `TagflowComponentRegistry`
- Configure runtime behavior with `TagflowViewOptions`
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
          text: 'HTML is an adapter, not the runtime model.',
        ),
      ],
    ),
  ],
);

Tagflow.document(document);
```

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

Patch envelopes follow the same path: decode the producer envelope, adapt the
ordered native operations, then apply runtime document patches.

```dart
final envelope = codec.decodePatchEnvelope({
  'id': 'announcement-42',
  'schemaVersion': 1,
  'baseRevision': 'cms-rev-7',
  'revision': 'cms-rev-8',
  'operations': [
    {
      'op': 'append-children',
      'parentNodeId': 'announcement-42.list',
      'blocks': [
        {
          'id': 'announcement-42.list.new-item',
          'kind': 'listItem',
          'children': [
            {
              'id': 'announcement-42.list.new-item.text',
              'kind': 'text',
              'text': 'New rollout step',
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
```

### Compatibility Imports

Parser, converter, selector, and legacy node APIs are still available during the
alpha transition from the compatibility barrel:

```dart
import 'package:tagflow/legacy.dart';
```

Use it for existing `TagflowParser`, `ElementConverter`, `TagflowNode`, or
selector-based custom converter integrations. New runtime code should prefer
`package:tagflow/tagflow.dart`, `Tagflow.document(...)`, `Tagflow.html(...)`,
`TagflowHtmlAdapter`, and `TagflowComponentRegistry`.

### Theming

```dart
Tagflow.html(
  html: articleContent,
  theme: TagflowTheme.fromTheme(
    Theme.of(context),
    headingConfig: const TagflowHeadingConfig(
      baseSize: 16,
      scales: [2.5, 2, 1.75, 1.5, 1.25, 1],
    ),
  ),
);
```

## Installation

Add `tagflow` to your `pubspec.yaml`:

```yaml
dependencies:
  tagflow: ^1.0.0-alpha.1
```

## Supported Features

- Native semantic document rendering
- HTML adapter support for headings, paragraphs, emphasis, links, code,
  blockquotes, lists, images, and tables
- Content policy filtering for unsafe tags, URL schemes, and unsupported input
- Runtime view options for links, selection, image behavior, caching, and
  render errors
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
  spacingConfig: const TagflowSpacingConfig(baseSize: 16, scale: 1.2),
);
```

## Documentation

Visit our [documentation](https://docs.arya.run/tagflow) for detailed guides and examples.

For the v1 alpha migration direction, see
[`docs/migration/2026-06-11-tagflow-v1-alpha-migration.md`](../../docs/migration/2026-06-11-tagflow-v1-alpha-migration.md).
The example app also includes a `Native JSON Transport` screen that decodes
native block JSON, renders it with `Tagflow.document(...)`, and applies a patch
envelope through `TagflowNativeBlockAdapter.adaptPatches(...)`.

## Contributing

Contributions are welcome! Please read our [contributing guidelines](CONTRIBUTING.md) before submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
