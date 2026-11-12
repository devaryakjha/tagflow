import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:tagflow/src/runtime/metadata.dart';
import 'package:tagflow/src/runtime/presentation.dart';
import 'package:tagflow/src/runtime/source.dart';

const ListEquality<TagflowDocumentNode> _nodeListEquality =
    ListEquality<TagflowDocumentNode>();

/// Semantic runtime node kinds for Tagflow documents.
enum TagflowNodeKind {
  root,
  container,
  paragraph,
  heading,
  text,
  link,
  list,
  listItem,
  descriptionList,
  descriptionTerm,
  descriptionDetails,
  blockquote,

  /// A collapsible section, like HTML `<details>`.
  ///
  /// Its first [disclosureSummary] child is the always-visible title; the
  /// other children are shown when the section is expanded.
  disclosure,

  /// The title of a [disclosure], like HTML `<summary>`.
  disclosureSummary,
  codeBlock,
  inlineCode,
  image,
  table,
  tableRow,
  tableCell,

  /// The caption of a [table], like HTML `<caption>`.
  tableCaption,
  horizontalRule,
  unsupported,
}

/// Immutable semantic node used by the runtime document model.
@immutable
final class TagflowDocumentNode {
  TagflowDocumentNode._({
    required this.id,
    required this.kind,
    List<TagflowDocumentNode> children = const [],
    TagflowPresentation? presentation,
    TagflowMetadata? metadata,
    this.source,
    this.text,
    this.url,
    this.level,
    this.ordered,
    this.startIndex,
    this.alt,
    this.width,
    this.height,
    this.language,
    this.rowSpan = 1,
    this.colSpan = 1,
    this.header = false,
    this.checked,
    this.expanded = false,
    this.unsupportedReason,
  }) : children = List.unmodifiable(children),
       presentation = presentation ?? TagflowPresentation.empty,
       metadata = metadata ?? TagflowMetadata.empty;

  /// Creates a root node.
  factory TagflowDocumentNode.root({
    required String id,
    List<TagflowDocumentNode> children = const [],
    TagflowPresentation? presentation,
    TagflowMetadata? metadata,
    TagflowSourceInfo? source,
  }) {
    return TagflowDocumentNode._(
      id: id,
      kind: TagflowNodeKind.root,
      children: children,
      presentation: presentation,
      metadata: metadata,
      source: source,
    );
  }

  /// Creates a generic container node.
  factory TagflowDocumentNode.container({
    required String id,
    List<TagflowDocumentNode> children = const [],
    TagflowPresentation? presentation,
    TagflowMetadata? metadata,
    TagflowSourceInfo? source,
  }) {
    return TagflowDocumentNode._(
      id: id,
      kind: TagflowNodeKind.container,
      children: children,
      presentation: presentation,
      metadata: metadata,
      source: source,
    );
  }

  /// Creates a paragraph node.
  factory TagflowDocumentNode.paragraph({
    required String id,
    List<TagflowDocumentNode> children = const [],
    TagflowPresentation? presentation,
    TagflowMetadata? metadata,
    TagflowSourceInfo? source,
  }) {
    return TagflowDocumentNode._(
      id: id,
      kind: TagflowNodeKind.paragraph,
      children: children,
      presentation: presentation,
      metadata: metadata,
      source: source,
    );
  }

  /// Creates a heading node.
  factory TagflowDocumentNode.heading({
    required String id,
    required int level,
    List<TagflowDocumentNode> children = const [],
    TagflowPresentation? presentation,
    TagflowMetadata? metadata,
    TagflowSourceInfo? source,
  }) {
    return TagflowDocumentNode._(
      id: id,
      kind: TagflowNodeKind.heading,
      children: children,
      presentation: presentation,
      metadata: metadata,
      source: source,
      level: level,
    );
  }

