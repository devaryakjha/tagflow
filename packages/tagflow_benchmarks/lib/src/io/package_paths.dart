import 'dart:io';

import 'package:path/path.dart' as p;

Directory resolveBenchmarkPackageRoot() {
  final current = Directory.current;

  if (_isBenchmarkPackageRoot(current)) {
    return current;
  }

  final nestedPackage = Directory(
    p.join(current.path, 'packages', 'tagflow_benchmarks'),
  );
  if (_isBenchmarkPackageRoot(nestedPackage)) {
    return nestedPackage;
  }

  var probe = current;
  while (true) {
    if (_isBenchmarkPackageRoot(probe)) {
      return probe;
    }

    final workspacePackage = Directory(
      p.join(probe.path, 'packages', 'tagflow_benchmarks'),
    );
    if (_isBenchmarkPackageRoot(workspacePackage)) {
      return workspacePackage;
    }

    final parent = probe.parent;
    if (parent.path == probe.path) {
      break;
    }
    probe = parent;
  }

  throw StateError('Unable to locate the tagflow_benchmarks package root.');
}

Directory resolveWorkspaceRoot() {
  final packageRoot = resolveBenchmarkPackageRoot();
  final workspaceRoot = Directory(
    p.normalize(p.join(packageRoot.path, '..', '..')),
  );

  if (File(p.join(workspaceRoot.path, 'pubspec.yaml')).existsSync()) {
    return workspaceRoot;
  }

  throw StateError('Unable to locate the workspace root.');
}

bool _isBenchmarkPackageRoot(Directory directory) {
  final pubspec = File(p.join(directory.path, 'pubspec.yaml'));
  if (!pubspec.existsSync()) {
    return false;
  }

  final contents = pubspec.readAsStringSync();
  return contents.contains('name: tagflow_benchmarks');
}
