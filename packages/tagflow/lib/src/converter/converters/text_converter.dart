import 'package:flutter/widgets.dart';
import 'package:tagflow/tagflow.dart';

/// Converts text-based elements (p, h1-h6, span, etc.)
class TextConverter extends ElementConverter {
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
      };

  @override
  Widget convert(
    TagflowElement element,
    BuildContext context,
    TagflowConverter converter,
  ) {
    final style = resolveStyle(element, context);
    final children = converter.convertChildren(element.children, context);

    final textWidget = children.isEmpty
        ? const SizedBox.shrink()
        : children.length == 1
            ? children.first
            : Text.rich(
                TextSpan(
                  children: children
                      .map((child) => TextSpan(text: child.toString()))
                      .toList(),
                ),
                style: style.textStyle,
                textAlign: style.textAlign,
              );

    return StyledContainer(
      style: style,
      tag: element.tag,
      child: textWidget,
    );
  }
}
