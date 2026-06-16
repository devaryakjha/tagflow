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
    int version = 1,
  }) : version = _validateRuntimeDocumentVersion(version),
       children = List.unmodifiable(children),
       metadata = metadata ?? TagflowMetadata.empty;

  /// Creates a runtime document and validates that every node ID is unique.
  ///
  /// Use this factory for app-authored, CMS-authored, or AI-authored native
  /// document payloads that need fail-fast validation before rendering or
  /// patch application. The default constructor remains permissive for
  /// compatibility with existing alpha callers that validate explicitly.
  ///
  /// Throws [StateError] when duplicate node IDs are found.
  factory TagflowDocument.validated({
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

  /// Runtime document model schema version.
  ///
  /// This version belongs to Tagflow's in-process [TagflowDocument] model. It
  /// is intentionally separate from adapter or wire-format schema versions such
  /// as native block JSON `schemaVersion` values.
  final int version;

  /// Creates a copy of this document with selected fields replaced.
  ///
  /// This method preserves the default constructor's permissive alpha
  /// compatibility behavior. Use [copyWithValidated] when app-authored,
  /// CMS-authored, or AI-authored document updates should fail fast on
  /// duplicate node IDs.
  ///
  /// Nullable fields use explicit clear flags so omitted values can continue
  /// to mean "keep the current value". Set [clearSource] to remove [source].
  TagflowDocument copyWith({
    String? id,
    List<TagflowDocumentNode>? children,
    TagflowMetadata? metadata,
    TagflowSourceInfo? source,
    int? version,
    bool clearSource = false,
  }) {
    return TagflowDocument(
      id: id ?? this.id,
      children: children ?? this.children,
      metadata: metadata ?? this.metadata,
      source: _resolveNullableCopyField(
        current: this.source,
        replacement: source,
        clear: clearSource,
        name: 'source',
      ),
      version: version ?? this.version,
    );
  }

  /// Creates a validated copy of this document with selected fields replaced.
  ///
  /// Throws [StateError] when the resulting child tree contains duplicate node
  /// IDs.
  ///
  /// Set [clearSource] to remove [source].
  TagflowDocument copyWithValidated({
    String? id,
    List<TagflowDocumentNode>? children,
    TagflowMetadata? metadata,
    TagflowSourceInfo? source,
    int? version,
    bool clearSource = false,
  }) {
    return TagflowDocument.validated(
      id: id ?? this.id,
      children: children ?? this.children,
      metadata: metadata ?? this.metadata,
      source: _resolveNullableCopyField(
        current: this.source,
        replacement: source,
        clear: clearSource,
        name: 'source',
      ),
      version: version ?? this.version,
    );
  }

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

/// Validates a runtime document model schema version.
///
/// The version is reserved for Tagflow runtime model compatibility. App, CMS,
/// AI or adapter producers should use adapter metadata for their own payload
/// schema or revision values instead of mapping them into
/// [TagflowDocument.version].
int _validateRuntimeDocumentVersion(int version) {
  if (version < 1) {
    throw ArgumentError.value(
      version,
      'version',
      'TagflowDocument.version must be greater than 0.',
    );
  }
  return version;
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
