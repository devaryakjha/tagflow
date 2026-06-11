import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:tagflow_benchmarks/src/io/package_paths.dart';
import 'package:tagflow_benchmarks/src/profile/profile_baseline_cli_options.dart';
import 'package:tagflow_benchmarks/src/profile/profile_baseline_runner.dart';

Future<void> main(List<String> arguments) async {
  if (arguments.contains('--help') || arguments.contains('-h')) {
    _printUsage();
    return;
  }

  final options = ProfileBaselineCliOptions.parse(arguments);
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
    pairs: options.pairs,
    repeatCount: options.repeatCount,
    runId: options.runId ?? defaultProfileBaselineRunId(),
    device: options.device,
    failFast: !options.continueOnFailure,
  );

  final manifest = await runner.run();
  stdout.writeln(const JsonEncoder.withIndent('  ').convert(manifest.toJson()));
}

void _printUsage() {
  stdout.writeln(r'''
Runs repeated profile-mode benchmark baselines.

Usage:
  dart run bin/run_profile_baselines.dart [options]

Options:
  --renderer=<ids>    Comma-separated renderer ids, or all.
  --fixture=<ids>     Comma-separated fixture ids, or all.
  --pair=<pairs>      Comma-separated renderer:fixture cells. When set, runs
                      exactly these cells in order instead of a cross-product.
                      Also accepts TAGFLOW_PROFILE_PAIR.
  --repeat=<count>    Repeats per renderer/fixture pair. Defaults to 3.
  --device=<id>       Flutter device id. Defaults to macos.
  --output-dir=<path> Output directory. Defaults to build/benchmarks/profile.
                      Also accepts TAGFLOW_PROFILE_OUTPUT_DIR.
  --run-id=<id>       Optional stable run id for deterministic artifact paths.
                      Also accepts TAGFLOW_PROFILE_RUN_ID.
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
