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
      style: style,
      child: Table(
        children: element.cells.map((e) {
          return TableRow(children: converter.convertChildren(e, context));
        }).toList(),
      ),
    );
  }

  @override
  Set<String> get supportedTags => {'table'};
}
