import 'dart:async';
import 'dart:collection';

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:tagflow/src/render/code_block.dart';
import 'package:tagflow/src/render/render_theme.dart';
import 'package:tagflow/src/runtime/runtime.dart';
import 'package:tagflow/src/tagflow_options.dart';
import 'package:tagflow/src/widgets/selectable_adapter.dart';

/// Builds a Flutter widget for a semantic Tagflow document node.
typedef TagflowComponentBuilder =
    Widget Function(TagflowComponentContext context, TagflowDocumentNode node);

/// Rendering context passed to semantic component builders.
final class TagflowComponentContext {
  const TagflowComponentContext._({
    required this.buildContext,
    required this.registry,
  });

  /// The Flutter build context for the current render pass.
  final BuildContext buildContext;

  /// Registry dispatching the current render pass.
  final TagflowComponentRegistry registry;

  /// Renders a child [node] through the same registry precedence rules.
  Widget render(TagflowDocumentNode node) {
    return registry.render(buildContext, node);
  }

  /// Renders all direct children of [node].
  List<Widget> renderChildren(TagflowDocumentNode node) {
    return [for (final child in node.children) render(child)];
  }

  /// Renders the children of [node] as block content, the way the built-in
  /// table cell and list item do.
  ///
  /// Consecutive inline children (text, links, inline code and inline
  /// containers) flow as one rich text, so they wrap word by word and share
  /// a baseline. Other children render as blocks in a column.
  Widget renderBlockContent(TagflowDocumentNode node) {
    return _renderBlockChildren(this, node);
  }
}

/// Registry for mapping semantic Tagflow node kinds to Flutter components.
///
/// Registry precedence is app overrides, extension registries, then built-in
/// core components.
final class TagflowComponentRegistry {
  /// Creates a registry with built-ins, optional [extensions], and app
  /// [overrides].
  ///
  /// [customComponents] render [TagflowNodeKind.custom] nodes by their
  /// [TagflowDocumentNode.customType]; they take precedence over the
  /// extensions' custom components.
  factory TagflowComponentRegistry({
    Map<TagflowNodeKind, TagflowComponentBuilder> overrides = const {},
    Map<String, TagflowComponentBuilder> customComponents = const {},
    Iterable<TagflowComponentRegistry> extensions = const [],
    TagflowComponentBuilder? fallbackBuilder,
  }) {
    return TagflowComponentRegistry._(
      components: {
        ...builtIn._components,
        for (final extension in extensions) ...extension._components,
        ...overrides,
      },
      customComponents: {
        for (final extension in extensions) ...extension._customComponents,
        ...customComponents,
      },
      fallbackBuilder: fallbackBuilder ?? builtIn._fallbackBuilder,
    );
  }

  /// Creates a registry fragment for first-party or app extension components.
  factory TagflowComponentRegistry.components({
    Map<TagflowNodeKind, TagflowComponentBuilder> components = const {},
    Map<String, TagflowComponentBuilder> customComponents = const {},
    TagflowComponentBuilder? fallbackBuilder,
  }) {
    return TagflowComponentRegistry._(
      components: components,
      customComponents: customComponents,
      fallbackBuilder: fallbackBuilder,
    );
  }

  TagflowComponentRegistry._({
    required Map<TagflowNodeKind, TagflowComponentBuilder> components,
    required TagflowComponentBuilder? fallbackBuilder,
    Map<String, TagflowComponentBuilder> customComponents = const {},
  }) : _components = Map.unmodifiable(components),
       _customComponents = Map.unmodifiable(customComponents),
       _fallbackBuilder = fallbackBuilder;

  /// Built-in semantic components shipped by the core package.
  static final TagflowComponentRegistry builtIn = TagflowComponentRegistry._(
    components: _builtInComponents,
    fallbackBuilder: _defaultFallback,
  );

  final Map<TagflowNodeKind, TagflowComponentBuilder> _components;
  final Map<String, TagflowComponentBuilder> _customComponents;
  final TagflowComponentBuilder? _fallbackBuilder;

  /// Semantic node kinds with an explicitly registered component.
  Set<TagflowNodeKind> get registeredKinds =>
      Set.unmodifiable(_components.keys);

  /// Whether [kind] has an explicit component in this registry.
  bool hasComponent(TagflowNodeKind kind) {
    return _components.containsKey(kind);
  }

  /// Custom node types with a registered component.
  Set<String> get registeredCustomTypes =>
      Set.unmodifiable(_customComponents.keys);

  /// Whether [kind] can be rendered by a component or fallback.
  bool canRender(TagflowNodeKind kind) {
    return hasComponent(kind) || _fallbackBuilder != null;
  }

  /// Renders [node] through this registry.
  ///
  /// Works with or without an enclosing `Tagflow` widget. Without one, the
  /// built-in components use [TagflowViewOptions.defaults].
  ///
  /// The node is built by a widget keyed by [TagflowDocumentNode.id]. When a
  /// later render passes the identical node instance through the same
  /// registry, and the theme and view options it read are unchanged, the
  /// previous build is reused. Patched documents keep the instances of
  /// untouched nodes, so during streaming only the changed blocks build
  /// again. Keep the registry instance stable across builds to benefit.
  Widget render(BuildContext context, TagflowDocumentNode node) {
    return _TagflowNodeView(
      key: ValueKey<String>(node.id),
      registry: this,
      node: node,
      builder: _builderFor(node),
    );
  }

  TagflowComponentBuilder _builderFor(TagflowDocumentNode node) {
    final builder =
        (node.kind == TagflowNodeKind.custom
            ? _customComponents[node.customType]
            : null) ??
        _components[node.kind] ??
        _fallbackBuilder;
    if (builder == null) {
      throw UnsupportedError(
        'No Tagflow component registered for ${node.kind}.',
      );
    }
    return builder;
  }

  Widget _build(
    BuildContext context,
    TagflowDocumentNode node,
    TagflowComponentBuilder builder,
  ) {
    var child = builder(
      TagflowComponentContext._(buildContext: context, registry: this),
      node,
    );
    final inlineStyle = node.presentation.inlineStyle;
    if (inlineStyle != null &&
        identical(builder, _builtInComponents[node.kind] ?? _defaultFallback)) {
      child = _applyInlineStyle(context, node, inlineStyle, child);
    }

    return _wrapNodeTapTarget(context, node, child);
  }
}

