// ignore_for_file: public_member_api_docs

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:tagflow/tagflow.dart';

class StyledContainer extends StatelessWidget {
  const StyledContainer({
    required this.style,
    required this.tag,
    required this.child,
    this.width,
    this.height,
    super.key,
  });

  final TagflowStyle style;
  final String tag;
  final double? width;
  final double? height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      style: style.textStyle,
      child: _StyledContainerWidget(
        style: style,
        tag: tag,
        width: width,
        height: height,
        child: child,
      ),
    );
  }
}

class _StyledContainerWidget extends SingleChildRenderObjectWidget {
  const _StyledContainerWidget({
    required this.style,
    required this.tag,
    required Widget super.child,
    this.width,
    this.height,
  });

  final TagflowStyle style;
  final String tag;
  final double? width;
  final double? height;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderStyledContainer(
      style: style,
      tag: tag,
      width: width,
      height: height,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderStyledContainer renderObject,
  ) {
    if (renderObject.style != style ||
        renderObject.tag != tag ||
        renderObject.width != width ||
        renderObject.height != height) {
      renderObject
        ..style = style
        ..tag = tag
        ..width = width
        ..height = height;
    }
  }
}

class RenderStyledContainer extends RenderBox
    with RenderObjectWithChildMixin<RenderBox>, RenderProxyBoxMixin {
  RenderStyledContainer({
    required TagflowStyle style,
    required String tag,
    double? width,
    double? height,
  })  : _style = style,
        _tag = tag,
        _width = width,
        _height = height {
    _updateCachedStyles();
  }

  TagflowStyle _style;
  TagflowStyle get style => _style;
  set style(TagflowStyle value) {
    if (_style == value) return;
    _style = value;
    _updateCachedStyles();
    markNeedsLayout();
  }

  String _tag;
  String get tag => _tag;
  set tag(String value) {
    if (_tag == value) return;
    _tag = value;
    _updateCachedStyles();
    markNeedsLayout();
  }

  double? _width;
  double? get width => _width;
  set width(double? value) {
    if (_width == value) return;
    _width = value;
    markNeedsLayout();
  }

  double? _height;
  double? get height => _height;
  set height(double? value) {
    if (_height == value) return;
    _height = value;
    markNeedsLayout();
  }

  // Cached styles for better performance
  late EdgeInsets _margin;
  late EdgeInsets _padding;
  late BoxDecoration? _decoration;
  late bool _hasDecoration;
  late bool _needsClipping;

  void _updateCachedStyles() {
    final elementStyle = _style.getElementStyle(_tag);
    _margin = elementStyle?.margin ?? _style.margin ?? EdgeInsets.zero;
    _padding = elementStyle?.padding ?? _style.padding ?? EdgeInsets.zero;

    if (_style.backgroundColor != null || elementStyle?.decoration != null) {
      _decoration = (elementStyle?.decoration ?? const BoxDecoration())
          .copyWith(color: _style.backgroundColor);
      _hasDecoration = true;
      // Check if decoration requires clipping
      _needsClipping = _decoration?.borderRadius != null ||
          _decoration?.shape != BoxShape.rectangle;
    } else {
      _decoration = null;
      _hasDecoration = false;
      _needsClipping = false;
    }
    markNeedsPaint();
  }

  @override
  void performLayout() {
    if (child == null) {
      size = constraints.constrain(Size(_width ?? 0.0, _height ?? 0.0));
      return;
    }

    // Use cached values for better performance
    final horizontalExtra = _margin.horizontal + _padding.horizontal;
    final verticalExtra = _margin.vertical + _padding.vertical;

    final childConstraints = constraints.deflate(
      EdgeInsets.symmetric(
        horizontal: horizontalExtra,
        vertical: verticalExtra,
      ),
    );

    child?.layout(childConstraints, parentUsesSize: true);

    // Optimize size calculation
    final childSize = child!.size;
    final width = _width ?? (childSize.width + horizontalExtra);
    final height = _height ?? (childSize.height + verticalExtra);
    size = constraints.constrain(Size(width, height));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_needsClipping) {
      _paintWithClipping(context, offset);
    } else {
      _paintWithoutClipping(context, offset);
    }
  }

  void _paintWithClipping(PaintingContext context, Offset offset) {
    final marginOffset = offset.translate(_margin.left, _margin.top);
    // Calculate content rect accounting for padding/margin
    final contentRect = Rect.fromLTWH(
      _margin.left,
      _margin.top,
      size.width - _margin.horizontal,
      size.height - _margin.vertical,
    );

    if (_hasDecoration && _decoration != null) {
      context.pushClipPath(
        needsCompositing,
        offset, // Use original offset for proper clipping
        contentRect, // Use content rect for decoration bounds
        _decoration!.getClipPath(contentRect, TextDirection.ltr),
        (context, offset) {
          // Paint decoration aligned with content
          _decoration!.createBoxPainter().paint(
                context.canvas,
                marginOffset,
                ImageConfiguration(size: contentRect.size),
              );

          // Paint child with proper padding offset
          if (child != null) {
            final childOffset =
                marginOffset.translate(_padding.left, _padding.top);
            context.paintChild(child!, childOffset);
          }
        },
      );
    }
  }

  void _paintWithoutClipping(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final marginOffset = offset.translate(_margin.left, _margin.top);
    final contentSize = Size(
      size.width - _margin.horizontal,
      size.height - _margin.vertical,
    );

    if (_hasDecoration && _decoration != null) {
      // Paint decoration only in the content area (after margin)
      _decoration!.createBoxPainter().paint(
            canvas,
            marginOffset,
            ImageConfiguration(
              size: contentSize,
            ), // Use content size, not full size
          );
    }

    if (child != null) {
      final childOffset = marginOffset.translate(_padding.left, _padding.top);
      context.paintChild(child!, childOffset);
    }
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (size.contains(position)) {
      // Adjust hit test position for margin and padding
      final adjustedPosition = position.translate(
        -(_margin.left + _padding.left),
        -(_margin.top + _padding.top),
      );

      if (child != null && child!.hitTest(result, position: adjustedPosition)) {
        result.add(BoxHitTestEntry(this, position));
        return true;
      }
    }
    return false;
  }

  @override
  Rect get paintBounds =>
      Offset(_margin.left, _margin.top) &
      Size(
        size.width - _margin.horizontal,
        size.height - _margin.vertical,
      );
}
