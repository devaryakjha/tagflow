import 'package:flutter/foundation.dart';
import 'package:tagflow/tagflow.dart';
import 'package:tagflow_example/widgets/example_page.dart';
import 'package:url_launcher/url_launcher_string.dart';

// complete typography example with tags like h1, h2, h3, p, span, etc.
const _html = '''
<h1>Heading 1</h1>
<h2>Heading 2</h2>
<h3>Heading 3</h3>
<h4>Heading 4</h4>
<h5>Heading 5</h5>
<h6>Heading 6</h6>
<p>Paragraph</p>
<p>Paragraph with <a href="https://github.com/devaryakjha/tagflow">link</a></p>
<span>span</span>
<p><u>underlined</u></p>
<pre><p>Preformatted text</p></pre>
<p><s>strikethrough</s></p>
<p><b>bold</b></p>
<p><i>italic</i></p>
<p><em>emphasized</em></p>
<p><strong>strong</strong></p>
<p><small>small</small></p>
<p><mark>marked</mark></p>
<p><del>deleted</del></p>
<p><ins>inserted</ins></p>
<p><code>code</code></p>
<h3>Subscripts and Superscripts</h3>
<pre>
<p>C<sub>6</sub>H<sub>12</sub>O<sub>6</sub></p>
<br />
<p>2<sup>2</sup> = 4</p>
<br />
<p>E = mc<sup>2</sup></p>
<br />
<p>x<sup>2</sup> + y<sup>2</sup> = z<sup>2</sup></p>
<br />
<p>x<sub>1</sub> + x<sub>2</sub> + x<sub>3</sub> + x<sub>4</sub> = 0</p>
</pre>
''';

class TypographyExample extends ExamplePage {
  const TypographyExample({super.key});

  @override
  String get title => 'Typography Examples';

  @override
  String get html => _html;

  @override
  TagflowOptions? get options => TagflowOptions(
        selectable: const TagflowSelectableOptions(enabled: true),
        debug: kDebugMode,
        linkTapCallback: (link, attributes) async {
          if (await canLaunchUrlString(link)) {
            await launchUrlString(link);
          }
        },
      );
}