/// Builds one node and reuses the result while the node instance, the
/// registry and the inherited values the build read stay the same.
final class _TagflowNodeView extends StatefulWidget {
  const _TagflowNodeView({
    required this.registry,
    required this.node,
    required this.builder,
    super.key,
  });

  final TagflowComponentRegistry registry;
  final TagflowDocumentNode node;
  final TagflowComponentBuilder builder;

  @override
  State<_TagflowNodeView> createState() => _TagflowNodeViewState();
}

final class _TagflowNodeViewState extends State<_TagflowNodeView> {
  Widget? _built;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // A theme, options or media query the builder read has changed.
    _built = null;
  }

  @override
  void didUpdateWidget(_TagflowNodeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.node, widget.node) ||
        !identical(oldWidget.registry, widget.registry) ||
        !identical(oldWidget.builder, widget.builder)) {
      _built = null;
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    _built = null;
  }

  @override
  Widget build(BuildContext context) {
    try {
      // Returning the identical widget lets Flutter skip the whole subtree.
      return _built ??= widget.registry._build(
        context,
        widget.node,
        widget.builder,
      );
    } on Object catch (error, stackTrace) {
      final scope = context
          .getInheritedWidgetOfExactType<TagflowRenderErrorScope>();
      if (scope == null) rethrow;
      return scope.onError(context, error, stackTrace);
    }
  }
}

/// Routes errors thrown by component builders below it to [onError], which
/// returns the widget shown in place of the failing node.
///
/// The `Tagflow` widget installs one that uses its error builder. Without a
/// scope, builder errors reach Flutter's error widget.
@internal
final class TagflowRenderErrorScope extends InheritedWidget {
  /// Creates an error scope.
  const TagflowRenderErrorScope({
    required this.onError,
    required super.child,
    super.key,
  });

  /// Builds the replacement for a node whose builder threw `error`.
  final Widget Function(
    BuildContext context,
    Object error,
    StackTrace stackTrace,
  )
  onError;

  // Read without a dependency at error time, so changes need no rebuild.
  @override
  bool updateShouldNotify(TagflowRenderErrorScope oldWidget) => false;
}

Widget _wrapNodeTapTarget(
  BuildContext context,
  TagflowDocumentNode node,
  Widget child,
) {
  final options = TagflowViewOptions.maybeOf(context);
  final callback = options?.nodeTapCallback;
  if (callback == null ||
      options == null ||
      node.kind == TagflowNodeKind.link ||
      !options.tapTargetKinds.contains(node.kind)) {
    return child;
  }

  return _TagflowTapTarget(
    button: true,
    onTap: () {
      callback(TagflowNodeTapDetails(context: context, node: node));
    },
    child: child,
  );
}

/// A tap target that the keyboard can reach: it takes focus, shows a focus
/// ring while focused, and activates with Enter or Space, besides a tap.
final class _TagflowTapTarget extends StatefulWidget {
  const _TagflowTapTarget({
    required this.onTap,
    required this.child,
    this.button = false,
    this.link = false,
    this.expanded,
  });

  final VoidCallback? onTap;
  final Widget child;
  final bool button;
  final bool link;
  final bool? expanded;

  @override
  State<_TagflowTapTarget> createState() => _TagflowTapTargetState();
}

final class _TagflowTapTargetState extends State<_TagflowTapTarget> {
  bool _showFocus = false;

  late final Map<Type, Action<Intent>> _actions = {
    ActivateIntent: CallbackAction<ActivateIntent>(
      onInvoke: (_) {
        widget.onTap?.call();
        return null;
      },
    ),
  };

