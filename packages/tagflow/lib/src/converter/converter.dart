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

  /// Get the computed style for an element
  TagflowStyle resolveStyle(TagflowElement element, BuildContext context) {
    return TagflowThemeProvider.of(context).resolveStyle(element);
  }

  @override
  String toString() => '$runtimeType(supportedTags: $supportedTags)';
}

/// Main converter that orchestrates the conversion process
class TagflowConverter {
  /// Create a new converter with optional custom converters
  TagflowConverter([List<ElementConverter>? customConverters]) {
    if (customConverters != null) {
      _customConverters.addAll(customConverters);
    }
    _registerBuiltIns();
  }

  final List<ElementConverter> _customConverters = [];
  final List<ElementConverter> _builtInConverters = [];

  /// Add a custom converter
  void addConverter(ElementConverter converter) {
    _customConverters.add(converter);
  }

  /// Add multiple custom converters
  void addAllConverters(List<ElementConverter> converters) {
    _customConverters.addAll(converters);
  }

  void _registerBuiltIns() {
    _builtInConverters.addAll([
      const ContainerConverter(),
      const TextConverter(),
      const ImgConverter(),
      const CodeConverter(),
      const BlockquoteConverter(),
      const HrConverter(),
    ]);
  }

  /// Convert a TagflowElement to a Widget
  Widget convert(TagflowElement element, BuildContext context) {
    // Try custom converters first
    for (final converter in _customConverters) {
      if (converter.canHandle(element)) {
        log('Using custom converter: $converter');
        return converter.convert(element, context, this);
      }
    }

    // Then try built-in converters
    for (final converter in _builtInConverters) {
      if (converter.canHandle(element)) {
        log('Using built-in converter: $converter');
        return converter.convert(element, context, this);
      }
    }

    // Fallback to default converter
    return const DefaultConverter().convert(element, context, this);
  }

  /// Convert a list of elements to widgets
  List<Widget> convertChildren(
    List<TagflowElement> elements,
    BuildContext context,
  ) {
    return elements.map((e) => convert(e, context)).toList();
  }
}

/// Default fallback converter for unknown elements
class DefaultConverter extends ElementConverter {
  const DefaultConverter();

  @override
  Set<String> get supportedTags => const {};

  @override
  bool canHandle(TagflowElement element) => true;

  @override
  Widget convert(
    TagflowElement element,
    BuildContext context,
    TagflowConverter converter,
  ) {
    if (element.isTextNode) {
      final style = resolveStyle(element, context);
      return Text(
        element.textContent ?? '',
        style: style.textStyle,
        textAlign: style.textAlign,
      );
    }
    return const SizedBox.shrink();
  }
}
