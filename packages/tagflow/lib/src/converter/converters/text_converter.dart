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
        'h1',
        'h2',
        'h3',
        'h4',
        'h5',
        'h6',
        'span',
        'strong',
        'em',
        'u',
        's',
        'small',
        'mark',
        'del',
        'ins',
        'sub',
        'sup',
        'a',
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
    final children = _convertChildren(element, context, converter);

    return _wrapInContainerIfNeeded(
      Text.rich(
        TextSpan(
          text: element.textContent,
          children: children,
          recognizer: _getGestures(element, context),
          mouseCursor: _getMouseCursor(element, context),
        ),
        textScaler: _getTextScaler(style),
      ),
      element,
      context,
      style,
    );
  }

  List<InlineSpan> _convertChildren(
    TagflowElement element,
    BuildContext context,
    TagflowConverter converter,
  ) {
    return element.children.map((child) {
      final resolvedStyle =
          child.isTextNode ? null : resolveStyle(child, context);
      // create a text span for text nodes
      if (child.isTextNode) {
        return TextSpan(
          text: child.textContent,
          recognizer: _getGestures(child, context),
          mouseCursor: _getMouseCursor(child, context),
        );
      } else {
        if (!canHandle(child) || child.tag == 'sub' || child.tag == 'sup') {
          // create a widget span for unsupported elements
          return WidgetSpan(
            child: converter.convert(child, context),
            alignment: PlaceholderAlignment.middle,
          );
        }

        // create a text span for supported elements
        return TextSpan(
          children: _convertChildren(child, context, converter),
          style: _getTextStyle(child, resolvedStyle),
          recognizer: _getGestures(child, context),
          mouseCursor: _getMouseCursor(child, context),
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

  TextScaler? _getTextScaler(TagflowStyle style) {
    return style.textScaleFactor != null
        ? TextScaler.linear(style.textScaleFactor!)
        : null;
  }

  /// Get the text style for a given element
  TextStyle? _getTextStyle(
    TagflowElement element,
    TagflowStyle? resolvedStyle,
  ) {
    if (element.tag == '#text') {
      return null;
    }
    return resolvedStyle?.textStyle;
  }
}
