import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/tagflow.dart';
import 'package:tagflow_example/benchmarks/fixtures.dart';
import 'package:tagflow_example/benchmarks/semantic_patch_stream.dart';

void main() {
  group('SemanticPatchStream', () {
    test('builds patch steps from one adapted semantic document', () {
      final html = File(
        '../../packages/tagflow_benchmarks/fixtures/html/ai_answer_rich.html',
      ).readAsStringSync();
      final sourceDocument = const TagflowHtmlAdapter().parse(html);
      final stream = SemanticPatchStream.fromHtml(html);

      expect(stream.steps, hasLength(streamingChunkFractions.length));
      expect(stream.initialDocument.children, hasLength(1));
      expect(
        stream.initialDocument.children.single.id,
        sourceDocument.children.single.id,
      );
      expect(stream.initialDocument.children.single.children, isEmpty);

      var currentDocument = stream.initialDocument;
      var appendedNodeCount = 0;
      var previousInputLength = 0;
      for (final step in stream.steps) {
        expect(step.inputLength, greaterThan(previousInputLength));
        previousInputLength = step.inputLength;
        appendedNodeCount += step.appendedNodeCount;

        currentDocument = currentDocument.applyPatch(step.patch);

        expect(
          currentDocument.children.single.children,
          hasLength(appendedNodeCount),
        );
      }

      expect(
        currentDocument.children.single.id,
        sourceDocument.children.single.id,
      );
      expect(
        currentDocument.children.single.kind,
        sourceDocument.children.single.kind,
      );
      expect(
        currentDocument.children.single.children.map((node) => node.id),
        sourceDocument.children.single.children.map((node) => node.id),
      );
    });

    test(
      'builds authored insertion patch steps from stable semantic snapshots',
      () {
        final fixture = profileBenchmarkFixtureById(
          authoredInsertionSemanticPatchBenchmarkFixtureId,
        );
        final stream = SemanticPatchStream.fromFixture(
          fixture,
          authoredInsertionStreamingHtmlSnapshots.last,
        );

        expect(stream.steps, hasLength(4));
        expect(stream.initialDocument.children, hasLength(1));
        expect(stream.initialDocument.children.single.id, 'answer');
        expect(stream.initialDocument.children.single.children, isEmpty);

        var currentDocument = stream.initialDocument;
        final expectedChildIdsByStep = <List<String>>[
          ['summary', 'details'],
          ['callout', 'summary', 'details'],
          ['context', 'callout', 'summary', 'details'],
          ['lead', 'context', 'callout', 'summary', 'details'],
        ];
        final expectedInsertedNodeCounts = [2, 1, 1, 1];

        for (final indexedStep in stream.steps.indexed) {
          final step = indexedStep.$2;
          final previousChildren = currentDocument.children.single.children;
          final previousChildrenById = {
            for (final child in previousChildren) child.id: child,
          };

          expect(
            step.appendedNodeCount,
            expectedInsertedNodeCounts[indexedStep.$1],
          );
          currentDocument = currentDocument.applyPatch(step.patch);

          expect(
            currentDocument.children.single.children.map((node) => node.id),
            orderedEquals(expectedChildIdsByStep[indexedStep.$1]),
          );
          for (final entry in previousChildrenById.entries) {
            expect(currentDocument.nodeById(entry.key), same(entry.value));
          }
        }

        expect(
          _descendantText(
            currentDocument.nodeById('lead') ?? (throw StateError('lead')),
          ),
          'Lead',
        );
        expect(
          _descendantText(
            currentDocument.nodeById('context') ??
                (throw StateError('context')),
          ),
          'Context',
        );
        expect(
          _descendantText(
            currentDocument.nodeById('callout') ??
                (throw StateError('callout')),
          ),
          'Callout',
        );
        expect(
          _descendantText(
            currentDocument.nodeById('summary') ??
                (throw StateError('summary')),
          ),
          'Summary',
        );
        expect(
          _descendantText(
            currentDocument.nodeById('details') ??
                (throw StateError('details')),
          ),
          'Details',
        );
      },
    );
  });
}

String _descendantText(TagflowDocumentNode node) {
  if (node.kind == TagflowNodeKind.text) {
    return node.text ?? '';
  }

  return node.children.map(_descendantText).join(' ').trim();
}
