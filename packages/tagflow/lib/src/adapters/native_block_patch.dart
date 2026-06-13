import 'package:meta/meta.dart';
import 'package:tagflow/src/adapters/native_block.dart';

/// Immutable native block update operation adapted into runtime document
/// patches.
@immutable
final class TagflowNativeBlockPatch {
  /// Creates an update that replaces the existing node with [nodeId].
  const TagflowNativeBlockPatch.replaceNode({
    required String nodeId,
    required this.block,
  }) : kind = TagflowNativeBlockPatchKind.replaceNode,
       targetNodeId = nodeId,
       blocks = const [];

  /// Creates an update that appends [children] to the existing parent node.
  TagflowNativeBlockPatch.appendChildren({
    required String parentNodeId,
    required List<TagflowNativeBlock> children,
  }) : kind = TagflowNativeBlockPatchKind.appendChildren,
       targetNodeId = parentNodeId,
       block = null,
       blocks = List.unmodifiable(children);

  /// Creates an update that inserts [nodes] before the existing sibling node.
  TagflowNativeBlockPatch.insertBefore({
    required String siblingNodeId,
    required List<TagflowNativeBlock> nodes,
  }) : kind = TagflowNativeBlockPatchKind.insertBefore,
       targetNodeId = siblingNodeId,
       block = null,
       blocks = List.unmodifiable(nodes);

  /// Creates an update that removes the existing node with [nodeId].
  const TagflowNativeBlockPatch.removeNode({required String nodeId})
    : kind = TagflowNativeBlockPatchKind.removeNode,
      targetNodeId = nodeId,
      block = null,
      blocks = const [];

  /// The semantic update kind.
  final TagflowNativeBlockPatchKind kind;

  /// Runtime node id targeted by the update.
  final String targetNodeId;

  /// Native block payload for replacement updates.
  final TagflowNativeBlock? block;

  /// Native block payload for append/insert updates.
  final List<TagflowNativeBlock> blocks;
}

/// Semantic native update kinds supported by the patch adapter slice.
enum TagflowNativeBlockPatchKind {
  replaceNode,
  appendChildren,
  insertBefore,
  removeNode,
}
