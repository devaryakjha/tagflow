// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/widgets.dart';

/// Callback for handling link taps
typedef TagflowLinkTapCallback = void Function(
  String url,
  Map<String, String> attributes,
);

/// Options for configuring the Tagflow widget
///
/// [debug] Enable debug mode
///
/// [linkTapCallback] Callback for handling link taps
@immutable
final class TagflowOptions {
  /// Creates a new [TagflowOptions] instance.
  const TagflowOptions({
    this.debug = false,
    this.linkTapCallback,
  });

  /// Enable debug mode
  final bool debug;

  /// Callback for handling link taps
  final TagflowLinkTapCallback? linkTapCallback;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TagflowOptions &&
        other.debug == debug &&
        other.linkTapCallback == linkTapCallback;
  }

  @override
  int get hashCode => Object.hash(debug, linkTapCallback);

  /// Default options for configuring the Tagflow widget
  static const TagflowOptions defaultOptions = TagflowOptions();

  /// Get the [TagflowOptions] from the context
  static TagflowOptions of(BuildContext context) {
    return TagflowScope.of(context).options;
  }
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
