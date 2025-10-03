import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:tagflow/tagflow.dart';

/// Converter for text elements
class TextConverter extends ElementConverter<TagflowElement> {
  /// Create a new text converter
  const TextConverter();

  @override
  Set<String> get supportedTags => {
    'p',
    'font',
    'h1',
    'h2',
    'h3',
    'h4',
    'h5',
    'h6',
    'span',
    'strong',
    'b',
    'em',
    'i',
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
    TagflowNode element,
    BuildContext context,
    TagflowStyle style,
  ) {
    // text nodes are already wrapped,
    // wrapping them again will break the text style
    if (element.isTextNode) return child;

    return StyledContainer(style: style, tag: element.tag, child: child);
  }

  @override
  Widget convert(
    TagflowElement element,
    BuildContext context,
    TagflowConverter converter,
  ) {
    final style = resolveStyle(element, context);
    final children = _convertChildren(element, context, converter);
    final prefix = getPrefix(element);
    final suffix = getSuffix(element);
    return _wrapInContainerIfNeeded(
      Text.rich(
        TextSpan(
          text: element.textContent,
          children: [
            if (prefix != null) prefix,
            ...children,
            if (suffix != null) suffix,
          ],
          recognizer: _getGestures(element, context),
          mouseCursor: _getMouseCursor(element, context),
        ),
        style: getTextStyle(element, style, context),
        softWrap: style.softWrap,
        maxLines: style.maxTextLines,
      ),
      element,
      context,
      style,
    );
  }

  /// Get the prefix for a given element
  InlineSpan? getPrefix(TagflowElement element) {
    return null;
  }

  /// Get the suffix for a given element
  InlineSpan? getSuffix(TagflowElement element) {
    return null;
  }

  bool shouldForceWidgetSpan(TagflowNode element) {
    return ['sub', 'sup', 'mark'].contains(element.tag);
  }

  List<InlineSpan> _convertChildren(
    TagflowNode element,
    BuildContext context,
    TagflowConverter converter,
  ) {
    return element.children.map((child) {
      final resolvedStyle =
          child.isTextNode ? null : resolveStyle(child, context);

      // Get parent gestures and cursor if the parent is an interactive element
      final parentGestures = _getGestures(element, context);
      final parentCursor = _getMouseCursor(element, context);

      // create a text span for text nodes
      if (child.isTextNode) {
        return TextSpan(
          text: child.textContent,
          // Use parent gestures for text nodes if available
          recognizer: parentGestures ?? _getGestures(child, context),
          mouseCursor: parentCursor ?? _getMouseCursor(child, context),
          style: getTextStyle(child, resolvedStyle, context),
        );
      } else {
        if (!canHandle(child) || shouldForceWidgetSpan(child)) {
          // create a widget span for unsupported elements
          return WidgetSpan(
            child: converter.convert(child, context),
            style: getTextStyle(child, resolvedStyle, context),
            alignment: PlaceholderAlignment.middle,
          );
        }

        // create a text span for supported elements
        return TextSpan(
          children: _convertChildren(child, context, converter),
          style: getTextStyle(child, resolvedStyle, context),
          // Only add gestures if this node contains direct text content
          recognizer:
              (child.textContent ?? '').isNotEmpty
                  ? (parentGestures ?? _getGestures(child, context))
                  : null,
          mouseCursor: parentCursor ?? _getMouseCursor(child, context),
        );
      }
    }).toList();
  }

  MouseCursor? _getMouseCursor(TagflowNode element, BuildContext context) =>
      switch (element.parentTag) {
        'a' => SystemMouseCursors.click,
        _ => null,
      };

  GestureRecognizer? _getGestures(TagflowNode element, BuildContext context) =>
      switch (element.parentTag) {
        'a' =>
          TapGestureRecognizer()
            ..onTap = Feedback.wrapForTap(() {
              final link = element.parentHref;
              final options = TagflowOptions.of(context);
              final cb = options.linkTapCallback;
              if (cb != null && link != null) {
                cb(link, element.attributes);
              }
            }, context),
        _ => null,
      };

  /// Get the text style for a given element
  TextStyle? getTextStyle(
    TagflowNode element,
    TagflowStyle? resolvedStyle,
    BuildContext context,
  ) {
    if (element.isTextNode) {
      return null;
    }
    var textStyle = resolvedStyle?.textStyleWithColor;

    // Apply text scale factor directly to fontSize to avoid compounding
    // in nested elements
    if (resolvedStyle?.textScaleFactor != null && textStyle != null) {
      final currentFontSize =
          textStyle.fontSize ??
          DefaultTextStyle.of(context).style.fontSize ??
          14.0;
      textStyle = textStyle.copyWith(
        fontSize: currentFontSize * resolvedStyle!.textScaleFactor!,
      );
    }

    return textStyle;
  }
}
