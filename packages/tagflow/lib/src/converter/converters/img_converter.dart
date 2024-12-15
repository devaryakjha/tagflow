import 'package:flutter/widgets.dart';
import 'package:tagflow/tagflow.dart';

/// Converter for img elements
final class ImgConverter extends ElementConverter {
  /// Create a new img converter
  const ImgConverter();

  @override
  Set<String> get supportedTags => {'img'};

  String? _createSelectionText(TagflowElement element, BuildContext context) {
    final options = TagflowOptions.maybeOf(context);
    final behavior = options?.selectable.imageSelectionBehavior;
    final altText = element.alt;
    final url = element.src;
    switch (behavior) {
      case TagflowImageSelectionBehavior.urlAndAlt:
        final buffer = StringBuffer();

        // Maintain semantic structure: alt text first, then URL
        if (altText.isNotEmpty) {
          buffer.write(altText);
        }

        if (url.isNotEmpty) {
          if (buffer.isNotEmpty) {
            // Add semantic separator for screen readers
            buffer.write(' — '); // Em dash for visual separation
          }
          buffer.write(url);
        }

        return buffer.toString();
      case TagflowImageSelectionBehavior.altTextOnly:
        return element.alt;
      case TagflowImageSelectionBehavior.custom:
        return options?.selectable.imageSelectionBehaviorTextBuilder
            ?.call(element, context);
      case null:
        return null;
    }
  }

  @override
  Widget convert(
    TagflowElement element,
    BuildContext context,
    TagflowConverter converter,
  ) {
    if (!element.hasAttribute('src')) {
      throw Exception('Image tag must have a src attribute');
    }
    final style = resolveStyle(element, context);
    // Lets use alt for semantics
    return StyledContainer(
      style: style,
      tag: element.tag,
      child: TagflowSelectableAdapter(
        text: _createSelectionText(element, context),
        child: Image.network(
          element.src,
          semanticLabel: element.alt,
          width: element.width,
          height: element.height,
          fit: element.fit,
        ),
      ),
    );
  }
}
