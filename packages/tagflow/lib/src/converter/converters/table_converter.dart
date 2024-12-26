import 'package:flutter/material.dart';
import 'package:tagflow/tagflow.dart';

final class TableConverter extends ElementConverter<TagflowTableElement> {
  const TableConverter();

  @override
  Widget convert(
    TagflowTableElement element,
    BuildContext context,
    TagflowConverter converter,
  ) {
    final style = resolveStyle(element, context);
    return StyledContainer(
      tag: element.tag,
      style: style.copyWith(
        border: Border.all(
          width: 0,
          style: BorderStyle.none,
        ),
      ),
      child: Table(
        border: TableBorder(
          left: style.effectiveBorder.left,
          right: style.effectiveBorder.right,
          top: style.effectiveBorder.top,
          bottom: style.effectiveBorder.bottom,
          horizontalInside: style.effectiveBorder.bottom,
          verticalInside: style.effectiveBorder.right,
        ),
        children: element.rows.map((e) {
          final style = resolveStyle(e, context);
          return TableRow(
            decoration: style.toBoxDecoration(),
            children: converter.convertChildren(e.children, context),
          );
        }).toList(),
      ),
    );
  }

  @override
  Set<String> get supportedTags => {'table'};
}

final class TableCellConverter extends TextConverter {
  const TableCellConverter();

  @override
  bool shouldForceWidgetSpan(TagflowNode element) {
    return super.shouldForceWidgetSpan(element) ||
        ['td', 'th'].contains(element.tag);
  }

  @override
  Set<String> get supportedTags => super.supportedTags.union({
        'tr',
        'td',
        'th',
      });

  @override
  TextStyle? getTextStyle(
    TagflowNode element,
    TagflowStyle? resolvedStyle,
    BuildContext context,
  ) {
    final parentTr = lookupParent(element, 'tr');
    if (parentTr != null) {
      final parentTrStyle = resolveStyle(parentTr, context);
      return resolvedStyle?.textStyleWithColor
          ?.merge(parentTrStyle.textStyleWithColor);
    }
    return resolvedStyle?.textStyleWithColor;
  }
}
