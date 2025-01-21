import 'dart:math' as math;

import 'package:equatable/equatable.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class TableCellData extends ContainerBoxParentData<RenderBox> {
  int row = 0;
  int column = 0;
  int rowSpan = 1;
  int colSpan = 1;
  bool isSeparator = false;
}

/// Defines the borders for a table
// ignore: must_be_immutable
class TagflowTableBorder extends Equatable {
  TagflowTableBorder({
    this.left = BorderSide.none,
    this.right = BorderSide.none,
    this.top = BorderSide.none,
    this.bottom = BorderSide.none,
    this.horizontalInside = BorderSide.none,
    this.verticalInside = BorderSide.none,
  });

  factory TagflowTableBorder.fromBorder(Border border) {
    return TagflowTableBorder(
      left: border.left,
      right: border.right,
      top: border.top,
      bottom: border.bottom,
      horizontalInside: border.bottom,
      verticalInside: border.right,
    );
  }

  factory TagflowTableBorder.all({
    Color color = const Color(0xFF000000),
    double width = 1.0,
    BorderStyle style = BorderStyle.solid,
  }) {
    final side = BorderSide(color: color, width: width, style: style);
    return TagflowTableBorder(
      left: side,
      right: side,
      top: side,
      bottom: side,
      horizontalInside: side,
      verticalInside: side,
    );
  }

  factory TagflowTableBorder.symmetric({
    BorderSide outside = BorderSide.none,
    BorderSide inside = BorderSide.none,
  }) {
    return TagflowTableBorder(
      left: outside,
      right: outside,
      top: outside,
      bottom: outside,
      horizontalInside: inside,
      verticalInside: inside,
    );
  }

  static final none = TagflowTableBorder();

  bool get isNone =>
      left == BorderSide.none &&
      right == BorderSide.none &&
      top == BorderSide.none &&
      bottom == BorderSide.none &&
      horizontalInside == BorderSide.none &&
      verticalInside == BorderSide.none;

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

  static TagflowTableBorder? lerp(
    TagflowTableBorder? a,
    TagflowTableBorder? b,
    double t,
  ) {
    if (a == null && b == null) return null;
    if (a == null) return b!.scale(t);
    if (b == null) return a.scale(1.0 - t);
    return TagflowTableBorder(
      left: BorderSide.lerp(a.left, b.left, t),
      right: BorderSide.lerp(a.right, b.right, t),
      top: BorderSide.lerp(a.top, b.top, t),
      bottom: BorderSide.lerp(a.bottom, b.bottom, t),
      horizontalInside:
          BorderSide.lerp(a.horizontalInside, b.horizontalInside, t),
      verticalInside: BorderSide.lerp(a.verticalInside, b.verticalInside, t),
    );
  }

  TagflowTableBorder copyWith({
    BorderSide? left,
    BorderSide? right,
    BorderSide? top,
    BorderSide? bottom,
    BorderSide? horizontalInside,
    BorderSide? verticalInside,
  }) {
    return TagflowTableBorder(
      left: left ?? this.left,
      right: right ?? this.right,
      top: top ?? this.top,
      bottom: bottom ?? this.bottom,
      horizontalInside: horizontalInside ?? this.horizontalInside,
      verticalInside: verticalInside ?? this.verticalInside,
    );
  }

  TagflowTableBorder scale(double t) {
    return TagflowTableBorder(
      left: left.scale(t),
      right: right.scale(t),
      top: top.scale(t),
      bottom: bottom.scale(t),
      horizontalInside: horizontalInside.scale(t),
      verticalInside: verticalInside.scale(t),
    );
  }

