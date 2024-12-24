import 'package:flutter/cupertino.dart';
import 'package:tagflow/tagflow.dart';

final class ListConverter extends ElementConverter {
  const ListConverter();

  @override
  Set<String> get supportedTags => {'ul', 'ol'};

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
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: children,
      ),
    );
  }
}

final class ListItemConverter extends TextConverter {
  const ListItemConverter();

  @override
  Set<String> get supportedTags => super.supportedTags.union({'li'});

  @override
  InlineSpan? getPrefix(TagflowElement element) {
    final isOrdered = element.parentTag == 'ol';
    final index = element.parent?.children.indexOf(element) ?? 0;
    const noSpace = '\u00A0\u00A0';
    return TextSpan(
      text: isOrdered ? '${index + 1}.$noSpace' : '•$noSpace',
    );
  }
}
