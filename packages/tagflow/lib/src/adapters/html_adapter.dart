import 'package:flutter/widgets.dart';
import 'package:tagflow/src/adapters/content_limits.dart';
import 'package:tagflow/src/adapters/html_dom.dart';
import 'package:tagflow/src/runtime/runtime.dart';
import 'package:tagflow/src/style/style_parser.dart';
import 'package:tagflow/src/tagflow_options.dart';

const _htmlAdapterName = 'html';
const _htmlTagKey = 'htmlTag';
const _blockedHtmlTagKey = 'blockedHtmlTag';
const _htmlAttributesKey = 'htmlAttributes';
const _policyDecisionReasonKey = 'policyDecisionReason';
const _tableRowCountKey = 'tableRowCount';
const _tableColumnCountKey = 'tableColumnCount';
const _tableBorderWidthHintKey = 'tableBorderWidth';
const _tableInsideBorderWidthHintKey = 'tableInsideBorderWidth';
const _tableBorderColorHintKey = 'tableBorderColor';
const _tableColumnSpacingHintKey = 'tableColumnSpacing';
const _tableRowSpacingHintKey = 'tableRowSpacing';
const _tableCellPaddingHintKey = 'tableCellPadding';
const _textAlignHintKey = 'textAlign';
const _defaultHtmlNodeIdAttribute = 'data-tagflow-id';

enum _TagflowHtmlNodeIdStrategyKind { path, attribute }

/// Configures how the HTML adapter assigns runtime node IDs.
@immutable
final class TagflowHtmlNodeIdStrategy {
  /// Uses deterministic path-based IDs for every adapted node.
  const TagflowHtmlNodeIdStrategy.path()
    : _kind = _TagflowHtmlNodeIdStrategyKind.path,
      attribute = null,
      fallbackToPath = true;

  /// Uses an HTML attribute when present and optionally falls back to path IDs.
  const TagflowHtmlNodeIdStrategy.attribute({
    this.attribute = _defaultHtmlNodeIdAttribute,
    this.fallbackToPath = true,
  }) : _kind = _TagflowHtmlNodeIdStrategyKind.attribute;

  final _TagflowHtmlNodeIdStrategyKind _kind;

  /// Attribute read for authored IDs in attribute mode.
  final String? attribute;

  /// Whether nodes without authored IDs fall back to path IDs.
  final bool fallbackToPath;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TagflowHtmlNodeIdStrategy &&
            other._kind == _kind &&
            other.attribute == attribute &&
            other.fallbackToPath == fallbackToPath;
  }

  @override
  int get hashCode => Object.hash(_kind, attribute, fallbackToPath);
}

/// Converts HTML input into the native Tagflow runtime document model.
///
/// Parses with `package:html` and maps the DOM onto runtime nodes, applying
/// [policy] on the way. It does not use the legacy parser or element
/// types.
@immutable
final class TagflowHtmlAdapter {
  /// Creates an HTML adapter.
  const TagflowHtmlAdapter({
    this.debug,
    this.renderBoundary,
    this.policy = TagflowContentPolicy.defaults,
    this.nodeIdStrategy = const TagflowHtmlNodeIdStrategy.path(),
  });

  /// Logs the parsed HTML body when true. Defaults to the view options'
  /// `debug` flag.
  final bool? debug;

  /// Renders only the content between the boundary's comment markers.
  final TagflowRenderBoundary? renderBoundary;

  /// Content policy used while adapting HTML into runtime document nodes.
  final TagflowContentPolicy policy;

  /// Strategy used to assign [TagflowDocumentNode.id] values.
  final TagflowHtmlNodeIdStrategy nodeIdStrategy;