  /// Creates a text node.
  factory TagflowDocumentNode.text({
    required String id,
    required String text,
    TagflowPresentation? presentation,
    TagflowMetadata? metadata,
    TagflowSourceInfo? source,
  }) {
    return TagflowDocumentNode._(
      id: id,
      kind: TagflowNodeKind.text,
      presentation: presentation,
      metadata: metadata,
      source: source,
      text: text,
    );
  }

  /// Creates a link node.
  factory TagflowDocumentNode.link({
    required String id,
    required Uri url,
    List<TagflowDocumentNode> children = const [],
    TagflowPresentation? presentation,
    TagflowMetadata? metadata,
    TagflowSourceInfo? source,
  }) {
    return TagflowDocumentNode._(
      id: id,
      kind: TagflowNodeKind.link,
      children: children,
      presentation: presentation,
      metadata: metadata,
      source: source,
      url: url,
    );
  }

  /// Creates a list node.
  factory TagflowDocumentNode.list({
    required String id,
    required bool ordered,
    int? startIndex,
    List<TagflowDocumentNode> children = const [],
    TagflowPresentation? presentation,
    TagflowMetadata? metadata,
    TagflowSourceInfo? source,
  }) {
    return TagflowDocumentNode._(
      id: id,
      kind: TagflowNodeKind.list,
      children: children,
      presentation: presentation,
      metadata: metadata,
      source: source,
      ordered: ordered,
      startIndex: startIndex,
    );
  }

  /// Creates a list item node.
  ///
  /// Set [checked] to make a task list item: `true` for a done task, `false`
  /// for an open one. Leave it `null` for an ordinary item.
  factory TagflowDocumentNode.listItem({
    required String id,
    List<TagflowDocumentNode> children = const [],
    bool? checked,
    TagflowPresentation? presentation,
    TagflowMetadata? metadata,
    TagflowSourceInfo? source,
  }) {
    return TagflowDocumentNode._(
      id: id,
      kind: TagflowNodeKind.listItem,
      children: children,
      presentation: presentation,
      metadata: metadata,
      source: source,
      checked: checked,
    );
  }

  /// Creates a description list node.
  factory TagflowDocumentNode.descriptionList({
    required String id,
    List<TagflowDocumentNode> children = const [],
    TagflowPresentation? presentation,
    TagflowMetadata? metadata,
    TagflowSourceInfo? source,
  }) {
    return TagflowDocumentNode._(
      id: id,
      kind: TagflowNodeKind.descriptionList,
      children: children,
      presentation: presentation,
      metadata: metadata,
      source: source,
    );
  }

  /// Creates a description term node.
  factory TagflowDocumentNode.descriptionTerm({
    required String id,
    List<TagflowDocumentNode> children = const [],
    TagflowPresentation? presentation,
    TagflowMetadata? metadata,
    TagflowSourceInfo? source,
  }) {
    return TagflowDocumentNode._(
      id: id,
      kind: TagflowNodeKind.descriptionTerm,
      children: children,
      presentation: presentation,
      metadata: metadata,
      source: source,
    );
  }

  /// Creates a description details node.
  factory TagflowDocumentNode.descriptionDetails({
    required String id,
    List<TagflowDocumentNode> children = const [],
    TagflowPresentation? presentation,
    TagflowMetadata? metadata,
    TagflowSourceInfo? source,
  }) {
    return TagflowDocumentNode._(
      id: id,
      kind: TagflowNodeKind.descriptionDetails,
      children: children,
      presentation: presentation,
      metadata: metadata,
      source: source,
    );
  }

  /// Creates a disclosure node: a section that can be expanded and collapsed.
  ///
  /// The first [TagflowNodeKind.disclosureSummary] child is the title. When
  /// [expanded] is true the section starts open.
  factory TagflowDocumentNode.disclosure({
    required String id,
    List<TagflowDocumentNode> children = const [],
    bool expanded = false,
    TagflowPresentation? presentation,
    TagflowMetadata? metadata,
    TagflowSourceInfo? source,
  }) {
    return TagflowDocumentNode._(
      id: id,
      kind: TagflowNodeKind.disclosure,
      children: children,
      presentation: presentation,
      metadata: metadata,
      source: source,
      expanded: expanded,
    );
  }

