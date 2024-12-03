import 'package:collection/collection.dart' show MapEquality;
import 'package:flutter/foundation.dart' show immutable;

/// Represents HTML element attributes with type-safe access and validation
@immutable
final class TagflowAttributes {
  /// Creates a new [TagflowAttributes]
  const TagflowAttributes([Map<String, String>? attributes])
      : _attributes = attributes ?? const {};

  final Map<String, String> _attributes;

  /// Returns the value of the 'id' attribute,
  /// or `null` if the attribute is not present
  String? get id => _attributes['id'];

  /// Returns the value of the 'class' attribute,
  /// or `null` if the attribute is not present
  String? get className => _attributes['class'];

  /// Returns the value of the 'style' attribute,
  /// or `null` if the attribute is not present
  String? get style => _attributes['style'];

  /// Returns the value of the attribute with the given [name],
  /// or `null` if the attribute is not present
  String? operator [](String name) => _attributes[name.toLowerCase()];

  /// Returns `true` if the attribute with the given [name] is present
  bool contains(String name) => _attributes.containsKey(name.toLowerCase());

  /// Merges two attribute collections, with the newer values taking precedence
  TagflowAttributes merge(TagflowAttributes other) {
    return TagflowAttributes(Map.of(_attributes)..addAll(other._attributes));
  }

  /// Parses space-separated class names into a list
  List<String> get classList =>
      className?.split(' ').where((c) => c.isNotEmpty).toList() ?? [];

  /// Checks if element has a specific class
  bool hasClass(String className) => classList.contains(className);

  /// Creates a new instance with modified attributes
  TagflowAttributes copyWith({Map<String, String>? attributes}) {
    return TagflowAttributes({
      ..._attributes,
      ...?attributes,
    });
  }

  /// Validates common attribute patterns and throws if invalid
  void validate() {
    if (id != null && !RegExp(r'^[a-zA-Z][a-zA-Z0-9_-]*$').hasMatch(id!)) {
      throw FormatException('Invalid ID format: $id');
    }
  }

  @override
  String toString() =>
      _attributes.entries.map((e) => '${e.key}="${e.value}"').join(' ');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TagflowAttributes &&
          const MapEquality<String, String>()
              .equals(_attributes, other._attributes);

  @override
  int get hashCode => const MapEquality<String, String>().hash(_attributes);
}
