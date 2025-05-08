// ignore_for_file: public_member_api_docs, dead_code

import 'package:flutter/widgets.dart';
import 'package:tagflow/tagflow.dart';

/// A container that applies TagflowStyle to its child
class StyledContainer extends StatelessWidget {
  /// Create a new styled container
  const StyledContainer({
    required this.style,
    required this.tag,
    this.child,
    super.key,
  });

  /// Style to apply
  final TagflowStyle style;

  /// HTML tag this container represents
  final String tag;

  /// Child widget
  final Widget? child;

  bool _needsContainer(TagflowStyle style) {
    return style.padding != null ||
        style.margin != null ||
        style.width != null ||
        style.height != null ||
        style.minWidth != null ||
        style.maxWidth != null ||
        style.minHeight != null ||
        style.maxHeight != null ||
        style.alignment != null ||
        style.toBoxDecoration() != null ||
        style.transform != null;
  }

  @override
  Widget build(BuildContext context) {
    if (style.display == Display.none) {
      return const SizedBox.shrink();
    }

    var content = child ?? const SizedBox.shrink();

    // Apply display-specific layout
    content = switch (style.display) {
      Display.flex => Flex(
        direction: style.flexDirection ?? Axis.horizontal,
        mainAxisAlignment: style.justifyContent ?? MainAxisAlignment.start,
        crossAxisAlignment: style.alignItems ?? CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [content],
      ),
      _ => content,
    };

    if (!_needsContainer(style)) {
      return content;
    }


    return Container(
      padding: style.padding,
      margin: style.margin,
      width: style.width,
      height: style.height,
      constraints: BoxConstraints(
        minWidth: style.minWidth ?? 0.0,
        maxWidth: style.maxWidth ?? double.infinity,
        minHeight: style.minHeight ?? 0.0,
        maxHeight: style.maxHeight ?? double.infinity,
      ),
      alignment: style.alignment,
      decoration: style.toBoxDecoration() ?? const BoxDecoration(),
      clipBehavior: style.overflow,
      transform: style.transform,
      transformAlignment: style.transformAlignment,
      child: MouseRegion(
        cursor: style.cursor ?? MouseCursor.defer,
        child: Opacity(
          opacity: style.opacity ?? 1.0,
          child: DefaultTextStyle.merge(
            style: style.textStyleWithColor ?? const TextStyle(),
            textAlign: style.textAlign,
            child:
                style.aspectRatio != null
                    ? AspectRatio(
                      aspectRatio: style.aspectRatio!,
                      child: content,
                    )
                    : content,
          ),
        ),
      ),
    );
  }
}
