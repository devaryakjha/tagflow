import 'dart:collection';

import 'package:tagflow/src/core/models/models.dart';
import 'package:tagflow/src/core/parser/parser.dart';
import 'package:tagflow/src/runtime/runtime.dart';
import 'package:tagflow/src/tagflow_options.dart';

const _htmlAdapterName = 'html';
const _htmlTagKey = 'htmlTag';
const _htmlAttributesKey = 'htmlAttributes';
const _tableRowCountKey = 'tableRowCount';
const _tableColumnCountKey = 'tableColumnCount';
const _syntheticRootStyle = 'display: flex; flex-direction: column; gap: 1rem;';

/// Converts HTML input into the native Tagflow runtime document model.
///
/// This first adapter slice intentionally delegates HTML parsing to the legacy
/// parser so current rendering behavior remains stable while
/// [TagflowDocument] becomes the public render input.
final class TagflowHtmlAdapter {
  /// Creates an HTML adapter.
  const TagflowHtmlAdapter({this.debug, this.renderBoundary});

  /// Optional debug override for the underlying HTML parser.
  final bool? debug;

  /// Optional render-boundary override for the underlying HTML parser.
  final TagflowRenderBoundary? renderBoundary;

  /// Parses [html] into a source-tagged [TagflowDocument].
  TagflowDocument parse(
    String html, {
    String? id,
    Uri? uri,
    TagflowMetadata? metadata,
    TagflowOptions options = TagflowOptions.defaults,
  }) {
    final parser = TagflowParser(
      debug: debug ?? options.debug,
      renderBoundary: renderBoundary ?? options.renderBoundary,
    );
    final root = parser.parse(html);
    final source = TagflowSourceInfo(
      kind: TagflowSourceKind.html,
      adapter: _htmlAdapterName,
      uri: uri,
    );
    final rootNodes = _isSyntheticRoot(root) ? root.children : [root];

    return TagflowDocument(
      id: id ?? _documentIdFor(html),
      children: [
        for (final indexed in rootNodes.indexed)
          _documentNodeFromLegacy(indexed.$2, [indexed.$1], source),
      ],
      metadata: metadata,
      source: source,
    );
  }
}

/// Transitional bridge from runtime documents into the legacy converter tree.
//
// TODO(devaryakjha): Replace this bridge with semantic component-registry
// rendering once the renderer contract lands.
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

TagflowDocumentNode _documentNodeFromLegacy(
  TagflowNode node,
  List<int> path,
  TagflowSourceInfo documentSource,
) {
  final id = TagflowNodeIds.fromPath(path);
  final source = TagflowSourceInfo(
    kind: TagflowSourceKind.html,
    adapter: _htmlAdapterName,
    uri: documentSource.uri,
    metadata: TagflowMetadata({_htmlTagKey: node.tag}),
  );
  final metadata = _metadataForLegacyNode(node);
  final presentation = TagflowPresentation(
    variant: _variantForHtmlTag(node.tag),
    width: _parseDimension(node['width']),
    height: _parseDimension(node['height']),
    hints: {
      _htmlTagKey: node.tag,
      if (node.className != null) 'className': node.className,
    },
  );
  final children = [
    for (final indexed in node.children.indexed)
      _documentNodeFromLegacy(indexed.$2, [
        ...path,
        indexed.$1,
      ], documentSource),
  ];

  if (node.isTextNode) {
    return TagflowDocumentNode.text(
      id: id,
      text: node.textContent ?? '',
      metadata: metadata,
      presentation: presentation,
      source: source,
    );
  }

  return switch (node.tag) {
    'p' => TagflowDocumentNode.paragraph(
      id: id,
      children: children,
      metadata: metadata,
      presentation: presentation,
      source: source,
    ),
    'h1' || 'h2' || 'h3' || 'h4' || 'h5' || 'h6' => TagflowDocumentNode.heading(
      id: id,
      level: int.parse(node.tag.substring(1)),
      children: children,
      metadata: metadata,
      presentation: presentation,
      source: source,
    ),
    'a' => TagflowDocumentNode.link(
      id: id,
      url: Uri.tryParse(node['href'] ?? '') ?? Uri(),
      children: children,
      metadata: metadata,
      presentation: presentation,
      source: source,
    ),
    'ul' || 'ol' => TagflowDocumentNode.list(
      id: id,
      ordered: node.tag == 'ol',
      startIndex: int.tryParse(node['start'] ?? ''),
      children: children,
      metadata: metadata,
      presentation: presentation,
      source: source,
    ),
    'li' => TagflowDocumentNode.listItem(
      id: id,
      children: children,
      metadata: metadata,
      presentation: presentation,
      source: source,
    ),
    'blockquote' => TagflowDocumentNode.blockquote(
      id: id,
      children: children,
      metadata: metadata,
      presentation: presentation,
      source: source,
    ),
    'pre' => TagflowDocumentNode.codeBlock(
      id: id,
      text: _textContentFor(node),
      language: node.className,
      metadata: metadata,
      presentation: presentation,
      source: source,
    ),
    'code' => TagflowDocumentNode.inlineCode(
      id: id,
      text: _textContentFor(node),
      metadata: metadata,
      presentation: presentation,
      source: source,
    ),
    'img' => TagflowDocumentNode.image(
      id: id,
      url: Uri.tryParse(node['src'] ?? '') ?? Uri(),
      alt: node['alt'],
      width: _parseDimension(node['width']),
      height: _parseDimension(node['height']),
      metadata: metadata,
      presentation: presentation,
      source: source,
    ),
    'table' => TagflowDocumentNode.table(
      id: id,
      children: children,
      metadata: metadata,
      presentation: presentation,
      source: source,
    ),
    'tr' => TagflowDocumentNode.tableRow(
      id: id,
      children: children,
      metadata: metadata,
      presentation: presentation,
      source: source,
    ),
    'td' || 'th' => TagflowDocumentNode.tableCell(
      id: id,
      children: children,
      rowSpan: int.tryParse(node['rowspan'] ?? '') ?? 1,
      colSpan: int.tryParse(node['colspan'] ?? '') ?? 1,
      header: node.tag == 'th',
      metadata: metadata,
      presentation: presentation,
      source: source,
    ),
    'hr' => TagflowDocumentNode.horizontalRule(
      id: id,
      metadata: metadata,
      presentation: presentation,
      source: source,
    ),
    'div' ||
    'section' ||
    'article' ||
    'aside' ||
    'nav' ||
    'header' ||
    'footer' ||
    'main' => TagflowDocumentNode.container(
      id: id,
      children: children,
      metadata: metadata,
      presentation: presentation,
      source: source,
    ),
    _ => TagflowDocumentNode.unsupported(
      id: id,
      unsupportedReason: 'HTML tag "${node.tag}" has no semantic mapping yet.',
      children: children,
      metadata: metadata,
      presentation: presentation,
      source: source,
    ),
  };
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
    final rows = children;
    return TagflowTableElement(
      tag: tag,
      rowCount: _metadataInt(node, _tableRowCountKey) ?? rows.length,
      columnCount:
          _metadataInt(node, _tableColumnCountKey) ?? _maxChildCount(rows),
      rows: rows,
      spans: const {},
      attributes: attributes,
    );
  }

  return TagflowElement(tag: tag, children: children, attributes: attributes);
}

