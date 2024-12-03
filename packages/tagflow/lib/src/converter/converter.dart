// lib/src/converter/converter.dart
import 'package:flutter/widgets.dart';
import 'package:tagflow/src/core/models/element.dart';

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
  final List<ElementConverter> _converters = [];

  /// Register a new converter
  void register(ElementConverter converter) {
    _converters.add(converter);
  }

  /// Convert a TagflowElement to a Widget
  Widget convert(TagflowElement element, BuildContext context) {
    // Find appropriate converter
    final converter = _converters.firstWhere(
      (conv) => conv.canHandle(element),
      orElse: DefaultConverter.new,
    );

    // Convert using the found converter, passing this converter instance
    return converter.convert(element, context, this);
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
