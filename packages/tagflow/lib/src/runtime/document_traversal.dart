import 'package:tagflow/src/runtime/document_node.dart';

/// Returns the first node in [nodes] with [nodeId], or `null` if none exist.
TagflowDocumentNode? findNodeByIdInChildren(
  Iterable<TagflowDocumentNode> nodes,
  String nodeId,
) {
  for (final node in nodes) {
    if (node.id == nodeId) {
      return node;
    }

    final match = findNodeByIdInChildren(node.children, nodeId);
    if (match != null) {
      return match;
    }
  }

  return null;
}

/// Returns whether any node in [nodes] has [nodeId].
bool containsNodeIdInChildren(
  Iterable<TagflowDocumentNode> nodes,
  String nodeId,
) {
  return findNodeByIdInChildren(nodes, nodeId) != null;
}

/// Validates that [nodes] do not contain duplicate IDs.
///
/// Throws [StateError] when a duplicate ID is found anywhere in the tree.
void validateUniqueNodeIdsInChildren(Iterable<TagflowDocumentNode> nodes) {
  final seen = <String>{};

  void visit(TagflowDocumentNode node) {
    if (!seen.add(node.id)) {
      throw StateError('Duplicate TagflowDocumentNode id: ${node.id}.');
    }

    for (final child in node.children) {
      visit(child);
    }
  }

  for (final node in nodes) {
    visit(node);
  }
}
