import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:tagflow_benchmarks/src/io/package_paths.dart';
import 'package:tagflow_benchmarks/src/profile/profile_baseline_check.dart';

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
    final result = checkProfileBaselineSummary(
      summaryFile: options.summaryFile,
      minRepeats: options.minRepeats,
    );

    stdout.writeln(const JsonEncoder.withIndent('  ').convert(result.toJson()));
    exitCode = result.passed ? 0 : 1;
  } on FormatException catch (error) {
    stderr.writeln(error.message);
    _printUsage(to: stderr);
    exitCode = 64;
  }
}

_CheckProfileBaselineOptions _parseOptions({
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

  final minRepeats = int.tryParse(values['min-repeats'] ?? '1');
  if (minRepeats == null || minRepeats < 1) {
    throw const FormatException('--min-repeats must be an integer >= 1.');
  }

  return _CheckProfileBaselineOptions(
    summaryFile: _resolveSummaryFile(values, workspaceRoot),
    minRepeats: minRepeats,
  );
}

File _resolveSummaryFile(Map<String, String> values, Directory workspaceRoot) {
  if (values.containsKey('summary')) {
    final summary = values['summary']!;
    return File(
      p.isAbsolute(summary) ? summary : p.join(workspaceRoot.path, summary),
    );
  }

  final runId = values['run-id'];
  if (runId == null || runId.trim().isEmpty) {
    throw const FormatException('Provide --summary=<path> or --run-id=<id>.');
  }

  final outputDirectory =
      values['output-dir'] ??
      Platform.environment['TAGFLOW_PROFILE_OUTPUT_DIR'] ??
      p.join('build', 'benchmarks', 'profile');
  final resolvedOutputDirectory = p.isAbsolute(outputDirectory)
      ? outputDirectory
      : p.join(workspaceRoot.path, outputDirectory);

  return File(
    p.join(resolvedOutputDirectory, runId, 'profile-baseline-summary.json'),
  );
}

void _printUsage({IOSink? to}) {
  (to ?? stdout).writeln(r'''
Checks a collected profile baseline summary for collection completeness.

Usage:
  dart run bin/check_profile_baseline.dart [options]

Options:
  --run-id=<id>        Baseline run id under the output directory.
  --output-dir=<path>  Output directory. Defaults to build/benchmarks/profile.
                       Also accepts TAGFLOW_PROFILE_OUTPUT_DIR.
  --summary=<path>     Explicit profile-baseline-summary.json path.
  --min-repeats=<n>    Minimum successful repeats per cell. Defaults to 1.

Example:
  dart run bin/check_profile_baseline.dart \
    --run-id=2026-06-11-macos-reference-repeat5 \
    --min-repeats=5
''');
}

final class _CheckProfileBaselineOptions {
  const _CheckProfileBaselineOptions({
    required this.summaryFile,
    required this.minRepeats,
  });

  final File summaryFile;
  final int minRepeats;
}
