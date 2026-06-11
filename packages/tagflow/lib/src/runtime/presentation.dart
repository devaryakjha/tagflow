import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

const MapEquality<String, Object?> _presentationHintEquality =
    MapEquality<String, Object?>();

/// Immutable presentation hints carried by adapters into the runtime layer.
@immutable
final class TagflowPresentation {
  /// Creates a new immutable presentation container.
  TagflowPresentation({
    this.variant,
    this.width,
    this.height,
    Map<String, Object?> hints = const {},
  }) : hints = Map.unmodifiable(hints);

  /// Shared empty presentation.
  static final TagflowPresentation empty = TagflowPresentation();

  /// Optional presentation variant name such as `display` or `body`.
  final String? variant;

  /// Suggested presentation width.
  final double? width;

  /// Suggested presentation height.
  final double? height;

  /// Adapter-specific normalized hints.
  final Map<String, Object?> hints;

  /// Returns true when no explicit hints are stored.
  bool get isEmpty =>
      variant == null && width == null && height == null && hints.isEmpty;

  /// Merges [other] over this presentation container.
  TagflowPresentation merge(TagflowPresentation other) {
    if (other.isEmpty) return this;
    if (isEmpty) return other;
    return TagflowPresentation(
      variant: other.variant ?? variant,
      width: other.width ?? width,
      height: other.height ?? height,
      hints: {...hints, ...other.hints},
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TagflowPresentation &&
            other.variant == variant &&
            other.width == width &&
            other.height == height &&
            _presentationHintEquality.equals(hints, other.hints);
  }

  @override
  int get hashCode => Object.hash(
    variant,
    width,
    height,
    _presentationHintEquality.hash(hints),
  );
}
