import 'dart:convert';
import 'dart:ui' show FrameTiming;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tagflow/tagflow.dart';
import 'package:tagflow_example/benchmarks/benchmark_host.dart';
import 'package:tagflow_example/benchmarks/fixtures.dart';
import 'package:tagflow_example/benchmarks/launch_attribution.dart';
import 'package:tagflow_example/benchmarks/profile_checkpoint_hold.dart';
import 'package:tagflow_example/benchmarks/renderer_registry.dart';
import 'package:tagflow_example/benchmarks/semantic_patch_stream.dart';
import 'package:tagflow_example/screens/benchmark_screen.dart';

const double _frameBudgetMillis = 16.667;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('scrolls a Tagflow benchmark fixture', (tester) async {
    final checkpointHold = _checkpointHoldOptionsFromEnvironment();
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

    binding.reportData ??= <String, dynamic>{};
    final fullDocument = await rootBundle.loadString(fixture.source.assetPath);
    _recordInputMetadata(
      binding,
      rendererId: rendererId,
      fixture: fixture,
      input: fullDocument,
    );
    _recordCheckpointHoldConfig(
      binding,
      rendererId: rendererId,
      fixtureId: fixtureId,
      holdOptions: checkpointHold,
    );
    _recordViewport(
      tester,
      binding,
      rendererId: rendererId,
      fixtureId: fixtureId,
    );
    await _recordLaunchAttribution(
      binding,
      rendererId: rendererId,
      fixtureId: fixtureId,
    );

    await binding.watchPerformance(() async {
      await tester.pumpWidget(
        _buildStaticBenchmarkApp(fixtureId: fixtureId, rendererId: rendererId),
      );
      await tester.pumpAndSettle();
    }, reportKey: '${rendererId}_${fixtureId}_initial_render');

    expect(find.byKey(BenchmarkHost.contentKey), findsOneWidget);

    await binding.watchPerformance(() async {
      await tester.pumpWidget(
        _buildStaticBenchmarkApp(fixtureId: fixtureId, rendererId: rendererId),
      );
      await tester.pumpAndSettle();
    }, reportKey: '${rendererId}_${fixtureId}_warm_rebuild');

    expect(find.byKey(BenchmarkHost.contentKey), findsOneWidget);

    await binding.watchPerformance(() async {
      await tester.fling(
        find.byKey(BenchmarkHost.scrollKey),
        const Offset(0, -1200),
        10000,
      );
      await tester.pumpAndSettle();
    }, reportKey: '${rendererId}_${fixtureId}_scroll');

    await _replayStaticCheckpointHolds(
      tester: tester,
      binding: binding,
      fixtureId: fixtureId,
      rendererId: rendererId,
      holdOptions: checkpointHold,
    );
  });
}

