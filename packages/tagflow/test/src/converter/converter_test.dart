// test/src/converter/converter_test.dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/tagflow.dart';

void main() {
  group('TagflowConverter', () {
    late TagflowConverter converter;

    setUp(() {
      converter = TagflowConverter()
        ..register(const ContainerConverter())
        ..register(const TextConverter())
        ..register(const HeadingConverter());
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

      expect(find.byType(Padding), findsOneWidget);
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

      expect(find.byType(DefaultTextStyle), findsOneWidget);
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
}
