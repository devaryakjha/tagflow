import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:tagflow/tagflow.dart';

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
    this.width,
    this.height,
    super.key,
  });

  /// The style to apply
  final TagflowStyle style;

  /// The HTML tag this style is being applied to
  final String tag;

  /// The child widget
  final Widget child;

  /// The width of the element
  final double? width;

  /// The height of the element
  final double? height;

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

    // Apply width and height from element or base style
    if (width != null || height != null) {
      current = SizedBox(
        width: width,
        height: height,
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
// lib/src/converter/converter.dart
extension StyleResolution on ElementConverter {
  /// Get the computed style for an element
  TagflowStyle resolveStyle(
    TagflowElement element,
    BuildContext context,
  ) {
    final theme = TagflowThemeProvider.of(context);

    // Start with base style
    var style = theme.baseStyle;

    // Add default element style if exists
    if (style.defaultElementStyle != null) {
      style = style.merge(
        TagflowStyle(
          textStyle: style.defaultElementStyle?.textStyle,
          padding: style.defaultElementStyle?.padding,
          margin: style.defaultElementStyle?.margin,
          decoration: style.defaultElementStyle?.decoration,
          alignment: style.defaultElementStyle?.alignment,
        ),
      );
    }

    // Add tag-specific style from theme's tagStyles
    final tagStyle = theme.getTagStyle(element.tag);
    if (tagStyle != null) {
      style = style.merge(tagStyle);
    }

    // Add element-specific style
    final elementStyle = style.getElementStyle(element.tag);
    if (elementStyle != null) {
      style = style.merge(
        TagflowStyle(
          textStyle: elementStyle.textStyle,
          padding: elementStyle.padding,
          margin: elementStyle.margin,
          decoration: elementStyle.decoration,
          alignment: elementStyle.alignment,
        ),
      );
    }

    // Add class-specific styles
    for (final className in element.classList) {
      final classStyle = theme.getClassStyle(className);
      if (classStyle != null) {
        style = style.merge(classStyle);
      }
    }

    // Finally, add inline styles
    if (element.styles != null) {
      style = style.merge(_parseInlineStyles(element.styles!));
    }

    return style;
  }

  /// Parse inline styles into TagflowStyle
  TagflowStyle _parseInlineStyles(Map<Object, String> styles) {
    var textStyle = const TextStyle();
    EdgeInsets? padding;
    EdgeInsets? margin;
    Color? backgroundColor;
    BoxDecoration? decoration;
    Alignment? alignment;

    for (final entry in styles.entries) {
      final property = entry.key.toString();
      final value = entry.value;

      switch (property) {
        // Font styles
        case 'font-size':
          final size = StyleParser.parseFontSize(value);
          if (size != null) {
            textStyle = textStyle.copyWith(fontSize: size);
          }
        case 'font-weight':
          final weight = StyleParser.parseFontWeight(value);
          if (weight != null) {
            textStyle = textStyle.copyWith(fontWeight: weight);
          }
        case 'font-style':
          final style = StyleParser.parseFontStyle(value);
          if (style != null) {
            textStyle = textStyle.copyWith(fontStyle: style);
          }
        case 'color':
          final color = StyleParser.parseColor(value);
          if (color != null) {
            textStyle = textStyle.copyWith(color: color);
          }
        case 'text-decoration':
          final decoration = StyleParser.parseTextDecoration(value);
          if (decoration != null) {
            textStyle = textStyle.copyWith(decoration: decoration);
          }
        case 'text-align':
        // Handle in the converter since it's not part of TextStyle

        // Layout
        case 'padding':
          padding = StyleParser.parseEdgeInsets(value);
        case 'margin':
          margin = StyleParser.parseEdgeInsets(value);
        case 'background-color':
          backgroundColor = StyleParser.parseColor(value);

        // Add more properties as needed
      }
    }

    return TagflowStyle(
      textStyle: textStyle,
      padding: padding,
      margin: margin,
      backgroundColor: backgroundColor,
      decoration: decoration,
      alignment: alignment,
    );
  }
}
