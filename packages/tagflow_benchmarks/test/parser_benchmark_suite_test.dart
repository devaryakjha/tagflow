import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow_benchmarks/tagflow_benchmarks.dart';

void main() {
  test('runs parser benchmarks for selected fixtures', () {
    const suite = TagflowParserBenchmarkSuite(
      warmupIterations: 1,
      sampleCount: 3,
    );

    final result = suite.run(
      fixtures: <BenchmarkFixture>[fixtureById('smoke_short_html')],
    );

    expect(result.suite, 'parser');
    expect(result.warmupIterations, 1);
    expect(result.sampleCount, 3);
    expect(result.fixtureResults, hasLength(1));

    final fixtureResult = result.fixtureResults.single;
    expect(fixtureResult.fixtureId, 'smoke_short_html');
    expect(fixtureResult.inputBytes, greaterThan(0));
    expect(fixtureResult.nodeCount, greaterThan(0));
    expect(fixtureResult.sampleMicros, hasLength(3));
    expect(fixtureResult.medianMicros, greaterThan(0));
    expect(fixtureResult.p95Micros, greaterThan(0));
    expect(fixtureResult.coefficientOfVariation, greaterThanOrEqualTo(0));
    expect(fixtureResult.parsesPerSecond, greaterThan(0));
    expect(fixtureResult.nodesPerSecond, greaterThan(0));
  });
}
