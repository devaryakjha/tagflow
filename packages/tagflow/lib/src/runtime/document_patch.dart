import 'package:meta/meta.dart';
import 'package:tagflow/src/runtime/document.dart';
import 'package:tagflow/src/runtime/document_node.dart';

/// Immutable structural update operation for a [TagflowDocument].
@immutable
final class TagflowDocumentPatch {
  /// Creates a patch that replaces the existing node with [nodeId].
  const TagflowDocumentPatch.replaceNode({
    required String nodeId,
    required TagflowDocumentNode node,
  }) : _kind = _TagflowDocumentPatchKind.replaceNode,
       _targetNodeId = nodeId,
       _targetArgumentName = 'nodeId',
       _node = node,
       _children = const [];

  /// Creates a patch that appends [children] to the existing parent node.
  TagflowDocumentPatch.appendChildren({
    required String parentNodeId,
    required List<TagflowDocumentNode> children,
  }) : _kind = _TagflowDocumentPatchKind.appendChildren,
       _targetNodeId = parentNodeId,
       _targetArgumentName = 'parentNodeId',
       _node = null,
       _children = List.unmodifiable(children);

  /// Creates a patch that appends [children] to the top level of the
  /// document, after its existing top-level nodes.
  ///
  /// Top-level nodes have no parent node, so this is the only way to add a
  /// node to an empty document or after its last top-level node.
  TagflowDocumentPatch.appendRootChildren({
    required List<TagflowDocumentNode> children,
  }) : _kind = _TagflowDocumentPatchKind.appendRootChildren,
       _targetNodeId = null,
       _targetArgumentName = 'children',
       _node = null,
       _children = List.unmodifiable(children);

  /// Creates a patch that inserts [nodes] before the existing sibling node.
  TagflowDocumentPatch.insertBefore({
    required String siblingNodeId,
    required List<TagflowDocumentNode> nodes,
  }) : _kind = _TagflowDocumentPatchKind.insertBefore,
       _targetNodeId = siblingNodeId,
       _targetArgumentName = 'siblingNodeId',
       _node = null,
       _children = List.unmodifiable(nodes);

  /// Creates a patch that removes the existing node with [nodeId].
  const TagflowDocumentPatch.removeNode({required String nodeId})
    : _kind = _TagflowDocumentPatchKind.removeNode,
      _targetNodeId = nodeId,
      _targetArgumentName = 'nodeId',
      _node = null,
      _children = const [];

  final _TagflowDocumentPatchKind _kind;
  final String? _targetNodeId;
  final String _targetArgumentName;
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
  ///
  /// The first patch on a document indexes its node ids once. The index then
  /// moves to the returned document, so a chain of patches, such as a
  /// stream, costs time in proportion to the nodes each patch touches and the
  /// depth of its target rather than the size of the document. Nodes outside
  /// the patched path keep their instances.
  TagflowDocument applyPatch(TagflowDocumentPatch patch) {
    final index = _TagflowNodeIndex.of(this);
    final targetNodeId = patch._targetNodeId;
    if (targetNodeId != null && !index.contains(targetNodeId)) {
      throw ArgumentError.value(
        targetNodeId,
        patch._targetArgumentName,
        'No TagflowDocumentNode exists with this id.',
      );
    }

    final replacement = patch._kind == _TagflowDocumentPatchKind.replaceNode
        ? _validatedReplacement(patch)
        : null;
    final added = replacement == null ? patch._children : [replacement];
    final path = targetNodeId == null
        ? const <String>[]
        : index.pathTo(targetNodeId);

    // Find the removed subtree on the way down, then check the added ids
    // against the index before anything changes.
    TagflowDocumentNode? removed;
    final updatedChildren = switch (patch._kind) {
      _TagflowDocumentPatchKind.appendRootChildren =>
        List<TagflowDocumentNode>.unmodifiable([...children, ...added]),
      _TagflowDocumentPatchKind.replaceNode => _rebuildAlong(children, path, (
        siblings,
        i,
      ) {
        removed = siblings[i];
        return [...siblings]..[i] = replacement!;
      }),
      _TagflowDocumentPatchKind.appendChildren => _rebuildAlong(
        children,
        path,
        (siblings, i) {
          final parent = siblings[i];
          return [...siblings]
            ..[i] = parent.copyWith(children: [...parent.children, ...added]);
        },
      ),
      _TagflowDocumentPatchKind.insertBefore => _rebuildAlong(
        children,
        path,
        (siblings, i) => [...siblings]..insertAll(i, added),
      ),
      _TagflowDocumentPatchKind.removeNode => _rebuildAlong(children, path, (
        siblings,
        i,
      ) {
        removed = siblings[i];
        return [...siblings]..removeAt(i);
      }),
    };

    final parentOfAdded = switch (patch._kind) {
      _TagflowDocumentPatchKind.appendChildren => targetNodeId,
      _TagflowDocumentPatchKind.appendRootChildren => null,
      _ => path.length > 1 ? path[path.length - 2] : null,
    };
    index.update(added: added, parentId: parentOfAdded, removed: removed);

    final updated = _copyDocumentWithChildren(this, updatedChildren);
    index.moveTo(this, updated);
    return updated;
  }

