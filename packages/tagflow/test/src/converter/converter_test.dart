// test/src/converter/converter_test.dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/tagflow.dart';

void main() {
  group('TagflowConverter', () {
    late TagflowConverter converter;

    setUp(() {
      converter = TagflowConverter();
    });

    testWidgets('converts basic div correctly', (tester) async {
      final element = TagflowElement(
        tag: 'div',
        children: [TagflowElement.text('Hello')],
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) => converter.convert(
              element,
              context,
            ),
          ),
        ),
      );

      expect(find.byType(Column), findsOneWidget);
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('converts paragraph with text correctly', (tester) async {
      final element = TagflowElement(
        tag: 'p',
        children: [TagflowElement.text('Paragraph text')],
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) => converter.convert(
              element,
              context,
            ),
          ),
        ),
      );

      // expect(find.byType(Padding), findsOneWidget); Not yet
      expect(find.text('Paragraph text'), findsOneWidget);
    });

    testWidgets('converts heading correctly', (tester) async {
      final element = TagflowElement(
        tag: 'h1',
        children: [TagflowElement.text('Heading')],
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) => converter.convert(element, context),
          ),
        ),
      );

      expect(find.text('Heading'), findsOneWidget);
    });

    testWidgets('converts complex nested structure correctly', (tester) async {
      final parser = TagflowParser();
      final element = parser.parse('''
        <div>
          <p>This is a paragraph</p>
          <h1>This is a heading1</h1>
        </div>
      ''');
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) => converter.convert(element, context),
          ),
        ),
      );

      expect(find.text('This is a paragraph'), findsOneWidget);
      expect(find.text('This is a heading1'), findsOneWidget);
      expect(
        find.byType(Column),
        findsWidgets,
      ); // Should find multiple columns (div and p)
    });
  });

  group('TagflowConverter with custom converters', () {
    late TagflowConverter converter;

    setUp(() {
      converter = TagflowConverter();
    });

    testWidgets('custom converter takes precedence over built-in',
        (tester) async {
      // Create a custom paragraph converter
      final customParagraphConverter = CustomParagraphConverter();
      converter.addConverter(customParagraphConverter);

      final element = TagflowElement(
        tag: 'p',
        children: [TagflowElement.text('Test text')],
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              final widget = converter.convert(
                element,
                context,
              );
              print(element);
              return widget;
            },
          ),
        ),
      );

      // Should find our custom text, not the default paragraph implementation
      expect(find.text('Custom: Test text'), findsOneWidget);
      expect(find.text('Test text'), findsNothing);
    });

    testWidgets('falls back to built-in when no custom handler',
        (tester) async {
      final element = TagflowElement(
        tag: 'p',
        children: [TagflowElement.text('Test text')],
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              return converter.convert(
                element,
                context,
              );
            },
          ),
        ),
      );

      // Should find regular text with default paragraph implementation
      expect(find.text('Test text'), findsOneWidget);
    });
  });
}

class CustomParagraphConverter extends ElementConverter {
  @override
  Set<String> get supportedTags => {'p'};

  @override
  Widget convert(
    TagflowElement element,
    BuildContext context,
    TagflowConverter converter,
  ) {
    final children = converter.convertChildren(element.children, context);
    final child = children.first;
    final text = child is Text
        ? child.data ?? child.textSpan?.toPlainText()
        : 'No text widget found';
    return Text('Custom: $text');
  }
}
