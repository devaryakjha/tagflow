import 'dart:convert';

import 'package:flutter/painting.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:meta/meta.dart';
import 'package:tagflow/src/adapters/html_adapter.dart';
import 'package:tagflow/src/runtime/runtime.dart';

const _markdownAdapterName = 'markdown';
const _htmlTagKey = 'htmlTag';
const _markdownTagKey = 'markdownTag';
const _blockedHtmlTagKey = 'blockedHtmlTag';
const _policyDecisionReasonKey = 'policyDecisionReason';
const _taskCheckedKey = 'taskChecked';
const _titleKey = 'title';
const _tableRowCountKey = 'tableRowCount';
const _tableColumnCountKey = 'tableColumnCount';
const _textAlignHintKey = 'textAlign';
const _rawHtmlKey = 'markdownRawHtml';

// Synthetic tags used to keep raw HTML distinguishable from Markdown text in
// the parsed AST. They never reach the runtime document.
const _rawInlineHtmlTag = 'x-tagflow-raw-html';
const _rawBlockHtmlTag = 'x-tagflow-raw-html-block';

/// How [TagflowMarkdownAdapter] treats raw HTML embedded in Markdown.
enum TagflowMarkdownRawHtmlBehavior {
  /// Adapts raw HTML through [TagflowHtmlAdapter] and the adapter's
  /// [TagflowContentPolicy].
  adapt,

  /// Drops raw HTML. Inline tags are removed and the text between them kept;
  /// HTML blocks are removed entirely.
  drop,

  /// Keeps raw HTML as literal text, as a chat transcript would show it.
  text,
}

/// Converts Markdown (GitHub Flavored) into the native Tagflow runtime
/// document model.
///
/// Every top-level Markdown block gets the deterministic id
/// `TagflowNodeIds.fromPath([blockIndex])` and descendants extend that path,
/// so re-parsing a longer prefix of the same Markdown keeps earlier ids
/// stable.
@immutable
final class TagflowMarkdownAdapter {
  /// Creates a Markdown adapter.
  const TagflowMarkdownAdapter({
    this.policy = TagflowContentPolicy.defaults,
    this.rawHtml = TagflowMarkdownRawHtmlBehavior.adapt,
  });

  /// Content policy applied to links, images, tags and raw HTML.
  final TagflowContentPolicy policy;

  /// Behavior for raw HTML embedded in Markdown.
  final TagflowMarkdownRawHtmlBehavior rawHtml;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TagflowMarkdownAdapter &&
            other.policy == policy &&
            other.rawHtml == rawHtml;
  }

  @override
  int get hashCode => Object.hash(policy, rawHtml);

  /// Parses [markdown] into a source-tagged [TagflowDocument].
  TagflowDocument parse(
    String markdown, {
    String? id,
    Uri? uri,
    TagflowMetadata? metadata,
  }) {
    final source = _markdownSource(uri);
    return TagflowDocument(
      id: id ?? _documentIdFor(markdown),
      children: [
        ..._adaptBlocks(markdown, source: source, firstBlockIndex: 0).nonNulls,
      ],
      metadata: metadata,
      source: source,
    );
  }

  List<TagflowDocumentNode?> _adaptBlocks(
    String markdown, {
    required TagflowSourceInfo source,
    required int firstBlockIndex,
  }) {
    final document = md.Document(
      extensionSet: md.ExtensionSet.gitHubFlavored,
      blockSyntaxes: const [_RawHtmlBlockSyntax()],
      inlineSyntaxes: [_RawInlineHtmlSyntax()],
      encodeHtml: false,
    );
    final blocks = document.parse(markdown);
    final context = _MarkdownAdaptContext(
      policy: policy,
      rawHtml: rawHtml,
      source: source,
    );

    return [
      for (final (index, block) in _withoutBlankText(blocks).indexed)
        context.adaptNode(block, [firstBlockIndex + index]),
    ];
  }
}

/// Adapts the top-level blocks of [markdown] as if they started at block
/// [firstBlockIndex] of a larger document.
///
/// Entry `i` is the node for Markdown block `firstBlockIndex + i`, or `null`
/// when the content policy dropped it. Used by `TagflowMarkdownStream` to
/// re-parse only the open tail of a stream; hidden from the package barrel.
List<TagflowDocumentNode?> tagflowAdaptMarkdownBlocks(
  TagflowMarkdownAdapter adapter,
  String markdown, {
  int firstBlockIndex = 0,
  Uri? uri,
}) {
  return adapter._adaptBlocks(
    markdown,
    source: _markdownSource(uri),
    firstBlockIndex: firstBlockIndex,
  );
}