  /// Adapters are equal when they produce the same document for the same
  /// input, so a widget can skip re-parsing when a parent rebuilds with a new
  /// but equivalent adapter.
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TagflowHtmlAdapter &&
            other.debug == debug &&
            other.renderBoundary == renderBoundary &&
            other.policy == policy &&
            other.nodeIdStrategy == nodeIdStrategy;
  }

  @override
  int get hashCode =>
      Object.hash(debug, renderBoundary, policy, nodeIdStrategy);

  /// Parses [html] into a source-tagged [TagflowDocument].
  TagflowDocument parse(
    String html, {
    String? id,
    Uri? uri,
    TagflowMetadata? metadata,
    TagflowViewOptions viewOptions = TagflowViewOptions.defaults,
    @Deprecated(
      'Use viewOptions and renderBoundary instead. '
      'Will be removed in tagflow 2.0.',
    )
    TagflowOptions? options,
    TagflowRenderBoundary? renderBoundary,
  }) {
    final resolvedViewOptions = options?.toViewOptions() ?? viewOptions;
    final rootNodes = readHtmlBody(
      html,
      debug: debug ?? resolvedViewOptions.debug,
      renderBoundary:
          this.renderBoundary ?? renderBoundary ?? options?.renderBoundary,
      maxDepth: policy.maxDepth,
      maxNodes: policy.maxNodes,
    );
    final source = TagflowSourceInfo(
      kind: TagflowSourceKind.html,
      adapter: _htmlAdapterName,
      uri: uri,
    );
    final nodeIds = _TagflowHtmlNodeIds(nodeIdStrategy);

    return TagflowDocument(
      id: id ?? _documentIdFor(html),
      children: _HtmlWhitespaceCollapser().block([
        for (final indexed in rootNodes.indexed)
          if (_documentNodeFromHtml(
                indexed.$2,
                [indexed.$1],
                source,
                policy,
                nodeIds,
              )
              case final node?)
            node,
      ]),
      metadata: metadata,
      source: source,
    );
  }
}

/// Read-only node metadata exposed by the HTML adapter.
extension TagflowHtmlNodeMetadata on TagflowDocumentNode {
  /// Original HTML tag name or the closest semantic fallback tag.
  String? get htmlTag {
    final metadataTag = metadata[_htmlTagKey];
    final presentationTag = presentation.hints[_htmlTagKey];
    if (metadataTag is String) return metadataTag;
    if (presentationTag is String) return presentationTag;
    return null;
  }

  /// Sanitized HTML attributes preserved from the adapted source node.
  Map<String, String> get htmlAttributes {
    final value = metadata[_htmlAttributesKey];
    if (value is! Map) {
      return const {};
    }

    return Map.unmodifiable(
      value.map((key, value) => MapEntry('$key', '$value')),
    );
  }

  /// Original blocked tag when policy preserved an unsupported placeholder.
  String? get blockedHtmlTag {
    final value = metadata[_blockedHtmlTagKey];
    return value is String ? value : null;
  }

  /// Adapter policy decision reason for preserved placeholder/fallback nodes.
  String? get htmlPolicyDecisionReason {
    final value = metadata[_policyDecisionReasonKey];
    return value is String ? value : null;
  }
}

