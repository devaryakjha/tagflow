import 'package:flutter/material.dart';
import 'package:tagflow/tagflow.dart';
import 'package:tagflow_example/widgets/gallery_scaffold.dart';

TagflowDocumentNode _paragraph(String id, String text) {
  return TagflowDocumentNode.paragraph(
    id: id,
    children: [TagflowDocumentNode.text(id: '$id.text', text: text)],
  );
}

TagflowDocumentNode _task(String id, String text) {
  return TagflowDocumentNode.container(
    id: id,
    children: [_paragraph('$id.body', text)],
  );
}

TagflowDocument _initialDocument() {
  return TagflowDocument(
    id: 'release-checklist',
    children: [
      TagflowDocumentNode.heading(
        id: 'title',
        level: 2,
        children: [
          TagflowDocumentNode.text(id: 'title.text', text: 'Release checklist'),
        ],
      ),
      _paragraph('status', 'Revision 1'),
      _task('task-1', 'Run the validate script'),
      _task('task-2', 'Update the changelog'),
      _task('task-3', 'Push the release tag'),
    ],
  );
}

/// Renders every container as a task card with a checkbox.
///
/// The checkbox state lives in the widget, so it survives a patch only
/// because Tagflow keys each node by its id.
final _registry = TagflowComponentRegistry(
  overrides: {
    TagflowNodeKind.container: (context, node) => _TaskCard(
      key: ValueKey('task-card-${node.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: context.renderChildren(node),
      ),
    ),
  },
);

class DocumentPatchExample extends StatefulWidget {
  const DocumentPatchExample({super.key});

  @override
  State<DocumentPatchExample> createState() => _DocumentPatchExampleState();
}

class _DocumentPatchExampleState extends State<DocumentPatchExample> {
  TagflowDocument _document = _initialDocument();
  final List<String> _log = [];
  int _revision = 1;
  int _nextTask = 4;

  void _apply(String label, TagflowDocumentPatch patch) {
    setState(() {
      _document = _document.applyPatch(patch);
      _log.insert(0, label);
    });
  }

  void _append() {
    final id = 'task-${_nextTask++}';
    _apply(
      'appendRootChildren($id)',
      TagflowDocumentPatch.appendRootChildren(
        children: [_task(id, 'Follow-up task $id')],
      ),
    );
  }

  void _insertBefore() {
    final first = _document.children.firstWhere(
      (node) => node.kind == TagflowNodeKind.container,
    );
    final id = 'task-${_nextTask++}';
    _apply(
      'insertBefore(${first.id})',
      TagflowDocumentPatch.insertBefore(
        siblingNodeId: first.id,
        nodes: [_task(id, 'Urgent task $id')],
      ),
    );
  }

  void _replaceStatus() {
    _revision++;
    _apply(
      'replaceNode(status)',
      TagflowDocumentPatch.replaceNode(
        nodeId: 'status',
        node: _paragraph('status', 'Revision $_revision'),
      ),
    );
  }

  void _removeLast() {
    final last = _document.children.lastWhere(
      (node) => node.kind == TagflowNodeKind.container,
    );
    _apply(
      'removeNode(${last.id})',
      TagflowDocumentPatch.removeNode(nodeId: last.id),
    );
  }

  void _reset() {
    setState(() {
      _document = _initialDocument();
      _log.clear();
      _revision = 1;
      _nextTask = 4;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasTasks = _document.children.any(
      (node) => node.kind == TagflowNodeKind.container,
    );
    return GalleryScaffold(
      title: 'Document patches',
      description:
          'Tick a task, then apply patches. Each patch returns a new '
          'document, and unchanged nodes keep their widget state because '
          'rendering keys them by id.',
      actions: [
        FilledButton.tonal(
          key: const ValueKey('patch-append'),
          onPressed: _append,
          child: const Text('Append'),
        ),
        FilledButton.tonal(
          key: const ValueKey('patch-insert'),
          onPressed: hasTasks ? _insertBefore : null,
          child: const Text('Insert first'),
        ),
        FilledButton.tonal(
          key: const ValueKey('patch-replace'),
          onPressed: _replaceStatus,
          child: const Text('Replace status'),
        ),
        FilledButton.tonal(
          key: const ValueKey('patch-remove'),
          onPressed: hasTasks ? _removeLast : null,
          child: const Text('Remove last'),
        ),
        TextButton(
          key: const ValueKey('patch-reset'),
          onPressed: _reset,
          child: const Text('Reset'),
        ),
      ],
      children: [
        Tagflow.document(_document, registry: _registry),
        const Divider(height: 32),
        Text('Patch log', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        if (_log.isEmpty)
          const Text('No patches applied yet.')
        else
          for (final entry in _log)
            Text(
              entry,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
      ],
    );
  }
}

class _TaskCard extends StatefulWidget {
  const _TaskCard({required this.child, super.key});

  final Widget child;

  @override
  State<_TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<_TaskCard> {
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Checkbox(
            value: _done,
            onChanged: (value) => setState(() => _done = value ?? false),
          ),
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}
