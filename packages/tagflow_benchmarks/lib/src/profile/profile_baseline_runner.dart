import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

/// Default profile benchmark renderer matrix.
const List<String> defaultProfileBaselineRenderers = [
  'tagflow',
  'flutter_html',
  'flutter_widget_from_html',
];

/// Default profile benchmark fixture matrix.
const List<String> defaultProfileBaselineFixtures = [
  'ai_answer_rich',
  'table_dense',
  'large_article',
  'table_stress',
];

/// Options passed to a profile benchmark process invocation.
final class ProfileProcessOptions {
  /// Creates process invocation options.
  const ProfileProcessOptions({
    required this.workingDirectory,
    required this.environment,
  });

  /// Working directory for the spawned process.
  final String workingDirectory;

  /// Environment overrides for the spawned process.
  final Map<String, String> environment;
}

/// Runs one profile benchmark process.
typedef ProfileProcessRunner =
    Future<ProcessResult> Function(
      String executable,
      List<String> arguments,
      ProfileProcessOptions options,
    );

/// Profile baseline manifest written after a matrix run.
final class ProfileBaselineManifest {
  /// Creates a profile baseline manifest.
  const ProfileBaselineManifest({
    required this.runId,
    required this.generatedAt,
    required this.environment,
    required this.device,
    required this.repeatCount,
    required this.renderers,
    required this.fixtures,
    required this.command,
    required this.outputDirectory,
    required this.sourceResponsePath,
    required this.runs,
  });

  /// Stable id used as the output folder name.
  final String runId;

  /// UTC manifest generation time.
  final DateTime generatedAt;

  /// Host and toolchain fields for this profile baseline run.
  final ProfileBaselineEnvironment environment;

  /// Flutter device id passed to the profile harness.
  final String device;

  /// Number of repeats per renderer/fixture pair.
  final int repeatCount;

  /// Renderer ids included in this run.
  final List<String> renderers;

  /// Fixture ids included in this run.
  final List<String> fixtures;

  /// Existing Melos command reused by each matrix cell.
  final List<String> command;

  /// Directory where the raw response artifacts and manifest were written.
  final String outputDirectory;

  /// Existing integration-test response path copied after each run.
  final String sourceResponsePath;

  /// Individual run records.
  final List<ProfileBaselineRun> runs;

  /// Converts this manifest to machine-readable JSON.
  Map<String, Object?> toJson() => <String, Object?>{
    'runId': runId,
    'generatedAt': generatedAt.toUtc().toIso8601String(),
    'environment': environment.toJson(),
    'device': device,
    'repeatCount': repeatCount,
    'renderers': renderers,
    'fixtures': fixtures,
    'command': command,
    'outputDirectory': outputDirectory,
    'sourceResponsePath': sourceResponsePath,
    'runs': runs.map((run) => run.toJson()).toList(),
  };
}

/// Host and toolchain fields recorded with a profile baseline manifest.
final class ProfileBaselineEnvironment {
  /// Creates profile baseline environment metadata.
  const ProfileBaselineEnvironment({
    required this.tagflowVersion,
    required this.dartVersion,
    required this.flutterVersion,
    required this.hostOs,
    required this.hostOsVersion,
    required this.gitCommit,
  });

  /// Version from `packages/tagflow/pubspec.yaml`.
  final String tagflowVersion;

  /// Dart SDK version used to launch the runner.
  final String dartVersion;

  /// Flutter SDK version from `FLUTTER_VERSION`, when provided.
  final String flutterVersion;

  /// Host operating system id.
  final String hostOs;

  /// Host operating system version string.
  final String hostOsVersion;

  /// Git commit checked out for this run, or `unknown`.
  final String gitCommit;

  /// Converts this environment metadata to machine-readable JSON.
  Map<String, Object?> toJson() => <String, Object?>{
    'tagflowVersion': tagflowVersion,
    'dartVersion': dartVersion,
    'flutterVersion': flutterVersion,
    'hostOs': hostOs,
    'hostOsVersion': hostOsVersion,
    'gitCommit': gitCommit,
  };
}

