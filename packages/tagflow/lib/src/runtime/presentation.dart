import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

const MapEquality<String, Object?> _presentationHintEquality =
    MapEquality<String, Object?>();
const SetEquality<TagflowInlineSemantic> _inlineSemanticEquality =
    SetEquality<TagflowInlineSemantic>();

/// Source-agnostic inline text semantics that affect presentation.
enum TagflowInlineSemantic {
  /// Strong importance, commonly rendered with heavier font weight.
  strong,

  /// Emphasized text, commonly rendered with italic style.
  emphasis,

  /// Underlined text.
  underline,

  /// Deleted text, commonly rendered with a line-through decoration.
  deleted,

  /// Highlighted or marked text.
  highlight,

  /// Smaller secondary inline text.
  small,

  /// Subscript text.
  subscript,

  /// Superscript text.
  superscript,
}

/// Immutable presentation hints carried by adapters into the runtime layer.
@immutable
final class TagflowPresentation {
  /// Creates a new immutable presentation container.
  TagflowPresentation({
    this.variant,
    this.width,
    this.height,
    Set<TagflowInlineSemantic> inlineSemantics = const {},
    Map<String, Object?> hints = const {},
  }) : inlineSemantics = Set.unmodifiable(inlineSemantics),
       hints = Map.unmodifiable(hints);

  /// Shared empty presentation.
  static final TagflowPresentation empty = TagflowPresentation();

  /// Optional presentation variant name such as `display` or `body`.
  final String? variant;

  /// Suggested presentation width.
  final double? width;

  /// Suggested presentation height.
  final double? height;

  /// Source-agnostic inline text semantics.
  final Set<TagflowInlineSemantic> inlineSemantics;

  /// Adapter-specific normalized hints.
  final Map<String, Object?> hints;

  /// Returns true when no explicit hints are stored.
  bool get isEmpty =>
      variant == null &&
      width == null &&
      height == null &&
      inlineSemantics.isEmpty &&
      hints.isEmpty;

  /// Merges [other] over this presentation container.
  TagflowPresentation merge(TagflowPresentation other) {
    if (other.isEmpty) return this;
    if (isEmpty) return other;
    return TagflowPresentation(
      variant: other.variant ?? variant,
      width: other.width ?? width,
      height: other.height ?? height,
      inlineSemantics: {...inlineSemantics, ...other.inlineSemantics},
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
            _inlineSemanticEquality.equals(
              other.inlineSemantics,
              inlineSemantics,
            ) &&
            _presentationHintEquality.equals(hints, other.hints);
  }

  @override
  int get hashCode => Object.hash(
    variant,
    width,
    height,
    _inlineSemanticEquality.hash(inlineSemantics),
    _presentationHintEquality.hash(hints),
  );
}
