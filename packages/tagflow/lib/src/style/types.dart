import 'package:flutter/widgets.dart';
import 'package:tagflow/tagflow.dart'
    show AlignItems, FlexDirection, JustifyContent;

/// Extension methods for converting style enums to Flutter types
extension FlexTypeExtensions on FlexDirection {
  /// Convert to Flutter's [MainAxisAlignment]
  MainAxisAlignment toMainAxisAlignment({required bool reverse}) {
    if (reverse) {
      return MainAxisAlignment.end;
    }
    return MainAxisAlignment.start;
  }
}

extension JustifyContentExtensions on JustifyContent {
  /// Convert to Flutter's [MainAxisAlignment]
  MainAxisAlignment toMainAxisAlignment() => switch (this) {
        JustifyContent.start => MainAxisAlignment.start,
        JustifyContent.end => MainAxisAlignment.end,
        JustifyContent.center => MainAxisAlignment.center,
        JustifyContent.spaceBetween => MainAxisAlignment.spaceBetween,
        JustifyContent.spaceAround => MainAxisAlignment.spaceAround,
        JustifyContent.spaceEvenly => MainAxisAlignment.spaceEvenly,
      };
}

extension AlignItemsExtensions on AlignItems {
  /// Convert to Flutter's [CrossAxisAlignment]
  CrossAxisAlignment toCrossAxisAlignment() => switch (this) {
        AlignItems.start => CrossAxisAlignment.start,
        AlignItems.end => CrossAxisAlignment.end,
        AlignItems.center => CrossAxisAlignment.center,
        AlignItems.stretch => CrossAxisAlignment.stretch,
        AlignItems.baseline => CrossAxisAlignment.baseline,
      };
}
