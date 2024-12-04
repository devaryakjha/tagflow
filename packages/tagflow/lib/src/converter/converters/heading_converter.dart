import 'package:flutter/widgets.dart';
import 'package:tagflow/tagflow.dart';

/// Converter for heading elements
class HeadingConverter extends TextConverter {
  /// Create a new heading converter
  const HeadingConverter();

  @override
  Set<String> get supportedTags => {'h1', 'h2', 'h3', 'h4', 'h5', 'h6'};

  @override
  TextStyle? getTextStyle(TagflowElement element) => switch (element.tag) {
        'h1' => const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        'h2' => const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        'h3' => const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        'h4' => const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        'h5' => const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        'h6' => const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        _ => null,
      };
}
