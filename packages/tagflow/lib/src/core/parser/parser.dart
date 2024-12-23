import 'dart:collection';

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

    // Filter out empty nodes and normalize whitespace
    final validNodes = body.nodes
        .where((n) => n is dom.Element || (n is dom.Text && n.text.isNotEmpty))
        .map(_convertNode)
        .where(_isValidNode)
        .toList();

    // If there's exactly one valid node, return it directly
    if (validNodes.length == 1) {
      return validNodes.first;
    }

    // Otherwise wrap all nodes in a container
    return TagflowElement(
      tag: 'div',
      attributes: LinkedHashMap.from({
        'style': 'display: flex; flex-direction: column; gap: 1rem;',
      }),
      children: validNodes,
    )..reparent();
  }

  bool _isValidNode(TagflowElement element) {
    if (element.isEmpty) return false;
    if (element.isTextNode) {
      return element.textContent?.trim().isNotEmpty ?? false;
    }
    return true;
  }

  /// Converts DOM node to TagflowElement
  TagflowElement _convertNode(dom.Node node) {
    // Handle text nodes
    if (node is dom.Text) {
      final text = _normalizeWhitespace(node.text);
      return text.isEmpty ? TagflowElement.empty() : TagflowElement.text(text);
    }

    // Handle element nodes
    if (node is dom.Element) {
      final tag = node.localName?.toLowerCase() ?? 'div';

      // Convert attributes with proper type handling
      final attributes = LinkedHashMap<String, String>.fromEntries(
        node.attributes.entries.map((e) => MapEntry(e.key.toString(), e.value)),
      );
      _processAttributes(attributes, node);

      // Convert child nodes and filter out empty ones
      final children =
          node.nodes.map(_convertNode).where(_isValidNode).toList();

      return TagflowElement(
        tag: tag,
        children: children,
        attributes: attributes,
      );
    }

    return TagflowElement.empty();
  }

  /// Process and normalize attributes
  void _processAttributes(
    LinkedHashMap<String, String> attributes,
    dom.Element node,
  ) {
    // Handle style attribute
    if (attributes.containsKey('style')) {
      attributes['style'] = _normalizeStyle(attributes['style']!);
    }

    // Handle class attribute
    if (attributes.containsKey('class')) {
      attributes['class'] = _normalizeClasses(attributes['class']!);
    }

    // Handle data attributes
    attributes.addEntries(
      node.attributes.entries
          .where((e) => e.key.toString().startsWith('data-'))
          .map((e) => MapEntry(e.key.toString(), e.value)),
    );
  }

  /// Normalize whitespace in text content
  String _normalizeWhitespace(String text) {
    // Collapse spaces/tabs within each line
    String replaceSpaces(String lines) {
      return lines.replaceAll(RegExp(r'[ \t]+'), ' ');
    }

    // Preserve newlines but collapse multiple spaces between words
    return text
        .split('\n') // Split on newlines to preserve them
        .map(replaceSpaces)
        .join('\n'); // Rejoin with newlines
  }

  /// Normalize style declarations
  String _normalizeStyle(String style) {
    return style
        .split(';')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .map((s) {
          final parts = s.split(':').map((p) => p.trim()).toList();
          return parts.length == 2 ? '${parts[0]}: ${parts[1]}' : null;
        })
        .where((s) => s != null)
        .join('; ');
  }

  /// Normalize class names
  String _normalizeClasses(String classes) {
    return classes
        .split(' ')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .join(' ');
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
