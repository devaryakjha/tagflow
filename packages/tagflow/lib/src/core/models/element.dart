import 'dart:collection';

/// Represents an HTML element in the tagflow tree.
class TagflowElement {
  /// Creates a new [TagflowElement] instance.
  TagflowElement({
    required this.tag,
    this.textContent,
    this.children = const [],
    LinkedHashMap<Object, String>? attributes,
  }) : _attributes = attributes ?? LinkedHashMap.identity();

  /// Factory constructor for text nodes
  factory TagflowElement.text(String content) {
    return TagflowElement(
      tag: '#text',
      textContent: content,
    );
  }

  /// Factory constructor for empty elements
  factory TagflowElement.empty() => TagflowElement(tag: '#empty');

  /// The HTML tag name (e.g., 'div', 'p', 'h1')
  final String tag;

  /// Element's text content
  final String? textContent;

  // Element's attributes
  final LinkedHashMap<Object, String> _attributes;

  /// Returns the value of the attribute with the given name.
  String? operator [](String name) => _attributes[name];

  /// Returns the value of the attribute with the given name.
  String? get(String name) => _attributes[name];

  /// Returns true if the element has the given attribute.
  bool hasAttribute(String name) => _attributes.containsKey(name);

  /// Return class attribute value
  String get className => _attributes['class'] ?? '';

  /// Returns the list of class names
  List<String> get classList => className.split(' ');

  /// Sets the class attribute value
  set className(String value) => _attributes['class'] = value;

  /// Sets the class attribute value
  set classList(List<String> value) {
    _attributes['class'] = value.join(' ');
  }

  /// Child elements
  final List<TagflowElement> children;

  /// Whether this element represents a text node
  bool get isTextNode => tag == '#text' && textContent != null;

  /// Whether this element is an empty element
  bool get isEmpty => tag == '#empty';

  @override
  String toString() {
    return 'TagflowElement{tag: $tag, textContent: $textContent,'
        ' children: $children'
        ' attributes: $_attributes}';
  }
}
