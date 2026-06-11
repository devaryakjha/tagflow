import 'package:meta/meta.dart';
import 'package:tagflow/src/runtime/document.dart';
import 'package:tagflow/src/runtime/document_node.dart';
import 'package:tagflow/src/runtime/document_traversal.dart';

/// Immutable structural update operation for a [TagflowDocument].
@immutable
final class TagflowDocumentPatch {
  /// Creates a patch that replaces the existing node with [nodeId].
  const TagflowDocumentPatch.replaceNode({
    required String nodeId,
    required TagflowDocumentNode node,
  }) : _kind = _TagflowDocumentPatchKind.replaceNode,
       _targetNodeId = nodeId,
       _node = node,
       _children = const [];

  /// Creates a patch that appends [children] to the existing parent node.
  TagflowDocumentPatch.appendChildren({
    required String parentNodeId,
    required List<TagflowDocumentNode> children,
  }) : _kind = _TagflowDocumentPatchKind.appendChildren,
       _targetNodeId = parentNodeId,
       _node = null,
       _children = List.unmodifiable(children);

  /// Creates a patch that removes the existing node with [nodeId].
  const TagflowDocumentPatch.removeNode({required String nodeId})
    : _kind = _TagflowDocumentPatchKind.removeNode,
      _targetNodeId = nodeId,
      _node = null,
      _children = const [];

  final _TagflowDocumentPatchKind _kind;
  final String _targetNodeId;
  final TagflowDocumentNode? _node;
  final List<TagflowDocumentNode> _children;
}

/// Immutable update helpers for [TagflowDocument].
extension TagflowDocumentUpdates on TagflowDocument {
  /// Applies [patch] and returns a new document.
  ///
  /// Throws [ArgumentError] when the patch target does not exist or when a
  /// replacement node does not use the target ID. Throws [StateError] when the
  /// current or updated document contains duplicate node IDs.
  TagflowDocument applyPatch(TagflowDocumentPatch patch) {
    validateUniqueNodeIdsInChildren(children);
    if (!containsNodeIdInChildren(children, patch._targetNodeId)) {
      throw ArgumentError.value(
        patch._targetNodeId,
        'nodeId',
        'No TagflowDocumentNode exists with this id.',
      );
    }

    final updatedChildren = switch (patch._kind) {
      _TagflowDocumentPatchKind.replaceNode => _replaceNode(
        children,
        patch._targetNodeId,
        _validatedReplacement(patch),
      ),
      _TagflowDocumentPatchKind.appendChildren => _appendChildren(
        children,
        patch._targetNodeId,
        patch._children,
      ),
      _TagflowDocumentPatchKind.removeNode => _removeNode(
        children,
        patch._targetNodeId,
      ),
    };
    validateUniqueNodeIdsInChildren(updatedChildren);
    return _copyDocumentWithChildren(this, updatedChildren);
  }

  /// Applies [patches] in order and returns the final document.
  ///
  /// Each patch has the same validation behavior as [applyPatch].
  TagflowDocument applyPatches(Iterable<TagflowDocumentPatch> patches) {
    var document = this;
    for (final patch in patches) {
      document = document.applyPatch(patch);
    }
    return document;
  }
}

enum _TagflowDocumentPatchKind { replaceNode, appendChildren, removeNode }

TagflowDocumentNode _validatedReplacement(TagflowDocumentPatch patch) {
  final node = patch._node;
  if (node == null) {
    throw StateError('Replace-node patch is missing a replacement node.');
  }
  if (node.id != patch._targetNodeId) {
    throw ArgumentError.value(
      node.id,
      'node.id',
      'Replacement node id must match nodeId ${patch._targetNodeId}.',
    );
  }
  return node;
}

TagflowDocument _copyDocumentWithChildren(
  TagflowDocument document,
  List<TagflowDocumentNode> children,
) {
  return TagflowDocument(
    id: document.id,
    children: children,
    metadata: document.metadata,
    source: document.source,
    version: document.version,
  );
}

List<TagflowDocumentNode> _replaceNode(
  List<TagflowDocumentNode> nodes,
  String nodeId,
  TagflowDocumentNode replacement,
) {
  var changed = false;
  final updated = <TagflowDocumentNode>[];

  for (final node in nodes) {
    if (node.id == nodeId) {
      updated.add(replacement);
      changed = true;
    } else {
      final updatedNode = _replaceNodeInDescendants(node, nodeId, replacement);
      updated.add(updatedNode);
      changed = changed || !identical(updatedNode, node);
    }
  }

  return changed ? List.unmodifiable(updated) : nodes;
}

TagflowDocumentNode _replaceNodeInDescendants(
  TagflowDocumentNode node,
  String nodeId,
  TagflowDocumentNode replacement,
) {
  if (node.children.isEmpty) {
    return node;
  }

  final updatedChildren = _replaceNode(node.children, nodeId, replacement);
  if (identical(updatedChildren, node.children)) {
    return node;
  }
  return _copyNodeWithChildren(node, updatedChildren);
}

