import 'dart:math' as math;

import 'package:tagflow/tagflow.dart';
import 'package:tagflow_example/benchmarks/fixtures.dart';

/// Progressive update fractions shared by streaming profile benchmarks.
const List<double> streamingChunkFractions = [0.25, 0.5, 0.75, 1.0];

const _semanticBenchmarkHtmlAdapter = TagflowHtmlAdapter(
  nodeIdStrategy: TagflowHtmlNodeIdStrategy.attribute(),
);

/// Patch target and updates for one semantic document streaming run.
final class SemanticPatchStream {
  const SemanticPatchStream._({
    required this.initialDocument,
    required this.steps,
  });

  /// Creates a patch stream by adapting [html] exactly once.
  factory SemanticPatchStream.fromHtml(String html) {
    final fullDocument = _semanticBenchmarkHtmlAdapter.parse(html);
    final streamSource = _streamSourceFor(fullDocument);
    final initialDocument = TagflowDocument(
      id: '${fullDocument.id}:patch-stream',
      children: [_copyNodeWithChildren(streamSource.parent, const [])],
      metadata: fullDocument.metadata,
      source: fullDocument.source,
      version: fullDocument.version,
    );

    var appendedChildCount = 0;
    final steps = <SemanticPatchStreamStep>[];
    for (final indexedFraction in streamingChunkFractions.indexed) {
      final fraction = indexedFraction.$2;
      final targetChildCount = _targetChildCount(
        streamSource.children.length,
        fraction,
      );
      final children = streamSource.children.sublist(
        appendedChildCount,
        targetChildCount,
      );
      appendedChildCount = targetChildCount;

      steps.add(
        SemanticPatchStreamStep(
          chunk: indexedFraction.$1 + 1,
          fraction: fraction,
          inputLength: _chunkDocument(html, fraction).length,
          patch: TagflowDocumentPatch.appendChildren(
            parentNodeId: streamSource.parent.id,
            children: children,
          ),
          appendedNodeCount: children.length,
        ),
      );
    }

    return SemanticPatchStream._(
      initialDocument: initialDocument,
      steps: List.unmodifiable(steps),
    );
  }

  /// Creates a patch stream for one benchmark fixture.
  factory SemanticPatchStream.fromFixture(
    ProfileBenchmarkFixture fixture,
    String html,
  ) {
    if (fixture.id == authoredInsertionSemanticPatchBenchmarkFixtureId) {
      return SemanticPatchStream._fromSnapshots(
        benchmarkStreamingSnapshots(fixture.id, html),
      );
    }

    return SemanticPatchStream.fromHtml(html);
  }

  factory SemanticPatchStream._fromSnapshots(
    List<BenchmarkStreamingSnapshot> snapshots,
  ) {
    final documents = [
      for (final snapshot in snapshots)
        _semanticBenchmarkHtmlAdapter.parse(snapshot.html),
    ];
    final firstSource = _streamSourceFor(documents.first);
    final initialDocument = TagflowDocument(
      id: '${documents.first.id}:patch-stream',
      children: [_copyNodeWithChildren(firstSource.parent, const [])],
      metadata: documents.first.metadata,
      source: documents.first.source,
      version: documents.first.version,
    );

    var previousChildren = const <TagflowDocumentNode>[];
    final steps = <SemanticPatchStreamStep>[];
    for (final indexedDocument in documents.indexed) {
      final snapshot = snapshots[indexedDocument.$1];
      final streamSource = _streamSourceFor(indexedDocument.$2);
      final currentChildren = _normalizedStreamChildren(streamSource.children);
      final currentChildIds = {for (final child in currentChildren) child.id};
      final previousChildIds = {for (final child in previousChildren) child.id};
      final insertedNodeCount = currentChildIds
          .difference(previousChildIds)
          .length;

      steps.add(
        SemanticPatchStreamStep(
          chunk: snapshot.chunk,
          fraction: snapshot.fraction,
          inputLength: snapshot.inputLength,
          patch: _orderedAuthoredInsertionPatch(
            parentNodeId: streamSource.parent.id,
            previousChildren: previousChildren,
            currentChildren: currentChildren,
          ),
          appendedNodeCount: insertedNodeCount,
        ),
      );

      previousChildren = currentChildren;
    }

    return SemanticPatchStream._(
      initialDocument: initialDocument,
      steps: List.unmodifiable(steps),
    );
  }

