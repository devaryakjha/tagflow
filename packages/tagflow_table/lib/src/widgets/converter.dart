import 'package:flutter/material.dart' as material;
import 'package:flutter/rendering.dart';
import 'package:tagflow/tagflow.dart';
import 'package:tagflow_table/tagflow_table.dart';

/// Represents a cell in the grid with its ownership and span information
class _GridCell {
  _GridCell({
    required this.ownerRow,
    required this.ownerCol,
    required this.rowSpan,
    required this.colSpan,
    required this.node,
  });

  final int ownerRow;
  final int ownerCol;
  final int rowSpan;
  final int colSpan;
  final TagflowNode node;

  @override
  String toString() => '$ownerRow,$ownerCol';
}

final class TagflowTableConverter
    extends ElementConverter<TagflowTableElement> {
  @override
  Set<String> get supportedTags => {'table'};

  @override
  material.Widget convert(
    TagflowTableElement element,
    material.BuildContext context,
    TagflowConverter converter,
  ) {
    final style = resolveStyle(element, context);
    final cells = <TableCell>[];

    // Create a grid to track cell ownership
    final grid = List.generate(
      element.rowCount,
      (_) => List<_GridCell?>.filled(element.columnCount, null),
    );

    for (var rowIndex = 0; rowIndex < element.rowCount; rowIndex++) {
      final row = element.rows[rowIndex];
      final rowStyle = resolveStyle(row, context);

      // Filter out empty cells
      final nonEmptyCells =
          row.children.where((cell) => cell.children.isNotEmpty).toList();

      // Process each cell in the row
      var cellIndex = 0;
      var colIndex = 0;

      while (
          cellIndex < nonEmptyCells.length && colIndex < element.columnCount) {
        // Skip columns that are already taken by rowspans
        while (colIndex < element.columnCount &&
            grid[rowIndex][colIndex] != null) {
          colIndex++;
        }

        if (colIndex >= element.columnCount) break;

        final cell = nonEmptyCells[cellIndex];
        final rowSpan = int.tryParse(cell['rowspan'] ?? '1') ?? 1;
        final colSpan = int.tryParse(cell['colspan'] ?? '1') ?? 1;
        final cellStyle = resolveStyle(cell, context);

        // Create grid cell
        final gridCell = _GridCell(
          ownerRow: rowIndex,
          ownerCol: colIndex,
          rowSpan: rowSpan,
          colSpan: colSpan,
          node: cell,
        );

        // Mark territory
        for (var r = rowIndex;
            r < rowIndex + rowSpan && r < element.rowCount;
            r++) {
          for (var c = colIndex;
              c < colIndex + colSpan && c < element.columnCount;
              c++) {
            grid[r][c] = gridCell;
          }
        }

        // Create cell widget with styles
        final cellWidget = material.Container(
          alignment: material.Alignment.center,
          decoration: (cellStyle.toBoxDecoration() ??
                  rowStyle.toBoxDecoration() ??
                  const BoxDecoration())
              .copyWith(
            color: cellStyle.backgroundColor ?? rowStyle.backgroundColor,
          ),
          child: _convertCell(cell, context, converter),
        );

        cells.add(
          TableCell(
            row: rowIndex,
            column: colIndex,
            rowSpan: rowSpan,
            colSpan: colSpan,
            child: cellWidget,
          ),
        );

        cellIndex++;
        colIndex += colSpan;
      }
    }

    return StyledContainer(
      tag: element.tag,
      style: style.copyWith(
        border: material.Border.all(
          width: 0,
          style: material.BorderStyle.none,
        ),
      ),
      child: TagflowTable(
        rowCount: element.rowCount,
        columnCount: element.columnCount,
        border: TagflowTableBorder(
          left: style.effectiveBorder?.left ?? material.BorderSide.none,
          right: style.effectiveBorder?.right ?? material.BorderSide.none,
          top: style.effectiveBorder?.top ?? material.BorderSide.none,
          bottom: style.effectiveBorder?.bottom ?? material.BorderSide.none,
          horizontalInside:
              style.effectiveBorder?.bottom ?? material.BorderSide.none,
          verticalInside:
              style.effectiveBorder?.right ?? material.BorderSide.none,
        ),
        children: cells,
      ),
    );
  }

  material.Widget _convertCell(
    TagflowNode cell,
    material.BuildContext context,
    TagflowConverter converter,
  ) {
    if (cell.children.isEmpty) {
      return const material.SizedBox.shrink();
    }
    return converter.convert(cell, context);
  }
}
