import 'package:flutter/material.dart';
import 'package:tagflow/tagflow.dart';
import 'package:tagflow_example/widgets/gallery_scaffold.dart';

const _markdown = '''
# Release notes

Tagflow parses **GitHub Flavored Markdown** into the same document model as
HTML, so it renders through the same components. Read the
[contract](https://github.com/devaryakjha/tagflow) for details.

## What changed

- A Markdown adapter with *stable* node ids
- A streaming helper for ~~polling~~ token streams
- [x] Task lists
- [ ] Footnotes in the gallery

> Blocks are adapted, not re-rendered: unchanged nodes keep their state.

| Input    | Adapter                   |
| -------- | ------------------------- |
| HTML     | `TagflowHtmlAdapter`      |
| JSON     | `TagflowNativeBlockAdapter` |
| Markdown | `TagflowMarkdownAdapter`  |

```dart
Tagflow.markdown(markdown: source);
```

Raw HTML such as <mark>this mark</mark> goes through the HTML adapter and
the content policy. <script>alert('dropped')</script>
''';

class MarkdownExample extends StatefulWidget {
  const MarkdownExample({super.key});

  @override
  State<MarkdownExample> createState() => _MarkdownExampleState();
}

class _MarkdownExampleState extends State<MarkdownExample> {
  bool _showSource = false;

  @override
  Widget build(BuildContext context) {
    return GalleryScaffold(
      title: 'Markdown',
      description:
          'GitHub Flavored Markdown adapted by TagflowMarkdownAdapter and '
          'rendered with Tagflow.markdown(...).',
      actions: [
        FilterChip(
          key: const ValueKey('markdown-show-source'),
          label: const Text('Show source'),
          selected: _showSource,
          onSelected: (value) => setState(() => _showSource = value),
        ),
      ],
      children: [
        if (_showSource)
          const SelectableText(
            _markdown,
            style: TextStyle(fontFamily: 'monospace', fontSize: 12),
          )
        else
          const Tagflow.markdown(markdown: _markdown),
      ],
    );
  }
}
