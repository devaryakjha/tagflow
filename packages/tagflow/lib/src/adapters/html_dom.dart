import 'dart:developer' show log;

import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html;
import 'package:tagflow/src/adapters/content_limits.dart';
import 'package:tagflow/src/tagflow_options.dart';

/// A content node read from the `package:html` DOM by the HTML adapter.
///
/// This is a thin view: it keeps the element's normalized attributes and the
/// children that count as content (blank text and comments are left out, and
/// a render boundary is applied), so the adapter can assign path ids over the
/// same children it maps. It is not exported.
final class HtmlSourceNode {
  HtmlSourceNode._element(
    this.tag,
    this.attributes,
    this.children, {
    this.caption,
    this.rowCount,
    this.columnCount,
  }) : text = null;

  HtmlSourceNode._text(String this.text)
    : tag = textTag,
      attributes = const {},
      children = const [],
      caption = null,
      rowCount = null,
      columnCount = null;

  /// Tag of text nodes.
  static const textTag = '#text';

  /// Lower-case element name, or [textTag].
  final String tag;

  /// Attributes with `style` and `class` normalized.
  final Map<String, String> attributes;

  /// Content children. For a table these are its rows, and for a row its
  /// `td` and `th` cells.
  final List<HtmlSourceNode> children;

  /// Text of a text node, with runs of spaces and tabs collapsed outside
  /// `<pre>`.
  final String? text;

  /// The `<caption>` of a table.
  final HtmlSourceNode? caption;

  /// Number of rows of a table.
  final int? rowCount;

  /// Number of columns of a table, at most [maxTableColumns].
  final int? columnCount;

  /// Whether this is a text node.
  bool get isTextNode => tag == textTag;

  /// The value of [attribute], if set.
  String? operator [](String attribute) => attributes[attribute];

  /// The normalized `class` attribute.
  String? get className => attributes['class'];

  /// The normalized `style` attribute.
  String? get style => attributes['style'];
}

/// Parses [input] and reads the top-level content nodes of its body.
///
/// [maxDepth] and [maxNodes] cut the DOM before it is read, replacing cut
/// content with [tagflowLimitDepthTag] and [tagflowLimitNodesTag] elements.
List<HtmlSourceNode> readHtmlBody(
  String input, {
  TagflowRenderBoundary? renderBoundary,
  int? maxDepth,
  int? maxNodes,
  bool debug = false,
}) {
  final document = html.parse(input);
  final body = document.body;
  if (body == null) {
    throw const FormatException('Invalid HTML: no body element found');
  }
  if (debug) log(body.outerHtml);

  if (maxDepth != null || maxNodes != null) {
    limitHtmlDom(body, maxDepth: maxDepth, maxNodes: maxNodes);
  }

  final reader = _HtmlDomReader(renderBoundary);
  reader.boundary?.setHasStartBoundary(
    hasStartBoundary: _hasStartBoundary(body.nodes, renderBoundary),
  );
  // Whitespace between top-level inline elements is not kept.
  return [
    for (final node in reader.readNodes(body.nodes))
      if (!node.isTextNode || node.text!.trim().isNotEmpty) node,
  ];
}

/// Cuts [body] down to [maxDepth] and [maxNodes] before it is read, so the
/// cost of the rest of the pipeline is bounded.
///
/// Depth counts the body's children as 1. Deeper content is replaced by one
/// [tagflowLimitDepthTag] element; nodes after the first [maxNodes], in
/// document order, are removed and one [tagflowLimitNodesTag] element marks
/// the cut. Walks the tree iteratively, so very deep input cannot overflow
/// the stack.
void limitHtmlDom(dom.Element body, {int? maxDepth, int? maxNodes}) {
  final stack = <(dom.Node, int)>[
    for (final node in body.nodes.reversed) (node, 1),
  ];
  var count = 0;
  var markedNodeLimit = false;

  while (stack.isNotEmpty) {
    final (node, depth) = stack.removeLast();

    if (maxNodes != null && count >= maxNodes) {
      if (markedNodeLimit) {
        node.remove();
      } else {
        markedNodeLimit = true;
        node.replaceWith(dom.Element.tag(tagflowLimitNodesTag));
      }
      continue;
    }
    count++;

    if (maxDepth != null && depth > maxDepth) {
      node.replaceWith(dom.Element.tag(tagflowLimitDepthTag));
      continue;
    }

    final children = node.nodes.toList(growable: false);
    for (final child in children.reversed) {
      stack.add((child, depth + 1));
    }
  }
}

