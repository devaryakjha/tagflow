import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tagflow/tagflow.dart';

/// Represents an HTML element in the tagflow tree.
class TagflowElement {
  /// Creates a new [TagflowElement] instance.
  TagflowElement({
    required this.tag,
    this.textContent,
    this.children = const [],
    LinkedHashMap<String, String>? attributes,
    this.parent,
  }) : _attributes = attributes ?? LinkedHashMap.from({});

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

  /// Parent element
  TagflowElement? parent;

  /// Element's text content
  final String? textContent;

  /// Element's attributes
  final LinkedHashMap<String, String> _attributes;

  /// Child elements
  final List<TagflowElement> children;

  /// Returns the value of the attribute with the given name
  String? operator [](String name) => _attributes[name];

  /// Returns true if the element has the given attribute
  bool hasAttribute(String name) => _attributes.containsKey(name);

  /// Returns all attributes as an immutable map
  Map<String, String> get attributes => Map.unmodifiable(_attributes);

  /// Whether this element represents a text node
  bool get isTextNode => tag == '#text' && textContent != null;

  /// Whether this element represents a break element
  bool get isBreak => tag == 'br';

  /// Whether this element is an empty element
  bool get isEmpty => tag == '#empty';

  /// The tag name of the parent element
  String get parentTag => parent?.tag ?? '';

  /// Adds multiple child elements
  void addAllChildren(Iterable<TagflowElement> children) {
    for (final child in children) {
      addChild(child);
    }
  }

  /// Adds a child element and sets its parent
  void addChild(TagflowElement child) {
    children.add(child);
    child.parent = this;
  }

  /// Sets the parent element and updates all children
  void reparent([TagflowElement? newParent]) {
    parent = newParent;
    for (final child in children) {
      child.reparent(this);
    }
  }

  @override
  String toString() {
    return 'TagflowElement{tag: $tag, textContent: $textContent, '
        'attributes: $_attributes, children: $children}';
  }
}

/// Style-related extensions for TagflowElement
extension TagflowElementStyle on TagflowElement {
  /// Returns the inline style string
  String? get style => _attributes['style'];

  /// Returns parsed inline styles
  Map<String, String>? get styles {
    final styleStr = style;
    if (styleStr == null || styleStr.isEmpty) return null;

    return Map.fromEntries(
      styleStr.split(';').map((declaration) {
        final parts = declaration.split(':').map((s) => s.trim()).toList();
        return parts.length == 2 ? MapEntry(parts[0], parts[1]) : null;
      }).whereType<MapEntry<String, String>>(),
    );
  }

  /// Returns class names as a list
  List<String> get classList =>
      _attributes['class']
          ?.split(' ')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList() ??
      const [];

  /// Returns the class attribute value
  String get className => _attributes['class'] ?? '';

  /// Sets the class attribute value
  set className(String value) => _attributes['class'] = value;

  /// Sets class names from a list
  set classList(List<String> value) => _attributes['class'] = value.join(' ');
}

/// Media-related extensions for TagflowElement
extension TagflowElementMedia on TagflowElement {
  /// Returns true if this is an image element
  bool get isImage => tag == 'img';

  /// Returns the src attribute for media elements
  String? get src => _attributes['src'];

  /// Returns the alt text for media elements
  String? get alt => _attributes['alt'];

  /// Returns the object-fit style as BoxFit
  BoxFit? get fit => styles?['object-fit'] != null
      ? StyleParser.parseBoxFit(styles!['object-fit']!)
      : null;
}

/// Link-related extensions for TagflowElement
extension TagflowElementLink on TagflowElement {
  /// Returns true if this is an anchor element
  bool get isAnchor => tag == 'a';

  /// Returns the href attribute
  String? get href => _attributes['href'];

  /// Returns the target attribute
  String? get target => _attributes['target'];

  /// Returns the parent's href if it exists
  String? get parentHref => parent?.href;
}

/// Size-related extensions for TagflowElement
extension TagflowElementSize on TagflowElement {
  /// Returns the width as a double
  double? get width {
    final value = _attributes['width'] ?? styles?['width'];
    return value != null ? StyleParser.parseSize(value) : null;
  }

  /// Returns the height as a double
  double? get height {
    final value = _attributes['height'] ?? styles?['height'];
    return value != null ? StyleParser.parseSize(value) : null;
  }

  /// Returns the gap between flex items
  double? get gap {
    final value = styles?['gap'];
    return value != null ? StyleParser.parseSize(value) : null;
  }
}
