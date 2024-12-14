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
        'pre',
        'br',
      };

  Widget _wrapInContainerIfNeeded(
    Widget child,
    TagflowElement element,
    BuildContext context,
    TagflowStyle style,
  ) {
    // text nodes are already wrapped,
    // wrapping them again will break the text style
    if (element.isTextNode) return child;

    return StyledContainer(
      style: style,
      tag: element.tag,
      child: child,
    );
  }

  @override
  Widget convert(
    TagflowElement element,
    BuildContext context,
    TagflowConverter converter,
  ) {
    final style = resolveStyle(element, context);
    final children = _convertChildren(element, context, converter, style);

    // reduce the number of widgets if possible
    if (children.length == 1) {
      final child = children.first;
      if (child is TextSpan) {
        return KeyedSubtree(
          child: _wrapInContainerIfNeeded(
            Text(
              child.toPlainText(),
              softWrap: true,
            ),
            element,
            context,
            style,
          ),
        );
      }
      if (child is WidgetSpan) {
        return KeyedSubtree(
          child: _wrapInContainerIfNeeded(
            child.child,
            element,
            context,
            style,
          ),
        );
      }
    }

    return KeyedSubtree(
      child: _wrapInContainerIfNeeded(
        Text.rich(
          TextSpan(
            text: element.textContent,
            children: children,
            recognizer: _getGestures(element, context),
            mouseCursor: _getMouseCursor(element, context),
          ),
          softWrap: true,
        ),
        element,
        context,
        style,
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
      if (child.isBreak) {
        return const TextSpan(text: '\n');
      }
      // create a text span for text nodes
      if (child.isTextNode) {
        return TextSpan(
          text: child.textContent,
          style: _getTextStyle(child, resolvedStyle),
          recognizer: _getGestures(child, context),
          mouseCursor: _getMouseCursor(child, context),
        );
      } else {
        // create a text span for supported elements
        if (canHandle(child)) {
          return TextSpan(
            children:
                _convertChildren(child, context, converter, resolvedStyle),
            style: _getTextStyle(child, resolvedStyle),
            recognizer: _getGestures(child, context),
            mouseCursor: _getMouseCursor(child, context),
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

  MouseCursor? _getMouseCursor(
    TagflowElement element,
    BuildContext context,
  ) =>
      switch (element.parentTag) {
        'a' => SystemMouseCursors.click,
        _ => null,
      };

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
    if (element.tag == '#text') {
      return null;
    }
    return resolvedStyle.getElementStyle(element.tag)?.textStyle;
  }
}
