import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:tagflow_benchmarks/src/io/package_paths.dart';
import 'package:tagflow_benchmarks/src/profile/profile_baseline_runner.dart';

Future<void> main(List<String> arguments) async {
  if (arguments.contains('--help') || arguments.contains('-h')) {
    _printUsage();
    return;
  }

  final options = _ProfileBaselineCliOptions.parse(arguments);
  final workspaceRoot = resolveWorkspaceRoot();
  final outputDirectory = Directory(
    p.isAbsolute(options.outputDirectory)
        ? options.outputDirectory
        : p.join(workspaceRoot.path, options.outputDirectory),
  );

  final runner = ProfileBaselineRunner(
    workspaceRoot: workspaceRoot,
    outputDirectory: outputDirectory,
    renderers: options.renderers,
    fixtures: options.fixtures,
    repeatCount: options.repeatCount,
    runId: options.runId ?? defaultProfileBaselineRunId(),
    device: options.device,
    failFast: !options.continueOnFailure,
  );

  final manifest = await runner.run();
  stdout.writeln(const JsonEncoder.withIndent('  ').convert(manifest.toJson()));
}

final class _ProfileBaselineCliOptions {
  const _ProfileBaselineCliOptions({
    required this.renderers,
    required this.fixtures,
    required this.repeatCount,
    required this.device,
    required this.outputDirectory,
    required this.continueOnFailure,
    this.runId,
  });

  factory _ProfileBaselineCliOptions.parse(List<String> arguments) {
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

    return _ProfileBaselineCliOptions(
      renderers: _csv(
        values['renderer'] ?? Platform.environment['TAGFLOW_RENDERER'],
        defaultProfileBaselineRenderers,
      ),
      fixtures: _csv(
        values['fixture'] ?? Platform.environment['TAGFLOW_FIXTURE'],
        defaultProfileBaselineFixtures,
      ),
      repeatCount: _positiveInt(
        values['repeat'] ?? Platform.environment['TAGFLOW_PROFILE_REPEAT'],
        defaultValue: 3,
      ),
      device:
          values['device'] ??
          Platform.environment['TAGFLOW_PROFILE_DEVICE'] ??
          'macos',
      outputDirectory:
          values['output-dir'] ??
          Platform.environment['TAGFLOW_PROFILE_OUTPUT_DIR'] ??
          p.join('build', 'benchmarks', 'profile'),
      continueOnFailure: _boolFlag(
        values['continue-on-failure'] ??
            Platform.environment['TAGFLOW_PROFILE_CONTINUE_ON_FAILURE'],
      ),
      runId: values['run-id'],
    );
  }

  final List<String> renderers;
  final List<String> fixtures;
  final int repeatCount;
  final String device;
  final String outputDirectory;
  final bool continueOnFailure;
  final String? runId;

  static List<String> _csv(String? value, List<String> fallback) {
    if (value == null || value.trim().isEmpty || value == 'all') {
      return List<String>.unmodifiable(fallback);
    }

    final parsed = value
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList(growable: false);

    if (parsed.isEmpty) {
      throw const FormatException('CSV option must not be empty.');
    }
    return List<String>.unmodifiable(parsed);
  }

  static int _positiveInt(String? value, {required int defaultValue}) {
    if (value == null) {
      return defaultValue;
    }

    final parsed = int.tryParse(value);
    if (parsed == null || parsed < 1) {
      throw FormatException('Expected a positive integer, got: $value');
    }
    return parsed;
  }

  static bool _boolFlag(String? value) {
    if (value == null) {
      return false;
    }
    final normalized = value.trim().toLowerCase();
    return normalized == 'true' || normalized == '1' || normalized == 'yes';
  }
}

void _printUsage() {
  stdout.writeln(r'''
Runs repeated profile-mode benchmark baselines.

Usage:
  dart run bin/run_profile_baselines.dart [options]

Options:
  --renderer=<ids>    Comma-separated renderer ids, or all.
  --fixture=<ids>     Comma-separated fixture ids, or all.
  --repeat=<count>    Repeats per renderer/fixture pair. Defaults to 3.
  --device=<id>       Flutter device id. Defaults to macos.
  --output-dir=<path> Output directory. Defaults to build/benchmarks/profile.
                      Also accepts TAGFLOW_PROFILE_OUTPUT_DIR.
  --run-id=<id>       Optional stable run id for deterministic artifact paths.
  --continue-on-failure=true
                    Keep running the selected matrix and write failed runs to
                    the manifest instead of failing on the first process error.

Example:
  TAGFLOW_RENDERER=tagflow \
  TAGFLOW_FIXTURE=ai_answer_rich \
  TAGFLOW_PROFILE_REPEAT=1 \
  TAGFLOW_PROFILE_CONTINUE_ON_FAILURE=true \
    dart run melos run benchmark:profile:baselines
''');
}
