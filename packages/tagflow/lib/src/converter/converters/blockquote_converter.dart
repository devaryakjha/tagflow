import 'package:flutter/material.dart';
import 'package:tagflow/legacy.dart';

/// A converter for the `blockquote` tag.
final class BlockquoteConverter extends ElementConverter<TagflowElement> {
  /// Create a new blockquote converter
  const BlockquoteConverter();

  @override
  Set<String> get supportedTags => {'blockquote', 'q'};

  @override
  Widget convert(
    TagflowElement element,
    BuildContext context,
    TagflowConverter converter,
  ) {
    final style = resolveStyle(element, context);
    final children = converter.convertChildren(element.children, context);

    return StyledContainer(
      style: style,
      tag: element.tag,
      child: children.length == 1
          ? children.first
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: children,
            ),
    );
  }
}

/// Converter for the `footer` of a blockquote.
final class BlockquoteFooterConverter extends ElementConverter<TagflowElement> {
  /// Creates a blockquote footer converter.
  const BlockquoteFooterConverter();

  @override
  Set<String> get supportedTags => {'blockquote footer'};

  @override
  Widget convert(
    TagflowElement element,
    BuildContext context,
    TagflowConverter converter,
  ) {
    final style = resolveStyle(element, context);
    final children = converter.convertChildren(element.children, context);

    return StyledContainer(
      style: style,
      tag: element.tag,
      child: Row(children: [const Text('\u2014'), ...children]),
    );
  }
}
