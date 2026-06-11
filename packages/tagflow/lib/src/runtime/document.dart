import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:tagflow/src/runtime/document_node.dart';
import 'package:tagflow/src/runtime/metadata.dart';
import 'package:tagflow/src/runtime/source.dart';

const ListEquality<TagflowDocumentNode> _documentChildrenEquality =
    ListEquality<TagflowDocumentNode>();

/// Immutable source-agnostic rich-content document for Tagflow runtime APIs.
@immutable
final class TagflowDocument {
  /// Creates a new runtime document.
  TagflowDocument({
    required this.id,
    required List<TagflowDocumentNode> children,
    TagflowMetadata? metadata,
    this.source,
    this.version = 1,
  }) : children = List.unmodifiable(children),
       metadata = metadata ?? TagflowMetadata.empty;

  /// Stable document identifier.
  final String id;

  /// Root-level document nodes.
  final List<TagflowDocumentNode> children;

  /// Document metadata.
  final TagflowMetadata metadata;

  /// Source information for the document.
  final TagflowSourceInfo? source;

  /// Runtime document schema version.
  final int version;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TagflowDocument &&
            other.id == id &&
            _documentChildrenEquality.equals(other.children, children) &&
            other.metadata == metadata &&
            other.source == source &&
            other.version == version;
  }

  @override
  int get hashCode => Object.hash(
    id,
    _documentChildrenEquality.hash(children),
    metadata,
    source,
    version,
  );
}
