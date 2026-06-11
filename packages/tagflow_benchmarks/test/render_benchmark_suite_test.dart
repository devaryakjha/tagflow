import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow_benchmarks/tagflow_benchmarks.dart';

void main() {
  testWidgets('runs render benchmarks for selected fixtures', (tester) async {
    const suite = TagflowRenderBenchmarkSuite(
      warmupIterations: 1,
      sampleCount: 2,
    );

    final result = await suite.run(
      pumpWidget: tester.pumpWidget,
      fixtures: <BenchmarkFixture>[fixtureById('smoke_short_html')],
    );

    expect(result.suite, 'render');
    expect(result.warmupIterations, 1);
    expect(result.sampleCount, 2);
    expect(result.fixtureResults, hasLength(1));

    final fixtureResult = result.fixtureResults.single;
    expect(fixtureResult.fixtureId, 'smoke_short_html');
    expect(fixtureResult.inputBytes, greaterThan(0));
    expect(fixtureResult.nodeCount, greaterThan(0));
    expect(fixtureResult.conversionBuildSampleMicros, hasLength(2));
    expect(fixtureResult.medianConversionBuildMicros, greaterThan(0));
    expect(fixtureResult.p95ConversionBuildMicros, greaterThan(0));
    expect(fixtureResult.coefficientOfVariation, greaterThanOrEqualTo(0));
  });
}