TagflowDocumentNode? _documentNodeFromHtml(
  HtmlSourceNode node,
  List<int> path,
  TagflowSourceInfo documentSource,
  TagflowContentPolicy policy,
  _TagflowHtmlNodeIds nodeIds,
) {
  final id = nodeIds.resolve(node, path);
  final source = TagflowSourceInfo(
    kind: TagflowSourceKind.html,
    adapter: _htmlAdapterName,
    uri: documentSource.uri,
    metadata: TagflowMetadata({_htmlTagKey: node.tag}),
  );
  final limit = switch (node.tag) {
    tagflowLimitDepthTag => TagflowContentLimit.maxDepth,
    tagflowLimitNodesTag => TagflowContentLimit.maxNodes,
    _ => null,
  };
  if (limit != null) {
    return tagflowContentLimitNode(
      policy,
      limit,
      id: id,
      source: source,
      metadata: TagflowMetadata(const {_htmlTagKey: 'div'}),
    );
  }

  final tagDecision = node.isTextNode
      ? const TagflowTagPolicyDecision.allow('#text')
      : policy.decideTag(node.tag);
  if (!tagDecision.isAllowed) {
    return _disallowedNode(
      id: id,
      node: node,
      source: source,
      policy: policy,
      reason: tagDecision.reason?.name ?? 'disallowedTag',
    );
  }

  final presentation = TagflowPresentation(
    variant: _variantForHtmlTag(node.tag),
    width: _parseDimension(node['width']),
    height: _parseDimension(node['height']),
    display: _inlineHtmlTags.contains(node.tag) ? TagflowDisplay.inline : null,
    inlineSemantics: _inlineSemanticsForHtmlTag(node.tag),
    inlineStyle: policy.allowInlineStyles ? _inlineStyleFor(node) : null,
    hints: _presentationHintsForHtmlNode(node),
  );
  final tableCaption = node.caption;
  final children = [
    for (final indexed in node.children.indexed)
      if (_documentNodeFromHtml(
            indexed.$2,
            [...path, indexed.$1],
            documentSource,
            policy,
            nodeIds,
          )
          case final child?)
        child,
    if (tableCaption != null)
      if (_documentNodeFromHtml(
            tableCaption,
            [...path, node.children.length],
            documentSource,
            policy,
            nodeIds,
          )
          case final child?)
        child,
  ];

  if (node.isTextNode) {
    return TagflowDocumentNode.text(
      id: id,
      text: node.text ?? '',
      metadata: _metadataForHtmlNode(node),
      presentation: presentation,
      source: source,
    );
  }

  final hrefDecision = node.tag == 'a'
      ? policy.decideUrl(
          node['href'] ?? '',
          resourceType: TagflowResourceType.link,
        )
      : null;
  final srcDecision = node.tag == 'img'
      ? policy.decideUrl(
          node['src'] ?? '',
          resourceType: TagflowResourceType.image,
        )
      : null;
  final metadata = _metadataForHtmlNode(
    node,
    hrefDecision: hrefDecision,
    srcDecision: srcDecision,
  );

  return switch (node.tag) {
    'p' => TagflowDocumentNode.paragraph(
      id: id,
      children: children,
      metadata: metadata,
      presentation: presentation,
      source: source,
    ),
    'h1' || 'h2' || 'h3' || 'h4' || 'h5' || 'h6' => TagflowDocumentNode.heading(
      id: id,
      level: int.parse(node.tag.substring(1)),
      children: children,
      metadata: metadata,
      presentation: presentation,
      source: source,
    ),
    'a' =>
      hrefDecision == null || !hrefDecision.isAllowed
          ? TagflowDocumentNode.container(
              id: id,
              children: children,
              metadata: _metadataForRejectedUrl(
                metadata,
                hrefDecision?.reason?.name ?? 'malformedUrl',
              ),
              presentation: presentation,
              source: source,
            )
          : TagflowDocumentNode.link(
              id: id,
              url: hrefDecision.uri!,
              children: children,
              metadata: metadata,
              presentation: presentation,
              source: source,
            ),
    'ul' || 'ol' => TagflowDocumentNode.list(
      id: id,
      ordered: node.tag == 'ol',
      startIndex: int.tryParse(node['start'] ?? ''),
      children: children,
      metadata: metadata,
      presentation: presentation,
      source: source,
    ),
    'li' => TagflowDocumentNode.listItem(
      id: id,
      children: children,
      metadata: metadata,
      presentation: presentation,
      source: source,
    ),
    'dl' => TagflowDocumentNode.descriptionList(
      id: id,
      children: children,
      metadata: metadata,
      presentation: presentation,
      source: source,
    ),
    'dt' => TagflowDocumentNode.descriptionTerm(
      id: id,
      children: children,
      metadata: metadata,
      presentation: presentation,
      source: source,
    ),
    'dd' => TagflowDocumentNode.descriptionDetails(
      id: id,
      children: children,
      metadata: metadata,
      presentation: presentation,
      source: source,
    ),
    'blockquote' => TagflowDocumentNode.blockquote(
      id: id,
      children: children,
      metadata: metadata,
      presentation: presentation,
      source: source,
    ),
    'pre' => TagflowDocumentNode.codeBlock(
      id: id,
      text: _textContentFor(node),
      language: _codeBlockLanguageFor(node),
      metadata: metadata,
      presentation: presentation,
      source: source,
    ),
    'code' => TagflowDocumentNode.inlineCode(
      id: id,
      text: _textContentFor(node),
      metadata: metadata,
      presentation: presentation,
      source: source,
    ),
    'img' =>
      srcDecision == null || !srcDecision.isAllowed
          ? _disallowedNode(
              id: id,
              node: node,
              source: source,
              policy: policy,
              reason: srcDecision?.reason?.name ?? 'malformedUrl',
            )
          : TagflowDocumentNode.image(
              id: id,
              url: srcDecision.uri!,
              alt: node['alt'],
              width: _parseDimension(node['width']),
              height: _parseDimension(node['height']),
              metadata: metadata,
              presentation: presentation,
              source: source,
            ),
    'table' => TagflowDocumentNode.table(
      id: id,
      children: children,
      metadata: metadata,
      presentation: presentation,
      source: source,
    ),
    'tr' => TagflowDocumentNode.tableRow(
      id: id,
      children: children,
      metadata: metadata,
      presentation: presentation,
      source: source,
    ),
    'td' || 'th' => TagflowDocumentNode.tableCell(
      id: id,
      children: children,
      rowSpan: clampTableSpan(node['rowspan'], maxTableRowSpan),
      colSpan: clampTableSpan(node['colspan'], maxTableColSpan),
      header: node.tag == 'th',
      metadata: metadata,
      presentation: presentation,
      source: source,
    ),
    // `wbr` is only a line-break opportunity; a zero-width space gives the
    // text layout the same opportunity without any visible glyph.
    'wbr' => TagflowDocumentNode.text(
      id: id,
      text: '\u200B',
      metadata: metadata,
      presentation: presentation,
      source: source,
    ),
    'br' => TagflowDocumentNode.text(
      id: id,
      text: '\n',
      metadata: metadata,
      presentation: presentation,
      source: source,
    ),
    'hr' => TagflowDocumentNode.horizontalRule(
      id: id,
      metadata: metadata,
      presentation: presentation,
      source: source,
    ),
    'strong' ||
    'b' ||
    'em' ||
    'i' ||
    'u' ||
    'del' ||
    'mark' ||
    'small' ||
    'sub' ||
    'sup' ||
    'span' ||
    'abbr' ||
    'bdi' ||
    'bdo' ||
    'cite' ||
    'data' ||
    'dfn' ||
    'ins' ||
    'kbd' ||
    'label' ||
    'q' ||
    's' ||
    'samp' ||
    'time' ||
    'var' => TagflowDocumentNode.container(
      id: id,
      children: children,
      metadata: metadata,
      presentation: presentation,
      source: source,
    ),
    'details' => TagflowDocumentNode.disclosure(
      id: id,
      children: children,
      expanded: node.attributes.containsKey('open'),
      metadata: metadata,
      presentation: presentation,
      source: source,
    ),
    'summary' => TagflowDocumentNode.disclosureSummary(
      id: id,
      children: children,
      metadata: metadata,
      presentation: presentation,
      source: source,
    ),
    'caption' => TagflowDocumentNode.tableCaption(
      id: id,
      children: children,
      metadata: metadata,
      presentation: presentation,
      source: source,
    ),
    'div' ||
    'section' ||
    'article' ||
    'aside' ||
    'nav' ||
    'header' ||
    'footer' ||
    'main' => TagflowDocumentNode.container(
      id: id,
      children: children,
      metadata: metadata,
      presentation: presentation,
      source: source,
    ),
    // With nothing to render, an unmapped element is dropped unless the policy
    // asks for placeholders.
    _
        when children.isEmpty &&
            policy.unsupportedBehavior == TagflowUnsupportedBehavior.drop =>
      null,
    _ => TagflowDocumentNode.unsupported(
      id: id,
      unsupportedReason: 'HTML tag "${node.tag}" has no semantic mapping yet.',
      children: children,
      metadata: metadata,
      presentation: presentation,
      source: source,
    ),
  };
}

