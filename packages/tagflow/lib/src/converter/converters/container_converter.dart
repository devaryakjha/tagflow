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
    final style = resolveStyle(element, context);
    return StyledContainer(
      style: style,
      tag: element.tag,
      width: element.width ?? double.maxFinite,
      // this is a hack to make the container expand to the width of the parent
      height: element.height,
      child: Flex(
        mainAxisSize: MainAxisSize.min,
        direction: dir,
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        spacing: element.spacing ?? 0,
        children: children,
      ),
    );
  }
}