  /// Creates the title node of a disclosure.
  factory TagflowDocumentNode.disclosureSummary({
    required String id,
    List<TagflowDocumentNode> children = const [],
    TagflowPresentation? presentation,
    TagflowMetadata? metadata,
    TagflowSourceInfo? source,
  }) {
    return TagflowDocumentNode._(
      id: id,
      kind: TagflowNodeKind.disclosureSummary,
      children: children,
      presentation: presentation,
      metadata: metadata,
      source: source,
    );
  }

  /// Creates a blockquote node.
  factory TagflowDocumentNode.blockquote({
    required String id,
    List<TagflowDocumentNode> children = const [],
    TagflowPresentation? presentation,
    TagflowMetadata? metadata,
    TagflowSourceInfo? source,
  }) {
    return TagflowDocumentNode._(
      id: id,
      kind: TagflowNodeKind.blockquote,
      children: children,
      presentation: presentation,
      metadata: metadata,
      source: source,
    );
  }

  /// Creates a block code node.
  factory TagflowDocumentNode.codeBlock({
    required String id,
    required String text,
    String? language,
    TagflowPresentation? presentation,
    TagflowMetadata? metadata,
    TagflowSourceInfo? source,
  }) {
    return TagflowDocumentNode._(
      id: id,
      kind: TagflowNodeKind.codeBlock,
      presentation: presentation,
      metadata: metadata,
      source: source,
      text: text,
      language: language,
    );
  }

  /// Creates an inline code node.
  factory TagflowDocumentNode.inlineCode({
    required String id,
    required String text,
    TagflowPresentation? presentation,
    TagflowMetadata? metadata,
    TagflowSourceInfo? source,
  }) {
    return TagflowDocumentNode._(
      id: id,
      kind: TagflowNodeKind.inlineCode,
      presentation: presentation,
      metadata: metadata,
      source: source,
      text: text,
    );
  }

  /// Creates an image node.
  factory TagflowDocumentNode.image({
    required String id,
    required Uri url,
    String? alt,
    double? width,
    double? height,
    TagflowPresentation? presentation,
    TagflowMetadata? metadata,
    TagflowSourceInfo? source,
  }) {
    return TagflowDocumentNode._(
      id: id,
      kind: TagflowNodeKind.image,
      presentation: presentation,
      metadata: metadata,
      source: source,
      url: url,
      alt: alt,
      width: width,
      height: height,
    );
  }

  /// Creates a table node.
  factory TagflowDocumentNode.table({
    required String id,
    List<TagflowDocumentNode> children = const [],
    TagflowPresentation? presentation,
    TagflowMetadata? metadata,
    TagflowSourceInfo? source,
  }) {
    return TagflowDocumentNode._(
      id: id,
      kind: TagflowNodeKind.table,
      children: children,
      presentation: presentation,
      metadata: metadata,
      source: source,
    );
  }

  /// Creates a table row node.
  factory TagflowDocumentNode.tableRow({
    required String id,
    List<TagflowDocumentNode> children = const [],
    TagflowPresentation? presentation,
    TagflowMetadata? metadata,
    TagflowSourceInfo? source,
  }) {
    return TagflowDocumentNode._(
      id: id,
      kind: TagflowNodeKind.tableRow,
      children: children,
      presentation: presentation,
      metadata: metadata,
      source: source,
    );
  }

  /// Creates a table caption node.
  ///
  /// Put it among the children of a [TagflowNodeKind.table] node; renderers
  /// show it above the rows.
  factory TagflowDocumentNode.tableCaption({
    required String id,
    List<TagflowDocumentNode> children = const [],
    TagflowPresentation? presentation,
    TagflowMetadata? metadata,
    TagflowSourceInfo? source,
  }) {
    return TagflowDocumentNode._(
      id: id,
      kind: TagflowNodeKind.tableCaption,
      children: children,
      presentation: presentation,
      metadata: metadata,
      source: source,
    );
  }

