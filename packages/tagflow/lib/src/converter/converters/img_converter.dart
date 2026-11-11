import 'package:flutter/widgets.dart';
import 'package:tagflow/legacy.dart';

/// Converter for img elements
final class ImgConverter extends ElementConverter<TagflowImgElement> {
  /// Create a new img converter
  const ImgConverter();

  @override
  Set<String> get supportedTags => {'img'};

  String? _createSelectionText(
    TagflowImgElement element,
    BuildContext context,
  ) {
    final selectable = TagflowViewOptions.maybeOf(context)?.selectable;
    if (selectable == null) return null;
    return selectable.imageSelectionText(
      TagflowDocumentNode.image(
        id: 'img',
        url: Uri.tryParse(element.src ?? '') ?? Uri(),
        alt: element.alt,
        width: element.width,
        height: element.height,
      ),
      context,
    );
  }

  @override
  Widget convert(
    TagflowImgElement element,
    BuildContext context,
    TagflowConverter converter,
  ) {
    if (!element.hasAttribute('src')) {
      throw Exception('Image tag must have a src attribute');
    }
    final options = TagflowOptions.maybeOf(context);
    final style = resolveStyle(element, context);
    // Lets use alt for semantics
    return StyledContainer(
      style: style,
      tag: element.tag,
      child: TagflowSelectableAdapter(
        text: _createSelectionText(element, context),
        child: Image.network(
          element.src ?? '',
          semanticLabel: element.alt,
          width: element.width?.clamp(
            0,
            options?.maxImageWidth ?? double.infinity,
          ),
          height: element.height?.clamp(
            0,
            options?.maxImageHeight ?? double.infinity,
          ),
          fit: element.fit,
        ),
      ),
    );
  }
}
