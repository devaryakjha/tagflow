import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:tagflow_benchmarks/src/io/package_paths.dart';
import 'package:tagflow_benchmarks/src/profile/profile_baseline_summary.dart';

Future<void> main(List<String> arguments) async {
  if (arguments.contains('--help') || arguments.contains('-h')) {
    _printUsage();
    return;
  }

  final workspaceRoot = resolveWorkspaceRoot();
  final manifestFile = _resolveManifestFile(
    arguments: arguments,
    workspaceRoot: workspaceRoot,
  );
  final summaryFile = writeProfileBaselineSummary(
    manifestFile: manifestFile,
    workspaceRoot: workspaceRoot,
  );
  final summary =
      jsonDecode(summaryFile.readAsStringSync()) as Map<String, Object?>;
  stdout.writeln(const JsonEncoder.withIndent('  ').convert(summary));
}

File _resolveManifestFile({
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

  if (values.containsKey('manifest')) {
    final manifest = values['manifest']!;
    return File(
      p.isAbsolute(manifest) ? manifest : p.join(workspaceRoot.path, manifest),
    );
  }

  final runId = values['run-id'];
  if (runId == null || runId.trim().isEmpty) {
    throw const FormatException('Provide --manifest=<path> or --run-id=<id>.');
  }

  final outputDirectory =
      values['output-dir'] ??
      Platform.environment['TAGFLOW_PROFILE_OUTPUT_DIR'] ??
      p.join('build', 'benchmarks', 'profile');
  final resolvedOutputDirectory = p.isAbsolute(outputDirectory)
      ? outputDirectory
      : p.join(workspaceRoot.path, outputDirectory);

  return File(
    p.join(resolvedOutputDirectory, runId, 'profile-baseline-manifest.json'),
  );
}

void _printUsage() {
  stdout.writeln(r'''
Summarizes a collected profile baseline run.

Usage:
  dart run bin/summarize_profile_baselines.dart [options]

Options:
  --run-id=<id>       Baseline run id under the output directory.
  --output-dir=<path> Output directory. Defaults to build/benchmarks/profile.
                      Also accepts TAGFLOW_PROFILE_OUTPUT_DIR.
  --manifest=<path>   Explicit manifest path.

Example:
  dart run bin/summarize_profile_baselines.dart \
    --run-id=2026-06-11-macos-reference-repeat5
''');
}
