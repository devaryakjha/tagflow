import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:tagflow_benchmarks/src/io/package_paths.dart';
import 'package:tagflow_benchmarks/src/profile/memory_evidence_exporter.dart';

Future<void> main(List<String> arguments) async {
  if (arguments.contains('--help') || arguments.contains('-h')) {
    _printUsage();
    return;
  }

  try {
    final workspaceRoot = resolveWorkspaceRoot();
    final options = _parseOptions(arguments, workspaceRoot: workspaceRoot);
    final result = await exportMemoryEvidence(options);
    stdout.writeln(const JsonEncoder.withIndent('  ').convert(result.toJson()));
  } on FormatException catch (error) {
    stderr.writeln(error.message);
    _printUsage(to: stderr);
    exitCode = 64;
  } on Object catch (error) {
    stderr.writeln(error);
    exitCode = 1;
  }
}

MemoryEvidenceExportOptions _parseOptions(
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

  final vmServiceUri = values['vm-service-uri'];
  if (vmServiceUri == null || vmServiceUri.trim().isEmpty) {
    throw const FormatException('Provide --vm-service-uri=<uri>.');
  }

  final checkpoint = values['checkpoint'];
  if (checkpoint == null || checkpoint.trim().isEmpty) {
    throw const FormatException('Provide --checkpoint=<name>.');
  }

  final outputDirectory =
      values['output-dir'] ??
      Platform.environment['TAGFLOW_MEMORY_EVIDENCE_OUTPUT_DIR'] ??
      p.join('build', 'benchmarks', 'profile-memory-evidence', 'manual');

  final topClasses = int.tryParse(values['top-classes'] ?? '30');
  if (topClasses == null || topClasses < 1) {
    throw const FormatException('--top-classes must be an integer >= 1.');
  }

  final retainingPathSampleLimit = int.tryParse(
    values['retaining-path-sample-limit'] ?? '1',
  );
  if (retainingPathSampleLimit == null || retainingPathSampleLimit < 1) {
    throw const FormatException(
      '--retaining-path-sample-limit must be an integer >= 1.',
    );
  }

  final retainingPathLimit = int.tryParse(
    values['retaining-path-limit'] ?? '20',
  );
  if (retainingPathLimit == null || retainingPathLimit < 1) {
    throw const FormatException(
      '--retaining-path-limit must be an integer >= 1.',
    );
  }

  return MemoryEvidenceExportOptions(
    vmServiceUri: Uri.parse(vmServiceUri),
    outputDirectory: Directory(
      p.isAbsolute(outputDirectory)
          ? outputDirectory
          : p.join(workspaceRoot.path, outputDirectory),
    ),
    checkpoint: checkpoint,
    isolateId: values['isolate-id'],
    topClasses: topClasses,
    gc: _parseBool(values['gc'] ?? 'true', optionName: '--gc'),
    retainingPathClassTargets: normalizeRetainingPathClassTargets([
      if (values['retaining-path-classes'] != null)
        values['retaining-path-classes']!,
      if (Platform.environment['TAGFLOW_MEMORY_EVIDENCE_RETAINING_CLASSES']
          case final retainingClasses?)
        retainingClasses,
    ]),
    retainingPathSampleLimit: retainingPathSampleLimit,
    retainingPathLimit: retainingPathLimit,
  );
}

bool _parseBool(String value, {required String optionName}) {
  switch (value.trim().toLowerCase()) {
    case 'true':
    case '1':
    case 'yes':
      return true;
    case 'false':
    case '0':
    case 'no':
      return false;
  }
  throw FormatException('$optionName must be true or false.');
}

void _printUsage({IOSink? to}) {
  (to ?? stdout).writeln(r'''
Exports report-only memory evidence from a live VM service URI.

Usage:
  dart run bin/export_memory_evidence.dart \
    --vm-service-uri=<uri> \
    --checkpoint=<name> \
    [--output-dir=<path>] \
    [--isolate-id=<id-or-name>] \
    [--top-classes=<n>] \
    [--gc=true|false] \
    [--retaining-path-classes=<ClassName[,OtherClass]>] \
    [--retaining-path-sample-limit=<n>] \
    [--retaining-path-limit=<n>]

The target VM service must still be live. Use this against a profile hold-open
run and one checkpoint listed in memory-evidence-manifest.json.

Outputs:
  <checkpoint>-allocation-profile.json
  <checkpoint>-heap-summary.json
  <checkpoint>-retaining-paths.json, when retained-path classes are requested

These files are review inputs. They do not replace human retained-object
interpretation, and they should stay under ignored build/ output.
''');
}
