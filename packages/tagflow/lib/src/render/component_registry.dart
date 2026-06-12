import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:tagflow/src/runtime/runtime.dart';
import 'package:tagflow/src/tagflow_options.dart';

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
}

/// Registry for mapping semantic Tagflow node kinds to Flutter components.
///
/// Registry precedence is app overrides, extension registries, then built-in
/// core components.
final class TagflowComponentRegistry {
  /// Creates a registry with built-ins, optional [extensions], and app
  /// [overrides].
  factory TagflowComponentRegistry({
    Map<TagflowNodeKind, TagflowComponentBuilder> overrides = const {},
    Iterable<TagflowComponentRegistry> extensions = const [],
    TagflowComponentBuilder? fallbackBuilder,
  }) {
    return TagflowComponentRegistry._(
      components: {
        ...builtIn._components,
        for (final extension in extensions) ...extension._components,
        ...overrides,
      },
      fallbackBuilder: fallbackBuilder ?? builtIn._fallbackBuilder,
    );
  }

  /// Creates a registry fragment for first-party or app extension components.
  factory TagflowComponentRegistry.components({
    required Map<TagflowNodeKind, TagflowComponentBuilder> components,
    TagflowComponentBuilder? fallbackBuilder,
  }) {
    return TagflowComponentRegistry._(
      components: components,
      fallbackBuilder: fallbackBuilder,
    );
  }

  TagflowComponentRegistry._({
    required Map<TagflowNodeKind, TagflowComponentBuilder> components,
    required TagflowComponentBuilder? fallbackBuilder,
  }) : _components = Map.unmodifiable(components),
       _fallbackBuilder = fallbackBuilder;

  /// Built-in semantic components shipped by the core package.
  static final TagflowComponentRegistry builtIn = TagflowComponentRegistry._(
    components: _builtInComponents,
    fallbackBuilder: _defaultFallback,
  );

  final Map<TagflowNodeKind, TagflowComponentBuilder> _components;
  final TagflowComponentBuilder? _fallbackBuilder;

  /// Semantic node kinds with an explicitly registered component.
  Set<TagflowNodeKind> get registeredKinds =>
      Set.unmodifiable(_components.keys);

  /// Whether [kind] has an explicit component in this registry.
  bool hasComponent(TagflowNodeKind kind) {
    return _components.containsKey(kind);
  }

  /// Whether [kind] can be rendered by a component or fallback.
  bool canRender(TagflowNodeKind kind) {
    return hasComponent(kind) || _fallbackBuilder != null;
  }

  /// Renders [node] through this registry.
  Widget render(BuildContext context, TagflowDocumentNode node) {
    final builder = _components[node.kind] ?? _fallbackBuilder;
    if (builder == null) {
      throw UnsupportedError(
        'No Tagflow component registered for ${node.kind}.',
      );
    }

    final child = builder(
      TagflowComponentContext._(buildContext: context, registry: this),
      node,
    );

    return KeyedSubtree(
      key: ValueKey<String>(node.id),
      child: _wrapNodeTapTarget(context, node, child),
    );
  }
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

  return MouseRegion(
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        callback(TagflowNodeTapDetails(context: context, node: node));
      },
      child: child,
    ),
  );
}

final Map<TagflowNodeKind, TagflowComponentBuilder> _builtInComponents = {
  TagflowNodeKind.root: _renderBlockChildren,
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
  TagflowNodeKind.codeBlock: _renderCodeBlock,
  TagflowNodeKind.inlineCode: _renderInlineCode,
  TagflowNodeKind.image: _renderImage,
  TagflowNodeKind.table: _renderTable,
  TagflowNodeKind.tableRow: _renderTableRow,
  TagflowNodeKind.tableCell: _renderTableCell,
  TagflowNodeKind.horizontalRule: _renderHorizontalRule,
  TagflowNodeKind.unsupported: _renderUnsupported,
};

Widget _renderContainer(
  TagflowComponentContext context,
  TagflowDocumentNode node,
) {
  if (_htmlTag(node) == 'details') {
    return _renderDisclosure(context, node);
  }

  if (_htmlTag(node) == 'summary') {
    return _applyInlinePresentation(
      node.presentation,
      Wrap(children: context.renderChildren(node)),
    );
  }

  final isInline =
      node.presentation.inlineSemantics.isNotEmpty ||
      _isInlineFallbackTag(_htmlTag(node));
  final child = isInline
      ? Wrap(children: context.renderChildren(node))
      : _renderBlockChildren(context, node);

  return _applyInlinePresentation(node.presentation, child);
}