  @override
  Widget build(BuildContext context) {
    final onTap = widget.onTap;
    final enabled = onTap != null;
    final ring =
        _theme(context).linkStyle?.color ??
        DefaultTextStyle.of(context).style.color ??
        const Color(0xFF1A73E8);
    return Semantics(
      button: widget.button,
      link: widget.link,
      expanded: widget.expanded,
      child: FocusableActionDetector(
        enabled: enabled,
        actions: _actions,
        mouseCursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
        onShowFocusHighlight: (value) => setState(() => _showFocus = value),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: onTap,
          child: DecoratedBox(
            position: DecorationPosition.foreground,
            decoration: _showFocus
                ? BoxDecoration(
                    border: Border.all(color: ring, width: 2),
                    borderRadius: BorderRadius.circular(2),
                  )
                : const BoxDecoration(),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// View options from the nearest [TagflowScope], or the defaults when the
/// registry renders outside a `Tagflow` widget.
TagflowViewOptions _viewOptionsOf(BuildContext context) {
  return TagflowViewOptions.maybeOf(context) ?? TagflowViewOptions.defaults;
}

/// Applies source inline styling (for example safe HTML inline CSS) around a
/// built-in component. Inline runs get the same styling as text spans in
/// [_InlineSpanBuilder].
Widget _applyInlineStyle(
  BuildContext context,
  TagflowDocumentNode node,
  TagflowInlineStyle inlineStyle,
  Widget child,
) {
  final textStyle = _textStyleFromInline(
    context,
    inlineStyle,
    includeBackground: false,
  );
  final textAlign = _flutterTextAlign(inlineStyle.textAlign);
  var current = child;
  if (textStyle != null || textAlign != null) {
    current = DefaultTextStyle.merge(
      style: textStyle,
      textAlign: textAlign,
      child: current,
    );
  }

  final isBlock = !_isInlineNode(node);
  final alignment = switch (inlineStyle.textAlign) {
    TagflowTextAlign.center => Alignment.topCenter,
    TagflowTextAlign.right => Alignment.topRight,
    TagflowTextAlign.end => AlignmentDirectional.topEnd,
    _ => null,
  };
  // A short line only moves when its box is as wide as the block.
  if (isBlock && alignment != null) {
    current = Align(alignment: alignment, child: current);
  }

  final background = inlineStyle.backgroundColor;
  if (background != null) {
    current = DecoratedBox(
      decoration: BoxDecoration(color: Color(background)),
      child: current,
    );
  }
  return current;
}

TextStyle? _textStyleFromInline(
  BuildContext context,
  TagflowInlineStyle? inlineStyle, {
  bool includeBackground = true,
}) {
  if (inlineStyle == null || inlineStyle.isEmpty) return null;
  final decorations = inlineStyle.decorations;
  final factor = inlineStyle.fontSizeFactor;
  final style = TextStyle(
    color: switch (inlineStyle.color) {
      final color? => Color(color),
      null => null,
    },
    backgroundColor: switch (inlineStyle.backgroundColor) {
      final color? when includeBackground => Color(color),
      _ => null,
    },
    fontWeight: switch (inlineStyle.fontWeight) {
      final weight? => FontWeight.values[(weight ~/ 100 - 1).clamp(0, 8)],
      null => null,
    },
    fontStyle: switch (inlineStyle.italic) {
      true => FontStyle.italic,
      false => FontStyle.normal,
      null => null,
    },
    decoration: decorations == null
        ? null
        : TextDecoration.combine([
            for (final decoration in decorations)
              switch (decoration) {
                TagflowTextDecoration.underline => TextDecoration.underline,
                TagflowTextDecoration.overline => TextDecoration.overline,
                TagflowTextDecoration.lineThrough => TextDecoration.lineThrough,
              },
          ]),
    fontSize:
        inlineStyle.fontSize ??
        (factor == null ? null : _relativeFontSize(context, factor)),
  );
  return style == const TextStyle() ? null : style;
}

TextAlign? _flutterTextAlign(TagflowTextAlign? align) {
  return switch (align) {
    TagflowTextAlign.start => TextAlign.start,
    TagflowTextAlign.end => TextAlign.end,
    TagflowTextAlign.left => TextAlign.left,
    TagflowTextAlign.right => TextAlign.right,
    TagflowTextAlign.center => TextAlign.center,
    TagflowTextAlign.justify => TextAlign.justify,
    null => null,
  };
}

/// The resolved render theme the built-in components read.
TagflowRenderTheme _theme(BuildContext context) {
  return TagflowRenderTheme.of(context);
}

/// [factor] times the ambient font size, for text that is smaller than its
/// surroundings (`small`, `sub`, `sup`, placeholder labels).
double _relativeFontSize(BuildContext context, double factor) {
  return (DefaultTextStyle.of(context).style.fontSize ?? 14) * factor;
}

/// Ratio used for `small`, `sub` and `sup` text.
const _smallTextFactor = 0.85;

final Map<TagflowNodeKind, TagflowComponentBuilder> _builtInComponents = {
  TagflowNodeKind.root: _renderRoot,
  TagflowNodeKind.container: _renderContainer,
  TagflowNodeKind.paragraph: _renderParagraph,
  TagflowNodeKind.heading: _renderHeading,
  TagflowNodeKind.text: _renderText,
  TagflowNodeKind.link: _renderLink,
  TagflowNodeKind.list: _renderList,
  TagflowNodeKind.listItem: _renderListItem,
  TagflowNodeKind.descriptionList: _renderDescriptionList,
  TagflowNodeKind.descriptionTerm: _renderDescriptionTerm,
  TagflowNodeKind.descriptionDetails: _renderDescriptionDetails,
  TagflowNodeKind.blockquote: _renderBlockquote,
  TagflowNodeKind.disclosure: _renderDisclosure,
  TagflowNodeKind.disclosureSummary: _renderDisclosureSummary,
  TagflowNodeKind.callout: _renderCallout,
  TagflowNodeKind.codeBlock: _renderCodeBlock,
  TagflowNodeKind.inlineCode: _renderInlineCode,
  TagflowNodeKind.image: _renderImage,
  TagflowNodeKind.table: _renderTable,
  TagflowNodeKind.tableRow: _renderTableRow,
  TagflowNodeKind.tableCell: _renderTableCell,
  TagflowNodeKind.tableCaption: _renderTableCaptionNode,
  TagflowNodeKind.horizontalRule: _renderHorizontalRule,
  TagflowNodeKind.unsupported: _renderUnsupported,
};

Widget _renderContainer(
  TagflowComponentContext context,
  TagflowDocumentNode node,
) {
  final child = _isInlineContainer(node)
      ? _renderInlineChildren(context, node)
      : _renderBlockChildren(context, node);

  return _applyInlinePresentation(
    context.buildContext,
    node.presentation,
    child,
  );
}

/// Renders a disclosure summary on its own, outside a disclosure.
///
/// Inside a disclosure the summary is rendered as the disclosure title.
Widget _renderDisclosureSummary(
  TagflowComponentContext context,
  TagflowDocumentNode node,
) {
  return _applyInlinePresentation(
    context.buildContext,
    node.presentation,
    _renderInlineChildren(context, node),
  );
}

Widget _renderDisclosure(
  TagflowComponentContext context,
  TagflowDocumentNode node,
) {
  TagflowDocumentNode? summary;
  final body = <TagflowDocumentNode>[];
  for (final child in node.children) {
    if (summary == null && child.kind == TagflowNodeKind.disclosureSummary) {
      summary = child;
      continue;
    }
    body.add(child);
  }

  return _TagflowDisclosure(
    initiallyExpanded: node.expanded,
    title: summary == null
        ? const Text('Details')
        : DefaultTextStyle.merge(
            style: const TextStyle(fontWeight: FontWeight.w600),
            child: context.render(summary),
          ),
    body: [for (final child in body) context.render(child)],
  );
}

Widget _renderRoot(TagflowComponentContext context, TagflowDocumentNode node) {
  return DefaultTextStyle.merge(
    style: _theme(context.buildContext).textStyle,
    child: _renderBlockChildren(context, node),
  );
}

/// Renders [node]'s children as stacked blocks.
///
/// Consecutive inline children, such as the bare text and emphasis runs of a
/// tight Markdown list item, are merged into one flowing text run instead of
/// one line each.
Widget _renderBlockChildren(
  TagflowComponentContext context,
  TagflowDocumentNode node,
) {
  final children = <Widget>[];
  var inlineRun = <TagflowDocumentNode>[];

  void flushInlineRun() {
    if (inlineRun.isEmpty) return;
    children.add(
      _TagflowInlineText(
        key: ValueKey<String>('${inlineRun.first.id}:inline'),
        context: context,
        nodes: inlineRun,
      ),
    );
    inlineRun = <TagflowDocumentNode>[];
  }

  for (final child in node.children) {
    if (_isInlineNode(child)) {
      inlineRun.add(child);
      continue;
    }
    flushInlineRun();
    children.add(context.render(child));
  }
  flushInlineRun();

  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: children,
  );
}

/// Renders [node]'s children as one flowing text run, so inline content wraps
/// word by word like prose instead of run by run.
Widget _renderInlineChildren(
  TagflowComponentContext context,
  TagflowDocumentNode node,
) {
  return _TagflowInlineText(context: context, nodes: node.children);
}

Widget _renderParagraph(
  TagflowComponentContext context,
  TagflowDocumentNode node,
) {
  final theme = _theme(context.buildContext);
  return Padding(
    padding: EdgeInsets.only(bottom: theme.paragraphSpacing!),
    child: DefaultTextStyle.merge(
      style: theme.paragraphStyle,
      child: _renderInlineChildren(context, node),
    ),
  );
}

Widget _renderHeading(
  TagflowComponentContext context,
  TagflowDocumentNode node,
) {
  final level = (node.level ?? 1).clamp(1, 6);
  final style = _theme(context.buildContext).headingStyle(level);

  return Semantics(
    header: true,
    headingLevel: level,
    child: DefaultTextStyle.merge(
      style: style,
      child: _renderInlineChildren(context, node),
    ),
  );
}

Widget _renderText(TagflowComponentContext context, TagflowDocumentNode node) {
  return _applyInlinePresentation(
    context.buildContext,
    node.presentation,
    Text(node.text ?? ''),
  );
}

Widget _renderLink(TagflowComponentContext context, TagflowDocumentNode node) {
  final options = _viewOptionsOf(context.buildContext);
  final linkAttributes = _linkAttributes(node);

  return _TagflowTapTarget(
    link: true,
    onTap: node.url == null
        ? null
        : () => options.linkTapCallback?.call(
            node.url.toString(),
            linkAttributes,
          ),
    child: DefaultTextStyle.merge(
      style: _theme(context.buildContext).linkStyle,
      child: _renderInlineChildren(context, node),
    ),
  );
}

Widget _renderList(TagflowComponentContext context, TagflowDocumentNode node) {
  final startIndex = node.startIndex ?? 1;
  final children = <Widget>[];

  for (var index = 0; index < node.children.length; index++) {
    final child = node.children[index];
    if (child.kind == TagflowNodeKind.listItem) {
      final row = _renderListRow(
        context,
        child,
        marker:
            _taskMarker(child) ??
            ((node.ordered ?? false) ? '${startIndex + index}.' : '•'),
      );
      children.add(
        KeyedSubtree(
          key: ValueKey<String>(child.id),
          child: _wrapNodeTapTarget(context.buildContext, child, row),
        ),
      );
      continue;
    }
    children.add(context.render(child));
  }

  return Padding(
    padding: EdgeInsets.only(
      bottom: _theme(context.buildContext).paragraphSpacing!,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  );
}

Widget _renderListItem(
  TagflowComponentContext context,
  TagflowDocumentNode node,
) {
  return _renderListRow(context, node, marker: _taskMarker(node) ?? '•');
}

/// Checkbox marker for task list items, such as GFM `- [x] done`.
String? _taskMarker(TagflowDocumentNode node) {
  return switch (node.checked) {
    true => '☑',
    false => '☐',
    _ => null,
  };
}

Widget _renderListRow(
  TagflowComponentContext context,
  TagflowDocumentNode node, {
  required String marker,
}) {
  return Padding(
    padding: EdgeInsets.only(
      bottom: _theme(context.buildContext).listItemSpacing!,
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8, top: 1),
          child: Text(
            marker,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(child: _renderBlockChildren(context, node)),
      ],
    ),
  );
}

Widget _renderDescriptionList(
  TagflowComponentContext context,
  TagflowDocumentNode node,
) {
  return Padding(
    padding: EdgeInsets.only(
      bottom: _theme(context.buildContext).paragraphSpacing!,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: context.renderChildren(node),
    ),
  );
}

Widget _renderDescriptionTerm(
  TagflowComponentContext context,
  TagflowDocumentNode node,
) {
  return Padding(
    padding: EdgeInsets.only(
      top: _theme(context.buildContext).listItemSpacing!,
    ),
    child: DefaultTextStyle.merge(
      style: _theme(context.buildContext).strongStyle,
      child: _renderInlineChildren(context, node),
    ),
  );
}

Widget _renderDescriptionDetails(
  TagflowComponentContext context,
  TagflowDocumentNode node,
) {
  return Padding(
    padding: const EdgeInsets.only(left: 16, bottom: 6),
    child: _renderBlockChildren(context, node),
  );
}

Widget _renderBlockquote(
  TagflowComponentContext context,
  TagflowDocumentNode node,
) {
  final theme = _theme(context.buildContext);
  final spacing = theme.blockSpacing!;
  return Padding(
    padding: EdgeInsets.only(bottom: spacing),
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: theme.quoteBackgroundColor,
        border: Border(
          left: BorderSide(color: theme.quoteBorderColor!, width: 4),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(spacing + 4, spacing, spacing, spacing),
        child: DefaultTextStyle.merge(
          style: theme.blockquoteStyle,
          child: _renderBlockChildren(context, node),
        ),
      ),
    ),
  );
}

Widget _renderCallout(
  TagflowComponentContext context,
  TagflowDocumentNode node,
) {
  final theme = _theme(context.buildContext);
  final spacing = theme.blockSpacing!;
  final accent = theme.calloutColor(node.tone)!;
  final title = node.title;
  return Padding(
    padding: EdgeInsets.only(bottom: spacing),
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: accent.withAlpha(0x1A),
        border: Border(left: BorderSide(color: accent, width: 4)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(spacing + 4, spacing, spacing, spacing),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null && title.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(bottom: theme.paragraphSpacing!),
                child: Text(
                  title,
                  style: theme.strongStyle!.copyWith(color: accent),
                ),
              ),
            _renderBlockChildren(context, node),
          ],
        ),
      ),
    ),
  );
}

