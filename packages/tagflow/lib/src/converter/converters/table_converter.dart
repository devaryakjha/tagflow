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
    return const Text('Table');
  }

  @override
  Set<String> get supportedTags => {'table', 'tr', 'td', 'th'};
}
