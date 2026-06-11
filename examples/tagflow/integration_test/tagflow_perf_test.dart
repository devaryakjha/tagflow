import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tagflow/tagflow.dart';
import 'package:tagflow_example/benchmarks/benchmark_host.dart';
import 'package:tagflow_example/benchmarks/fixtures.dart';
import 'package:tagflow_example/benchmarks/renderer_registry.dart';
import 'package:tagflow_example/benchmarks/semantic_patch_stream.dart';
import 'package:tagflow_example/screens/benchmark_screen.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('scrolls a Tagflow benchmark fixture', (tester) async {
    // ignore: prefer_const_declarations
    final fixtureId = const String.fromEnvironment(
      'TAGFLOW_FIXTURE',
      defaultValue: defaultProfileBenchmarkFixtureId,
    );
    // ignore: prefer_const_declarations
    final rendererId = const String.fromEnvironment(
      'TAGFLOW_RENDERER',
      defaultValue: defaultBenchmarkRendererId,
    );
    final fixture = profileBenchmarkFixtureById(fixtureId);
    final renderer = benchmarkRendererById(rendererId);

    _verifyRendererFixturePair(renderer: renderer, fixture: fixture);

    if (fixture.scenario == BenchmarkScenario.streamingChunks) {
      await _runStreamingBenchmark(
        tester: tester,
        binding: binding,
        fixture: fixture,
        renderer: renderer,
      );
      return;
    }

    if (fixture.scenario == BenchmarkScenario.semanticPatchStreaming) {
      await _runSemanticPatchStreamingBenchmark(
        tester: tester,
        binding: binding,
        fixture: fixture,
        renderer: renderer,
      );
      return;
    }

    await tester.pumpWidget(
      MaterialApp(
        home: BenchmarkScreen(
          fixtureId: fixtureId,
          rendererId: rendererId,
          showFixturePicker: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(BenchmarkHost.contentKey), findsOneWidget);

    binding.reportData ??= <String, dynamic>{};
    _recordViewport(
      tester,
      binding,
      rendererId: rendererId,
      fixtureId: fixtureId,
    );

    await binding.watchPerformance(() async {
      await tester.fling(
        find.byKey(BenchmarkHost.scrollKey),
        const Offset(0, -1200),
        10000,
      );
      await tester.pumpAndSettle();
    }, reportKey: '${rendererId}_${fixtureId}_scroll');
  });
}

void _verifyRendererFixturePair({
  required BenchmarkRenderer renderer,
  required ProfileBenchmarkFixture fixture,
}) {
  if (!benchmarkRendererSupportsFixture(renderer, fixture)) {
    throw StateError(
      'Renderer "${renderer.id}" is not enabled for fixture "${fixture.id}".',
    );
  }
}

Future<void> _runStreamingBenchmark({
  required WidgetTester tester,
  required IntegrationTestWidgetsFlutterBinding binding,
  required ProfileBenchmarkFixture fixture,
  required BenchmarkRenderer renderer,
}) async {
  final fullDocument = await rootBundle.loadString(fixture.source.assetPath);
  final updateLatencies = <Map<String, Object?>>[];

  binding.reportData ??= <String, dynamic>{};
  _recordViewport(
    tester,
    binding,
    rendererId: renderer.id,
    fixtureId: fixture.id,
  );

  await binding.watchPerformance(() async {
    for (final snapshot in benchmarkStreamingSnapshots(
      fixture.id,
      fullDocument,
    )) {
      final totalStopwatch = Stopwatch()..start();

      final pumpWidgetStopwatch = Stopwatch()..start();
      await tester.pumpWidget(
        MaterialApp(
          home: _BenchmarkDocumentFrame(
            document: BenchmarkSourceDocument(
              type: fixture.source.type,
              data: snapshot.html,
              assetPath: fixture.source.assetPath,
            ),
            renderer: renderer,
          ),
        ),
      );
      pumpWidgetStopwatch.stop();

      final settleStopwatch = Stopwatch()..start();
      await tester.pumpAndSettle();
      settleStopwatch.stop();
      totalStopwatch.stop();

      updateLatencies.add(<String, Object?>{
        'chunk': snapshot.chunk,
        'fraction': snapshot.fraction,
        'inputLength': snapshot.inputLength,
        'pumpWidgetMicros': pumpWidgetStopwatch.elapsedMicroseconds,
        'settleMicros': settleStopwatch.elapsedMicroseconds,
        'elapsedMicros': totalStopwatch.elapsedMicroseconds,
      });
    }
  }, reportKey: '${renderer.id}_${fixture.id}_updates');

  expect(find.byKey(BenchmarkHost.contentKey), findsOneWidget);
  binding.reportData!['${renderer.id}_${fixture.id}_update_latencies'] =
      updateLatencies;

  await binding.watchPerformance(() async {
    await tester.fling(
      find.byKey(BenchmarkHost.scrollKey),
      const Offset(0, -1200),
      10000,
    );
    await tester.pumpAndSettle();
  }, reportKey: '${renderer.id}_${fixture.id}_scroll');
}

