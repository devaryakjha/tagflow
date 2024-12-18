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
    super.key,
  });

  /// Style to apply
  final TagflowStyle style;

  /// HTML tag this container represents
  final String tag;

  /// Child widget
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    if (style.display == Display.none) {
      return const SizedBox.shrink();
    }

    return _buildStyledWidget(
      _buildLayoutWidget(
        child ?? const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildStyledWidget(Widget child) {
    // Early return if no visual styles are applied
    if (!_hasVisualStyles) {
      return child;
    }

    var current = child;

    // Apply text styling
    if (style.textStyle != null || style.textAlign != null) {
      current = DefaultTextStyle.merge(
        style: style.textStyle ?? const TextStyle(),
        textAlign: style.textAlign,
        child: current,
      );
    }

    // Apply spacing
    if (style.padding != null || style.margin != null) {
      current = Padding(
        padding: style.margin ?? EdgeInsets.zero,
        child: Padding(
          padding: style.padding ?? EdgeInsets.zero,
          child: current,
        ),
      );
    }

    // Apply visual styles
    if (_hasDecoration) {
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
    if (_hasIndividualBorders) {
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

    // Apply effects
    return _applyEffects(current);
  }

  Widget _buildLayoutWidget(Widget child) {
    var current = child;

    // Apply alignment
    if (style.alignment != null) {
      current = Align(
        alignment: style.alignment!,
        child: current,
      );
    }

    // Apply display-specific layout
    current = switch (style.display) {
      Display.flex => Flex(
          direction: style.flexDirection ?? Axis.horizontal,
          mainAxisAlignment: style.justifyContent ?? MainAxisAlignment.start,
          crossAxisAlignment: style.alignItems ?? CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [current],
        ),
      Display.inline => current, // Inline elements don't create new blocks
      _ => current, // block and none are handled elsewhere
    };

    // Apply size constraints if any exist
    if (_hasSizeConstraints) {
      current = ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: style.minWidth ?? 0.0,
          maxWidth: style.maxWidth ?? double.infinity,
          minHeight: style.minHeight ?? 0.0,
          maxHeight: style.maxHeight ?? double.infinity,
        ),
        child: SizedBox(
          width: style.width,
          height: style.height,
          child: current,
        ),
      );
    }

    // Apply aspect ratio
    if (style.aspectRatio != null) {
      current = AspectRatio(
        aspectRatio: style.aspectRatio!,
        child: current,
      );
    }

    return current;
  }

  Widget _applyEffects(Widget child) {
    var current = child;

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

  // Optimization helpers
  bool get _hasVisualStyles =>
      style.textStyle != null ||
      style.textAlign != null ||
      style.padding != null ||
      style.margin != null ||
      _hasDecoration ||
      _hasIndividualBorders ||
      style.opacity != null ||
      style.overflow != Clip.hardEdge ||
      style.transform != null ||
      style.cursor != null;

  bool get _hasDecoration =>
      style.backgroundColor != null ||
      style.borderRadius != null ||
      style.border != null ||
      style.boxShadow != null;

  bool get _hasIndividualBorders =>
      style.borderLeft != null ||
      style.borderRight != null ||
      style.borderTop != null ||
      style.borderBottom != null;

  bool get _hasSizeConstraints =>
      style.width != null ||
      style.height != null ||
      style.minWidth != null ||
      style.minHeight != null ||
      style.maxWidth != null ||
      style.maxHeight != null;
}
