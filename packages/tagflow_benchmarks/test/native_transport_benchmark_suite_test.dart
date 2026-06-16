import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow_benchmarks/tagflow_benchmarks.dart';

void main() {
  test('runs native transport benchmark for selected fixtures', () {
    const suite = TagflowNativeTransportBenchmarkSuite(
      warmupIterations: 1,
      sampleCount: 3,
    );

    final result = suite.run(
      fixtures: <NativeTransportBenchmarkFixture>[
        nativeTransportBenchmarkFixtures.single,
      ],
    );

    expect(result.suite, 'native_transport');
    expect(result.warmupIterations, 1);
    expect(result.sampleCount, 3);
    expect(result.fixtureResults, hasLength(1));

    final fixtureResult = result.fixtureResults.single;
    expect(fixtureResult.fixtureId, 'native_ai_answer_patch');
    expect(fixtureResult.documentBytes, greaterThan(0));
    expect(fixtureResult.patchBytes, greaterThan(0));
    expect(fixtureResult.nodeCount, greaterThan(0));
    expect(fixtureResult.patchOperationCount, greaterThan(0));
    expect(fixtureResult.phaseResults.map((phase) => phase.phaseId), [
      'decodeDocument',
      'adaptDocument',
      'decodePatchEnvelope',
      'adaptPatches',
      'applyPatches',
      'totalTransport',
    ]);
    for (final phase in fixtureResult.phaseResults) {
      expect(phase.sampleMicros, hasLength(3));
      expect(phase.medianMicros, greaterThan(0));
      expect(phase.p95Micros, greaterThan(0));
      expect(phase.coefficientOfVariation, greaterThanOrEqualTo(0));
    }
  });
}
