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

    // Apply text style
    if (style.textStyle != null) {
      current = DefaultTextStyle.merge(
        style: style.textStyle,
        child: current,
      );
    }

    // Create constraints
    final constraints = BoxConstraints(
      maxWidth: width ?? double.infinity,
      maxHeight: height ?? double.infinity,
    );

    // Apply styling based on display type
    switch (style.display) {
      case Display.flex:
        current = Flex(
          direction: style.flexDirection ?? Axis.vertical,
          mainAxisAlignment: style.justifyContent ?? MainAxisAlignment.start,
          crossAxisAlignment: style.alignItems ?? CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [current],
        );
      case Display.inline:
        // Inline elements don't create new blocks
        break;
      case Display.inlineBlock:
        current = IntrinsicWidth(child: current);
      case Display.block:
      case Display.none:
        if (style.alignment != null) {
          current = Align(
            alignment: style.alignment!,
            child: current,
          );
        }
    }

    // Apply container styling if needed
    final hasDecoration =
        style.decoration != null || style.backgroundColor != null;
    final hasSpacing = style.padding != null || style.margin != null;
    final hasTransform = style.transform != null;

    if (hasDecoration || hasSpacing || hasTransform) {
      current = Container(
        padding: style.padding,
        margin: style.margin,
        transform: style.transform,
        decoration: style.decoration?.copyWith(
              color: style.backgroundColor,
            ) ??
            (style.backgroundColor != null
                ? BoxDecoration(color: style.backgroundColor)
                : null),
        clipBehavior: hasDecoration ? Clip.antiAlias : Clip.none,
        child: current,
      );
    }

    // Apply constraints
    return ConstrainedBox(
      constraints: constraints,
      child: current,
    );
  }
}
