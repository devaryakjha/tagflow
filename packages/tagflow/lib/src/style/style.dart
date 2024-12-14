// lib/src/style/style.dart
import 'package:flutter/widgets.dart';

/// Represents a set of styles for an element
class TagflowStyle {
  /// Create a new style
  const TagflowStyle({
    this.textStyle,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.decoration,
    this.alignment,
    this.elementStyles = const {},
    this.defaultElementStyle,
  });

  /// Base text style
  final TextStyle? textStyle;

  /// Padding
  final EdgeInsets? padding;

  /// Margin
  final EdgeInsets? margin;

  /// Background color
  final Color? backgroundColor;

  /// Decoration
  final BoxDecoration? decoration;

  /// Alignment
  final Alignment? alignment;

  /// Style applied to all elements (like CSS *)
  final ElementStyle? defaultElementStyle;

  /// Styles for specific HTML elements
  /// Keys are HTML element names (e.g., 'p', 'h1', 'strong', 'em')
  final Map<String, ElementStyle> elementStyles;

  /// Create a copy of this style with specific overrides
  TagflowStyle copyWith({
    TextStyle? textStyle,
    EdgeInsets? padding,
    EdgeInsets? margin,
    Color? backgroundColor,
    BoxDecoration? decoration,
    Alignment? alignment,
    Map<String, ElementStyle>? elementStyles,
    ElementStyle? defaultElementStyle,
  }) {
    return TagflowStyle(
      textStyle: textStyle ?? this.textStyle,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      decoration: decoration ?? this.decoration,
      alignment: alignment ?? this.alignment,
      elementStyles: elementStyles ?? this.elementStyles,
      defaultElementStyle: defaultElementStyle ?? this.defaultElementStyle,
    );
  }

  /// Merge two styles, with other taking precedence
  TagflowStyle merge(TagflowStyle? other) {
    if (other == null) return this;

    return TagflowStyle(
      textStyle:
          textStyle?.merge(other.textStyle) ?? other.textStyle ?? textStyle,
      padding: other.padding ?? padding,
      margin: other.margin ?? margin,
      backgroundColor: other.backgroundColor ?? backgroundColor,
      decoration: other.decoration ?? decoration,
      alignment: other.alignment ?? alignment,
      elementStyles: {
        ...elementStyles,
        for (final entry in other.elementStyles.entries)
          entry.key:
              elementStyles[entry.key]?.merge(entry.value) ?? entry.value,
      },
      defaultElementStyle:
          other.defaultElementStyle?.merge(defaultElementStyle) ??
              defaultElementStyle,
    );
  }

  /// Get style for a specific HTML element
  ElementStyle? getElementStyle(String tag) {
    final resolvedTag = tag.toLowerCase();

    if (resolvedTag == '#text') {
      return null;
    }

    // Start with default style if exists
    final baseStyle = defaultElementStyle;

    // Get tag-specific style
    final tagStyle = elementStyles[resolvedTag];

    // If we have both, merge them, otherwise return whichever exists
    if (baseStyle != null && tagStyle != null) {
      return baseStyle.merge(tagStyle);
    }

    return tagStyle ?? baseStyle;
  }
}

/// Style configuration for a specific HTML element
class ElementStyle {
  /// Create a new element style
  const ElementStyle({
    this.textStyle,
    this.padding,
    this.margin,
    this.decoration,
    this.alignment,
  });

  /// Text style
  final TextStyle? textStyle;

  /// element's padding
  final EdgeInsets? padding;

  /// element's margin
  final EdgeInsets? margin;

  /// element's decoration
  final BoxDecoration? decoration;

  /// element's alignment
  final Alignment? alignment;

  /// Merge two element styles
  ElementStyle merge(ElementStyle? other) {
    if (other == null) return this;
    return ElementStyle(
      textStyle:
          textStyle?.merge(other.textStyle) ?? other.textStyle ?? textStyle,
      padding: other.padding ?? padding,
      margin: other.margin ?? margin,
      decoration: other.decoration ?? decoration,
      alignment: other.alignment ?? alignment,
    );
  }

  /// Create a new element style with specific overrides
  ElementStyle copyWith({
    TextStyle? textStyle,
    EdgeInsets? padding,
    EdgeInsets? margin,
    BoxDecoration? decoration,
    Alignment? alignment,
  }) {
    return ElementStyle(
      textStyle: textStyle ?? this.textStyle,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      decoration: decoration ?? this.decoration,
      alignment: alignment ?? this.alignment,
    );
  }
}
