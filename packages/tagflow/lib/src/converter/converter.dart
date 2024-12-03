// lib/src/converter/converter.dart
import 'package:flutter/widgets.dart';
import 'package:tagflow/tagflow.dart';

/// Base interface for element converters
abstract class ElementConverter {
  /// Whether this converter can handle the given element
  bool canHandle(TagflowElement element);

  /// Convert the element to a widget
  Widget convert(
    TagflowElement element,
    BuildContext context,
    TagflowConverter converter,
  );
}

/// Main converter that orchestrates the conversion process
class TagflowConverter {
  /// Create a new converter
  TagflowConverter() {
    // Register built-in converters
    _registerBuiltIns([
      const ContainerConverter(),
      const TextConverter(),
      const HeadingConverter(),
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
class DefaultConverter implements ElementConverter {
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
