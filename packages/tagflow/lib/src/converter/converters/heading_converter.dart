import 'package:flutter/widgets.dart';
import 'package:tagflow/tagflow.dart';

/// Converter for heading elements
class HeadingConverter implements ElementConverter {
  /// Create a new heading converter
  const HeadingConverter();

  static const _headingTags = {'h1', 'h2', 'h3', 'h4', 'h5', 'h6'};

  @override
  bool canHandle(TagflowElement element) =>
      _headingTags.contains(element.tag.toLowerCase());

  @override
  Widget convert(
    TagflowElement element,
    BuildContext context,
    TagflowConverter converter,
  ) {
    final children = converter.convertChildren(element.children, context);

    final style = _getHeadingStyle(element.tag);

    return DefaultTextStyle(
      style: style,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  TextStyle _getHeadingStyle(String tag) {
    switch (tag.toLowerCase()) {
      case 'h1':
        return const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
        );
      case 'h2':
        return const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        );
      case 'h3':
        return const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        );
      default:
        return const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        );
    }
  }
}
