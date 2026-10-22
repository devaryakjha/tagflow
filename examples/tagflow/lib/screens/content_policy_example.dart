import 'package:flutter/material.dart';
import 'package:tagflow/tagflow.dart';
import 'package:tagflow_example/widgets/gallery_scaffold.dart';

const _untrustedHtml = '''
<h3>Untrusted HTML</h3>
<p>This paragraph is safe and always renders.</p>
<script>alert('blocked');</script>
<iframe src="https://example.com/embed"></iframe>
<p>A <a href="javascript:alert('x')">javascript: link</a> loses its target,
while an <a href="https://pub.dev/packages/tagflow">https link</a> keeps it.</p>
<form><input type="text" placeholder="Blocked form control"></form>
<img src="data:image/png;base64,iVBORw0KGgo=" alt="data: image">
<p>The paragraph after the blocked content still renders.</p>
''';

class ContentPolicyExample extends StatefulWidget {
  const ContentPolicyExample({super.key});

  @override
  State<ContentPolicyExample> createState() => _ContentPolicyExampleState();
}

class _ContentPolicyExampleState extends State<ContentPolicyExample> {
  TagflowUnsupportedBehavior _behavior = TagflowUnsupportedBehavior.drop;

  @override
  Widget build(BuildContext context) {
    final adapter = TagflowHtmlAdapter(
      policy: TagflowContentPolicy(unsupportedBehavior: _behavior),
    );
    return GalleryScaffold(
      title: 'Content policy',
      description:
          'The default TagflowContentPolicy blocks scripts, iframes and form '
          'controls, allows only http, https and mailto URLs, and rejects '
          'data: images. Choose whether blocked content is dropped or kept '
          'as a placeholder.',
      actions: [
        SegmentedButton<TagflowUnsupportedBehavior>(
          key: const ValueKey('policy-behavior'),
          segments: const [
            ButtonSegment(
              value: TagflowUnsupportedBehavior.drop,
              label: Text('Drop'),
            ),
            ButtonSegment(
              value: TagflowUnsupportedBehavior.preservePlaceholder,
              label: Text('Placeholder'),
            ),
          ],
          selected: {_behavior},
          onSelectionChanged: (selection) {
            setState(() => _behavior = selection.single);
          },
        ),
      ],
      children: [
        Tagflow.html(
          key: ValueKey(_behavior),
          html: _untrustedHtml,
          adapter: adapter,
        ),
      ],
    );
  }
}