  void paint(
    Canvas canvas,
    Rect rect, {
    required int rows,
    required int columns,
    required List<List<TableCellData>> cellData,
    required List<double> columnWidths,
    required List<double> rowHeights,
    bool treatFirstRowAsHeader = false,
    Color? headerBackgroundColor,
    EdgeInsets padding = EdgeInsets.zero,
  }) {
    final adjustedRect = Rect.fromLTWH(
      rect.left + padding.left,
      rect.top + padding.top,
      rect.width - padding.horizontal,
      rect.height - padding.vertical,
    );

    // Paint header background if needed
    if (treatFirstRowAsHeader && headerBackgroundColor != null && rows > 0) {
      // extending beyond the padding
      // TODO: make this configurable
      final headerRect = Rect.fromLTWH(
        0,
        0,
        rect.width,
        rowHeights[0],
      );
      canvas.drawRect(
        headerRect,
        Paint()..color = headerBackgroundColor,
      );
    }

    // Paint outer borders
    if (left != BorderSide.none) {
      _leftPaint = _getPaint(left, _leftPaint);
      canvas.drawLine(
        adjustedRect.topLeft,
        adjustedRect.bottomLeft,
        _leftPaint!,
      );
    }

    if (right != BorderSide.none) {
      _rightPaint = _getPaint(right, _rightPaint);
      canvas.drawLine(
        adjustedRect.topRight,
        adjustedRect.bottomRight,
        _rightPaint!,
      );
    }

    if (top != BorderSide.none) {
      _topPaint = _getPaint(top, _topPaint);
      canvas.drawLine(adjustedRect.topLeft, adjustedRect.topRight, _topPaint!);
    }

    if (bottom != BorderSide.none) {
      _bottomPaint = _getPaint(bottom, _bottomPaint);
      canvas.drawLine(
        adjustedRect.bottomLeft,
        adjustedRect.bottomRight,
        _bottomPaint!,
      );
    }

    // Paint inner borders
    if (horizontalInside != BorderSide.none && rows > 1) {
      _horizontalInsidePaint =
          _getPaint(horizontalInside, _horizontalInsidePaint);
      var y = rowHeights[0];
      for (var i = 1; i < rows; i++) {
        // Find segments where we should draw the horizontal line
        final segments = <(double, double)>[];
        var currentStart = adjustedRect.left;
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
              if (currentStart < adjustedRect.left + x) {
                segments.add((currentStart, adjustedRect.left + x));
              }
              skipLine = true;
            }
          } else if (skipLine) {
            currentStart = adjustedRect.left + x;
            skipLine = false;
          }
          x += columnWidths[j];
        }

        if (!skipLine && currentStart < adjustedRect.right) {
          segments.add((currentStart, adjustedRect.right));
        }

