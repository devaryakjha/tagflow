import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow_benchmarks/tagflow_benchmarks.dart';

void main() {
  test('benchmark results round-trip through JSON', () {
    final result = ParserBenchmarkSuiteResult(
      suite: 'parser',
      generatedAt: DateTime.utc(2026, 6, 11),
      environment: const BenchmarkEnvironment(
        packageVersion: '0.0.0-test',
        dartVersion: '3.9.0',
        flutterVersion: '3.35.0',
        os: 'macos',
      ),
      warmupIterations: 2,
      sampleCount: 3,
      fixtureResults: const <ParserBenchmarkFixtureResult>[
        ParserBenchmarkFixtureResult(
          fixtureId: 'smoke_short_html',
          inputBytes: 128,
          nodeCount: 5,
          sampleMicros: <int>[120, 130, 140],
          medianMicros: 130,
          p95Micros: 140,
          minMicros: 120,
          maxMicros: 140,
          meanMicros: 130,
          coefficientOfVariation: 0.06,
          parsesPerSecond: 7692.31,
          nodesPerSecond: 38461.54,
        ),
      ],
    );

    final roundTrip = ParserBenchmarkSuiteResult.fromJson(
      jsonDecode(jsonEncode(result.toJson())) as Map<String, Object?>,
    );

    expect(roundTrip, result);
  });

  test('render benchmark results round-trip through JSON', () {
    final result = RenderBenchmarkSuiteResult(
      suite: 'render',
      generatedAt: DateTime.utc(2026, 6, 11),
      environment: const BenchmarkEnvironment(
        packageVersion: '0.0.0-test',
        dartVersion: '3.9.0',
        flutterVersion: '3.35.0',
        os: 'macos',
      ),
      warmupIterations: 1,
      sampleCount: 3,
      fixtureResults: const <RenderBenchmarkFixtureResult>[
        RenderBenchmarkFixtureResult(
          fixtureId: 'ai_answer_rich',
          inputBytes: 4096,
          nodeCount: 42,
          conversionBuildSampleMicros: <int>[1000, 1100, 1200],
          medianConversionBuildMicros: 1100,
          p95ConversionBuildMicros: 1200,
          minConversionBuildMicros: 1000,
          maxConversionBuildMicros: 1200,
          meanConversionBuildMicros: 1100,
          coefficientOfVariation: 0.07,
        ),
      ],
    );

    final roundTrip = RenderBenchmarkSuiteResult.fromJson(
      jsonDecode(jsonEncode(result.toJson())) as Map<String, Object?>,
    );

    expect(roundTrip, result);
  });

  test('native transport benchmark results round-trip through JSON', () {
    final result = NativeTransportBenchmarkSuiteResult(
      suite: 'native_transport',
      generatedAt: DateTime.utc(2026, 6, 11),
      environment: const BenchmarkEnvironment(
        packageVersion: '0.0.0-test',
        dartVersion: '3.9.0',
        flutterVersion: '3.35.0',
        os: 'macos',
      ),
      warmupIterations: 1,
      sampleCount: 3,
      fixtureResults: const <NativeTransportBenchmarkFixtureResult>[
        NativeTransportBenchmarkFixtureResult(
          fixtureId: 'native_ai_answer_patch',
          documentBytes: 2048,
          patchBytes: 512,
          nodeCount: 12,
          patchOperationCount: 2,
          phaseResults: <NativeTransportBenchmarkPhaseResult>[
            NativeTransportBenchmarkPhaseResult(
              phaseId: 'decodeDocument',
              sampleMicros: <int>[40, 50, 60],
              medianMicros: 50,
              p95Micros: 60,
              minMicros: 40,
              maxMicros: 60,
              meanMicros: 50,
              coefficientOfVariation: 0.2,
            ),
          ],
        ),
      ],
    );

    final roundTrip = NativeTransportBenchmarkSuiteResult.fromJson(
      jsonDecode(jsonEncode(result.toJson())) as Map<String, Object?>,
    );

    expect(roundTrip, result);
  });
}
