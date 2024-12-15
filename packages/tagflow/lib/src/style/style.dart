import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

/// Represents a set of styles for an element
class TagflowStyle extends Equatable {
  /// Create a new style
  const TagflowStyle({
    this.textStyle,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.decoration,
    this.alignment,
    this.transform,
    this.textAlign,
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

  /// Transform matrix
  final Matrix4? transform;

  /// Text alignment
  final TextAlign? textAlign;

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
    Matrix4? transform,
    Map<String, ElementStyle>? elementStyles,
    ElementStyle? defaultElementStyle,
    TextAlign? textAlign,
  }) {
    return TagflowStyle(
      textStyle: textStyle ?? this.textStyle,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      decoration: decoration ?? this.decoration,
      alignment: alignment ?? this.alignment,
      transform: transform ?? this.transform,
      elementStyles: elementStyles ?? this.elementStyles,
      defaultElementStyle: defaultElementStyle ?? this.defaultElementStyle,
      textAlign: textAlign ?? this.textAlign,
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
      transform: other.transform ?? transform,
      elementStyles: {
        ...elementStyles,
        for (final entry in other.elementStyles.entries)
          entry.key:
              elementStyles[entry.key]?.merge(entry.value) ?? entry.value,
      },
      defaultElementStyle:
          other.defaultElementStyle?.merge(defaultElementStyle) ??
              defaultElementStyle,
      textAlign: other.textAlign ?? textAlign,
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

  @override
  List<Object?> get props => [
        textStyle,
        padding,
        margin,
        backgroundColor,
        decoration,
        alignment,
        transform,
        elementStyles,
        defaultElementStyle,
        textAlign,
      ];
}

/// Style configuration for a specific HTML element
class ElementStyle extends Equatable {
  /// Create a new element style
  const ElementStyle({
    this.textStyle,
    this.padding,
    this.margin,
    this.decoration,
    this.alignment,
    this.transform,
    this.textAlign,
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

  /// Transform matrix (e.g. for superscripts and subscripts)
  final Matrix4? transform;

  /// Text alignment
  final TextAlign? textAlign;

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
      transform: other.transform ?? transform,
      textAlign: other.textAlign ?? textAlign,
    );
  }

  /// Create a new element style with specific overrides
  ElementStyle copyWith({
    TextStyle? textStyle,
    EdgeInsets? padding,
    EdgeInsets? margin,
    BoxDecoration? decoration,
    Alignment? alignment,
    Matrix4? transform,
    TextAlign? textAlign,
  }) {
    return ElementStyle(
      textStyle: textStyle ?? this.textStyle,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      decoration: decoration ?? this.decoration,
      alignment: alignment ?? this.alignment,
      transform: transform ?? this.transform,
      textAlign: textAlign ?? this.textAlign,
    );
  }

  @override
  List<Object?> get props => [
        textStyle,
        padding,
        margin,
        decoration,
        alignment,
        transform,
        textAlign,
      ];
}
