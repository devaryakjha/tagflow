import 'dart:collection';

import 'package:tagflow/tagflow.dart';

/// Represents an HTML element in the tagflow tree.
class TagflowElement extends TagflowNode {
  /// Creates a new [TagflowElement] instance.
  const TagflowElement({
    required super.tag,
    super.textContent,
    List<TagflowNode>? children,
    Map<String, String>? attributes,
    super.parent,
  })  : _children = children ?? const [],
        _attributes = attributes ?? const {};

  /// Factory constructor for text nodes
  factory TagflowElement.text(String content) {
    return TagflowElement(
      tag: '#text',
      textContent: content,
    );
  }

  /// Factory constructor for empty elements
  factory TagflowElement.empty() => const TagflowElement(tag: '#empty');

  /// Element's attributes
  final Map<String, String> _attributes;

  /// Internal children list
  final List<TagflowNode> _children;

  /// Child elements (unmodifiable view)
  @override
  List<TagflowNode> get children => List.unmodifiable(_children);

  /// Set child elements
  @override
  set children(List<TagflowNode> value) {
    _children
      ..clear()
      ..addAll(value);
  }

  @override
  LinkedHashMap<String, String>? get attributes =>
      LinkedHashMap.from(_attributes);

  @override
  String? operator [](String key) => _attributes[key];

  /// Set an attribute value
  @override
  void operator []=(String key, String value) {
    _attributes[key] = value;
  }

  @override
  TagflowNode reparent([TagflowNode? newParent]) {
    return TagflowElement(
      tag: tag,
      textContent: textContent,
      children: children.map((e) => e.reparent(this)).toList(),
      parent: newParent,
      attributes: attributes,
    );
  }

  @override
  List<Object?> get props => [tag, textContent, children, attributes];
}
