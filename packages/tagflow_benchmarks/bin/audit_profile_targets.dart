import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:tagflow_benchmarks/src/io/package_paths.dart';
import 'package:tagflow_benchmarks/src/profile/target_availability_audit.dart';

Future<void> main(List<String> arguments) async {
  if (arguments.contains('--help') || arguments.contains('-h')) {
    _printUsage();
    return;
  }

  try {
    final workspaceRoot = resolveWorkspaceRoot();
    final options = _parseOptions(arguments, workspaceRoot: workspaceRoot);
    final auditor = TargetAvailabilityAuditor(
      workspaceRoot: workspaceRoot,
      outputDirectory: options.outputDirectory,
      runId: options.runId,
    );
    final result = await auditor.run();
    stdout.writeln(const JsonEncoder.withIndent('  ').convert(result.toJson()));

    if (options.requireCredibleTarget && !result.canRunPhysicalProfileProbe) {
      exitCode = 2;
    }
  } on FormatException catch (error) {
    stderr.writeln(error.message);
    _printUsage(to: stderr);
    exitCode = 64;
  }
}

_TargetAuditCliOptions _parseOptions(
  List<String> arguments, {
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

  final outputDirectory =
      values['output-dir'] ??
      Platform.environment['TAGFLOW_TARGET_AUDIT_OUTPUT_DIR'] ??
      p.join('build', 'benchmarks', 'target-availability');
  final resolvedOutputDirectory = p.isAbsolute(outputDirectory)
      ? outputDirectory
      : p.join(workspaceRoot.path, outputDirectory);

  final requireCredibleTarget = _parseBool(
    values['require-credible-target'] ??
        Platform.environment['TAGFLOW_TARGET_AUDIT_REQUIRE_CREDIBLE_TARGET'] ??
        'false',
    name: '--require-credible-target',
  );

  return _TargetAuditCliOptions(
    outputDirectory: Directory(resolvedOutputDirectory),
    runId:
        values['run-id'] ??
        Platform.environment['TAGFLOW_TARGET_AUDIT_RUN_ID'] ??
        defaultTargetAvailabilityRunId(),
    requireCredibleTarget: requireCredibleTarget,
  );
}

bool _parseBool(String value, {required String name}) {
  final normalized = value.trim().toLowerCase();
  return switch (normalized) {
    'true' || '1' || 'yes' || 'y' => true,
    'false' || '0' || 'no' || 'n' => false,
    _ => throw FormatException('$name must be true or false.'),
  };
}

void _printUsage({IOSink? to}) {
  (to ?? stdout).writeln('''
Audits whether this machine has a credible physical target for Tagflow profile
benchmark probes.

Usage:
  dart run bin/audit_profile_targets.dart [options]

Options:
  --run-id=<id>       Optional stable run id for deterministic artifact paths.
                      Also accepts TAGFLOW_TARGET_AUDIT_RUN_ID.
  --output-dir=<path> Output directory. Defaults to
                      build/benchmarks/target-availability.
                      Also accepts TAGFLOW_TARGET_AUDIT_OUTPUT_DIR.
  --require-credible-target=true
                      Exit with code 2 when no credible physical profile target
                      is available. Defaults to false.
                      Also accepts
                      TAGFLOW_TARGET_AUDIT_REQUIRE_CREDIBLE_TARGET.

The command writes:
  <output-dir>/<run-id>/target-availability-audit.json

The audit is a preflight gate. It does not run profile benchmarks and does not
support performance claims by itself.
''');
}

final class _TargetAuditCliOptions {
  const _TargetAuditCliOptions({
    required this.outputDirectory,
    required this.runId,
    required this.requireCredibleTarget,
  });

  final Directory outputDirectory;
  final String runId;
  final bool requireCredibleTarget;
}
