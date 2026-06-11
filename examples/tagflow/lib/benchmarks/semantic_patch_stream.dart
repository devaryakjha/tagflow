import 'dart:math' as math;

import 'package:tagflow/tagflow.dart';

/// Progressive update fractions shared by streaming profile benchmarks.
const List<double> streamingChunkFractions = [0.25, 0.5, 0.75, 1.0];

/// Patch target and updates for one semantic document streaming run.
final class SemanticPatchStream {
  const SemanticPatchStream._({
    required this.initialDocument,
    required this.steps,
  });

  /// Creates a patch stream by adapting [html] exactly once.
  factory SemanticPatchStream.fromHtml(String html) {
    final fullDocument = const TagflowHtmlAdapter().parse(html);
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
    TagflowNodeKind.horizontalRule => node,
  };
}