List<TagflowDocumentNode> _appendChildren(
  List<TagflowDocumentNode> nodes,
  String parentNodeId,
  List<TagflowDocumentNode> children,
) {
  var changed = false;
  final updated = <TagflowDocumentNode>[];

  for (final node in nodes) {
    if (node.id == parentNodeId) {
      updated.add(_copyNodeWithChildren(node, [...node.children, ...children]));
      changed = true;
    } else {
      final updatedNode = _appendChildrenInDescendants(
        node,
        parentNodeId,
        children,
      );
      updated.add(updatedNode);
      changed = changed || !identical(updatedNode, node);
    }
  }

  return changed ? List.unmodifiable(updated) : nodes;
}

TagflowDocumentNode _appendChildrenInDescendants(
  TagflowDocumentNode node,
  String parentNodeId,
  List<TagflowDocumentNode> children,
) {
  if (node.children.isEmpty) {
    return node;
  }

  final updatedChildren = _appendChildren(
    node.children,
    parentNodeId,
    children,
  );
  if (identical(updatedChildren, node.children)) {
    return node;
  }
  return _copyNodeWithChildren(node, updatedChildren);
}

List<TagflowDocumentNode> _removeNode(
  List<TagflowDocumentNode> nodes,
  String nodeId,
) {
  var changed = false;
  final updated = <TagflowDocumentNode>[];

  for (final node in nodes) {
    if (node.id == nodeId) {
      changed = true;
    } else {
      final updatedNode = _removeNodeFromDescendants(node, nodeId);
      updated.add(updatedNode);
      changed = changed || !identical(updatedNode, node);
    }
  }

  return changed ? List.unmodifiable(updated) : nodes;
}

TagflowDocumentNode _removeNodeFromDescendants(
  TagflowDocumentNode node,
  String nodeId,
) {
  if (node.children.isEmpty) {
    return node;
  }

  final updatedChildren = _removeNode(node.children, nodeId);
  if (identical(updatedChildren, node.children)) {
    return node;
  }
  return _copyNodeWithChildren(node, updatedChildren);
}

TagflowDocumentNode _copyNodeWithChildren(
  TagflowDocumentNode node,
  List<TagflowDocumentNode> children,
) {
  return switch (node.kind) {
    TagflowNodeKind.root => TagflowDocumentNode.root(
      id: node.id,
      children: children,
      presentation: node.presentation,
      metadata: node.metadata,
      source: node.source,
    ),
    TagflowNodeKind.container => TagflowDocumentNode.container(
      id: node.id,
      children: children,
      presentation: node.presentation,
      metadata: node.metadata,
      source: node.source,
    ),
    TagflowNodeKind.paragraph => TagflowDocumentNode.paragraph(
      id: node.id,
      children: children,
      presentation: node.presentation,
      metadata: node.metadata,
      source: node.source,
    ),
    TagflowNodeKind.heading => TagflowDocumentNode.heading(
      id: node.id,
      level: node.level ?? 1,
      children: children,
      presentation: node.presentation,
      metadata: node.metadata,
      source: node.source,
    ),
    TagflowNodeKind.link => TagflowDocumentNode.link(
      id: node.id,
      url: node.url ?? Uri(),
      children: children,
      presentation: node.presentation,
      metadata: node.metadata,
      source: node.source,
    ),
    TagflowNodeKind.list => TagflowDocumentNode.list(
      id: node.id,
      ordered: node.ordered ?? false,
      startIndex: node.startIndex,
      children: children,
      presentation: node.presentation,
      metadata: node.metadata,
      source: node.source,
    ),
    TagflowNodeKind.listItem => TagflowDocumentNode.listItem(
      id: node.id,
      children: children,
      presentation: node.presentation,
      metadata: node.metadata,
      source: node.source,
    ),
    TagflowNodeKind.blockquote => TagflowDocumentNode.blockquote(
      id: node.id,
      children: children,
      presentation: node.presentation,
      metadata: node.metadata,
      source: node.source,
    ),
    TagflowNodeKind.table => TagflowDocumentNode.table(
      id: node.id,
      children: children,
      presentation: node.presentation,
      metadata: node.metadata,
      source: node.source,
    ),
    TagflowNodeKind.tableRow => TagflowDocumentNode.tableRow(
      id: node.id,
      children: children,
      presentation: node.presentation,
      metadata: node.metadata,
      source: node.source,
    ),
    TagflowNodeKind.tableCell => TagflowDocumentNode.tableCell(
      id: node.id,
      children: children,
      rowSpan: node.rowSpan,
      colSpan: node.colSpan,
      header: node.header,
      presentation: node.presentation,
      metadata: node.metadata,
      source: node.source,
    ),
    TagflowNodeKind.unsupported => TagflowDocumentNode.unsupported(
      id: node.id,
      unsupportedReason: node.unsupportedReason,
      children: children,
      presentation: node.presentation,
      metadata: node.metadata,
      source: node.source,
    ),
    TagflowNodeKind.text ||
    TagflowNodeKind.codeBlock ||
    TagflowNodeKind.inlineCode ||
    TagflowNodeKind.image ||
    TagflowNodeKind.horizontalRule => throw ArgumentError.value(
      node.id,
      'parentNodeId',
      'Node kind ${node.kind.name} does not support children.',
    ),
  };
}
