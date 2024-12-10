import 'package:flutter/widgets.dart';
import 'package:tagflow/tagflow.dart';

/// A converter for the `<br>` tag.
final class BrConverter extends ElementConverter {
  /// Creates a new instance of [BrConverter].
  const BrConverter();

  @override
  Set<String> get supportedTags => {'br'};

  @override
  Widget convert(
    TagflowElement element,
    BuildContext context,
    TagflowConverter converter,
  ) {
    // br is a void element, so we return a SizedBox with zero height
    return const SizedBox.shrink();
  }
}
