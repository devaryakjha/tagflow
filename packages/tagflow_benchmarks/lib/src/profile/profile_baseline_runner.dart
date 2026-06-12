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

/// Default checkpoint hold-open duration for DevTools attachment.
const int defaultProfileHoldOpenSeconds = 120;

/// One explicit profile benchmark renderer/fixture cell.
final class ProfileBaselineCell {
  /// Creates one explicit profile baseline cell.
  const ProfileBaselineCell({required this.renderer, required this.fixture});

  /// Renderer id used for this cell.
  final String renderer;

  /// Fixture id used for this cell.
  final String fixture;

  /// Converts this cell to machine-readable JSON.
  Map<String, Object?> toJson() => <String, Object?>{
    'renderer': renderer,
    'fixture': fixture,
  };
}

/// Options passed to a profile benchmark process invocation.
final class ProfileProcessOptions {
  /// Creates process invocation options.
  const ProfileProcessOptions({
    required this.workingDirectory,
    required this.environment,
    this.stdoutSink,
    this.stderrSink,
  });

  /// Working directory for the spawned process.
  final String workingDirectory;

  /// Environment overrides for the spawned process.
  final Map<String, String> environment;

  /// Optional sink for live stdout chunks from the spawned process.
  final void Function(String chunk)? stdoutSink;

  /// Optional sink for live stderr chunks from the spawned process.
  final void Function(String chunk)? stderrSink;
}

/// Runs one profile benchmark process.
typedef ProfileProcessRunner =
    Future<ProcessResult> Function(
      String executable,
      List<String> arguments,
      ProfileProcessOptions options,
    );

/// Runs a synchronous environment probe process.
typedef ProfileEnvironmentProcessRunner =
    ProcessResult Function(
      String executable,
      List<String> arguments, {
      String? workingDirectory,
    });

/// Profile baseline manifest written after a matrix run.
final class ProfileBaselineManifest {
  /// Creates a profile baseline manifest.
  const ProfileBaselineManifest({
    required this.runId,
    required this.generatedAt,
    required this.gitCommit,
    required this.environment,
    required this.device,
    required this.repeatCount,
    required this.profileMemory,
    required this.profileHoldOpen,
    required this.profileHoldOpenSeconds,
    required this.renderers,
    required this.fixtures,
    required this.selectionMode,
    required this.pairs,
    required this.command,
    required this.outputDirectory,
    required this.memoryEvidenceManifestPath,
    required this.sourceResponsePath,
    required this.failFast,
    required this.runs,
  });

  /// Stable id used as the output folder name.
  final String runId;

  /// UTC manifest generation time.
  final DateTime generatedAt;

  /// Git commit checked out for this run, mirrored from [environment].
  final String gitCommit;

  /// Host and toolchain fields for this profile baseline run.
  final ProfileBaselineEnvironment environment;

  /// Flutter device id passed to the profile harness.
  final String device;

  /// Number of repeats per renderer/fixture pair.
  final int repeatCount;

  /// Whether per-cell `flutter drive --profile-memory` capture was requested.
  final bool profileMemory;

  /// Whether benchmark cells request checkpoint hold-open replay.
  final bool profileHoldOpen;

  /// Hold-open duration for checkpoint replay, when enabled.
  final int? profileHoldOpenSeconds;

  /// Renderer ids included in this run.
  final List<String> renderers;

  /// Fixture ids included in this run.
  final List<String> fixtures;

  /// Matrix selection mode: `matrix` or `pairs`.
  final String selectionMode;

  /// Explicit pair selection, when [selectionMode] is `pairs`.
  final List<ProfileBaselineCell>? pairs;

  /// Existing Melos command reused by each matrix cell.
  final List<String> command;

  /// Directory where the raw response artifacts and manifest were written.
  final String outputDirectory;

  /// Machine-readable DevTools memory evidence checklist, when emitted.
  final String? memoryEvidenceManifestPath;

  /// Existing integration-test response path copied after each run.
  final String sourceResponsePath;

  /// Whether this run was configured to stop at the first failed matrix cell.
  final bool failFast;

  /// Individual run records.
  final List<ProfileBaselineRun> runs;

