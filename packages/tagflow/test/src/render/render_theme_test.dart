import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/tagflow.dart';

Widget _app(Widget child, {ThemeData? theme}) {
  return MaterialApp(
    theme: theme,
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

/// The effective style of the text span that contains [text].
TextStyle _styleOf(WidgetTester tester, String text) {
  final paragraphs = tester.renderObjectList<RenderParagraph>(
    find.byType(RichText),
  );
  for (final paragraph in paragraphs) {
    final found = _find(paragraph.text, text, const TextStyle());
    if (found != null) return found;
  }
  throw StateError('No text span contains "$text"');
}

TextStyle? _find(InlineSpan span, String text, TextStyle inherited) {
  if (span is! TextSpan) return null;
  final style = inherited.merge(span.style);
  if (span.text?.contains(text) ?? false) return style;
  for (final child in span.children ?? const <InlineSpan>[]) {
    final found = _find(child, text, style);
    if (found != null) return found;
  }
  return null;
}

RenderParagraph _paragraphOf(WidgetTester tester, String text) {
  return tester
      .renderObjectList<RenderParagraph>(find.byType(RichText))
      .firstWhere((p) => p.text.toPlainText().contains(text));
}

void main() {
  group('render theme', () {
    testWidgets('should apply renderTheme heading styles over the defaults', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          const Tagflow.html(
            html: '<h1>Title</h1>',
            renderTheme: TagflowRenderTheme(h1Style: TextStyle(fontSize: 40)),
          ),
        ),
      );

      final style = _styleOf(tester, 'Title');
      expect(style.fontSize, 40);
      expect(style.fontWeight, FontWeight.w700);
    });

    testWidgets('should map theme: h1Style onto the runtime renderer', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (context) => Tagflow.html(
              html: '<h1>Title</h1>',
              theme: TagflowTheme.fromTheme(
                Theme.of(context),
                h1Style: const TextStyle(fontSize: 77),
              ),
            ),
          ),
        ),
      );

      expect(_styleOf(tester, 'Title').fontSize, 77);
    });

    testWidgets('should apply paragraph and link styles', (tester) async {
      await tester.pumpWidget(
        _app(
          const Tagflow.html(
            html: '<p>Body <a href="https://example.com">link</a></p>',
            renderTheme: TagflowRenderTheme(
              paragraphStyle: TextStyle(color: Color(0xFF00AA00)),
              linkStyle: TextStyle(color: Color(0xFFAA0000)),
            ),
          ),
        ),
      );

      expect(_styleOf(tester, 'Body').color, const Color(0xFF00AA00));
      expect(_styleOf(tester, 'link').color, const Color(0xFFAA0000));
    });

    testWidgets('should apply code block style and background', (tester) async {
      await tester.pumpWidget(
        _app(
          const Tagflow.markdown(
            markdown: '```\nx = 1\n```',
            renderTheme: TagflowRenderTheme(
              codeBlockStyle: TextStyle(fontSize: 21),
              codeBackgroundColor: Color(0xFF123456),
            ),
          ),
        ),
      );

      expect(_styleOf(tester, 'x = 1').fontSize, 21);
      expect(_styleOf(tester, 'x = 1').fontFamily, 'monospace');
      final decorations = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .map((box) => (box.decoration as BoxDecoration).color);
      expect(decorations, contains(const Color(0xFF123456)));
    });

    testWidgets('should apply theme: to Tagflow.document', (tester) async {
      final document = TagflowDocument(
        id: 'd',
        children: [
          TagflowDocumentNode.heading(
            id: 'h',
            level: 2,
            children: [TagflowDocumentNode.text(id: 't', text: 'Second')],
          ),
        ],
      );
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (context) => Tagflow.document(
              document,
              theme: TagflowTheme.fromTheme(
                Theme.of(context),
                h2Style: const TextStyle(fontSize: 33),
              ),
            ),
          ),
        ),
      );

      expect(_styleOf(tester, 'Second').fontSize, 33);
    });

    testWidgets('should derive defaults from the ambient Theme', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          const Tagflow.html(html: '<h1>Title</h1>'),
          theme: ThemeData(
            textTheme: const TextTheme(
              headlineLarge: TextStyle(fontSize: 50, fontFamily: 'Serif'),
            ),
          ),
        ),
      );

      final style = _styleOf(tester, 'Title');
      expect(style.fontSize, 50);
      expect(style.fontFamily, 'Serif');
    });

    testWidgets('should merge nested scopes', (tester) async {
      await tester.pumpWidget(
        _app(
          const TagflowRenderThemeScope(
            theme: TagflowRenderTheme(h1Style: TextStyle(fontSize: 40)),
            child: Tagflow.html(
              html: '<h1>Title</h1>',
              renderTheme: TagflowRenderTheme(
                h1Style: TextStyle(color: Color(0xFF0000AA)),
              ),
            ),
          ),
        ),
      );

      final style = _styleOf(tester, 'Title');
      expect(style.fontSize, 40);
      expect(style.color, const Color(0xFF0000AA));
    });

    testWidgets('should apply spacing from the render theme', (tester) async {
      await tester.pumpWidget(
        _app(
          const Tagflow.html(
            html: '<p>One</p>',
            renderTheme: TagflowRenderTheme(paragraphSpacing: 30),
          ),
        ),
      );

      final padding = tester.widget<Padding>(
        find
            .ancestor(of: find.byType(RichText), matching: find.byType(Padding))
            .first,
      );
      expect(padding.padding, const EdgeInsets.only(bottom: 30));
    });
  });

  group('inline CSS', () {
    Future<void> pump(WidgetTester tester, String html, {bool allow = true}) {
      return tester.pumpWidget(
        _app(
          Tagflow.html(
            html: html,
            adapter: TagflowHtmlAdapter(
              policy: TagflowContentPolicy(allowInlineStyles: allow),
            ),
          ),
        ),
      );
    }

    testWidgets('should apply color', (tester) async {
      await pump(tester, '<p style="color: #ff0000">Red</p>');
      expect(_styleOf(tester, 'Red').color, const Color(0xFFFF0000));
    });

    testWidgets('should apply color on an inline span', (tester) async {
      await pump(tester, '<p>A <span style="color: blue">blue</span></p>');
      expect(_styleOf(tester, 'blue').color, const Color(0xFF0000FF));
    });

    testWidgets('should apply background-color', (tester) async {
      await pump(
        tester,
        '<p>A <span style="background-color: #00ff00">g</span></p>',
      );
      expect(_styleOf(tester, 'g').backgroundColor, const Color(0xFF00FF00));
    });

    testWidgets('should apply background-color on a block', (tester) async {
      await pump(tester, '<div style="background-color: #00ff00">g</div>');
      final colors = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .map((box) => (box.decoration as BoxDecoration).color);
      expect(colors, contains(const Color(0xFF00FF00)));
    });

    testWidgets('should apply text-align', (tester) async {
      await pump(tester, '<p style="text-align: center">Centered</p>');
      expect(_paragraphOf(tester, 'Centered').textAlign, TextAlign.center);
      expect(find.byType(Align), findsWidgets);
    });

    testWidgets('should apply font-weight', (tester) async {
      await pump(tester, '<p><span style="font-weight: bold">B</span></p>');
      expect(_styleOf(tester, 'B').fontWeight, FontWeight.w700);
    });

    testWidgets('should apply font-style', (tester) async {
      await pump(tester, '<p><span style="font-style: italic">I</span></p>');
      expect(_styleOf(tester, 'I').fontStyle, FontStyle.italic);
    });

    testWidgets('should apply text-decoration', (tester) async {
      await pump(
        tester,
        '<p><span style="text-decoration: line-through">D</span></p>',
      );
      expect(_styleOf(tester, 'D').decoration, TextDecoration.lineThrough);
    });

    testWidgets('should apply font-size in px and em', (tester) async {
      await pump(
        tester,
        '<p><span style="font-size: 30px">P</span> '
        '<span style="font-size: 2em">E</span></p>',
      );
      expect(_styleOf(tester, 'P').fontSize, 30);
      expect(_styleOf(tester, 'E').fontSize, 28);
    });

    testWidgets('should ignore inline styles when the policy turns them off', (
      tester,
    ) async {
      await pump(tester, '<p style="color: #ff0000">Red</p>', allow: false);
      expect(_styleOf(tester, 'Red').color, isNot(const Color(0xFFFF0000)));
    });

    test('should keep only the safe subset of properties', () {
      final document = const TagflowHtmlAdapter().parse(
        '<p style="color: red; position: fixed; width: 9999px; '
        'font-size: 20px; text-align: right">x</p>',
      );
      final style = document.children.single.presentation.inlineStyle!;

      expect(style.color, 0xFFFF0000);
      expect(style.fontSize, 20);
      expect(style.textAlign, TagflowTextAlign.right);
      expect(
        style,
        TagflowInlineStyle(
          color: 0xFFFF0000,
          fontSize: 20,
          textAlign: TagflowTextAlign.right,
        ),
      );
    });
  });
}
