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
    this.display = Display.block,
    this.flexDirection,
    this.justifyContent,
    this.alignItems,
    this.flexWrap,
    this.gap,
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

  /// Display type (block, flex, etc.)
  final Display display;

  /// Flex direction (for flex containers)
  final Axis? flexDirection;

  /// Main axis alignment (for flex containers)
  final MainAxisAlignment? justifyContent;

  /// Cross axis alignment (for flex containers)
  final CrossAxisAlignment? alignItems;

  /// Flex wrap behavior
  final Wrap? flexWrap;

  /// Gap between flex items
  final double? gap;

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
      textAlign: other.textAlign ?? textAlign,
      display: other.display,
      flexDirection: other.flexDirection ?? flexDirection,
      justifyContent: other.justifyContent ?? justifyContent,
      alignItems: other.alignItems ?? alignItems,
      flexWrap: other.flexWrap ?? flexWrap,
      gap: other.gap ?? gap,
    );
  }

  /// Create a copy of this style with specific overrides
  TagflowStyle copyWith({
    TextStyle? textStyle,
    EdgeInsets? padding,
    EdgeInsets? margin,
    Color? backgroundColor,
    BoxDecoration? decoration,
    Alignment? alignment,
    Matrix4? transform,
    TextAlign? textAlign,
    Display? display,
    Axis? flexDirection,
    MainAxisAlignment? justifyContent,
    CrossAxisAlignment? alignItems,
    Wrap? flexWrap,
    double? gap,
  }) {
    return TagflowStyle(
      textStyle: textStyle ?? this.textStyle,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      decoration: decoration ?? this.decoration,
      alignment: alignment ?? this.alignment,
      transform: transform ?? this.transform,
      textAlign: textAlign ?? this.textAlign,
      display: display ?? this.display,
      flexDirection: flexDirection ?? this.flexDirection,
      justifyContent: justifyContent ?? this.justifyContent,
      alignItems: alignItems ?? this.alignItems,
      flexWrap: flexWrap ?? this.flexWrap,
      gap: gap ?? this.gap,
    );
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
        textAlign,
        display,
        flexDirection,
        justifyContent,
        alignItems,
        flexWrap,
        gap,
      ];
}

/// Display options for elements
enum Display {
  /// Block display
  block,

  /// Inline display
  inline,

  /// Inline block display
  inlineBlock,

  /// Flex display
  flex,

  /// None display
  none,
}

/// Flex direction options
enum FlexDirection {
  /// Row direction
  row,

  /// Row reverse direction
  rowReverse,

  /// Column direction
  column,

  /// Column reverse direction
  columnReverse,
}
