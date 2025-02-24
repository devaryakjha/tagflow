import 'package:html/dom.dart' as dom;
import 'package:tagflow/tagflow.dart';

class ElementParser extends NodeParser<TagflowElement> {
  const ElementParser();

  @override
  bool canHandle(dom.Node node) {
    if (node is dom.Text) return true;
    if (node is! dom.Element) return false;

    final tag = node.localName?.toLowerCase();
    // Exclude tags handled by specialized parsers
    return tag != 'table' && tag != 'img';
  }

  @override
  TagflowElement? tryParse(dom.Node node, TagflowParser parser) {
    if (node is dom.Text) {
      final text = normalizeWhitespace(node.text);
      return text.isEmpty ? TagflowElement.empty() : TagflowElement.text(text);
    }

    if (node is dom.Element) {
      return TagflowElement(
        tag: node.localName?.toLowerCase() ?? 'div',
        attributes: parseAttributes(node),
        children: parseChildren(node, parser),
      );
    }

    return null;
  }
}
