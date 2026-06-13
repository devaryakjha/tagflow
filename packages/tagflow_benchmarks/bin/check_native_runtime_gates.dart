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
    final expectedOpenGateIds = options.expectProfileOpenGates
        ? result.profile.expectedOpenGateIds
        : options.expectedOpenGateIds;
    final expectationPassed = _expectationPassed(
      result: result,
      expectedOpenGateIds: expectedOpenGateIds,
    );
    final json = result.toJson();
    if (expectedOpenGateIds != null) {
      json.addAll(<String, Object?>{
        'expectedOpenGateIds': expectedOpenGateIds,
        'expectationPassed': expectationPassed,
      });
    }

    stdout.writeln(const JsonEncoder.withIndent('  ').convert(json));
    exitCode = expectationPassed ? 0 : 1;
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
  final expectedOpenGateIds = _readExpectedOpenGateIds(
    values['expect-open-gates'] ??
        Platform.environment['TAGFLOW_NATIVE_RUNTIME_EXPECT_OPEN_GATES'],
  );
  final expectProfileOpenGates = _readBoolFlag(
    values['expect-profile-open-gates'] ??
        Platform
            .environment['TAGFLOW_NATIVE_RUNTIME_EXPECT_PROFILE_OPEN_GATES'],
    label: '--expect-profile-open-gates',
  );
  if (expectedOpenGateIds != null && expectProfileOpenGates) {
    throw const FormatException(
      'Use either --expect-open-gates or --expect-profile-open-gates, '
      'not both.',
    );
  }

  return _CheckNativeRuntimeGatesOptions(
    manifestFile: File(resolvedManifestPath),
    profileId: profileId,
    expectedOpenGateIds: expectedOpenGateIds,
    expectProfileOpenGates: expectProfileOpenGates,
  );
}

List<String>? _readExpectedOpenGateIds(String? value) {
  if (value == null) {
    return null;
  }

  final gateIds = value
      .split(',')
      .map((entry) => entry.trim())
      .where((entry) => entry.isNotEmpty)
      .toList(growable: false);
  if (gateIds.isEmpty) {
    throw const FormatException(
      '--expect-open-gates must contain at least one gate id when provided.',
    );
  }

  return gateIds;
}

bool _readBoolFlag(String? value, {required String label}) {
  if (value == null) {
    return false;
  }

  return switch (value.trim().toLowerCase()) {
    '1' || 'true' || 'yes' => true,
    '0' || 'false' || 'no' => false,
    _ => throw FormatException('$label must be true or false when provided.'),
  };
}

bool _expectationPassed({
  required NativeRuntimeGateStatusCheckResult result,
  required List<String>? expectedOpenGateIds,
}) {
  if (expectedOpenGateIds == null) {
    return result.passed;
  }

  final requiredOpenGateIds = result.requiredOpenGates
      .map((gate) => gate.id)
      .toList(growable: false);
  if (!_sameOrderedValues(requiredOpenGateIds, expectedOpenGateIds)) {
    return false;
  }

  final expectedOpenGateIdSet = expectedOpenGateIds.toSet();
  return result.issues.every((issue) {
    if (issue.code != 'required_gate_not_satisfied') {
      return false;
    }

    return expectedOpenGateIdSet.contains(issue.details['gateId']);
  });
}

bool _sameOrderedValues(List<String> actual, List<String> expected) {
  if (actual.length != expected.length) {
    return false;
  }

  for (var index = 0; index < actual.length; index += 1) {
    if (actual[index] != expected[index]) {
      return false;
    }
  }

  return true;
}

void _printUsage({IOSink? to}) {
  (to ?? stdout).writeln(r'''
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
  --expect-open-gates=<ids>
                     Comma-separated required-open gate ids expected for this
                     profile. When provided, exits 0 only if the profile fails
                     exactly on those required gates and has no other issues.
                     Also accepts TAGFLOW_NATIVE_RUNTIME_EXPECT_OPEN_GATES.
  --expect-profile-open-gates=<true|false>
                     Use the selected profile's expectedOpenGateIds metadata
                     for expected-open verification. Mutually exclusive with
                     --expect-open-gates. Also accepts
                     TAGFLOW_NATIVE_RUNTIME_EXPECT_PROFILE_OPEN_GATES.

Examples:
  dart run bin/check_native_runtime_gates.dart --profile=pr72-draft
  dart run bin/check_native_runtime_gates.dart --profile=pr72-ready
  dart run bin/check_native_runtime_gates.dart \\
    --profile=beta-preapproval \\
    --expect-profile-open-gates=true
''');
}

final class _CheckNativeRuntimeGatesOptions {
  const _CheckNativeRuntimeGatesOptions({
    required this.manifestFile,
    required this.profileId,
    required this.expectedOpenGateIds,
    required this.expectProfileOpenGates,
  });

  final File manifestFile;
  final String profileId;
  final List<String>? expectedOpenGateIds;
  final bool expectProfileOpenGates;
}
