import 'package:flutter/widgets.dart';
import 'package:tagflow/tagflow.dart';

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

extension StyleExtension on TagflowStyle {
  bool get hasBorder =>
      border != null ||
      borderLeft != null ||
      borderRight != null ||
      borderTop != null ||
      borderBottom != null;

  Border? get effectiveBorder => hasBorder
      ? border ??
          Border(
            left: borderLeft ?? BorderSide.none,
            right: borderRight ?? BorderSide.none,
            top: borderTop ?? BorderSide.none,
            bottom: borderBottom ?? BorderSide.none,
          )
      : null;

  bool get hasBoxDecoration =>
      backgroundColor != null ||
      borderRadius != null ||
      effectiveBorder != null ||
      boxShadow != null;

  BoxDecoration? toBoxDecoration() => hasBoxDecoration
      ? BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius,
          border: effectiveBorder,
          boxShadow: boxShadow,
        )
      : null;

  TextStyle? get textStyleWithColor =>
      textStyle == null && (color != null || backgroundColor != null)
          ? TextStyle(color: color)
          : textStyle?.copyWith(color: color);
}

/// Position-related extensions for TagflowNode
extension TagflowNodePosition on TagflowNode {
  /// Returns true if this node is the first child of its parent
  bool get isFirstChild {
    final parent = this.parent;
    if (parent == null) return false;
    return parent.children.firstOrNull == this;
  }

  /// Returns true if this node is the last child of its parent
  bool get isLastChild {
    final parent = this.parent;
    if (parent == null) return false;
    return parent.children.lastOrNull == this;
  }
}