  /// Creates a table cell node.
  factory TagflowDocumentNode.tableCell({
    required String id,
    List<TagflowDocumentNode> children = const [],
    int rowSpan = 1,
    int colSpan = 1,
    bool header = false,
    TagflowPresentation? presentation,
    TagflowMetadata? metadata,
    TagflowSourceInfo? source,
  }) {
    return TagflowDocumentNode._(
      id: id,
      kind: TagflowNodeKind.tableCell,
      children: children,
      presentation: presentation,
      metadata: metadata,
      source: source,
      rowSpan: rowSpan,
      colSpan: colSpan,
      header: header,
    );
  }

  /// Creates a horizontal rule node.
  factory TagflowDocumentNode.horizontalRule({
    required String id,
    TagflowPresentation? presentation,
    TagflowMetadata? metadata,
    TagflowSourceInfo? source,
  }) {
    return TagflowDocumentNode._(
      id: id,
      kind: TagflowNodeKind.horizontalRule,
      presentation: presentation,
      metadata: metadata,
      source: source,
    );
  }

  /// Creates an unsupported placeholder node.
  factory TagflowDocumentNode.unsupported({
    required String id,
    String? unsupportedReason,
    List<TagflowDocumentNode> children = const [],
    TagflowPresentation? presentation,
    TagflowMetadata? metadata,
    TagflowSourceInfo? source,
  }) {
    return TagflowDocumentNode._(
      id: id,
      kind: TagflowNodeKind.unsupported,
      children: children,
      presentation: presentation,
      metadata: metadata,
      source: source,
      unsupportedReason: unsupportedReason,
    );
  }

  /// Stable node identifier.
  final String id;

  /// Semantic node kind.
  final TagflowNodeKind kind;

  /// Child runtime nodes.
  final List<TagflowDocumentNode> children;

  /// Presentation hints for the renderer layer.
  final TagflowPresentation presentation;

  /// Non-visual metadata attached to the node.
  final TagflowMetadata metadata;

  /// Optional source record.
  final TagflowSourceInfo? source;

  /// Text payload for text or code nodes.
  final String? text;

  /// URI payload for link or image nodes.
  final Uri? url;

  /// Heading level for heading nodes.
  final int? level;

  /// Ordered flag for list nodes.
  final bool? ordered;

  /// Optional list start index for ordered lists.
  final int? startIndex;

  /// Alt text for image nodes.
  final String? alt;

  /// Suggested media width.
  final double? width;

  /// Suggested media height.
  final double? height;

  /// Optional language identifier for code blocks.
  final String? language;

  /// Row span for table cells.
  final int rowSpan;

  /// Column span for table cells.
  final int colSpan;

  /// Header flag for table cells.
  final bool header;

  /// Task state for list items: `true` when done, `false` when open, and
  /// `null` when the item is not a task.
  final bool? checked;

  /// Whether a disclosure node starts expanded.
  final bool expanded;

  /// Optional unsupported-content reason.
  final String? unsupportedReason;

