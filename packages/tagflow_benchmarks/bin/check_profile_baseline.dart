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
      expectedViewport: options.expectedViewport,
      policy: options.policy,
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

  final policy = _readPolicy(values, workspaceRoot);
  final minRepeats = int.tryParse(
    values['min-repeats'] ?? policy?.minRepeats.toString() ?? '1',
  );
  if (minRepeats == null || minRepeats < 1) {
    throw const FormatException('--min-repeats must be an integer >= 1.');
  }

  return _CheckProfileBaselineOptions(
    summaryFile: _resolveSummaryFile(values, workspaceRoot),
    minRepeats: minRepeats,
    expectedViewport: _parseExpectedViewport(
      values,
      fallback: policy?.expectedViewport,
    ),
    policy: policy,
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
Checks a collected profile baseline summary for collection completeness and
optional viewport environment invariants.

Usage:
  dart run bin/check_profile_baseline.dart [options]

Options:
  --run-id=<id>        Baseline run id under the output directory.
  --output-dir=<path>  Output directory. Defaults to build/benchmarks/profile.
                       Also accepts TAGFLOW_PROFILE_OUTPUT_DIR.
  --summary=<path>     Explicit profile-baseline-summary.json path.
  --policy=<path>      Optional report-only checker policy JSON path.
                       Also accepts TAGFLOW_PROFILE_CHECK_POLICY.
  --min-repeats=<n>    Minimum successful repeats per cell. Defaults to 1.
                       Overrides policy check.minRepeats when provided.
  --expected-logical-size=<w>x<h>
                       Expected logical viewport size for every successful
                       cell. Must be used with --expected-device-pixel-ratio.
                       Also accepts TAGFLOW_PROFILE_EXPECTED_LOGICAL_SIZE.
  --expected-device-pixel-ratio=<value>
                       Expected device-pixel ratio for every successful cell.
                       Must be used with --expected-logical-size.
                       Also accepts
                       TAGFLOW_PROFILE_EXPECTED_DEVICE_PIXEL_RATIO.
                       Expected viewport flags override policy values.

Example:
  dart run bin/check_profile_baseline.dart \
    --run-id=2026-06-11-macos-reference-repeat5 \
    --policy=../../docs/benchmarks/policies/profile-reference-runner-policy.json
''');
}

final class _CheckProfileBaselineOptions {
  const _CheckProfileBaselineOptions({
    required this.summaryFile,
    required this.minRepeats,
    required this.expectedViewport,
    required this.policy,
  });

  final File summaryFile;
  final int minRepeats;
  final ProfileBaselineExpectedViewport? expectedViewport;
  final ProfileBaselineCheckPolicy? policy;
}

ProfileBaselineExpectedViewport? _parseExpectedViewport(
  Map<String, String> values, {
  ProfileBaselineExpectedViewport? fallback,
}) {
  final expectedLogicalSize =
      values['expected-logical-size'] ??
      Platform.environment['TAGFLOW_PROFILE_EXPECTED_LOGICAL_SIZE'];
  final expectedDevicePixelRatio =
      values['expected-device-pixel-ratio'] ??
      Platform.environment['TAGFLOW_PROFILE_EXPECTED_DEVICE_PIXEL_RATIO'];

  if (expectedLogicalSize == null && expectedDevicePixelRatio == null) {
    return fallback;
  }

  if (expectedLogicalSize == null || expectedDevicePixelRatio == null) {
    throw const FormatException(
      'Provide both --expected-logical-size=<w>x<h> and '
      '--expected-device-pixel-ratio=<value>.',
    );
  }

  final sizePattern = RegExp(
    r'^\s*(\d+(?:\.\d+)?)x(\d+(?:\.\d+)?)\s*$',
    caseSensitive: false,
  );
  final match = sizePattern.firstMatch(expectedLogicalSize);
  if (match == null) {
    throw const FormatException(
      '--expected-logical-size must be formatted as <width>x<height>.',
    );
  }

  final logicalWidth = double.parse(match.group(1)!);
  final logicalHeight = double.parse(match.group(2)!);
  final devicePixelRatio = double.tryParse(expectedDevicePixelRatio);

  if (logicalWidth <= 0 || logicalHeight <= 0) {
    throw const FormatException(
      '--expected-logical-size values must be greater than 0.',
    );
  }

  if (devicePixelRatio == null || devicePixelRatio <= 0) {
    throw const FormatException(
      '--expected-device-pixel-ratio must be a number greater than 0.',
    );
  }

  return ProfileBaselineExpectedViewport(
    logicalWidth: logicalWidth,
    logicalHeight: logicalHeight,
    devicePixelRatio: devicePixelRatio,
  );
}

ProfileBaselineCheckPolicy? _readPolicy(
  Map<String, String> values,
  Directory workspaceRoot,
) {
  final policyPath =
      values['policy'] ?? Platform.environment['TAGFLOW_PROFILE_CHECK_POLICY'];
  if (policyPath == null || policyPath.trim().isEmpty) {
    return null;
  }

  final resolvedPath = p.isAbsolute(policyPath)
      ? policyPath
      : p.join(workspaceRoot.path, policyPath);
  return ProfileBaselineCheckPolicy.fromFile(File(resolvedPath));
}