Widget _renderCodeBlock(
  TagflowComponentContext context,
  TagflowDocumentNode node,
) {
  final theme = _theme(context.buildContext);
  final options =
      TagflowViewOptions.maybeOf(context.buildContext)?.codeBlock ??
      const TagflowCodeBlockOptions();

  return Padding(
    padding: EdgeInsets.only(bottom: theme.blockSpacing!),
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: theme.codeBackgroundColor,
        border: Border.all(color: theme.borderColor!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: _TagflowCodeBlock(
        node: node,
        options: options,
        style: theme.codeBlockStyle!,
      ),
    ),
  );
}

Widget _renderInlineCode(
  TagflowComponentContext context,
  TagflowDocumentNode node,
) {
  final theme = _theme(context.buildContext);
  return DecoratedBox(
    decoration: BoxDecoration(
      color: theme.codeBackgroundColor,
      borderRadius: BorderRadius.circular(4),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Text(node.text ?? '', style: theme.inlineCodeStyle),
    ),
  );
}

Widget _renderImage(TagflowComponentContext context, TagflowDocumentNode node) {
  final url = node.url;
  if (url == null) return const SizedBox.shrink();
  final options = _viewOptionsOf(context.buildContext);

  final image = Image.network(
    url.toString(),
    width: _clampDimension(node.width, options.maxImageWidth),
    height: _clampDimension(node.height, options.maxImageHeight),
    semanticLabel: node.alt,
    // An empty alt marks a decorative image, as in HTML.
    excludeFromSemantics: node.alt?.isEmpty ?? false,
    loadingBuilder: options.imageLoadingBuilder,
    errorBuilder: options.imageErrorBuilder,
  );
  if (!options.selectable.enabled) return image;

  // Inside a SelectionArea the image takes part in the selection, and
  // copying gives the text from imageSelectionBehavior.
  return TagflowSelectableAdapter(
    text: options.selectable.imageSelectionText(node, context.buildContext),
    child: image,
  );
}

