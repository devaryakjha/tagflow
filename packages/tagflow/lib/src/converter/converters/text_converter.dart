import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:tagflow/tagflow.dart';

/// Converter for text elements
///
/// This converter is responsible for converting text elements into a
/// [SelectableText.rich] widget.
///
/// It handles the conversion of text nodes and inline elements, including
/// handling of gestures and widget spans for styled elements.
final class TextConverter extends ElementConverter {
  /// Create a new text converter
  const TextConverter();

  // Static set for O(1) lookup
  static const _supportedTags = {
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
    'u',
    's',
    'small',
    'mark',
    'del',
    'ins',
    'sub',
    'sup',
  };

  @override
  Set<String> get supportedTags => _supportedTags;

  // Optimized container wrapping with early return
  Widget _wrapInStyledContainer(
    Widget child,
    TagflowElement element,
    BuildContext context,
    TagflowStyle style,
  ) =>
      element.isTextNode
          ? child
          : StyledContainer(
              style: style,
              tag: element.tag,
              width: element.width,
              height: element.height,
              child: child,
            );

  @override
  Widget convert(
    TagflowElement element,
    BuildContext context,
    TagflowConverter converter,
  ) {
    final style = resolveStyle(element, context);
    final children = _convertChildren(element, context, converter, style);

    // Fast path for single WidgetSpan
    if (children.length == 1 && children.first is WidgetSpan) {
      return _wrapInStyledContainer(
        (children.first as WidgetSpan).child,
        element,
        context,
        style,
      );
    }

    return _wrapInStyledContainer(
      SelectableText.rich(
        TextSpan(
          text: element.textContent,
          children: children,
          recognizer: _getGestures(element, context),
          mouseCursor: (element.parent?.isAnchor ?? false)
              ? SystemMouseCursors.click
              : null,
        ),
      ),
      element,
      context,
      style,
    );
  }

  // Cached style check for widget span requirement
  static bool _needsWidgetSpan(ElementStyle? style) =>
      style != null &&
      (style.padding != null ||
          style.margin != null ||
          style.decoration != null ||
          style.alignment != null);

  List<InlineSpan> _convertChildren(
    TagflowElement element,
    BuildContext context,
    TagflowConverter converter,
    TagflowStyle resolvedStyle,
  ) =>
      element.children.map((child) {
        // Fast paths for common cases
        if (child.isBreak) return const TextSpan(text: '\n');

        final elementStyle = resolvedStyle.getElementStyle(child.tag);
        final textStyle = child.isTextNode ? null : elementStyle?.textStyle;

        // Widget span path for styled elements
        if (_needsWidgetSpan(elementStyle)) {
          return WidgetSpan(
            child: converter.convert(child, context),
            style: textStyle,
            alignment: PlaceholderAlignment.middle,
          );
        }

        // Text node path
        if (child.isTextNode) {
          return TextSpan(
            text: child.textContent,
            style: textStyle,
            recognizer: _getGestures(child, context),
            mouseCursor: child.parent?.isAnchor ?? false
                ? SystemMouseCursors.click
                : null,
          );
        }

        // Handle supported text elements
        return canHandle(child)
            ? TextSpan(
                children:
                    _convertChildren(child, context, converter, resolvedStyle),
                style: textStyle,
                recognizer: _getGestures(child, context),
                mouseCursor: child.parent?.isAnchor ?? false
                    ? SystemMouseCursors.click
                    : null,
              )
            : WidgetSpan(
                child: converter.convert(child, context),
                style: textStyle,
                alignment: PlaceholderAlignment.middle,
              );
      }).toList();

  // Simplified gesture handling
  GestureRecognizer? _getGestures(
    TagflowElement element,
    BuildContext context,
  ) =>
      element.parent?.isAnchor ?? false
          ? (TapGestureRecognizer()
            ..onTap = Feedback.wrapForTap(
              () {
                final options = TagflowOptions.of(context);
                options.linkTapCallback?.call(
                  element.parentHref ?? '',
                  element.attributes,
                );
              },
              context,
            ))
          : null;
}
