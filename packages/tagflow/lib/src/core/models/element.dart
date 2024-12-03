/// Represents an HTML element in the tagflow tree.
class TagflowElement {
  /// Creates a new [TagflowElement] instance.
  const TagflowElement({
    required this.tag,
    this.textContent,
    this.children = const [],
  });

  /// Factory constructor for text nodes
  factory TagflowElement.text(String content) {
    return TagflowElement(
      tag: '#text',
      textContent: content,
    );
  }

  /// The HTML tag name (e.g., 'div', 'p', 'h1')
  final String tag;

  /// Element's text content
  final String? textContent;

  /// Child elements
  final List<TagflowElement> children;

  /// Whether this element represents a text node
  bool get isTextNode => tag == '#text' && textContent != null;

  @override
  String toString() {
    if (isTextNode) {
      return 'TagflowElement(text: $textContent)';
    }
    return 'TagflowElement(tag: $tag,'
        ' children: $children)';
  }
}