TagflowSourceInfo _markdownSource(Uri? uri) {
  return TagflowSourceInfo(
    kind: TagflowSourceKind.markdown,
    adapter: _markdownAdapterName,
    uri: uri,
  );
}

/// Read-only node metadata exposed by the Markdown adapter.
extension TagflowMarkdownNodeMetadata on TagflowDocumentNode {
  /// Markdown construct this node was adapted from, using the HTML tag name
  /// `package:markdown` assigns (`p`, `h2`, `del`, `pre`, ...).
  String? get markdownTag {
    final value = metadata[_markdownTagKey];
    return value is String ? value : null;
  }

  /// Whether this list item is a GFM task list item.
  bool get isMarkdownTaskItem => metadata[_taskCheckedKey] is bool;

  /// Checked state of a GFM task list item, or `null` for other nodes.
  bool? get markdownTaskChecked {
    final value = metadata[_taskCheckedKey];
    return value is bool ? value : null;
  }

  /// Whether this node was produced from raw HTML embedded in Markdown.
  bool get isMarkdownRawHtml => metadata[_rawHtmlKey] == true;
}

final class _MarkdownAdaptContext {
  _MarkdownAdaptContext({
    required this.policy,
    required this.rawHtml,
    required this.source,
  });

  final TagflowContentPolicy policy;
  final TagflowMarkdownRawHtmlBehavior rawHtml;
  final TagflowSourceInfo source;

