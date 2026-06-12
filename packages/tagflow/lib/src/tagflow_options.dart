// ignore_for_file: lines_longer_than_80_chars

import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:tagflow/src/core/models/img_element.dart';
import 'package:tagflow/src/runtime/document_node.dart';

/// Callback for handling link taps
typedef TagflowLinkTapCallback =
    void Function(String url, LinkedHashMap<String, String>? attributes);

/// Callback for handling taps on opted-in semantic document nodes.
typedef TagflowNodeTapCallback = void Function(TagflowNodeTapDetails details);

/// Error widget builder for handling parsing and rendering failures.
typedef TagflowErrorWidgetBuilder =
    Widget Function(BuildContext context, Object? error);

/// Details passed to [TagflowNodeTapCallback].
final class TagflowNodeTapDetails {
  /// Creates tap details for a semantic document node.
  const TagflowNodeTapDetails({required this.context, required this.node});

  /// Build context from the current render pass.
  final BuildContext context;

  /// Runtime node that was tapped.
  final TagflowDocumentNode node;
}

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

/// Boundary that limits rendering when matched while parsing the HTML tree.
final class TagflowRenderBoundary extends Equatable {
  /// Renders content between optional HTML comment markers.
  ///
  /// If [start] is omitted, rendering starts at the beginning of the tree.
  /// If [end] is omitted, rendering continues through the end of the tree.
  ///
  /// For example, `comment(end: 'end-of-mobile')` matches
  /// `<!--end-of-mobile-->`.
  const TagflowRenderBoundary.comment({
    this.start,
    this.end,
    this.caseSensitive = false,
  });

  /// Optional comment marker that starts rendering after it is encountered.
  final String? start;

  /// Optional comment marker that stops rendering before it is encountered.
  final String? end;

  /// Whether comment matching should be case-sensitive.
  final bool caseSensitive;

  /// Returns true when [comment] matches [start].
  bool matchesStartComment(String comment) => _matchesComment(comment, start);

  /// Returns true when [comment] matches [end].
  bool matchesEndComment(String comment) => _matchesComment(comment, end);

  bool _matchesComment(String comment, String? value) {
    if (value == null) return false;
    final normalizedValue = _normalize(value);
    final normalizedComment = _normalize(comment);
    return normalizedComment == normalizedValue;
  }

  String _normalize(String input) {
    final trimmed = input.trim();
    return caseSensitive ? trimmed : trimmed.toLowerCase();
  }

  @override
  // coverage:ignore-line
  List<Object?> get props => [start, end, caseSensitive];
}

/// Options for configuring the Tagflow widget
///
/// [debug] Enable debug mode
///
/// [linkTapCallback] Callback for handling link taps
final class TagflowViewOptions extends Equatable {
  /// Creates a new [TagflowViewOptions] instance.
  const TagflowViewOptions({
    this.debug = false,
    this.linkTapCallback,
    this.nodeTapCallback,
    this.tapTargetKinds = const {},
    this.selectable = const TagflowSelectableOptions(),
    this.imageLoadingBuilder,
    this.imageErrorBuilder,
    this.maxImageWidth,
    this.maxImageHeight,
    this.enableImageCache = true,
    this.errorBuilder,
  });

  /// Enable debug mode
  final bool debug;

  /// Callback for handling link taps
  final TagflowLinkTapCallback? linkTapCallback;

  /// Callback for taps on opted-in semantic node kinds.
  final TagflowNodeTapCallback? nodeTapCallback;

  /// Semantic node kinds that should be wrapped as tap targets.
  final Set<TagflowNodeKind> tapTargetKinds;

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

  /// Custom widget builder for unrecoverable parsing or rendering errors.
  final TagflowErrorWidgetBuilder? errorBuilder;

