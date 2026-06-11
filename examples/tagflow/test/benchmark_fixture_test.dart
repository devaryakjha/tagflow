import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/tagflow.dart';
import 'package:tagflow_example/benchmarks/fixtures.dart';
import 'package:tagflow_example/benchmarks/renderer_registry.dart';

void main() {
  group('profileBenchmarkFixtureById', () {
    test('resolves HTML and markdown fixture ids', () {
      final htmlFixture = profileBenchmarkFixtureById('ai_answer_rich');
      final markdownFixture = profileBenchmarkFixtureById('ai_answer_rich_md');

      expect(htmlFixture.source.type, BenchmarkSourceType.html);
      expect(htmlFixture.source.assetPath, endsWith('ai_answer_rich.html'));

      expect(markdownFixture.source.type, BenchmarkSourceType.markdown);
      expect(markdownFixture.source.assetPath, endsWith('ai_answer_rich.md'));
    });

    test('resolves streaming fixture as an HTML chunk scenario', () {
      final fixture = profileBenchmarkFixtureById('streaming_ai_chunks');

      expect(fixture.source.type, BenchmarkSourceType.html);
      expect(fixture.source.assetPath, endsWith('ai_answer_rich.html'));
      expect(fixture.scenario, BenchmarkScenario.streamingChunks);
    });

    test('resolves semantic patch fixture as a restricted HTML scenario', () {
      final fixture = profileBenchmarkFixtureById(
        semanticPatchBenchmarkFixtureId,
      );

      expect(fixture.source.type, BenchmarkSourceType.html);
      expect(fixture.source.assetPath, endsWith('ai_answer_rich.html'));
      expect(fixture.scenario, BenchmarkScenario.semanticPatchStreaming);
      expect(
        fixture.supportsRendererId(semanticPatchBenchmarkRendererId),
        true,
      );
      expect(fixture.supportsRendererId('tagflow'), false);
    });

    test('resolves native JSON fixtures as restricted document scenarios', () {
      for (final fixtureId in [
        nativeJsonBenchmarkFixtureId,
        nativeJsonTableBenchmarkFixtureId,
        nativeJsonLargeArticleBenchmarkFixtureId,
      ]) {
        final fixture = profileBenchmarkFixtureById(fixtureId);

        expect(fixture.source.type, BenchmarkSourceType.nativeJson);
        expect(fixture.source.assetPath, endsWith('$fixtureId.json'));
        expect(fixture.supportsRendererId(nativeJsonBenchmarkRendererId), true);
        expect(fixture.supportsRendererId(defaultBenchmarkRendererId), false);
      }
    });

    test('includes native JSON fixtures in the profile fixture list', () {
      expect(
        profileBenchmarkFixtureIds,
        containsAll(<String>[
          nativeJsonBenchmarkFixtureId,
          nativeJsonTableBenchmarkFixtureId,
          nativeJsonLargeArticleBenchmarkFixtureId,
        ]),
      );
    });

    test('resolves authored insertion fixture as a semantic HTML scenario', () {
      final fixture = profileBenchmarkFixtureById(
        authoredInsertionBenchmarkFixtureId,
      );

      expect(fixture.source.type, BenchmarkSourceType.html);
      expect(
        fixture.source.assetPath,
        endsWith('streaming_ai_authored_insertions.html'),
      );
      expect(fixture.scenario, BenchmarkScenario.streamingChunks);
      expect(fixture.supportsRendererId('tagflow_semantic'), true);
      expect(fixture.supportsRendererId(defaultBenchmarkRendererId), false);
    });

    test(
      'resolves authored insertion patch fixture as a restricted pair lane',
      () {
        final fixture = profileBenchmarkFixtureById(
          authoredInsertionSemanticPatchBenchmarkFixtureId,
        );

        expect(fixture.source.type, BenchmarkSourceType.html);
        expect(
          fixture.source.assetPath,
          endsWith('streaming_ai_authored_insertions.html'),
        );
        expect(fixture.scenario, BenchmarkScenario.semanticPatchStreaming);
        expect(
          fixture.supportsRendererId(semanticPatchBenchmarkRendererId),
          true,
        );
        expect(fixture.supportsRendererId('tagflow_semantic'), false);
      },
    );

    test('authored insertion snapshots keep stable data-tagflow-id values', () {
      final fixture = profileBenchmarkFixtureById(
        authoredInsertionBenchmarkFixtureId,
      );
      final snapshots = benchmarkStreamingSnapshots(
        fixture.id,
        authoredInsertionStreamingHtmlSnapshots.last,
      );
      const adapter = TagflowHtmlAdapter(
        nodeIdStrategy: TagflowHtmlNodeIdStrategy.attribute(),
      );

      final stableTailIds = <String>['summary', 'details'];
      for (final snapshot in snapshots) {
        final document = adapter.parse(snapshot.html);
        final childIds = document.children.single.children
            .map((node) => node.id)
            .toList();

        expect(
          childIds.skip(childIds.length - stableTailIds.length),
          orderedEquals(stableTailIds),
        );
      }

      final finalDocument = adapter.parse(snapshots.last.html);
      expect(
        finalDocument.children.map((node) => node.id),
        orderedEquals(<String>['answer']),
      );
      expect(
        finalDocument.children.single.children.map((node) => node.id),
        orderedEquals(<String>[
          'lead',
          'context',
          'callout',
          'summary',
          'details',
        ]),
      );
    });

    test('throws for an unknown fixture id', () {
      expect(
        () => profileBenchmarkFixtureById('missing_fixture'),
        throwsArgumentError,
      );
    });
  });
}