/// One profile benchmark run record.
final class ProfileBaselineRun {
  /// Creates a profile benchmark run record.
  const ProfileBaselineRun({
    required this.renderer,
    required this.fixture,
    required this.repeat,
    required this.exitCode,
    required this.artifactPath,
    required this.startedAt,
    required this.finishedAt,
  });

  /// Renderer id used for the run.
  final String renderer;

  /// Fixture id used for the run.
  final String fixture;

  /// One-based repeat index.
  final int repeat;

  /// Process exit code.
  final int exitCode;

  /// Copied raw integration-test JSON artifact path.
  final String artifactPath;

  /// UTC start time.
  final DateTime startedAt;

  /// UTC finish time.
  final DateTime finishedAt;

  /// Converts this run record to machine-readable JSON.
  Map<String, Object?> toJson() => <String, Object?>{
    'renderer': renderer,
    'fixture': fixture,
    'repeat': repeat,
    'exitCode': exitCode,
    'artifactPath': artifactPath,
    'startedAt': startedAt.toUtc().toIso8601String(),
    'finishedAt': finishedAt.toUtc().toIso8601String(),
  };
}

/// Runs repeated profile baselines through the existing Melos profile command.
final class ProfileBaselineRunner {
  /// Creates a profile baseline runner.
  ProfileBaselineRunner({
    required this.workspaceRoot,
    required this.outputDirectory,
    required this.renderers,
    required this.fixtures,
    required this.repeatCount,
    required this.runId,
    this.device = 'macos',
    ProfileProcessRunner? processRunner,
    DateTime Function()? clock,
  }) : _processRunner = processRunner ?? _defaultProcessRunner,
       _clock = clock ?? DateTime.now {
    if (repeatCount < 1) {
      throw ArgumentError.value(
        repeatCount,
        'repeatCount',
        'Repeat count must be at least 1.',
      );
    }
    if (renderers.isEmpty) {
      throw ArgumentError.value(renderers, 'renderers', 'Cannot be empty.');
    }
    if (fixtures.isEmpty) {
      throw ArgumentError.value(fixtures, 'fixtures', 'Cannot be empty.');
    }
  }

  /// Workspace root containing the Melos configuration.
  final Directory workspaceRoot;

  /// Parent directory for profile benchmark outputs.
  final Directory outputDirectory;

  /// Renderer ids to benchmark.
  final List<String> renderers;

  /// Fixture ids to benchmark.
  final List<String> fixtures;

  /// Number of repeats per renderer/fixture pair.
  final int repeatCount;

  /// Stable id for this run, also used in artifact paths.
  final String runId;

  /// Flutter device id.
  final String device;

  final ProfileProcessRunner _processRunner;
  final DateTime Function() _clock;

  static const List<String> _command = [
    'run',
    'melos',
    'run',
    'benchmark:profile',
  ];