final class _HtmlDomReader {
  _HtmlDomReader(this.renderBoundary)
    : boundary = renderBoundary == null
          ? null
          : _RenderBoundaryState(renderBoundary);

  final TagflowRenderBoundary? renderBoundary;
  final _RenderBoundaryState? boundary;

  static final _spacesAndTabs = RegExp(r'[ \t]+');

  /// Reads the content nodes among [nodes], in order.
  ///
  /// Reading a node can move the render boundary (a start or end comment
  /// inside it), so whether a node is kept is decided after it is read.
  List<HtmlSourceNode> readNodes(dom.NodeList nodes) {
    final result = <HtmlSourceNode>[];
    final state = boundary;
    for (final node in nodes) {
      if (state != null && _handleBoundary(node, state)) break;
      if (state?.isRendering == false && node is! dom.Element) continue;
      final wasRendering = state?.isRendering ?? true;
      final read = _readNode(node);
      final keep =
          wasRendering ||
          (state?.isRendering ?? false) ||
          (state?.isStopped ?? false);
      if (keep && read != null) result.add(read);
      if (state?.isStopped ?? false) break;
    }
    return result;
  }

  HtmlSourceNode? _readNode(dom.Node node) {
    if (node is dom.Text) return _readText(node);
    if (node is! dom.Element) return null;
    final tag = node.localName?.toLowerCase() ?? 'div';
    if (tag == 'table') return _readTable(node);
    if (tag == 'img') {
      return HtmlSourceNode._element(tag, _attributes(node), const []);
    }
    return HtmlSourceNode._element(
      tag,
      _attributes(node),
      readNodes(node.nodes),
    );
  }

  /// Reads a text node, or returns `null` when it is not content: empty, or
  /// whitespace only outside `<pre>` and not between two inline siblings.
  HtmlSourceNode? _readText(dom.Text node) {
    final preformatted = _isPreformatted(node);
    final text = preformatted
        ? node.text
        : node.text
              .split('\n')
              .map((line) => line.replaceAll(_spacesAndTabs, ' '))
              .join('\n');
    if (text.isEmpty) return null;
    if (text.trim().isEmpty && !preformatted && !_isBetweenInline(node)) {
      return null;
    }
    return HtmlSourceNode._text(text);
  }

  HtmlSourceNode _readTable(dom.Element table) {
    HtmlSourceNode? caption;
    for (final child in table.children) {
      if (child.localName?.toLowerCase() == 'caption') {
        caption = HtmlSourceNode._element(
          'caption',
          _attributes(child),
          readNodes(child.nodes),
        );
        break;
      }
    }

    final rows = <HtmlSourceNode>[];
    var columns = 0;
    for (final row in _tableRows(table)) {
      final cells = <HtmlSourceNode>[];
      var width = 0;
      for (final cell in row.children) {
        final tag = cell.localName?.toLowerCase();
        if (tag != 'td' && tag != 'th') continue;
        width += clampTableSpan(cell.attributes['colspan'], maxTableColSpan);
        cells.add(
          HtmlSourceNode._element(
            tag!,
            _attributes(cell),
            readNodes(cell.nodes),
          ),
        );
      }
      if (width > columns) columns = width;
      rows.add(HtmlSourceNode._element('tr', _attributes(row), cells));
    }

    return HtmlSourceNode._element(
      'table',
      _attributes(table),
      rows,
      caption: caption,
      rowCount: rows.length,
      columnCount: columns > maxTableColumns ? maxTableColumns : columns,
    );
  }

  /// The rows of [table]: those of its `thead` and `tbody` sections, or its
  /// direct `tr` children when it has no sections.
  static Iterable<dom.Element> _tableRows(dom.Element table) {
    bool isTag(dom.Element element, String tag) =>
        element.localName?.toLowerCase() == tag;
    final sections = table.children.where(
      (child) => isTag(child, 'thead') || isTag(child, 'tbody'),
    );
    if (sections.isEmpty) {
      return table.children.where((child) => isTag(child, 'tr'));
    }
    return sections.expand(
      (section) => section.children.where((child) => isTag(child, 'tr')),
    );
  }

