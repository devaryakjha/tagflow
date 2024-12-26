import 'package:tagflow/tagflow.dart';

class TagflowTableElement extends TagflowNode {
  TagflowTableElement({
    required super.tag,
    required this.rows,
    required this.columns,
    Map<String, String>? attributes,
    super.parent,
  }) : _attributes = attributes ?? {};

  final int rows;
  final int columns;
  final List<List<TagflowNode>> cells = [];
  final Map<String, CellSpan> spans = {};

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
  void reparent([TagflowNode? newParent]) {
    // TODO(devaryakjha): implement reparent
  }

  @override
  void operator []=(String key, String value) {
    _attributes[key] = value;
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
