import 'package:flutter/material.dart' hide TableCell;
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow_table/tagflow_table.dart';

void main() {
  group('RenderTagflowTable', () {
    late RenderTagflowTable renderTable;

    setUp(() {
      renderTable = RenderTagflowTable()
        ..setTableDimensions(2, 2)
        ..setBorder(TagflowTableBorder());
    });

    test('initial setup is correct', () {
      expect(renderTable.childCount, 0);
    });

    testWidgets('performs layout correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TagflowTable(
              rowCount: 2,
              columnCount: 2,
              border: TagflowTableBorder(),
              children: const [
                TableCell(
                  row: 0,
                  column: 0,
                  child: SizedBox(width: 100, height: 50),
                ),
                TableCell(
                  row: 0,
                  column: 1,
                  child: SizedBox(width: 100, height: 50),
                ),
                TableCell(
                  row: 1,
                  column: 0,
                  child: SizedBox(width: 100, height: 50),
                ),
                TableCell(
                  row: 1,
                  column: 1,
                  child: SizedBox(width: 100, height: 50),
                ),
              ],
            ),
          ),
        ),
      );

      final table = tester.renderObject<RenderTagflowTable>(
        find.byType(TagflowTable),
      );
      expect(table.size.width, greaterThan(0));
      expect(table.size.height, greaterThan(0));
    });

    testWidgets('handles rowspan and colspan', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TagflowTable(
              rowCount: 2,
              columnCount: 2,
              border: TagflowTableBorder(),
              children: const [
                TableCell(
                  row: 0,
                  column: 0,
                  rowSpan: 2,
                  colSpan: 2,
                  child: SizedBox(width: 200, height: 100),
                ),
              ],
            ),
          ),
        ),
      );

      final table = tester.renderObject<RenderTagflowTable>(
        find.byType(TagflowTable),
      );
      expect(table.size.width, greaterThan(0));
      expect(table.size.height, greaterThan(0));
    });

    testWidgets('handles empty cells', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TagflowTable(
              rowCount: 2,
              columnCount: 2,
              border: TagflowTableBorder(),
              children: const [
                TableCell(
                  row: 0,
                  column: 0,
                  child: SizedBox(width: 100, height: 50),
                ),
                // Leave other cells empty
              ],
            ),
          ),
        ),
      );

      final table = tester.renderObject<RenderTagflowTable>(
        find.byType(TagflowTable),
      );
      expect(table.size.width, greaterThan(0));
      expect(table.size.height, greaterThan(0));
    });

    testWidgets('applies border correctly', (tester) async {
      final border = TagflowTableBorder(
        left: const BorderSide(width: 2),
        right: const BorderSide(width: 2),
        top: const BorderSide(width: 2),
        bottom: const BorderSide(width: 2),
        horizontalInside: const BorderSide(),
        verticalInside: const BorderSide(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TagflowTable(
              rowCount: 2,
              columnCount: 2,
              border: border,
              children: const [
                TableCell(
                  row: 0,
                  column: 0,
                  child: SizedBox(width: 100, height: 50),
                ),
                TableCell(
                  row: 0,
                  column: 1,
                  child: SizedBox(width: 100, height: 50),
                ),
                TableCell(
                  row: 1,
                  column: 0,
                  child: SizedBox(width: 100, height: 50),
                ),
                TableCell(
                  row: 1,
                  column: 1,
                  child: SizedBox(width: 100, height: 50),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pump(); // Wait for layout and paint
    });

    testWidgets('computes dry layout correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TagflowTable(
              rowCount: 2,
              columnCount: 2,
              border: TagflowTableBorder(),
              children: const [
                TableCell(
                  row: 0,
                  column: 0,
                  child: SizedBox(width: 100, height: 50),
                ),
                TableCell(
                  row: 0,
                  column: 1,
                  child: SizedBox(width: 100, height: 50),
                ),
              ],
            ),
          ),
        ),
      );

      final table = tester.renderObject<RenderTagflowTable>(
        find.byType(TagflowTable),
      );

      final constraints = BoxConstraints.loose(const Size(500, 500));
      final size = table.getDryLayout(constraints);
      expect(size.width, greaterThan(0));
      expect(size.height, greaterThan(0));
    });
  });
}
