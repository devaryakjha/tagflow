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
    final layout = _SemanticTableLayout.from(node, context);
    final resolvedBorder =
        border ??
        _borderHint(node) ??
        TagflowTableBorder.all(color: const Color(0x1F000000));
    final resolvedColumnSpacing = columnSpacing.isNaN
        ? _doubleHint(node, _tableColumnSpacingHintKey) ?? 0
        : columnSpacing;
    final resolvedRowSpacing = rowSpacing.isNaN
        ? _doubleHint(node, _tableRowSpacingHintKey) ?? 0
        : rowSpacing;

    if (layout.rowCount == 0 || layout.columnCount == 0) {
      return const SizedBox.shrink();
    }

    return TagflowTable(
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
            child: _renderCell(context, table, row, cell),
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
  TagflowDocumentNode table,
  TagflowDocumentNode row,
  TagflowDocumentNode cell,
) {
  final content = _renderCellContent(context, cell);
  final padded = Padding(
    padding:
        _edgeInsetsHint(cell, 'padding') ??
        _edgeInsetsHint(table, _tableCellPaddingHintKey) ??
        const EdgeInsets.all(8),
    child: content,
  );
  final decorated = DecoratedBox(
    decoration: BoxDecoration(
      color:
          _colorHint(cell, 'backgroundColor') ??
          _colorHint(row, 'backgroundColor') ??
          (cell.header ? const Color(0x12000000) : null),
    ),
    child: padded,
  );

  if (!cell.header) return decorated;

  return DefaultTextStyle.merge(
    style: const TextStyle(fontWeight: FontWeight.w700),
    child: decorated,
  );
}

Widget _renderCellContent(
  TagflowComponentContext context,
  TagflowDocumentNode cell,
) {
  if (cell.children.isEmpty) {
    return const SizedBox.shrink();
  }

  final blocks = <Widget>[];
  final inlineRun = <TagflowDocumentNode>[];

  void flushInlineRun() {
    if (inlineRun.isEmpty) {
      return;
    }

    blocks.add(
      Wrap(children: [for (final node in inlineRun) context.render(node)]),
    );
    inlineRun.clear();
  }

  for (final child in cell.children) {
    if (_isInlineCellNode(child)) {
      inlineRun.add(child);
      continue;
    }

    flushInlineRun();
    blocks.add(context.render(child));
  }

  flushInlineRun();

  if (blocks.length == 1) {
    return blocks.single;
  }

  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: blocks,
  );
}

bool _isInlineCellNode(TagflowDocumentNode node) {
  return switch (node.kind) {
    TagflowNodeKind.text ||
    TagflowNodeKind.link ||
    TagflowNodeKind.inlineCode => true,
    TagflowNodeKind.container =>
      node.presentation.inlineSemantics.isNotEmpty ||
          _isInlineFallbackTag(_htmlTag(node)),
    _ => false,
  };
}

String? _htmlTag(TagflowDocumentNode node) {
  final metadataTag = node.metadata['htmlTag'];
  if (metadataTag is String && metadataTag.isNotEmpty) {
    return metadataTag;
  }

  final hintTag = node.presentation.hints['htmlTag'];
  if (hintTag is String && hintTag.isNotEmpty) {
    return hintTag;
  }

  return null;
}

bool _isInlineFallbackTag(String? htmlTag) {
  return switch (htmlTag) {
    'a' ||
    'b' ||
    'strong' ||
    'i' ||
    'em' ||
    'u' ||
    'span' ||
    'small' ||
    'mark' ||
    'del' ||
    'ins' ||
    'sub' ||
    'sup' => true,
    _ => false,
  };
}

int _positiveSpan(int value) => value < 1 ? 1 : value;

TagflowTableBorder? _borderHint(TagflowDocumentNode node) {
  final outsideWidth = _doubleHint(node, _tableBorderWidthHintKey);
  final insideWidth = _doubleHint(node, _tableInsideBorderWidthHintKey);
  final color =
      _colorHint(node, _tableBorderColorHintKey) ?? const Color(0xFF000000);

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
