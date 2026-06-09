// ignore_for_file: cascade_invocations

import 'dart:collection';
import 'dart:developer' show log;

import 'package:html/dom.dart' as dom;
import 'package:html/dom_parsing.dart';
import 'package:html/parser.dart' as html;
import 'package:tagflow/tagflow.dart';

/// Parses HTML string into TagflowElement
class TagflowParser {
  const TagflowParser({
    List<NodeParser>? parsers,
    this.debug = false,
    this.renderBoundary,
  }) : _renderBoundaryState = null,
       _parsers =
           parsers ?? const [ElementParser(), TableParser(), ImgParser()];

  TagflowParser._run({
    required List<NodeParser> parsers,
    required this.debug,
    required this.renderBoundary,
  }) : _parsers = parsers,
       _renderBoundaryState = _RenderBoundaryState(renderBoundary);

  final List<NodeParser> _parsers;
  final bool debug;
  final TagflowRenderBoundary? renderBoundary;
  final _RenderBoundaryState? _renderBoundaryState;

  TagflowNode parse(String input) {
    final parser = TagflowParser._run(
      parsers: _parsers,
      debug: debug,
      renderBoundary: renderBoundary,
    );
    return parser._parse(input);
  }

  TagflowNode _parse(String input) {
    final document = html.parse(input);

    if (debug) {
      _Visitor().visit(document);
    }

    final body = document.body;

    if (body == null) {
      throw const FormatException('Invalid HTML: no body element found');
    }

    _renderBoundaryState?.setHasStartBoundary(
      hasStartBoundary: _hasStartBoundary(body.nodes),
    );

    final validNodes = parseNodes(body.nodes).where(isValidNode).toList();

    TagflowNode element;
    if (validNodes.length == 1) {
      element = validNodes.first;
    } else {
      element = TagflowElement(
        tag: 'div',
        attributes: LinkedHashMap.from({
          'style': 'display: flex; flex-direction: column; gap: 1rem;',
        }),
        children: validNodes,
      );
    }

    return element.reparent();
  }

  List<TagflowNode> parseNodes(dom.NodeList nodes) {
    const excludeTags = ['table'];
    bool isNodeValid(dom.Node node) {
      if (node is dom.Text) {
        return node.text.isNotEmpty ||
            excludeTags.contains(node.parent?.localName);
      }

      if (node is dom.Element) {
        if (excludeTags.contains(node.localName)) {
          return true;
        }
        return node.hasChildNodes() || node.nodes.every(isNodeValid);
      }

      return false;
    }

    final parsedNodes = <TagflowNode>[];
    for (final node in nodes) {
      final state = _renderBoundaryState;
      if (state != null && _handleRenderBoundary(node, state)) break;
      if (state?.isRendering == false && node is! dom.Element) continue;
      if (!isNodeValid(node)) continue;
      final wasRendering = state?.isRendering ?? true;
      final parsedNode = parseNode(node);
      final canAddNode =
          wasRendering ||
          (state?.isRendering ?? false) ||
          (state?.isStopped ?? false);
      if (canAddNode && parsedNode != null && isValidNode(parsedNode)) {
        parsedNodes.add(parsedNode);
      }
      if (state?.isStopped ?? false) break;
    }
    return parsedNodes;
  }

  TagflowNode? parseNode(dom.Node node) {
    for (final parser in _parsers) {
      if (parser.canHandle(node)) {
        return parser.tryParse(node, this);
      }
    }
    return null;
  }

  bool isValidNode(TagflowNode node) {
    const excludeTags = ['table'];
    if (node.isEmpty) return false;
    if (node.isTextNode && !excludeTags.contains(node.tag)) {
      return node.textContent?.trim().isNotEmpty ?? false;
    }

    // except for table cells, empty nodes are valid
    if (excludeTags.contains(node.tag)) {
      return true;
    }

    return node.hasChildren || node.children.every(isValidNode);
  }

  bool _handleRenderBoundary(dom.Node node, _RenderBoundaryState state) {
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

  bool _hasStartBoundary(dom.NodeList nodes) {
    final boundary = renderBoundary;
    if (boundary?.start == null) return false;
    for (final node in nodes) {
      if (node is dom.Comment) {
        final data = node.data;
        if (data != null && boundary!.matchesStartComment(data)) return true;
      }
      if (node is dom.Element && _hasStartBoundary(node.nodes)) return true;
    }
    return false;
  }
}

class _RenderBoundaryState {
  _RenderBoundaryState(TagflowRenderBoundary? boundary)
    : _isRendering = boundary?.start == null;

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

class _Visitor extends TreeVisitor {
  String indent = '';

  @override
  void visitText(dom.Text node) {
    if (node.data.trim().isNotEmpty) {
      log('$indent${node.data.trim()}');
    }
  }

  @override
  void visitElement(dom.Element node) {
    if (isVoidElement(node.localName)) {
      log('$indent<${node.localName}/>');
    } else {
      log('$indent<${node.localName}>');
      indent += '  ';
      visitChildren(node);
      indent = indent.substring(0, indent.length - 2);
      log('$indent</${node.localName}>');
    }
  }

  @override
  void visitChildren(dom.Node node) {
    for (final child in node.nodes) {
      visit(child);
    }
  }
}
