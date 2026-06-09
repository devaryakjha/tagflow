import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow_table/tagflow_table.dart';

void main() {
  group('TableCellData', () {
    test('initializes with default values', () {
      final data = TableCellData();
      expect(data.row, 0);
      expect(data.column, 0);
      expect(data.rowSpan, 1);
      expect(data.colSpan, 1);
    });

    test('can set row and column', () {
      final data = TableCellData()
        ..row = 2
        ..column = 3;
      expect(data.row, 2);
      expect(data.column, 3);
    });

    test('can set rowSpan and colSpan', () {
      final data = TableCellData()
        ..rowSpan = 2
        ..colSpan = 3;
      expect(data.rowSpan, 2);
      expect(data.colSpan, 3);
    });

    test('extends ContainerBoxParentData', () {
      final data = TableCellData();
      expect(data, isA<ContainerBoxParentData<RenderBox>>());
    });
  });
}
