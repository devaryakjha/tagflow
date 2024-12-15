// ignore_for_file: lines_longer_than_80_chars

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:tagflow/tagflow.dart';

/// Callback for handling link taps
typedef TagflowLinkTapCallback = void Function(
  String url,
  Map<String, String> attributes,
);

/// Behavior for selecting images
enum TagflowImageSelectionBehavior {
  /// Select the image alt text only
  altTextOnly,

  /// Select the image url and alt text
  urlAndAlt,

  /// Custom behavior for selecting images
  custom;
}

/// Options for configuring the selectable behavior of the Tagflow widget
final class TagflowSelectableOptions extends Equatable {
  /// Creates a new [TagflowSelectableOptions] instance.
  const TagflowSelectableOptions({
    this.enabled = false,
    this.imageSelectionBehavior = TagflowImageSelectionBehavior.altTextOnly,
    this.imageSelectionBehaviorTextBuilder,
  }) : assert(
          imageSelectionBehavior != TagflowImageSelectionBehavior.custom ||
              imageSelectionBehaviorTextBuilder != null,
          'imageSelectionBehaviorTextBuilder must be provided when imageSelectionBehavior is custom',
        );

  /// Whether the selectable behavior is enabled
  final bool enabled;

  /// Behavior for selecting images
  final TagflowImageSelectionBehavior imageSelectionBehavior;

  /// Custom behavior for selecting images
  final String? Function(TagflowElement, BuildContext)?
      imageSelectionBehaviorTextBuilder;

  @override
  List<Object?> get props => [enabled, imageSelectionBehavior];
}

/// Options for configuring the Tagflow widget
///
/// [debug] Enable debug mode
///
/// [linkTapCallback] Callback for handling link taps
@immutable
final class TagflowOptions extends Equatable {
  /// Creates a new [TagflowOptions] instance.
  const TagflowOptions({
    this.debug = false,
    this.linkTapCallback,
    this.selectable = const TagflowSelectableOptions(),
  });

  /// Enable debug mode
  final bool debug;

  /// Callback for handling link taps
  final TagflowLinkTapCallback? linkTapCallback;

  /// Options for configuring the selectable behavior of the Tagflow widget
  final TagflowSelectableOptions selectable;

  /// Default options for configuring the Tagflow widget
  static const TagflowOptions defaultOptions = TagflowOptions();

  /// Get the [TagflowOptions] from the context
  static TagflowOptions? maybeOf(BuildContext context) {
    return TagflowScope.maybeOf(context)?.options;
  }

  /// Get the [TagflowOptions] from the context
  static TagflowOptions of(BuildContext context) {
    return TagflowScope.of(context).options;
  }

  @override
  List<Object?> get props => [debug, linkTapCallback];
}

/// Inherited widget for configuring the Tagflow widget
final class TagflowScope extends InheritedWidget {
  /// Creates a new [TagflowScope] instance.
  const TagflowScope({
    required this.options,
    required super.child,
    super.key,
  });

  /// The options for configuring the Tagflow widget
  final TagflowOptions options;

  @override
  bool updateShouldNotify(covariant TagflowScope oldWidget) {
    return options != oldWidget.options;
  }

  /// Get the [TagflowOptions] from the context
  static TagflowScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TagflowScope>();
  }

  /// Get the [TagflowOptions] from the context
  static TagflowScope of(BuildContext context) {
    final scope = maybeOf(context);
    if (scope == null) {
      throw FlutterError(
        'TagflowOptions.of() called with a context that does not contain a TagflowOptions.\n'
        'No TagflowOptions ancestor could be found starting from the context that was passed to '
        'TagflowOptions.of(). This can happen if the context you used comes from a widget that '
        'was not placed under a Tagflow widget.',
      );
    }
    return scope;
  }
}
