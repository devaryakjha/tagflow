import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tagflow/legacy.dart';
import 'package:tagflow_benchmarks/src/fixtures/fixture_manifest.dart';
import 'package:tagflow_benchmarks/src/results/benchmark_result.dart';
import 'package:tagflow_benchmarks/src/results/environment_detector.dart';
import 'package:tagflow_benchmarks/src/results/sample_statistics.dart';

/// Pumps a widget under the benchmark test binding.
typedef BenchmarkWidgetPump = Future<void> Function(Widget widget);

/// Widget-test render benchmark for Tagflow's parse, conversion, and build
/// path.
class TagflowRenderBenchmarkSuite {
  /// Creates a render benchmark suite.
  const TagflowRenderBenchmarkSuite({
    this.warmupIterations = 3,
    this.sampleCount = 5,
    this.parser = const TagflowParser(),
  });

  /// Untimed pumps before collecting samples.
  final int warmupIterations;

  /// Number of timed pumps per fixture.
  final int sampleCount;

  /// Parser used for deterministic node counts.
  final TagflowParser parser;

  /// Runs render benchmarks for [fixtures], or all fixtures when omitted.
  Future<RenderBenchmarkSuiteResult> run({
    required BenchmarkWidgetPump pumpWidget,
    Iterable<BenchmarkFixture>? fixtures,
  }) async {
    final selectedFixtures = List<BenchmarkFixture>.unmodifiable(
      fixtures ?? benchmarkFixtures,
    );

    final fixtureResults = <RenderBenchmarkFixtureResult>[];
    for (final fixture in selectedFixtures) {
      fixtureResults.add(await _benchmarkFixture(fixture, pumpWidget));
    }

    await pumpWidget(const SizedBox.shrink());

    return RenderBenchmarkSuiteResult(
      suite: 'render',
      generatedAt: DateTime.now().toUtc(),
      environment: detectBenchmarkEnvironment(),
      warmupIterations: warmupIterations,
      sampleCount: sampleCount,
      fixtureResults: fixtureResults,
    );
  }

  Future<RenderBenchmarkFixtureResult> _benchmarkFixture(
    BenchmarkFixture fixture,
    BenchmarkWidgetPump pumpWidget,
  ) async {
    final html = fixture.html;
    final inputBytes = utf8.encode(html).length;
    final nodeCount = _countNodes(parser.parse(html));

    for (var index = 0; index < warmupIterations; index++) {
      await pumpWidget(_BenchmarkHost(html: html, iteration: index));
    }

    final samples = <int>[];
    for (var index = 0; index < sampleCount; index++) {
      final stopwatch = Stopwatch()..start();
      await pumpWidget(
        _BenchmarkHost(html: html, iteration: warmupIterations + index),
      );
      stopwatch.stop();
      samples.add(max(stopwatch.elapsedMicroseconds, 1));
    }

    final stats = BenchmarkSampleStatistics.fromSamples(samples);

    return RenderBenchmarkFixtureResult(
      fixtureId: fixture.id,
      inputBytes: inputBytes,
      nodeCount: nodeCount,
      conversionBuildSampleMicros: stats.samples,
      medianConversionBuildMicros: stats.medianMicros,
      p95ConversionBuildMicros: stats.p95Micros,
      minConversionBuildMicros: stats.minMicros,
      maxConversionBuildMicros: stats.maxMicros,
      meanConversionBuildMicros: stats.meanMicros,
      coefficientOfVariation: stats.coefficientOfVariation,
    );
  }

  int _countNodes(TagflowNode node) {
    var count = 1;
    for (final child in node.children) {
      count += _countNodes(child);
    }
    return count;
  }
}

class _BenchmarkHost extends StatelessWidget {
  const _BenchmarkHost({required this.html, required this.iteration});

  final String html;
  final int iteration;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MediaQuery(
        data: const MediaQueryData(size: Size(800, 1200)),
        child: Scaffold(
          body: SingleChildScrollView(
            child: Tagflow(
              key: ValueKey<int>(iteration),
              html: html,
              options: TagflowOptions.defaults.copyWith(
                enableImageCache: false,
                selectable: const TagflowSelectableOptions(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
