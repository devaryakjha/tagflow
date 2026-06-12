import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:tagflow/src/runtime/metadata.dart';
import 'package:tagflow/src/runtime/source.dart';

const ListEquality<TagflowNativeBlock> _nativeBlockListEquality =
    ListEquality<TagflowNativeBlock>();
const MapEquality<String, Object?> _nativeBlockAttributeEquality =
    MapEquality<String, Object?>();

/// Semantic native block kinds supported by the block adapter contract.
enum TagflowNativeBlockKind {
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
  codeBlock,
  inlineCode,
  image,
  table,
  tableRow,
  tableCell,
  callout,
  horizontalRule,
  container,
}

/// Immutable native block payload adapted into the runtime document model.
@immutable
final class TagflowNativeBlock {
  /// Creates a native block.
  TagflowNativeBlock({
    required this.id,
    required this.kind,
    this.text,
    Map<String, Object?> attributes = const {},
    List<TagflowNativeBlock> children = const [],
    TagflowMetadata? metadata,
    this.source,
  }) : attributes = Map.unmodifiable(attributes),
       children = List.unmodifiable(children),
       metadata = metadata ?? TagflowMetadata.empty;

  /// Creates a paragraph block.
  factory TagflowNativeBlock.paragraph({
    required String id,
    List<TagflowNativeBlock> children = const [],
    TagflowMetadata? metadata,
    TagflowSourceInfo? source,
  }) {
    return TagflowNativeBlock(
      id: id,
      kind: TagflowNativeBlockKind.paragraph,
      children: children,
      metadata: metadata,
      source: source,
    );
  }

  /// Creates a heading block.
  factory TagflowNativeBlock.heading({
    required String id,
    required int level,
    List<TagflowNativeBlock> children = const [],
    TagflowMetadata? metadata,
    TagflowSourceInfo? source,
  }) {
    return TagflowNativeBlock(
      id: id,
      kind: TagflowNativeBlockKind.heading,
      attributes: {'level': level},
      children: children,
      metadata: metadata,
      source: source,
    );
  }

  /// Creates a text block.
  factory TagflowNativeBlock.text({
    required String id,
    required String text,
    TagflowMetadata? metadata,
    TagflowSourceInfo? source,
  }) {
    return TagflowNativeBlock(
      id: id,
      kind: TagflowNativeBlockKind.text,
      text: text,
      metadata: metadata,
      source: source,
    );
  }

  /// Creates a link block.
  factory TagflowNativeBlock.link({
    required String id,
    required String url,
    List<TagflowNativeBlock> children = const [],
    String? title,
    TagflowMetadata? metadata,
    TagflowSourceInfo? source,
  }) {
    return TagflowNativeBlock(
      id: id,
      kind: TagflowNativeBlockKind.link,
      attributes: {'url': url, if (title != null) 'title': title},
      children: children,
      metadata: metadata,
      source: source,
    );
  }

  /// Creates a list block.
  factory TagflowNativeBlock.list({
    required String id,
    required bool ordered,
    int? startIndex,
    List<TagflowNativeBlock> children = const [],
    TagflowMetadata? metadata,
    TagflowSourceInfo? source,
  }) {
    return TagflowNativeBlock(
      id: id,
      kind: TagflowNativeBlockKind.list,
      attributes: {
        'ordered': ordered,
        if (startIndex != null) 'startIndex': startIndex,
      },
      children: children,
      metadata: metadata,
      source: source,
    );
  }

  /// Creates a list item block.
  factory TagflowNativeBlock.listItem({
    required String id,
    List<TagflowNativeBlock> children = const [],
    TagflowMetadata? metadata,
    TagflowSourceInfo? source,
  }) {
    return TagflowNativeBlock(
      id: id,
      kind: TagflowNativeBlockKind.listItem,
      children: children,
      metadata: metadata,
      source: source,
    );
  }

  /// Creates a description-list block.
  factory TagflowNativeBlock.descriptionList({
    required String id,
    List<TagflowNativeBlock> children = const [],
    TagflowMetadata? metadata,
    TagflowSourceInfo? source,
  }) {
    return TagflowNativeBlock(
      id: id,
      kind: TagflowNativeBlockKind.descriptionList,
      children: children,
      metadata: metadata,
      source: source,
    );
  }

