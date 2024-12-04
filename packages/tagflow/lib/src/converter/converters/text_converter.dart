import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:tagflow/tagflow.dart';

/// Converter for text elements
class TextConverter implements ElementConverter {
  /// Create a new text converter
  const TextConverter();

  static const _textTags = {
    'p',
    'span',
    'strong',
    'em',
    'i',
    'b',
    '#text',
  };

  @override
  bool canHandle(TagflowElement element) =>
      _textTags.contains(element.tag.toLowerCase());

  @override
  Widget convert(
    TagflowElement element,
    BuildContext context,
    TagflowConverter converter,
  ) {
    final spans = _createSpansForText(element);
    return Text.rich(
      TextSpan(
        text: element.textContent,
        children: spans,
      ),
    );
  }

  List<InlineSpan> _createSpansForText(TagflowElement element) {
    return element.children.map(_mapElementToSpan).whereNotNull().toList();
  }

  InlineSpan? _mapElementToSpan(TagflowElement element) {
    final children =
        element.children.map(_mapElementToSpan).whereNotNull().toList();
    return TextSpan(
      text: element.textContent,
      children: children,
      style: _getTextstyle(element),
    );
  }

  TextStyle? _getTextstyle(TagflowElement element) => switch (element.tag) {
        'em' || 'i' => const TextStyle(fontStyle: FontStyle.italic),
        'strong' || 'b' => const TextStyle(fontWeight: FontWeight.bold),
        _ => null,
      };
}