  /// Initial semantic document before stream updates apply.
  final TagflowDocument initialDocument;

  /// Ordered patch stream steps.
  final List<SemanticPatchStreamStep> steps;
}

/// One semantic stream update step.
final class SemanticPatchStreamStep {
  const SemanticPatchStreamStep({
    required this.chunk,
    required this.fraction,
    required this.inputLength,
    required this.patch,
    required this.appendedNodeCount,
  });

  /// 1-based update index.
  final int chunk;

  /// Fraction of the source stream represented by this update.
  final double fraction;

  /// HTML input length comparable with the full-reparse streaming lane.
  final int inputLength;

  /// Document patch applied for this update.
  final TagflowDocumentPatch patch;

  /// Number of top-level semantic children appended by this step.
  final int appendedNodeCount;
}

TagflowDocumentPatch _orderedAuthoredInsertionPatch({
  required String parentNodeId,
  required List<TagflowDocumentNode> previousChildren,
  required List<TagflowDocumentNode> currentChildren,
}) {
  if (previousChildren.isEmpty) {
    return TagflowDocumentPatch.appendChildren(
      parentNodeId: parentNodeId,
      children: currentChildren,
    );
  }

  final previousChildIds = {for (final child in previousChildren) child.id};
  final firstExistingChildIndex = currentChildren.indexWhere(
    (child) => previousChildIds.contains(child.id),
  );
  if (firstExistingChildIndex <= 0) {
    throw StateError(
      'Authored insertion benchmark snapshots must prepend new siblings '
      'ahead of an existing authored sibling.',
    );
  }

  final insertedChildren = currentChildren.sublist(0, firstExistingChildIndex);
  final trailingExistingChildren = currentChildren.sublist(
    firstExistingChildIndex,
  );
  final trailingExistingIds = [
    for (final child in trailingExistingChildren) child.id,
  ];
  final previousOrderedIds = [for (final child in previousChildren) child.id];
  if (!_hasSameOrderedIds(trailingExistingIds, previousOrderedIds)) {
    throw StateError(
      'Authored insertion benchmark snapshots must preserve existing sibling '
      'order after inserting new authored blocks.',
    );
  }

  return TagflowDocumentPatch.insertBefore(
    siblingNodeId: trailingExistingChildren.first.id,
    nodes: insertedChildren,
  );
}

List<TagflowDocumentNode> _normalizedStreamChildren(
  List<TagflowDocumentNode> children,
) {
  return List<TagflowDocumentNode>.unmodifiable([
    for (final child in children) _normalizedStreamNode(child, child.id),
  ]);
}

TagflowDocumentNode _normalizedStreamNode(
  TagflowDocumentNode node,
  String stableRootId, [
  List<int> relativePath = const [],
]) {
  final normalizedChildren = [
    for (final indexedChild in node.children.indexed)
      _normalizedStreamNode(indexedChild.$2, stableRootId, [
        ...relativePath,
        indexedChild.$1,
      ]),
  ];
  final normalizedId = switch (relativePath) {
    [] => node.id,
    _ => '$stableRootId.${relativePath.join('.')}',
  };

  return _copyNode(node, id: normalizedId, children: normalizedChildren);
}

final class _PatchStreamSource {
  const _PatchStreamSource({required this.parent, required this.children});

  final TagflowDocumentNode parent;
  final List<TagflowDocumentNode> children;
}

_PatchStreamSource _streamSourceFor(TagflowDocument document) {
  if (document.children.length == 1 &&
      document.children.single.children.isNotEmpty) {
    final parent = document.children.single;
    return _PatchStreamSource(parent: parent, children: parent.children);
  }

  final parent = TagflowDocumentNode.root(
    id: '${document.id}:stream-root',
    source: document.source,
  );
  return _PatchStreamSource(parent: parent, children: document.children);
}

int _targetChildCount(int childCount, double fraction) {
  if (childCount == 0 || fraction >= 1) {
    return childCount;
  }

  return math.max(1, (childCount * fraction).ceil()).clamp(0, childCount);
}

String _chunkDocument(String document, double fraction) {
  if (fraction >= 1) {
    return document;
  }

  final targetLength = (document.length * fraction).round();
  final nextBoundary = document.indexOf('>', targetLength);
  if (nextBoundary == -1) {
    return document;
  }

  return '${document.substring(0, nextBoundary + 1)}</article>';
}

