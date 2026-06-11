import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow_example/benchmarks/fixtures.dart';

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

    test('throws for an unknown fixture id', () {
      expect(
        () => profileBenchmarkFixtureById('missing_fixture'),
        throwsArgumentError,
      );
    });
  });
}
