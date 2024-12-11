import 'package:flutter/widgets.dart';
import 'package:tagflow/tagflow.dart';

/// Converter for img elements
final class ImgConverter extends ElementConverter {
  /// Create a new img converter
  const ImgConverter();

  @override
  Set<String> get supportedTags => {'img'};

  @override
  Widget convert(
    TagflowElement element,
    BuildContext context,
    TagflowConverter converter,
  ) {
    if (!element.hasAttribute('src')) {
      throw Exception('Image tag must have a src attribute');
    }

    // Lets use alt for semantics
    return Image.network(
      key: createUniqueKey(),
      element.src,
      semanticLabel: element.alt,
      width: element.width,
      height: element.height,
      fit: element.fit,
    );
  }
}
