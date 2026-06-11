import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:tagflow_benchmarks/src/io/package_paths.dart';

void main() {
  test('resolves benchmark package root from a workspace consumer', () {
    final originalCurrent = Directory.current;
    final temp = Directory.systemTemp.createTempSync('tagflow_paths_test_');

    try {
      final benchmarkPackage = Directory(
        p.join(temp.path, 'packages', 'tagflow_benchmarks'),
      )..createSync(recursive: true);
      File(
        p.join(benchmarkPackage.path, 'pubspec.yaml'),
      ).writeAsStringSync('name: tagflow_benchmarks\n');

      final examplePackage = Directory(p.join(temp.path, 'examples', 'tagflow'))
        ..createSync(recursive: true);

      Directory.current = examplePackage;

      expect(
        resolveBenchmarkPackageRoot().resolveSymbolicLinksSync(),
        benchmarkPackage.resolveSymbolicLinksSync(),
      );
    } finally {
      Directory.current = originalCurrent;
      temp.deleteSync(recursive: true);
    }
  });
}
