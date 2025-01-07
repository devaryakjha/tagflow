import 'package:tagflow/tagflow.dart';

class TagflowTableElement extends TagflowNode {
  const TagflowTableElement({
    required super.tag,
    required this.rowCount,
    required this.columnCount,
    required this.rows,
    required this.spans,
    Map<String, String>? attributes,
    super.parent,
  }) : _attributes = attributes ?? const {};

  final int rowCount;
  final int columnCount;
  final List<TagflowNode> rows;
  final Map<String, CellSpan> spans;

  /// Element's attributes
  final Map<String, String> _attributes;

  void addRow(TagflowNode row) {
    rows.add(row);
  }

  CellSpan? getSpan(int row, int column) => spans['$row:$column'];

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
  TagflowNode reparent([TagflowNode? newParent]) {
    return TagflowTableElement(
      tag: tag,
      rowCount: rowCount,
      columnCount: columnCount,
      rows: rows.map((e) => e.reparent(this)).toList(),
      spans: spans,
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

class CellSpan {
  const CellSpan({
    required this.rowSpan,
    required this.colSpan,
  });

  final int rowSpan;
  final int colSpan;
}
