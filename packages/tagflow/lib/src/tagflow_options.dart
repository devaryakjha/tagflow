// ignore_for_file: lines_longer_than_80_chars

import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:tagflow/tagflow.dart';

/// Callback for handling link taps
typedef TagflowLinkTapCallback =
    void Function(String url, LinkedHashMap<String, String>? attributes);

/// Behavior for selecting images
enum TagflowImageSelectionBehavior {
  /// Select the image alt text only
  altTextOnly,

  /// Select the image url and alt text
  urlAndAlt,

  /// Custom behavior for selecting images
  custom,
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
  final String? Function(TagflowImgElement, BuildContext)?
  imageSelectionBehaviorTextBuilder;

  @override
  // coverage:ignore-line
  List<Object?> get props => [enabled, imageSelectionBehavior];
}

/// Options for configuring the Tagflow widget
///
/// [debug] Enable debug mode
///
/// [linkTapCallback] Callback for handling link taps
final class TagflowOptions extends Equatable {
  /// Creates a new [TagflowOptions] instance.
  const TagflowOptions({
    this.debug = false,
    this.linkTapCallback,
    this.selectable = const TagflowSelectableOptions(),
    this.imageLoadingBuilder,
    this.imageErrorBuilder,
    this.maxImageWidth,
    this.maxImageHeight,
    this.enableImageCache = true,
  });

  /// Enable debug mode
  final bool debug;

  /// Callback for handling link taps
  final TagflowLinkTapCallback? linkTapCallback;

  /// Options for configuring the selectable behavior
  final TagflowSelectableOptions selectable;

  /// Custom image loading widget builder
  final ImageLoadingBuilder? imageLoadingBuilder;

  /// Custom image error widget builder
  final ImageErrorWidgetBuilder? imageErrorBuilder;

  /// Maximum width for images
  final double? maxImageWidth;

  /// Maximum height for images
  final double? maxImageHeight;

  /// Whether to cache images
  final bool enableImageCache;

  /// Create a copy with some properties replaced
  TagflowOptions copyWith({
    bool? debug,
    TagflowLinkTapCallback? linkTapCallback,
    TagflowSelectableOptions? selectable,
    ImageLoadingBuilder? imageLoadingBuilder,
    ImageErrorWidgetBuilder? imageErrorBuilder,
    double? maxImageWidth,
    double? maxImageHeight,
    bool? enableImageCache,
  }) {
    return TagflowOptions(
      debug: debug ?? this.debug,
      linkTapCallback: linkTapCallback ?? this.linkTapCallback,
      selectable: selectable ?? this.selectable,
      imageLoadingBuilder: imageLoadingBuilder ?? this.imageLoadingBuilder,
      imageErrorBuilder: imageErrorBuilder ?? this.imageErrorBuilder,
      maxImageWidth: maxImageWidth ?? this.maxImageWidth,
      maxImageHeight: maxImageHeight ?? this.maxImageHeight,
      enableImageCache: enableImageCache ?? this.enableImageCache,
    );
  }

  /// Default options
  static const defaults = TagflowOptions();

  /// Get options from context
  static TagflowOptions of(BuildContext context) {
    final options = maybeOf(context);
    assert(options != null, 'No TagflowScope found in context');
    return options!;
  }

  /// Get options from context if available
  static TagflowOptions? maybeOf(BuildContext context) {
    return TagflowScope.maybeOf(context)?.options;
  }

  @override
  // coverage:ignore-line
  List<Object?> get props => [
    debug,
    linkTapCallback,
    selectable,
    imageLoadingBuilder,
    imageErrorBuilder,
    maxImageWidth,
    maxImageHeight,
    enableImageCache,
  ];
}

/// Scope for providing options to descendants
class TagflowScope extends InheritedWidget {
  /// Creates a new [TagflowScope].
  const TagflowScope({required this.options, required super.child, super.key});

  /// The options to provide
  final TagflowOptions options;

  /// Get scope from context
  static TagflowScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TagflowScope>();
  }

  /// Get scope from context
  static TagflowScope of(BuildContext context) {
    final scope = maybeOf(context);
    assert(scope != null, 'No TagflowScope found in context');
    return scope!;
  }

  @override
  bool updateShouldNotify(TagflowScope oldWidget) {
    return options != oldWidget.options;
  }
}
