import 'package:flutter/widgets.dart';
import 'package:tagflow/tagflow.dart';

/// Converter for container elements
class ContainerConverter implements ElementConverter {
  /// Create a new container converter
  const ContainerConverter();

  static const _containerTags = {'div', 'section', 'article'};

  @override
  bool canHandle(TagflowElement element) =>
      _containerTags.contains(element.tag.toLowerCase());

  @override
  Widget convert(
    TagflowElement element,
    BuildContext context,
    TagflowConverter converter,
  ) {
    final children = converter.convertChildren(element.children, context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}
