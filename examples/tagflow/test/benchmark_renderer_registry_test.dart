import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/tagflow.dart';
import 'package:tagflow_example/benchmarks/fixtures.dart';
import 'package:tagflow_example/benchmarks/renderer_registry.dart';
import 'package:tagflow_example/benchmarks/semantic_patch_stream.dart';

void main() {
  group('benchmarkRendererById', () {
    test('resolves the known benchmark renderers', () {
      expect(
        benchmarkRendererIds,
        containsAll(<String>[
          defaultBenchmarkRendererId,
          'tagflow_semantic',
          semanticPatchBenchmarkRendererId,
          nativeJsonBenchmarkRendererId,
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
      expect(
        benchmarkRendererById(nativeJsonBenchmarkRendererId).label,
        'Tagflow (native JSON)',
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

  test(
    'returns compat and semantic HTML renderers for the equivalent fixture',
    () {
      final fixture = profileBenchmarkFixtureById(
        'answer_detail_equivalent_v1',
      );
      final htmlRenderers = benchmarkRenderersForFixture(fixture);

      expect(htmlRenderers.map((renderer) => renderer.id), [
        'tagflow',
        'tagflow_semantic',
        'flutter_html',
        'flutter_widget_from_html',
      ]);
    },
  );

  test('returns only native JSON renderers for native JSON fixtures', () {
    final nativeJsonRenderers = benchmarkRenderersForSourceType(
      BenchmarkSourceType.nativeJson,
    );

    expect(nativeJsonRenderers.map((renderer) => renderer.id), [
      nativeJsonBenchmarkRendererId,
    ]);
    expect(
      nativeJsonRenderers.every(
        (renderer) => renderer.supports(BenchmarkSourceType.nativeJson),
      ),
      isTrue,
    );
  });

  test('returns only the native JSON renderer for native JSON fixtures', () {
    for (final fixtureId in [
      nativeJsonBenchmarkFixtureId,
      nativeJsonTableBenchmarkFixtureId,
      nativeJsonLargeArticleBenchmarkFixtureId,
      'answer_detail_equivalent_v1_native',
    ]) {
      final fixture = profileBenchmarkFixtureById(fixtureId);
      final renderers = benchmarkRenderersForFixture(fixture);

      expect(renderers.map((renderer) => renderer.id), [
        nativeJsonBenchmarkRendererId,
      ]);
      expect(
        benchmarkRendererSupportsFixture(
          benchmarkRendererById(nativeJsonBenchmarkRendererId),
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
    }
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

  test(
    'returns only the semantic renderer for the authored insertion fixture',
    () {
      final fixture = profileBenchmarkFixtureById(
        authoredInsertionBenchmarkFixtureId,
      );
      final renderers = benchmarkRenderersForFixture(fixture);

      expect(renderers.map((renderer) => renderer.id), ['tagflow_semantic']);
      expect(
        benchmarkRendererSupportsFixture(
          benchmarkRendererById('tagflow_semantic'),
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
    },
  );

  test(
    'returns only the patch renderer for the authored insertion patch fixture',
    () {
      final fixture = profileBenchmarkFixtureById(
        authoredInsertionSemanticPatchBenchmarkFixtureId,
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
          benchmarkRendererById('tagflow_semantic'),
          fixture,
        ),
        isFalse,
      );
    },
  );

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

  testWidgets(
    'builds the authored insertion fixture with the semantic renderer',
    (tester) async {
      final fixture = profileBenchmarkFixtureById(
        authoredInsertionBenchmarkFixtureId,
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) =>
                benchmarkRendererById('tagflow_semantic').build(
                  context,
                  BenchmarkSourceDocument(
                    type: fixture.source.type,
                    data: authoredInsertionStreamingHtmlSnapshots.last,
                    assetPath: fixture.source.assetPath,
                  ),
                ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Lead'), findsOneWidget);
      expect(find.text('Summary'), findsOneWidget);
      expect(find.text('Details'), findsOneWidget);
    },
  );

  testWidgets('builds the native JSON fixture with the native renderer', (
    tester,
  ) async {
    final fixture = profileBenchmarkFixtureById(nativeJsonBenchmarkFixtureId);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Builder(
          builder: (context) =>
              benchmarkRendererById(nativeJsonBenchmarkRendererId).build(
                context,
                const BenchmarkSourceDocument(
                  type: BenchmarkSourceType.nativeJson,
                  data: '''
{
  "id": "native-test",
  "schemaVersion": 1,
  "blocks": [
    {
      "id": "title",
      "kind": "heading",
      "attributes": {"level": 2},
      "children": [
        {"id": "title.text", "kind": "text", "text": "Native JSON render"}
      ]
    },
    {
      "id": "body",
      "kind": "paragraph",
      "children": [
        {"id": "body.text", "kind": "text", "text": "Rendered from blocks."}
      ]
    }
  ]
}
''',
                  assetPath:
                      'packages/tagflow_benchmarks/fixtures/native/'
                      'native_ai_answer.json',
                ),
              ),
        ),
      ),
    );

    await tester.pump();

    expect(fixture.source.type, BenchmarkSourceType.nativeJson);
    expect(find.text('Native JSON render'), findsOneWidget);
    expect(find.text('Rendered from blocks.'), findsOneWidget);
  });

  testWidgets(
    'builds the authored insertion patch fixture with the patch renderer',
    (tester) async {
      final fixture = profileBenchmarkFixtureById(
        authoredInsertionSemanticPatchBenchmarkFixtureId,
      );
      final stream = SemanticPatchStream.fromFixture(
        fixture,
        authoredInsertionStreamingHtmlSnapshots.last,
      );
      final runtimeDocument = stream.steps.fold(
        stream.initialDocument,
        (document, step) => document.applyPatch(step.patch),
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) =>
                benchmarkRendererById(semanticPatchBenchmarkRendererId).build(
                  context,
                  BenchmarkSourceDocument(
                    type: fixture.source.type,
                    data: authoredInsertionStreamingHtmlSnapshots.last,
                    assetPath: fixture.source.assetPath,
                    runtimeDocument: runtimeDocument,
                  ),
                ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Lead'), findsOneWidget);
      expect(find.text('Summary'), findsOneWidget);
      expect(find.text('Details'), findsOneWidget);
    },
  );
}
