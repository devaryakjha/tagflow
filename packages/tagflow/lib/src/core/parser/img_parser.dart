import 'package:html/dom.dart' as dom;
import 'package:tagflow/legacy.dart';

/// Parses `img` elements.
class ImgParser extends NodeParser<TagflowImgElement> {
  /// Creates an image parser.
  const ImgParser();

  @override
  bool canHandle(dom.Node node) {
    if (node is! dom.Element) return false;
    return node.localName?.toLowerCase() == 'img';
  }

  @override
  TagflowImgElement? tryParse(dom.Node node, TagflowParser parser) {
    if (node is! dom.Element) return null;

    return TagflowImgElement(
      attributes: parseAttributes(node),
      // src: node.attributes['src'] ?? '',
      // alt: node.attributes['alt'] ?? '',
    );
  }
}
