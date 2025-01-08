import 'package:flutter/material.dart' hide TableCell;
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow_table/tagflow_table.dart';

void main() {
  group('TableCell', () {
    testWidgets('creates RenderTableCell', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TagflowTable(
            rowCount: 2,
            columnCount: 2,
            border: TagflowTableBorder(),
            children: const [
              TableCell(
                row: 0,
                column: 0,
                child: SizedBox(width: 100, height: 50),
              ),
            ],
          ),
        ),
      );

      expect(find.byType(TableCell), findsOneWidget);
      final renderObject = tester.renderObject<RenderBox>(
        find.byType(TableCell),
      );
      expect(renderObject, isNotNull);
    });

    testWidgets('updates row and column', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TagflowTable(
            rowCount: 2,
            columnCount: 2,
            border: TagflowTableBorder(),
            children: const [
              TableCell(
                row: 0,
                column: 0,
                child: SizedBox(width: 100, height: 50),
              ),
            ],
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: TagflowTable(
            rowCount: 2,
            columnCount: 2,
            border: TagflowTableBorder(),
            children: const [
              TableCell(
                row: 1,
                column: 1,
                child: SizedBox(width: 100, height: 50),
              ),
            ],
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderBox>(
        find.byType(TableCell),
      );
      expect(renderObject, isNotNull);
    });

    testWidgets('updates rowSpan and colSpan', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TagflowTable(
            rowCount: 3,
            columnCount: 3,
            border: TagflowTableBorder(),
            children: const [
              TableCell(
                row: 0,
                column: 0,
                rowSpan: 2,
                colSpan: 2,
                child: SizedBox(width: 100, height: 50),
              ),
            ],
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: TagflowTable(
            rowCount: 3,
            columnCount: 3,
            border: TagflowTableBorder(),
            children: const [
              TableCell(
                row: 0,
                column: 0,
                rowSpan: 3,
                colSpan: 3,
                child: SizedBox(width: 100, height: 50),
              ),
            ],
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderBox>(
        find.byType(TableCell),
      );
      expect(renderObject, isNotNull);
    });

    testWidgets('updates child', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: SizedBox(
              width: 400,
              height: 300,
              child: TagflowTable(
                rowCount: 2,
                columnCount: 2,
                border: TagflowTableBorder(),
                children: const [
                  TableCell(
                    row: 0,
                    column: 0,
                    child: SizedBox(width: 100, height: 50),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: SizedBox(
              width: 400,
              height: 300,
              child: TagflowTable(
                rowCount: 2,
                columnCount: 2,
                border: TagflowTableBorder(),
                children: const [
                  TableCell(
                    row: 0,
                    column: 0,
                    child: SizedBox(width: 200, height: 100),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderBox>(
        find.byType(TableCell),
      );
      expect(renderObject, isNotNull);
    });
  });
}