  /// Create a copy with some properties replaced
  TagflowViewOptions copyWith({
    bool? debug,
    TagflowLinkTapCallback? linkTapCallback,
    TagflowNodeTapCallback? nodeTapCallback,
    Set<TagflowNodeKind>? tapTargetKinds,
    TagflowSelectableOptions? selectable,
    ImageLoadingBuilder? imageLoadingBuilder,
    ImageErrorWidgetBuilder? imageErrorBuilder,
    double? maxImageWidth,
    double? maxImageHeight,
    bool? enableImageCache,
    TagflowErrorWidgetBuilder? errorBuilder,
  }) {
    return TagflowViewOptions(
      debug: debug ?? this.debug,
      linkTapCallback: linkTapCallback ?? this.linkTapCallback,
      nodeTapCallback: nodeTapCallback ?? this.nodeTapCallback,
      tapTargetKinds: tapTargetKinds ?? this.tapTargetKinds,
      selectable: selectable ?? this.selectable,
      imageLoadingBuilder: imageLoadingBuilder ?? this.imageLoadingBuilder,
      imageErrorBuilder: imageErrorBuilder ?? this.imageErrorBuilder,
      maxImageWidth: maxImageWidth ?? this.maxImageWidth,
      maxImageHeight: maxImageHeight ?? this.maxImageHeight,
      enableImageCache: enableImageCache ?? this.enableImageCache,
      errorBuilder: errorBuilder ?? this.errorBuilder,
    );
  }

  /// Default options
  static const defaults = TagflowViewOptions();

  /// Get options from context
  static TagflowViewOptions of(BuildContext context) {
    final options = maybeOf(context);
    assert(options != null, 'No TagflowScope found in context');
    return options!;
  }

  /// Get options from context if available
  static TagflowViewOptions? maybeOf(BuildContext context) {
    return TagflowScope.maybeOf(context)?.viewOptions;
  }

  @override
  // coverage:ignore-line
  List<Object?> get props => [
    debug,
    linkTapCallback,
    nodeTapCallback,
    tapTargetKinds,
    selectable,
    imageLoadingBuilder,
    imageErrorBuilder,
    maxImageWidth,
    maxImageHeight,
    enableImageCache,
    errorBuilder,
  ];
}

/// Legacy alpha compatibility wrapper for runtime view options.
///
/// Prefer [TagflowViewOptions] for new code. [TagflowRenderBoundary] remains on
/// this compatibility type so existing HTML-first usage continues to work while
/// the alpha API moves HTML-only parsing behavior onto `Tagflow.html(...)` and
/// the HTML adapter.
final class TagflowOptions extends Equatable {
  /// Creates a new [TagflowOptions] instance.
  const TagflowOptions({
    this.debug = false,
    this.linkTapCallback,
    this.nodeTapCallback,
    this.tapTargetKinds = const {},
    this.selectable = const TagflowSelectableOptions(),
    this.imageLoadingBuilder,
    this.imageErrorBuilder,
    this.maxImageWidth,
    this.maxImageHeight,
    this.enableImageCache = true,
    this.errorBuilder,
    this.renderBoundary,
  });

  /// Creates legacy options from the new runtime view options.
  factory TagflowOptions.fromViewOptions(
    TagflowViewOptions options, {
    TagflowRenderBoundary? renderBoundary,
  }) {
    return TagflowOptions(
      debug: options.debug,
      linkTapCallback: options.linkTapCallback,
      nodeTapCallback: options.nodeTapCallback,
      tapTargetKinds: options.tapTargetKinds,
      selectable: options.selectable,
      imageLoadingBuilder: options.imageLoadingBuilder,
      imageErrorBuilder: options.imageErrorBuilder,
      maxImageWidth: options.maxImageWidth,
      maxImageHeight: options.maxImageHeight,
      enableImageCache: options.enableImageCache,
      errorBuilder: options.errorBuilder,
      renderBoundary: renderBoundary,
    );
  }

  /// Enable debug mode
  final bool debug;

  /// Callback for handling link taps
  final TagflowLinkTapCallback? linkTapCallback;

  /// Callback for taps on opted-in semantic node kinds.
  final TagflowNodeTapCallback? nodeTapCallback;