  /// Creates a description-term block.
  factory TagflowNativeBlock.descriptionTerm({
    required String id,
    List<TagflowNativeBlock> children = const [],
    TagflowMetadata? metadata,
    TagflowSourceInfo? source,
  }) {
    return TagflowNativeBlock(
      id: id,
      kind: TagflowNativeBlockKind.descriptionTerm,
      children: children,
      metadata: metadata,
      source: source,
    );
  }

  /// Creates a description-details block.
  factory TagflowNativeBlock.descriptionDetails({
    required String id,
    List<TagflowNativeBlock> children = const [],
    TagflowMetadata? metadata,
    TagflowSourceInfo? source,
  }) {
    return TagflowNativeBlock(
      id: id,
      kind: TagflowNativeBlockKind.descriptionDetails,
      children: children,
      metadata: metadata,
      source: source,
    );
  }

  /// Creates a blockquote block.
  factory TagflowNativeBlock.blockquote({
    required String id,
    List<TagflowNativeBlock> children = const [],
    TagflowMetadata? metadata,
    TagflowSourceInfo? source,
  }) {
    return TagflowNativeBlock(
      id: id,
      kind: TagflowNativeBlockKind.blockquote,
      children: children,
      metadata: metadata,
      source: source,
    );
  }

  /// Creates a code-block block.
  factory TagflowNativeBlock.codeBlock({
    required String id,
    required String text,
    String? language,
    TagflowMetadata? metadata,
    TagflowSourceInfo? source,
  }) {
    return TagflowNativeBlock(
      id: id,
      kind: TagflowNativeBlockKind.codeBlock,
      text: text,
      attributes: {if (language != null) 'language': language},
      metadata: metadata,
      source: source,
    );
  }

  /// Creates an inline-code block.
  factory TagflowNativeBlock.inlineCode({
    required String id,
    required String text,
    TagflowMetadata? metadata,
    TagflowSourceInfo? source,
  }) {
    return TagflowNativeBlock(
      id: id,
      kind: TagflowNativeBlockKind.inlineCode,
      text: text,
      metadata: metadata,
      source: source,
    );
  }

  /// Creates an image block.
  factory TagflowNativeBlock.image({
    required String id,
    required String url,
    String? alt,
    double? width,
    double? height,
    TagflowMetadata? metadata,
    TagflowSourceInfo? source,
  }) {
    return TagflowNativeBlock(
      id: id,
      kind: TagflowNativeBlockKind.image,
      attributes: {
        'url': url,
        if (alt != null) 'alt': alt,
        if (width != null) 'width': width,
        if (height != null) 'height': height,
      },
      metadata: metadata,
      source: source,
    );
  }

  /// Creates a table block.
  factory TagflowNativeBlock.table({
    required String id,
    List<TagflowNativeBlock> children = const [],
    TagflowMetadata? metadata,
    TagflowSourceInfo? source,
  }) {
    return TagflowNativeBlock(
      id: id,
      kind: TagflowNativeBlockKind.table,
      children: children,
      metadata: metadata,
      source: source,
    );
  }

  /// Creates a table-row block.
  factory TagflowNativeBlock.tableRow({
    required String id,
    List<TagflowNativeBlock> children = const [],
    TagflowMetadata? metadata,
    TagflowSourceInfo? source,
  }) {
    return TagflowNativeBlock(
      id: id,
      kind: TagflowNativeBlockKind.tableRow,
      children: children,
      metadata: metadata,
      source: source,
    );
  }

  /// Creates a table-cell block.
  factory TagflowNativeBlock.tableCell({
    required String id,
    List<TagflowNativeBlock> children = const [],
    bool header = false,
    int rowSpan = 1,
    int colSpan = 1,
    TagflowMetadata? metadata,
    TagflowSourceInfo? source,
  }) {
    return TagflowNativeBlock(
      id: id,
      kind: TagflowNativeBlockKind.tableCell,
      attributes: {
        if (header) 'header': true,
        if (rowSpan != 1) 'rowSpan': rowSpan,
        if (colSpan != 1) 'colSpan': colSpan,
      },
      children: children,
      metadata: metadata,
      source: source,
    );
  }

