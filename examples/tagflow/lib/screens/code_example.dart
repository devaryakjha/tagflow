import 'package:flutter/material.dart';
import 'package:tagflow/tagflow.dart';
import 'package:tagflow_example/utils/dart_highlighter.dart';
import 'package:tagflow_example/widgets/gallery_scaffold.dart';

const _html = r'''
<p>Code blocks come from <code>&lt;pre&gt;&lt;code&gt;</code>. The
<code>language-dart</code> class reaches the highlighter as
<code>dart</code>:</p>

<pre><code class="language-dart">// Render a streamed answer.
final stream = TagflowMarkdownStream();

Future<void> main() async {
  await stream.addStream(tokens);
  print('Blocks: ${stream.document.children.length}');
}</code></pre>

<p>A block in a language the highlighter does not know stays plain:</p>

<pre><code class="language-yaml">dependencies:
  tagflow: ^1.0.0-beta.0</code></pre>

<p>Inline code such as <code>Tagflow.html(...)</code> is never highlighted.</p>
''';

class CodeExample extends StatefulWidget {
  const CodeExample({super.key});

  @override
  State<CodeExample> createState() => _CodeExampleState();
}

class _CodeExampleState extends State<CodeExample> {
  bool _highlight = true;
  bool _copyButton = true;

  void _onCopy(TagflowCodeCopyDetails details) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Copied ${details.source.split('\n').length} lines of '
            '${details.language ?? 'code'}',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return GalleryScaffold(
      title: 'Code blocks',
      description:
          'TagflowCodeBlockOptions takes an app-supplied highlighter and an '
          'optional copy button. This screen uses a small Dart highlighter '
          'written for the gallery.',
      actions: [
        FilterChip(
          key: const ValueKey('code-highlight'),
          label: const Text('Highlight'),
          selected: _highlight,
          onSelected: (value) => setState(() => _highlight = value),
        ),
        FilterChip(
          key: const ValueKey('code-copy-button'),
          label: const Text('Copy button'),
          selected: _copyButton,
          onSelected: (value) => setState(() => _copyButton = value),
        ),
      ],
      children: [
        Tagflow.html(
          html: _html,
          viewOptions: TagflowViewOptions(
            codeBlock: TagflowCodeBlockOptions(
              highlighter: _highlight ? highlightDart : null,
              showCopyButton: _copyButton,
              onCopy: _onCopy,
            ),
          ),
        ),
      ],
    );
  }
}
