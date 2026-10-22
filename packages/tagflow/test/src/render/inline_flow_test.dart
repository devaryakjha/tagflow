import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/tagflow.dart';

void main() {
  group('inline flow', () {
    testWidgets('should render a paragraph of mixed inline runs as one text', (
      tester,
    ) async {
      final document = const TagflowMarkdownAdapter().parse(
        'You asked: *hi there*. Then `code`.\nnext **bold\nword** end.',
      );

      await tester.pumpWidget(_app(Tagflow.document(document)));

      expect(find.byType(RichText), findsOneWidget);
      expect(
        find.text(
          'You asked: hi there. Then code. next bold word end.',
          findRichText: true,
        ),
        findsOneWidget,
      );
      expect(_spanStyle(tester, 'hi there')?.fontStyle, FontStyle.italic);
      expect(_spanStyle(tester, 'code')?.fontFamily, 'monospace');
      expect(_spanStyle(tester, 'bold word')?.fontWeight, FontWeight.w700);
    });

    testWidgets('should wrap inline runs word by word at narrow widths', (
      tester,
    ) async {
      final document = const TagflowMarkdownAdapter().parse(
        'Start *emph words that run long*. End.',
      );

      await tester.pumpWidget(
        _app(SizedBox(width: 200, child: Tagflow.document(document))),
      );

      final paragraph = tester.renderObject<RenderParagraph>(
        find.byType(RichText),
      );
      double lineOf(int offset) => paragraph
          .getOffsetForCaret(TextPosition(offset: offset), Rect.zero)
          .dy;

      // "emph" starts on the first line, right after "Start ", instead
      // of the whole emphasis run moving to a line of its own.
      expect(lineOf(6), lineOf(0));
      expect(paragraph.size.height, greaterThan(lineOf(0) + 20));
    });

    testWidgets('should merge bare inline children of a list item', (
      tester,
    ) async {
      final document = const TagflowMarkdownAdapter().parse(
        '- some **bold** text',
      );

      await tester.pumpWidget(_app(Tagflow.document(document)));

      expect(find.text('some bold text', findRichText: true), findsOneWidget);
    });

    testWidgets('should handle an empty paragraph', (tester) async {
      final document = TagflowDocument(
        id: 'empty',
        children: [TagflowDocumentNode.paragraph(id: 'p', children: const [])],
      );

      await tester.pumpWidget(_app(Tagflow.document(document)));

      expect(tester.takeException(), isNull);
    });

    testWidgets('should keep deeply nested inline styles', (tester) async {
      final document = const TagflowHtmlAdapter().parse(
        '<p>a <strong>b <em>c <u>d</u></em></strong> e</p>',
      );

      await tester.pumpWidget(_app(Tagflow.document(document)));

      expect(find.text('a b c d e', findRichText: true), findsOneWidget);
      final style = _spanStyle(tester, 'd');
      expect(style?.fontWeight, FontWeight.w700);
      expect(style?.fontStyle, FontStyle.italic);
      expect(style?.decoration, TextDecoration.underline);
    });

    testWidgets('should call the link callback for nested link text', (
      tester,
    ) async {
      String? tappedUrl;
      final document = const TagflowHtmlAdapter().parse(
        '<p><a href="https://example.com/x"><strong>Open</strong></a></p>',
      );

      await tester.pumpWidget(
        _app(
          Tagflow.document(
            document,
            viewOptions: TagflowViewOptions(
              linkTapCallback: (url, attributes) => tappedUrl = url,
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open', findRichText: true));

      expect(tappedUrl, 'https://example.com/x');
    });

    testWidgets('should render inline overrides through the registry', (
      tester,
    ) async {
      final document = const TagflowHtmlAdapter().parse(
        '<p>Call <code>run()</code> now.</p>',
      );

      await tester.pumpWidget(
        _app(
          Tagflow.document(
            document,
            registry: TagflowComponentRegistry(
              overrides: {
                TagflowNodeKind.inlineCode: (context, node) =>
                    Text('[${node.text}]'),
              },
            ),
          ),
        ),
      );

      expect(find.text('[run()]'), findsOneWidget);
      expect(find.textContaining('Call ', findRichText: true), findsOneWidget);
    });

    testWidgets('should keep node tap targets for inline nodes', (
      tester,
    ) async {
      TagflowDocumentNode? tapped;
      final document = TagflowDocument(
        id: 'tap',
        children: [
          TagflowDocumentNode.paragraph(
            id: 'p',
            children: [
              TagflowDocumentNode.text(id: 'a', text: 'Tap '),
              TagflowDocumentNode.inlineCode(id: 'code', text: 'me'),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        _app(
          Tagflow.document(
            document,
            viewOptions: TagflowViewOptions(
              nodeTapCallback: (details) => tapped = details.node,
              tapTargetKinds: const {TagflowNodeKind.inlineCode},
            ),
          ),
        ),
      );
      await tester.tap(find.text('me'));

      expect(tapped?.id, 'code');
    });
  });
}

Widget _app(Widget child) => MaterialApp(home: Scaffold(body: child));

TextStyle? _spanStyle(WidgetTester tester, String text) {
  TextStyle? styleOf(InlineSpan span, TextStyle? inherited) {
    final style = inherited?.merge(span.style) ?? span.style;
    if (span is TextSpan) {
      for (final child in span.children ?? const <InlineSpan>[]) {
        final match = styleOf(child, style);
        if (match != null) return match;
      }
    }
    return span.toPlainText() == text ? style : null;
  }

  for (final widget in tester.widgetList<RichText>(find.byType(RichText))) {
    final match = styleOf(widget.text, null);
    if (match != null) return match;
  }
  return null;
}
