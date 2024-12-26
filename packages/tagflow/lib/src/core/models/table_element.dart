import 'package:tagflow/tagflow.dart';

class TagflowTableElement extends TagflowNode {
  const TagflowTableElement({
    required super.tag,
    required this.rows,
    required this.columns,
    required this.cells,
    required this.spans,
    Map<String, String>? attributes,
    super.parent,
  }) : _attributes = attributes ?? const {};

  final int rows;
  final int columns;
  final List<List<TagflowNode>> cells;
  final Map<String, CellSpan> spans;

  /// Element's attributes
  final Map<String, String> _attributes;

  void addRow(List<TagflowNode> row) {
    if (row.length != columns) {
      throw Exception('Row length must match number of columns');
    }
    cells.add(row);
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
      rows: rows,
      columns: columns,
      cells: cells.map((e) => e.map((c) => c.reparent(this)).toList()).toList(),
      spans: spans,
      parent: newParent,
      attributes: attributes,
    );
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
