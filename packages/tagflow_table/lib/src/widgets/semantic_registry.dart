import 'dart:math' as math;

import 'package:flutter/widgets.dart' hide TableCell;
import 'package:tagflow/tagflow.dart';
import 'package:tagflow_table/src/rendering/tagflow_table.dart';
import 'package:tagflow_table/src/widgets/tagflow_table.dart';

const _tableBorderWidthHintKey = 'tableBorderWidth';
const _tableInsideBorderWidthHintKey = 'tableInsideBorderWidth';
const _tableBorderColorHintKey = 'tableBorderColor';
const _tableColumnSpacingHintKey = 'tableColumnSpacing';
const _tableRowSpacingHintKey = 'tableRowSpacing';
const _tableCellPaddingHintKey = 'tableCellPadding';
const _textAlignHintKey = 'textAlign';

/// Creates a semantic registry fragment backed by [TagflowTable].
///
/// Use this extension with `TagflowComponentRegistry(extensions: [...])` when
/// rendering native [TagflowDocument] table nodes through the first-party table
/// render object instead of the core package's simple fallback table.
///
/// Unset colours follow the ambient [TagflowRenderTheme]: the border uses
/// [TagflowRenderTheme.borderColor], header cells use
/// [TagflowRenderTheme.tableHeaderBackgroundColor] and
/// [TagflowRenderTheme.tableHeaderStyle], and a `border` attribute without a
/// colour uses the ambient text colour. Cell content renders like the core
/// table cell, so inline runs such as `some <b>bold</b> text` flow and wrap
/// as one paragraph.
TagflowComponentRegistry tagflowTableComponents({
  TagflowTableBorder? border,
  bool treatFirstRowAsHeader = false,
  Color? headerBackgroundColor,
  EdgeInsets padding = EdgeInsets.zero,
  IndexedWidgetBuilder? separatorBuilder,
  double columnSpacing = double.nan,
  double rowSpacing = double.nan,
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
    final theme = TagflowRenderTheme.of(context.buildContext);
    final layout = _SemanticTableLayout.from(node, context, theme);
    final resolvedBorder =
        border ??
        _borderHint(node, DefaultTextStyle.of(context.buildContext).style) ??
        TagflowTableBorder.all(color: theme.borderColor!);
    final resolvedColumnSpacing = columnSpacing.isNaN
        ? _doubleHint(node, _tableColumnSpacingHintKey) ?? 0
        : columnSpacing;
    final resolvedRowSpacing = rowSpacing.isNaN
        ? _doubleHint(node, _tableRowSpacingHintKey) ?? 0
        : rowSpacing;

    if (layout.rowCount == 0 || layout.columnCount == 0) {
      return const SizedBox.shrink();
    }

    final tableWidget = TagflowTable(
      rowCount: layout.rowCount,
      columnCount: layout.columnCount,
      border: resolvedBorder,
      treatFirstRowAsHeader: treatFirstRowAsHeader,
      headerBackgroundColor: headerBackgroundColor,
      padding: padding,
      separatorBuilder: separatorBuilder,
      columnSpacing: resolvedColumnSpacing,
      rowSpacing: resolvedRowSpacing,
      children: layout.cells,
    );

    final caption = _captionWidget(context, node);
    if (caption == null) {
      return tableWidget;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [caption, tableWidget],
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
    TagflowRenderTheme theme,
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

        // A row span past the last row is cut at the end of the table, as
        // the HTML table model does.
        final rowSpan = math.min(
          _clampSpan(cell.rowSpan, _maxRowSpan),
          rows.length - rowIndex,
        );
        final colSpan = _clampSpan(cell.colSpan, _maxColSpan);
        cells.add(
          TableCell(
            row: rowIndex,
            column: columnIndex,
            rowSpan: rowSpan,
            colSpan: colSpan,
            child: _renderCell(context, theme, table, row, cell),
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

Widget _renderCell(
  TagflowComponentContext context,
  TagflowRenderTheme theme,
  TagflowDocumentNode table,
  TagflowDocumentNode row,
  TagflowDocumentNode cell,
) {
  final content = cell.children.isEmpty
      ? const SizedBox.shrink()
      : context.renderBlockContent(cell);
  final aligned = _alignCellContent(content, cell, row);
  final padded = Padding(
    padding:
        _edgeInsetsHint(cell, 'padding') ??
        _edgeInsetsHint(table, _tableCellPaddingHintKey) ??
        const EdgeInsets.all(8),
    child: aligned,
  );
  final decorated = DecoratedBox(
    decoration: BoxDecoration(
      color:
          _colorHint(cell, 'backgroundColor') ??
          _colorHint(row, 'backgroundColor') ??
          (cell.header ? theme.tableHeaderBackgroundColor : null),
    ),
    child: padded,
  );

  if (!cell.header) return decorated;

  // Flutter's table widgets have no row semantics, so the header role is a
  // hint read after the cell text, the same as the core table.
  return Semantics(
    container: true,
    hint: 'Column header',
    child: DefaultTextStyle.merge(
      style: theme.tableHeaderStyle,
      child: decorated,
    ),
  );
}

Widget _alignCellContent(
  Widget content,
  TagflowDocumentNode cell,
  TagflowDocumentNode row,
) {
  final textAlign = _textAlignHint(cell) ?? _textAlignHint(row);
  final alignment = switch (textAlign) {
    TextAlign.right || TextAlign.end => Alignment.centerRight,
    TextAlign.center => Alignment.center,
    _ => null,
  };

  if (alignment == null) {
    return content;
  }

  return Align(alignment: alignment, child: content);
}

Widget? _captionWidget(
  TagflowComponentContext context,
  TagflowDocumentNode table,
) {
  for (final child in table.children) {
    if (child.kind == TagflowNodeKind.tableCaption) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: DefaultTextStyle.merge(
          style: const TextStyle(fontWeight: FontWeight.w600),
          child: context.render(child),
        ),
      );
    }
  }

  return null;
}

/// Largest spans the HTML specification allows.
const _maxColSpan = 1000;
const _maxRowSpan = 65534;

int _clampSpan(int value, int max) {
  if (value < 1) return 1;
  return value > max ? max : value;
}

TagflowTableBorder? _borderHint(TagflowDocumentNode node, TextStyle text) {
  final outsideWidth = _doubleHint(node, _tableBorderWidthHintKey);
  final insideWidth = _doubleHint(node, _tableInsideBorderWidthHintKey);
  // CSS draws a border without a colour in `currentColor`.
  final color =
      _colorHint(node, _tableBorderColorHintKey) ??
      text.color ??
      const Color(0xFF000000);

  if (outsideWidth == null && insideWidth == null) {
    return null;
  }

  final resolvedOutsideWidth = outsideWidth ?? 0;
  final resolvedInsideWidth = insideWidth ?? resolvedOutsideWidth;
  if (resolvedOutsideWidth <= 0 && resolvedInsideWidth <= 0) {
    return TagflowTableBorder.none;
  }

  BorderSide side(double width) {
    if (width <= 0) {
      return BorderSide.none;
    }

    return BorderSide(color: color, width: width);
  }

  return TagflowTableBorder(
    left: side(resolvedOutsideWidth),
    right: side(resolvedOutsideWidth),
    top: side(resolvedOutsideWidth),
    bottom: side(resolvedOutsideWidth),
    horizontalInside: side(resolvedInsideWidth),
    verticalInside: side(resolvedInsideWidth),
  );
}

Color? _colorHint(TagflowDocumentNode node, String key) {
  final value = node.presentation.hints[key];
  return value is Color ? value : null;
}

double? _doubleHint(TagflowDocumentNode node, String key) {
  final value = node.presentation.hints[key];
  return value is num ? value.toDouble() : null;
}

EdgeInsetsGeometry? _edgeInsetsHint(TagflowDocumentNode node, String key) {
  final value = node.presentation.hints[key];
  return value is EdgeInsetsGeometry ? value : null;
}

TextAlign? _textAlignHint(TagflowDocumentNode node) {
  final value = node.presentation.hints[_textAlignHintKey];
  return value is TextAlign ? value : null;
}
