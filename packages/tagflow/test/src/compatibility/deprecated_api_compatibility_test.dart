import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/legacy.dart';

// Pins Tagflow.html(...) output for representative HTML so the 1.x
// deprecation of the legacy converter API cannot change what existing users
// see. Deprecated entry points must render pixel-identical output to their
// replacements.

const _representativeHtml = '''
<h1>Release notes</h1>
<p>Tagflow renders <strong>bold</strong>, <em>italic</em>, <u>underline</u>,
<code>inline code</code> and <a href="https://example.com">links</a>.</p>
<h2>Lists</h2>
<ul>
  <li>First item</li>
  <li>Second item
    <ol>
      <li>Nested one</li>
      <li>Nested two</li>
    </ol>
  </li>
</ul>
<blockquote>Quoted text with <strong>emphasis</strong>.</blockquote>
<pre><code>final answer = 42;</code></pre>
<hr>
<table border="1">
  <tr><th>Name</th><th>Value</th></tr>
  <tr><td>Alpha</td><td>1</td></tr>
  <tr><td colspan="2">Spanning cell</td></tr>
</table>
<p style="color: #1565C0; text-align: center;">Styled paragraph</p>
<x-badge>legacy badge</x-badge>
''';

const _runtimeGolden = 'goldens/representative_runtime.png';
const _legacyConverterGolden = 'goldens/representative_legacy_converter.png';

final class _BadgeConverter extends ElementConverter<TagflowElement> {
  const _BadgeConverter();

  @override
  Set<String> get supportedTags => {'x-badge'};

  @override
  Widget convert(
    TagflowElement element,
    BuildContext context,
    TagflowConverter converter,
  ) {
    return const ColoredBox(
      color: Color(0xFFFFE082),
      child: Text('converted badge'),
    );
  }
}

Future<void> _pump(WidgetTester tester, Widget tagflow) async {
  tester.view
    ..physicalSize = const Size(600, 1400)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
        body: RepaintBoundary(
          key: const ValueKey('tagflow-output'),
          child: SingleChildScrollView(child: tagflow),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder get _output => find.byKey(const ValueKey('tagflow-output'));

void main() {
  group('Deprecated API compatibility', () {
    testWidgets('Tagflow.html renders representative HTML unchanged', (
      tester,
    ) async {
      await _pump(tester, const Tagflow.html(html: _representativeHtml));

      expect(find.text('Release notes'), findsOneWidget);
      await expectLater(_output, matchesGoldenFile(_runtimeGolden));
    });

    testWidgets('deprecated Tagflow() matches Tagflow.html output', (
      tester,
    ) async {
      await _pump(tester, const Tagflow(html: _representativeHtml));

      await expectLater(_output, matchesGoldenFile(_runtimeGolden));
    });

    testWidgets('deprecated options: matches viewOptions: output', (
      tester,
    ) async {
      await _pump(
        tester,
        const Tagflow.html(
          html: _representativeHtml,
          options: TagflowOptions(enableImageCache: false),
        ),
      );
      await expectLater(_output, matchesGoldenFile(_runtimeGolden));

      await _pump(
        tester,
        const Tagflow.html(
          html: _representativeHtml,
          viewOptions: TagflowViewOptions(enableImageCache: false),
        ),
      );
      await expectLater(_output, matchesGoldenFile(_runtimeGolden));
    });

    testWidgets('legacy converters keep the legacy rendering pipeline', (
      tester,
    ) async {
      await _pump(
        tester,
        const Tagflow.html(
          html: _representativeHtml,
          converters: [_BadgeConverter()],
        ),
      );

      expect(find.text('converted badge'), findsOneWidget);
      expect(find.text('legacy badge'), findsNothing);
      await expectLater(_output, matchesGoldenFile(_legacyConverterGolden));

      await _pump(
        tester,
        const Tagflow(
          html: _representativeHtml,
          converters: [_BadgeConverter()],
        ),
      );
      await expectLater(_output, matchesGoldenFile(_legacyConverterGolden));
    });

    testWidgets('deprecated render boundary option matches renderBoundary:', (
      tester,
    ) async {
      const html = '<p>Visible</p><!--cut--><p>Hidden</p>';
      const boundary = TagflowRenderBoundary.comment(end: 'cut');

      await _pump(
        tester,
        const Tagflow.html(
          html: html,
          options: TagflowOptions(renderBoundary: boundary),
        ),
      );
      expect(find.text('Visible'), findsOneWidget);
      expect(find.text('Hidden'), findsNothing);

      await _pump(
        tester,
        const Tagflow.html(html: html, renderBoundary: boundary),
      );
      expect(find.text('Visible'), findsOneWidget);
      expect(find.text('Hidden'), findsNothing);
    });
  });
}