  /// Creates a callout block.
  factory TagflowNativeBlock.callout({
    required String id,
    List<TagflowNativeBlock> children = const [],
    String? tone,
    String? variant,
    String? title,
    TagflowMetadata? metadata,
    TagflowSourceInfo? source,
  }) {
    return TagflowNativeBlock(
      id: id,
      kind: TagflowNativeBlockKind.callout,
      attributes: {
        if (tone != null) 'tone': tone,
        if (variant != null) 'variant': variant,
        if (title != null) 'title': title,
      },
      children: children,
      metadata: metadata,
      source: source,
    );
  }

  /// Creates a container block.
  factory TagflowNativeBlock.container({
    required String id,
    List<TagflowNativeBlock> children = const [],
    TagflowMetadata? metadata,
    TagflowSourceInfo? source,
  }) {
    return TagflowNativeBlock(
      id: id,
      kind: TagflowNativeBlockKind.container,
      children: children,
      metadata: metadata,
      source: source,
    );
  }

  /// Creates a horizontal-rule block.
  factory TagflowNativeBlock.horizontalRule({
    required String id,
    TagflowMetadata? metadata,
    TagflowSourceInfo? source,
  }) {
    return TagflowNativeBlock(
      id: id,
      kind: TagflowNativeBlockKind.horizontalRule,
      metadata: metadata,
      source: source,
    );
  }

  /// Stable block identifier.
  final String id;

  /// Semantic block kind.
  final TagflowNativeBlockKind kind;

  /// Optional leaf text payload.
  final String? text;

  /// Kind-specific structured attributes.
  final Map<String, Object?> attributes;

  /// Ordered child blocks.
  final List<TagflowNativeBlock> children;

  /// Non-executable block metadata.
  final TagflowMetadata metadata;

  /// Optional per-block provenance.
  final TagflowSourceInfo? source;

  /// String form of [kind] for producer diagnostics or serialization.
  String get type => kind.name;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TagflowNativeBlock &&
            other.id == id &&
            other.kind == kind &&
            other.text == text &&
            _nativeBlockAttributeEquality.equals(
              other.attributes,
              attributes,
            ) &&
            _nativeBlockListEquality.equals(other.children, children) &&
            other.metadata == metadata &&
            other.source == source;
  }

  @override
  int get hashCode => Object.hash(
    id,
    kind,
    text,
    _nativeBlockAttributeEquality.hash(attributes),
    _nativeBlockListEquality.hash(children),
    metadata,
    source,
  );
}

/// Immutable document envelope for native blocks.
@immutable
final class TagflowNativeBlockDocument {
  /// Creates a native block document.
  TagflowNativeBlockDocument({
    required this.id,
    required this.schemaVersion,
    required List<TagflowNativeBlock> blocks,
    TagflowMetadata? metadata,
    this.source,
    this.revision,
  }) : blocks = List.unmodifiable(blocks),
       metadata = metadata ?? TagflowMetadata.empty;

  /// Stable document identifier.
  final String id;

  /// Adapter schema version for this payload.
  final int schemaVersion;

  /// Ordered root blocks.
  final List<TagflowNativeBlock> blocks;

  /// Non-executable document metadata.
  final TagflowMetadata metadata;

  /// Optional document provenance.
  final TagflowSourceInfo? source;

  /// Optional producer revision token.
  final String? revision;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TagflowNativeBlockDocument &&
            other.id == id &&
            other.schemaVersion == schemaVersion &&
            _nativeBlockListEquality.equals(other.blocks, blocks) &&
            other.metadata == metadata &&
            other.source == source &&
            other.revision == revision;
  }

  @override
  int get hashCode => Object.hash(
    id,
    schemaVersion,
    _nativeBlockListEquality.hash(blocks),
    metadata,
    source,
    revision,
  );
}
