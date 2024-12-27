import 'package:flutter/material.dart';
import 'package:tagflow/tagflow.dart';

final class TagflowTableConverter
    extends ElementConverter<TagflowTableElement> {
  @override
  Set<String> get supportedTags => {'table'};

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
      child: const SizedBox.shrink(),
    );
  }
}
