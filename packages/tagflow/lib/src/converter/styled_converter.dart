// ignore_for_file: public_member_api_docs

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
    final hasDecoration = style.decoration != null;
    final hasAlignment = style.alignment != null;
    final hasPadding = style.padding != null;
    final hasMargin = style.margin != null;
    final hasTransform = style.transform != null;
    final needsStyling = hasDecoration ||
        hasAlignment ||
        hasPadding ||
        hasMargin ||
        hasTransform;

    final constraints = BoxConstraints.tightFor(width: width, height: height);

    return DefaultTextStyle.merge(
      style: style.textStyle,
      child: needsStyling
          ? Container(
              transform: style.transform,
              clipBehavior: hasDecoration ? Clip.antiAlias : Clip.none,
              alignment: style.alignment,
              padding: style.padding,
              margin: style.margin,
              decoration: style.decoration,
              constraints: constraints,
              child: child,
            )
          : ConstrainedBox(constraints: constraints, child: child),
    );
  }
}