Widget _renderTable(TagflowComponentContext context, TagflowDocumentNode node) {
  final rows = node.children
      .where((child) => child.kind == TagflowNodeKind.tableRow)
      .toList(growable: false);
  final grid = _tableGrid(rows);
  final theme = _theme(context.buildContext);
  final table = Padding(
    padding: EdgeInsets.only(bottom: theme.blockSpacing!),
    child: Table(
      border: TableBorder.all(color: theme.borderColor!),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        for (final row in grid)
          TableRow(
            children: [
              for (final cell in row)
                cell == null ? const SizedBox.shrink() : context.render(cell),
            ],
          ),
      ],
    ),
  );
  final caption = _renderTableCaption(context, node);

  if (caption == null) {
    return table;
  }

  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [caption, table],
  );
}

/// Lays [rows] out on a plain grid for the core table renderer.
///
/// The core renderer does not merge cells: a cell that spans columns or rows
/// keeps its first slot, and the slots it covers, plus the end of short rows,
/// are filled with empty cells (`null`). Register `tagflowTableComponents()`
/// from `package:tagflow_table` for real `rowspan` and `colspan` layout.
List<List<TagflowDocumentNode?>> _tableGrid(List<TagflowDocumentNode> rows) {
  // Spans are clamped as the HTML specification clamps them (colspan 1000,
  // rowspan 65534) and the grid is at most 1000 columns wide, so a document
  // built by hand cannot ask for an unbounded grid.
  int span(int value, int max) => value < 1 ? 1 : (value > max ? max : value);
  int colSpanOf(TagflowDocumentNode cell) => span(cell.colSpan, 1000);
  int rowSpanOf(TagflowDocumentNode cell) => span(cell.rowSpan, 65534);

  var columns = 0;
  for (final row in rows) {
    var width = 0;
    for (final cell in row.children) {
      if (cell.kind == TagflowNodeKind.tableCell) width += colSpanOf(cell);
    }
    if (width > columns) columns = width;
  }
  if (columns > 1000) columns = 1000;

  final occupiedThroughRow = <int, int>{};
  final grid = <List<TagflowDocumentNode?>>[];
  for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) {
    final slots = List<TagflowDocumentNode?>.filled(columns, null);
    var column = 0;
    for (final cell in rows[rowIndex].children) {
      if (cell.kind != TagflowNodeKind.tableCell) continue;
      while (column < columns &&
          (occupiedThroughRow[column] ?? -1) >= rowIndex) {
        column++;
      }
      if (column >= columns) break;
      slots[column] = cell;
      final colSpan = colSpanOf(cell);
      final rowSpan = rowSpanOf(cell);
      for (var c = column; c < column + colSpan && c < columns; c++) {
        occupiedThroughRow[c] = rowIndex + rowSpan - 1;
      }
      column += colSpan;
    }
    grid.add(slots);
  }

  return grid;
}

Widget? _renderTableCaption(
  TagflowComponentContext context,
  TagflowDocumentNode table,
) {
  for (final child in table.children) {
    if (child.kind == TagflowNodeKind.tableCaption) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: _theme(context.buildContext).paragraphSpacing!,
        ),
        child: DefaultTextStyle.merge(
          style: const TextStyle(fontWeight: FontWeight.w600),
          child: context.render(child),
        ),
      );
    }
  }

  return null;
}

/// Renders the content of a table caption; the table places it.
Widget _renderTableCaptionNode(
  TagflowComponentContext context,
  TagflowDocumentNode node,
) {
  return _applyInlinePresentation(
    context.buildContext,
    node.presentation,
    _renderBlockChildren(context, node),
  );
}

Widget _renderTableRow(
  TagflowComponentContext context,
  TagflowDocumentNode node,
) {
  return Row(children: context.renderChildren(node));
}

Widget _renderTableCell(
  TagflowComponentContext context,
  TagflowDocumentNode node,
) {
  final child = Padding(
    padding: const EdgeInsets.all(8),
    child: _renderBlockChildren(context, node),
  );

  final theme = _theme(context.buildContext);
  final cell = DecoratedBox(
    decoration: BoxDecoration(
      color: node.header ? theme.tableHeaderBackgroundColor : null,
    ),
    child: node.header
        ? DefaultTextStyle.merge(style: theme.tableHeaderStyle, child: child)
        : child,
  );
  return node.header ? _tableHeaderSemantics(cell) : cell;
}

Widget _renderHorizontalRule(
  TagflowComponentContext context,
  TagflowDocumentNode node,
) {
  return Container(
    height: 1,
    width: double.infinity,
    color: _theme(context.buildContext).borderColor,
  );
}

Widget _renderUnsupported(
  TagflowComponentContext context,
  TagflowDocumentNode node,
) {
  if (node.children.isNotEmpty) {
    return _defaultFallback(context, node);
  }

  final theme = _theme(context.buildContext);
  final ink = DefaultTextStyle.of(context.buildContext).style.color;
  return Semantics(
    label: 'Unsupported content',
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: theme.codeBackgroundColor,
        border: Border.all(color: theme.borderColor!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          'Unsupported content',
          style: TextStyle(
            fontSize: _relativeFontSize(context.buildContext, _smallTextFactor),
            color: ink?.withAlpha(0x99),
          ),
        ),
      ),
    ),
  );
}

