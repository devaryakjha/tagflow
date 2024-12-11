import 'package:flutter/src/foundation/diagnostics.dart';
import 'package:flutter/widgets.dart';
import 'package:tagflow/src/converter/converter.dart';
import 'package:tagflow/src/core/models/element.dart';
import 'package:tagflow/src/style/style.dart';

/// {@template styled_widget}
/// A widget that applies a style to its child
///
/// e.g.:
///
/// ```dart
/// class StyledTextConverter implements ElementConverter {
///   static const supportedTags = {'p', 'span', ...};

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
/// {@endtemplate}
class StyledContainerWidget extends StatelessWidget {
  /// Create a new styled container
  ///
  /// {@macro styled_widget}
  const StyledContainerWidget({
    required this.style,
    required this.tag,
    required this.child,
    super.key,
  });

  /// The style to apply
  final TagflowStyle style;

  /// The HTML tag this style is being applied to
  final String tag;

  /// The child widget
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final elementStyle = style.getElementStyle(tag);

    // Start with the child
    var current = child;

    // Apply text styles if any exist
    final mergedTextStyle = style.textStyle?.merge(
      elementStyle?.textStyle ?? const TextStyle(),
    );

    if (mergedTextStyle != null) {
      current = DefaultTextStyle.merge(
        style: mergedTextStyle,
        child: current,
      );
    }

    // Apply padding from element or base style
    final padding = elementStyle?.padding ?? style.padding;
    if (padding != null) {
      current = Padding(
        padding: padding,
        child: current,
      );
    }

    // Apply margin from element or base style
    final margin = elementStyle?.margin ?? style.margin;
    if (margin != null) {
      current = Padding(
        padding: margin,
        child: current,
      );
    }

    // Apply decoration and background color if needed
    final decoration = elementStyle?.decoration ?? style.decoration;
    final backgroundColor = style.backgroundColor;
    if (decoration != null || backgroundColor != null) {
      current = DecoratedBox(
        decoration: (decoration ?? const BoxDecoration()).copyWith(
          color: backgroundColor,
        ),
        child: current,
      );
    }

    return current;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty<TagflowStyle>('style', style))
      ..add(DiagnosticsProperty<String>('tag', tag))
      ..add(DiagnosticsProperty<Widget>('child', child));

    super.debugFillProperties(properties);
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

    // Add tag-specific style from theme's tagStyles
    final tagStyle = theme.getTagStyle(element.tag);
    if (tagStyle != null) {
      style = style.merge(tagStyle);
    }

    // Add class-specific styles if element has classes
    if (element.classList.isNotEmpty) {
      final classStyles =
          element.classList.map(theme.getClassStyle).whereType<TagflowStyle>();

      if (classStyles.isNotEmpty) {
        style = style.merge(classStyles.reduce((a, b) => a.merge(b)));
      }
    }

    return style;
  }
}