/// Collapses HTML source whitespace the way CSS `white-space: normal` does.
///
/// Runs of spaces, tabs and newlines become one space, a space that follows
/// another (even across inline element boundaries) is dropped, and spaces at
/// the start and end of each block are removed. `<br>` is the only line
/// break. Code blocks keep their text as written.
final class _HtmlWhitespaceCollapser {
  static final _whitespace = RegExp(r'[ \t\n\r\f]+');

  /// Whether the next text starts a line, or follows a collapsible space.
  bool _skipLeadingSpace = true;

  List<TagflowDocumentNode> block(List<TagflowDocumentNode> children) {
    final saved = _skipLeadingSpace;
    _skipLeadingSpace = true;
    final result = <TagflowDocumentNode>[];
    for (final child in children) {
      if (_isInlineHtmlNode(child)) {
        if (_isLineBreak(child)) _trimTrailing(result);
        if (_inline(child) case final node?) result.add(node);
        continue;
      }
      _trimTrailing(result);
      result.add(_block(child));
      _skipLeadingSpace = true;
    }
    _trimTrailing(result);
    _skipLeadingSpace = saved;
    return result;
  }

  TagflowDocumentNode _block(TagflowDocumentNode node) {
    if (node.kind == TagflowNodeKind.codeBlock || node.children.isEmpty) {
      return node;
    }
    return node.copyWith(children: block(node.children));
  }

  TagflowDocumentNode? _inline(TagflowDocumentNode node) {
    if (_isLineBreak(node)) {
      _skipLeadingSpace = true;
      return node;
    }

    if (node.kind == TagflowNodeKind.text) {
      var text = (node.text ?? '').replaceAll(_whitespace, ' ');
      if (_skipLeadingSpace && text.startsWith(' ')) text = text.substring(1);
      if (text.isEmpty) return null;
      _skipLeadingSpace = text.endsWith(' ');
      return text == node.text ? node : node.copyWith(text: text);
    }

    if (node.children.isEmpty) {
      _skipLeadingSpace = false;
      return node;
    }

    final children = <TagflowDocumentNode>[];
    for (final child in node.children) {
      if (_isInlineHtmlNode(child)) {
        if (_inline(child) case final inline?) children.add(inline);
      } else {
        children.add(_block(child));
        _skipLeadingSpace = true;
      }
    }
    return node.copyWith(children: children);
  }

