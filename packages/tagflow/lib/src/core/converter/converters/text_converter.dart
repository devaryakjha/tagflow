import 'package:flutter/widgets.dart';
import 'package:tagflow/tagflow.dart';

/// Converter for text elements
final class TextConverter implements TagflowConverter {
  /// Creates a new text converter
  const TextConverter();
  static const _textTags = {
    'text',
    'p',
    'span',
    'div',
    'h1',
    'h2',
    'h3',
    'h4',
    'h5',
    'h6',
  };

  @override
  bool canHandle(TagflowElement element) {
    return _textTags.contains(element.tag);
  }

  @override
  Widget convert(TagflowElement element, BuildContext context) {
    return Text(_extractText(element));
  }

  String _extractText(TagflowElement element) {
    // Recursively extract text from element and its children
    final buffer = StringBuffer();

    void extract(TagflowElement e) {
      if (e.isTextNode) {
        buffer.write(e.textContent);
      } else {
        for (final child in e.children) {
          extract(child);
        }
      }
    }

    extract(element);
    return buffer.toString();
  }
}