  /// Converts this manifest to machine-readable JSON.
  Map<String, Object?> toJson() => <String, Object?>{
    'runId': runId,
    'generatedAt': generatedAt.toUtc().toIso8601String(),
    'gitCommit': gitCommit,
    'environment': environment.toJson(),
    'device': device,
    'repeatCount': repeatCount,
    'profileMemory': profileMemory,
    'profileHoldOpen': profileHoldOpen,
    'profileHoldOpenSeconds': profileHoldOpenSeconds,
    'renderers': renderers,
    'fixtures': fixtures,
    'selectionMode': selectionMode,
    if (pairs != null) 'pairs': pairs!.map((pair) => pair.toJson()).toList(),
    'command': command,
    'outputDirectory': outputDirectory,
    if (memoryEvidenceManifestPath != null)
      'memoryEvidenceManifestPath': memoryEvidenceManifestPath,
    'sourceResponsePath': sourceResponsePath,
    'failFast': failFast,
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

  /// Flutter SDK version from `FLUTTER_VERSION` or `flutter --version`.
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
    required this.status,
    required this.exitCode,
    required this.artifactPath,
    required this.memoryProfilePath,
    required this.memoryProfileStatus,
    required this.vmServiceUri,
    required this.logPath,
    required this.startedAt,
    required this.finishedAt,
  });

  /// Renderer id used for the run.
  final String renderer;

  /// Fixture id used for the run.
  final String fixture;

  /// One-based repeat index.
  final int repeat;

  /// Result status for this repeat.
  final String status;

  /// Process exit code.
  final int exitCode;

  /// Copied raw integration-test JSON artifact path.
  final String? artifactPath;

  /// Per-cell `--profile-memory` JSON path when profile memory is enabled.
  final String? memoryProfilePath;

  /// `notRequested`, `captured`, or `missing`.
  final String memoryProfileStatus;

  /// VM service URI observed in stdout/stderr, when Flutter prints one.
  final String? vmServiceUri;

  /// Per-run stdout/stderr and command log path.
  final String logPath;

  /// UTC start time.
  final DateTime startedAt;

  /// UTC finish time.
  final DateTime finishedAt;

  /// Converts this run record to machine-readable JSON.
  Map<String, Object?> toJson() => <String, Object?>{
    'renderer': renderer,
    'fixture': fixture,
    'repeat': repeat,
    'status': status,
    'exitCode': exitCode,
    'artifactPath': artifactPath,
    'memoryProfilePath': memoryProfilePath,
    'memoryProfileStatus': memoryProfileStatus,
    'vmServiceUri': vmServiceUri,
    'logPath': logPath,
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
    this.failFast = true,
    this.profileMemory = false,
    bool profileHoldOpen = false,
    int? profileHoldOpenSeconds,
    this.pairs,
    ProfileProcessRunner? processRunner,
    ProfileEnvironmentProcessRunner? environmentProcessRunner,
    DateTime Function()? clock,
  }) : _processRunner = processRunner ?? _defaultProcessRunner,
       profileHoldOpen = profileHoldOpen || profileHoldOpenSeconds != null,
       profileHoldOpenSeconds =
           profileHoldOpen || profileHoldOpenSeconds != null
           ? profileHoldOpenSeconds ?? defaultProfileHoldOpenSeconds
           : null,
       _environmentProcessRunner =
           environmentProcessRunner ?? _defaultEnvironmentProcessRunner,
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
    final holdOpenSeconds = this.profileHoldOpenSeconds;
    if (holdOpenSeconds != null && holdOpenSeconds < 1) {
      throw ArgumentError.value(
        holdOpenSeconds,
        'profileHoldOpenSeconds',
        'Must be at least 1.',
      );
    }
    final pairs = this.pairs;
    if (pairs != null) {
      if (pairs.isEmpty) {
        throw ArgumentError.value(pairs, 'pairs', 'Cannot be empty.');
      }
      for (final pair in pairs) {
        if (pair.renderer.trim().isEmpty) {
          throw ArgumentError.value(
            pair.renderer,
            'renderer',
            'Cannot be empty.',
          );
        }
        if (pair.fixture.trim().isEmpty) {
          throw ArgumentError.value(
            pair.fixture,
            'fixture',
            'Cannot be empty.',
          );
        }
      }
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

  /// Whether to stop on the first failed profile process or missing artifact.
  final bool failFast;

  /// Whether to request per-cell `flutter drive --profile-memory` JSON.
  final bool profileMemory;

  /// Whether to request checkpoint hold-open replay after measurement.
  final bool profileHoldOpen;

  /// Hold-open duration for checkpoint replay, when enabled.
  final int? profileHoldOpenSeconds;

  /// Explicit renderer/fixture cells to run instead of the renderer matrix.
  final List<ProfileBaselineCell>? pairs;

  final ProfileProcessRunner _processRunner;
  final ProfileEnvironmentProcessRunner _environmentProcessRunner;
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

    for (final cell in _selectedCells) {
      final renderer = cell.renderer;
      final fixture = cell.fixture;
      for (var repeat = 1; repeat <= repeatCount; repeat += 1) {
        if (sourceResponse.existsSync()) {
          sourceResponse.deleteSync();
        }

        final startedAt = _clock().toUtc();
        final cellDirectory = Directory(
          p.join(runDirectory.path, renderer, fixture),
        )..createSync(recursive: true);
        final repeatId = 'repeat-${repeat.toString().padLeft(2, '0')}';
        final memoryProfile = profileMemory
            ? File(p.join(cellDirectory.path, '$repeatId-memory.json'))
            : null;
        if (memoryProfile != null && memoryProfile.existsSync()) {
          memoryProfile.deleteSync();
        }

        final processEnvironment = <String, String>{
          'TAGFLOW_RENDERER': renderer,
          'TAGFLOW_FIXTURE': fixture,
          'TAGFLOW_PROFILE_DEVICE': device,
        };
        if (memoryProfile != null) {
          processEnvironment['TAGFLOW_PROFILE_MEMORY_FILE'] =
              memoryProfile.absolute.path;
        }
        if (profileHoldOpen) {
          processEnvironment['TAGFLOW_PROFILE_HOLD_OPEN'] = 'true';
          processEnvironment['TAGFLOW_PROFILE_HOLD_OPEN_SECONDS'] =
              profileHoldOpenSeconds.toString();
        }

        final result = await _processRunner(
          'dart',
          _command,
          ProfileProcessOptions(
            workingDirectory: workspaceRoot.path,
            environment: processEnvironment,
            stdoutSink: stdout.write,
            stderrSink: stderr.write,
          ),
        );
        final finishedAt = _clock().toUtc();
        final logFile = File(p.join(cellDirectory.path, '$repeatId.log'));
        final vmServiceUri = _extractVmServiceUri(result);
        final memoryProfilePath = memoryProfile == null
            ? null
            : p.relative(memoryProfile.path, from: workspaceRoot.path);
        _writeRunLog(
          logFile: logFile,
          renderer: renderer,
          fixture: fixture,
          repeat: repeat,
          result: result,
          memoryProfilePath: memoryProfilePath,
          memoryProfileStatus: _memoryProfileStatus(memoryProfile),
          vmServiceUri: vmServiceUri,
          profileHoldOpen: profileHoldOpen,
          profileHoldOpenSeconds: profileHoldOpenSeconds,
          startedAt: startedAt,
          finishedAt: finishedAt,
        );
        final logPath = p.relative(logFile.path, from: workspaceRoot.path);

        if (result.exitCode != 0) {
          runs.add(
            ProfileBaselineRun(
              renderer: renderer,
              fixture: fixture,
              repeat: repeat,
              status: 'failed',
              exitCode: result.exitCode,
              artifactPath: null,
              memoryProfilePath: memoryProfilePath,
              memoryProfileStatus: _memoryProfileStatus(memoryProfile),
              vmServiceUri: vmServiceUri,
              logPath: logPath,
              startedAt: startedAt,
              finishedAt: finishedAt,
            ),
          );
          if (!failFast) {
            continue;
          }
          throw ProcessException(
            'dart',
            _command,
            '${result.stderr}\n${result.stdout}'.trim(),
            result.exitCode,
          );
        }
        if (!sourceResponse.existsSync()) {
          runs.add(
            ProfileBaselineRun(
              renderer: renderer,
              fixture: fixture,
              repeat: repeat,
              status: 'missingArtifact',
              exitCode: result.exitCode,
              artifactPath: null,
              memoryProfilePath: memoryProfilePath,
              memoryProfileStatus: _memoryProfileStatus(memoryProfile),
              vmServiceUri: vmServiceUri,
              logPath: logPath,
              startedAt: startedAt,
              finishedAt: finishedAt,
            ),
          );
          if (!failFast) {
            continue;
          }
          throw StateError(
            'Profile benchmark completed but did not write '
            '${sourceResponse.path}.',
          );
        }

        final artifact = File(p.join(cellDirectory.path, '$repeatId.json'));
        sourceResponse.copySync(artifact.path);
        final artifactPath = p.relative(
          artifact.path,
          from: workspaceRoot.path,
        );

        if (memoryProfile != null && !memoryProfile.existsSync()) {
          runs.add(
            ProfileBaselineRun(
              renderer: renderer,
              fixture: fixture,
              repeat: repeat,
              status: 'missingMemoryProfile',
              exitCode: result.exitCode,
              artifactPath: artifactPath,
              memoryProfilePath: memoryProfilePath,
              memoryProfileStatus: 'missing',
              vmServiceUri: vmServiceUri,
              logPath: logPath,
              startedAt: startedAt,
              finishedAt: finishedAt,
            ),
          );
          if (!failFast) {
            continue;
          }
          throw StateError(
            'Profile benchmark completed but did not write '
            '${memoryProfile.path}.',
          );
        }

        runs.add(
          ProfileBaselineRun(
            renderer: renderer,
            fixture: fixture,
            repeat: repeat,
            status: 'passed',
            exitCode: result.exitCode,
            artifactPath: artifactPath,
            memoryProfilePath: memoryProfilePath,
            memoryProfileStatus: _memoryProfileStatus(memoryProfile),
            vmServiceUri: vmServiceUri,
            logPath: logPath,
            startedAt: startedAt,
            finishedAt: finishedAt,
          ),
        );
      }
    }

    final environment = _detectEnvironment(
      workspaceRoot,
      _environmentProcessRunner,
    );
    final memoryEvidenceManifestPath = profileHoldOpen
        ? _writeMemoryEvidenceManifest(
            workspaceRoot: workspaceRoot,
            runDirectory: runDirectory,
            runId: runId,
            gitCommit: environment.gitCommit,
            device: device,
            profileMemory: profileMemory,
            profileHoldOpenSeconds: profileHoldOpenSeconds,
            runs: runs,
            generatedAt: _clock().toUtc(),
          )
        : null;
    final selectedPairs = pairs;
    final manifest = ProfileBaselineManifest(
      runId: runId,
      generatedAt: _clock().toUtc(),
      gitCommit: environment.gitCommit,
      environment: environment,
      device: device,
      repeatCount: repeatCount,
      profileMemory: profileMemory,
      profileHoldOpen: profileHoldOpen,
      profileHoldOpenSeconds: profileHoldOpenSeconds,
      renderers: List<String>.unmodifiable(renderers),
      fixtures: List<String>.unmodifiable(fixtures),
      selectionMode: selectedPairs == null ? 'matrix' : 'pairs',
      pairs: selectedPairs == null
          ? null
          : List<ProfileBaselineCell>.unmodifiable(selectedPairs),
      command: _command,
      outputDirectory: p.relative(runDirectory.path, from: workspaceRoot.path),
      memoryEvidenceManifestPath: memoryEvidenceManifestPath,
      sourceResponsePath: p.relative(
        sourceResponse.path,
        from: workspaceRoot.path,
      ),
      failFast: failFast,
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

  Iterable<ProfileBaselineCell> get _selectedCells sync* {
    final pairs = this.pairs;
    if (pairs != null) {
      yield* pairs;
      return;
    }

    for (final renderer in renderers) {
      for (final fixture in fixtures) {
        yield ProfileBaselineCell(renderer: renderer, fixture: fixture);
      }
    }
  }
}

String _writeMemoryEvidenceManifest({
  required Directory workspaceRoot,
  required Directory runDirectory,
  required String runId,
  required String gitCommit,
  required String device,
  required bool profileMemory,
  required int? profileHoldOpenSeconds,
  required List<ProfileBaselineRun> runs,
  required DateTime generatedAt,
}) {
  final devtoolsDirectory = Directory(p.join(runDirectory.path, 'devtools'))
    ..createSync(recursive: true);
  final manifestFile = File(
    p.join(runDirectory.path, 'memory-evidence-manifest.json'),
  );
  final manifestPath = p.relative(manifestFile.path, from: workspaceRoot.path);
  final devtoolsPath = p.relative(
    devtoolsDirectory.path,
    from: workspaceRoot.path,
  );
  final manualExportsRequired = <String>[
    'heapSnapshot',
    'allocationProfileOrClassDiff',
    'retainedObjectReview',
  ];
  final runPlans = runs
      .map(
        (run) => _memoryEvidenceRunJson(run: run, devtoolsPath: devtoolsPath),
      )
      .toList();

  manifestFile.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(<String, Object?>{
      'runId': runId,
      'generatedAt': generatedAt.toUtc().toIso8601String(),
      'gitCommit': gitCommit,
      'status': 'manualExportsRequired',
      'device': device,
      'profileMemory': profileMemory,
      'profileHoldOpen': true,
      'profileHoldOpenSeconds': profileHoldOpenSeconds,
      'devtoolsDirectory': devtoolsPath,
      'interactiveDevToolsCommand': ['dart', 'devtools'],
      'manualExportsRequired': manualExportsRequired,
      'runs': runPlans,
    })}\n',
  );

  return manifestPath;
}

