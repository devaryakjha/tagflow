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
    // Compute parent properties once before loop (optimization)
    final parentGestures = _getGestures(element, context);
    final parentCursor = _getMouseCursor(element, context);

    final result = <InlineSpan>[];

    for (final child in element.children) {
      if (child.isTextNode) {
        // Text nodes don't need style resolution
        result.add(TextSpan(
          text: child.textContent,
          recognizer: parentGestures,
          mouseCursor: parentCursor,
          style: getTextStyle(child, null, context),
        ));
      } else {
        final resolvedStyle = resolveStyle(child, context);

        if (!canHandle(child) || shouldForceWidgetSpan(child)) {
          // Create a widget span for unsupported elements
          result.add(WidgetSpan(
            child: converter.convert(child, context),
            style: getTextStyle(child, resolvedStyle, context),
            alignment: PlaceholderAlignment.middle,
          ));
        } else {
          // Create a text span for supported elements
          result.add(TextSpan(
            children: _convertChildren(child, context, converter),
            style: getTextStyle(child, resolvedStyle, context),
            // Only add gestures if node contains direct text content
            recognizer:
                (child.textContent ?? '').isNotEmpty ? parentGestures : null,
            mouseCursor: parentCursor,
          ));
        }
      }
    }

    return result;
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
