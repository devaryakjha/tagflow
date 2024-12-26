import 'package:html/dom.dart' as dom;
import 'package:tagflow/src/core/parser/base_parser.dart';
import 'package:tagflow/src/core/parser/element_parser.dart';
import 'package:tagflow/tagflow.dart';

class TableParser extends NodeParser<TagflowTableElement> {
  const TableParser();

  static const _elementParser = ElementParser();

  @override
  bool canHandle(dom.Node node) {
    if (node is! dom.Element) return false;
    return node.localName?.toLowerCase() == 'table';
  }

  @override
  TagflowTableElement? tryParse(dom.Node node, TagflowParser parser) {
    if (node is! dom.Element) return null;

    final structure = _analyzeStructure(node);
    final table = TagflowTableElement(
      tag: 'table',
      rows: structure.rows,
      columns: structure.columns,
      cells: List.empty(growable: true),
      spans: Map.from({}),
      attributes: parseAttributes(node),
    );

    _populateCells(table, node, parser, structure);
    return table;
  }

  _TableStructure _analyzeStructure(dom.Element table) {
    var maxColumns = 0;
    var totalRows = 0;

    for (final row in table.querySelectorAll('tr')) {
      totalRows++;
      var columnsInRow = 0;

      for (final cell in row.children) {
        if (cell.localName?.toLowerCase() != 'td' &&
            cell.localName?.toLowerCase() != 'th') {
          continue;
        }

        final colspan = int.tryParse(cell.attributes['colspan'] ?? '1') ?? 1;
        columnsInRow += colspan;
      }

      maxColumns = maxColumns < columnsInRow ? columnsInRow : maxColumns;
    }

    return _TableStructure(rows: totalRows, columns: maxColumns);
  }

  void _populateCells(
    TagflowTableElement table,
    dom.Element element,
    TagflowParser parser,
    _TableStructure structure,
  ) {
    var rowIndex = 0;
    final occupied = List.generate(
      structure.rows,
      (_) => List.filled(structure.columns, false),
    );

    for (final row in element.querySelectorAll('tr')) {
      final cells = <TagflowNode>[];
      var colIndex = 0;

      // Skip already occupied cells (from previous rowspans)
      while (colIndex < structure.columns && occupied[rowIndex][colIndex]) {
        cells.add(TagflowElement.empty());
        colIndex++;
      }

      for (final cell in row.children) {
        if (cell.localName?.toLowerCase() != 'td' &&
            cell.localName?.toLowerCase() != 'th') {
          continue;
        }

        // Skip occupied cells
        while (colIndex < structure.columns && occupied[rowIndex][colIndex]) {
          cells.add(TagflowElement.empty());
          colIndex++;
        }

        final rowspan = int.tryParse(cell.attributes['rowspan'] ?? '1') ?? 1;
        final colspan = int.tryParse(cell.attributes['colspan'] ?? '1') ?? 1;

        // Create cell element
        final cellElement =
            _elementParser.tryParse(cell, parser) ?? TagflowElement.empty();
        cells.add(cellElement);

        // Mark spans
        if (rowspan > 1 || colspan > 1) {
          table.setSpan(
            rowIndex,
            colIndex,
            rowSpan: rowspan,
            colSpan: colspan,
          );
        }

        // Mark occupied cells
        for (var r = 0; r < rowspan; r++) {
          for (var c = 0; c < colspan; c++) {
            if (rowIndex + r < structure.rows &&
                colIndex + c < structure.columns) {
              occupied[rowIndex + r][colIndex + c] = true;
            }
          }
        }

        colIndex += colspan;
      }

      // Fill remaining columns with empty cells
      while (cells.length < structure.columns) {
        cells.add(TagflowElement.empty());
      }

      table.addRow(cells);
      rowIndex++;
    }
  }
}

class _TableStructure {
  const _TableStructure({
    required this.rows,
    required this.columns,
  });

  final int rows;
  final int columns;
}