  TagflowDocumentNode? adaptNode(md.Node node, List<int> path) {
    final id = TagflowNodeIds.fromPath(path);
    if (node is md.Text) {
      return _text(id, node.text.replaceAll('\n', ' '));
    }
    if (node is! md.Element) {
      return _text(id, node.textContent);
    }

    switch (node.tag) {
      case _rawBlockHtmlTag:
        return _rawHtmlBlock(id, node.textContent);
      case _rawInlineHtmlTag:
        // Only reached when raw HTML is not adapted as part of its parent.
        return rawHtml == TagflowMarkdownRawHtmlBehavior.text
            ? _text(id, node.textContent, rawHtml: true)
            : null;
      case 'br':
        return _text(id, '\n', tag: 'br');
    }

    final tagDecision = policy.decideTag(node.tag);
    if (!tagDecision.isAllowed) {
      return _disallowed(
        id,
        node.tag,
        tagDecision.reason?.name ?? 'disallowedTag',
      );
    }

    final metadata = _metadataFor(node.tag);
    final presentation = TagflowPresentation(
      variant: _variantFor(node.tag),
      inlineSemantics: _inlineSemanticsFor(node.tag),
      hints: {_htmlTagKey: node.tag},
    );

    switch (node.tag) {
      case 'pre':
        final code = node.children?.whereType<md.Element>().firstOrNull;
        final text = (code ?? node).textContent;
        return TagflowDocumentNode.codeBlock(
          id: id,
          text: text.endsWith('\n') ? text.substring(0, text.length - 1) : text,
          language: _languageFor(code),
          metadata: metadata,
          presentation: presentation,
          source: source,
        );
      case 'code':
        return TagflowDocumentNode.inlineCode(
          id: id,
          text: node.textContent,
          metadata: metadata,
          presentation: presentation,
          source: source,
        );
      case 'hr':
        return TagflowDocumentNode.horizontalRule(
          id: id,
          metadata: metadata,
          presentation: presentation,
          source: source,
        );
      case 'img':
        final decision = policy.decideUrl(
          node.attributes['src'] ?? '',
          resourceType: TagflowResourceType.image,
        );
        if (!decision.isAllowed) {
          return _disallowed(id, 'img', decision.reason?.name ?? 'malformed');
        }
        return TagflowDocumentNode.image(
          id: id,
          url: decision.uri!,
          alt: node.attributes['alt'],
          metadata: _withTitle(metadata, node),
          presentation: presentation,
          source: source,
        );
      case 'table':
        return _table(id, node, path, metadata, presentation);
    }

    final children = _adaptChildren(node, path);

    return switch (node.tag) {
      'p' => TagflowDocumentNode.paragraph(
        id: id,
        children: children,
        metadata: metadata,
        presentation: presentation,
        source: source,
      ),
      'h1' ||
      'h2' ||
      'h3' ||
      'h4' ||
      'h5' ||
      'h6' => TagflowDocumentNode.heading(
        id: id,
        level: int.parse(node.tag.substring(1)),
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
      'ul' || 'ol' => TagflowDocumentNode.list(
        id: id,
        ordered: node.tag == 'ol',
        startIndex: int.tryParse(node.attributes['start'] ?? ''),
        children: children,
        metadata: metadata,
        presentation: presentation,
        source: source,
      ),
      'li' => TagflowDocumentNode.listItem(
        id: id,
        children: children,
        metadata: _withTaskState(metadata, node),
        presentation: presentation,
        source: source,
      ),
      'a' => _link(id, node, children, metadata, presentation),
      'em' ||
      'strong' ||
      'del' ||
      'sup' ||
      'sub' ||
      'section' ||
      'div' ||
      'span' => TagflowDocumentNode.container(
        id: id,
        children: children,
        metadata: metadata,
        presentation: presentation,
        source: source,
      ),
      _ => TagflowDocumentNode.unsupported(
        id: id,
        unsupportedReason:
            'Markdown element "${node.tag}" has no semantic mapping yet.',
        children: children,
        metadata: metadata,
        presentation: presentation,
        source: source,
      ),
    };
  }

  List<TagflowDocumentNode> _adaptChildren(md.Element node, List<int> path) {
    final children = _withoutBlankText(
      node.children ?? const <md.Node>[],
    ).where((child) => !_isTaskCheckbox(child)).toList(growable: false);

    // Inline raw HTML is adapted as one run from the first to the last raw
    // tag, so markup such as `<kbd>Ctrl</kbd>` reaches the HTML adapter
    // balanced. Nodes outside the run keep their Markdown mapping.
    final rawIndexes = [
      for (final (index, child) in children.indexed)
        if (_isRawInlineHtml(child)) index,
    ];
    final adaptRun =
        rawHtml == TagflowMarkdownRawHtmlBehavior.adapt &&
        rawIndexes.isNotEmpty;
    final runStart = adaptRun ? rawIndexes.first : -1;
    final runEnd = adaptRun ? rawIndexes.last : -1;

    return [
      for (final (index, child) in children.indexed)
        if (index == runStart)
          ..._adaptInlineHtml(
            children.sublist(runStart, runEnd + 1),
            TagflowNodeIds.fromPath([...path, index]),
          )
        else if (index < runStart || index > runEnd)
          if (adaptNode(child, [...path, index]) case final adapted?) adapted,
    ];
  }

  List<TagflowDocumentNode> _adaptInlineHtml(
    List<md.Node> nodes,
    String runId,
  ) {
    final html = StringBuffer('<span>');
    nodes.forEach(html.writeHtml);
    html.write('</span>');

    final adapted = _htmlAdapter.parse(html.toString()).children;
    if (adapted.isEmpty) return const [];

    final wrapper = _reId(adapted.first, from: '0.0', to: runId);
    return [
      for (final child in wrapper.children)
        child.copyWith(metadata: _markRawHtml(child.metadata)),
    ];
  }

  TagflowDocumentNode? _rawHtmlBlock(String id, String raw) {
    final html = raw.trim();
    switch (rawHtml) {
      case TagflowMarkdownRawHtmlBehavior.drop:
        return null;
      case TagflowMarkdownRawHtmlBehavior.text:
        return TagflowDocumentNode.paragraph(
          id: id,
          children: [_text('$id.0', html, rawHtml: true)],
          metadata: TagflowMetadata(const {
            _htmlTagKey: 'p',
            _rawHtmlKey: true,
          }),
          source: source,
        );
      case TagflowMarkdownRawHtmlBehavior.adapt:
        final adapted = _htmlAdapter.parse(html).children;
        if (adapted.isEmpty) return null;
        if (adapted.length == 1) {
          final node = _reId(adapted.single, from: '0.0', to: id);
          return node.copyWith(metadata: _markRawHtml(node.metadata));
        }
        return TagflowDocumentNode.container(
          id: id,
          children: [
            for (final indexed in adapted.indexed)
              _reId(
                indexed.$2,
                from: '0.${indexed.$1}',
                to: '$id.${indexed.$1}',
              ),
          ],
          metadata: TagflowMetadata(const {
            _htmlTagKey: 'div',
            _rawHtmlKey: true,
          }),
          source: source,
        );
    }
  }

  TagflowHtmlAdapter get _htmlAdapter => TagflowHtmlAdapter(policy: policy);

  TagflowDocumentNode _table(
    String id,
    md.Element node,
    List<int> path,
    TagflowMetadata metadata,
    TagflowPresentation presentation,
  ) {
    // Flatten thead/tbody sections so rows are direct table children, which
    // is the shape the HTML adapter and tagflow_table expect.
    final rows = <md.Element>[
      for (final section in node.children ?? const <md.Node>[])
        if (section is md.Element)
          if (section.tag == 'tr')
            section
          else
            ...?section.children?.whereType<md.Element>(),
    ];
    var columnCount = 0;
    final children = <TagflowDocumentNode>[];
    for (final (rowIndex, row) in rows.indexed) {
      final rowPath = [...path, rowIndex];
      final rowId = TagflowNodeIds.fromPath(rowPath);
      final cells = row.children?.whereType<md.Element>().toList() ?? const [];
      if (cells.length > columnCount) columnCount = cells.length;
      children.add(
        TagflowDocumentNode.tableRow(
          id: rowId,
          children: [
            for (final (cellIndex, cell) in cells.indexed)
              _tableCell(cell, [...rowPath, cellIndex]),
          ],
          metadata: _metadataFor('tr'),
          presentation: TagflowPresentation(hints: const {_htmlTagKey: 'tr'}),
          source: source,
        ),
      );
    }

    return TagflowDocumentNode.table(
      id: id,
      children: children,
      metadata: metadata.merge(
        TagflowMetadata({
          _tableRowCountKey: rows.length,
          _tableColumnCountKey: columnCount,
        }),
      ),
      presentation: presentation,
      source: source,
    );
  }

  TagflowDocumentNode _tableCell(md.Element cell, List<int> path) {
    final id = TagflowNodeIds.fromPath(path);
    final textAlign = switch (cell.attributes['align']) {
      'left' => TextAlign.left,
      'center' => TextAlign.center,
      'right' => TextAlign.right,
      _ => null,
    };

    return TagflowDocumentNode.tableCell(
      id: id,
      header: cell.tag == 'th',
      children: _adaptChildren(cell, path),
      metadata: _metadataFor(cell.tag),
      presentation: TagflowPresentation(
        hints: {
          _htmlTagKey: cell.tag,
          if (textAlign != null) _textAlignHintKey: textAlign,
        },
      ),
      source: source,
    );
  }

  TagflowDocumentNode _link(
    String id,
    md.Element node,
    List<TagflowDocumentNode> children,
    TagflowMetadata metadata,
    TagflowPresentation presentation,
  ) {
    final decision = policy.decideUrl(
      node.attributes['href'] ?? '',
      resourceType: TagflowResourceType.link,
    );
    if (!decision.isAllowed) {
      return TagflowDocumentNode.container(
        id: id,
        children: children,
        metadata: metadata.merge(
          TagflowMetadata({
            _policyDecisionReasonKey: decision.reason?.name ?? 'malformedUrl',
          }),
        ),
        presentation: presentation,
        source: source,
      );
    }

    return TagflowDocumentNode.link(
      id: id,
      url: decision.uri!,
      children: children,
      metadata: _withTitle(metadata, node),
      presentation: presentation,
      source: source,
    );
  }

  TagflowDocumentNode _text(
    String id,
    String text, {
    String tag = '#text',
    bool rawHtml = false,
  }) {
    return TagflowDocumentNode.text(
      id: id,
      text: text,
      metadata: TagflowMetadata({
        _htmlTagKey: tag,
        if (rawHtml) _rawHtmlKey: true,
      }),
      source: source,
    );
  }

  TagflowDocumentNode? _disallowed(String id, String tag, String reason) {
    if (policy.unsupportedBehavior == TagflowUnsupportedBehavior.drop) {
      return null;
    }

    return TagflowDocumentNode.unsupported(
      id: id,
      unsupportedReason: 'Markdown element "$tag" was rejected by policy.',
      metadata: TagflowMetadata({
        _htmlTagKey: 'div',
        _markdownTagKey: tag,
        _blockedHtmlTagKey: tag,
        _policyDecisionReasonKey: reason,
      }),
      presentation: TagflowPresentation(
        variant: 'unsupported',
        hints: {_blockedHtmlTagKey: tag},
      ),
      source: source,
    );
  }

  TagflowMetadata _withTaskState(TagflowMetadata metadata, md.Element node) {
    final checkbox = _taskCheckbox(node);
    if (checkbox == null) return metadata;
    return metadata.merge(
      TagflowMetadata({
        _taskCheckedKey: checkbox.attributes.containsKey('checked'),
      }),
    );
  }
}

final class _RawInlineHtmlSyntax extends md.InlineHtmlSyntax {
  @override
  bool onMatch(md.InlineParser parser, Match match) {
    parser.addNode(md.Element(_rawInlineHtmlTag, [md.Text(match[0]!)]));
    return true;
  }
}

final class _RawHtmlBlockSyntax extends md.HtmlBlockSyntax {
  const _RawHtmlBlockSyntax();