  /// Removes the trailing space of the inline run ending [nodes].
  void _trimTrailing(List<TagflowDocumentNode> nodes) {
    while (nodes.isNotEmpty) {
      final last = nodes.last;
      if (!_isInlineHtmlNode(last) || _isLineBreak(last)) return;

      if (last.kind == TagflowNodeKind.text) {
        final text = last.text ?? '';
        if (!text.endsWith(' ')) return;
        final trimmed = text.substring(0, text.length - 1);
        if (trimmed.isNotEmpty) {
          nodes.last = last.copyWith(text: trimmed);
          return;
        }
        nodes.removeLast();
        continue;
      }

      if (last.children.isEmpty) return;
      final children = [...last.children];
      _trimTrailing(children);
      nodes.last = last.copyWith(children: children);
      return;
    }
  }

  static bool _isLineBreak(TagflowDocumentNode node) {
    return node.kind == TagflowNodeKind.text && node.htmlTag == 'br';
  }

  static bool _isInlineHtmlNode(TagflowDocumentNode node) {
    return switch (node.kind) {
      TagflowNodeKind.text ||
      TagflowNodeKind.link ||
      TagflowNodeKind.inlineCode ||
      TagflowNodeKind.image => true,
      TagflowNodeKind.container || TagflowNodeKind.unsupported =>
        node.presentation.display == TagflowDisplay.inline,
      _ => false,
    };
  }
}

final class _TagflowHtmlNodeIds {
  _TagflowHtmlNodeIds(this.strategy);

  final TagflowHtmlNodeIdStrategy strategy;
  final Set<String> _seen = <String>{};

  String resolve(HtmlSourceNode node, List<int> path) {
    final id = switch (strategy._kind) {
      _TagflowHtmlNodeIdStrategyKind.path => TagflowNodeIds.fromPath(path),
      _TagflowHtmlNodeIdStrategyKind.attribute => _resolveAttributeId(
        node,
        path,
      ),
    };

    if (!_seen.add(id)) {
      throw StateError(
        'duplicate HTML adapter node id "$id" detected at '
        '${TagflowNodeIds.fromPath(path)}.',
      );
    }

    return id;
  }

  String _resolveAttributeId(HtmlSourceNode node, List<int> path) {
    final attribute = strategy.attribute ?? _defaultHtmlNodeIdAttribute;
    final authoredId = _trimmedAttributeValue(node, attribute);
    if (authoredId != null) {
      return authoredId;
    }
    if (strategy.fallbackToPath) {
      return TagflowNodeIds.fromPath(path);
    }

    throw StateError(
      'Missing required HTML node id attribute "$attribute" for '
      '${_htmlNodeLabel(node)} at ${TagflowNodeIds.fromPath(path)}.',
    );
  }
}

TagflowMetadata _metadataForHtmlNode(
  HtmlSourceNode node, {
  TagflowUrlPolicyDecision? hrefDecision,
  TagflowUrlPolicyDecision? srcDecision,
}) {
  final attributes = node.attributes;
  final sanitizedAttributes = Map<String, String>.fromEntries(
    attributes.entries.where((entry) {
      final key = entry.key.toLowerCase();
      if (key.startsWith('on')) return false;
      if (key == 'href' && hrefDecision != null && !hrefDecision.isAllowed) {
        return false;
      }
      if (key == 'src' && srcDecision != null && !srcDecision.isAllowed) {
        return false;
      }
      return true;
    }),
  );

  return TagflowMetadata({
    _htmlTagKey: node.tag,
    if (sanitizedAttributes.isNotEmpty) _htmlAttributesKey: sanitizedAttributes,
    if (node.rowCount != null) ...{
      _tableRowCountKey: node.rowCount,
      _tableColumnCountKey: node.columnCount,
    },
  });
}

TagflowMetadata _metadataForRejectedUrl(
  TagflowMetadata metadata,
  String reason,
) {
  return metadata.merge(TagflowMetadata({_policyDecisionReasonKey: reason}));
}

