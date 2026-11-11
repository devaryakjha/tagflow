import 'package:html/dom.dart' as dom;
import 'package:tagflow/legacy.dart';
import 'package:tagflow/src/adapters/content_limits.dart';

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

    // Parse caption if present
    TagflowNode? caption;
    for (final element in node.children.whereType<dom.Element>()) {
      if (element.localName?.toLowerCase() == 'caption') {
        caption = _elementParser.tryParse(element, parser);
        break;
      }
    }

    final table = TagflowTableElement(
      tag: 'table',
      rowCount: structure.rows,
      columnCount: structure.columns,
      rows: List.empty(growable: true),
      spans: Map.from({}),
      attributes: parseAttributes(node),
      caption: caption,
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

        columnsInRow += _colSpan(cell);
      }

      maxColumns = maxColumns < columnsInRow ? columnsInRow : maxColumns;
    }

    return _TableStructure(
      rows: totalRows,
      columns: maxColumns > maxTableColumns ? maxTableColumns : maxColumns,
    );
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
    // Column -> last row index covered by a row span. Sparse, so a large
    // rowspan costs nothing per covered row.
    final occupiedThroughRow = <int, int>{};
    bool isOccupied(int column) =>
        (occupiedThroughRow[column] ?? -1) >= rowIndex;

    // Reuse the row getter
    final rows = _getTableRows(element);

    for (final rowElement in rows) {
      final cells = <TagflowNode>[];
      var colIndex = 0;

      for (final cell in rowElement.children) {
        final tag = cell.localName?.toLowerCase();
        if (tag != 'td' && tag != 'th') continue;

        // Skip cells covered by row spans from earlier rows
        while (colIndex < structure.columns && isOccupied(colIndex)) {
          cells.add(TagflowElement.empty());
          colIndex++;
        }

        final rowspan = _rowSpan(cell);
        final colspan = _colSpan(cell);

        // Create cell element
        final cellElement =
            _elementParser.tryParse(cell, parser) ?? TagflowElement.empty();
        cells.add(cellElement);

        // Mark spans
        if (rowspan > 1 || colspan > 1) {
          table.setSpan(rowIndex, colIndex, rowSpan: rowspan, colSpan: colspan);
        }

        if (rowspan > 1) {
          final end = colIndex + colspan < structure.columns
              ? colIndex + colspan
              : structure.columns;
          for (var c = colIndex; c < end; c++) {
            occupiedThroughRow[c] = rowIndex + rowspan - 1;
          }
        }

        colIndex += colspan;
      }

      // Slots covered by row spans after the last cell
      while (colIndex < structure.columns && isOccupied(colIndex)) {
        cells.add(TagflowElement.empty());
        colIndex++;
      }

      // Fill remaining columns with empty cells
      while (cells.length < structure.columns) {
        cells.add(TagflowElement.empty());
      }

      // Create row element and add it to table
      final rowNode =
          (_elementParser.tryParse(rowElement, parser) ??
                TagflowElement.empty())
            ..children = cells;

      table.addRow(rowNode);
      rowIndex++;
    }
  }
}

int _colSpan(dom.Element cell) {
  return clampTableSpan(cell.attributes['colspan'], maxTableColSpan);
}

int _rowSpan(dom.Element cell) {
  return clampTableSpan(cell.attributes['rowspan'], maxTableRowSpan);
}

class _TableStructure {
  const _TableStructure({required this.rows, required this.columns});

  final int rows;
  final int columns;
}
