import 'package:flutter/widgets.dart';
import 'package:tagflow/src/converter/converter.dart';
import 'package:tagflow/src/core/models/element.dart';
import 'package:tagflow/src/style/style.dart';

/// A widget that applies a style to its child
///
/// e.g.:
///
/// ```dart
/// class StyledTextConverter implements ElementConverter {
///   static const _textTags = {'p', 'span'};

///   @override
///   bool canHandle(TagflowElement element) =>
///       _textTags.contains(element.tag.toLowerCase());

///   @override
///   Widget convert(
///     TagflowElement element,
///     BuildContext context,
///     TagflowConverter converter,
///   ) {
///     final style = resolveStyle(element, context);
///     final children = converter.convertChildren(element.children, context);

///     final content = Column(
///       crossAxisAlignment: CrossAxisAlignment.start,
///       children: children,
///     );

///     return StyledContainerWidget(
///       style: style,
///       child: content,
///     );
///   }
/// }
/// ```
class StyledContainerWidget extends StatelessWidget {
  /// Create a new styled container
  const StyledContainerWidget({
    required this.style,
    required this.child,
    super.key,
  });

  /// The style to apply
  final TagflowStyle style;

  /// The child widget
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: style.padding,
      margin: style.margin,
      decoration: style.decoration?.copyWith(
        color: style.backgroundColor,
      ),
      child: DefaultTextStyle.merge(
        style: style.textStyle ?? const TextStyle(),
        child: child,
      ),
    );
  }
}

/// Extension to help with style resolution
extension StyleResolution on ElementConverter {
  /// Get the computed style for an element
  TagflowStyle resolveStyle(
    TagflowElement element,
    BuildContext context,
  ) {
    final theme = TagflowThemeProvider.of(context);

    // Start with base style
    var style = theme.baseStyle;

    // Add tag-specific style
    final tagStyle = theme.getTagStyle(element.tag);
    if (tagStyle != null) {
      style = style.merge(tagStyle);
    }

    // Add class-specific styles
    // TODO: Add class handling when we add attributes to TagflowElement

    return style;
  }
}