Map<String, Object?> _memoryEvidenceRunJson({
  required ProfileBaselineRun run,
  required String devtoolsPath,
}) {
  final laneId = _memoryEvidenceLaneId(run);
  final repeatId = 'repeat-${run.repeat.toString().padLeft(2, '0')}';
  final headlessMemoryProfilePath = p.join(
    devtoolsPath,
    '$laneId-$repeatId-memory-profile.json',
  );
  final vmServiceUri = run.vmServiceUri;
  return <String, Object?>{
    'renderer': run.renderer,
    'fixture': run.fixture,
    'repeat': run.repeat,
    'runStatus': run.status,
    'vmServiceUri': vmServiceUri,
    'memoryProfilePath': run.memoryProfilePath,
    'memoryProfileStatus': run.memoryProfileStatus,
    'logPath': run.logPath,
    'status': vmServiceUri == null
        ? 'vmServiceUriMissing'
        : 'manualExportsRequired',
    'headlessMemoryProfilePath': headlessMemoryProfilePath,
    if (vmServiceUri != null)
      'headlessMemoryProfileCommand': [
        'dart',
        'devtools',
        '--record-memory-profile=$headlessMemoryProfilePath',
        vmServiceUri,
      ],
    'checkpoints': _memoryEvidenceCheckpoints(run).map((checkpoint) {
      final automatedCheckpoint = '$laneId-$repeatId-$checkpoint';
      final heapSummaryPath = p.join(
        devtoolsPath,
        '$automatedCheckpoint-heap-summary.json',
      );
      final allocationProfilePath = p.join(
        devtoolsPath,
        '$automatedCheckpoint-allocation-profile.json',
      );
      final heapSnapshotPath = p.join(
        devtoolsPath,
        '$automatedCheckpoint-heap-snapshot.json',
      );
      return <String, Object?>{
        'checkpoint': checkpoint,
        'status': 'manualExportRequired',
        'heapSnapshotPath': heapSnapshotPath,
        'allocationDiffPath': p.join(
          devtoolsPath,
          '$laneId-$repeatId-$checkpoint-allocation-diff.json',
        ),
        'retainedObjectReviewPath': p.join(
          devtoolsPath,
          '$laneId-$repeatId-$checkpoint-retained-objects.md',
        ),
        'automatedVmServiceExport': vmServiceUri == null
            ? null
            : <String, Object?>{
                'checkpoint': automatedCheckpoint,
                'heapSummaryPath': heapSummaryPath,
                'allocationProfilePath': allocationProfilePath,
                'heapSnapshotPath': heapSnapshotPath,
                'environment': <String, String>{
                  'TAGFLOW_MEMORY_EVIDENCE_VM_SERVICE_URI': vmServiceUri,
                  'TAGFLOW_MEMORY_EVIDENCE_CHECKPOINT': automatedCheckpoint,
                  'TAGFLOW_MEMORY_EVIDENCE_OUTPUT_DIR': devtoolsPath,
                  'TAGFLOW_MEMORY_EVIDENCE_WRITE_RAW_HEAP': 'true',
                },
                'command': [
                  'dart',
                  'run',
                  'melos',
                  'run',
                  'benchmark:memory-evidence:export',
                ],
              },
      };
    }).toList(),
  };
}

