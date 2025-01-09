import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:tagflow/tagflow.dart';

/// Style configuration for HTML elements
class TagflowStyle extends Equatable {
  /// Creates a new [TagflowStyle]
  const TagflowStyle({
    this.textStyle,
    this.textScaleFactor,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.color,
    this.borderRadius,
    this.border,
    this.borderLeft,
    this.borderRight,
    this.borderTop,
    this.borderBottom,
    this.boxShadow,
    this.alignment,
    this.textAlign,
    this.display = Display.block,
    this.flexDirection,
    this.justifyContent,
    this.alignItems,
    this.gap,
    this.width,
    this.height,
    this.minWidth,
    this.minHeight,
    this.maxWidth,
    this.maxHeight,
    this.aspectRatio,
    this.opacity,
    this.overflow = Clip.hardEdge,
    this.transform,
    this.transformAlignment,
    this.boxFit,
    this.cursor,
  });

  static const TagflowStyle empty = TagflowStyle();

  /// Text style
  final TextStyle? textStyle;

  /// Text scale factor
  final double? textScaleFactor;

  /// Padding around the content
  final EdgeInsets? padding;

  /// Margin around the element
  final EdgeInsets? margin;

  /// Background color
  final Color? backgroundColor;

  /// Text color
  final Color? color;

  /// Border radius
  final BorderRadius? borderRadius;

  /// Border for all sides
  final Border? border;

  /// Left border
  final BorderSide? borderLeft;

  /// Right border
  final BorderSide? borderRight;

  /// Top border
  final BorderSide? borderTop;

  /// Bottom border
  final BorderSide? borderBottom;

  /// Box shadow
  final List<BoxShadow>? boxShadow;

  /// Alignment within parent
  final Alignment? alignment;

  /// Text alignment
  final TextAlign? textAlign;

  /// Display type
  final Display display;

  /// Flex direction (for flex containers)
  final Axis? flexDirection;

  /// Main axis alignment (for flex containers)
  final MainAxisAlignment? justifyContent;

  /// Cross axis alignment (for flex containers)
  final CrossAxisAlignment? alignItems;

  /// Gap between flex items
  final double? gap;

  /// Element width
  final double? width;

  /// Element height
  final double? height;

  /// Minimum width
  final double? minWidth;

  /// Minimum height
  final double? minHeight;

  /// Maximum width
  final double? maxWidth;

  /// Maximum height
  final double? maxHeight;

  /// Aspect ratio
  final double? aspectRatio;

  /// Opacity
  final double? opacity;

  /// Overflow behavior
  final Clip overflow;

  /// Transform matrix
  final Matrix4? transform;

  /// Transform alignment
  final AlignmentGeometry? transformAlignment;

  /// Box fit for images
  final BoxFit? boxFit;

  /// Mouse cursor
  final MouseCursor? cursor;