TagflowDocumentNode? _disallowedNode({
  required String id,
  required HtmlSourceNode node,
  required TagflowSourceInfo source,
  required TagflowContentPolicy policy,
  required String reason,
}) {
  if (policy.unsupportedBehavior == TagflowUnsupportedBehavior.drop) {
    return null;
  }

  return TagflowDocumentNode.unsupported(
    id: id,
    unsupportedReason: 'HTML tag "${node.tag}" was rejected by policy.',
    metadata: TagflowMetadata({
      _htmlTagKey: 'div',
      _blockedHtmlTagKey: node.tag,
      _policyDecisionReasonKey: reason,
    }),
    presentation: TagflowPresentation(
      variant: 'unsupported',
      hints: {_blockedHtmlTagKey: node.tag},
    ),
    source: source,
  );
}

String? _trimmedAttributeValue(HtmlSourceNode node, String attribute) {
  final value = node[attribute]?.trim();
  if (value == null || value.isEmpty) return null;
  return value;
}

String _htmlNodeLabel(HtmlSourceNode node) {
  return node.isTextNode ? '#text' : '<${node.tag}>';
}

/// HTML elements that are inline-level by default.
const _inlineHtmlTags = {
  'a',
  'abbr',
  'b',
  'bdi',
  'bdo',
  'cite',
  'code',
  'data',
  'del',
  'dfn',
  'em',
  'i',
  'ins',
  'kbd',
  'label',
  'mark',
  'q',
  's',
  'samp',
  'small',
  'span',
  'strong',
  'sub',
  'sup',
  'time',
  'u',
  'var',
};

String? _variantForHtmlTag(String tag) {
  return switch (tag) {
    'h1' || 'h2' || 'h3' || 'h4' || 'h5' || 'h6' => 'heading',
    'p' => 'paragraph',
    'dl' => 'description-list',
    'dt' => 'description-term',
    'dd' => 'description-details',
    'pre' || 'code' => 'code',
    'details' => 'details',
    'summary' => 'summary',
    _ => null,
  };
}

Set<TagflowInlineSemantic> _inlineSemanticsForHtmlTag(String tag) {
  return switch (tag) {
    'strong' || 'b' => const {TagflowInlineSemantic.strong},
    'em' || 'i' => const {TagflowInlineSemantic.emphasis},
    'cite' || 'dfn' || 'var' => const {TagflowInlineSemantic.emphasis},
    'u' || 'ins' => const {TagflowInlineSemantic.underline},
    'del' || 's' => const {TagflowInlineSemantic.deleted},
    'kbd' || 'samp' => const {TagflowInlineSemantic.code},
    'mark' => const {TagflowInlineSemantic.highlight},
    'small' => const {TagflowInlineSemantic.small},
    'sub' => const {TagflowInlineSemantic.subscript},
    'sup' => const {TagflowInlineSemantic.superscript},
    _ => const {},
  };
}

String? _codeBlockLanguageFor(HtmlSourceNode node) {
  final className = node.className;
  if (className != null && className.trim().isNotEmpty) return className;

  // Markdown renderers emit `<pre><code class="language-x">`, so fall back to
  // the class of a direct `code` child.
  for (final child in node.children) {
    final childClassName = child.className;
    if (child.tag == 'code' &&
        childClassName != null &&
        childClassName.trim().isNotEmpty) {
      return childClassName;
    }
  }

  return null;
}

String _textContentFor(HtmlSourceNode node) {
  final buffer = StringBuffer(node.text ?? '');
  for (final child in node.children) {
    buffer.write(_textContentFor(child));
  }
  return buffer.toString();
}

/// Maps the safe subset of the inline `style` attribute onto a typed
/// [TagflowInlineStyle]: `color`, `background-color`, `text-align`,
/// `font-weight`, `font-style`, `text-decoration` and `font-size`. Every
/// other property is ignored.
TagflowInlineStyle? _inlineStyleFor(HtmlSourceNode node) {
  if (node.isTextNode) return null;
  final styles = _styleDeclarations(node.style);
  if (styles.isEmpty) return null;

  int? color(String key) {
    final value = styles[key];
    if (value == null) return null;
    return StyleParser.parseColor(value, _cssNamedColors)?.toARGB32();
  }

  final weight = switch (styles['font-weight']) {
    final value? => StyleParser.parseFontWeight(value.trim())?.value,
    null => null,
  };
  final italic = switch (styles['font-style']?.trim().toLowerCase()) {
    'italic' || 'oblique' => true,
    'normal' => false,
    _ => null,
  };
  final (fontSize, fontSizeFactor) = _fontSize(styles['font-size']);

  final style = TagflowInlineStyle(
    color: color('color'),
    backgroundColor: color('background-color'),
    textAlign: _textAlign(styles['text-align']),
    fontWeight: weight,
    italic: italic,
    decorations: _decorations(styles['text-decoration']),
    fontSize: fontSize,
    fontSizeFactor: fontSizeFactor,
  );
  return style.isEmpty ? null : style;
}

