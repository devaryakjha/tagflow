// lib/src/converter/converter.dart
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:tagflow/tagflow.dart';

/// Base interface for element converters
abstract class ElementConverter {
  /// Create a new element converter
  const ElementConverter();

  /// Supported tags for this converter
  Set<String> get supportedTags;

  /// Whether this converter can handle the given element
  bool canHandle(TagflowElement element) => supportedTags.contains(element.tag);

  /// Convert the element to a widget
  Widget convert(
    TagflowElement element,
    BuildContext context,
    TagflowConverter converter,
  );

  @override
  String toString() {
    return '$runtimeType(supportedTags: $supportedTags)';
  }
}

/// Main converter that orchestrates the conversion process
class TagflowConverter {
  /// Create a new converter
  TagflowConverter() {
    // Register built-in converters
    _registerBuiltIns([
      const ContainerConverter(),
      const TextConverter(),
      const ImgConverter(),
      const BrConverter(),
      const BasicCodeConverter(),
      const BlockquoteConverter(),
    ]);
  }

  /// Custom converters take precedence over built-in ones
  final List<ElementConverter> _customConverters = [];

  /// Built-in converters as fallback
  final List<ElementConverter> _builtInConverters = [];

  /// Add a custom converter that takes precedence over built-in ones
  void addConverter(ElementConverter converter) {
    _customConverters.add(converter);
  }

  /// Add multiple custom converters
  void addAllConverters(List<ElementConverter> converters) {
    _customConverters.addAll(converters);
  }

  /// Internal method to register built-in converters
  void _registerBuiltIns(List<ElementConverter> converters) {
    _builtInConverters.addAll(converters);
  }

  /// Convert a TagflowElement to a Widget
  Widget convert(TagflowElement element, BuildContext context) {
    // Combine custom and built-in converters for a single iteration
    final allConverters = [..._customConverters, ..._builtInConverters];

    for (final converter in allConverters) {
      if (converter.canHandle(element)) {
        log('Using converter: $converter');
        return converter.convert(element, context, this);
      }
    }

    // Fallback to default converter
    return DefaultConverter().convert(element, context, this);
  }

  /// Convert a list of elements to widgets
  List<Widget> convertChildren(
    List<TagflowElement> elements,
    BuildContext context,
  ) {
    return elements.map((e) => convert(e, context)).toList();
  }
}

/// Default fallback converter
class DefaultConverter extends ElementConverter {
  @override
  Set<String> get supportedTags => {};

  @override
  bool canHandle(TagflowElement element) => true;

  @override
  Widget convert(
    TagflowElement element,
    BuildContext context,
    TagflowConverter converter,
  ) {
    if (element.isTextNode) {
      return Text(element.textContent ?? '');
    }
    return const SizedBox.shrink();
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
          backgroundColor: elementStyle.decoration?.color,
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