  /// Creates a copy of this node with selected fields replaced.
  ///
  /// The copied node remains immutable: replacement children are copied into an
  /// unmodifiable list by the private runtime constructor.
  ///
  /// Nullable fields use explicit clear flags so omitted values can continue
  /// to mean "keep the current value". For example, set [clearAlt] to remove
  /// image alt text or [clearText] to remove a text/code payload.
  TagflowDocumentNode copyWith({
    String? id,
    TagflowNodeKind? kind,
    List<TagflowDocumentNode>? children,
    TagflowPresentation? presentation,
    TagflowMetadata? metadata,
    TagflowSourceInfo? source,
    String? text,
    Uri? url,
    int? level,
    bool? ordered,
    int? startIndex,
    String? alt,
    double? width,
    double? height,
    String? language,
    int? rowSpan,
    int? colSpan,
    bool? header,
    bool? checked,
    bool? expanded,
    String? unsupportedReason,
    bool clearSource = false,
    bool clearText = false,
    bool clearUrl = false,
    bool clearLevel = false,
    bool clearOrdered = false,
    bool clearStartIndex = false,
    bool clearAlt = false,
    bool clearWidth = false,
    bool clearHeight = false,
    bool clearLanguage = false,
    bool clearChecked = false,
    bool clearUnsupportedReason = false,
  }) {
    return TagflowDocumentNode._(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      children: children ?? this.children,
      presentation: presentation ?? this.presentation,
      metadata: metadata ?? this.metadata,
      source: _resolveNullableCopyField(
        current: this.source,
        replacement: source,
        clear: clearSource,
        name: 'source',
      ),
      text: _resolveNullableCopyField(
        current: this.text,
        replacement: text,
        clear: clearText,
        name: 'text',
      ),
      url: _resolveNullableCopyField(
        current: this.url,
        replacement: url,
        clear: clearUrl,
        name: 'url',
      ),
      level: _resolveNullableCopyField(
        current: this.level,
        replacement: level,
        clear: clearLevel,
        name: 'level',
      ),
      ordered: _resolveNullableCopyField(
        current: this.ordered,
        replacement: ordered,
        clear: clearOrdered,
        name: 'ordered',
      ),
      startIndex: _resolveNullableCopyField(
        current: this.startIndex,
        replacement: startIndex,
        clear: clearStartIndex,
        name: 'startIndex',
      ),
      alt: _resolveNullableCopyField(
        current: this.alt,
        replacement: alt,
        clear: clearAlt,
        name: 'alt',
      ),
      width: _resolveNullableCopyField(
        current: this.width,
        replacement: width,
        clear: clearWidth,
        name: 'width',
      ),
      height: _resolveNullableCopyField(
        current: this.height,
        replacement: height,
        clear: clearHeight,
        name: 'height',
      ),
      language: _resolveNullableCopyField(
        current: this.language,
        replacement: language,
        clear: clearLanguage,
        name: 'language',
      ),
      rowSpan: rowSpan ?? this.rowSpan,
      colSpan: colSpan ?? this.colSpan,
      header: header ?? this.header,
      checked: _resolveNullableCopyField(
        current: this.checked,
        replacement: checked,
        clear: clearChecked,
        name: 'checked',
      ),
      expanded: expanded ?? this.expanded,
      unsupportedReason: _resolveNullableCopyField(
        current: this.unsupportedReason,
        replacement: unsupportedReason,
        clear: clearUnsupportedReason,
        name: 'unsupportedReason',
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TagflowDocumentNode &&
            other.id == id &&
            other.kind == kind &&
            _nodeListEquality.equals(other.children, children) &&
            other.presentation == presentation &&
            other.metadata == metadata &&
            other.source == source &&
            other.text == text &&
            other.url == url &&
            other.level == level &&
            other.ordered == ordered &&
            other.startIndex == startIndex &&
            other.alt == alt &&
            other.width == width &&
            other.height == height &&
            other.language == language &&
            other.rowSpan == rowSpan &&
            other.colSpan == colSpan &&
            other.header == header &&
            other.checked == checked &&
            other.expanded == expanded &&
            other.unsupportedReason == unsupportedReason;
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    kind,
    _nodeListEquality.hash(children),
    presentation,
    metadata,
    source,
    text,
    url,
    level,
    ordered,
    startIndex,
    alt,
    width,
    height,
    language,
    rowSpan,
    colSpan,
    header,
    checked,
    expanded,
    unsupportedReason,
  ]);
}

T? _resolveNullableCopyField<T>({
  required T? current,
  required T? replacement,
  required bool clear,
  required String name,
}) {
  if (clear && replacement != null) {
    throw ArgumentError.value(
      replacement,
      name,
      'Cannot provide a replacement while also clearing the field.',
    );
  }
  return clear ? null : replacement ?? current;
}