  @override
  md.Node parse(md.BlockParser parser) {
    final text = super.parse(parser).textContent;
    return md.Element(_rawBlockHtmlTag, [md.Text(text)]);
  }
}

extension on StringBuffer {
  void writeHtml(md.Node node) {
    if (node is md.Text) {
      write(const HtmlEscape(HtmlEscapeMode.element).convert(node.text));
      return;
    }
    if (node is! md.Element) {
      write(const HtmlEscape(HtmlEscapeMode.element).convert(node.textContent));
      return;
    }
    if (node.tag == _rawInlineHtmlTag || node.tag == _rawBlockHtmlTag) {
      write(node.textContent);
      return;
    }

    write('<${node.tag}');
    for (final attribute in node.attributes.entries) {
      final value = const HtmlEscape(
        HtmlEscapeMode.attribute,
      ).convert(attribute.value);
      write(' ${attribute.key}="$value"');
    }
    if (node.isEmpty) {
      write(' />');
      return;
    }
    write('>');
    node.children?.forEach(writeHtml);
    write('</${node.tag}>');
  }
}

TagflowDocumentNode _reId(
  TagflowDocumentNode node, {
  required String from,
  required String to,
}) {
  final id = node.id == from
      ? to
      : node.id.startsWith('$from.')
      ? '$to${node.id.substring(from.length)}'
      : node.id;

  return node.copyWith(
    id: id,
    children: [
      for (final child in node.children) _reId(child, from: from, to: to),
    ],
  );
}

TagflowMetadata _markRawHtml(TagflowMetadata metadata) {
  return metadata.merge(TagflowMetadata(const {_rawHtmlKey: true}));
}

TagflowMetadata _metadataFor(String tag) {
  return TagflowMetadata({_htmlTagKey: tag, _markdownTagKey: tag});
}

TagflowMetadata _withTitle(TagflowMetadata metadata, md.Element node) {
  final title = node.attributes['title'];
  if (title == null || title.isEmpty) return metadata;
  return metadata.merge(TagflowMetadata({_titleKey: title}));
}

md.Element? _taskCheckbox(md.Element listItem) {
  for (final child in listItem.children ?? const <md.Node>[]) {
    if (_isTaskCheckbox(child)) return child as md.Element;
    // Loose task lists wrap the checkbox in the first paragraph.
    if (child is md.Element && child.tag == 'p') {
      final first = child.children?.firstOrNull;
      if (first != null && _isTaskCheckbox(first)) return first as md.Element;
    }
    if (child is md.Element || child.textContent.trim().isNotEmpty) break;
  }
  return null;
}

bool _isTaskCheckbox(md.Node node) {
  return node is md.Element &&
      node.tag == 'input' &&
      node.attributes['type'] == 'checkbox';
}

bool _isRawInlineHtml(md.Node node) {
  return node is md.Element && node.tag == _rawInlineHtmlTag;
}

Iterable<md.Node> _withoutBlankText(Iterable<md.Node> nodes) {
  return nodes.where((node) => node is! md.Text || node.text.isNotEmpty);
}

String? _languageFor(md.Element? code) {
  final className = code?.attributes['class'];
  if (className == null) return null;
  for (final name in className.split(RegExp(r'\s+'))) {
    if (name.startsWith('language-') && name.length > 'language-'.length) {
      return name.substring('language-'.length);
    }
  }
  return null;
}

String? _variantFor(String tag) {
  return switch (tag) {
    'h1' || 'h2' || 'h3' || 'h4' || 'h5' || 'h6' => 'heading',
    'p' => 'paragraph',
    'pre' || 'code' => 'code',
    _ => null,
  };
}

Set<TagflowInlineSemantic> _inlineSemanticsFor(String tag) {
  return switch (tag) {
    'strong' => const {TagflowInlineSemantic.strong},
    'em' => const {TagflowInlineSemantic.emphasis},
    'del' => const {TagflowInlineSemantic.deleted},
    'sub' => const {TagflowInlineSemantic.subscript},
    'sup' => const {TagflowInlineSemantic.superscript},
    _ => const {},
  };
}

String _documentIdFor(String markdown) {
  var hash = 0;
  for (final codeUnit in markdown.codeUnits) {
    hash = (hash * 31 + codeUnit) & 0x3fffffff;
  }
  return 'markdown-$hash';
}
