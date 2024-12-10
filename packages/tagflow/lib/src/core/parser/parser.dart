import 'package:flutter/foundation.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/dom.dart';
import 'package:html/dom_parsing.dart';
import 'package:html/parser.dart' as html;
import 'package:tagflow/src/core/models/element.dart';

/// Parses HTML string into TagflowElement
class TagflowParser {
  /// Parses HTML string into TagflowElement
  TagflowElement parse(String htmlString) {
    final document = html.parse(htmlString);

    if (kDebugMode) {
      _Visitor().visit(document);
    }

    final body = document.body;

    if (body == null) {
      throw const FormatException('Invalid HTML: no body element found');
    }

    // Filter out empty nodes

    final validNodes = body.nodes
        .map(_convertNode)
        .where((element) => element.tag != '#empty')
        .toList();

    // If there's exactly one valid node, return it directly
    if (validNodes.length == 1) {
      return validNodes.first;
    }

    // Otherwise wrap all nodes in a div
    return TagflowElement(
      tag: 'div',
      children: validNodes,
    );
  }

  /// Converts DOM node to TagflowElement
  TagflowElement _convertNode(dom.Node node) {
    final attributes = node.attributes;
    // Handle text nodes
    if (node is dom.Text) {
      final text = node.text;
      return text.isEmpty || text.trim().isEmpty
          ? TagflowElement.empty()
          : TagflowElement.text(text);
    }

    // Handle element nodes
    if (node is dom.Element) {
      final tag = node.localName?.toLowerCase() ?? 'div';

      // Convert child nodes and filter out empty ones
      final children = node.nodes
          .map(_convertNode)
          .where((element) => element.tag != '#empty')
          .toList();

      return TagflowElement(
        tag: tag,
        children: children,
        attributes: attributes,
      );
    }

    // Handle unknown nodes
    return TagflowElement.empty();
  }
}

class _Visitor extends TreeVisitor {
  String indent = '';

  void log(String message) {
    if (kDebugMode) print(message);
  }

  @override
  void visitText(Text node) {
    if (node.data.trim().isNotEmpty) {
      log('$indent${node.data.trim()}');
    }
  }

  @override
  void visitElement(Element node) {
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
  void visitChildren(Node node) {
    for (final child in node.nodes) {
      visit(child);
    }
  }
}
