import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:tagflow_table/src/rendering/tagflow_table.dart';

/// Places a child in a [TagflowTable] grid.
class TableCell extends ParentDataWidget<TableCellData> {
  /// Creates a cell at [row] and [column].
  const TableCell({
    required this.row,
    required this.column,
    required super.child,
    super.key,
    this.rowSpan = 1,
    this.colSpan = 1,
    this.isSeparator = false,
  });

  /// Row index of the cell.
  final int row;

  /// Column index of the cell.
  final int column;

  /// Rows the cell covers.
  final int rowSpan;

  /// Columns the cell covers.
  final int colSpan;

  /// Whether the child is a row separator rather than a cell.
  final bool isSeparator;

  @override
  void applyParentData(RenderObject renderObject) {
    final parentData = renderObject.parentData! as TableCellData;
    var needsLayout = false;

    if (parentData.isSeparator != isSeparator) {
      parentData.isSeparator = isSeparator;
      needsLayout = true;
    }

    if (parentData.row != row) {
      parentData.row = row;
      needsLayout = true;
    }

    if (parentData.column != column) {
      parentData.column = column;
      needsLayout = true;
    }

    if (parentData.rowSpan != rowSpan) {
      parentData.rowSpan = rowSpan;
      needsLayout = true;
    }

    if (parentData.colSpan != colSpan) {
      parentData.colSpan = colSpan;
      needsLayout = true;
    }

    if (needsLayout) {
      final targetParent = renderObject.parent;
      if (targetParent is RenderObject) {
        targetParent.markNeedsLayout();
      }
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => TagflowTable;
}

/// A table that supports row and column spans.
final class TagflowTable extends MultiChildRenderObjectWidget {
  /// Creates a table of [rowCount] by [columnCount] cells.
  TagflowTable({
    required this.rowCount,
    required this.columnCount,
    required List<TableCell> children,
    super.key,
    TagflowTableBorder? border,
    this.treatFirstRowAsHeader = false,
    this.headerBackgroundColor,
    this.padding = EdgeInsets.zero,
    this.separatorBuilder,
    this.columnSpacing = 0.0, // Add this
    this.rowSpacing = 0.0, // Add this
  }) : border = border ?? TagflowTableBorder.none,
       super(children: children);

  /// Number of rows.
  final int rowCount;

  /// Number of columns.
  final int columnCount;

  /// Outer and inner borders.
  final TagflowTableBorder border;

  /// Whether the first row is styled as a header.
  final bool treatFirstRowAsHeader;

  /// Background of the header row.
  final Color? headerBackgroundColor;

  /// Padding inside each cell.
  final EdgeInsets padding;

  /// Builds a separator between rows.
  final IndexedWidgetBuilder? separatorBuilder;

  /// Space between columns.
  final double columnSpacing;

  /// Space between rows.
  final double rowSpacing;

  @override
  RenderTagflowTable createRenderObject(BuildContext context) {
    return RenderTagflowTable()
      ..setTableDimensions(rowCount, columnCount)
      ..setBorder(border)
      ..setTreatFirstRowAsHeader(value: treatFirstRowAsHeader)
      ..setHeaderBackgroundColor(headerBackgroundColor)
      ..setSeparatorBuilder(separatorBuilder)
      ..setPadding(padding)
      ..setColumnSpacing(columnSpacing) // Add this
      ..setRowSpacing(rowSpacing); // Add this
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderTagflowTable renderObject,
  ) {
    renderObject
      ..setTableDimensions(rowCount, columnCount)
      ..setBorder(border)
      ..setTreatFirstRowAsHeader(value: treatFirstRowAsHeader)
      ..setHeaderBackgroundColor(headerBackgroundColor)
      ..setSeparatorBuilder(separatorBuilder)
      ..setPadding(padding)
      ..setColumnSpacing(columnSpacing) // Add this
      ..setRowSpacing(rowSpacing); // Add this
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IntProperty('rowCount', rowCount))
      ..add(IntProperty('columnCount', columnCount))
      ..add(DiagnosticsProperty<TagflowTableBorder>('border', border))
      ..add(DiagnosticsProperty<List<Widget>>('children', children))
      ..add(
        DiagnosticsProperty<bool>(
          'treatFirstRowAsHeader',
          treatFirstRowAsHeader,
        ),
      )
      ..add(
        DiagnosticsProperty<Color?>(
          'headerBackgroundColor',
          headerBackgroundColor,
        ),
      )
      ..add(DiagnosticsProperty<EdgeInsets>('padding', padding))
      ..add(DoubleProperty('columnSpacing', columnSpacing))
      ..add(DoubleProperty('rowSpacing', rowSpacing));
  }
}
