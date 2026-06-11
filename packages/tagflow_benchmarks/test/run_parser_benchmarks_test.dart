import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../bin/run_parser_benchmarks.dart' as runner;

void main() {
  test(
    'writes parser benchmark JSON artifact',
    () {
      final outputPath = p.join('build', 'benchmarks', 'parser.json');
      final outputFile = File(outputPath);
      if (outputFile.existsSync()) {
        outputFile.deleteSync();
      }

      runner.main(['--warmup=1', '--samples=3', '--output=$outputPath']);

      expect(outputFile.existsSync(), isTrue);

      final json = jsonDecode(outputFile.readAsStringSync());
      expect(json, isA<Map<String, Object?>>());

      final result = json as Map<String, Object?>;
      final fixtureResults = result['fixtureResults'];

      expect(result['suite'], 'parser');
      expect(fixtureResults, isA<List<Object?>>());
      expect(fixtureResults, hasLength(5));
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
