import 'package:flutter/material.dart' hide TableCell;
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/tagflow.dart';
import 'package:tagflow_table/tagflow_table.dart';

void main() {
  group('tagflowTableComponents', () {
    testWidgets('renders semantic document tables through TagflowTable', (
      tester,
    ) async {
      final document = TagflowDocument(
        id: 'doc-table',
        children: [
          TagflowDocumentNode.table(
            id: 'table',
            children: [
              TagflowDocumentNode.tableRow(
                id: 'row-header',
                children: [
                  TagflowDocumentNode.tableCell(
                    id: 'cell-header',
                    header: true,
                    children: [
                      TagflowDocumentNode.text(id: 'header-text', text: 'Name'),
                    ],
                  ),
                ],
              ),
              TagflowDocumentNode.tableRow(
                id: 'row-body',
                children: [
                  TagflowDocumentNode.tableCell(
                    id: 'cell-body',
                    children: [
                      TagflowDocumentNode.text(
                        id: 'body-text',
                        text: 'Tagflow',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      );
      final registry = TagflowComponentRegistry(
        extensions: [tagflowTableComponents()],
      );

      await tester.pumpWidget(
        MaterialApp(home: Tagflow.document(document, registry: registry)),
      );

      expect(find.byType(TagflowTable), findsOneWidget);
      expect(find.byType(Table), findsNothing);
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Tagflow'), findsOneWidget);
      expect(_richTextStyle(tester, 'Name')?.fontWeight, FontWeight.w700);
    });

    testWidgets('preserves semantic row and column spans', (tester) async {
      final document = TagflowDocument(
        id: 'doc-spans',
        children: [
          TagflowDocumentNode.table(
            id: 'table',
            children: [
              TagflowDocumentNode.tableRow(
                id: 'row-0',
                children: [
                  TagflowDocumentNode.tableCell(
                    id: 'span-rows',
                    rowSpan: 2,
                    children: [
                      TagflowDocumentNode.text(
                        id: 'span-rows-text',
                        text: 'Spans rows',
                      ),
                    ],
                  ),
                  TagflowDocumentNode.tableCell(
                    id: 'top-right',
                    children: [
                      TagflowDocumentNode.text(
                        id: 'top-right-text',
                        text: 'Top right',
                      ),
                    ],
                  ),
                ],
              ),
              TagflowDocumentNode.tableRow(
                id: 'row-1',
                children: [
                  TagflowDocumentNode.tableCell(
                    id: 'middle-right',
                    children: [
                      TagflowDocumentNode.text(
                        id: 'middle-right-text',
                        text: 'Middle right',
                      ),
                    ],
                  ),
                ],
              ),
              TagflowDocumentNode.tableRow(
                id: 'row-2',
                children: [
                  TagflowDocumentNode.tableCell(
                    id: 'bottom-span',
                    colSpan: 2,
                    children: [
                      TagflowDocumentNode.text(
                        id: 'bottom-span-text',
                        text: 'Bottom span',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      );
      final registry = TagflowComponentRegistry(
        extensions: [tagflowTableComponents()],
      );

      await tester.pumpWidget(
        MaterialApp(home: Tagflow.document(document, registry: registry)),
      );

      final table = tester.widget<TagflowTable>(find.byType(TagflowTable));
      expect(table.rowCount, 3);
      expect(table.columnCount, 2);

      expect(_tableCellForText(tester, 'Spans rows').rowSpan, 2);
      expect(_tableCellForText(tester, 'Spans rows').column, 0);
      expect(_tableCellForText(tester, 'Middle right').column, 1);
      expect(_tableCellForText(tester, 'Bottom span').colSpan, 2);
    });

    testWidgets('keeps inline cell content on one line', (tester) async {
      final document = TagflowDocument(
        id: 'doc-inline-cell',
        children: [
          TagflowDocumentNode.table(
            id: 'table',
            children: [
              TagflowDocumentNode.tableRow(
                id: 'row',
                children: [
                  TagflowDocumentNode.tableCell(
                    id: 'cell',
                    children: [
                      TagflowDocumentNode.text(id: 'one', text: 'One'),
                      TagflowDocumentNode.container(
                        id: 'strong',
                        presentation: TagflowPresentation(
                          inlineSemantics: const {TagflowInlineSemantic.strong},
                          hints: const {'htmlTag': 'strong'},
                        ),
                        children: [
                          TagflowDocumentNode.text(id: 'two', text: 'Two'),
                        ],
                      ),
                      TagflowDocumentNode.text(id: 'three', text: 'Three'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      );
      final registry = TagflowComponentRegistry(
        extensions: [tagflowTableComponents()],
      );

      await tester.pumpWidget(
        MaterialApp(home: Tagflow.document(document, registry: registry)),
      );

      final oneY = tester.getTopLeft(find.text('One')).dy;
      expect(tester.getTopLeft(find.text('Two')).dy, oneY);
      expect(tester.getTopLeft(find.text('Three')).dy, oneY);
      expect(_richTextStyle(tester, 'Two')?.fontWeight, FontWeight.w700);
    });

    testWidgets('applies semantic cell padding and background hints', (
      tester,
    ) async {
      const rowBackground = Color(0xFFE8F1FF);
      const cellBackground = Color(0xFFFFF4CC);
      const cellPadding = EdgeInsets.fromLTRB(12, 10, 8, 6);
      final document = TagflowDocument(
        id: 'doc-cell-presentation',
        children: [
          TagflowDocumentNode.table(
            id: 'table',
            children: [
              TagflowDocumentNode.tableRow(
                id: 'row',
                presentation: TagflowPresentation(
                  hints: const {'backgroundColor': rowBackground},
                ),
                children: [
                  TagflowDocumentNode.tableCell(
                    id: 'row-backed-cell',
                    children: [
                      TagflowDocumentNode.text(
                        id: 'row-backed-text',
                        text: 'Row backed',
                      ),
                    ],
                  ),
                  TagflowDocumentNode.tableCell(
                    id: 'cell-backed-cell',
                    presentation: TagflowPresentation(
                      hints: const {
                        'backgroundColor': cellBackground,
                        'padding': cellPadding,
                      },
                    ),
                    children: [
                      TagflowDocumentNode.text(
                        id: 'cell-backed-text',
                        text: 'Cell backed',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      );
      final registry = TagflowComponentRegistry(
        extensions: [tagflowTableComponents()],
      );

      await tester.pumpWidget(
        MaterialApp(home: Tagflow.document(document, registry: registry)),
      );

      expect(_decoratedBoxColorForText(tester, 'Row backed'), rowBackground);
      expect(_decoratedBoxColorForText(tester, 'Cell backed'), cellBackground);
      expect(_paddingForText(tester, 'Cell backed'), cellPadding);
    });

    testWidgets('renders HTML table presentation hints through the registry', (
      tester,
    ) async {
      const rowBackground = Color(0xFFE8F1FF);
      const cellBackground = Color(0xFFFFF4CC);
      const html = '''
<table border="2" cellpadding="6" cellspacing="4">
  <tr style="background-color: #e8f1ff;">
    <td>Row backed</td>
    <td style="background-color: #fff4cc; padding: 4px;">Cell backed</td>
  </tr>
</table>
''';
      final document = const TagflowHtmlAdapter().parse(html);
      final registry = TagflowComponentRegistry(
        extensions: [tagflowTableComponents()],
      );

      await tester.pumpWidget(
        MaterialApp(home: Tagflow.document(document, registry: registry)),
      );

      final table = tester.widget<TagflowTable>(find.byType(TagflowTable));
      expect(table.border.left.width, 2);
      expect(table.border.horizontalInside.width, 1);
      expect(table.columnSpacing, 4);
      expect(table.rowSpacing, 4);
      expect(_decoratedBoxColorForText(tester, 'Row backed'), rowBackground);
      expect(_decoratedBoxColorForText(tester, 'Cell backed'), cellBackground);
      expect(_paddingForText(tester, 'Row backed'), const EdgeInsets.all(6));
      expect(_paddingForText(tester, 'Cell backed'), const EdgeInsets.all(4));
    });

    testWidgets('renders HTML table captions through the semantic registry', (
      tester,
    ) async {
      const html = '''
<table>
  <caption>Revenue summary</caption>
  <tr><th>Quarter</th><th>Revenue</th></tr>
  <tr><td>Q1</td><td>12.4</td></tr>
</table>
''';
      final document = const TagflowHtmlAdapter().parse(html);
      final registry = TagflowComponentRegistry(
        extensions: [tagflowTableComponents()],
      );

      await tester.pumpWidget(
        MaterialApp(home: Tagflow.document(document, registry: registry)),
      );

      expect(find.byType(TagflowTable), findsOneWidget);
      expect(find.text('Revenue summary'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Revenue summary')).dy,
        lessThan(tester.getTopLeft(find.byType(TagflowTable)).dy),
      );
    });
  });
}

TableCell _tableCellForText(WidgetTester tester, String text) {
  final cellFinder = find.ancestor(
    of: find.text(text),
    matching: find.byType(TableCell),
  );
  expect(cellFinder, findsOneWidget);
  return tester.widget<TableCell>(cellFinder);
}

TextStyle? _richTextStyle(WidgetTester tester, String text) {
  final finder = find.byWidgetPredicate((widget) {
    if (widget is! RichText) return false;
    return widget.text.toPlainText() == text;
  });

  if (finder.evaluate().isEmpty) {
    return null;
  }

  return tester.widget<RichText>(finder.first).text.style;
}

Color? _decoratedBoxColorForText(WidgetTester tester, String text) {
  final finder = find.ancestor(
    of: find.text(text),
    matching: find.byWidgetPredicate((widget) => widget is DecoratedBox),
  );
  expect(finder, findsOneWidget);

  final decoratedBox = tester.widget<DecoratedBox>(finder);
  final decoration = decoratedBox.decoration;
  return decoration is BoxDecoration ? decoration.color : null;
}

EdgeInsetsGeometry? _paddingForText(WidgetTester tester, String text) {
  final finder = find.ancestor(
    of: find.text(text),
    matching: find.byWidgetPredicate((widget) => widget is Padding),
  );
  expect(finder, findsOneWidget);

  return tester.widget<Padding>(finder).padding;
}
