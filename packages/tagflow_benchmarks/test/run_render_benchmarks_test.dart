import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:tagflow_benchmarks/tagflow_benchmarks.dart';

void main() {
  testWidgets(
    'writes render benchmark JSON artifact',
    (tester) async {
      final outputPath = p.join('build', 'benchmarks', 'render.json');
      final outputFile = File(outputPath);
      if (outputFile.existsSync()) {
        outputFile.deleteSync();
      }

      const suite = TagflowRenderBenchmarkSuite(
        warmupIterations: 1,
        sampleCount: 2,
      );

      final result = await suite.run(pumpWidget: tester.pumpWidget);
      writeBenchmarkJson(result.toJson(), outputPath);

      expect(outputFile.existsSync(), isTrue);

      final json = jsonDecode(outputFile.readAsStringSync());
      expect(json, isA<Map<String, Object?>>());

      final artifact = json as Map<String, Object?>;
      final fixtureResults = artifact['fixtureResults'];

      expect(artifact['suite'], 'render');
      expect(fixtureResults, isA<List<Object?>>());
      expect(fixtureResults, hasLength(5));
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
