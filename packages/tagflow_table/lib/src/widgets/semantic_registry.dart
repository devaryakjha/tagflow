import 'dart:math' as math;

import 'package:flutter/widgets.dart' hide TableCell;
import 'package:tagflow/tagflow.dart';
import 'package:tagflow_table/src/rendering/tagflow_table.dart';
import 'package:tagflow_table/src/widgets/tagflow_table.dart';

/// Creates a semantic registry fragment backed by [TagflowTable].
///
/// Use this extension with `TagflowComponentRegistry(extensions: [...])` when
/// rendering native [TagflowDocument] table nodes through the first-party table
/// render object instead of the core package's simple fallback table.
TagflowComponentRegistry tagflowTableComponents({
  TagflowTableBorder? border,
  bool treatFirstRowAsHeader = false,
  Color? headerBackgroundColor,
  EdgeInsets padding = EdgeInsets.zero,
  IndexedWidgetBuilder? separatorBuilder,
  double columnSpacing = 0,
  double rowSpacing = 0,
}) {
  final renderer = _SemanticTableRenderer(
    border: border,
    treatFirstRowAsHeader: treatFirstRowAsHeader,
    headerBackgroundColor: headerBackgroundColor,
    padding: padding,
    separatorBuilder: separatorBuilder,
    columnSpacing: columnSpacing,
    rowSpacing: rowSpacing,
  );

  return TagflowComponentRegistry.components(
    components: {TagflowNodeKind.table: renderer.render},
  );
}

final class _SemanticTableRenderer {
  const _SemanticTableRenderer({
    required this.border,
    required this.treatFirstRowAsHeader,
    required this.headerBackgroundColor,
    required this.padding,
    required this.separatorBuilder,
    required this.columnSpacing,
    required this.rowSpacing,
  });

  final TagflowTableBorder? border;
  final bool treatFirstRowAsHeader;
  final Color? headerBackgroundColor;
  final EdgeInsets padding;
  final IndexedWidgetBuilder? separatorBuilder;
  final double columnSpacing;
  final double rowSpacing;

  Widget render(TagflowComponentContext context, TagflowDocumentNode node) {
    final layout = _SemanticTableLayout.from(node, context);

    if (layout.rowCount == 0 || layout.columnCount == 0) {
      return const SizedBox.shrink();
    }

    return TagflowTable(
      rowCount: layout.rowCount,
      columnCount: layout.columnCount,
      border: border ?? TagflowTableBorder.all(color: const Color(0x1F000000)),
      treatFirstRowAsHeader: treatFirstRowAsHeader,
      headerBackgroundColor: headerBackgroundColor,
      padding: padding,
      separatorBuilder: separatorBuilder,
      columnSpacing: columnSpacing,
      rowSpacing: rowSpacing,
      children: layout.cells,
    );
  }
}

final class _SemanticTableLayout {
  const _SemanticTableLayout({
    required this.rowCount,
    required this.columnCount,
    required this.cells,
  });

  factory _SemanticTableLayout.from(
    TagflowDocumentNode table,
    TagflowComponentContext context,
  ) {
    final rows = table.children
        .where((child) => child.kind == TagflowNodeKind.tableRow)
        .toList(growable: false);
    final cells = <TableCell>[];
    final occupiedUntilRow = <int, int>{};
    var rowCount = rows.length;
    var columnCount = 0;

    for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) {
      final row = rows[rowIndex];
      var columnIndex = 0;

      for (final cell in row.children.where(
        (child) => child.kind == TagflowNodeKind.tableCell,
      )) {
        while ((occupiedUntilRow[columnIndex] ?? -1) > rowIndex) {
          columnIndex++;
        }

        final rowSpan = _positiveSpan(cell.rowSpan);
        final colSpan = _positiveSpan(cell.colSpan);
        cells.add(
          TableCell(
            row: rowIndex,
            column: columnIndex,
            rowSpan: rowSpan,
            colSpan: colSpan,
            child: _renderCell(context, cell),
          ),
        );

        if (rowSpan > 1) {
          for (
            var column = columnIndex;
            column < columnIndex + colSpan;
            column++
          ) {
            occupiedUntilRow[column] = math.max(
              occupiedUntilRow[column] ?? -1,
              rowIndex + rowSpan,
            );
          }
        }

        columnIndex += colSpan;
        columnCount = math.max(columnCount, columnIndex);
        rowCount = math.max(rowCount, rowIndex + rowSpan);
      }
    }

    return _SemanticTableLayout(
      rowCount: rowCount,
      columnCount: columnCount,
      cells: cells,
    );
  }

  final int rowCount;
  final int columnCount;
  final List<TableCell> cells;
}

Widget _renderCell(TagflowComponentContext context, TagflowDocumentNode cell) {
  final content = cell.children.isEmpty
      ? const SizedBox.shrink()
      : Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: context.renderChildren(cell),
        );
  final padded = Padding(padding: const EdgeInsets.all(8), child: content);
  final decorated = DecoratedBox(
    decoration: BoxDecoration(
      color: cell.header ? const Color(0x12000000) : null,
    ),
    child: padded,
  );

  if (!cell.header) return decorated;

  return DefaultTextStyle.merge(
    style: const TextStyle(fontWeight: FontWeight.w700),
    child: decorated,
  );
}

int _positiveSpan(int value) => value < 1 ? 1 : value;
