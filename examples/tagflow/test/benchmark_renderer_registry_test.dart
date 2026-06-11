import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow_example/benchmarks/renderer_registry.dart';

void main() {
  group('benchmarkRendererById', () {
    test('resolves the known benchmark renderers', () {
      expect(
        benchmarkRendererIds,
        containsAll(<String>[defaultBenchmarkRendererId, 'flutter_html']),
      );

      expect(
        benchmarkRendererById(defaultBenchmarkRendererId).label,
        'Tagflow',
      );
      expect(benchmarkRendererById('flutter_html').label, 'Flutter HTML');
    });

    test('throws for an unknown renderer id', () {
      expect(() => benchmarkRendererById('missing'), throwsArgumentError);
    });
  });
}