Future<void> _runSemanticPatchStreamingBenchmark({
  required WidgetTester tester,
  required IntegrationTestWidgetsFlutterBinding binding,
  required ProfileBenchmarkFixture fixture,
  required BenchmarkRenderer renderer,
}) async {
  final fullDocument = await rootBundle.loadString(fixture.source.assetPath);
  final stream = SemanticPatchStream.fromFixture(fixture, fullDocument);
  final updateLatencies = <Map<String, Object?>>[];

  binding.reportData ??= <String, dynamic>{};
  _recordViewport(
    tester,
    binding,
    rendererId: renderer.id,
    fixtureId: fixture.id,
  );

  var currentDocument = stream.initialDocument;
  await binding.watchPerformance(() async {
    for (final step in stream.steps) {
      final totalStopwatch = Stopwatch()..start();

      final applyPatchStopwatch = Stopwatch()..start();
      currentDocument = currentDocument.applyPatch(step.patch);
      applyPatchStopwatch.stop();

      final pumpWidgetStopwatch = Stopwatch()..start();
      await tester.pumpWidget(
        MaterialApp(
          home: _BenchmarkDocumentFrame(
            document: BenchmarkSourceDocument(
              type: fixture.source.type,
              data: fullDocument,
              assetPath: fixture.source.assetPath,
              runtimeDocument: currentDocument,
            ),
            renderer: renderer,
          ),
        ),
      );
      pumpWidgetStopwatch.stop();

      final settleStopwatch = Stopwatch()..start();
      await tester.pumpAndSettle();
      settleStopwatch.stop();
      totalStopwatch.stop();

      updateLatencies.add(<String, Object?>{
        'chunk': step.chunk,
        'fraction': step.fraction,
        'inputLength': step.inputLength,
        'applyPatchMicros': applyPatchStopwatch.elapsedMicroseconds,
        'pumpWidgetMicros': pumpWidgetStopwatch.elapsedMicroseconds,
        'settleMicros': settleStopwatch.elapsedMicroseconds,
        'elapsedMicros': totalStopwatch.elapsedMicroseconds,
      });
    }
  }, reportKey: '${renderer.id}_${fixture.id}_updates');

  expect(find.byKey(BenchmarkHost.contentKey), findsOneWidget);
  binding.reportData!['${renderer.id}_${fixture.id}_update_latencies'] =
      updateLatencies;

  await binding.watchPerformance(() async {
    await tester.fling(
      find.byKey(BenchmarkHost.scrollKey),
      const Offset(0, -1200),
      10000,
    );
    await tester.pumpAndSettle();
  }, reportKey: '${renderer.id}_${fixture.id}_scroll');
}

void _recordViewport(
  WidgetTester tester,
  IntegrationTestWidgetsFlutterBinding binding, {
  required String rendererId,
  required String fixtureId,
}) {
  final physicalSize = tester.view.physicalSize;
  final devicePixelRatio = tester.view.devicePixelRatio;
  binding.reportData!['${rendererId}_${fixtureId}_viewport'] =
      <String, Object?>{
        'logicalWidth': physicalSize.width / devicePixelRatio,
        'logicalHeight': physicalSize.height / devicePixelRatio,
        'physicalWidth': physicalSize.width,
        'physicalHeight': physicalSize.height,
        'devicePixelRatio': devicePixelRatio,
      };
}

final class _BenchmarkDocumentFrame extends StatelessWidget {
  const _BenchmarkDocumentFrame({
    required this.document,
    required this.renderer,
  });

  final BenchmarkSourceDocument document;
  final BenchmarkRenderer renderer;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: BenchmarkHost.scrollKey,
      padding: const EdgeInsets.all(24),
      children: [
        KeyedSubtree(
          key: BenchmarkHost.contentKey,
          child: renderer.build(context, document),
        ),
      ],
    );
  }
}