Widget _renderDisclosure(
  TagflowComponentContext context,
  TagflowDocumentNode node,
) {
  TagflowDocumentNode? summary;
  final body = <TagflowDocumentNode>[];
  for (final child in node.children) {
    if (summary == null && _htmlTag(child) == 'summary') {
      summary = child;
      continue;
    }
    body.add(child);
  }

  return _TagflowDisclosure(
    initiallyExpanded: _hasHtmlAttribute(node, 'open'),
    title: summary == null
        ? const Text('Details')
        : DefaultTextStyle.merge(
            style: const TextStyle(fontWeight: FontWeight.w600),
            child: context.render(summary),
          ),
    body: [for (final child in body) context.render(child)],
  );
}

Widget _renderBlockChildren(
  TagflowComponentContext context,
  TagflowDocumentNode node,
) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: context.renderChildren(node),
  );
}

Widget _renderParagraph(
  TagflowComponentContext context,
  TagflowDocumentNode node,
) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Wrap(children: context.renderChildren(node)),
  );
}

Widget _renderHeading(
  TagflowComponentContext context,
  TagflowDocumentNode node,
) {
  final level = node.level?.clamp(1, 6) ?? 1;
  final fontSize = switch (level) {
    1 => 32.0,
    2 => 28.0,
    3 => 24.0,
    4 => 20.0,
    5 => 18.0,
    _ => 16.0,
  };

  return DefaultTextStyle.merge(
    style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700),
    child: Wrap(children: context.renderChildren(node)),
  );
}

Widget _renderText(TagflowComponentContext context, TagflowDocumentNode node) {
  return _applyInlinePresentation(node.presentation, Text(node.text ?? ''));
}

Widget _renderLink(TagflowComponentContext context, TagflowDocumentNode node) {
  final options = TagflowOptions.of(context.buildContext);
  final linkAttributes = _linkAttributes(node);

  return Semantics(
    link: true,
    child: MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: node.url == null
            ? null
            : () => options.linkTapCallback?.call(
                node.url.toString(),
                linkAttributes,
              ),
        child: DefaultTextStyle.merge(
          style: const TextStyle(
            color: Color(0xFF0B57D0),
            decoration: TextDecoration.underline,
          ),
          child: Wrap(children: context.renderChildren(node)),
        ),
      ),
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
        marker: (node.ordered ?? false) ? '${startIndex + index}.' : '•',
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
    padding: const EdgeInsets.only(bottom: 8),
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
  return _renderListRow(context, node, marker: '•');
}

Widget _renderListRow(
  TagflowComponentContext context,
  TagflowDocumentNode node, {
  required String marker,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 4),
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
    padding: const EdgeInsets.only(bottom: 8),
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
    padding: const EdgeInsets.only(top: 4),
    child: DefaultTextStyle.merge(
      style: const TextStyle(fontWeight: FontWeight.w700),
      child: Wrap(children: context.renderChildren(node)),
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
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0x14000000),
        border: Border(left: BorderSide(color: Color(0x661F4B99), width: 4)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
        child: _renderBlockChildren(context, node),
      ),
    ),
  );
}

Widget _renderCodeBlock(
  TagflowComponentContext context,
  TagflowDocumentNode node,
) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x12000000),
        border: Border.all(color: const Color(0x1F000000)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text(
            node.text ?? '',
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ),
      ),
    ),
  );
}

Widget _renderInlineCode(
  TagflowComponentContext context,
  TagflowDocumentNode node,
) {
  return DecoratedBox(
    decoration: BoxDecoration(
      color: const Color(0x12000000),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Text(
        node.text ?? '',
        style: const TextStyle(fontFamily: 'monospace'),
      ),
    ),
  );
}

Widget _renderImage(TagflowComponentContext context, TagflowDocumentNode node) {
  final url = node.url;
  if (url == null) return const SizedBox.shrink();
  final options = TagflowOptions.of(context.buildContext);

  return Image.network(
    url.toString(),
    width: _clampDimension(node.width, options.maxImageWidth),
    height: _clampDimension(node.height, options.maxImageHeight),
    semanticLabel: node.alt,
    loadingBuilder: options.imageLoadingBuilder,
    errorBuilder: options.imageErrorBuilder,
  );
}

