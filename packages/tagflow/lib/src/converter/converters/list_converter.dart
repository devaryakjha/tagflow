import 'package:flutter/cupertino.dart';
import 'package:tagflow/legacy.dart';

/// Converter for `ul` and `ol` lists.
final class ListConverter extends ElementConverter<TagflowElement> {
  /// Creates a list converter.
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
      style: style.copyWith(padding: EdgeInsets.zero),
      tag: element.tag,
      child: ListView(
        padding: style.padding ?? EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: children,
      ),
    );
  }
}

/// Converter for `li` list items.
final class ListItemConverter extends TextConverter {
  /// Creates a list item converter.
  const ListItemConverter();

  @override
  Set<String> get supportedTags => super.supportedTags.union({'li'});

  @override
  InlineSpan? getPrefix(TagflowElement element) {
    final isOrdered = element.parentTag == 'ol';
    const noSpace = '\u00A0\u00A0';
    if (isOrdered) {
      final index = element.parent?.children.indexOf(element) ?? 0;
      return TextSpan(text: '${index + 1}.$noSpace');
    }
    return const TextSpan(text: '•$noSpace');
  }
}
