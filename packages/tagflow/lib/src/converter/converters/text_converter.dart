import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:tagflow/tagflow.dart';

/// Converter for text elements
final class TextConverter extends ElementConverter {
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
    final style = resolveStyle(element, context);
    final children = _convertChildren(element, context, converter, style);

    return StyledContainerWidget(
      style: style,
      tag: element.tag,
      key: createUniqueKey(),
      child: Text.rich(
        TextSpan(
          text: element.textContent,
          children: children,
          recognizer: _getGestures(element, context),
          style: style.textStyle,
        ),
      ),
    );
  }

  List<InlineSpan> _convertChildren(
    TagflowElement element,
    BuildContext context,
    TagflowConverter converter,
    TagflowStyle resolvedStyle,
  ) {
    return element.children.map((child) {
      // create a text span for text nodes
      if (child.isTextNode) {
        return TextSpan(
          text: child.textContent,
          style: _getTextStyle(child, resolvedStyle),
          recognizer: _getGestures(child, context),
        );
      } else {
        // create a text span for supported elements
        if (canHandle(child)) {
          return TextSpan(
            children:
                _convertChildren(child, context, converter, resolvedStyle),
            style: _getTextStyle(child, resolvedStyle),
            recognizer: _getGestures(child, context),
          );
        }

        // create a widget span for unsupported elements
        return WidgetSpan(
          child: converter.convert(child, context),
          style: _getTextStyle(child, resolvedStyle),
          alignment: PlaceholderAlignment.middle,
        );
      }
    }).toList();
  }

  GestureRecognizer? _getGestures(
    TagflowElement element,
    BuildContext context,
  ) =>
      switch (element.parentTag) {
        'a' => TapGestureRecognizer()
          ..onTap = Feedback.wrapForTap(
            () {
              final link = element.parentHref;
              final options = TagflowOptions.of(context);
              final cb = options.linkTapCallback;
              if (cb != null && link != null) {
                cb(link, element.attributes);
              }
            },
            context,
          ),
        _ => null,
      };

  /// Get the text style for a given element
  TextStyle? _getTextStyle(
    TagflowElement element,
    TagflowStyle resolvedStyle,
  ) {
    return resolvedStyle.getElementStyle(element.tag)?.textStyle;
  }
}