  /// Runs the selected profile matrix and writes a manifest.
  Future<ProfileBaselineManifest> run() async {
    final runDirectory = Directory(p.join(outputDirectory.path, runId))
      ..createSync(recursive: true);
    final sourceResponse = _sourceResponseFile;
    final runs = <ProfileBaselineRun>[];

    for (final renderer in renderers) {
      for (final fixture in fixtures) {
        for (var repeat = 1; repeat <= repeatCount; repeat += 1) {
          if (sourceResponse.existsSync()) {
            sourceResponse.deleteSync();
          }

          final startedAt = _clock().toUtc();
          final result = await _processRunner(
            'dart',
            _command,
            ProfileProcessOptions(
              workingDirectory: workspaceRoot.path,
              environment: <String, String>{
                'TAGFLOW_RENDERER': renderer,
                'TAGFLOW_FIXTURE': fixture,
                'TAGFLOW_PROFILE_DEVICE': device,
              },
            ),
          );
          final finishedAt = _clock().toUtc();

          if (result.exitCode != 0) {
            throw ProcessException(
              'dart',
              _command,
              '${result.stderr}\n${result.stdout}'.trim(),
              result.exitCode,
            );
          }
          if (!sourceResponse.existsSync()) {
            throw StateError(
              'Profile benchmark completed but did not write '
              '${sourceResponse.path}.',
            );
          }

          final artifact = File(
            p.join(
              runDirectory.path,
              renderer,
              fixture,
              'repeat-${repeat.toString().padLeft(2, '0')}.json',
            ),
          );
          artifact.parent.createSync(recursive: true);
          sourceResponse.copySync(artifact.path);

          runs.add(
            ProfileBaselineRun(
              renderer: renderer,
              fixture: fixture,
              repeat: repeat,
              exitCode: result.exitCode,
              artifactPath: p.relative(artifact.path, from: workspaceRoot.path),
              startedAt: startedAt,
              finishedAt: finishedAt,
            ),
          );
        }
      }
    }

    final manifest = ProfileBaselineManifest(
      runId: runId,
      generatedAt: _clock().toUtc(),
      environment: _detectEnvironment(workspaceRoot),
      device: device,
      repeatCount: repeatCount,
      renderers: List<String>.unmodifiable(renderers),
      fixtures: List<String>.unmodifiable(fixtures),
      command: _command,
      outputDirectory: p.relative(runDirectory.path, from: workspaceRoot.path),
      sourceResponsePath: p.relative(
        sourceResponse.path,
        from: workspaceRoot.path,
      ),
      runs: List<ProfileBaselineRun>.unmodifiable(runs),
    );

    File(
      p.join(runDirectory.path, 'profile-baseline-manifest.json'),
    ).writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(manifest.toJson())}\n',
    );

    return manifest;
  }

  File get _sourceResponseFile => File(
    p.join(
      workspaceRoot.path,
      'examples',
      'tagflow',
      'build',
      'integration_response_data.json',
    ),
  );
}

ProfileBaselineEnvironment _detectEnvironment(Directory workspaceRoot) {
  return ProfileBaselineEnvironment(
    tagflowVersion: _readTagflowVersion(workspaceRoot),
    dartVersion: Platform.version.split(' ').first,
    flutterVersion: Platform.environment['FLUTTER_VERSION'] ?? 'unknown',
    hostOs: Platform.operatingSystem,
    hostOsVersion: Platform.operatingSystemVersion,
    gitCommit: _readGitCommit(workspaceRoot),
  );
}

String _readTagflowVersion(Directory workspaceRoot) {
  final pubspec = File(
    p.join(workspaceRoot.path, 'packages', 'tagflow', 'pubspec.yaml'),
  );
  if (!pubspec.existsSync()) {
    return 'unknown';
  }

  for (final line in pubspec.readAsLinesSync()) {
    if (line.startsWith('version: ')) {
      return line.replaceFirst('version: ', '').trim();
    }
  }
  return 'unknown';
}

String _readGitCommit(Directory workspaceRoot) {
  final result = Process.runSync('git', const [
    'rev-parse',
    'HEAD',
  ], workingDirectory: workspaceRoot.path);
  if (result.exitCode != 0) {
    return 'unknown';
  }
  return result.stdout.toString().trim();
}

Future<ProcessResult> _defaultProcessRunner(
  String executable,
  List<String> arguments,
  ProfileProcessOptions options,
) {
  return Process.run(
    executable,
    arguments,
    workingDirectory: options.workingDirectory,
    environment: options.environment,
  );
}

/// Returns a filesystem-safe UTC run id.
String defaultProfileBaselineRunId() {
  return DateTime.now()
      .toUtc()
      .toIso8601String()
      .replaceAll(':', '-')
      .replaceAll('.', '-');
}
