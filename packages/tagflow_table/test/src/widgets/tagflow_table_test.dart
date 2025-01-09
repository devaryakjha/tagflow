import 'package:flutter/material.dart' hide TableCell;
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow_table/tagflow_table.dart';

void main() {
  group('TagflowTable', () {
    testWidgets('creates RenderTagflowTable', (tester) async {
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

      expect(find.byType(TagflowTable), findsOneWidget);
      final renderObject = tester.renderObject<RenderTagflowTable>(
        find.byType(TagflowTable),
      );
      expect(renderObject, isNotNull);
    });

    testWidgets('updates table dimensions', (tester) async {
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
            rowCount: 3,
            columnCount: 3,
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

      final renderObject = tester.renderObject<RenderTagflowTable>(
        find.byType(TagflowTable),
      );
      expect(renderObject, isNotNull);
    });

    testWidgets('updates border', (tester) async {
      final initialBorder = TagflowTableBorder(
        left: const BorderSide(),
      );

      final updatedBorder = TagflowTableBorder(
        left: const BorderSide(width: 2),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: TagflowTable(
            rowCount: 2,
            columnCount: 2,
            border: initialBorder,
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
            border: updatedBorder,
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

      final renderObject = tester.renderObject<RenderTagflowTable>(
        find.byType(TagflowTable),
      );
      expect(renderObject, isNotNull);
    });

    testWidgets('handles child updates', (tester) async {
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
                row: 0,
                column: 0,
                child: SizedBox(width: 200, height: 100),
              ),
              TableCell(
                row: 1,
                column: 1,
                child: SizedBox(width: 100, height: 50),
              ),
            ],
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderTagflowTable>(
        find.byType(TagflowTable),
      );
      expect(renderObject, isNotNull);
    });
  });
}
