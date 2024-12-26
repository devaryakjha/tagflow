import 'package:tagflow/tagflow.dart';

/// A converter for code elements (`code` and `pre` tags)
final class CodeConverter extends TextConverter {
  /// Create a new code converter
  const CodeConverter();

  @override
  bool shouldForceWidgetSpan(TagflowNode element) {
    return super.shouldForceWidgetSpan(element) ||
        ['code', 'pre'].contains(element.tag);
  }

  @override
  Set<String> get supportedTags => super.supportedTags.union({'code', 'pre'});
}
