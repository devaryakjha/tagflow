import 'package:flutter/material.dart';
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
    final el =
        element.children.first; // since code will always have a single child
    final child = converter.convert(el, context);
    var style = resolveStyle(element, context);

    // remove background color if the parent is pre
    if (element.parentTag == 'pre') {
      style = style.copyWith(backgroundColor: Colors.transparent);
    }

    return StyledContainer(
      style: style,
      tag: element.tag,
      child: child,
    );
  }
}
