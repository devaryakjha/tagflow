import 'package:flutter/widgets.dart';
import 'package:tagflow/src/runtime/runtime.dart';

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

    return builder(
      TagflowComponentContext._(buildContext: context, registry: this),
      node,
    );
  }
}

final Map<TagflowNodeKind, TagflowComponentBuilder> _builtInComponents = {
  TagflowNodeKind.root: _renderBlockChildren,
  TagflowNodeKind.container: _renderBlockChildren,
  TagflowNodeKind.paragraph: _renderParagraph,
  TagflowNodeKind.heading: _renderHeading,
  TagflowNodeKind.text: _renderText,
  TagflowNodeKind.link: _renderLink,
  TagflowNodeKind.list: _renderBlockChildren,
  TagflowNodeKind.listItem: _renderListItem,
  TagflowNodeKind.blockquote: _renderBlockquote,
  TagflowNodeKind.codeBlock: _renderCodeBlock,
  TagflowNodeKind.inlineCode: _renderInlineCode,
  TagflowNodeKind.image: _renderImage,
  TagflowNodeKind.table: _renderTable,
  TagflowNodeKind.tableRow: _renderTableRow,
  TagflowNodeKind.tableCell: _renderTableCell,
  TagflowNodeKind.horizontalRule: _renderHorizontalRule,
};

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
  return Text(node.text ?? '');
}

Widget _renderLink(TagflowComponentContext context, TagflowDocumentNode node) {
  return Semantics(
    link: true,
    child: DefaultTextStyle.merge(
      style: const TextStyle(
        color: Color(0xFF0B57D0),
        decoration: TextDecoration.underline,
      ),
      child: Wrap(children: context.renderChildren(node)),
    ),
  );
}

Widget _renderListItem(
  TagflowComponentContext context,
  TagflowDocumentNode node,
) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('- '),
      Expanded(child: _renderBlockChildren(context, node)),
    ],
  );
}

Widget _renderBlockquote(
  TagflowComponentContext context,
  TagflowDocumentNode node,
) {
  return Padding(
    padding: const EdgeInsets.only(left: 16),
    child: _renderBlockChildren(context, node),
  );
}

Widget _renderCodeBlock(
  TagflowComponentContext context,
  TagflowDocumentNode node,
) {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Text(
      node.text ?? '',
      style: const TextStyle(fontFamily: 'monospace'),
    ),
  );
}

Widget _renderInlineCode(
  TagflowComponentContext context,
  TagflowDocumentNode node,
) {
  return Text(node.text ?? '', style: const TextStyle(fontFamily: 'monospace'));
}

Widget _renderImage(TagflowComponentContext context, TagflowDocumentNode node) {
  final url = node.url;
  if (url == null) return const SizedBox.shrink();

  return Image.network(
    url.toString(),
    width: node.width,
    height: node.height,
    semanticLabel: node.alt,
  );
}

Widget _renderTable(TagflowComponentContext context, TagflowDocumentNode node) {
  final rows = node.children.where(
    (child) => child.kind == TagflowNodeKind.tableRow,
  );

  return Table(
    children: [
      for (final row in rows)
        TableRow(
          children: [for (final cell in row.children) context.render(cell)],
        ),
    ],
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
  return Padding(
    padding: const EdgeInsets.all(8),
    child: _renderBlockChildren(context, node),
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

Widget _defaultFallback(
  TagflowComponentContext context,
  TagflowDocumentNode node,
) {
  return const SizedBox.shrink();
}
