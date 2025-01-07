import 'package:flutter/rendering.dart';

class TableCellData extends ContainerBoxParentData<RenderBox> {
  int row = 0;
  int column = 0;
  int rowSpan = 1;
  int colSpan = 1;
}

/// Defines the borders for a table
class TagflowTableBorder {
  TagflowTableBorder({
    this.left = BorderSide.none,
    this.right = BorderSide.none,
    this.top = BorderSide.none,
    this.bottom = BorderSide.none,
    this.horizontalInside = BorderSide.none,
    this.verticalInside = BorderSide.none,
  });

  static final none = TagflowTableBorder();

  final BorderSide left;
  final BorderSide right;
  final BorderSide top;
  final BorderSide bottom;
  final BorderSide horizontalInside;
  final BorderSide verticalInside;

  // Cache Paint objects
  Paint? _leftPaint;
  Paint? _rightPaint;
  Paint? _topPaint;
  Paint? _bottomPaint;
  Paint? _horizontalInsidePaint;
  Paint? _verticalInsidePaint;

  Paint _getPaint(BorderSide side, Paint? cache) {
    return cache ??
        (Paint()
          ..color = side.color
          ..strokeWidth = side.width
          ..style = PaintingStyle.stroke);
  }

  void paint(
    Canvas canvas,
    Rect rect, {
    required int rows,
    required int columns,
    required List<List<TableCellData>> cellData,
    required List<double> columnWidths,
    required List<double> rowHeights,
  }) {
    // Paint outer borders
    if (left != BorderSide.none) {
      _leftPaint = _getPaint(left, _leftPaint);
      canvas.drawLine(rect.topLeft, rect.bottomLeft, _leftPaint!);
    }

    if (right != BorderSide.none) {
      _rightPaint = _getPaint(right, _rightPaint);
      canvas.drawLine(rect.topRight, rect.bottomRight, _rightPaint!);
    }

    if (top != BorderSide.none) {
      _topPaint = _getPaint(top, _topPaint);
      canvas.drawLine(rect.topLeft, rect.topRight, _topPaint!);
    }

    if (bottom != BorderSide.none) {
      _bottomPaint = _getPaint(bottom, _bottomPaint);
      canvas.drawLine(rect.bottomLeft, rect.bottomRight, _bottomPaint!);
    }

    // Paint inner borders
    if (horizontalInside != BorderSide.none && rows > 1) {
      _horizontalInsidePaint =
          _getPaint(horizontalInside, _horizontalInsidePaint);
      var y = rowHeights[0];
      for (var i = 1; i < rows; i++) {
        // Find segments where we should draw the horizontal line
        final segments = <(double, double)>[];
        var currentStart = rect.left;
        var skipLine = false;

        var x = 0.0;
        for (var j = 0; j < columns; j++) {
          final cell = cellData[i][j];
          final aboveCell = cellData[i - 1][j];

          // Skip if this cell or the cell above it spans multiple rows
          if (cell.row < i || // Cell starts in a row above
              (aboveCell.row + aboveCell.rowSpan > i)) {
            // Cell above spans into this row
            if (!skipLine) {
              if (currentStart < rect.left + x) {
                segments.add((currentStart, rect.left + x));
              }
              skipLine = true;
            }
          } else if (skipLine) {
            currentStart = rect.left + x;
            skipLine = false;
          }
          x += columnWidths[j];
        }

        if (!skipLine && currentStart < rect.right) {
          segments.add((currentStart, rect.right));
        }

        // Draw the line segments
        for (final segment in segments) {
          canvas.drawLine(
            Offset(segment.$1, rect.top + y),
            Offset(segment.$2, rect.top + y),
            _horizontalInsidePaint!,
          );
        }
        y += rowHeights[i];
      }
    }

    if (verticalInside != BorderSide.none && columns > 1) {
      _verticalInsidePaint = _getPaint(verticalInside, _verticalInsidePaint);
      var x = columnWidths[0];
      for (var i = 1; i < columns; i++) {
        // Find segments where we should draw the vertical line
        final segments = <(double, double)>[];
        var currentStart = rect.top;
        var skipLine = false;

        var y = 0.0;
        for (var j = 0; j < rows; j++) {
          final cell = cellData[j][i];
          final leftCell = cellData[j][i - 1];

          // Skip if this cell or the cell to the left spans multiple columns
          if (cell.column < i || // Cell starts in a column to the left
              (leftCell.column + leftCell.colSpan > i)) {
            // Cell to the left spans into this column
            if (!skipLine) {
              if (currentStart < rect.top + y) {
                segments.add((currentStart, rect.top + y));
              }
              skipLine = true;
            }
          } else if (skipLine) {
            currentStart = rect.top + y;
            skipLine = false;
          }
          y += rowHeights[j];
        }

        if (!skipLine && currentStart < rect.bottom) {
          segments.add((currentStart, rect.bottom));
        }

        // Draw the line segments
        for (final segment in segments) {
          canvas.drawLine(
            Offset(rect.left + x, segment.$1),
            Offset(rect.left + x, segment.$2),
            _verticalInsidePaint!,
          );
        }
        x += columnWidths[i];
      }
    }
  }
}

