import 'package:flutter/widgets.dart';
import 'package:tagflow/tagflow.dart';

/// Converter for text elements
class TextConverter extends ElementConverter {
  /// Create a new text converter
  const TextConverter();

  @override
  Set<String> get supportedTags => {
        'p',
        'span',
        'strong',
        'em',
        'i',
        'b',
        '#text',
        'h1',
        'h2',
        'h3',
        'h4',
        'h5',
        'h6',
        'a',
      };

  @override
  Widget convert(
    TagflowElement element,
    BuildContext context,
    TagflowConverter converter,
  ) {
    final children = _convertChildren(element, context, converter);
    return Text.rich(
      key: createUniqueKey(),
      TextSpan(text: element.textContent, children: children),
      style: getTextStyle(element),
    );
  }

  List<InlineSpan> _convertChildren(
    TagflowElement element,
    BuildContext context,
    TagflowConverter converter,
  ) {
    return element.children.map((child) {
      // create a text span for text nodes
      if (child.isTextNode) {
        return TextSpan(
          text: child.textContent,
          style: getTextStyle(child),
        );
      } else {
        // create a widget span for non-text nodes
        if (canHandle(child)) {
          return TextSpan(
            children: _convertChildren(child, context, converter),
            style: getTextStyle(child),
          );
        }
        return WidgetSpan(
          child: converter.convert(child, context),
          style: getTextStyle(child),
          alignment: PlaceholderAlignment.middle,
        );
      }
    }).toList();
  }

  /// Get the text style for a given element
  TextStyle? getTextStyle(TagflowElement element) => switch (element.tag) {
        'em' || 'i' => const TextStyle(fontStyle: FontStyle.italic),
        'strong' || 'b' => const TextStyle(fontWeight: FontWeight.bold),
        'h1' => const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        'h2' => const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        'h3' => const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        'h4' => const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        'h5' => const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        'h6' => const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        _ => null,
      };
}
