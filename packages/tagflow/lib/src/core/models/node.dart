import 'dart:collection';

abstract class TagflowNode {
  TagflowNode({
    required this.tag,
    this.children = const [],
    this.textContent,
    this.parent,
    this.attributes,
  });

  /// The HTML tag name
  final String tag;

  /// Parent node
  TagflowNode? parent;

  /// Children nodes
  final List<TagflowNode> children;

  /// Element's attributes
  final LinkedHashMap<String, String>? attributes;

  /// Element's text content
  final String? textContent;

  /// Whether this node represents a text node
  bool get isTextNode => tag == '#text' && textContent != null;

  /// Whether this node is an empty node
  bool get isEmpty => tag == '#empty';

  /// The tag name of the parent element
  String get parentTag => parent?.tag ?? '';

  /// Get an attribute value
  String? operator [](String key);

  /// Set an attribute value
  void operator []=(String key, String value);

  /// Get the style attribute
  String? get style => this['style'];

  /// Get the class attribute
  String? get className => this['class'];

  /// Get the list of classes
  List<String> get classList =>
      (className?.split(' ') ?? const []).where((s) => s.isNotEmpty).toList();

  /// Set the class attribute
  set classList(List<String> value) {
    this['class'] = value.join(' ');
  }

  void reparent([TagflowNode? newParent]);

  bool hasAttribute(String attribute) =>
      attributes?.containsKey(attribute) ?? false;
}