Widget _defaultFallback(
  TagflowComponentContext context,
  TagflowDocumentNode node,
) {
  if (node.children.isEmpty) {
    return const SizedBox.shrink();
  }

  final child = _isInlineDisplay(node)
      ? _renderInlineChildren(context, node)
      : _renderBlockChildren(context, node);

  return _applyInlinePresentation(
    context.buildContext,
    node.presentation,
    child,
  );
}

Widget _applyInlinePresentation(
  BuildContext context,
  TagflowPresentation presentation,
  Widget child,
) {
  final semantics = presentation.inlineSemantics;
  if (semantics.isEmpty) return child;

  var current = child;
  final textStyle = _inlineTextStyle(context, semantics);
  if (textStyle != null) {
    current = DefaultTextStyle.merge(style: textStyle, child: current);
  }

  if (semantics.contains(TagflowInlineSemantic.highlight)) {
    current = DecoratedBox(
      decoration: BoxDecoration(
        color: _theme(context).highlightColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: current,
    );
  }

  return current;
}

TextStyle? _inlineTextStyle(
  BuildContext context,
  Set<TagflowInlineSemantic> semantics,
) {
  if (semantics.isEmpty) return null;
  final theme = _theme(context);
  final decorations = <TextDecoration>[];
  if (semantics.contains(TagflowInlineSemantic.underline)) {
    decorations.add(TextDecoration.underline);
  }
  if (semantics.contains(TagflowInlineSemantic.deleted)) {
    decorations.add(TextDecoration.lineThrough);
  }

  var style = const TextStyle();
  if (semantics.contains(TagflowInlineSemantic.code)) {
    style = style.merge(theme.inlineCodeStyle);
  }
  if (semantics.contains(TagflowInlineSemantic.strong)) {
    style = style.merge(theme.strongStyle);
  }
  if (semantics.contains(TagflowInlineSemantic.emphasis)) {
    style = style.merge(theme.emphasisStyle);
  }
  style = style.merge(
    TextStyle(
      decoration: decorations.isEmpty
          ? null
          : TextDecoration.combine(decorations),
      fontSize:
          semantics.contains(TagflowInlineSemantic.small) ||
              semantics.contains(TagflowInlineSemantic.subscript) ||
              semantics.contains(TagflowInlineSemantic.superscript)
          ? _relativeFontSize(context, _smallTextFactor)
          : null,
    ),
  );

  return style == const TextStyle() ? null : style;
}

double? _clampDimension(double? value, double? maxValue) {
  if (value == null || maxValue == null) return value;
  return value > maxValue ? maxValue : value;
}

LinkedHashMap<String, String>? _linkAttributes(TagflowDocumentNode node) {
  final attributes = <String, String>{};
  final rawAttributes = node.metadata['htmlAttributes'];
  if (rawAttributes is Map) {
    for (final entry in rawAttributes.entries) {
      attributes['${entry.key}'] = '${entry.value}';
    }
  }

  if (node.url != null) {
    attributes.putIfAbsent('href', () => node.url.toString());
  }

  return attributes.isEmpty ? null : LinkedHashMap.of(attributes);
}

final class _TagflowDisclosure extends StatefulWidget {
  const _TagflowDisclosure({
    required this.initiallyExpanded,
    required this.title,
    required this.body,
  });

  final bool initiallyExpanded;
  final Widget title;
  final List<Widget> body;

  @override
  State<_TagflowDisclosure> createState() => _TagflowDisclosureState();
}

final class _TagflowDisclosureState extends State<_TagflowDisclosure> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  void didUpdateWidget(_TagflowDisclosure oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initiallyExpanded != widget.initiallyExpanded) {
      _expanded = widget.initiallyExpanded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TagflowTapTarget(
            button: true,
            expanded: _expanded,
            onTap: () => setState(() {
              _expanded = !_expanded;
            }),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ExcludeSemantics(
                      child: _DisclosureChevron(expanded: _expanded),
                    ),
                  ),
                  Flexible(child: widget.title),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.body,
              ),
            ),
        ],
      ),
    );
  }
}

/// Whether [node] is a container that flows inline, such as `<strong>` or a
/// Markdown emphasis run.
///
/// An explicit [TagflowPresentation.display] wins; otherwise a container with
/// inline semantics flows inline.
bool _isInlineContainer(TagflowDocumentNode node) {
  return switch (node.presentation.display) {
    TagflowDisplay.inline => true,
    TagflowDisplay.block => false,
    null => node.presentation.inlineSemantics.isNotEmpty,
  };
}

/// Whether [node] asked to flow inline through
/// [TagflowPresentation.display].
bool _isInlineDisplay(TagflowDocumentNode node) {
  return node.presentation.display == TagflowDisplay.inline;
}

/// Whether [node] takes part in an inline text run inside a block.
bool _isInlineNode(TagflowDocumentNode node) {
  return switch (node.kind) {
    TagflowNodeKind.text ||
    TagflowNodeKind.inlineCode ||
    TagflowNodeKind.link => true,
    TagflowNodeKind.container => _isInlineContainer(node),
    TagflowNodeKind.unsupported =>
      node.children.isNotEmpty && _isInlineDisplay(node),
    _ => false,
  };
}

/// Paints inline [nodes] as a single [Text.rich] so runs of text, emphasis,
/// links and inline code wrap together like prose.
///
/// Nodes that need their own widget (app overrides, extension components,
/// node tap targets, images and block content) are embedded as [WidgetSpan]s
/// rendered through the registry, so registry precedence still holds.
final class _TagflowInlineText extends StatefulWidget {
  const _TagflowInlineText({
    required this.context,
    required this.nodes,
    super.key,
  });

  final TagflowComponentContext context;
  final List<TagflowDocumentNode> nodes;

  @override
  State<_TagflowInlineText> createState() => _TagflowInlineTextState();
}

final class _TagflowInlineTextState extends State<_TagflowInlineText> {
  List<GestureRecognizer> _recognizers = const [];

  /// Focus nodes of the tappable links in this run, by link node id.
  Map<String, FocusNode> _linkFocusNodes = const {};

  /// The link whose keyboard focus highlight is showing.
  String? _highlightedLink;