Widget _renderTable(TagflowComponentContext context, TagflowDocumentNode node) {
  final rows = node.children.where(
    (child) => child.kind == TagflowNodeKind.tableRow,
  );
  final table = Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Table(
      border: TableBorder.all(color: const Color(0x1F000000)),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        for (final row in rows)
          TableRow(
            children: [for (final cell in row.children) context.render(cell)],
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

Widget? _renderTableCaption(
  TagflowComponentContext context,
  TagflowDocumentNode table,
) {
  for (final child in table.children) {
    if (_htmlTag(child) == 'caption') {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: DefaultTextStyle.merge(
          style: const TextStyle(fontWeight: FontWeight.w600),
          child: context.render(child),
        ),
      );
    }
  }

  return null;
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

  return DecoratedBox(
    decoration: BoxDecoration(
      color: node.header ? const Color(0x12000000) : null,
    ),
    child: node.header
        ? DefaultTextStyle.merge(
            style: const TextStyle(fontWeight: FontWeight.w700),
            child: child,
          )
        : child,
  );
}

Widget _renderHorizontalRule(
  TagflowComponentContext context,
  TagflowDocumentNode node,
) {
  return Container(
    height: 1,
    width: double.infinity,
    color: const Color(0x1F000000),
  );
}

Widget _renderUnsupported(
  TagflowComponentContext context,
  TagflowDocumentNode node,
) {
  if (node.children.isNotEmpty) {
    return _defaultFallback(context, node);
  }

  return Semantics(
    label: 'Unsupported content',
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x0F000000),
        border: Border.all(color: const Color(0x1F000000)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          'Unsupported content',
          style: TextStyle(fontSize: 12, color: Color(0x99000000)),
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

  final htmlTag = _htmlTag(node);
  final child = _isInlineFallbackTag(htmlTag)
      ? Wrap(children: context.renderChildren(node))
      : _renderBlockChildren(context, node);

  final textStyle = _fallbackTextStyle(htmlTag);
  if (textStyle != null) {
    return DefaultTextStyle.merge(style: textStyle, child: child);
  }

  if (htmlTag == 'mark') {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x33FFE082),
        borderRadius: BorderRadius.circular(4),
      ),
      child: child,
    );
  }

  return child;
}

Widget _applyInlinePresentation(
  TagflowPresentation presentation,
  Widget child,
) {
  final semantics = presentation.inlineSemantics;
  if (semantics.isEmpty) return child;

  var current = child;
  final textStyle = _inlineTextStyle(semantics);
  if (textStyle != null) {
    current = DefaultTextStyle.merge(style: textStyle, child: current);
  }

  if (semantics.contains(TagflowInlineSemantic.highlight)) {
    current = DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x33FFE082),
        borderRadius: BorderRadius.circular(4),
      ),
      child: current,
    );
  }

  return current;
}

TextStyle? _inlineTextStyle(Set<TagflowInlineSemantic> semantics) {
  final decorations = <TextDecoration>[];
  if (semantics.contains(TagflowInlineSemantic.underline)) {
    decorations.add(TextDecoration.underline);
  }
  if (semantics.contains(TagflowInlineSemantic.deleted)) {
    decorations.add(TextDecoration.lineThrough);
  }

  final style = TextStyle(
    fontWeight: semantics.contains(TagflowInlineSemantic.strong)
        ? FontWeight.w700
        : null,
    fontStyle: semantics.contains(TagflowInlineSemantic.emphasis)
        ? FontStyle.italic
        : null,
    decoration: decorations.isEmpty
        ? null
        : TextDecoration.combine(decorations),
    fontSize:
        semantics.contains(TagflowInlineSemantic.small) ||
            semantics.contains(TagflowInlineSemantic.subscript) ||
            semantics.contains(TagflowInlineSemantic.superscript)
        ? 12
        : null,
  );

  return style == const TextStyle() ? null : style;
}

double? _clampDimension(double? value, double? maxValue) {
  if (value == null || maxValue == null) return value;
  return value > maxValue ? maxValue : value;
}

String? _htmlTag(TagflowDocumentNode node) {
  final metadataTag = node.metadata['htmlTag'];
  if (metadataTag is String && metadataTag.isNotEmpty) {
    return metadataTag;
  }

  final hintTag = node.presentation.hints['htmlTag'];
  if (hintTag is String && hintTag.isNotEmpty) {
    return hintTag;
  }

  return null;
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

bool _hasHtmlAttribute(TagflowDocumentNode node, String attribute) {
  final rawAttributes = node.metadata['htmlAttributes'];
  if (rawAttributes is! Map) return false;
  return rawAttributes.keys.any((key) => '$key'.toLowerCase() == attribute);
}

bool _isInlineFallbackTag(String? htmlTag) {
  return switch (htmlTag) {
    'a' ||
    'b' ||
    'strong' ||
    'i' ||
    'em' ||
    'u' ||
    'span' ||
    'small' ||
    'mark' ||
    'del' ||
    'ins' ||
    'sub' ||
    'sup' => true,
    _ => false,
  };
}

TextStyle? _fallbackTextStyle(String? htmlTag) {
  return switch (htmlTag) {
    'b' || 'strong' => const TextStyle(fontWeight: FontWeight.w700),
    'i' || 'em' => const TextStyle(fontStyle: FontStyle.italic),
    'u' || 'ins' => const TextStyle(decoration: TextDecoration.underline),
    'del' => const TextStyle(decoration: TextDecoration.lineThrough),
    'small' => const TextStyle(fontSize: 12),
    'sub' => const TextStyle(fontSize: 12),
    'sup' => const TextStyle(fontSize: 12),
    _ => null,
  };
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
          Semantics(
            button: true,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
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
                      child: Text(_expanded ? 'v' : '>'),
                    ),
                    Flexible(child: widget.title),
                  ],
                ),
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