        // Draw the line segments
        for (final segment in segments) {
          canvas.drawLine(
            Offset(segment.$1, adjustedRect.top + y),
            Offset(segment.$2, adjustedRect.top + y),
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
        var currentStart = adjustedRect.top;
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
              if (currentStart < adjustedRect.top + y) {
                segments.add((currentStart, adjustedRect.top + y));
              }
              skipLine = true;
            }
          } else if (skipLine) {
            currentStart = adjustedRect.top + y;
            skipLine = false;
          }
          y += rowHeights[j];
        }

        if (!skipLine && currentStart < adjustedRect.bottom) {
          segments.add((currentStart, adjustedRect.bottom));
        }

        // Draw the line segments
        for (final segment in segments) {
          canvas.drawLine(
            Offset(adjustedRect.left + x, segment.$1),
            Offset(adjustedRect.left + x, segment.$2),
            _verticalInsidePaint!,
          );
        }
        x += columnWidths[i];
      }
    }
  }

  @override
  List<Object?> get props => [
        left,
        right,
        top,
        bottom,
        horizontalInside,
        verticalInside,
      ];
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
  bool _treatFirstRowAsHeader = false;
  Color? _headerBackgroundColor;
  EdgeInsets _padding = EdgeInsets.zero;
  IndexedWidgetBuilder? _separatorBuilder;

  void setSeparatorBuilder(IndexedWidgetBuilder? value) {
    if (_separatorBuilder == value) return;
    _separatorBuilder = value;
    markNeedsLayout();
  }

  void setTreatFirstRowAsHeader({bool value = false}) {
    if (_treatFirstRowAsHeader == value) return;
    _treatFirstRowAsHeader = value;
    markNeedsPaint();
  }

  void setHeaderBackgroundColor(Color? value) {
    if (_headerBackgroundColor == value) return;
    _headerBackgroundColor = value;
    markNeedsPaint();
  }

  void setPadding(EdgeInsets value) {
    if (_padding == value) return;
    _padding = value;
    markNeedsPaint();
  }

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

    // First pass: Calculate minimum and preferred column widths
    _columnWidths = List<double>.filled(_columnCount, 0);
    final columnFlexibility = List<double>.filled(_columnCount, 0);

    var child = firstChild;
    while (child != null) {
      final childParentData = child.parentData! as TableCellData;
      if (!childParentData.isSeparator) {
        final minWidth = child.getMinIntrinsicWidth(double.infinity);
        final maxWidth = child.getMaxIntrinsicWidth(double.infinity);
        final widthPerColumn = minWidth / childParentData.colSpan;

        // Update minimum widths
        for (var i = 0; i < childParentData.colSpan; i++) {
          final colIndex = childParentData.column + i;
          _columnWidths[colIndex] =
              _columnWidths[colIndex].clamp(widthPerColumn, double.infinity);

          // Track how flexible each column is based on content
          final flexibility = (maxWidth - minWidth) / childParentData.colSpan;
          columnFlexibility[colIndex] =
              math.max(columnFlexibility[colIndex], flexibility);
        }
      }
      child = childParentData.nextSibling;
    }

    // Calculate total minimum width and distribute extra space
    final totalMinWidth =
        _columnWidths.reduce((a, b) => a + b) + _padding.horizontal;
    final extraWidth =
        (constraints.maxWidth - totalMinWidth).clamp(0.0, double.infinity);

    if (extraWidth > 0) {
      // Calculate total flexibility
      final totalFlexibility = columnFlexibility.reduce((a, b) => a + b);

      if (totalFlexibility > 0) {
        // Distribute extra space proportionally to column flexibility
        for (var i = 0; i < _columnCount; i++) {
          final proportion = columnFlexibility[i] / totalFlexibility;
          _columnWidths[i] += extraWidth * proportion;
        }
      } else {
        // If no flexible columns found, distribute evenly
        final widthPerColumn = extraWidth / _columnCount;
        for (var i = 0; i < _columnCount; i++) {
          _columnWidths[i] += widthPerColumn;
        }
      }
    }

    // Calculate row heights
    _rowHeights = List<double>.filled(_rowCount, 0);
    child = firstChild;
    while (child != null) {
      final childParentData = child.parentData! as TableCellData;
      if (!childParentData.isSeparator) {
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
      }
      child = childParentData.nextSibling;
    }

    // Layout children with clipping
    child = firstChild;
    while (child != null) {
      final childParentData = child.parentData! as TableCellData;

      if (childParentData.isSeparator) {
        // Layout separator with full table width (including padding)
        final tableWidth =
            _columnWidths.reduce((a, b) => a + b) + _padding.horizontal;
        child.layout(
          BoxConstraints.tightFor(width: tableWidth),
          parentUsesSize: true,
        );

        // Position separator after the current row, ignoring padding
        var y = 0.0;
        for (var i = 0; i <= childParentData.row; i++) {
          y += _rowHeights[i];
        }
        childParentData.offset = Offset(0, y);
      } else {
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
        var x = _padding.left;
        for (var i = 0; i < childParentData.column; i++) {
          x += _columnWidths[i];
        }

        var y = _padding.top;
        for (var i = 0; i < childParentData.row; i++) {
          y += _rowHeights[i];
        }

        // Layout child with tight constraints to prevent overflow
        child.layout(BoxConstraints.tight(Size(width, height)));
        childParentData.offset = Offset(x, y);
      }

      child = childParentData.nextSibling;
    }

    // Set table size
    size = constraints.constrain(
      Size(
        _columnWidths.reduce((a, b) => a + b) + _padding.horizontal,
        _rowHeights.reduce((a, b) => a + b) + _padding.vertical,
      ),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // First paint the table background and borders
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
      treatFirstRowAsHeader: _treatFirstRowAsHeader,
      headerBackgroundColor: _headerBackgroundColor,
      padding: _padding,
    );

    // Then paint regular cells
    var child = firstChild;
    while (child != null) {
      final childParentData = child.parentData! as TableCellData;
      if (!childParentData.isSeparator) {
        context.pushClipRect(
          needsCompositing,
          offset + childParentData.offset,
          Offset.zero & child.size,
          (context, offset) => context.paintChild(child!, offset),
        );
      }
      child = childAfter(child);
    }

    // Finally paint separators on top
    child = firstChild;
    while (child != null) {
      final childParentData = child.parentData! as TableCellData;
      if (childParentData.isSeparator) {
        context.paintChild(child, offset + childParentData.offset);
      }
      child = childAfter(child);
    }
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
      if (!data.isSeparator) {
        for (var r = data.row; r < data.row + data.rowSpan; r++) {
          for (var c = data.column; c < data.column + data.colSpan; c++) {
            grid[r][c] = data;
          }
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
      if (!childParentData.isSeparator) {
        width = width.clamp(
          child.getMinIntrinsicWidth(height) / childParentData.colSpan,
          double.infinity,
        );
      }
      child = childParentData.nextSibling;
    }
    return width * _columnCount + _padding.horizontal;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    var width = 0.0;
    var child = firstChild;
    while (child != null) {
      final childParentData = child.parentData! as TableCellData;
      if (!childParentData.isSeparator) {
        width = width.clamp(
          child.getMaxIntrinsicWidth(height) / childParentData.colSpan,
          double.infinity,
        );
      }
      child = childParentData.nextSibling;
    }
    return width * _columnCount + _padding.horizontal;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    var height = 0.0;
    var child = firstChild;
    while (child != null) {
      final childParentData = child.parentData! as TableCellData;
      if (!childParentData.isSeparator) {
        height = height.clamp(
          child.getMinIntrinsicHeight(width) / childParentData.rowSpan,
          double.infinity,
        );
      }
      child = childParentData.nextSibling;
    }
    return height * _rowCount + _padding.vertical;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    var height = 0.0;
    var child = firstChild;
    while (child != null) {
      final childParentData = child.parentData! as TableCellData;
      if (!childParentData.isSeparator) {
        height = height.clamp(
          child.getMaxIntrinsicHeight(width) / childParentData.rowSpan,
          double.infinity,
        );
      }
      child = childParentData.nextSibling;
    }
    return height * _rowCount + _padding.vertical;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    if (childCount == 0) {
      return constraints.smallest;
    }

    // Calculate minimum and preferred column widths
    _columnWidths = List<double>.filled(_columnCount, 0);
    final columnFlexibility = List<double>.filled(_columnCount, 0);

    var child = firstChild;
    while (child != null) {
      final childParentData = child.parentData! as TableCellData;
      if (!childParentData.isSeparator) {
        final minWidth = child.getMinIntrinsicWidth(double.infinity);
        final maxWidth = child.getMaxIntrinsicWidth(double.infinity);
        final widthPerColumn = minWidth / childParentData.colSpan;

        // Update minimum widths
        for (var i = 0; i < childParentData.colSpan; i++) {
          final colIndex = childParentData.column + i;
          _columnWidths[colIndex] =
              _columnWidths[colIndex].clamp(widthPerColumn, double.infinity);

          // Track how flexible each column is based on content
          final flexibility = (maxWidth - minWidth) / childParentData.colSpan;
          columnFlexibility[colIndex] =
              math.max(columnFlexibility[colIndex], flexibility);
        }
      }
      child = childParentData.nextSibling;
    }

    // Calculate total minimum width and distribute extra space
    final totalMinWidth =
        _columnWidths.reduce((a, b) => a + b) + _padding.horizontal;
    final extraWidth =
        (constraints.maxWidth - totalMinWidth).clamp(0.0, double.infinity);

    if (extraWidth > 0) {
      // Calculate total flexibility
      final totalFlexibility = columnFlexibility.reduce((a, b) => a + b);

      if (totalFlexibility > 0) {
        // Distribute extra space proportionally to column flexibility
        for (var i = 0; i < _columnCount; i++) {
          final proportion = columnFlexibility[i] / totalFlexibility;
          _columnWidths[i] += extraWidth * proportion;
        }
      } else {
        // If no flexible columns found, distribute evenly
        final widthPerColumn = extraWidth / _columnCount;
        for (var i = 0; i < _columnCount; i++) {
          _columnWidths[i] += widthPerColumn;
        }
      }
    }

    // Calculate row heights
    final rowHeights = List<double>.filled(_rowCount, 0);
    child = firstChild;
    while (child != null) {
      final childParentData = child.parentData! as TableCellData;
      if (!childParentData.isSeparator) {
        // Calculate the width this cell will have
        var cellWidth = 0.0;
        for (var i = 0; i < childParentData.colSpan; i++) {
          cellWidth += _columnWidths[childParentData.column + i];
        }

        // Get the height needed for this width
        final childHeight = child
                .getDryLayout(BoxConstraints.tightFor(width: cellWidth))
                .height /
            childParentData.rowSpan;
        for (var i = 0; i < childParentData.rowSpan; i++) {
          rowHeights[childParentData.row + i] =
              rowHeights[childParentData.row + i]
                  .clamp(childHeight, double.infinity);
        }
      }
      child = childParentData.nextSibling;
    }

    return constraints.constrain(
      Size(
        _columnWidths.reduce((a, b) => a + b) + _padding.horizontal,
        rowHeights.reduce((a, b) => a + b) + _padding.vertical,
      ),
    );
  }
}
