// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:tagflow/tagflow.dart';

/// A container that applies TagflowStyle to its child
class StyledContainer extends StatelessWidget {
  /// Create a new styled container
  const StyledContainer({
    required this.style,
    required this.tag,
    this.child,
    this.width,
    this.height,
    super.key,
  });

  /// Style to apply
  final TagflowStyle style;

  /// HTML tag this container represents
  final String tag;

  /// Explicit width constraint
  final double? width;

  /// Explicit height constraint
  final double? height;

  /// Child widget
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    var current = child ?? const SizedBox.shrink();

    // Handle display none
    if (style.display == Display.none) {
      return const SizedBox.shrink();
    }

    // Apply basic styling
    current = DefaultTextStyle.merge(
      style: style.textStyle ?? const TextStyle(),
      textAlign: style.textAlign,
      child: current,
    );

    // Apply padding and margin
    if (style.padding != null || style.margin != null) {
      current = Padding(
        padding: style.margin ?? EdgeInsets.zero,
        child: Padding(
          padding: style.padding ?? EdgeInsets.zero,
          child: current,
        ),
      );
    }

    // Apply background, borders, and shadows
    if (style.backgroundColor != null ||
        style.borderRadius != null ||
        style.border != null ||
        style.boxShadow != null) {
      current = DecoratedBox(
        decoration: BoxDecoration(
          color: style.backgroundColor,
          borderRadius: style.borderRadius,
          border: style.border,
          boxShadow: style.boxShadow,
        ),
        child: current,
      );
    }

    // Apply individual borders
    if (style.borderLeft != null ||
        style.borderRight != null ||
        style.borderTop != null ||
        style.borderBottom != null) {
      current = Container(
        decoration: BoxDecoration(
          border: Border(
            left: style.borderLeft ?? BorderSide.none,
            right: style.borderRight ?? BorderSide.none,
            top: style.borderTop ?? BorderSide.none,
            bottom: style.borderBottom ?? BorderSide.none,
          ),
        ),
        child: current,
      );
    }

    // Apply alignment
    if (style.alignment != null) {
      current = Align(
        alignment: style.alignment!,
        child: current,
      );
    }

    // Apply display-specific styling
    switch (style.display) {
      case Display.flex:
        current = Flex(
          direction: style.flexDirection ?? Axis.horizontal,
          mainAxisAlignment: style.justifyContent ?? MainAxisAlignment.start,
          crossAxisAlignment: style.alignItems ?? CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [current],
        );
      case Display.inline:
        // Inline elements don't create new blocks
        break;
      case Display.block:
      case Display.none:
        // Already handled
        break;
    }

    // Apply size constraints
    current = ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: style.minWidth ?? 0.0,
        maxWidth: style.maxWidth ?? width ?? double.infinity,
        minHeight: style.minHeight ?? 0.0,
        maxHeight: style.maxHeight ?? height ?? double.infinity,
      ),
      child: SizedBox(
        width: style.width ?? width,
        height: style.height ?? height,
        child: current,
      ),
    );

    // Apply aspect ratio
    if (style.aspectRatio != null) {
      current = AspectRatio(
        aspectRatio: style.aspectRatio!,
        child: current,
      );
    }

    // Apply opacity
    if (style.opacity != null) {
      current = Opacity(
        opacity: style.opacity!,
        child: current,
      );
    }

    // Apply overflow
    if (style.overflow != Clip.hardEdge) {
      current = ClipRect(
        clipBehavior: style.overflow,
        child: current,
      );
    }

    // Apply transform
    if (style.transform != null) {
      current = Transform(
        transform: style.transform!,
        alignment: style.transformAlignment,
        child: current,
      );
    }

    // Apply mouse cursor
    if (style.cursor != null) {
      current = MouseRegion(
        cursor: style.cursor!,
        child: current,
      );
    }

    return current;
  }
}