class RenderTagflowTable extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, TableCellData>,
        RenderBoxContainerDefaultsMixin<RenderBox, TableCellData> {
  int _rowCount = 0;
  int _columnCount = 0;
  TagflowTableBorder _border = TagflowTableBorder();
  List<double> _columnWidths = [];
  List<double> _rowHeights = [];

  void setTableDimensions(int rowCount, int columnCount) {
    if (rowCount < 0 || columnCount < 0) {
      throw ArgumentError('Table dimensions cannot be negative');
    }
    if (_rowCount != rowCount || _columnCount != columnCount) {
      _rowCount = rowCount;
      _columnCount = columnCount;
      markNeedsLayout();
    }
  }

  void setBorder(TagflowTableBorder value) {
    if (_border == value) return;
    _border = value;
    markNeedsPaint();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! TableCellData) {
      child.parentData = TableCellData();
    }
  }

  @override
  void performLayout() {
    if (childCount == 0) {
      size = constraints.smallest;
      return;
    }

    // First pass: Calculate minimum column widths
    _columnWidths = List<double>.filled(_columnCount, 0);
    var child = firstChild;
    while (child != null) {
      final childParentData = child.parentData! as TableCellData;
      final childWidth =
          child.getMinIntrinsicWidth(double.infinity) / childParentData.colSpan;
      for (var i = 0; i < childParentData.colSpan; i++) {
        _columnWidths[childParentData.column + i] =
            _columnWidths[childParentData.column + i]
                .clamp(childWidth, double.infinity);
      }
      child = childParentData.nextSibling;
    }

    // Calculate total minimum width and distribute extra space
    final totalMinWidth = _columnWidths.reduce((a, b) => a + b);
    final extraWidth =
        (constraints.maxWidth - totalMinWidth).clamp(0.0, double.infinity);
    if (extraWidth > 0) {
      final widthPerColumn = extraWidth / _columnCount;
      for (var i = 0; i < _columnCount; i++) {
        _columnWidths[i] += widthPerColumn;
      }
    }

    // Calculate row heights
    _rowHeights = List<double>.filled(_rowCount, 0);
    child = firstChild;
    while (child != null) {
      final childParentData = child.parentData! as TableCellData;

      // Calculate the width this cell will have
      var cellWidth = 0.0;
      for (var i = 0; i < childParentData.colSpan; i++) {
        cellWidth += _columnWidths[childParentData.column + i];
      }

      // Get the height needed for this width
      final childHeight =
          child.getMinIntrinsicHeight(cellWidth) / childParentData.rowSpan;
      for (var i = 0; i < childParentData.rowSpan; i++) {
        _rowHeights[childParentData.row + i] =
            _rowHeights[childParentData.row + i]
                .clamp(childHeight, double.infinity);
      }
      child = childParentData.nextSibling;
    }

    // Layout children with clipping
    child = firstChild;
    while (child != null) {
      final childParentData = child.parentData! as TableCellData;

      // Calculate cell width and height
      var width = 0.0;
      for (var i = 0; i < childParentData.colSpan; i++) {
        width += _columnWidths[childParentData.column + i];
      }

      var height = 0.0;
      for (var i = 0; i < childParentData.rowSpan; i++) {
        height += _rowHeights[childParentData.row + i];
      }

      // Calculate cell position
      var x = 0.0;
      for (var i = 0; i < childParentData.column; i++) {
        x += _columnWidths[i];
      }

      var y = 0.0;
      for (var i = 0; i < childParentData.row; i++) {
        y += _rowHeights[i];
      }

      // Layout child with tight constraints to prevent overflow
      child.layout(BoxConstraints.tight(Size(width, height)));
      childParentData.offset = Offset(x, y);

      child = childParentData.nextSibling;
    }

    // Set table size
    size = constraints.constrain(
      Size(
        _columnWidths.reduce((a, b) => a + b),
        _rowHeights.reduce((a, b) => a + b),
      ),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // Paint children with clipping
    var child = firstChild;
    while (child != null) {
      final childParentData = child.parentData! as TableCellData;
      context.pushClipRect(
        needsCompositing,
        offset + childParentData.offset,
        Offset.zero & child.size,
        (context, offset) => context.paintChild(child!, offset),
      );
      child = childAfter(child);
    }

    // Paint borders
    _border.paint(
      context.canvas,
      Rect.fromLTWH(
        offset.dx,
        offset.dy,
        size.width,
        size.height,
      ),
      rows: _rowCount,
      columns: _columnCount,
      cellData: _buildCellDataGrid(),
      columnWidths: _columnWidths,
      rowHeights: _rowHeights,
    );
  }

  List<List<TableCellData>> _buildCellDataGrid() {
    final grid = List.generate(
      _rowCount,
      (_) => List<TableCellData>.filled(
        _columnCount,
        TableCellData()..row = -1, // Use -1 to indicate unset cells
      ),
    );

    var child = firstChild;
    while (child != null) {
      final data = child.parentData! as TableCellData;
      for (var r = data.row; r < data.row + data.rowSpan; r++) {
        for (var c = data.column; c < data.column + data.colSpan; c++) {
          grid[r][c] = data;
        }
      }
      child = childAfter(child);
    }

    return grid;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    var width = 0.0;
    var child = firstChild;
    while (child != null) {
      final childParentData = child.parentData! as TableCellData;
      width = width.clamp(
        child.getMinIntrinsicWidth(height) / childParentData.colSpan,
        double.infinity,
      );
      child = childParentData.nextSibling;
    }
    return width * _columnCount;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    var width = 0.0;
    var child = firstChild;
    while (child != null) {
      final childParentData = child.parentData! as TableCellData;
      width = width.clamp(
        child.getMaxIntrinsicWidth(height) / childParentData.colSpan,
        double.infinity,
      );
      child = childParentData.nextSibling;
    }
    return width * _columnCount;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    var height = 0.0;
    var child = firstChild;
    while (child != null) {
      final childParentData = child.parentData! as TableCellData;
      height = height.clamp(
        child.getMinIntrinsicHeight(width) / childParentData.rowSpan,
        double.infinity,
      );
      child = childParentData.nextSibling;
    }
    return height * _rowCount;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    var height = 0.0;
    var child = firstChild;
    while (child != null) {
      final childParentData = child.parentData! as TableCellData;
      height = height.clamp(
        child.getMaxIntrinsicHeight(width) / childParentData.rowSpan,
        double.infinity,
      );
      child = childParentData.nextSibling;
    }
    return height * _rowCount;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    if (childCount == 0) {
      return constraints.smallest;
    }

    // Calculate minimum column widths
    final columnWidths = List<double>.filled(_columnCount, 0);
    var child = firstChild;
    while (child != null) {
      final childParentData = child.parentData! as TableCellData;
      final childWidth =
          child.getDryLayout(BoxConstraints.loose(constraints.biggest)).width /
              childParentData.colSpan;
      for (var i = 0; i < childParentData.colSpan; i++) {
        columnWidths[childParentData.column + i] =
            columnWidths[childParentData.column + i]
                .clamp(childWidth, double.infinity);
      }
      child = childParentData.nextSibling;
    }

    // Calculate total minimum width and distribute extra space
    final totalMinWidth = columnWidths.reduce((a, b) => a + b);
    final extraWidth =
        (constraints.maxWidth - totalMinWidth).clamp(0.0, double.infinity);
    if (extraWidth > 0) {
      final widthPerColumn = extraWidth / _columnCount;
      for (var i = 0; i < _columnCount; i++) {
        columnWidths[i] += widthPerColumn;
      }
    }

    // Calculate row heights
    final rowHeights = List<double>.filled(_rowCount, 0);
    child = firstChild;
    while (child != null) {
      final childParentData = child.parentData! as TableCellData;

      // Calculate the width this cell will have
      var cellWidth = 0.0;
      for (var i = 0; i < childParentData.colSpan; i++) {
        cellWidth += columnWidths[childParentData.column + i];
      }

      // Get the height needed for this width
      final childHeight =
          child.getDryLayout(BoxConstraints.tightFor(width: cellWidth)).height /
              childParentData.rowSpan;
      for (var i = 0; i < childParentData.rowSpan; i++) {
        rowHeights[childParentData.row + i] =
            rowHeights[childParentData.row + i]
                .clamp(childHeight, double.infinity);
      }
      child = childParentData.nextSibling;
    }

    return constraints.constrain(
      Size(
        columnWidths.reduce((a, b) => a + b),
        rowHeights.reduce((a, b) => a + b),
      ),
    );
  }
}
