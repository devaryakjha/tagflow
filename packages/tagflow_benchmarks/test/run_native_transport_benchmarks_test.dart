import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../bin/run_native_transport_benchmarks.dart' as runner;

void main() {
  test(
    'writes native transport benchmark JSON artifact',
    () {
      final outputPath = p.join('build', 'benchmarks', 'native_transport.json');
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

      expect(result['suite'], 'native_transport');
      expect(fixtureResults, isA<List<Object?>>());
      expect(fixtureResults, hasLength(1));
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
