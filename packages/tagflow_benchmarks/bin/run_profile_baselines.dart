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
    profileMemory: options.profileMemory,
    profileHoldOpen: options.profileHoldOpen,
    profileHoldOpenSeconds: options.profileHoldOpenSeconds,
    runTimeout: options.runTimeout,
    profileViewportConfiguration: options.profileViewportConfiguration,
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
  --profile-memory=true
                    Request a per-cell flutter drive --profile-memory JSON.
                    Also accepts TAGFLOW_PROFILE_MEMORY.
  --profile-hold-open=true
                    Replay named benchmark checkpoints after measurement and
                    keep each one alive for DevTools attachment.
                    Also accepts TAGFLOW_PROFILE_HOLD_OPEN.
  --profile-hold-open-seconds=<count>
                    Hold each checkpoint open for the given number of seconds.
                    Also accepts TAGFLOW_PROFILE_HOLD_OPEN_SECONDS.
  --run-timeout-seconds=<count>
                    Optional wall-clock timeout for each profile repeat.
                    Timed-out repeats exit 124 and are recorded as timedOut.
                    Also accepts TAGFLOW_PROFILE_RUN_TIMEOUT_SECONDS.
  --profile-viewport-mode=<mode>
                    Viewport mode: observed_host or synthetic.
                    Also accepts TAGFLOW_PROFILE_VIEWPORT_MODE.
  --profile-synthetic-logical-size=<width>x<height>
                    Synthetic logical viewport size, required in synthetic mode.
                    Also accepts TAGFLOW_PROFILE_SYNTHETIC_LOGICAL_SIZE.
  --profile-synthetic-device-pixel-ratio=<number>
                    Synthetic device-pixel ratio, required in synthetic mode.
                    Also accepts TAGFLOW_PROFILE_SYNTHETIC_DEVICE_PIXEL_RATIO.

Example:
  TAGFLOW_RENDERER=tagflow \
  TAGFLOW_FIXTURE=ai_answer_rich \
  TAGFLOW_PROFILE_REPEAT=1 \
  TAGFLOW_PROFILE_CONTINUE_ON_FAILURE=true \
  TAGFLOW_PROFILE_HOLD_OPEN=true \
    dart run melos run benchmark:profile:baselines
''');
}