String _memoryEvidenceLaneId(ProfileBaselineRun run) {
  return '${run.renderer}-${run.fixture}';
}

List<String> _memoryEvidenceCheckpoints(ProfileBaselineRun run) {
  if (run.renderer == 'tagflow_semantic_patch') {
    return const [
      'before_first_patch',
      'after_first_patch',
      'after_final_patch',
      'after_scroll',
    ];
  }

  if (run.fixture.startsWith('streaming_ai_')) {
    return const [
      'before_first_update',
      'after_first_update',
      'after_final_update',
      'after_scroll',
    ];
  }

  return const ['before_first_render', 'after_first_render', 'after_scroll'];
}

void _writeRunLog({
  required File logFile,
  required String renderer,
  required String fixture,
  required int repeat,
  required ProcessResult result,
  required String? memoryProfilePath,
  required String memoryProfileStatus,
  required String? vmServiceUri,
  required bool profileHoldOpen,
  required int? profileHoldOpenSeconds,
  required DateTime startedAt,
  required DateTime finishedAt,
}) {
  logFile.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(<String, Object?>{
      'renderer': renderer,
      'fixture': fixture,
      'repeat': repeat,
      'command': ['dart', ...ProfileBaselineRunner._command],
      'memoryProfilePath': memoryProfilePath,
      'memoryProfileStatus': memoryProfileStatus,
      'vmServiceUri': vmServiceUri,
      'profileHoldOpen': profileHoldOpen,
      'profileHoldOpenSeconds': profileHoldOpenSeconds,
      'startedAt': startedAt.toUtc().toIso8601String(),
      'finishedAt': finishedAt.toUtc().toIso8601String(),
      'exitCode': result.exitCode,
      'stdout': result.stdout.toString(),
      'stderr': result.stderr.toString(),
    })}\n',
  );
}

