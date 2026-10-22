@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/tagflow.dart';

import 'golden_harness.dart';

void main() {
  group('built-in node kind goldens', () {
    tagflowGoldenTest(
      'paragraph',
      html: '''
<p>Tagflow renders rich content into native Flutter widgets.</p>
<p>A second paragraph keeps its own spacing below the first one.</p>
''',
    );

    tagflowGoldenTest(
      'headings',
      html: '''
<h1>Heading 1</h1>
<h2>Heading 2</h2>
<h3>Heading 3</h3>
<h4>Heading 4</h4>
<h5>Heading 5</h5>
<h6>Heading 6</h6>
''',
    );

    tagflowGoldenTest(
      'inline_styles',
      html: '''
<p><strong>Strong</strong> <b>bold</b> <em>emphasis</em> <i>italic</i>
<u>underline</u> <del>deleted</del> <ins>inserted</ins> <mark>marked</mark>
<small>small</small> H<sub>2</sub>O x<sup>2</sup>
<strong><em>strong emphasis</em></strong></p>
''',
    );

    tagflowGoldenTest(
      'links',
      html: '''
<p>Read the <a href="https://docs.arya.run/tagflow">documentation</a> or
<a href="https://github.com/devaryakjha/tagflow"><strong>browse the
source</strong></a>.</p>
''',
    );

    tagflowGoldenTest(
      'lists',
      html: '''
<ul>
  <li>Unordered item</li>
  <li>Item with a nested list
    <ul>
      <li>Nested unordered</li>
      <li>Nested ordered
        <ol>
          <li>Deep one</li>
          <li>Deep two</li>
        </ol>
      </li>
    </ul>
  </li>
</ul>
<ol start="3">
  <li>Starts at three</li>
  <li>A longer ordered item that wraps onto a second line to check marker
  alignment against wrapped text.</li>
</ol>
''',
    );

    tagflowGoldenTest(
      'description_list',
      html: '''
<dl>
  <dt>Parser</dt>
  <dd>Turns HTML into a semantic document.</dd>
  <dt>Registry</dt>
  <dd>Maps node kinds to Flutter components.</dd>
  <dd>Supports overrides and extensions.</dd>
</dl>
''',
    );

    tagflowGoldenTest(
      'blockquote',
      html: '''
<blockquote>
  <p>Simple things should be simple, complex things should be possible.</p>
  <p><em>Alan Kay</em></p>
</blockquote>
''',
    );

    tagflowGoldenTest(
      'code_block',
      html: '''
<pre><code class="language-dart">void main() {
  final greeting = 'Hello, Tagflow';
  print(greeting);
}</code></pre>
''',
    );

    tagflowGoldenTest(
      'inline_code',
      html: '<p>Call <code>Tagflow.html</code> with a markup string.</p>',
    );

    tagflowGoldenTest(
      'image_placeholder',
      html: '''
<p>Before the image.</p>
<img src="https://example.com/missing.png" alt="Missing" width="200" height="100">
<p>After the image.</p>
''',
      viewOptions: TagflowViewOptions(
        imageErrorBuilder: (context, error, stackTrace) => const SizedBox(
          width: 200,
          height: 100,
          child: ColoredBox(
            color: Color(0x1F808080),
            child: Center(child: Text('Image unavailable')),
          ),
        ),
      ),
    );

    tagflowGoldenTest(
      'table',
      html: '''
<table>
  <caption>Release plan</caption>
  <tr><th>Phase</th><th>Version</th></tr>
  <tr><td>Beta</td><td>1.0.0-beta.1</td></tr>
  <tr><td>Stable</td><td>1.0.0</td></tr>
</table>
''',
    );

    tagflowGoldenTest(
      'horizontal_rule',
      html: '<p>Above the rule.</p><hr><p>Below the rule.</p>',
    );

    tagflowGoldenTest(
      'unsupported_fallback',
      html: '''
<p>Unknown empty element:</p>
<x-widget></x-widget>
<p>Unknown element with content:</p>
<x-card><p>Children still render.</p></x-card>
''',
    );

    tagflowGoldenTest(
      'details_closed',
      html: '''
<details>
  <summary>Show more</summary>
  <p>Hidden until expanded.</p>
</details>
''',
    );

    tagflowGoldenTest(
      'details_open',
      html: '''
<details open>
  <summary>Show less</summary>
  <p>Visible because the element is open.</p>
</details>
''',
    );
  });
}
