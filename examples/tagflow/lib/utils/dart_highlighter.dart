import 'package:flutter/material.dart';
import 'package:tagflow/tagflow.dart';

const _keywords = {
  'abstract', 'as', 'async', 'await', 'break', 'case', 'catch', 'class', //
  'const', 'continue', 'default', 'else', 'enum', 'extends', 'false',
  'final', 'for', 'if', 'implements', 'import', 'in', 'is', 'late', 'new',
  'null', 'required', 'return', 'static', 'super', 'switch', 'this',
  'throw', 'true', 'try', 'var', 'void', 'while', 'with', 'yield',
};

final _token = RegExp(
  r'(?<comment>//[^\n]*|/\*[\s\S]*?\*/)'
  r"|(?<string>'(?:[^'\\\n]|\\.)*'|"
  r'"(?:[^"\\\n]|\\.)*")'
  r'|(?<number>\b\d+(?:\.\d+)?\b)'
  r'|(?<word>\b[A-Za-z_]\w*\b)',
);

/// A small regex highlighter for Dart, written for the gallery.
///
/// Tagflow core ships without a highlighting dependency, so apps adapt a
/// package such as `highlight` or `syntax_highlight` the same way: map the
/// request source to spans that inherit `request.style`. This one returns
/// null for other languages, which keeps the plain rendering.
TextSpan? highlightDart(
  BuildContext context,
  TagflowCodeHighlightRequest request,
) {
  if (request.language != 'dart') return null;

  final colors = Theme.of(context).colorScheme;
  final dark = Theme.of(context).brightness == Brightness.dark;
  final comment = request.style.copyWith(
    color: colors.onSurfaceVariant,
    fontStyle: FontStyle.italic,
  );
  final string = request.style.copyWith(
    color: dark ? const Color(0xFF9CCC65) : const Color(0xFF2E7D32),
  );
  final number = request.style.copyWith(
    color: dark ? const Color(0xFFFFB74D) : const Color(0xFFB45309),
  );
  final keyword = request.style.copyWith(
    color: colors.primary,
    fontWeight: FontWeight.w600,
  );
  final type = request.style.copyWith(color: colors.tertiary);

  final source = request.source;
  final spans = <TextSpan>[];
  var start = 0;
  for (final match in _token.allMatches(source)) {
    if (match.start > start) {
      spans.add(TextSpan(text: source.substring(start, match.start)));
    }
    final text = match.group(0)!;
    final word = match.namedGroup('word');
    final style = match.namedGroup('comment') != null
        ? comment
        : match.namedGroup('string') != null
        ? string
        : match.namedGroup('number') != null
        ? number
        : _keywords.contains(word)
        ? keyword
        : word != null && word.startsWith(RegExp('[A-Z]'))
        ? type
        : null;
    spans.add(TextSpan(text: text, style: style));
    start = match.end;
  }
  if (start < source.length) {
    spans.add(TextSpan(text: source.substring(start)));
  }
  return TextSpan(style: request.style, children: spans);
}
