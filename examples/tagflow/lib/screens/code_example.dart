import 'package:tagflow_example/widgets/example_page.dart';

const _html = '''
<p>Code blocks can be created using the <code>&lt;pre&gt;</code> and <code>&lt;code&gt;</code> tags:</p>

<pre><code>This is a basic code block
It preserves whitespace and line breaks
No syntax highlighting is applied</code></pre>

<p>Inline code can be added with just the <code>&lt;code&gt;</code> tag like <code>this</code>.</p>
''';

final class CodeExample extends ExamplePage {
  const CodeExample({super.key, super.title = 'Code Blocks'});

  @override
  String get html => _html;
}
