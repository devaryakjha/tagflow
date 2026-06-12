import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:tagflow_benchmarks/src/gates/native_runtime_gate_status.dart';
import 'package:tagflow_benchmarks/src/io/package_paths.dart';

Future<void> main(List<String> arguments) async {
  if (arguments.contains('--help') || arguments.contains('-h')) {
    _printUsage();
    return;
  }

  try {
    final workspaceRoot = resolveWorkspaceRoot();
    final options = _parseOptions(
      arguments: arguments,
      workspaceRoot: workspaceRoot,
    );
    final result = checkNativeRuntimeGateStatus(
      manifestFile: options.manifestFile,
      profileId: options.profileId,
      evidenceRoot: workspaceRoot,
    );

    stdout.writeln(const JsonEncoder.withIndent('  ').convert(result.toJson()));
    exitCode = result.passed ? 0 : 1;
  } on FormatException catch (error) {
    stderr.writeln(error.message);
    _printUsage(to: stderr);
    exitCode = 64;
  }
}

_CheckNativeRuntimeGatesOptions _parseOptions({
  required List<String> arguments,
  required Directory workspaceRoot,
}) {
  final values = <String, String>{};
  for (final argument in arguments) {
    if (!argument.startsWith('--')) {
      throw FormatException('Unknown positional argument: $argument');
    }

    final separator = argument.indexOf('=');
    if (separator == -1) {
      throw FormatException('Expected --name=value, got: $argument');
    }

    values[argument.substring(2, separator)] = argument.substring(
      separator + 1,
    );
  }

  final manifestPath =
      values['manifest'] ??
      Platform.environment['TAGFLOW_NATIVE_RUNTIME_GATE_MANIFEST'] ??
      p.join('docs', 'plans', 'native-runtime-gate-status.json');
  final resolvedManifestPath = p.isAbsolute(manifestPath)
      ? manifestPath
      : p.join(workspaceRoot.path, manifestPath);

  final profileId =
      values['profile'] ??
      Platform.environment['TAGFLOW_NATIVE_RUNTIME_GATE_PROFILE'] ??
      'pr72-draft';
  if (profileId.trim().isEmpty) {
    throw const FormatException('--profile must be a non-empty string.');
  }

  return _CheckNativeRuntimeGatesOptions(
    manifestFile: File(resolvedManifestPath),
    profileId: profileId,
  );
}

void _printUsage({IOSink? to}) {
  (to ?? stdout).writeln('''
Checks the native runtime coordinator gate manifest for a selected readiness
profile. The command exits 0 only when every gate required by the selected
profile is satisfied.

Usage:
  dart run bin/check_native_runtime_gates.dart [options]

Options:
  --manifest=<path>  Gate manifest path. Defaults to
                     docs/plans/native-runtime-gate-status.json.
                     Also accepts TAGFLOW_NATIVE_RUNTIME_GATE_MANIFEST.
  --profile=<id>     Readiness profile to check. Defaults to pr72-draft.
                     Also accepts TAGFLOW_NATIVE_RUNTIME_GATE_PROFILE.

Examples:
  dart run bin/check_native_runtime_gates.dart --profile=pr72-draft
  dart run bin/check_native_runtime_gates.dart --profile=pr72-ready
''');
}

final class _CheckNativeRuntimeGatesOptions {
  const _CheckNativeRuntimeGatesOptions({
    required this.manifestFile,
    required this.profileId,
  });

  final File manifestFile;
  final String profileId;
}