  static Map<String, String> _attributes(dom.Element element) {
    final attributes = <String, String>{};
    for (final entry in element.attributes.entries) {
      final key = entry.key.toString();
      attributes[key] = switch (key) {
        'style' => _normalizeStyle(entry.value),
        'class' => _normalizeClasses(entry.value),
        _ => entry.value,
      };
    }
    return attributes;
  }

  static String _normalizeStyle(String style) {
    return style
        .split(';')
        .map((declaration) => declaration.trim())
        .where((declaration) => declaration.isNotEmpty)
        .map((declaration) {
          final parts = declaration.split(':').map((p) => p.trim()).toList();
          return parts.length == 2 ? '${parts[0]}: ${parts[1]}' : null;
        })
        .whereType<String>()
        .join('; ');
  }

  static String _normalizeClasses(String classes) {
    return classes
        .split(' ')
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty)
        .join(' ');
  }

  static bool _isPreformatted(dom.Node node) {
    for (var parent = node.parent; parent != null; parent = parent.parent) {
      if (parent.localName == 'pre') return true;
    }
    return false;
  }

  /// Whether whitespace-only [node] sits between two inline siblings, such
  /// as `<b>a</b> <i>b</i>`, where the HTML specification renders it as one
  /// space.
  static bool _isBetweenInline(dom.Text node) {
    final siblings = node.parent?.nodes;
    if (siblings == null) return false;
    final index = siblings.indexOf(node);
    return _isInlineSibling(siblings, index, -1) &&
        _isInlineSibling(siblings, index, 1);
  }

  static bool _isInlineSibling(dom.NodeList siblings, int index, int step) {
    for (var i = index + step; i >= 0 && i < siblings.length; i += step) {
      final sibling = siblings[i];
      if (sibling is dom.Comment) continue;
      if (sibling is dom.Text) return sibling.text.trim().isNotEmpty;
      if (sibling is dom.Element) {
        return _inlineElements.contains(sibling.localName?.toLowerCase());
      }
      return false;
    }
    return false;
  }

  bool _handleBoundary(dom.Node node, _RenderBoundaryState state) {
    final boundary = renderBoundary;
    if (boundary == null || node is! dom.Comment) return false;
    final data = node.data;
    if (data == null) return false;
    if (state.isRendering && boundary.matchesEndComment(data)) {
      state.stop();
      return true;
    }
    if (!state.isRendering && boundary.matchesStartComment(data)) {
      state.start();
    }
    return false;
  }
}

bool _hasStartBoundary(dom.NodeList nodes, TagflowRenderBoundary? boundary) {
  if (boundary?.start == null) return false;
  for (final node in nodes) {
    if (node is dom.Comment) {
      final data = node.data;
      if (data != null && boundary!.matchesStartComment(data)) return true;
    }
    if (node is dom.Element && _hasStartBoundary(node.nodes, boundary)) {
      return true;
    }
  }
  return false;
}

/// Elements that are inline-level by default, for whitespace handling.
const _inlineElements = {
  'a',
  'abbr',
  'b',
  'bdi',
  'bdo',
  'br',
  'cite',
  'code',
  'data',
  'del',
  'dfn',
  'em',
  'i',
  'img',
  'ins',
  'kbd',
  'label',
  'mark',
  'q',
  's',
  'samp',
  'small',
  'span',
  'strong',
  'sub',
  'sup',
  'time',
  'u',
  'var',
};

final class _RenderBoundaryState {
  _RenderBoundaryState(TagflowRenderBoundary boundary)
    : _isRendering = boundary.start == null;

  bool _isRendering;
  bool _isStopped = false;

  bool get isRendering => _isRendering && !_isStopped;
  bool get isStopped => _isStopped;

  void start() {
    if (!_isStopped) _isRendering = true;
  }

  void stop() {
    _isStopped = true;
    _isRendering = false;
  }

  void setHasStartBoundary({required bool hasStartBoundary}) {
    if (!hasStartBoundary && !_isStopped) _isRendering = true;
  }
}
