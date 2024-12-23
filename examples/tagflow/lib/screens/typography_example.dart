import 'package:tagflow_example/widgets/example_page.dart';

const _html = '''
<h1>Typography Examples</h1>

<h2>Text Styles</h2>
<p>This is a regular paragraph with <strong>bold text</strong>, <em>italic text</em>, and <u>underlined text</u>. Check out our <a href="https://github.com/devaryakjha/tagflow">GitHub repository</a>!</p>
<p>You can also use <mark>highlighted text</mark>, <del>strikethrough</del>, and <ins>inserted text</ins>.</p>
<p>For scientific notation, you can use subscript and superscript, for example H<sub>2</sub>O and 2<sup>3</sup>.</p>
<h2>Heading Levels</h2>
<h1>Heading 1</h1>
<h2>Heading 2</h2>
<h3>Heading 3</h3>
<h4>Heading 4</h4>
<h5>Heading 5</h5>
<h6>Heading 6</h6>

<h2>Text Containers</h2>
<blockquote>This is a blockquote element that can be used for citations or highlighting important text blocks.</blockquote>

<code style="padding: 8px 16px; border-radius: 4px;">
This is a code block that preserves formatting and spacing.
It can be used to display source code or other preformatted text.
</code>

<h2>Other Elements</h2>
<hr/>
<p><small>This is smaller text that can be used for captions or footnotes.</small></p>
<p>Here's an example of an <img src="https://picsum.photos/200/100" alt="Sample image"/> inline image.</p>
<p>Here's an example of an <img src="https://picsum.photos/200/100" alt="Sample image" style="width: 100px; height: 100px;"/> inline image with inline styles.</p>
''';

final class TypographyExample extends ExamplePage {
  const TypographyExample({super.key}) : super(title: 'Typography');

  @override
  String get html => _html;
}
