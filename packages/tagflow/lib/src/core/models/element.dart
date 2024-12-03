import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:tagflow/src/core/models/attributes.dart';

/// Represents a parsed HTML element in the Tagflow system
@immutable
final class TagflowElement {
  /// Creates a new [TagflowElement]
  const TagflowElement({
    required this.tag,
    this.children = const [],
    this.attributes = const TagflowAttributes(),
    this.textContent,
    this.isSelfClosing = false,
  });

  /// Creates a text node
  factory TagflowElement.text(String content) {
    return TagflowElement(
      tag: '#text',
      textContent: content,
    );
  }

  /// The HTML tag name (e.g., 'div', 'p', 'span')
  final String tag;

  /// Child elements
  final List<TagflowElement> children;

  /// Attributes of the element
  final TagflowAttributes attributes;

  /// Text content (if any)
  final String? textContent;

  /// Whether this is a self-closing tag (e.g., <img>, <br>)
  final bool isSelfClosing;

  /// Whether this element represents text content
  bool get isTextNode => tag == '#text' && textContent != null;

  /// Whether this element is a block-level element
  bool get isBlockElement {
    const blockElements = {
      'div',
      'p',
      'h1',
      'h2',
      'h3',
      'h4',
      'h5',
      'h6',
      'section',
      'article',
      'aside',
      'nav',
      'header',
      'footer',
    };
    return blockElements.contains(tag.toLowerCase());
  }

  /// Finds the first child matching the given predicate
  TagflowElement? findChild(bool Function(TagflowElement) predicate) {
    if (predicate(this)) return this;
    for (final child in children) {
      final result = child.findChild(predicate);
      if (result != null) return result;
    }
    return null;
  }

  /// Creates a copy of this element with optional modifications
  TagflowElement copyWith({
    String? tag,
    TagflowAttributes? attributes,
    List<TagflowElement>? children,
    String? textContent,
    bool? isSelfClosing,
  }) {
    return TagflowElement(
      tag: tag ?? this.tag,
      attributes: attributes ?? this.attributes,
      children: children ?? this.children,
      textContent: textContent ?? this.textContent,
      isSelfClosing: isSelfClosing ?? this.isSelfClosing,
    );
  }

  /// Returns all descendants that match the given predicate
  List<TagflowElement> findAll(bool Function(TagflowElement) predicate) {
    final results = <TagflowElement>[];
    void traverse(TagflowElement element) {
      if (predicate(element)) results.add(element);
      for (final child in element.children) {
        traverse(child);
      }
    }

    traverse(this);
    return results;
  }

  /// Walks the element tree and applies a transformation
  TagflowElement transform(
    TagflowElement Function(TagflowElement) transformer,
  ) {
    final transformed = transformer(this);
    if (transformed.children.isEmpty) return transformed;

    return transformed.copyWith(
      children: transformed.children
          .map((child) => child.transform(transformer))
          .toList(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TagflowElement &&
          tag == other.tag &&
          attributes == other.attributes &&
          const ListEquality<TagflowElement>()
              .equals(children, other.children) &&
          textContent == other.textContent &&
          isSelfClosing == other.isSelfClosing;

  @override
  int get hashCode =>
      tag.hashCode ^
      attributes.hashCode ^
      const ListEquality<TagflowElement>().hash(children) ^
      textContent.hashCode ^
      isSelfClosing.hashCode;
}
