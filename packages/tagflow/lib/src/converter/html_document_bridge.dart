import 'dart:collection';

import 'package:tagflow/src/adapters/content_limits.dart';
import 'package:tagflow/src/core/models/models.dart';
import 'package:tagflow/src/runtime/runtime.dart';

// Metadata keys written by the HTML adapter.
const _htmlTagKey = 'htmlTag';
const _htmlAttributesKey = 'htmlAttributes';
const _tableRowCountKey = 'tableRowCount';
const _tableColumnCountKey = 'tableColumnCount';
const _syntheticRootStyle = 'display: flex; flex-direction: column; gap: 1rem;';

/// Transitional bridge from runtime documents into the legacy converter tree.
//
// This is intentionally kept behind package:tagflow/legacy.dart so existing
// custom converter integrations can migrate during the 1.x support window. New
// extension work should target semantic component registries instead.
@Deprecated(
  'Legacy converter bridge. Use TagflowComponentRegistry instead. '
  'Will be removed in tagflow 2.0.',
)
abstract final class TagflowHtmlDocumentBridge {
  /// Converts [document] into the current converter-compatible node tree.
  static TagflowNode toLegacyNode(TagflowDocument document) {
    final legacyNode = switch (document.children.length) {
      0 => TagflowElement.empty(),
      1 => _legacyNodeFromDocumentNode(document.children.single),
      _ => TagflowElement(
        tag: 'div',
        attributes: LinkedHashMap.from({'style': _syntheticRootStyle}),
        children: document.children.map(_legacyNodeFromDocumentNode).toList(),
      ),
    };

    return legacyNode.reparent();
  }
}

TagflowNode _legacyNodeFromDocumentNode(TagflowDocumentNode node) {
  final tag = _htmlTagForDocumentNode(node);
  final attributes = _attributesForDocumentNode(node);

  if (node.kind == TagflowNodeKind.text) {
    return TagflowElement.text(node.text ?? '');
  }

  if (node.kind == TagflowNodeKind.image || tag == 'img') {
    return TagflowImgElement(attributes: attributes);
  }

  final children = switch (node.kind) {
    TagflowNodeKind.codeBlock || TagflowNodeKind.inlineCode => [
      if (node.text != null) TagflowElement.text(node.text!),
    ],
    _ => node.children.map(_legacyNodeFromDocumentNode).toList(),
  };

  if (node.kind == TagflowNodeKind.table || tag == 'table') {
    TagflowNode? caption;
    final rows = <TagflowNode>[];
    for (final child in children) {
      if (child.tag == 'caption' && caption == null) {
        caption = child;
      } else {
        rows.add(child);
      }
    }

    final columnCount = _padLegacyTableRows(rows);

    return TagflowTableElement(
      tag: tag,
      rowCount: _metadataInt(node, _tableRowCountKey) ?? rows.length,
      columnCount: _metadataInt(node, _tableColumnCountKey) ?? columnCount,
      rows: rows,
      spans: const {},
      caption: caption,
      attributes: attributes,
    );
  }

  return TagflowElement(tag: tag, children: children, attributes: attributes);
}

Map<String, String> _attributesForDocumentNode(TagflowDocumentNode node) {
  final rawAttributes = node.metadata[_htmlAttributesKey];
  final attributes = rawAttributes is Map
      ? rawAttributes.map((key, value) => MapEntry('$key', '$value'))
      : <String, String>{};

  if (node.kind == TagflowNodeKind.link && node.url != null) {
    attributes.putIfAbsent('href', () => node.url.toString());
  }
  if (node.kind == TagflowNodeKind.image && node.url != null) {
    attributes.putIfAbsent('src', () => node.url.toString());
  }
  if (node.alt != null) {
    attributes.putIfAbsent('alt', () => node.alt!);
  }
  if (node.width != null) {
    attributes.putIfAbsent('width', () => node.width!.toString());
  }
  if (node.height != null) {
    attributes.putIfAbsent('height', () => node.height!.toString());
  }
  if (node.rowSpan != 1) {
    attributes.putIfAbsent('rowspan', () => node.rowSpan.toString());
  }
  if (node.colSpan != 1) {
    attributes.putIfAbsent('colspan', () => node.colSpan.toString());
  }

  return attributes;
}

