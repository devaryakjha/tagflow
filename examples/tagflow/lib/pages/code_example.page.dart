import 'package:tagflow_example/widgets/example_page.dart';

// example code block
const _html = '''
<h3>Basic Code Block</h3>
<pre><code>const a = 1;
const b = 2;
const c = a + b;</code></pre>

<h3>Code Block with Multiple Elements</h3>
<pre>
<span>Line 1</span>
<code>some code</code>
<em>emphasized text</em>
Plain text
</pre>
''';

class CodeExample extends ExamplePage {
  const CodeExample({super.key});

  @override
  String get html => _html;

  @override
  String get title => 'Code Example';
}
