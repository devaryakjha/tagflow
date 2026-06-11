import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tagflow_example/benchmarks/benchmark_host.dart';
import 'package:tagflow_example/benchmarks/fixtures.dart';
import 'package:tagflow_example/benchmarks/renderer_registry.dart';
import 'package:tagflow_example/screens/benchmark_screen.dart';

const _streamingChunkFractions = [0.25, 0.5, 0.75, 1.0];

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

    if (fixture.scenario == BenchmarkScenario.streamingChunks) {
      await _runStreamingBenchmark(
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

Future<void> _runStreamingBenchmark({
  required WidgetTester tester,
  required IntegrationTestWidgetsFlutterBinding binding,
  required ProfileBenchmarkFixture fixture,
  required BenchmarkRenderer renderer,
}) async {
  if (!renderer.supports(fixture.source.type)) {
    throw StateError(
      'Renderer "${renderer.id}" does not support ${fixture.source.type.name} '
      'fixtures.',
    );
  }

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
    for (final indexedFraction in _streamingChunkFractions.indexed) {
      final fraction = indexedFraction.$2;
      final chunk = _chunkDocument(fullDocument, fraction);
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: _BenchmarkDocumentFrame(
            document: BenchmarkSourceDocument(
              type: fixture.source.type,
              data: chunk,
              assetPath: fixture.source.assetPath,
            ),
            renderer: renderer,
          ),
        ),
      );
      await tester.pumpAndSettle();
      stopwatch.stop();

      updateLatencies.add(<String, Object?>{
        'chunk': indexedFraction.$1 + 1,
        'fraction': fraction,
        'inputLength': chunk.length,
        'elapsedMicros': stopwatch.elapsedMicroseconds,
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
