import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:tagflow_benchmarks/tagflow_benchmarks.dart';

void main() {
  testWidgets(
    'writes streaming benchmark JSON artifact',
    (tester) async {
      final outputPath = p.join('build', 'benchmarks', 'streaming.json');
      final outputFile = File(outputPath);
      if (outputFile.existsSync()) {
        outputFile.deleteSync();
      }

      // Small sizes keep the test fast; the melos script runs the defaults.
      final full = Platform.environment['TAGFLOW_BENCH_FULL'] == '1';
      final suite = full
          ? const TagflowStreamingBenchmarkSuite()
          : const TagflowStreamingBenchmarkSuite(
              patchDocumentSections: 50,
              patchCount: 20,
              markdownRepeats: 1,
              renderChunks: 10,
            );

      final result = await suite.run(pumpWidget: tester.pumpWidget);
      writeBenchmarkJson(result.toJson(), outputPath);

      final json =
          jsonDecode(outputFile.readAsStringSync()) as Map<String, Object?>;
      expect(json['suite'], 'streaming');
      expect(
        (json['lanes']! as List<Object?>).map(
          (lane) => (lane! as Map<String, Object?>)['lane'],
        ),
        ['patch.replaceNode', 'markdown.stream.add', 'markdown.stream.render'],
      );
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );
}
