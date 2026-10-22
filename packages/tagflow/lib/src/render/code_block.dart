import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:tagflow/src/runtime/document_node.dart';

/// Callback invoked after a code block's source was copied to the clipboard.
typedef TagflowCodeCopyCallback = void Function(TagflowCodeCopyDetails details);

/// Source and context passed to a [TagflowCodeHighlighter].
final class TagflowCodeHighlightRequest {
  /// Creates a highlight request for a code block node.
  const TagflowCodeHighlightRequest({
    required this.node,
    required this.source,
    required this.language,
    required this.style,
  });

  /// The code block node being rendered.
  final TagflowDocumentNode node;

  /// The raw source text of the code block.
  final String source;

  /// The normalized language identifier, such as `dart` for an HTML
  /// `class="language-dart"`, or null when the block has no language.
  final String? language;

  /// The base monospace text style the code block renders with.
  ///
  /// Highlighters should return spans that inherit from this style so the
  /// highlighted block keeps the same font and size as the plain one.
  final TextStyle style;
}

/// Extension point that turns code block source into styled text spans.
///
/// Tagflow core ships without a highlighting dependency. Apps adapt an
/// existing Dart highlighter package by passing a function through
/// [TagflowCodeBlockOptions.highlighter].
///
/// Return null to fall back to the default plain monospace rendering, for
/// example when [TagflowCodeHighlightRequest.language] is not supported.
typedef TagflowCodeHighlighter =
    TextSpan? Function(
      BuildContext context,
      TagflowCodeHighlightRequest request,
    );

/// Details passed to [TagflowCodeCopyCallback].
final class TagflowCodeCopyDetails {
  /// Creates copy details for a code block node.
  const TagflowCodeCopyDetails({
    required this.node,
    required this.source,
    required this.language,
  });

  /// The code block node whose source was copied.
  final TagflowDocumentNode node;

  /// The source text that was written to the clipboard.
  final String source;

  /// The normalized language identifier, or null when the block has none.
  final String? language;
}

/// View-owned options for rendering code block nodes.
final class TagflowCodeBlockOptions extends Equatable {
  /// Creates code block options.
  const TagflowCodeBlockOptions({
    this.highlighter,
    this.showCopyButton = false,
    this.onCopy,
  });

  /// Optional highlighter for code block source.
  ///
  /// When null, code blocks render as plain monospace text.
  final TagflowCodeHighlighter? highlighter;

  /// Whether code blocks show a button that copies their source.
  final bool showCopyButton;

  /// Called after the copy button wrote a code block's source to the
  /// clipboard.
  final TagflowCodeCopyCallback? onCopy;

  /// Create a copy with some properties replaced
  TagflowCodeBlockOptions copyWith({
    TagflowCodeHighlighter? highlighter,
    bool? showCopyButton,
    TagflowCodeCopyCallback? onCopy,
  }) {
    return TagflowCodeBlockOptions(
      highlighter: highlighter ?? this.highlighter,
      showCopyButton: showCopyButton ?? this.showCopyButton,
      onCopy: onCopy ?? this.onCopy,
    );
  }

  /// Returns the normalized language for a code block [language] value.
  ///
  /// HTML-origin code blocks carry the raw `class` attribute, so this picks a
  /// `language-*` or `lang-*` class when present and strips the prefix.
  /// Otherwise the first class token is used.
  static String? normalizeLanguage(String? language) {
    if (language == null) return null;
    final tokens = language
        .split(RegExp(r'\s+'))
        .where((token) => token.isNotEmpty)
        .toList();
    if (tokens.isEmpty) return null;

    for (final token in tokens) {
      for (final prefix in const ['language-', 'lang-']) {
        if (token.startsWith(prefix) && token.length > prefix.length) {
          return token.substring(prefix.length);
        }
      }
    }

    return tokens.first;
  }

  @override
  // coverage:ignore-line
  List<Object?> get props => [highlighter, showCopyButton, onCopy];
}
