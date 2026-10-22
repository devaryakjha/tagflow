import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/tagflow.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final document = TagflowDocument(
    id: 'doc',
    children: [
      TagflowDocumentNode.codeBlock(
        id: 'code',
        text: 'final answer = 42;',
        language: 'language-dart',
      ),
    ],
  );

  Widget buildDocument(TagflowViewOptions viewOptions) {
    return MaterialApp(
      home: Scaffold(
        body: Tagflow.document(document, viewOptions: viewOptions),
      ),
    );
  }

  group('code blocks', () {
    testWidgets('should render plain monospace text without a highlighter', (
      tester,
    ) async {
      await tester.pumpWidget(buildDocument(TagflowViewOptions.defaults));

      final text = tester.widget<Text>(find.text('final answer = 42;'));
      expect(text.style?.fontFamily, 'monospace');
      expect(find.text('Copy'), findsNothing);
    });

    testWidgets('should render spans from a custom highlighter', (
      tester,
    ) async {
      TagflowCodeHighlightRequest? request;

      await tester.pumpWidget(
        buildDocument(
          TagflowViewOptions(
            codeBlock: TagflowCodeBlockOptions(
              highlighter: (context, value) {
                request = value;
                return TextSpan(
                  style: value.style,
                  children: const [
                    TextSpan(
                      text: 'final',
                      style: TextStyle(color: Color(0xFF7C4DFF)),
                    ),
                    TextSpan(text: ' answer = 42;'),
                  ],
                );
              },
            ),
          ),
        ),
      );

      expect(request?.source, 'final answer = 42;');
      expect(request?.language, 'dart');
      expect(request?.node.id, 'code');
      expect(request?.style.fontFamily, 'monospace');

      final richText = tester.widget<RichText>(
        find.byWidgetPredicate(
          (widget) =>
              widget is RichText &&
              widget.text.toPlainText() == 'final answer = 42;',
        ),
      );
      final keyword = _findSpan(richText.text, 'final');
      expect(keyword?.style?.color, const Color(0xFF7C4DFF));
    });

    testWidgets('should fall back to plain text when highlighter returns '
        'null', (tester) async {
      await tester.pumpWidget(
        buildDocument(
          TagflowViewOptions(
            codeBlock: TagflowCodeBlockOptions(
              highlighter: (context, request) => null,
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('final answer = 42;'));
      expect(text.data, 'final answer = 42;');
      expect(text.style?.fontFamily, 'monospace');
    });

    testWidgets('should copy source and call onCopy from the copy button', (
      tester,
    ) async {
      final clipboard = <String?>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            final arguments = call.arguments as Map<Object?, Object?>;
            clipboard.add(arguments['text'] as String?);
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );

      TagflowCodeCopyDetails? copied;
      await tester.pumpWidget(
        buildDocument(
          TagflowViewOptions(
            codeBlock: TagflowCodeBlockOptions(
              showCopyButton: true,
              onCopy: (details) => copied = details,
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Copy code'), findsOneWidget);

      await tester.tap(find.text('Copy'));
      await tester.pump();

      expect(clipboard, ['final answer = 42;']);
      expect(copied?.source, 'final answer = 42;');
      expect(copied?.language, 'dart');
      expect(copied?.node.id, 'code');
      expect(find.text('Copied'), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
      expect(find.text('Copy'), findsOneWidget);
    });

    testWidgets('should read the language from a nested HTML code element', (
      tester,
    ) async {
      TagflowCodeHighlightRequest? request;

      await tester.pumpWidget(
        MaterialApp(
          home: Tagflow.html(
            html: '<pre><code class="language-js">let x = 1;</code></pre>',
            viewOptions: TagflowViewOptions(
              codeBlock: TagflowCodeBlockOptions(
                highlighter: (context, value) {
                  request = value;
                  return null;
                },
              ),
            ),
          ),
        ),
      );

      expect(request?.language, 'js');
      expect(request?.source, 'let x = 1;');
    });
  });

  group('TagflowCodeBlockOptions.normalizeLanguage', () {
    test('should strip language and lang prefixes', () {
      expect(
        TagflowCodeBlockOptions.normalizeLanguage('language-dart'),
        'dart',
      );
      expect(TagflowCodeBlockOptions.normalizeLanguage('lang-py'), 'py');
      expect(
        TagflowCodeBlockOptions.normalizeLanguage('hljs language-ts'),
        'ts',
      );
    });

    test('should fall back to the first token or null', () {
      expect(TagflowCodeBlockOptions.normalizeLanguage('dart'), 'dart');
      expect(TagflowCodeBlockOptions.normalizeLanguage('  '), isNull);
      expect(TagflowCodeBlockOptions.normalizeLanguage(null), isNull);
    });
  });
}

TextSpan? _findSpan(InlineSpan span, String text) {
  TextSpan? match;
  span.visitChildren((child) {
    if (child is TextSpan && child.text == text) {
      match = child;
      return false;
    }
    return true;
  });
  return match;
}
