// lib/src/converter/converter.dart
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:nanoid/non_secure.dart';
import 'package:tagflow/tagflow.dart';

/// Base interface for element converters
abstract class ElementConverter {
  /// Create a new element converter
  const ElementConverter();

  /// Supported tags for this converter
  Set<String> get supportedTags => {};

  /// Whether this converter can handle the given element
  bool canHandle(TagflowElement element) => supportedTags.contains(element.tag);

  /// Convert the element to a widget
  Widget convert(
    TagflowElement element,
    BuildContext context,
    TagflowConverter converter,
  );

  /// Create a unique key for the given element
  /// can be used to identify elements in a list
  LocalKey createUniqueKey() {
    return ValueKey(nanoid());
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
