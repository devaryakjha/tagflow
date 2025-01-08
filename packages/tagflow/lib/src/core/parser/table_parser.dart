import 'package:html/dom.dart' as dom;
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
      rowCount: structure.rows,
      columnCount: structure.columns,
      rows: List.empty(growable: true),
      spans: Map.from({}),
      attributes: parseAttributes(node),
    );

    _populateCells(table, node, parser, structure);
    return table;
  }

  _TableStructure _analyzeStructure(dom.Element table) {
    var maxColumns = 0;
    var totalRows = 0;

    // Cache the tag checks
    final rows = _getTableRows(table);

    for (final row in rows) {
      totalRows++;
      var columnsInRow = 0;

      for (final cell in row.children) {
        final tag = cell.localName?.toLowerCase();
        if (tag != 'td' && tag != 'th') continue;

        final colspan = int.tryParse(cell.attributes['colspan'] ?? '1') ?? 1;
        columnsInRow += colspan;
      }

      maxColumns = maxColumns < columnsInRow ? columnsInRow : maxColumns;
    }

    return _TableStructure(rows: totalRows, columns: maxColumns);
  }

  /// Helper method to get table rows, handling tbody/thead sections
  Iterable<dom.Element> _getTableRows(dom.Element table) {
    // First try to get rows from tbody/thead
    final sections = table.children.whereType<dom.Element>().where((node) {
      final tag = node.localName?.toLowerCase();
      return tag == 'tbody' || tag == 'thead';
    });

    if (sections.isEmpty) {
      // If no sections, get direct tr children
      return table.children.whereType<dom.Element>().where(
            (node) => node.localName?.toLowerCase() == 'tr',
          );
    }

    // Get rows from all sections
    return sections.expand(
      (section) => section.children.whereType<dom.Element>().where(
            (node) => node.localName?.toLowerCase() == 'tr',
          ),
    );
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

    // Reuse the row getter
    final rows = _getTableRows(element);

    for (final rowElement in rows) {
      final cells = <TagflowNode>[];
      var colIndex = 0;

      // Skip already occupied cells (from previous rowspans)
      while (colIndex < structure.columns && occupied[rowIndex][colIndex]) {
        cells.add(TagflowElement.empty());
        colIndex++;
      }

      for (final cell in rowElement.children) {
        final tag = cell.localName?.toLowerCase();
        if (tag != 'td' && tag != 'th') continue;

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

      // Create row element and add it to table
      final rowNode = (_elementParser.tryParse(rowElement, parser) ??
          TagflowElement.empty())
        ..children = cells;

      table.addRow(rowNode);
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
