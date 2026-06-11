import 'dart:convert';
import 'dart:math';

import 'package:tagflow/tagflow.dart';
import 'package:tagflow_benchmarks/src/fixtures/fixture_manifest.dart';
import 'package:tagflow_benchmarks/src/results/benchmark_result.dart';
import 'package:tagflow_benchmarks/src/results/environment_detector.dart';
import 'package:tagflow_benchmarks/src/results/sample_statistics.dart';

class TagflowParserBenchmarkSuite {
  const TagflowParserBenchmarkSuite({
    this.warmupIterations = 5,
    this.sampleCount = 10,
    this.parser = const TagflowParser(),
  });

  final int warmupIterations;
  final int sampleCount;
  final TagflowParser parser;

  ParserBenchmarkSuiteResult run({Iterable<BenchmarkFixture>? fixtures}) {
    final selectedFixtures = List<BenchmarkFixture>.unmodifiable(
      fixtures ?? benchmarkFixtures,
    );

    final fixtureResults = selectedFixtures
        .map(_benchmarkFixture)
        .toList(growable: false);

    return ParserBenchmarkSuiteResult(
      suite: 'parser',
      generatedAt: DateTime.now().toUtc(),
      environment: _detectEnvironment(),
      warmupIterations: warmupIterations,
      sampleCount: sampleCount,
      fixtureResults: fixtureResults,
    );
  }

  ParserBenchmarkFixtureResult _benchmarkFixture(BenchmarkFixture fixture) {
    final html = fixture.html;
    final inputBytes = utf8.encode(html).length;

    for (var index = 0; index < warmupIterations; index++) {
      parser.parse(html);
    }

    final samples = <int>[];
    var nodeCount = 0;
    for (var index = 0; index < sampleCount; index++) {
      final stopwatch = Stopwatch()..start();
      final parsed = parser.parse(html);
      stopwatch.stop();

      nodeCount = _countNodes(parsed);
      samples.add(max(stopwatch.elapsedMicroseconds, 1));
    }

    final stats = BenchmarkSampleStatistics.fromSamples(samples);

    return ParserBenchmarkFixtureResult(
      fixtureId: fixture.id,
      inputBytes: inputBytes,
      nodeCount: nodeCount,
      sampleMicros: stats.samples,
      medianMicros: stats.medianMicros,
      p95Micros: stats.p95Micros,
      minMicros: stats.minMicros,
      maxMicros: stats.maxMicros,
      meanMicros: stats.meanMicros,
      coefficientOfVariation: stats.coefficientOfVariation,
      parsesPerSecond: 1000000 / stats.meanMicros,
      nodesPerSecond: (nodeCount * 1000000) / stats.meanMicros,
    );
  }

  int _countNodes(TagflowNode node) {
    var count = 1;
    for (final child in node.children) {
      count += _countNodes(child);
    }
    return count;
  }

  BenchmarkEnvironment _detectEnvironment() => detectBenchmarkEnvironment();
}