TagflowDocumentNode _copyNodeWithChildren(
  TagflowDocumentNode node,
  List<TagflowDocumentNode> children,
) {
  return _copyNode(node, id: node.id, children: children);
}

bool _hasSameOrderedIds(List<String> left, List<String> right) {
  if (left.length != right.length) {
    return false;
  }

  for (var index = 0; index < left.length; index++) {
    if (left[index] != right[index]) {
      return false;
    }
  }

  return true;
}

TagflowDocumentNode _copyNode(
  TagflowDocumentNode node, {
  required String id,
  required List<TagflowDocumentNode> children,
}) {
  return switch (node.kind) {
    TagflowNodeKind.root => TagflowDocumentNode.root(
      id: id,
      children: children,
      presentation: node.presentation,
      metadata: node.metadata,
      source: node.source,
    ),
    TagflowNodeKind.container => TagflowDocumentNode.container(
      id: id,
      children: children,
      presentation: node.presentation,
      metadata: node.metadata,
      source: node.source,
    ),
    TagflowNodeKind.paragraph => TagflowDocumentNode.paragraph(
      id: id,
      children: children,
      presentation: node.presentation,
      metadata: node.metadata,
      source: node.source,
    ),
    TagflowNodeKind.heading => TagflowDocumentNode.heading(
      id: id,
      level: node.level ?? 1,
      children: children,
      presentation: node.presentation,
      metadata: node.metadata,
      source: node.source,
    ),
    TagflowNodeKind.link => TagflowDocumentNode.link(
      id: id,
      url: node.url ?? Uri(),
      children: children,
      presentation: node.presentation,
      metadata: node.metadata,
      source: node.source,
    ),
    TagflowNodeKind.list => TagflowDocumentNode.list(
      id: id,
      ordered: node.ordered ?? false,
      startIndex: node.startIndex,
      children: children,
      presentation: node.presentation,
      metadata: node.metadata,
      source: node.source,
    ),
    TagflowNodeKind.listItem => TagflowDocumentNode.listItem(
      id: id,
      children: children,
      presentation: node.presentation,
      metadata: node.metadata,
      source: node.source,
    ),
    TagflowNodeKind.blockquote => TagflowDocumentNode.blockquote(
      id: id,
      children: children,
      presentation: node.presentation,
      metadata: node.metadata,
      source: node.source,
    ),
    TagflowNodeKind.table => TagflowDocumentNode.table(
      id: id,
      children: children,
      presentation: node.presentation,
      metadata: node.metadata,
      source: node.source,
    ),
    TagflowNodeKind.tableRow => TagflowDocumentNode.tableRow(
      id: id,
      children: children,
      presentation: node.presentation,
      metadata: node.metadata,
      source: node.source,
    ),
    TagflowNodeKind.tableCell => TagflowDocumentNode.tableCell(
      id: id,
      children: children,
      rowSpan: node.rowSpan,
      colSpan: node.colSpan,
      header: node.header,
      presentation: node.presentation,
      metadata: node.metadata,
      source: node.source,
    ),
    TagflowNodeKind.unsupported => TagflowDocumentNode.unsupported(
      id: id,
      unsupportedReason: node.unsupportedReason,
      children: children,
      presentation: node.presentation,
      metadata: node.metadata,
      source: node.source,
    ),
    TagflowNodeKind.text => TagflowDocumentNode.text(
      id: id,
      text: node.text ?? '',
      presentation: node.presentation,
      metadata: node.metadata,
      source: node.source,
    ),
    TagflowNodeKind.codeBlock => TagflowDocumentNode.codeBlock(
      id: id,
      text: node.text ?? '',
      language: node.language,
      presentation: node.presentation,
      metadata: node.metadata,
      source: node.source,
    ),
    TagflowNodeKind.inlineCode => TagflowDocumentNode.inlineCode(
      id: id,
      text: node.text ?? '',
      presentation: node.presentation,
      metadata: node.metadata,
      source: node.source,
    ),
    TagflowNodeKind.image => TagflowDocumentNode.image(
      id: id,
      url: node.url ?? Uri(),
      alt: node.alt,
      width: node.width,
      height: node.height,
      presentation: node.presentation,
      metadata: node.metadata,
      source: node.source,
    ),
    TagflowNodeKind.horizontalRule => TagflowDocumentNode.horizontalRule(
      id: id,
      presentation: node.presentation,
      metadata: node.metadata,
      source: node.source,
    ),
  };
}
