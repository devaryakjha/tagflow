import 'package:flutter/widgets.dart';
import 'package:tagflow/tagflow.dart';

/// A converter for the `code` tag.
final class BasicCodeConverter extends ElementConverter {
  /// Create a new basic code converter
  const BasicCodeConverter();

  @override
  Set<String> get supportedTags => {'code'};

  @override
  Widget convert(
    TagflowElement element,
    BuildContext context,
    TagflowConverter converter,
  ) {
    final children = converter.convertChildren(element.children, context);
    final style = resolveStyle(element, context);
    return StyledContainer(
      key: createUniqueKey(),
      style: style,
      tag: element.tag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}
