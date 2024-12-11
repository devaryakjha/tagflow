import 'package:flutter/widgets.dart';
import 'package:tagflow/tagflow.dart';

/// Converter for container elements
class ContainerConverter extends ElementConverter {
  /// Create a new container converter
  const ContainerConverter();

  @override
  Set<String> get supportedTags => {'div', 'section', 'article'};

  @override
  Widget convert(
    TagflowElement element,
    BuildContext context,
    TagflowConverter converter,
  ) {
    final children = converter.convertChildren(element.children, context);

    return StyledContainerWidget(
      key: createUniqueKey(),
      style: resolveStyle(element, context),
      tag: element.tag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}
