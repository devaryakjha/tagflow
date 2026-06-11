import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:tagflow_benchmarks/src/io/package_paths.dart';
import 'package:tagflow_benchmarks/src/results/benchmark_result.dart';

BenchmarkEnvironment detectBenchmarkEnvironment() {
  return BenchmarkEnvironment(
    packageVersion: _readTagflowVersion(),
    dartVersion: Platform.version.split(' ').first,
    flutterVersion: _readFlutterVersion(),
    os: Platform.operatingSystem,
  );
}

String _readTagflowVersion() {
  final workspaceRoot = resolveWorkspaceRoot();
  final pubspec = File(
    p.join(workspaceRoot.path, 'packages', 'tagflow', 'pubspec.yaml'),
  );

  if (!pubspec.existsSync()) {
    return 'unknown';
  }

  for (final line in pubspec.readAsLinesSync()) {
    if (line.startsWith('version: ')) {
      return line.replaceFirst('version: ', '').trim();
    }
  }
  return 'unknown';
}

String _readFlutterVersion() {
  final flutterVersion = Platform.environment['FLUTTER_VERSION'];
  if (flutterVersion != null && flutterVersion.isNotEmpty) {
    return flutterVersion;
  }
  return 'unknown';
}
