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
    final dir = StyleParser.parseFlexDirection(
      element.styles?['flex-direction'] ?? 'row',
    );
    final mainAxisAlignment = StyleParser.parseMainAxisAlignment(
      element.styles?['justify-content'] ?? 'start',
    );
    final crossAxisAlignment = StyleParser.parseCrossAxisAlignment(
      element.styles?['align-items'] ?? 'start',
    );
    return StyledContainer(
      key: createUniqueKey(),
      style: resolveStyle(element, context),
      tag: element.tag,
      width: element.width,
      height: element.height,
      child: Flex(
        mainAxisSize: MainAxisSize.min,
        direction: dir,
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: children,
      ),
    );
  }
}
