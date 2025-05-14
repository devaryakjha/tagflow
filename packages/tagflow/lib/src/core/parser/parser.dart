// ignore_for_file: cascade_invocations

import 'dart:collection';
import 'dart:developer' show log;

import 'package:html/dom.dart' as dom;
import 'package:html/dom_parsing.dart';
import 'package:html/parser.dart' as html;
import 'package:tagflow/tagflow.dart';

/// Parses HTML string into TagflowElement
class TagflowParser {
  const TagflowParser({List<NodeParser>? parsers, this.debug = false})
    : _parsers = parsers ?? const [ElementParser(), TableParser(), ImgParser()];

  final List<NodeParser> _parsers;
  final bool debug;

  TagflowNode parse(String input) {
    final document = html.parse(input);

    if (debug) {
      _Visitor().visit(document);
    }

    final body = document.body;

    if (body == null) {
      throw const FormatException('Invalid HTML: no body element found');
    }

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

    return nodes.where(isNodeValid).map(parseNode).nonNulls.toList();
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