TagflowMetadata _metadataForLegacyNode(TagflowNode node) {
  final attributes = node.attributes == null
      ? const <String, String>{}
      : Map<String, String>.from(node.attributes!);
  return TagflowMetadata({
    _htmlTagKey: node.tag,
    if (attributes.isNotEmpty) _htmlAttributesKey: attributes,
    if (node is TagflowTableElement) ...{
      _tableRowCountKey: node.rowCount,
      _tableColumnCountKey: node.columnCount,
    },
  });
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

  return switch (node.kind) {
    TagflowNodeKind.root || TagflowNodeKind.container => 'div',
    TagflowNodeKind.paragraph => 'p',
    TagflowNodeKind.heading => 'h${node.level ?? 1}',
    TagflowNodeKind.text => '#text',
    TagflowNodeKind.link => 'a',
    TagflowNodeKind.list => node.ordered ?? false ? 'ol' : 'ul',
    TagflowNodeKind.listItem => 'li',
    TagflowNodeKind.blockquote => 'blockquote',
    TagflowNodeKind.codeBlock => 'pre',
    TagflowNodeKind.inlineCode => 'code',
    TagflowNodeKind.image => 'img',
    TagflowNodeKind.table => 'table',
    TagflowNodeKind.tableRow => 'tr',
    TagflowNodeKind.tableCell => node.header ? 'th' : 'td',
    TagflowNodeKind.horizontalRule => 'hr',
    TagflowNodeKind.unsupported => 'div',
  };
}

String? _variantForHtmlTag(String tag) {
  return switch (tag) {
    'h1' || 'h2' || 'h3' || 'h4' || 'h5' || 'h6' => 'heading',
    'p' => 'paragraph',
    'pre' || 'code' => 'code',
    _ => null,
  };
}

String _textContentFor(TagflowNode node) {
  final buffer = StringBuffer(node.textContent ?? '');
  for (final child in node.children) {
    buffer.write(_textContentFor(child));
  }
  return buffer.toString();
}

double? _parseDimension(String? value) {
  if (value == null || value.isEmpty) return null;
  return double.tryParse(value);
}

int? _metadataInt(TagflowDocumentNode node, String key) {
  final value = node.metadata[key];
  return value is int ? value : null;
}

int _maxChildCount(List<TagflowNode> nodes) {
  var max = 0;
  for (final node in nodes) {
    if (node.children.length > max) max = node.children.length;
  }
  return max;
}

bool _isSyntheticRoot(TagflowNode node) {
  return node.tag == 'div' &&
      node.children.isNotEmpty &&
      node['style'] == _syntheticRootStyle;
}

String _documentIdFor(String html) {
  var hash = 0;
  for (final codeUnit in html.codeUnits) {
    hash = (hash * 31 + codeUnit) & 0x3fffffff;
  }
  return 'html-$hash';
}
