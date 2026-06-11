import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow_example/benchmarks/fixtures.dart';
import 'package:tagflow_example/benchmarks/renderer_registry.dart';

void main() {
  group('benchmarkRendererById', () {
    test('resolves the known benchmark renderers', () {
      expect(
        benchmarkRendererIds,
        containsAll(<String>[
          defaultBenchmarkRendererId,
          'tagflow_semantic',
          semanticPatchBenchmarkRendererId,
          'flutter_html',
          'flutter_widget_from_html',
          'flutter_markdown_plus',
          'markdown_widget',
        ]),
      );

      expect(
        benchmarkRendererById(defaultBenchmarkRendererId).label,
        'Tagflow (compat)',
      );
      expect(
        benchmarkRendererById('tagflow_semantic').label,
        'Tagflow (semantic)',
      );
      expect(
        benchmarkRendererById(semanticPatchBenchmarkRendererId).label,
        'Tagflow (semantic patch)',
      );
      expect(benchmarkRendererById('flutter_html').label, 'Flutter HTML');
      expect(
        benchmarkRendererById('flutter_widget_from_html').label,
        'Flutter Widget from HTML (core)',
      );
      expect(
        benchmarkRendererById('flutter_markdown_plus').label,
        'Flutter Markdown Plus',
      );
      expect(benchmarkRendererById('markdown_widget').label, 'Markdown Widget');
    });

    test('throws for an unknown renderer id', () {
      expect(() => benchmarkRendererById('missing'), throwsArgumentError);
    });
  });

  test('returns Tagflow and competitor renderers for HTML fixtures', () {
    final htmlRenderers = benchmarkRenderersForSourceType(
      BenchmarkSourceType.html,
    );

    expect(htmlRenderers.map((renderer) => renderer.id), [
      'tagflow',
      'tagflow_semantic',
      semanticPatchBenchmarkRendererId,
      'flutter_html',
      'flutter_widget_from_html',
    ]);
    expect(
      htmlRenderers.every(
        (renderer) => renderer.supports(BenchmarkSourceType.html),
      ),
      isTrue,
    );
  });

  test('returns ordinary HTML renderers for ordinary HTML fixtures', () {
    final fixture = profileBenchmarkFixtureById('ai_answer_rich');
    final htmlRenderers = benchmarkRenderersForFixture(fixture);

    expect(htmlRenderers.map((renderer) => renderer.id), [
      'tagflow',
      'tagflow_semantic',
      'flutter_html',
      'flutter_widget_from_html',
    ]);
  });

  test('returns only the patch renderer for the semantic patch fixture', () {
    final fixture = profileBenchmarkFixtureById(
      semanticPatchBenchmarkFixtureId,
    );
    final renderers = benchmarkRenderersForFixture(fixture);

    expect(renderers.map((renderer) => renderer.id), [
      semanticPatchBenchmarkRendererId,
    ]);
    expect(
      benchmarkRendererSupportsFixture(
        benchmarkRendererById(semanticPatchBenchmarkRendererId),
        fixture,
      ),
      isTrue,
    );
    expect(
      benchmarkRendererSupportsFixture(
        benchmarkRendererById(defaultBenchmarkRendererId),
        fixture,
      ),
      isFalse,
    );
  });

  test('returns markdown-only renderers for markdown fixtures', () {
    final markdownRenderers = benchmarkRenderersForSourceType(
      BenchmarkSourceType.markdown,
    );

    expect(markdownRenderers.map((renderer) => renderer.id), [
      'flutter_markdown_plus',
      'markdown_widget',
    ]);
    expect(
      markdownRenderers.every(
        (renderer) => renderer.supports(BenchmarkSourceType.markdown),
      ),
      isTrue,
    );
  });

  testWidgets('throws clearly for an incompatible source document', (
    tester,
  ) async {
    late BuildContext context;
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Builder(
          builder: (buildContext) {
            context = buildContext;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(
      () => benchmarkRendererById('tagflow').build(
        context,
        const BenchmarkSourceDocument(
          type: BenchmarkSourceType.markdown,
          data: '# markdown',
          assetPath:
              'packages/tagflow_benchmarks/fixtures/markdown/'
              'ai_answer_rich.md',
        ),
      ),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          contains('does not support markdown fixtures'),
        ),
      ),
    );
  });
}