/// The CSS basic colour keywords, plus `orange` and `transparent`.
const _cssNamedColors = <String, Color>{
  'black': Color(0xFF000000),
  'silver': Color(0xFFC0C0C0),
  'gray': Color(0xFF808080),
  'grey': Color(0xFF808080),
  'white': Color(0xFFFFFFFF),
  'maroon': Color(0xFF800000),
  'red': Color(0xFFFF0000),
  'purple': Color(0xFF800080),
  'fuchsia': Color(0xFFFF00FF),
  'green': Color(0xFF008000),
  'lime': Color(0xFF00FF00),
  'olive': Color(0xFF808000),
  'yellow': Color(0xFFFFFF00),
  'navy': Color(0xFF000080),
  'blue': Color(0xFF0000FF),
  'teal': Color(0xFF008080),
  'aqua': Color(0xFF00FFFF),
  'orange': Color(0xFFFFA500),
  'transparent': Color(0x00000000),
};

TagflowTextAlign? _textAlign(String? value) {
  return switch (value?.trim().toLowerCase()) {
    'left' => TagflowTextAlign.left,
    'right' => TagflowTextAlign.right,
    'center' => TagflowTextAlign.center,
    'justify' => TagflowTextAlign.justify,
    'start' => TagflowTextAlign.start,
    'end' => TagflowTextAlign.end,
    _ => null,
  };
}

Set<TagflowTextDecoration>? _decorations(String? value) {
  if (value == null) return null;
  final result = <TagflowTextDecoration>{};
  for (final part in value.toLowerCase().split(RegExp(r'\s+'))) {
    switch (part) {
      case 'none':
        return const {};
      case 'underline':
        result.add(TagflowTextDecoration.underline);
      case 'overline':
        result.add(TagflowTextDecoration.overline);
      case 'line-through':
        result.add(TagflowTextDecoration.lineThrough);
    }
  }
  return result.isEmpty ? null : result;
}

/// Parses a CSS `font-size` into an absolute size (`px`, `pt`, `rem`) or a
/// factor of the surrounding size (`em`, `%`). Keywords and other units are
/// ignored. Sizes are kept between 1 and 512 logical pixels.
(double?, double?) _fontSize(String? raw) {
  final value = raw?.trim().toLowerCase();
  if (value == null || value.isEmpty) return (null, null);
  final match = RegExp(r'^(\d*\.?\d+)(px|pt|rem|em|%)?$').firstMatch(value);
  if (match == null) return (null, null);
  final number = double.parse(match.group(1)!);
  return switch (match.group(2)) {
    null || 'px' => (number.clamp(1, 512).toDouble(), null),
    'pt' => ((number * 4 / 3).clamp(1, 512).toDouble(), null),
    'rem' => ((number * 16).clamp(1, 512).toDouble(), null),
    'em' => (null, number.clamp(0.1, 32).toDouble()),
    '%' => (null, (number / 100).clamp(0.1, 32).toDouble()),
    _ => (null, null),
  };
}

Map<String, Object?> _presentationHintsForHtmlNode(HtmlSourceNode node) {
  final hints = <String, Object?>{
    _htmlTagKey: node.tag,
    if (node.className != null) 'className': node.className,
  };
  final styles = _styleDeclarations(node.style);

  if (node.tag == 'table') {
    hints.addAll(_tablePresentationHints(node, styles));
  }

  if (node.tag == 'tr' || node.tag == 'td' || node.tag == 'th') {
    final backgroundColor = _colorFromStyles(styles, 'background-color');
    if (backgroundColor != null) {
      hints['backgroundColor'] = backgroundColor;
    }

    final textAlign = _textAlignHint(node, styles);
    if (textAlign != null) {
      hints[_textAlignHintKey] = textAlign;
    }
  }

  if (node.tag == 'td' || node.tag == 'th') {
    final padding = _edgeInsetsFromStyles(styles, 'padding');
    if (padding != null) {
      hints['padding'] = padding;
    }
  }

  return hints;
}