String _memoryProfileStatus(File? memoryProfile) {
  if (memoryProfile == null) {
    return 'notRequested';
  }
  return memoryProfile.existsSync() ? 'captured' : 'missing';
}

String? _extractVmServiceUri(ProcessResult result) {
  final combined = '${result.stdout}\n${result.stderr}';
  final serviceMatch = RegExp(
    r'(?:Dart VM service|VM Service|Observatory)[^\n]*(https?://[^\s]+)',
    caseSensitive: false,
  ).firstMatch(combined);
  if (serviceMatch != null) {
    return serviceMatch.group(1);
  }

  final localhostMatch = RegExp(
    r'https?://(?:127\.0\.0\.1|localhost):\d+/[^\s]+',
  ).firstMatch(combined);
  return localhostMatch?.group(0);
}

ProfileBaselineEnvironment _detectEnvironment(
  Directory workspaceRoot,
  ProfileEnvironmentProcessRunner processRunner,
) {
  return ProfileBaselineEnvironment(
    tagflowVersion: _readTagflowVersion(workspaceRoot),
    dartVersion: Platform.version.split(' ').first,
    flutterVersion: _readFlutterVersion(workspaceRoot, processRunner),
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

String _readFlutterVersion(
  Directory workspaceRoot,
  ProfileEnvironmentProcessRunner processRunner,
) {
  final override = Platform.environment['FLUTTER_VERSION'];
  if (override != null && override.trim().isNotEmpty) {
    return override.trim();
  }

  try {
    final result = processRunner('flutter', const [
      '--version',
      '--machine',
    ], workingDirectory: workspaceRoot.path);
    if (result.exitCode != 0) {
      return 'unknown';
    }

    final decoded = jsonDecode(result.stdout.toString());
    if (decoded is! Map<String, Object?>) {
      return 'unknown';
    }

    final frameworkVersion = decoded['frameworkVersion'];
    if (frameworkVersion is! String || frameworkVersion.trim().isEmpty) {
      return 'unknown';
    }

    final channel = decoded['channel'];
    if (channel is String && channel.trim().isNotEmpty) {
      return '${frameworkVersion.trim()} (${channel.trim()})';
    }
    return frameworkVersion.trim();
  } on Object {
    return 'unknown';
  }
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
) async {
  final process = await Process.start(
    executable,
    arguments,
    workingDirectory: options.workingDirectory,
    environment: options.environment,
  );

  final stdoutBuffer = StringBuffer();
  final stderrBuffer = StringBuffer();

  final stdoutDone = process.stdout.transform(utf8.decoder).listen((chunk) {
    stdoutBuffer.write(chunk);
    options.stdoutSink?.call(chunk);
  }).asFuture<void>();
  final stderrDone = process.stderr.transform(utf8.decoder).listen((chunk) {
    stderrBuffer.write(chunk);
    options.stderrSink?.call(chunk);
  }).asFuture<void>();

  final exitCode = await process.exitCode;
  await Future.wait<void>([stdoutDone, stderrDone]);

  return ProcessResult(
    process.pid,
    exitCode,
    stdoutBuffer.toString(),
    stderrBuffer.toString(),
  );
}

ProcessResult _defaultEnvironmentProcessRunner(
  String executable,
  List<String> arguments, {
  String? workingDirectory,
}) {
  return Process.runSync(
    executable,
    arguments,
    workingDirectory: workingDirectory,
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
