import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

const MapEquality<String, Object?> _metadataEquality =
    MapEquality<String, Object?>();

/// Immutable metadata attached to documents, nodes, or source records.
@immutable
final class TagflowMetadata {
  /// Creates a new immutable metadata container.
  TagflowMetadata([Map<String, Object?> values = const {}])
    : values = Map.unmodifiable(values);

  /// An empty metadata container.
  static final TagflowMetadata empty = TagflowMetadata();

  /// Stored metadata values.
  final Map<String, Object?> values;

  /// Reads a metadata value by [key].
  Object? operator [](String key) => values[key];

  /// Returns true when there are no metadata entries.
  bool get isEmpty => values.isEmpty;

  /// Returns a new container with [other] overriding matching keys.
  TagflowMetadata merge(TagflowMetadata other) {
    if (other.isEmpty) return this;
    if (isEmpty) return other;
    return TagflowMetadata({...values, ...other.values});
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TagflowMetadata &&
            _metadataEquality.equals(values, other.values);
  }

  @override
  int get hashCode => _metadataEquality.hash(values);
}
