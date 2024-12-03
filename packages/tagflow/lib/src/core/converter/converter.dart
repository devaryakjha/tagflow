import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tagflow/tagflow.dart';

export 'registery.dart';

/// Base converter interface for transforming
/// TagflowElements into Flutter widgets
abstract class TagflowConverter {
  /// Converts a single element to a widget
  Widget convert(TagflowElement element, BuildContext context);

  /// Checks if this converter can handle the given element
  bool canHandle(TagflowElement element);
}

/// A fallback converter that always returns an empty widget
class FallbackConverter implements TagflowConverter {
  @override
  Widget convert(TagflowElement element, BuildContext context) {
    if (kDebugMode) {
      return SizedBox(
        child: Text(
          'No converter found for element: $element',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  bool canHandle(TagflowElement element) {
    return true;
  }
}
