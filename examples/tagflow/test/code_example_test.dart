import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/tagflow.dart';
import 'package:tagflow_example/screens/code_example.dart';
import 'package:tagflow_example/utils/dart_highlighter.dart';

TextSpan? _highlight(WidgetTester tester, String source, String? language) {
  return highlightDart(
    tester.element(find.byType(SizedBox)),
    TagflowCodeHighlightRequest(
      node: TagflowDocumentNode.codeBlock(id: 'code', text: source),
      source: source,
      language: language,
      style: const TextStyle(fontFamily: 'monospace'),
    ),
  );
}

void main() {
  group('highlightDart', () {
    testWidgets('should style keywords, strings, comments and types', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(theme: ThemeData(), home: const SizedBox()),
      );
      const source = "// note\nfinal name = 'Tagflow'; Widget w; var n = 42;";

      final span = _highlight(tester, source, 'dart')!;
      final children = span.children!.cast<TextSpan>();
      TextStyle? styleOf(String text) =>
          children.firstWhere((child) => child.text == text).style;

      expect(span.toPlainText(), source);
      expect(span.style?.fontFamily, 'monospace');
      expect(styleOf('// note')?.fontStyle, FontStyle.italic);
      expect(styleOf('final')?.fontWeight, FontWeight.w600);
      expect(styleOf("'Tagflow'")?.color, isNotNull);
      expect(styleOf('Widget')?.color, isNotNull);
      expect(styleOf('42')?.color, isNotNull);
      expect(styleOf('name'), isNull);
    });

    testWidgets('should keep empty source as an empty span', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));

      expect(_highlight(tester, '', 'dart')?.toPlainText(), '');
    });

    testWidgets('should leave other languages to the plain renderer', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));

      expect(_highlight(tester, 'a: 1', 'yaml'), isNull);
      expect(_highlight(tester, 'a: 1', null), isNull);
    });
  });

  testWidgets('should copy a code block and confirm with a snack bar', (
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

    await tester.pumpWidget(const MaterialApp(home: CodeExample()));
    await tester.pump();

    expect(find.text('Copy'), findsNWidgets(2));

    await tester.tap(find.text('Copy').first);
    await tester.pump();

    expect(clipboard.single, startsWith('// Render a streamed answer.'));
    expect(find.text('Copied 7 lines of dart'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('code-copy-button')));
    await tester.pump(const Duration(seconds: 5));

    expect(find.text('Copy'), findsNothing);
  });
}
