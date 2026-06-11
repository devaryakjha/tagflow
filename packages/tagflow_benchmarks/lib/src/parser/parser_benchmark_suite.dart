import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:path/path.dart' as p;
import 'package:tagflow/tagflow.dart';
import 'package:tagflow_benchmarks/src/fixtures/fixture_manifest.dart';
import 'package:tagflow_benchmarks/src/io/package_paths.dart';
import 'package:tagflow_benchmarks/src/results/benchmark_result.dart';

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

    final sortedSamples = List<int>.from(samples)..sort();
    final meanMicros =
        samples.reduce((sum, value) => sum + value) / samples.length;
    final standardDeviation = _computeStandardDeviation(
      samples: samples,
      mean: meanMicros,
    );
    final coefficientOfVariation = meanMicros == 0
        ? 0.0
        : standardDeviation / meanMicros;

    return ParserBenchmarkFixtureResult(
      fixtureId: fixture.id,
      inputBytes: inputBytes,
      nodeCount: nodeCount,
      sampleMicros: samples,
      medianMicros: _percentile(sortedSamples, 0.5),
      p95Micros: _percentile(sortedSamples, 0.95),
      minMicros: sortedSamples.first,
      maxMicros: sortedSamples.last,
      meanMicros: meanMicros,
      coefficientOfVariation: coefficientOfVariation,
      parsesPerSecond: 1000000 / meanMicros,
      nodesPerSecond: (nodeCount * 1000000) / meanMicros,
    );
  }

  int _countNodes(TagflowNode node) {
    var count = 1;
    for (final child in node.children) {
      count += _countNodes(child);
    }
    return count;
  }

  int _percentile(List<int> sortedSamples, double percentile) {
    if (sortedSamples.length == 1) {
      return sortedSamples.single;
    }

    final rawIndex = ((sortedSamples.length - 1) * percentile).round();
    final boundedIndex = rawIndex.clamp(0, sortedSamples.length - 1);
    return sortedSamples[boundedIndex];
  }

  double _computeStandardDeviation({
    required List<int> samples,
    required double mean,
  }) {
    final variance =
        samples
            .map((value) => pow(value - mean, 2))
            .reduce((sum, value) => sum + value) /
        samples.length;
    return sqrt(variance);
  }

  BenchmarkEnvironment _detectEnvironment() {
    return BenchmarkEnvironment(
      packageVersion: _readTagflowVersion(),
      dartVersion: Platform.version.split(' ').first,
      flutterVersion: _readFlutterVersion(),
      os: Platform.operatingSystem,
    );
  }

  String _readTagflowVersion() {
    final workspaceRoot = resolveWorkspaceRoot();
    final pubspec = File(
      p.join(workspaceRoot.path, 'packages', 'tagflow', 'pubspec.yaml'),
    );

    if (!pubspec.existsSync()) {
      return 'unknown';
    }

    for (final line in pubspec.readAsLinesSync()) {
      if (line.startsWith('version: ')) {
        return line.replaceFirst('version: ', '').trim();
      }
    }
    return 'unknown';
  }

  String _readFlutterVersion() {
    final flutterVersion = Platform.environment['FLUTTER_VERSION'];
    if (flutterVersion != null && flutterVersion.isNotEmpty) {
      return flutterVersion;
    }
    return 'unknown';
  }
}
