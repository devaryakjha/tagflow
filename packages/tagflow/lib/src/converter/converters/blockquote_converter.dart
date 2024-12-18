import 'package:flutter/widgets.dart';
import 'package:tagflow/tagflow.dart';

/// A converter for the `blockquote` tag.
final class BlockquoteConverter extends ElementConverter {
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
    final child = converter.convert(element.children.first, context);

    return StyledContainer(
      style: style,
      tag: element.tag,
      child: child,
    );
  }
}