  /// Creates a copy with some properties replaced
  TagflowStyle copyWith({
    TextStyle? textStyle,
    EdgeInsets? padding,
    EdgeInsets? margin,
    Color? backgroundColor,
    Color? color,
    BorderRadius? borderRadius,
    Border? border,
    BorderSide? borderLeft,
    BorderSide? borderRight,
    BorderSide? borderTop,
    BorderSide? borderBottom,
    List<BoxShadow>? boxShadow,
    Alignment? alignment,
    TextAlign? textAlign,
    Display? display,
    Axis? flexDirection,
    MainAxisAlignment? justifyContent,
    CrossAxisAlignment? alignItems,
    double? gap,
    double? width,
    double? height,
    double? minWidth,
    double? minHeight,
    double? maxWidth,
    double? maxHeight,
    double? aspectRatio,
    double? opacity,
    Clip? overflow,
    Matrix4? transform,
    AlignmentGeometry? transformAlignment,
    BoxFit? boxFit,
    MouseCursor? cursor,
    double? textScaleFactor,
  }) {
    return TagflowStyle(
      textStyle: textStyle ?? this.textStyle,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      color: color ?? this.color,
      borderRadius: borderRadius ?? this.borderRadius,
      border: border ?? this.border,
      borderLeft: borderLeft ?? this.borderLeft,
      borderRight: borderRight ?? this.borderRight,
      borderTop: borderTop ?? this.borderTop,
      borderBottom: borderBottom ?? this.borderBottom,
      boxShadow: boxShadow ?? this.boxShadow,
      alignment: alignment ?? this.alignment,
      textAlign: textAlign ?? this.textAlign,
      display: display ?? this.display,
      flexDirection: flexDirection ?? this.flexDirection,
      justifyContent: justifyContent ?? this.justifyContent,
      alignItems: alignItems ?? this.alignItems,
      gap: gap ?? this.gap,
      width: width ?? this.width,
      height: height ?? this.height,
      minWidth: minWidth ?? this.minWidth,
      minHeight: minHeight ?? this.minHeight,
      maxWidth: maxWidth ?? this.maxWidth,
      maxHeight: maxHeight ?? this.maxHeight,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      opacity: opacity ?? this.opacity,
      overflow: overflow ?? this.overflow,
      transform: transform ?? this.transform,
      transformAlignment: transformAlignment ?? this.transformAlignment,
      boxFit: boxFit ?? this.boxFit,
      cursor: cursor ?? this.cursor,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
    );
  }

  /// Merges two styles, with properties from [other] taking precedence
  TagflowStyle merge(TagflowStyle? other) {
    if (other == null) return this;

    return TagflowStyle(
      textStyle:
          textStyle?.merge(other.textStyle) ?? textStyle ?? other.textStyle,
      padding: other.padding ?? padding,
      margin: other.margin ?? margin,
      backgroundColor: other.backgroundColor ?? backgroundColor,
      color: other.color ?? color,
      borderRadius: other.borderRadius ?? borderRadius,
      border: other.border ?? border,
      borderLeft: other.borderLeft ?? borderLeft,
      borderRight: other.borderRight ?? borderRight,
      borderTop: other.borderTop ?? borderTop,
      borderBottom: other.borderBottom ?? borderBottom,
      boxShadow: other.boxShadow ?? boxShadow,
      alignment: other.alignment ?? alignment,
      textAlign: other.textAlign ?? textAlign,
      display: other.display,
      flexDirection: other.flexDirection ?? flexDirection,
      justifyContent: other.justifyContent ?? justifyContent,
      alignItems: other.alignItems ?? alignItems,
      gap: other.gap ?? gap,
      width: other.width ?? width,
      height: other.height ?? height,
      minWidth: other.minWidth ?? minWidth,
      minHeight: other.minHeight ?? minHeight,
      maxWidth: other.maxWidth ?? maxWidth,
      maxHeight: other.maxHeight ?? maxHeight,
      aspectRatio: other.aspectRatio ?? aspectRatio,
      opacity: other.opacity ?? opacity,
      overflow: other.overflow,
      transform: other.transform ?? transform,
      transformAlignment: other.transformAlignment ?? transformAlignment,
      boxFit: other.boxFit ?? boxFit,
      cursor: other.cursor ?? cursor,
      textScaleFactor: other.textScaleFactor ?? textScaleFactor,
    );
  }

  @override
  List<Object?> get props => [
        textStyle,
        padding,
        margin,
        backgroundColor,
        color,
        borderRadius,
        border,
        borderLeft,
        borderRight,
        borderTop,
        borderBottom,
        boxShadow,
        alignment,
        textAlign,
        display,
        flexDirection,
        justifyContent,
        alignItems,
        gap,
        width,
        height,
        minWidth,
        minHeight,
        maxWidth,
        maxHeight,
        aspectRatio,
        opacity,
        overflow,
        transform,
        transformAlignment,
        boxFit,
        cursor,
        textScaleFactor,
      ];
}
