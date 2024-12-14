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
<span>Span</span>
<p><u>underlined</u></p>
<pre>Preformatted text</pre>
<p><s>strikethrough</s></p>
<p><b>bold</b></p>
<p><i>italic</i></p>
<p><em>emphasized</em></p>
<p><strong>strong</strong></p>
<p><small>small</small></p>
<p><mark>marked</mark></p>
<p><del>deleted</del></p>
<p><ins>inserted</ins></p>
<p><sub>subscript</sub></p>
<p><sup>superscript</sup></p>
<p><code>code</code></p>
''';

class TypographyExample extends ExamplePage {
  const TypographyExample({super.key});

  @override
  String get title => 'Typography Examples';

  @override
  String get html => _html;

  @override
  TagflowOptions? get options => TagflowOptions(
        debug: kDebugMode,
        linkTapCallback: (link, attributes) async {
          if (await canLaunchUrlString(link)) {
            await launchUrlString(link);
          }
        },
      );
}