Map<String, Object?> _tablePresentationHints(
  HtmlSourceNode node,
  Map<String, String> styles,
) {
  final hints = <String, Object?>{};
  final borderHints = _tableBorderHints(node, styles);
  if (borderHints != null) {
    hints.addAll(borderHints);
  }

  final spacingHints = _tableSpacingHints(node, styles);
  if (spacingHints != null) {
    hints.addAll(spacingHints);
  }

  final cellPadding = _tableCellPadding(node);
  if (cellPadding != null) {
    hints[_tableCellPaddingHintKey] = cellPadding;
  }

  return hints;
}

Map<String, Object?>? _tableBorderHints(
  HtmlSourceNode node,
  Map<String, String> styles,
) {
  final borderStyle = styles['border'];
  if (borderStyle != null) {
    final border = StyleParser.parseBorder(borderStyle);
    if (border == null) {
      if (borderStyle.trim().toLowerCase() == 'none') {
        return {
          _tableBorderWidthHintKey: 0.0,
          _tableInsideBorderWidthHintKey: 0.0,
        };
      }
      return null;
    }

    return {
      _tableBorderWidthHintKey: border.top.width,
      _tableInsideBorderWidthHintKey: border.top.width,
      _tableBorderColorHintKey: border.top.color,
    };
  }

  final borderWidth = _sizeFromHtmlAttribute(node['border']);
  if (borderWidth == null) {
    return null;
  }

  if (borderWidth <= 0) {
    return {_tableBorderWidthHintKey: 0.0, _tableInsideBorderWidthHintKey: 0.0};
  }

  return {
    _tableBorderWidthHintKey: borderWidth,
    _tableInsideBorderWidthHintKey: 1.0,
    _tableBorderColorHintKey: const Color(0xFF000000),
  };
}

Map<String, Object?>? _tableSpacingHints(
  HtmlSourceNode node,
  Map<String, String> styles,
) {
  final borderCollapse = styles['border-collapse']?.trim().toLowerCase();
  if (borderCollapse == 'collapse') {
    return {_tableColumnSpacingHintKey: 0.0, _tableRowSpacingHintKey: 0.0};
  }

  final borderSpacing = styles['border-spacing'];
  if (borderSpacing != null) {
    final spacing = _borderSpacing(borderSpacing);
    if (spacing != null) {
      return {
        _tableColumnSpacingHintKey: spacing.$1,
        _tableRowSpacingHintKey: spacing.$2,
      };
    }
  }

  final cellSpacing = _sizeFromHtmlAttribute(node['cellspacing']);
  if (cellSpacing == null) {
    return null;
  }

  return {
    _tableColumnSpacingHintKey: cellSpacing,
    _tableRowSpacingHintKey: cellSpacing,
  };
}

EdgeInsets? _tableCellPadding(HtmlSourceNode node) {
  final padding = _sizeFromHtmlAttribute(node['cellpadding']);
  if (padding == null) {
    return null;
  }

  return EdgeInsets.all(padding);
}

Map<String, String> _styleDeclarations(String? style) {
  if (style == null || style.trim().isEmpty) {
    return const {};
  }

  return StyleParser.parseDeclarations(style);
}

Color? _colorFromStyles(Map<String, String> styles, String key) {
  final value = styles[key];
  return value == null ? null : StyleParser.parseColor(value);
}

EdgeInsets? _edgeInsetsFromStyles(Map<String, String> styles, String key) {
  final value = styles[key];
  return value == null ? null : StyleParser.parseEdgeInsets(value);
}

TextAlign? _textAlignHint(HtmlSourceNode node, Map<String, String> styles) {
  final styleValue = styles['text-align'];
  if (styleValue != null) {
    final parsed = StyleParser.parseTextAlign(styleValue);
    if (parsed != null) {
      return parsed;
    }
  }

  final align = node['align'];
  return align == null ? null : StyleParser.parseTextAlign(align);
}

(double, double)? _borderSpacing(String value) {
  final parts = value
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList(growable: false);

  if (parts.isEmpty || parts.length > 2) {
    return null;
  }

  final horizontal = StyleParser.parseSize(parts.first);
  final vertical = StyleParser.parseSize(
    parts.length == 2 ? parts.last : parts.first,
  );
  if (horizontal == null || vertical == null) {
    return null;
  }

  return (horizontal, vertical);
}

double? _sizeFromHtmlAttribute(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }

  return StyleParser.parseSize(value);
}

double? _parseDimension(String? value) {
  if (value == null || value.isEmpty) return null;
  return double.tryParse(value);
}

String _documentIdFor(String html) {
  var hash = 0;
  for (final codeUnit in html.codeUnits) {
    hash = (hash * 31 + codeUnit) & 0x3fffffff;
  }
  return 'html-$hash';
}
