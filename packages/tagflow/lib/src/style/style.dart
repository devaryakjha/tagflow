import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:tagflow/tagflow.dart';

/// Style configuration for HTML elements
class TagflowStyle extends Equatable {
  /// Creates a new [TagflowStyle] with [SizeValue] parameters
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
    SizeValue? gap,
    SizeValue? width,
    SizeValue? height,
    SizeValue? minWidth,
    SizeValue? minHeight,
    SizeValue? maxWidth,
    SizeValue? maxHeight,
    this.aspectRatio,
    this.opacity,
    this.overflow = Clip.hardEdge,
    this.transform,
    this.transformAlignment,
    this.boxFit,
    this.cursor,
    this.inherit = true,
    this.softWrap,
  })  : _gap = gap,
        _width = width,
        _height = height,
        _minWidth = minWidth,
        _minHeight = minHeight,
        _maxWidth = maxWidth,
        _maxHeight = maxHeight;

  /// Creates a new [TagflowStyle] with pixel values
  factory TagflowStyle.pixels({
    TextStyle? textStyle,
    double? textScaleFactor,
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
    Display display = Display.block,
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
    Clip overflow = Clip.hardEdge,
    Matrix4? transform,
    AlignmentGeometry? transformAlignment,
    BoxFit? boxFit,
    MouseCursor? cursor,
    bool inherit = true,
    bool? softWrap,
  }) {
    return TagflowStyle(
      textStyle: textStyle,
      textScaleFactor: textScaleFactor,
      padding: padding,
      margin: margin,
      backgroundColor: backgroundColor,
      color: color,
      borderRadius: borderRadius,
      border: border,
      borderLeft: borderLeft,
      borderRight: borderRight,
      borderTop: borderTop,
      borderBottom: borderBottom,
      boxShadow: boxShadow,
      alignment: alignment,
      textAlign: textAlign,
      display: display,
      flexDirection: flexDirection,
      justifyContent: justifyContent,
      alignItems: alignItems,
      gap: gap != null ? SizeValue(gap) : null,
      width: width != null ? SizeValue(width) : null,
      height: height != null ? SizeValue(height) : null,
      minWidth: minWidth != null ? SizeValue(minWidth) : null,
      minHeight: minHeight != null ? SizeValue(minHeight) : null,
      maxWidth: maxWidth != null ? SizeValue(maxWidth) : null,
      maxHeight: maxHeight != null ? SizeValue(maxHeight) : null,
      aspectRatio: aspectRatio,
      opacity: opacity,
      overflow: overflow,
      transform: transform,
      transformAlignment: transformAlignment,
      boxFit: boxFit,
      cursor: cursor,
      inherit: inherit,
      softWrap: softWrap,
    );
  }

  /// Empty style
  static const TagflowStyle empty = TagflowStyle();

  /// Text style
  final TextStyle? textStyle;

  /// Text scale factor
  final double? textScaleFactor;

  /// Padding around the element
  final EdgeInsets? padding;

  /// Margin around the element
  final EdgeInsets? margin;

  /// Background color
  final Color? backgroundColor;

  /// Text color
  final Color? color;

  /// Border radius
  final BorderRadius? borderRadius;

  /// Border
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

  /// Alignment
  final Alignment? alignment;

  /// Text alignment
  final TextAlign? textAlign;

  /// Display type
  final Display display;

  /// Flex direction
  final Axis? flexDirection;

  /// Main axis alignment
  final MainAxisAlignment? justifyContent;

  /// Cross axis alignment
  final CrossAxisAlignment? alignItems;

  /// Gap between flex items (internal)
  final SizeValue? _gap;

  /// Width (internal)
  final SizeValue? _width;

  /// Height (internal)
  final SizeValue? _height;

  /// Minimum width (internal)
  final SizeValue? _minWidth;

  /// Minimum height (internal)
  final SizeValue? _minHeight;

  /// Maximum width (internal)
  final SizeValue? _maxWidth;

  /// Maximum height (internal)
  final SizeValue? _maxHeight;

  /// Gap between flex items
  double? get gap => _gap?.value;

  /// Width
  double? get width => _width?.value;

  /// Height
  double? get height => _height?.value;

  /// Minimum width
  double? get minWidth => _minWidth?.value;

  /// Minimum height
  double? get minHeight => _minHeight?.value;

  /// Maximum width
  double? get maxWidth => _maxWidth?.value;

  /// Maximum height
  double? get maxHeight => _maxHeight?.value;

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

  /// Inherit from parent
  final bool inherit;

  /// Useful for text elements
  final bool? softWrap;

  /// Resolves all size values in the style using the given context
  TagflowStyle resolveSize(
    BuildContext context, {
    double? parentWidth0,
    double? parentHeight0,
  }) {
    final size = MediaQuery.sizeOf(context);
    final parentWidth = parentWidth0 ?? size.width;
    final parentHeight = parentHeight0 ?? size.height;

    final gap = _gap?.resolve(context, parentSize: parentWidth);
    final width = _width?.resolve(context, parentSize: parentWidth);
    final height = _height?.resolve(context, parentSize: parentHeight);
    final minWidth = _minWidth?.resolve(context, parentSize: parentWidth);
    final minHeight = _minHeight?.resolve(context, parentSize: parentHeight);
    final maxWidth = _maxWidth?.resolve(context, parentSize: parentWidth);
    final maxHeight = _maxHeight?.resolve(context, parentSize: parentHeight);

    return copyWith(
      gap: gap != null ? SizeValue(gap) : null,
      width: width != null ? SizeValue(width) : null,
      height: height != null ? SizeValue(height) : null,
      minWidth: minWidth != null ? SizeValue(minWidth) : null,
      minHeight: minHeight != null ? SizeValue(minHeight) : null,
      maxWidth: maxWidth != null ? SizeValue(maxWidth) : null,
      maxHeight: maxHeight != null ? SizeValue(maxHeight) : null,
    );
  }

  /// Creates a copy with some properties replaced
  TagflowStyle copyWith({
    bool? inherit,
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
    SizeValue? gap,
    SizeValue? width,
    SizeValue? height,
    SizeValue? minWidth,
    SizeValue? minHeight,
    SizeValue? maxWidth,
    SizeValue? maxHeight,
    double? aspectRatio,
    double? opacity,
    Clip? overflow,
    Matrix4? transform,
    AlignmentGeometry? transformAlignment,
    BoxFit? boxFit,
    MouseCursor? cursor,
    double? textScaleFactor,
    bool? softWrap,
  }) {
    return TagflowStyle(
      inherit: inherit ?? this.inherit,
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
      gap: gap ?? _gap,
      width: width ?? _width,
      height: height ?? _height,
      minWidth: minWidth ?? _minWidth,
      minHeight: minHeight ?? _minHeight,
      maxWidth: maxWidth ?? _maxWidth,
      maxHeight: maxHeight ?? _maxHeight,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      opacity: opacity ?? this.opacity,
      overflow: overflow ?? this.overflow,
      transform: transform ?? this.transform,
      transformAlignment: transformAlignment ?? this.transformAlignment,
      boxFit: boxFit ?? this.boxFit,
      cursor: cursor ?? this.cursor,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
      softWrap: softWrap ?? this.softWrap,
    );
  }

  /// Merges this style with another style
  TagflowStyle merge(TagflowStyle? other) {
    if (other == null) return this;

    return copyWith(
      inherit: other.inherit,
      textStyle: textStyle?.merge(other.textStyle) ?? other.textStyle,
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
      gap: other._gap ?? _gap,
      width: other._width ?? _width,
      height: other._height ?? _height,
      minWidth: other._minWidth ?? _minWidth,
      minHeight: other._minHeight ?? _minHeight,
      maxWidth: other._maxWidth ?? _maxWidth,
      maxHeight: other._maxHeight ?? _maxHeight,
      aspectRatio: other.aspectRatio ?? aspectRatio,
      opacity: other.opacity ?? opacity,
      overflow: other.overflow,
      transform: other.transform ?? transform,
      transformAlignment: other.transformAlignment ?? transformAlignment,
      boxFit: other.boxFit ?? boxFit,
      cursor: other.cursor ?? cursor,
      textScaleFactor: other.textScaleFactor ?? textScaleFactor,
      softWrap: other.softWrap ?? softWrap,
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
        _gap,
        _width,
        _height,
        _minWidth,
        _minHeight,
        _maxWidth,
        _maxHeight,
        aspectRatio,
        opacity,
        overflow,
        transform,
        transformAlignment,
        boxFit,
        cursor,
        textScaleFactor,
        inherit,
        softWrap,
      ];
}