  @override
  void dispose() {
    _disposeRecognizers(_recognizers);
    for (final node in _linkFocusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  FocusNode _linkFocusNode(String id, Map<String, FocusNode> used) {
    return used[id] ??=
        _linkFocusNodes[id] ?? FocusNode(debugLabel: 'Tagflow link $id');
  }

  void _setHighlightedLink(String id, {required bool highlighted}) {
    final next = highlighted
        ? id
        : (_highlightedLink == id ? null : _highlightedLink);
    if (next != _highlightedLink) setState(() => _highlightedLink = next);
  }

  void _retainLinkFocusNodes(Map<String, FocusNode> used) {
    for (final entry in _linkFocusNodes.entries) {
      if (!identical(used[entry.key], entry.value)) entry.value.dispose();
    }
    _linkFocusNodes = used;
  }

  @override
  Widget build(BuildContext context) {
    final previous = _recognizers;
    final usedFocusNodes = <String, FocusNode>{};
    final builder = _InlineSpanBuilder(
      widget.context,
      context,
      linkFocus: (id) => _linkFocusNode(id, usedFocusNodes),
      highlightedLink: _highlightedLink,
      onLinkHighlight: _setHighlightedLink,
    );
    final nodes = widget.nodes;
    if (nodes.length == 1 &&
        nodes.single.kind == TagflowNodeKind.text &&
        nodes.single.presentation.inlineSemantics.isEmpty &&
        builder._canFlow(nodes.single)) {
      _recognizers = const [];
      _disposeRecognizers(previous);
      _retainLinkFocusNodes(usedFocusNodes);
      return Text(nodes.single.text ?? '');
    }

    final spans = [for (final node in nodes) builder.build(node)];
    _recognizers = builder.recognizers;
    _disposeRecognizers(previous);
    _retainLinkFocusNodes(usedFocusNodes);

    Widget text = Text.rich(TextSpan(children: spans));
    final links = builder.links;
    if (links.isEmpty) return text;
    // One focus target per link, wrapped around the text so layout and the
    // text itself are unchanged. They share a rect, so an ordered group
    // keeps Tab in reading order.
    for (var index = links.length - 1; index >= 0; index--) {
      text = FocusTraversalOrder(
        order: NumericFocusOrder(index.toDouble()),
        child: links[index].wrap(text),
      );
    }
    return FocusTraversalGroup(policy: OrderedTraversalPolicy(), child: text);
  }

  static void _disposeRecognizers(List<GestureRecognizer> recognizers) {
    for (final recognizer in recognizers) {
      recognizer.dispose();
    }
  }
}

final class _InlineSpanBuilder {
  _InlineSpanBuilder(
    this.context,
    this.buildContext, {
    required this.linkFocus,
    required this.highlightedLink,
    required this.onLinkHighlight,
  });

  final TagflowComponentContext context;
  final BuildContext buildContext;
  final List<GestureRecognizer> recognizers = [];

  /// Keyboard focus targets for the tappable links, in reading order.
  final List<_InlineLinkFocusTarget> links = [];
  final FocusNode Function(String linkId) linkFocus;
  final String? highlightedLink;
  final void Function(String linkId, {required bool highlighted})
  onLinkHighlight;

  late final TagflowViewOptions? _viewOptions = TagflowViewOptions.maybeOf(
    buildContext,
  );
  late final TagflowRenderTheme _renderTheme = _theme(buildContext);

  InlineSpan build(
    TagflowDocumentNode node, {
    GestureRecognizer? recognizer,
    MouseCursor? mouseCursor,
  }) {
    if (!_canFlow(node)) {
      return WidgetSpan(
        alignment: node.kind == TagflowNodeKind.image
            ? PlaceholderAlignment.middle
            : PlaceholderAlignment.baseline,
        baseline: TextBaseline.alphabetic,
        child: context.render(node),
      );
    }

    switch (node.kind) {
      case TagflowNodeKind.text:
        return TextSpan(
          text: node.text ?? '',
          style: _presentationStyle(node.presentation),
          recognizer: recognizer,
          mouseCursor: mouseCursor,
        );
      case TagflowNodeKind.inlineCode:
        return TextSpan(
          text: node.text ?? '',
          style: _renderTheme.inlineCodeStyle!.merge(
            TextStyle(backgroundColor: _renderTheme.codeBackgroundColor),
          ),
          recognizer: recognizer,
          mouseCursor: mouseCursor,
        );
      case TagflowNodeKind.link:
        if (!_canFlowSubtree(node)) {
          // A link around an image or other widget keeps its gesture
          // wrapper so the whole subtree stays tappable.
          return WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: context.render(node),
          );
        }
        final url = node.url;
        final callback = _viewOptions?.linkTapCallback;
        var linkRecognizer = recognizer;
        VoidCallback? activate;
        if (url != null && callback != null) {
          final attributes = _linkAttributes(node);
          activate = () => callback(url.toString(), attributes);
          linkRecognizer = TapGestureRecognizer()..onTap = activate;
          recognizers.add(linkRecognizer);
        }
        var style = _renderTheme.linkStyle!.merge(
          _presentationStyle(node.presentation),
        );
        if (highlightedLink == node.id) {
          // Text spans cannot take focus, so a focus target wraps the text
          // for each link and the link text shows the focus.
          style = style.merge(
            TextStyle(
              backgroundColor: (style.color ?? const Color(0xFF1A73E8))
                  .withAlpha(0x33),
            ),
          );
        }
        final link = TextSpan(
          style: style,
          children: _children(
            node,
            recognizer: linkRecognizer,
            mouseCursor: url == null ? mouseCursor : SystemMouseCursors.click,
          ),
        );
        if (activate != null) {
          links.add(
            _InlineLinkFocusTarget(
              focusNode: linkFocus(node.id),
              onActivate: activate,
              onHighlight: (value) =>
                  onLinkHighlight(node.id, highlighted: value),
            ),
          );
        }
        return link;
      case _:
        return TextSpan(
          style: _presentationStyle(node.presentation),
          children: _children(
            node,
            recognizer: recognizer,
            mouseCursor: mouseCursor,
          ),
        );
    }
  }

  List<InlineSpan> _children(
    TagflowDocumentNode node, {
    required GestureRecognizer? recognizer,
    required MouseCursor? mouseCursor,
  }) {
    return [
      for (final child in node.children)
        build(child, recognizer: recognizer, mouseCursor: mouseCursor),
    ];
  }

  /// Whether [node] can be painted as a [TextSpan] by the built-in inline
  /// renderer rather than embedded as its own widget.
  bool _canFlow(TagflowDocumentNode node) {
    if (!_isInlineNode(node)) return false;
    if (!identical(
      context.registry._components[node.kind] ??
          context.registry._fallbackBuilder,
      _builtInComponents[node.kind] ?? _defaultFallback,
    )) {
      return false;
    }

    final options = _viewOptions;
    if (options?.nodeTapCallback != null &&
        node.kind != TagflowNodeKind.link &&
        options!.tapTargetKinds.contains(node.kind)) {
      return false;
    }
    return true;
  }

  bool _canFlowSubtree(TagflowDocumentNode node) {
    return node.children.every(
      (child) => _canFlow(child) && _canFlowSubtree(child),
    );
  }

  TextStyle? _presentationStyle(TagflowPresentation presentation) {
    final semantics = presentation.inlineSemantics;
    var style = _inlineTextStyle(buildContext, semantics);
    if (semantics.contains(TagflowInlineSemantic.highlight)) {
      style = (style ?? const TextStyle()).copyWith(
        backgroundColor: _renderTheme.highlightColor,
      );
    }
    final inline = _textStyleFromInline(buildContext, presentation.inlineStyle);
    if (inline == null) return style;
    return (style ?? const TextStyle()).merge(inline);
  }
}

/// Keyboard focus target for a link painted as a text span.
///
/// Enter or Space activates the link. Screen readers use the span's own link
/// semantics, so the target adds no semantics node of its own.
final class _InlineLinkFocusTarget {
  const _InlineLinkFocusTarget({
    required this.focusNode,
    required this.onActivate,
    required this.onHighlight,
  });

