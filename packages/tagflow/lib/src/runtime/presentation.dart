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

  /// Code-like text, such as keyboard input or sample program output,
  /// commonly rendered in the inline code style.
  code,
}

/// How a node takes part in layout.
///
/// Most node kinds have a fixed display: paragraphs are blocks and text is
/// inline. Containers and unsupported nodes use [TagflowPresentation.display]
/// to say which one they are; `null` means block, unless the node carries
/// inline semantics.
enum TagflowDisplay {
  /// The node starts on its own line and stacks with its siblings.
  block,

  /// The node flows with surrounding text, like a `<span>`.
  inline,
}

/// Horizontal text alignment requested by the source content.
enum TagflowTextAlign {
  /// Align to the start edge for the text direction.
  start,

  /// Align to the end edge for the text direction.
  end,

  /// Align to the left edge.
  left,

  /// Align to the right edge.
  right,

  /// Center the text.
  center,

  /// Stretch lines to fill the width.
  justify,
}

/// Text decoration lines requested by the source content.
enum TagflowTextDecoration {
  /// A line below the text.
  underline,

  /// A line above the text.
  overline,

  /// A line through the text.
  lineThrough,
}

/// A small, safe set of text styling carried from the source content, such
/// as the inline `style` attribute of an HTML element.
///
/// Values are plain Dart so the document model stays independent of
/// Flutter. The built-in components turn them into a `TextStyle`.
@immutable
final class TagflowInlineStyle {
  /// Creates inline styling. Every field is optional.
  TagflowInlineStyle({
    this.color,
    this.backgroundColor,
    this.textAlign,
    this.fontWeight,
    this.italic,
    Set<TagflowTextDecoration>? decorations,
    this.fontSize,
    this.fontSizeFactor,
  }) : decorations = decorations == null ? null : Set.unmodifiable(decorations);

  /// Text colour as a 32-bit ARGB value (`0xAARRGGBB`).
  final int? color;

  /// Background colour as a 32-bit ARGB value (`0xAARRGGBB`).
  final int? backgroundColor;

  /// Horizontal text alignment.
  final TagflowTextAlign? textAlign;

  /// Font weight from 100 to 900.
  final int? fontWeight;

  /// Whether the text is italic (`true`) or explicitly upright (`false`).
  final bool? italic;

  /// Decoration lines. An empty set means `text-decoration: none`.
  final Set<TagflowTextDecoration>? decorations;

  /// Absolute font size in logical pixels.
  final double? fontSize;

  /// Font size relative to the surrounding text, such as `1.5` for `1.5em`.
  /// Ignored when [fontSize] is set.
  final double? fontSizeFactor;

  /// Whether no field is set.
  bool get isEmpty =>
      color == null &&
      backgroundColor == null &&
      textAlign == null &&
      fontWeight == null &&
      italic == null &&
      decorations == null &&
      fontSize == null &&
      fontSizeFactor == null;

  /// Returns a copy with the set fields of [other] applied over this one.
  TagflowInlineStyle merge(TagflowInlineStyle? other) {
    if (other == null || other.isEmpty) return this;
    if (isEmpty) return other;
    return TagflowInlineStyle(
      color: other.color ?? color,
      backgroundColor: other.backgroundColor ?? backgroundColor,
      textAlign: other.textAlign ?? textAlign,
      fontWeight: other.fontWeight ?? fontWeight,
      italic: other.italic ?? italic,
      decorations: other.decorations ?? decorations,
      fontSize:
          other.fontSize ?? (other.fontSizeFactor == null ? fontSize : null),
      fontSizeFactor: other.fontSizeFactor ?? fontSizeFactor,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TagflowInlineStyle &&
            other.color == color &&
            other.backgroundColor == backgroundColor &&
            other.textAlign == textAlign &&
            other.fontWeight == fontWeight &&
            other.italic == italic &&
            const SetEquality<TagflowTextDecoration>().equals(
              other.decorations,
              decorations,
            ) &&
            other.fontSize == fontSize &&
            other.fontSizeFactor == fontSizeFactor;
  }

  @override
  int get hashCode => Object.hash(
    color,
    backgroundColor,
    textAlign,
    fontWeight,
    italic,
    const SetEquality<TagflowTextDecoration>().hash(decorations),
    fontSize,
    fontSizeFactor,
  );
}

/// Immutable presentation hints carried by adapters into the runtime layer.
@immutable
final class TagflowPresentation {
  /// Creates a new immutable presentation container.
  TagflowPresentation({
    this.variant,
    this.width,
    this.height,
    this.display,
    Set<TagflowInlineSemantic> inlineSemantics = const {},
    this.inlineStyle,
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

  /// Whether the node is laid out as a block or inline.
  ///
  /// `null` keeps the default for the node kind. See [TagflowDisplay].
  final TagflowDisplay? display;

  /// Source-agnostic inline text semantics.
  final Set<TagflowInlineSemantic> inlineSemantics;

  /// Text styling carried from the source, such as safe inline CSS.
  final TagflowInlineStyle? inlineStyle;

  /// Adapter-specific normalized hints.
  final Map<String, Object?> hints;

  /// Returns true when no explicit hints are stored.
  bool get isEmpty =>
      variant == null &&
      width == null &&
      height == null &&
      display == null &&
      inlineSemantics.isEmpty &&
      (inlineStyle?.isEmpty ?? true) &&
      hints.isEmpty;

  /// Merges [other] over this presentation container.
  TagflowPresentation merge(TagflowPresentation other) {
    if (other.isEmpty) return this;
    if (isEmpty) return other;
    return TagflowPresentation(
      variant: other.variant ?? variant,
      width: other.width ?? width,
      height: other.height ?? height,
      display: other.display ?? display,
      inlineSemantics: {...inlineSemantics, ...other.inlineSemantics},
      inlineStyle: inlineStyle?.merge(other.inlineStyle) ?? other.inlineStyle,
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
            other.display == display &&
            _inlineSemanticEquality.equals(
              other.inlineSemantics,
              inlineSemantics,
            ) &&
            other.inlineStyle == inlineStyle &&
            _presentationHintEquality.equals(hints, other.hints);
  }

  @override
  int get hashCode => Object.hash(
    variant,
    width,
    height,
    display,
    _inlineSemanticEquality.hash(inlineSemantics),
    inlineStyle,
    _presentationHintEquality.hash(hints),
  );
}
