// A minimal app that renders HTML, Markdown and a hand-built document.
//
// The full gallery, with native JSON, streaming and custom components, is
// in examples/tagflow in the repository.
import 'package:flutter/material.dart';
import 'package:tagflow/tagflow.dart';

void main() => runApp(const TagflowExampleApp());

/// Example app.
class TagflowExampleApp extends StatelessWidget {
  /// Creates the example app.
  const TagflowExampleApp({super.key});

  static const _html = '''
<h2>From HTML</h2>
<p>Tagflow renders <strong>native widgets</strong>, with
<a href="https://pub.dev/packages/tagflow">links</a> and lists:</p>
<ul><li>No web view</li><li>Selectable text</li></ul>
''';

  static const _markdown = '''
## From Markdown

Streamed AI answers are the main use case:

```dart
Tagflow.markdown(markdown: answer);
```
''';

  @override
  Widget build(BuildContext context) {
    final document = TagflowDocument(
      id: 'built',
      children: [
        TagflowDocumentNode.heading(
          id: 'built.title',
          level: 2,
          children: [
            TagflowDocumentNode.text(
              id: 'built.title.text',
              text: 'From app code',
            ),
          ],
        ),
        TagflowDocumentNode.paragraph(
          id: 'built.body',
          children: [
            TagflowDocumentNode.text(
              id: 'built.body.text',
              text: 'Every input becomes the same TagflowDocument.',
            ),
          ],
        ),
      ],
    );

    final viewOptions = TagflowViewOptions(
      linkTapCallback: (url, attributes) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Tapped $url')));
      },
    );

    return MaterialApp(
      title: 'Tagflow example',
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('Tagflow')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Tagflow.html(html: _html, viewOptions: viewOptions),
            const Tagflow.markdown(markdown: _markdown),
            Tagflow.document(document),
          ],
        ),
      ),
    );
  }
}
