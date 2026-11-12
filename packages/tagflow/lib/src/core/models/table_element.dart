import 'dart:collection';

import 'package:tagflow/legacy.dart';

/// Legacy parsed `table` element.
class TagflowTableElement extends TagflowNode {
  /// Creates a table element.
  const TagflowTableElement({
    required super.tag,
    required this.rowCount,
    required this.columnCount,
    required this.rows,
    required this.spans,
    this.caption,
    Map<String, String>? attributes,
    super.parent,
  }) : _attributes = attributes ?? const {};

  /// Number of rows.
  final int rowCount;

  /// Number of columns.
  final int columnCount;

  /// The rows, padded to [columnCount] cells.
  final List<TagflowNode> rows;

  /// Cell spans keyed by `'row:column'`.
  final Map<String, CellSpan> spans;

  /// The table caption.
  final TagflowNode? caption;

  /// Element's attributes
  final Map<String, String> _attributes;

  /// Appends [row].
  void addRow(TagflowNode row) {
    rows.add(row);
  }

  /// The span of the cell at [row] and [column].
  CellSpan? getSpan(int row, int column) => spans['$row:$column'];

  /// Records the span of the cell at [row] and [column].
  void setSpan(int row, int column, {int rowSpan = 1, int colSpan = 1}) {
    spans['$row:$column'] = CellSpan(rowSpan: rowSpan, colSpan: colSpan);
  }

  @override
  String? operator [](String key) => _attributes[key];

  @override
  void operator []=(String key, String value) {
    _attributes[key] = value;
  }

  @override
  LinkedHashMap<String, String> get attributes =>
      LinkedHashMap.from(_attributes);

  @override
  TagflowNode reparent([TagflowNode? newParent]) {
    return TagflowTableElement(
      tag: tag,
      rowCount: rowCount,
      columnCount: columnCount,
      rows: rows.map((e) => e.reparent(this)).toList(),
      spans: spans,
      caption: caption?.reparent(this),
      parent: newParent,
      attributes: attributes,
    );
  }

  @override
  List<TagflowNode> get children => rows;

  @override
  set children(List<TagflowNode> value) {
    rows
      ..clear()
      ..addAll(value);
  }
}

/// Row and column span of a legacy table cell.
class CellSpan {
  /// Creates a span.
  const CellSpan({required this.rowSpan, required this.colSpan});

  /// Rows the cell covers.
  final int rowSpan;

  /// Columns the cell covers.
  final int colSpan;
}
