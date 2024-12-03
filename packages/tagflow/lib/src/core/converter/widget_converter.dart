import 'package:flutter/widgets.dart';
import 'package:tagflow/tagflow.dart';

/// Main converter for converting TagflowElements to widgets
final class WidgetConverter implements TagflowConverter {
  /// Creates a new converter with the given registry
  const WidgetConverter({
    ConverterRegistry? registery,
  }) : registery = registery ?? const ConverterRegistry();

  /// The registry for all converters
  final ConverterRegistry registery;

  @override
  bool canHandle(TagflowElement element) {
    return true;
  }

  @override
  Widget convert(TagflowElement element, BuildContext context) {
    final converter = registery.findConverter(element);
    return converter?.convert(element, context) ?? const SizedBox.shrink();
  }

  /// Converts a list of elements to widgets
  List<Widget> convertAll(List<TagflowElement> elements, BuildContext context) {
    return elements.map((element) => convert(element, context)).toList();
  }
}
