import 'package:html/dom.dart' as dom;
import 'package:tagflow/src/core/models/models.dart';

abstract class NodeParser<T extends TagflowNode> {
  const NodeParser();

  T? tryParse(dom.Node node);
  bool canHandle(dom.Node node);

  Map<String, String> parseAttributes(dom.Element element) {
    final attributes = <String, String>{};

    for (final attr in element.attributes.entries) {
      final key = attr.key.toString();
      final value = attr.value;
      if (key == 'style') {
        attributes[key] = _normalizeStyle(value);
      } else {
        attributes[key] = value;
      }
    }

    return attributes;
  }

  String normalizeWhitespace(String text) {
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

  List<TagflowNode> parseChildren(dom.Element element) {
    return element.nodes.map(tryParse).whereType<TagflowNode>().toList();
  }
}
