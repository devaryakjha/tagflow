import 'dart:collection';

import 'package:tagflow/tagflow.dart';

/// Represents an HTML element in the tagflow tree.
class TagflowElement extends TagflowNode {
  /// Creates a new [TagflowElement] instance.
  TagflowElement({
    required super.tag,
    super.textContent,
    List<TagflowNode>? children,
    LinkedHashMap<String, String>? attributes,
    super.parent,
  })  : _children = children ?? [],
        _attributes = attributes ?? {};

  /// Factory constructor for text nodes
  factory TagflowElement.text(String content) {
    return TagflowElement(
      tag: '#text',
      textContent: content,
    );
  }

  /// Factory constructor for empty elements
  factory TagflowElement.empty() => TagflowElement(tag: '#empty');

  /// Element's attributes
  final Map<String, String> _attributes;

  /// Internal children list
  final List<TagflowNode> _children;

  /// Child elements (unmodifiable view)
  @override
  List<TagflowNode> get children => List.unmodifiable(_children);

  @override
  LinkedHashMap<String, String>? get attributes =>
      LinkedHashMap.from(_attributes);

  /// Add a child element
  void addChild(TagflowNode child) {
    children.add(child);
    child.parent = this;
  }

  @override
  String? operator [](String key) => _attributes[key];

  /// Set an attribute value
  @override
  void operator []=(String key, String value) {
    _attributes[key] = value;
  }

  @override
  void reparent([TagflowNode? newParent]) {
    parent = newParent;
    for (final child in children) {
      child.reparent(this);
    }
  }
}