Widget _buildStaticBenchmarkApp({
  required String fixtureId,
  required String rendererId,
}) {
  return MaterialApp(
    home: BenchmarkScreen(
      fixtureId: fixtureId,
      rendererId: rendererId,
      showFixturePicker: false,
    ),
  );
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
  final checkpointHold = _checkpointHoldOptionsFromEnvironment();

  binding.reportData ??= <String, dynamic>{};
  _recordInputMetadata(
    binding,
    rendererId: renderer.id,
    fixture: fixture,
    input: fullDocument,
  );
  _recordCheckpointHoldConfig(
    binding,
    rendererId: renderer.id,
    fixtureId: fixture.id,
    holdOptions: checkpointHold,
  );
  _recordViewport(
    tester,
    binding,
    rendererId: renderer.id,
    fixtureId: fixture.id,
  );
  await _recordLaunchAttribution(
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

      late final int pumpWidgetMicros;
      late final int settleMicros;
      final frameTimingAttribution = await _captureUpdateFrameTimingAttribution(
        binding: binding,
        tester: tester,
        operation: (recorder) async {
          final pumpWidgetStopwatch = Stopwatch()..start();
          recorder.phase = _UpdateFramePhase.pumpWidget;
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
          recorder.phase = _UpdateFramePhase.unknown;
          pumpWidgetStopwatch.stop();
          pumpWidgetMicros = pumpWidgetStopwatch.elapsedMicroseconds;

          final settleStopwatch = Stopwatch()..start();
          recorder.phase = _UpdateFramePhase.settle;
          await tester.pumpAndSettle();
          recorder.phase = _UpdateFramePhase.unknown;
          settleStopwatch.stop();
          settleMicros = settleStopwatch.elapsedMicroseconds;
        },
      );
      totalStopwatch.stop();

      final updateLatency = <String, Object?>{
        'chunk': snapshot.chunk,
        'fraction': snapshot.fraction,
        'inputLength': snapshot.inputLength,
        'pumpWidgetMicros': pumpWidgetMicros,
        'settleMicros': settleMicros,
        'elapsedMicros': totalStopwatch.elapsedMicroseconds,
      };
      final frameTimingAttributionJson = frameTimingAttribution.toJson();
      if (frameTimingAttributionJson != null) {
        updateLatency['frameTimingAttribution'] = frameTimingAttributionJson;
      }
      updateLatencies.add(updateLatency);
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

  await _replayStreamingCheckpointHolds(
    tester: tester,
    binding: binding,
    fixture: fixture,
    renderer: renderer,
    fullDocument: fullDocument,
    holdOptions: checkpointHold,
  );
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
  final checkpointHold = _checkpointHoldOptionsFromEnvironment();

  binding.reportData ??= <String, dynamic>{};
  _recordInputMetadata(
    binding,
    rendererId: renderer.id,
    fixture: fixture,
    input: fullDocument,
  );
  _recordCheckpointHoldConfig(
    binding,
    rendererId: renderer.id,
    fixtureId: fixture.id,
    holdOptions: checkpointHold,
  );
  _recordViewport(
    tester,
    binding,
    rendererId: renderer.id,
    fixtureId: fixture.id,
  );
  await _recordLaunchAttribution(
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

      late final int pumpWidgetMicros;
      late final int settleMicros;
      final frameTimingAttribution = await _captureUpdateFrameTimingAttribution(
        binding: binding,
        tester: tester,
        operation: (recorder) async {
          final pumpWidgetStopwatch = Stopwatch()..start();
          recorder.phase = _UpdateFramePhase.pumpWidget;
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
          recorder.phase = _UpdateFramePhase.unknown;
          pumpWidgetStopwatch.stop();
          pumpWidgetMicros = pumpWidgetStopwatch.elapsedMicroseconds;

          final settleStopwatch = Stopwatch()..start();
          recorder.phase = _UpdateFramePhase.settle;
          await tester.pumpAndSettle();
          recorder.phase = _UpdateFramePhase.unknown;
          settleStopwatch.stop();
          settleMicros = settleStopwatch.elapsedMicroseconds;
        },
      );
      totalStopwatch.stop();

      final updateLatency = <String, Object?>{
        'chunk': step.chunk,
        'fraction': step.fraction,
        'inputLength': step.inputLength,
        'applyPatchMicros': applyPatchStopwatch.elapsedMicroseconds,
        'pumpWidgetMicros': pumpWidgetMicros,
        'settleMicros': settleMicros,
        'elapsedMicros': totalStopwatch.elapsedMicroseconds,
      };
      final frameTimingAttributionJson = frameTimingAttribution.toJson();
      if (frameTimingAttributionJson != null) {
        updateLatency['frameTimingAttribution'] = frameTimingAttributionJson;
      }
      updateLatencies.add(updateLatency);
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

  await _replaySemanticPatchCheckpointHolds(
    tester: tester,
    binding: binding,
    fixture: fixture,
    renderer: renderer,
    fullDocument: fullDocument,
    stream: stream,
    holdOptions: checkpointHold,
  );
}

void _recordInputMetadata(
  IntegrationTestWidgetsFlutterBinding binding, {
  required String rendererId,
  required ProfileBenchmarkFixture fixture,
  required String input,
}) {
  binding.reportData!['${rendererId}_${fixture.id}_input'] = <String, Object?>{
    'schemaVersion': 1,
    'sourceType': fixture.source.type.name,
    'assetPath': fixture.source.assetPath,
    'inputLength': input.length,
    'inputBytes': utf8.encode(input).length,
  };
}

void _recordCheckpointHoldConfig(
  IntegrationTestWidgetsFlutterBinding binding, {
  required String rendererId,
  required String fixtureId,
  required ProfileCheckpointHoldOptions holdOptions,
}) {
  binding.reportData!['${rendererId}_${fixtureId}_checkpoint_hold'] =
      holdOptions.toJson();
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

Future<void> _recordLaunchAttribution(
  IntegrationTestWidgetsFlutterBinding binding, {
  required String rendererId,
  required String fixtureId,
}) async {
  final payload = await BenchmarkLaunchAttributionPayload.capture();
  binding.reportData!['${rendererId}_${fixtureId}_launch_attribution'] = payload
      .toJson();
}

Future<_UpdateFrameTimingAttribution> _captureUpdateFrameTimingAttribution({
  required IntegrationTestWidgetsFlutterBinding binding,
  required WidgetTester tester,
  required Future<void> Function(_UpdateFrameTimingRecorder recorder) operation,
}) async {
  final recorder = _UpdateFrameTimingRecorder();
  void timingsCallback(List<FrameTiming> timings) {
    recorder.recordTimings(timings);
  }

  binding.addTimingsCallback(timingsCallback);
  try {
    await operation(recorder);
    recorder.phase = _UpdateFramePhase.unknown;
    await tester.idle();
    return recorder.buildAttribution();
  } finally {
    binding.removeTimingsCallback(timingsCallback);
  }
}

ProfileCheckpointHoldOptions _checkpointHoldOptionsFromEnvironment() {
  return ProfileCheckpointHoldOptions.parse(
    enabledValue: const String.fromEnvironment(
      'TAGFLOW_PROFILE_HOLD_OPEN',
      defaultValue: 'false',
    ),
    holdOpenSecondsValue: _nonEmptyEnvironmentValue(
      const String.fromEnvironment('TAGFLOW_PROFILE_HOLD_OPEN_SECONDS'),
    ),
  );
}

String? _nonEmptyEnvironmentValue(String value) {
  return value.trim().isEmpty ? null : value;
}

Future<void> _replayStaticCheckpointHolds({
  required WidgetTester tester,
  required IntegrationTestWidgetsFlutterBinding binding,
  required String fixtureId,
  required String rendererId,
  required ProfileCheckpointHoldOptions holdOptions,
}) async {
  if (!holdOptions.enabled) {
    return;
  }

  await _holdCheckpoint(
    binding,
    rendererId: rendererId,
    fixtureId: fixtureId,
    checkpoint: 'before_first_render',
    holdOptions: holdOptions,
  );

  await tester.pumpWidget(
    _buildStaticBenchmarkApp(fixtureId: fixtureId, rendererId: rendererId),
  );
  await tester.pumpAndSettle();
  expect(find.byKey(BenchmarkHost.contentKey), findsOneWidget);

  await _holdCheckpoint(
    binding,
    rendererId: rendererId,
    fixtureId: fixtureId,
    checkpoint: 'after_first_render',
    holdOptions: holdOptions,
  );

  await tester.pumpWidget(
    _buildStaticBenchmarkApp(fixtureId: fixtureId, rendererId: rendererId),
  );
  await tester.pumpAndSettle();
  await tester.fling(
    find.byKey(BenchmarkHost.scrollKey),
    const Offset(0, -1200),
    10000,
  );
  await tester.pumpAndSettle();

  await _holdCheckpoint(
    binding,
    rendererId: rendererId,
    fixtureId: fixtureId,
    checkpoint: 'after_scroll',
    holdOptions: holdOptions,
  );
}

Future<void> _replayStreamingCheckpointHolds({
  required WidgetTester tester,
  required IntegrationTestWidgetsFlutterBinding binding,
  required ProfileBenchmarkFixture fixture,
  required BenchmarkRenderer renderer,
  required String fullDocument,
  required ProfileCheckpointHoldOptions holdOptions,
}) async {
  if (!holdOptions.enabled) {
    return;
  }

  final snapshots = benchmarkStreamingSnapshots(fixture.id, fullDocument);
  await _holdCheckpoint(
    binding,
    rendererId: renderer.id,
    fixtureId: fixture.id,
    checkpoint: 'before_first_update',
    holdOptions: holdOptions,
  );

  for (final snapshot in snapshots.indexed) {
    await tester.pumpWidget(
      MaterialApp(
        home: _BenchmarkDocumentFrame(
          document: BenchmarkSourceDocument(
            type: fixture.source.type,
            data: snapshot.$2.html,
            assetPath: fixture.source.assetPath,
          ),
          renderer: renderer,
        ),
      ),
    );
    await tester.pumpAndSettle();

    if (snapshot.$1 == 0) {
      await _holdCheckpoint(
        binding,
        rendererId: renderer.id,
        fixtureId: fixture.id,
        checkpoint: 'after_first_update',
        holdOptions: holdOptions,
      );
    }
  }

  expect(find.byKey(BenchmarkHost.contentKey), findsOneWidget);

  await _holdCheckpoint(
    binding,
    rendererId: renderer.id,
    fixtureId: fixture.id,
    checkpoint: 'after_final_update',
    holdOptions: holdOptions,
  );

  await tester.fling(
    find.byKey(BenchmarkHost.scrollKey),
    const Offset(0, -1200),
    10000,
  );
  await tester.pumpAndSettle();

  await _holdCheckpoint(
    binding,
    rendererId: renderer.id,
    fixtureId: fixture.id,
    checkpoint: 'after_scroll',
    holdOptions: holdOptions,
  );
}

Future<void> _replaySemanticPatchCheckpointHolds({
  required WidgetTester tester,
  required IntegrationTestWidgetsFlutterBinding binding,
  required ProfileBenchmarkFixture fixture,
  required BenchmarkRenderer renderer,
  required String fullDocument,
  required SemanticPatchStream stream,
  required ProfileCheckpointHoldOptions holdOptions,
}) async {
  if (!holdOptions.enabled) {
    return;
  }

  await _holdCheckpoint(
    binding,
    rendererId: renderer.id,
    fixtureId: fixture.id,
    checkpoint: 'before_first_patch',
    holdOptions: holdOptions,
  );

  var currentDocument = stream.initialDocument;
  for (final step in stream.steps.indexed) {
    currentDocument = currentDocument.applyPatch(step.$2.patch);
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
    await tester.pumpAndSettle();

    if (step.$1 == 0) {
      await _holdCheckpoint(
        binding,
        rendererId: renderer.id,
        fixtureId: fixture.id,
        checkpoint: 'after_first_patch',
        holdOptions: holdOptions,
      );
    }
  }

  expect(find.byKey(BenchmarkHost.contentKey), findsOneWidget);

  await _holdCheckpoint(
    binding,
    rendererId: renderer.id,
    fixtureId: fixture.id,
    checkpoint: 'after_final_patch',
    holdOptions: holdOptions,
  );

  await tester.fling(
    find.byKey(BenchmarkHost.scrollKey),
    const Offset(0, -1200),
    10000,
  );
  await tester.pumpAndSettle();

  await _holdCheckpoint(
    binding,
    rendererId: renderer.id,
    fixtureId: fixture.id,
    checkpoint: 'after_scroll',
    holdOptions: holdOptions,
  );
}

Future<void> _holdCheckpoint(
  IntegrationTestWidgetsFlutterBinding binding, {
  required String rendererId,
  required String fixtureId,
  required String checkpoint,
  required ProfileCheckpointHoldOptions holdOptions,
}) async {
  final holds =
      binding.reportData!.putIfAbsent(
            '${rendererId}_${fixtureId}_checkpoint_holds',
            () => <Map<String, Object?>>[],
          )
          as List<Map<String, Object?>>;
  final event = <String, Object?>{
    'checkpoint': checkpoint,
    'holdOpenSeconds': holdOptions.holdOpenSeconds,
    'startedAt': DateTime.now().toUtc().toIso8601String(),
  };
  holds.add(event);

  debugPrint(
    '[tagflow-profile-checkpoint] renderer=$rendererId fixture=$fixtureId '
    'checkpoint=$checkpoint hold_open_seconds='
    '${holdOptions.holdOpenSeconds} action=attach-devtools',
  );
  await Future<void>.delayed(holdOptions.holdDuration);
  event['finishedAt'] = DateTime.now().toUtc().toIso8601String();
  debugPrint(
    '[tagflow-profile-checkpoint] renderer=$rendererId fixture=$fixtureId '
    'checkpoint=$checkpoint hold_complete=true',
  );
}

enum _UpdateFramePhase { pumpWidget, settle, unknown }

final class _UpdateFrameTimingRecorder {
  final Map<_UpdateFramePhase, List<FrameTiming>> _timingsByPhase =
      <_UpdateFramePhase, List<FrameTiming>>{
        for (final phase in _UpdateFramePhase.values) phase: <FrameTiming>[],
      };
  _UpdateFramePhase phase = _UpdateFramePhase.unknown;

  void recordTimings(List<FrameTiming> timings) {
    _timingsByPhase[phase]!.addAll(timings);
  }

  _UpdateFrameTimingAttribution buildAttribution() {
    final phaseSummaries = <String, _UpdateFrameTimingPhaseSummary>{};
    var frameCount = 0;
    var missedBuildBudgetCount = 0;
    var missedRasterBudgetCount = 0;
    _ObservedFrameTiming? worstFrame;

    for (final entry in _timingsByPhase.entries) {
      if (entry.value.isEmpty) {
        continue;
      }
      final summary = _summarizePhaseTimings(entry.value);
      phaseSummaries[_phaseName(entry.key)] = summary;
      frameCount += summary.frameCount;
      missedBuildBudgetCount += summary.missedBuildBudgetCount;
      missedRasterBudgetCount += summary.missedRasterBudgetCount;

      for (final timing in entry.value) {
        final observed = _ObservedFrameTiming(
          phase: _phaseName(entry.key),
          buildMillis: timing.buildDuration.inMicroseconds / 1000.0,
          rasterMillis: timing.rasterDuration.inMicroseconds / 1000.0,
        );
        if (worstFrame == null || observed.score > worstFrame.score) {
          worstFrame = observed;
        }
      }
    }

    return _UpdateFrameTimingAttribution(
      frameCount: frameCount,
      missedBuildBudgetCount: missedBuildBudgetCount,
      missedRasterBudgetCount: missedRasterBudgetCount,
      worstFrame: worstFrame,
      phaseSummaries: phaseSummaries,
    );
  }
}

final class _ObservedFrameTiming {
  const _ObservedFrameTiming({
    required this.phase,
    required this.buildMillis,
    required this.rasterMillis,
  });

  final String phase;
  final double buildMillis;
  final double rasterMillis;

  double get score => buildMillis > rasterMillis ? buildMillis : rasterMillis;

  Map<String, Object?> toJson() => <String, Object?>{
    'phase': phase,
    'buildMillis': buildMillis,
    'rasterMillis': rasterMillis,
    'buildOverBudget': buildMillis > _frameBudgetMillis,
    'rasterOverBudget': rasterMillis > _frameBudgetMillis,
  };
}

final class _UpdateFrameTimingAttribution {
  const _UpdateFrameTimingAttribution({
    required this.frameCount,
    required this.missedBuildBudgetCount,
    required this.missedRasterBudgetCount,
    required this.worstFrame,
    required this.phaseSummaries,
  });

  final int frameCount;
  final int missedBuildBudgetCount;
  final int missedRasterBudgetCount;
  final _ObservedFrameTiming? worstFrame;
  final Map<String, _UpdateFrameTimingPhaseSummary> phaseSummaries;

  Map<String, Object?>? toJson() {
    if (frameCount == 0) {
      return null;
    }
    return <String, Object?>{
      'frameCount': frameCount,
      'missedBuildBudgetCount': missedBuildBudgetCount,
      'missedRasterBudgetCount': missedRasterBudgetCount,
      if (worstFrame != null) 'worstFrame': worstFrame!.toJson(),
      if (phaseSummaries.isNotEmpty)
        'phases': phaseSummaries.map(
          (phase, summary) => MapEntry(phase, summary.toJson()),
        ),
    };
  }
}

final class _UpdateFrameTimingPhaseSummary {
  const _UpdateFrameTimingPhaseSummary({
    required this.frameCount,
    required this.worstBuildMillis,
    required this.worstRasterMillis,
    required this.missedBuildBudgetCount,
    required this.missedRasterBudgetCount,
  });

  final int frameCount;
  final double worstBuildMillis;
  final double worstRasterMillis;
  final int missedBuildBudgetCount;
  final int missedRasterBudgetCount;

  Map<String, Object?> toJson() => <String, Object?>{
    'frameCount': frameCount,
    'worstBuildMillis': worstBuildMillis,
    'worstRasterMillis': worstRasterMillis,
    'missedBuildBudgetCount': missedBuildBudgetCount,
    'missedRasterBudgetCount': missedRasterBudgetCount,
  };
}

_UpdateFrameTimingPhaseSummary _summarizePhaseTimings(
  List<FrameTiming> timings,
) {
  double worstBuildMillis = 0;
  double worstRasterMillis = 0;
  var missedBuildBudgetCount = 0;
  var missedRasterBudgetCount = 0;

  for (final timing in timings) {
    final buildMillis = timing.buildDuration.inMicroseconds / 1000.0;
    final rasterMillis = timing.rasterDuration.inMicroseconds / 1000.0;
    if (buildMillis > worstBuildMillis) {
      worstBuildMillis = buildMillis;
    }
    if (rasterMillis > worstRasterMillis) {
      worstRasterMillis = rasterMillis;
    }
    if (buildMillis > _frameBudgetMillis) {
      missedBuildBudgetCount += 1;
    }
    if (rasterMillis > _frameBudgetMillis) {
      missedRasterBudgetCount += 1;
    }
  }

  return _UpdateFrameTimingPhaseSummary(
    frameCount: timings.length,
    worstBuildMillis: worstBuildMillis,
    worstRasterMillis: worstRasterMillis,
    missedBuildBudgetCount: missedBuildBudgetCount,
    missedRasterBudgetCount: missedRasterBudgetCount,
  );
}

String _phaseName(_UpdateFramePhase phase) => switch (phase) {
  _UpdateFramePhase.pumpWidget => 'pumpWidget',
  _UpdateFramePhase.settle => 'settle',
  _UpdateFramePhase.unknown => 'unknown',
};

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
