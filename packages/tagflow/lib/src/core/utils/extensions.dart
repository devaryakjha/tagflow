import 'package:flutter/rendering.dart';
import 'package:tagflow/tagflow.dart';

extension TagflowNodeExtensions on TagflowNode {
  bool hasAttribute(String attribute) =>
      attributes?.containsKey(attribute) ?? false;
}

/// Style-related extensions for TagflowNode
extension TagflowNodeStyle on TagflowNode {
  /// Returns the inline style string
  String? get style => attributes?['style'];

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
      attributes?['class']
          ?.split(' ')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList() ??
      const [];

  /// Returns the class attribute value
  String get className => attributes?['class'] ?? '';

  /// Sets the class attribute value
  set className(String value) => attributes?['class'] = value;

  /// Sets class names from a list
  set classList(List<String> value) => attributes?['class'] = value.join(' ');
}

/// Media-related extensions for TagflowNode
extension TagflowNodeMedia on TagflowNode {
  /// Returns true if this is an image element
  bool get isImage => tag == 'img';

  /// Returns the src attribute for media elements
  String? get src => attributes?['src'];

  /// Returns the alt text for media elements
  String? get alt => attributes?['alt'];

  /// Returns the object-fit style as BoxFit
  BoxFit? get fit => styles?['object-fit'] != null
      ? StyleParser.parseBoxFit(styles!['object-fit']!)
      : null;
}

/// Link-related extensions for TagflowNode
extension TagflowNodeLink on TagflowNode {
  /// Returns true if this is an anchor element
  bool get isAnchor => tag == 'a';

  /// Returns the href attribute
  String? get href => attributes?['href'];

  /// Returns the target attribute
  String? get target => attributes?['target'];

  /// Returns the parent's href if it exists
  String? get parentHref => parent?.href;
}

/// Size-related extensions for TagflowNode
extension TagflowNodeSize on TagflowNode {
  /// Returns the width as a double
  double? get width {
    final value = attributes?['width'] ?? styles?['width'];
    return value != null ? StyleParser.parseSize(value) : null;
  }

  /// Returns the height as a double
  double? get height {
    final value = attributes?['height'] ?? styles?['height'];
    return value != null ? StyleParser.parseSize(value) : null;
  }

  /// Returns the gap between flex items
  double? get gap {
    final value = styles?['gap'];
    return value != null ? StyleParser.parseSize(value) : null;
  }
}