  final FocusNode focusNode;
  final VoidCallback onActivate;
  final ValueChanged<bool> onHighlight;

  Widget wrap(Widget child) {
    return FocusableActionDetector(
      focusNode: focusNode,
      includeFocusSemantics: false,
      onShowFocusHighlight: onHighlight,
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            onActivate();
            return null;
          },
        ),
      },
      child: child,
    );
  }
}

final class _TagflowCodeBlock extends StatefulWidget {
  const _TagflowCodeBlock({
    required this.node,
    required this.options,
    required this.style,
  });

  /// Code text style from the render theme.
  final TextStyle style;

  final TagflowDocumentNode node;
  final TagflowCodeBlockOptions options;

  @override
  State<_TagflowCodeBlock> createState() => _TagflowCodeBlockState();
}

final class _TagflowCodeBlockState extends State<_TagflowCodeBlock> {
  static const _copiedDuration = Duration(seconds: 2);

  Timer? _copiedTimer;
  bool _copied = false;

  String get _source => widget.node.text ?? '';

  String? get _language =>
      TagflowCodeBlockOptions.normalizeLanguage(widget.node.language);

  @override
  void dispose() {
    _copiedTimer?.cancel();
    super.dispose();
  }

  Future<void> _copy() async {
    final source = _source;
    await Clipboard.setData(ClipboardData(text: source));
    widget.options.onCopy?.call(
      TagflowCodeCopyDetails(
        node: widget.node,
        source: source,
        language: _language,
      ),
    );
    if (!mounted) return;

    _copiedTimer?.cancel();
    _copiedTimer = Timer(_copiedDuration, () {
      if (mounted) setState(() => _copied = false);
    });
    setState(() => _copied = true);
  }

  Widget _buildSource(BuildContext context) {
    final style = DefaultTextStyle.of(context).style.merge(widget.style);
    final highlighted = widget.options.highlighter?.call(
      context,
      TagflowCodeHighlightRequest(
        node: widget.node,
        source: _source,
        language: _language,
        style: style,
      ),
    );

    if (highlighted == null) {
      return Text(_source, style: widget.style);
    }

    return Text.rich(TextSpan(style: widget.style, children: [highlighted]));
  }

  @override
  Widget build(BuildContext context) {
    final source = Padding(
      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: _buildSource(context),
      ),
    );

    if (!widget.options.showCopyButton) return source;

    return Stack(
      children: [
        Padding(padding: const EdgeInsets.only(right: 56), child: source),
        Positioned(
          top: 4,
          right: 4,
          child: SelectionContainer.disabled(
            child: _TagflowCodeCopyButton(copied: _copied, onPressed: _copy),
          ),
        ),
      ],
    );
  }
}

final class _TagflowCodeCopyButton extends StatelessWidget {
  const _TagflowCodeCopyButton({required this.copied, required this.onPressed});

  final bool copied;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final label = copied ? 'Copied' : 'Copy';
    final ink = DefaultTextStyle.of(context).style.color;

    return Semantics(
      button: true,
      label: copied ? 'Code copied' : 'Copy code',
      excludeSemantics: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onPressed,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: _theme(context).codeBackgroundColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: _relativeFontSize(context, _smallTextFactor),
                  color: ink?.withAlpha(0x99),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A chevron that points right when collapsed and down when expanded.
///
/// Drawn rather than taken from an icon font, so the core package does not
/// depend on Material icons.
final class _DisclosureChevron extends StatelessWidget {
  const _DisclosureChevron({required this.expanded});

  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final style = DefaultTextStyle.of(context).style;
    final size = (style.fontSize ?? 14) * 0.75;
    return SizedBox(
      // Match the first line of the title.
      height: (style.fontSize ?? 14) * (style.height ?? 1.2),
      child: Center(
        child: AnimatedRotation(
          turns: expanded ? 0.25 : 0,
          duration: const Duration(milliseconds: 150),
          child: CustomPaint(
            size: Size.square(size),
            painter: _ChevronPainter(style.color ?? const Color(0xFF000000)),
          ),
        ),
      ),
    );
  }
}

final class _ChevronPainter extends CustomPainter {
  const _ChevronPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width / 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(size.width * 0.35, size.height * 0.2)
      ..lineTo(size.width * 0.7, size.height * 0.5)
      ..lineTo(size.width * 0.35, size.height * 0.8);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ChevronPainter oldDelegate) => oldDelegate.color != color;
}

/// Marks [cell] as a table column header for assistive technology.
///
/// Flutter's `Table` has no row semantics, so the header role is carried as
/// a hint read after the cell text rather than as a table role.
Widget _tableHeaderSemantics(Widget cell) {
  return Semantics(container: true, hint: 'Column header', child: cell);
}
