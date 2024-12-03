import 'package:tagflow/tagflow.dart';

/// ConverterRegistry is a registry for all converters.
class ConverterRegistry {
  /// Creates a new registry with the given converters
  const ConverterRegistry([
    List<TagflowConverter> converters = const [],
  ]) : _converters = converters;

  final List<TagflowConverter> _converters;

  /// Registers a new converter
  void register(TagflowConverter converter) {
    _converters.add(converter);
  }

  /// Unregisters a converter
  void unregister(TagflowConverter converter) {
    _converters.remove(converter);
  }

  /// Returns a list of all registered converters
  void registerAll(List<TagflowConverter> converters) {
    _converters.addAll(converters);
  }

  /// Converts a single element to a widget
  TagflowConverter? findConverter(TagflowElement element) {
    return _converters.firstWhere(
      (converter) => converter.canHandle(element),
      orElse: FallbackConverter.new,
    );
  }
}