String _htmlTagForDocumentNode(TagflowDocumentNode node) {
  final metadataTag = node.metadata[_htmlTagKey];
  final presentationTag = node.presentation.hints[_htmlTagKey];
  if (metadataTag is String) return metadataTag;
  if (presentationTag is String) return presentationTag;
  if (node.kind == TagflowNodeKind.container &&
      (node.presentation.display == TagflowDisplay.inline ||
          node.presentation.inlineSemantics.isNotEmpty)) {
    return 'span';
  }

  return switch (node.kind) {
    TagflowNodeKind.root || TagflowNodeKind.container => 'div',
    TagflowNodeKind.paragraph => 'p',
    TagflowNodeKind.heading => 'h${node.level ?? 1}',
    TagflowNodeKind.text => '#text',
    TagflowNodeKind.link => 'a',
    TagflowNodeKind.list => node.ordered ?? false ? 'ol' : 'ul',
    TagflowNodeKind.listItem => 'li',
    TagflowNodeKind.descriptionList => 'dl',
    TagflowNodeKind.descriptionTerm => 'dt',
    TagflowNodeKind.descriptionDetails => 'dd',
    TagflowNodeKind.blockquote => 'blockquote',
    TagflowNodeKind.disclosure => 'details',
    TagflowNodeKind.disclosureSummary => 'summary',
    TagflowNodeKind.callout => 'aside',
    TagflowNodeKind.codeBlock => 'pre',
    TagflowNodeKind.inlineCode => 'code',
    TagflowNodeKind.image => 'img',
    TagflowNodeKind.table => 'table',
    TagflowNodeKind.tableRow => 'tr',
    TagflowNodeKind.tableCell => node.header ? 'th' : 'td',
    TagflowNodeKind.tableCaption => 'caption',
    TagflowNodeKind.horizontalRule => 'hr',
    TagflowNodeKind.unsupported => 'div',
  };
}

int? _metadataInt(TagflowDocumentNode node, String key) {
  final value = node.metadata[key];
  return value is int ? value : null;
}

/// Pads legacy table [rows] with `#empty` cells so every row has one entry per
/// grid column, the shape the legacy table converters expect.
///
/// Mirrors the legacy table parser: a slot covered by a row span from above
/// gets a placeholder before the next real cell, and a column span keeps one
/// entry for the spanning cell. Returns the column count.
int _padLegacyTableRows(List<TagflowNode> rows) {
  int span(TagflowNode cell, String attribute, int max) {
    return clampTableSpan(cell[attribute], max);
  }

  var columns = 0;
  for (final row in rows) {
    var width = 0;
    for (final cell in row.children) {
      width += span(cell, 'colspan', maxTableColSpan);
    }
    if (width > columns) columns = width;
  }
  if (columns > maxTableColumns) columns = maxTableColumns;

  final occupied = <int, int>{};
  for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) {
    final row = rows[rowIndex];
    final cells = <TagflowNode>[];
    var column = 0;

    void skipOccupied() {
      while (column < columns && (occupied[column] ?? -1) >= rowIndex) {
        cells.add(TagflowElement.empty());
        column++;
      }
    }

    for (final cell in row.children) {
      skipOccupied();
      cells.add(cell);
      final rowSpan = span(cell, 'rowspan', maxTableRowSpan);
      final colSpan = span(cell, 'colspan', maxTableColSpan);
      for (var c = column; c < column + colSpan && c < columns; c++) {
        occupied[c] = rowIndex + rowSpan - 1;
      }
      column += colSpan;
    }
    while (cells.length < columns) {
      cells.add(TagflowElement.empty());
    }
    row.children = cells;
  }

  return columns;
}
