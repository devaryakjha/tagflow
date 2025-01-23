import 'package:flutter/material.dart';
import 'package:tagflow/tagflow.dart';

/// Converter for horizontal rules
final class HrConverter extends ElementConverter<TagflowElement> {
  /// Create a new horizontal rule converter
  const HrConverter();

  @override
  Set<String> get supportedTags => {'hr'};

  @override
  Widget convert(
    TagflowElement element,
    BuildContext context,
    TagflowConverter converter,
  ) {
    final style = resolveStyle(element, context);
    return StyledContainer(
      tag: element.tag,
      style: style.copyWith(
        width: const SizeValue(double.infinity),
        border: Border(
          bottom: BorderSide(
            color: style.textStyleWithColor?.color ?? Colors.grey,
            width: element.height ?? 1,
          ),
        ),
      ),
    );
  }
}
