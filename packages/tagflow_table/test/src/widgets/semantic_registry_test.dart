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
