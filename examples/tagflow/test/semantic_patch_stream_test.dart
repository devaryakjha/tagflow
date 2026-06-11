import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/tagflow.dart';
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
  });
}
