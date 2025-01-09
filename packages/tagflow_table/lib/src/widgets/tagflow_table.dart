import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:tagflow_table/src/rendering/tagflow_table.dart';

class TableCell extends ParentDataWidget<TableCellData> {
  const TableCell({
    required this.row,
    required this.column,
    required super.child,
    super.key,
    this.rowSpan = 1,
    this.colSpan = 1,
  });

  final int row;
  final int column;
  final int rowSpan;
  final int colSpan;

  @override
  void applyParentData(RenderObject renderObject) {
    final parentData = renderObject.parentData! as TableCellData;
    var needsLayout = false;

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

final class TagflowTable extends MultiChildRenderObjectWidget {
  TagflowTable({
    required this.rowCount,
    required this.columnCount,
    required List<TableCell> children,
    super.key,
    TagflowTableBorder? border,
  })  : border = border ?? TagflowTableBorder.none,
        super(children: children);

  final int rowCount;
  final int columnCount;
  final TagflowTableBorder border;

  @override
  RenderTagflowTable createRenderObject(BuildContext context) {
    return RenderTagflowTable()
      ..setTableDimensions(rowCount, columnCount)
      ..setBorder(border);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderTagflowTable renderObject,
  ) {
    renderObject
      ..setTableDimensions(rowCount, columnCount)
      ..setBorder(border);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IntProperty('rowCount', rowCount))
      ..add(IntProperty('columnCount', columnCount))
      ..add(DiagnosticsProperty<TagflowTableBorder>('border', border))
      ..add(DiagnosticsProperty<List<Widget>>('children', children));
  }
}
