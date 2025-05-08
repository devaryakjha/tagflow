import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/tagflow.dart';

void main() {
  group('TableConverter', () {
    const converter = TableConverter();

    test('supports table tag', () {
      expect(converter.supportedTags, {'table'});
    });

    testWidgets('renders basic table structure', (tester) async {
      const table = TagflowTableElement(
        tag: 'table',
        rowCount: 2,
        columnCount: 2,
        rows: [
          TagflowElement(
            tag: 'tr',
            children: [
              TagflowElement(tag: 'td', textContent: 'Cell 1'),
              TagflowElement(tag: 'td', textContent: 'Cell 2'),
            ],
          ),
          TagflowElement(
            tag: 'tr',
            children: [
              TagflowElement(tag: 'td', textContent: 'Cell 3'),
              TagflowElement(tag: 'td', textContent: 'Cell 4'),
            ],
          ),
        ],
        spans: {},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TagflowThemeProvider(
              theme: const TagflowTheme.raw(
                defaultStyle: TagflowStyle.empty,
                styles: {},
              ),
              child: Builder(
                builder: (context) {
                  return converter.convert(table, context, TagflowConverter());
                },
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Table), findsOneWidget);
      expect(find.text('Cell 1'), findsOneWidget);
      expect(find.text('Cell 2'), findsOneWidget);
      expect(find.text('Cell 3'), findsOneWidget);
      expect(find.text('Cell 4'), findsOneWidget);
    });

    testWidgets('applies table styles correctly', (tester) async {
      const table = TagflowTableElement(
        tag: 'table',
        rowCount: 1,
        columnCount: 1,
        rows: [
          TagflowElement(
            tag: 'tr',
            children: [TagflowElement(tag: 'td', textContent: 'Cell')],
          ),
        ],
        spans: {},
        attributes: {'style': 'border: 1px solid black; background-color: red'},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TagflowThemeProvider(
              theme: TagflowTheme.raw(
                defaultStyle: TagflowStyle.empty,
                styles: {
                  'table': TagflowStyle(border: Border.all(color: Colors.blue)),
                },
              ),
              child: Builder(
                builder: (context) {
                  return converter.convert(table, context, TagflowConverter());
                },
              ),
            ),
          ),
        ),
      );

      final container = find.byType(Container).first;
      final containerWidget = tester.widget<Container>(container);
      expect(containerWidget.decoration, isNotNull);
    });
  });

  group('TableCellConverter', () {
    const converter = TableCellConverter();

    test('supports td, th, and tr tags', () {
      expect(converter.supportedTags, containsAll(['td', 'th', 'tr']));
    });

    test('forces widget span for td and th', () {
      expect(
        converter.shouldForceWidgetSpan(const TagflowElement(tag: 'td')),
        true,
      );
      expect(
        converter.shouldForceWidgetSpan(const TagflowElement(tag: 'th')),
        true,
      );
    });
  });
}