  /// Applies [patches] in order and returns the final document.
  ///
  /// Each patch has the same validation behavior as [applyPatch], and the id
  /// index is built at most once for the whole batch.
  TagflowDocument applyPatches(Iterable<TagflowDocumentPatch> patches) {
    var document = this;
    for (final patch in patches) {
      document = document.applyPatch(patch);
    }
    return document;
  }
}

/// Node ids of one document, each mapped to its parent id (`null` at the
/// top level).
///
/// Building it validates that ids are unique. It belongs to one document at
/// a time: [moveTo] hands it to the patched document, and the old document
/// builds a new index if it is patched again.
final class _TagflowNodeIndex {
  _TagflowNodeIndex._(this._parents);

  factory _TagflowNodeIndex.of(TagflowDocument document) {
    return _indexes[document] ??= _TagflowNodeIndex._build(document.children);
  }

  factory _TagflowNodeIndex._build(List<TagflowDocumentNode> roots) {
    final parents = <String, String?>{};
    for (final root in roots) {
      _collect(root, null, parents, existing: const {});
    }
    return _TagflowNodeIndex._(parents);
  }

  static final _indexes = Expando<_TagflowNodeIndex>('TagflowNodeIndex');

  final Map<String, String?> _parents;

  bool contains(String id) => _parents.containsKey(id);

  /// Ids from the top level down to [id], inclusive.
  List<String> pathTo(String id) {
    final path = <String>[];
    String? current = id;
    while (current != null) {
      path.add(current);
      current = _parents[current];
    }
    return path.reversed.toList(growable: false);
  }

  /// Removes the ids under [removed] and adds the ids under [added], whose
  /// top nodes sit under [parentId].
  ///
  /// Throws [StateError] without changing the index when an added id
  /// already exists outside [removed] or repeats within [added].
  void update({
    required List<TagflowDocumentNode> added,
    required String? parentId,
    required TagflowDocumentNode? removed,
  }) {
    final removedIds = <String>{};
    if (removed != null) _collectIds(removed, removedIds);
    final addedParents = <String, String?>{};
    for (final node in added) {
      _collect(
        node,
        parentId,
        addedParents,
        existing: _parents,
        except: removedIds,
      );
    }
    removedIds.forEach(_parents.remove);
    _parents.addAll(addedParents);
  }

  void moveTo(TagflowDocument from, TagflowDocument to) {
    _indexes[from] = null;
    _indexes[to] = this;
  }

  static void _collect(
    TagflowDocumentNode node,
    String? parentId,
    Map<String, String?> into, {
    required Map<String, String?> existing,
    Set<String> except = const {},
  }) {
    final id = node.id;
    if (into.containsKey(id) ||
        (existing.containsKey(id) && !except.contains(id))) {
      throw StateError('Duplicate TagflowDocumentNode id: $id.');
    }
    into[id] = parentId;
    for (final child in node.children) {
      _collect(child, id, into, existing: existing, except: except);
    }
  }

  static void _collectIds(TagflowDocumentNode node, Set<String> into) {
    into.add(node.id);
    for (final child in node.children) {
      _collectIds(child, into);
    }
  }
}

/// Rebuilds [nodes] along [path], applying [edit] to the list that holds
/// the last id of [path]. Nodes off the path keep their instances.
List<TagflowDocumentNode> _rebuildAlong(
  List<TagflowDocumentNode> nodes,
  List<String> path,
  List<TagflowDocumentNode> Function(
    List<TagflowDocumentNode> siblings,
    int index,
  )
  edit, [
  int depth = 0,
]) {
  final id = path[depth];
  final index = nodes.indexWhere((node) => node.id == id);
  if (depth == path.length - 1) {
    return List.unmodifiable(edit(nodes, index));
  }
  final node = nodes[index];
  final children = _rebuildAlong(node.children, path, edit, depth + 1);
  return List.unmodifiable(
    [...nodes]..[index] = node.copyWith(children: children),
  );
}

enum _TagflowDocumentPatchKind {
  replaceNode,
  appendChildren,
  appendRootChildren,
  insertBefore,
  removeNode,
}

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
