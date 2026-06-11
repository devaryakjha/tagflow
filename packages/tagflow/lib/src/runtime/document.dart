import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:tagflow/src/runtime/document_node.dart';
import 'package:tagflow/src/runtime/document_traversal.dart';
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

  /// Creates a runtime document and validates that every node ID is unique.
  ///
  /// Use this factory for app-authored, CMS-authored, or AI-authored native
  /// document payloads that need fail-fast validation before rendering or
  /// patch application. The default constructor remains permissive for
  /// compatibility with existing alpha callers that validate explicitly.
  ///
  /// Throws [StateError] when duplicate node IDs are found.
  factory TagflowDocument.checked({
    required String id,
    required List<TagflowDocumentNode> children,
    TagflowMetadata? metadata,
    TagflowSourceInfo? source,
    int version = 1,
  }) {
    validateUniqueNodeIdsInChildren(children);
    return TagflowDocument(
      id: id,
      children: children,
      metadata: metadata,
      source: source,
      version: version,
    );
  }

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

/// Query and validation helpers for [TagflowDocument].
extension TagflowDocumentQueries on TagflowDocument {
  /// Returns the first node with [nodeId], or `null` when none exists.
  TagflowDocumentNode? nodeById(String nodeId) {
    return findNodeByIdInChildren(children, nodeId);
  }

  /// Returns whether any node in the document uses [nodeId].
  bool containsNodeId(String nodeId) {
    return containsNodeIdInChildren(children, nodeId);
  }

  /// Validates that every node ID in the document tree is unique.
  ///
  /// Throws [StateError] when a duplicate node ID is found.
  void validateUniqueNodeIds() {
    validateUniqueNodeIdsInChildren(children);
  }
}
