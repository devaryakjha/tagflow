import 'package:tagflow_example/widgets/example_page.dart';

// example code block
const _html = '''
<h3>Basic Code Block</h3>
<code>const a = 1;
const b = 2;
const c = a + b;</code>

<h3>Code Block inside a pre tag</h3>
<pre>
<code>const a = 1;
const b = 2;
const c = a + b;</code>
</pre>


<h3>Code Block with Multiple Elements</h3>
<pre>
<span>Line 1</span>
<code>some code</code>
<em>emphasized text</em>
Plain text
</pre>

<h3>Blockquote</h3>
<blockquote>
  <p>Blockquote</p>
</blockquote>

<h3>Blockquote inside a paragraph</h3>
<p>
<em>ABC</em>
<b>DEF</b>
<blockquote>This is a quoted text</blockquote>
<i>DEF</i>
</p>
''';

class CodeExample extends ExamplePage {
  const CodeExample({super.key});

  @override
  String get html => _html;

  @override
  String get title => 'Code Example';
}
