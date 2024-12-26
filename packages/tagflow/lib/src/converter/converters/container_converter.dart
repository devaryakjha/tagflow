import 'package:flutter/widgets.dart';
import 'package:tagflow/tagflow.dart';

/// Converts container elements (div, section, article, etc.)
class ContainerConverter extends ElementConverter<TagflowElement> {
  const ContainerConverter();

  @override
  Set<String> get supportedTags => {
        'div',
        'section',
        'article',
        'aside',
        'nav',
        'header',
        'footer',
        'main',
      };

  @override
  Widget convert(
    TagflowElement element,
    BuildContext context,
    TagflowConverter converter,
  ) {
    final style = resolveStyle(element, context);
    final children = converter.convertChildren(element.children, context);

    // Handle flex display
    if (style.display == Display.flex) {
      return StyledContainer(
        style: style,
        tag: element.tag,
        child: Flex(
          direction: style.flexDirection ?? Axis.vertical,
          mainAxisAlignment: style.justifyContent ?? MainAxisAlignment.start,
          crossAxisAlignment: style.alignItems ?? CrossAxisAlignment.start,
          children: children,
        ),
      );
    }

    // Default to Column for block elements
    return StyledContainer(
      style: style,
      tag: element.tag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}
