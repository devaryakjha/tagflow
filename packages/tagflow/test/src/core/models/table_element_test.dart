// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/tagflow.dart';

void main() {
  group('TagflowTableElement', () {
    test('constructor initializes correctly', () {
      const table = TagflowTableElement(
        tag: 'table',
        rowCount: 2,
        columnCount: 3,
        rows: [],
        spans: {},
        caption: TagflowElement(tag: 'caption', textContent: 'Test Caption'),
        attributes: {'class': 'test-table'},
      );

      expect(table.tag, 'table');
      expect(table.rowCount, 2);
      expect(table.columnCount, 3);
      expect(table.rows, isEmpty);
      expect(table.spans, isEmpty);
      expect(table.caption?.textContent, 'Test Caption');
      expect(table['class'], 'test-table');
    });

    test('addRow adds row correctly', () {
      final table = TagflowTableElement(
        tag: 'table',
        rowCount: 1,
        columnCount: 1,
        rows: [],
        spans: {},
      );

      const row = TagflowElement(tag: 'tr');
      table.addRow(row);

      expect(table.rows.length, 1);
      expect(table.rows.first, row);
    });

    test('getSpan returns correct span', () {
      const table = TagflowTableElement(
        tag: 'table',
        rowCount: 2,
        columnCount: 2,
        rows: [],
        spans: {
          '0:0': CellSpan(rowSpan: 2, colSpan: 1),
          '1:1': CellSpan(rowSpan: 1, colSpan: 2),
        },
      );

      final span1 = table.getSpan(0, 0);
      expect(span1?.rowSpan, 2);
      expect(span1?.colSpan, 1);

      final span2 = table.getSpan(1, 1);
      expect(span2?.rowSpan, 1);
      expect(span2?.colSpan, 2);

      expect(table.getSpan(0, 1), isNull);
    });

    test('setSpan sets span correctly', () {
      final table = TagflowTableElement(
        tag: 'table',
        rowCount: 2,
        columnCount: 2,
        rows: [],
        spans: {},
      )..setSpan(0, 0, rowSpan: 2);

      final span = table.getSpan(0, 0);
      expect(span?.rowSpan, 2);
      expect(span?.colSpan, 1);
    });

    test('attribute access works correctly', () {
      final table = TagflowTableElement(
        tag: 'table',
        rowCount: 1,
        columnCount: 1,
        rows: [],
        spans: {},
        attributes: {'style': 'width: 100%'},
      );

      expect(table['style'], 'width: 100%');

      table['class'] = 'new-class';
      expect(table['class'], 'new-class');
    });

    test('reparent creates new instance with correct parent', () {
      const originalTable = TagflowTableElement(
        tag: 'table',
        rowCount: 1,
        columnCount: 1,
        rows: [
          TagflowElement(
            tag: 'tr',
            children: [
              TagflowElement(tag: 'td', textContent: 'Cell'),
            ],
          ),
        ],
        spans: {'0:0': CellSpan(rowSpan: 1, colSpan: 1)},
        caption: TagflowElement(tag: 'caption', textContent: 'Caption'),
      );

      const newParent = TagflowElement(tag: 'div');
      final reparentedTable =
          originalTable.reparent(newParent) as TagflowTableElement;

      expect(reparentedTable.parent, newParent);
      expect(reparentedTable.rows.first.parent, reparentedTable);
      expect(reparentedTable.caption?.parent, reparentedTable);
      expect(reparentedTable.spans, originalTable.spans);
      expect(reparentedTable.rowCount, originalTable.rowCount);
      expect(reparentedTable.columnCount, originalTable.columnCount);
    });

    test('children getter returns rows', () {
      final rows = [
        const TagflowElement(tag: 'tr'),
        const TagflowElement(tag: 'tr'),
      ];

      final table = TagflowTableElement(
        tag: 'table',
        rowCount: 2,
        columnCount: 1,
        rows: rows,
        spans: const {},
      );

      expect(table.children, equals(rows));
    });

    test('children setter updates rows', () {
      final table = TagflowTableElement(
        tag: 'table',
        rowCount: 1,
        columnCount: 1,
        rows: [TagflowElement(tag: 'tr')],
        spans: {},
      );

      final newRows = [
        const TagflowElement(
          tag: 'tr',
          children: [
            TagflowElement(tag: 'td', textContent: 'New Cell'),
          ],
        ),
      ];

      table.children = newRows;
      expect(table.rows, equals(newRows));
    });
  });

  group('CellSpan', () {
    test('constructor initializes correctly', () {
      const span = CellSpan(rowSpan: 2, colSpan: 3);
      expect(span.rowSpan, 2);
      expect(span.colSpan, 3);
    });
  });
}