  /// Semantic node kinds that should be wrapped as tap targets.
  final Set<TagflowNodeKind> tapTargetKinds;

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

  /// Custom widget builder for unrecoverable parsing or rendering errors.
  final TagflowErrorWidgetBuilder? errorBuilder;

  /// Optional boundary that stops rendering part-way through the HTML tree.
  final TagflowRenderBoundary? renderBoundary;

  /// Converts these compatibility options into the runtime view options.
  TagflowViewOptions toViewOptions() {
    return TagflowViewOptions(
      debug: debug,
      linkTapCallback: linkTapCallback,
      nodeTapCallback: nodeTapCallback,
      tapTargetKinds: tapTargetKinds,
      selectable: selectable,
      imageLoadingBuilder: imageLoadingBuilder,
      imageErrorBuilder: imageErrorBuilder,
      maxImageWidth: maxImageWidth,
      maxImageHeight: maxImageHeight,
      enableImageCache: enableImageCache,
      errorBuilder: errorBuilder,
    );
  }

  /// Create a copy with some properties replaced
  TagflowOptions copyWith({
    bool? debug,
    TagflowLinkTapCallback? linkTapCallback,
    TagflowNodeTapCallback? nodeTapCallback,
    Set<TagflowNodeKind>? tapTargetKinds,
    TagflowSelectableOptions? selectable,
    ImageLoadingBuilder? imageLoadingBuilder,
    ImageErrorWidgetBuilder? imageErrorBuilder,
    double? maxImageWidth,
    double? maxImageHeight,
    bool? enableImageCache,
    TagflowErrorWidgetBuilder? errorBuilder,
    TagflowRenderBoundary? renderBoundary,
  }) {
    return TagflowOptions(
      debug: debug ?? this.debug,
      linkTapCallback: linkTapCallback ?? this.linkTapCallback,
      nodeTapCallback: nodeTapCallback ?? this.nodeTapCallback,
      tapTargetKinds: tapTargetKinds ?? this.tapTargetKinds,
      selectable: selectable ?? this.selectable,
      imageLoadingBuilder: imageLoadingBuilder ?? this.imageLoadingBuilder,
      imageErrorBuilder: imageErrorBuilder ?? this.imageErrorBuilder,
      maxImageWidth: maxImageWidth ?? this.maxImageWidth,
      maxImageHeight: maxImageHeight ?? this.maxImageHeight,
      enableImageCache: enableImageCache ?? this.enableImageCache,
      errorBuilder: errorBuilder ?? this.errorBuilder,
      renderBoundary: renderBoundary ?? this.renderBoundary,
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
    nodeTapCallback,
    tapTargetKinds,
    selectable,
    imageLoadingBuilder,
    imageErrorBuilder,
    maxImageWidth,
    maxImageHeight,
    enableImageCache,
    errorBuilder,
    renderBoundary,
  ];
}

/// Scope for providing options to descendants
class TagflowScope extends InheritedWidget {
  /// Creates a new legacy compatibility [TagflowScope].
  const TagflowScope({
    required TagflowOptions options,
    required super.child,
    super.key,
  }) : _legacyOptions = options,
       _viewOptions = null;

  /// Creates a [TagflowScope] with runtime view options.
  const TagflowScope.view({
    required TagflowViewOptions viewOptions,
    required super.child,
    super.key,
  }) : _viewOptions = viewOptions,
       _legacyOptions = null;

  final TagflowOptions? _legacyOptions;
  final TagflowViewOptions? _viewOptions;

  /// The runtime view options to provide.
  TagflowViewOptions get viewOptions =>
      _viewOptions ?? _legacyOptions!.toViewOptions();

  /// The legacy compatibility options exposed through [TagflowOptions.of].
  TagflowOptions get options =>
      _legacyOptions ?? TagflowOptions.fromViewOptions(viewOptions);

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
    return viewOptions != oldWidget.viewOptions;
  }
}
