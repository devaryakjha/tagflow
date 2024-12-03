import 'package:flutter/widgets.dart';
import 'package:tagflow/tagflow.dart';

/// Converter for text elements
class TextConverter implements ElementConverter {
  /// Create a new text converter
  const TextConverter();

  static const _textTags = {'p', 'span'};

  @override
  bool canHandle(TagflowElement element) =>
      _textTags.contains(element.tag.toLowerCase());

  @override
  Widget convert(
    TagflowElement element,
    BuildContext context,
    TagflowConverter converter,
  ) {
    final children = converter.convertChildren(element.children, context);

    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    // For paragraphs, add padding
    final isParagraph = element.tag.toLowerCase() == 'p';
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );

    return isParagraph
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: content,
          )
        : content;
  }
}
