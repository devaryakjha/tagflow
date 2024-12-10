import 'package:flutter/widgets.dart';
import 'package:tagflow/tagflow.dart';

/// Converter for img elements
class ImgConverter extends ElementConverter {
  /// Create a new img converter
  const ImgConverter();

  @override
  bool canHandle(TagflowElement element) => element.tag == 'img';

  @override
  Widget convert(
    TagflowElement element,
    BuildContext context,
    TagflowConverter converter,
  ) {
    if (!element.hasAttribute('src')) {
      throw Exception('Image tag must have a src attribute');
    }
    return Image.network(
      key: createUniqueKey(),
      element['src']!,
    );
  }
}
