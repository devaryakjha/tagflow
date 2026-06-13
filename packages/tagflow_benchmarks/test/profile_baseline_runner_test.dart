import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:tagflow_benchmarks/src/profile/profile_baseline_runner.dart';

void main() {
  test('runs selected profile matrix and writes a manifest', () async {
    final workspaceRoot = Directory.systemTemp.createTempSync(
      'tagflow_profile_runner_test_',
    );
    addTearDown(() => workspaceRoot.deleteSync(recursive: true));

    final integrationOutput = File(
      p.join(
        workspaceRoot.path,
        'examples',
        'tagflow',
        'build',
        'integration_response_data.json',
      ),
    )..parent.createSync(recursive: true);

    final commands = <Map<String, Object?>>[];
    var commandCount = 0;

    final runner = ProfileBaselineRunner(
      workspaceRoot: workspaceRoot,
      outputDirectory: Directory(
        p.join(workspaceRoot.path, 'build', 'benchmarks', 'profile'),
      ),
      renderers: const ['tagflow', 'flutter_html'],
      fixtures: const ['ai_answer_rich'],
      repeatCount: 2,
      runId: '2026-06-11T12-00-00Z',
      processRunner: (executable, arguments, options) async {
        commandCount += 1;
        commands.add(<String, Object?>{
          'executable': executable,
          'arguments': arguments,
          'workingDirectory': options.workingDirectory,
          'environment': options.environment,
          'stdoutSinkPresent': options.stdoutSink != null,
          'stderrSinkPresent': options.stderrSink != null,
        });
        integrationOutput.writeAsStringSync(
          jsonEncode(<String, Object?>{
            'run': commandCount,
            'results': <String, Object?>{},
          }),
        );
        return ProcessResult(100 + commandCount, 0, 'ok', '');
      },
    );

    final manifest = await runner.run();

    expect(commands, hasLength(4));
    expect(manifest.runs, hasLength(4));
    expect(manifest.runId, '2026-06-11T12-00-00Z');
    expect(commands.first['arguments'], <String>[
      'run',
      'melos',
      'run',
      'benchmark:profile',
    ]);

    final firstEnvironment =
        commands.first['environment']! as Map<String, String>;
    expect(firstEnvironment['TAGFLOW_RENDERER'], 'tagflow');
    expect(firstEnvironment['TAGFLOW_FIXTURE'], 'ai_answer_rich');
    expect(commands.first['stdoutSinkPresent'], isTrue);
    expect(commands.first['stderrSinkPresent'], isTrue);

    final artifactPath = p.join(
      workspaceRoot.path,
      'build',
      'benchmarks',
      'profile',
      '2026-06-11T12-00-00Z',
      'tagflow',
      'ai_answer_rich',
      'repeat-01.json',
    );
    expect(File(artifactPath).existsSync(), isTrue);

    final manifestPath = p.join(
      workspaceRoot.path,
      'build',
      'benchmarks',
      'profile',
      '2026-06-11T12-00-00Z',
      'profile-baseline-manifest.json',
    );
    expect(File(manifestPath).existsSync(), isTrue);

    final json =
        jsonDecode(File(manifestPath).readAsStringSync())
            as Map<String, Object?>;
    expect(json['runId'], '2026-06-11T12-00-00Z');
    expect(json['selectionMode'], 'matrix');
    expect(json.containsKey('pairs'), isFalse);
    expect(json['gitCommit'], manifest.environment.gitCommit);
    expect(
      (json['environment']! as Map<String, Object?>)['gitCommit'],
      json['gitCommit'],
    );
    expect(json['runs'], isA<List<Object?>>());
    expect(
      (json['runs']! as List<Object?>).first,
      containsPair('status', 'passed'),
    );
    expect(
      (json['runs']! as List<Object?>).first,
      containsPair(
        'logPath',
        'build/benchmarks/profile/2026-06-11T12-00-00Z/'
            'tagflow/ai_answer_rich/repeat-01.log',
      ),
    );
    expect(
      File(
        p.join(
          workspaceRoot.path,
          'build',
          'benchmarks',
          'profile',
          '2026-06-11T12-00-00Z',
          'tagflow',
          'ai_answer_rich',
          'repeat-01.log',
        ),
      ).existsSync(),
      isTrue,
    );
  });

  test('runs explicit profile pairs in order without cross-product', () async {
    final workspaceRoot = Directory.systemTemp.createTempSync(
      'tagflow_profile_runner_pairs_test_',
    );
    addTearDown(() => workspaceRoot.deleteSync(recursive: true));

    final integrationOutput = File(
      p.join(
        workspaceRoot.path,
        'examples',
        'tagflow',
        'build',
        'integration_response_data.json',
      ),
    )..parent.createSync(recursive: true);

    final commands = <Map<String, Object?>>[];
    var commandCount = 0;

    final runner = ProfileBaselineRunner(
      workspaceRoot: workspaceRoot,
      outputDirectory: Directory(
        p.join(workspaceRoot.path, 'build', 'benchmarks', 'profile'),
      ),
      renderers: const ['tagflow_semantic', 'tagflow_semantic_patch'],
      fixtures: const [
        'streaming_ai_authored_insertions',
        'streaming_ai_authored_insertion_patches',
      ],
      pairs: const [
        ProfileBaselineCell(
          renderer: 'tagflow_semantic',
          fixture: 'streaming_ai_authored_insertions',
        ),
        ProfileBaselineCell(
          renderer: 'tagflow_semantic_patch',
          fixture: 'streaming_ai_authored_insertion_patches',
        ),
      ],
      repeatCount: 1,
      runId: '2026-06-11T12-15-00Z',
      processRunner: (executable, arguments, options) async {
        commandCount += 1;
        commands.add(<String, Object?>{
          'executable': executable,
          'arguments': arguments,
          'environment': options.environment,
        });
        integrationOutput.writeAsStringSync(
          jsonEncode(<String, Object?>{
            'run': commandCount,
            'results': <String, Object?>{},
          }),
        );
        return ProcessResult(400 + commandCount, 0, 'ok', '');
      },
    );

    final manifest = await runner.run();

    expect(commands, hasLength(2));
    expect(manifest.runs, hasLength(2));
    expect(
      commands.map((command) {
        final environment = command['environment']! as Map<String, String>;
        return '${environment['TAGFLOW_RENDERER']}:'
            '${environment['TAGFLOW_FIXTURE']}';
      }),
      <String>[
        'tagflow_semantic:streaming_ai_authored_insertions',
        'tagflow_semantic_patch:streaming_ai_authored_insertion_patches',
      ],
    );
    expect(manifest.runs.first.renderer, 'tagflow_semantic');
    expect(manifest.runs.first.fixture, 'streaming_ai_authored_insertions');
    expect(manifest.runs.last.renderer, 'tagflow_semantic_patch');
    expect(
      manifest.runs.last.fixture,
      'streaming_ai_authored_insertion_patches',
    );

    final manifestPath = p.join(
      workspaceRoot.path,
      'build',
      'benchmarks',
      'profile',
      '2026-06-11T12-15-00Z',
      'profile-baseline-manifest.json',
    );
    final json =
        jsonDecode(File(manifestPath).readAsStringSync())
            as Map<String, Object?>;
    expect(json['selectionMode'], 'pairs');
    expect(json['pairs'], <Object?>[
      <String, Object?>{
        'renderer': 'tagflow_semantic',
        'fixture': 'streaming_ai_authored_insertions',
      },
      <String, Object?>{
        'renderer': 'tagflow_semantic_patch',
        'fixture': 'streaming_ai_authored_insertion_patches',
      },
    ]);
  });

  test('requests profile memory files and records VM service URIs', () async {
    final workspaceRoot = Directory.systemTemp.createTempSync(
      'tagflow_profile_runner_memory_test_',
    );
    addTearDown(() => workspaceRoot.deleteSync(recursive: true));

    final integrationOutput = File(
      p.join(
        workspaceRoot.path,
        'examples',
        'tagflow',
        'build',
        'integration_response_data.json',
      ),
    )..parent.createSync(recursive: true);

    late Map<String, String> environment;
    final runner = ProfileBaselineRunner(
      workspaceRoot: workspaceRoot,
      outputDirectory: Directory(
        p.join(workspaceRoot.path, 'build', 'benchmarks', 'profile'),
      ),
      renderers: const ['tagflow'],
      fixtures: const ['large_article'],
      repeatCount: 1,
      runId: '2026-06-12T12-00-00Z',
      profileMemory: true,
      processRunner: (executable, arguments, options) async {
        environment = options.environment;
        integrationOutput.writeAsStringSync(
          jsonEncode(<String, Object?>{
            'run': 1,
            'results': <String, Object?>{},
          }),
        );
        File(environment['TAGFLOW_PROFILE_MEMORY_FILE']!)
          ..parent.createSync(recursive: true)
          ..writeAsStringSync('{"samples":[]}');
        return ProcessResult(
          501,
          0,
          'The Dart VM service is listening on '
              'http://127.0.0.1:12345/abc=/',
          '',
        );
      },
    );

    final manifest = await runner.run();
    final run = manifest.runs.single;

    expect(environment['TAGFLOW_PROFILE_MEMORY_FILE'], isNotNull);
    expect(
      environment['TAGFLOW_PROFILE_MEMORY_FILE'],
      endsWith('repeat-01-memory.json'),
    );
    expect(manifest.profileMemory, isTrue);
    expect(run.status, 'passed');
    expect(run.memoryProfileStatus, 'captured');
    expect(run.memoryProfilePath, endsWith('repeat-01-memory.json'));
    expect(run.vmServiceUri, 'http://127.0.0.1:12345/abc=/');

    final manifestPath = p.join(
      workspaceRoot.path,
      'build',
      'benchmarks',
      'profile',
      '2026-06-12T12-00-00Z',
      'profile-baseline-manifest.json',
    );
    final json =
        jsonDecode(File(manifestPath).readAsStringSync())
            as Map<String, Object?>;
    final runs = json['runs']! as List<Object?>;
    expect(json['profileMemory'], isTrue);
    expect(
      runs.single,
      containsPair('vmServiceUri', 'http://127.0.0.1:12345/abc=/'),
    );
    expect(runs.single, containsPair('memoryProfileStatus', 'captured'));
  });

  test('passes profile checkpoint hold-open settings into each run', () async {
    final workspaceRoot = Directory.systemTemp.createTempSync(
      'tagflow_profile_runner_hold_open_test_',
    );
    addTearDown(() => workspaceRoot.deleteSync(recursive: true));

    final integrationOutput = File(
      p.join(
        workspaceRoot.path,
        'examples',
        'tagflow',
        'build',
        'integration_response_data.json',
      ),
    )..parent.createSync(recursive: true);

    late Map<String, String> environment;
    final runner = ProfileBaselineRunner(
      workspaceRoot: workspaceRoot,
      outputDirectory: Directory(
        p.join(workspaceRoot.path, 'build', 'benchmarks', 'profile'),
      ),
      renderers: const ['tagflow'],
      fixtures: const ['large_article'],
      repeatCount: 1,
      runId: '2026-06-12T12-10-00Z',
      profileHoldOpen: true,
      profileHoldOpenSeconds: 90,
      processRunner: (executable, arguments, options) async {
        environment = options.environment;
        integrationOutput.writeAsStringSync(
          jsonEncode(<String, Object?>{
            'run': 1,
            'results': <String, Object?>{},
          }),
        );
        return ProcessResult(701, 0, 'ok', '');
      },
    );

    final manifest = await runner.run();

    expect(environment['TAGFLOW_PROFILE_HOLD_OPEN'], 'true');
    expect(environment['TAGFLOW_PROFILE_HOLD_OPEN_SECONDS'], '90');
    expect(manifest.profileHoldOpen, isTrue);
    expect(manifest.profileHoldOpenSeconds, 90);

    final manifestPath = p.join(
      workspaceRoot.path,
      'build',
      'benchmarks',
      'profile',
      '2026-06-12T12-10-00Z',
      'profile-baseline-manifest.json',
    );
    final json =
        jsonDecode(File(manifestPath).readAsStringSync())
            as Map<String, Object?>;
    expect(json['profileHoldOpen'], isTrue);
    expect(json['profileHoldOpenSeconds'], 90);

    final logPath = p.join(workspaceRoot.path, manifest.runs.single.logPath);
    final logJson =
        jsonDecode(File(logPath).readAsStringSync()) as Map<String, Object?>;
    expect(logJson['profileHoldOpen'], isTrue);
    expect(logJson['profileHoldOpenSeconds'], 90);
  });

  test('passes synthetic viewport settings into each run', () async {
    final workspaceRoot = Directory.systemTemp.createTempSync(
      'tagflow_profile_runner_synthetic_viewport_test_',
    );
    addTearDown(() => workspaceRoot.deleteSync(recursive: true));

    final integrationOutput = File(
      p.join(
        workspaceRoot.path,
        'examples',
        'tagflow',
        'build',
        'integration_response_data.json',
      ),
    )..parent.createSync(recursive: true);

    late Map<String, String> environment;
    final runner = ProfileBaselineRunner(
      workspaceRoot: workspaceRoot,
      outputDirectory: Directory(
        p.join(workspaceRoot.path, 'build', 'benchmarks', 'profile'),
      ),
      renderers: const ['tagflow'],
      fixtures: const ['ai_answer_rich'],
      repeatCount: 1,
      runId: '2026-06-12T12-15-00Z',
      profileViewportConfiguration:
          const ProfileBaselineViewportConfiguration.synthetic(
            viewport: ProfileBaselineSyntheticViewport(
              logicalWidth: 800,
              logicalHeight: 600,
              devicePixelRatio: 2,
            ),
          ),
      processRunner: (executable, arguments, options) async {
        environment = options.environment;
        integrationOutput.writeAsStringSync(
          jsonEncode(<String, Object?>{
            'run': 1,
            'results': <String, Object?>{},
          }),
        );
        return ProcessResult(751, 0, 'ok', '');
      },
    );

    final manifest = await runner.run();

    expect(environment['TAGFLOW_PROFILE_VIEWPORT_MODE'], 'synthetic');
    expect(environment['TAGFLOW_PROFILE_SYNTHETIC_LOGICAL_SIZE'], '800x600');
    expect(environment['TAGFLOW_PROFILE_SYNTHETIC_DEVICE_PIXEL_RATIO'], '2');
    expect(
      manifest.profileViewportConfiguration.mode,
      ProfileBaselineViewportMode.synthetic,
    );

    final manifestPath = p.join(
      workspaceRoot.path,
      'build',
      'benchmarks',
      'profile',
      '2026-06-12T12-15-00Z',
      'profile-baseline-manifest.json',
    );
    final json =
        jsonDecode(File(manifestPath).readAsStringSync())
            as Map<String, Object?>;
    expect(json['profileViewportConfiguration'], <String, Object?>{
      'mode': 'synthetic',
      'syntheticViewport': <String, Object?>{
        'logicalWidth': 800.0,
        'logicalHeight': 600.0,
        'devicePixelRatio': 2.0,
      },
    });
  });

  test(
    'writes memory evidence checkpoint manifest for hold-open runs',
    () async {
      final workspaceRoot = Directory.systemTemp.createTempSync(
        'tagflow_profile_runner_memory_evidence_manifest_test_',
      );
      addTearDown(() => workspaceRoot.deleteSync(recursive: true));

      final integrationOutput = File(
        p.join(
          workspaceRoot.path,
          'examples',
          'tagflow',
          'build',
          'integration_response_data.json',
        ),
      )..parent.createSync(recursive: true);

      final runner = ProfileBaselineRunner(
        workspaceRoot: workspaceRoot,
        outputDirectory: Directory(
          p.join(workspaceRoot.path, 'build', 'benchmarks', 'profile'),
        ),
        renderers: const ['tagflow_semantic_patch'],
        fixtures: const ['streaming_ai_authored_insertion_patches'],
        repeatCount: 1,
        runId: '2026-06-12T12-20-00Z',
        profileMemory: true,
        profileHoldOpen: true,
        profileHoldOpenSeconds: 120,
        processRunner: (executable, arguments, options) async {
          integrationOutput.writeAsStringSync(
            jsonEncode(<String, Object?>{
              'run': 1,
              'results': <String, Object?>{},
            }),
          );
          File(options.environment['TAGFLOW_PROFILE_MEMORY_FILE']!)
            ..parent.createSync(recursive: true)
            ..writeAsStringSync('{"samples":[]}');
          return ProcessResult(
            801,
            0,
            'The Dart VM service is listening on '
                'http://127.0.0.1:54321/xyz=/',
            '',
          );
        },
      );

      await runner.run();

      final manifestPath = p.join(
        workspaceRoot.path,
        'build',
        'benchmarks',
        'profile',
        '2026-06-12T12-20-00Z',
        'profile-baseline-manifest.json',
      );
      final manifestJson =
          jsonDecode(File(manifestPath).readAsStringSync())
              as Map<String, Object?>;
      expect(
        manifestJson['memoryEvidenceManifestPath'],
        'build/benchmarks/profile/2026-06-12T12-20-00Z/'
        'memory-evidence-manifest.json',
      );

      final evidenceManifest = File(
        p.join(
          workspaceRoot.path,
          manifestJson['memoryEvidenceManifestPath']! as String,
        ),
      );
      expect(evidenceManifest.existsSync(), isTrue);

      final evidenceJson =
          jsonDecode(evidenceManifest.readAsStringSync())
              as Map<String, Object?>;
      expect(evidenceJson['runId'], '2026-06-12T12-20-00Z');
      expect(evidenceJson['gitCommit'], manifestJson['gitCommit']);
      expect(evidenceJson['status'], 'manualExportsRequired');
      expect(evidenceJson['interactiveDevToolsCommand'], <Object?>[
        'dart',
        'devtools',
      ]);

      final runs = evidenceJson['runs']! as List<Object?>;
      final run = runs.single! as Map<String, Object?>;
      expect(run['renderer'], 'tagflow_semantic_patch');
      expect(run['fixture'], 'streaming_ai_authored_insertion_patches');
      expect(run['vmServiceUri'], 'http://127.0.0.1:54321/xyz=/');
      final headlessMemoryProfilePath = p.join(
        'build',
        'benchmarks',
        'profile',
        '2026-06-12T12-20-00Z',
        'devtools',
        'tagflow_semantic_patch-'
            'streaming_ai_authored_insertion_patches-'
            'repeat-01-memory-profile.json',
      );
      final headlessMemoryProfileOption =
          '--record-memory-profile=$headlessMemoryProfilePath';
      expect(run['headlessMemoryProfileCommand'], <Object?>[
        'dart',
        'devtools',
        headlessMemoryProfileOption,
        'http://127.0.0.1:54321/xyz=/',
      ]);

      final checkpoints = run['checkpoints']! as List<Object?>;
      expect(
        checkpoints.map(
          (checkpoint) =>
              (checkpoint! as Map<String, Object?>)['checkpoint']! as String,
        ),
        <String>[
          'before_first_patch',
          'after_first_patch',
          'after_final_patch',
          'after_scroll',
        ],
      );
      expect(
        checkpoints.first,
        containsPair(
          'heapSnapshotPath',
          'build/benchmarks/profile/2026-06-12T12-20-00Z/devtools/'
              'tagflow_semantic_patch-streaming_ai_authored_insertion_patches-'
              'repeat-01-before_first_patch-heap-snapshot.json',
        ),
      );
      expect(checkpoints.first, containsPair('status', 'manualExportRequired'));
      final automatedExport =
          (checkpoints.first!
                  as Map<String, Object?>)['automatedVmServiceExport']!
              as Map<String, Object?>;
      expect(
        automatedExport['checkpoint'],
        'tagflow_semantic_patch-streaming_ai_authored_insertion_patches-'
        'repeat-01-before_first_patch',
      );
      expect(
        automatedExport['heapSummaryPath'],
        'build/benchmarks/profile/2026-06-12T12-20-00Z/devtools/'
        'tagflow_semantic_patch-streaming_ai_authored_insertion_patches-'
        'repeat-01-before_first_patch-heap-summary.json',
      );
      expect(
        automatedExport['allocationProfilePath'],
        'build/benchmarks/profile/2026-06-12T12-20-00Z/devtools/'
        'tagflow_semantic_patch-streaming_ai_authored_insertion_patches-'
        'repeat-01-before_first_patch-allocation-profile.json',
      );
      expect(
        automatedExport['heapSnapshotPath'],
        'build/benchmarks/profile/2026-06-12T12-20-00Z/devtools/'
        'tagflow_semantic_patch-streaming_ai_authored_insertion_patches-'
        'repeat-01-before_first_patch-heap-snapshot.json',
      );
      expect(automatedExport['command'], <Object?>[
        'dart',
        'run',
        'melos',
        'run',
        'benchmark:memory-evidence:export',
      ]);
      expect(
        automatedExport['environment'],
        containsPair(
          'TAGFLOW_MEMORY_EVIDENCE_VM_SERVICE_URI',
          'http://127.0.0.1:54321/xyz=/',
        ),
      );
      expect(
        automatedExport['environment'],
        containsPair('TAGFLOW_MEMORY_EVIDENCE_WRITE_RAW_HEAP', 'true'),
      );
    },
  );

  test('classifies missing requested profile memory separately', () async {
    final workspaceRoot = Directory.systemTemp.createTempSync(
      'tagflow_profile_runner_missing_memory_test_',
    );
    addTearDown(() => workspaceRoot.deleteSync(recursive: true));

    final integrationOutput = File(
      p.join(
        workspaceRoot.path,
        'examples',
        'tagflow',
        'build',
        'integration_response_data.json',
      ),
    )..parent.createSync(recursive: true);

    final runner = ProfileBaselineRunner(
      workspaceRoot: workspaceRoot,
      outputDirectory: Directory(
        p.join(workspaceRoot.path, 'build', 'benchmarks', 'profile'),
      ),
      renderers: const ['tagflow'],
      fixtures: const ['large_article'],
      repeatCount: 1,
      runId: '2026-06-12T12-05-00Z',
      failFast: false,
      profileMemory: true,
      processRunner: (executable, arguments, options) async {
        integrationOutput.writeAsStringSync(
          jsonEncode(<String, Object?>{
            'run': 1,
            'results': <String, Object?>{},
          }),
        );
        return ProcessResult(601, 0, 'ok', '');
      },
    );

    final manifest = await runner.run();
    final run = manifest.runs.single;

    expect(run.status, 'missingMemoryProfile');
    expect(run.artifactPath, isNotNull);
    expect(run.memoryProfileStatus, 'missing');
    expect(run.memoryProfilePath, endsWith('repeat-01-memory.json'));
  });

  test('can continue through failed profile runs and write logs', () async {
    final workspaceRoot = Directory.systemTemp.createTempSync(
      'tagflow_profile_runner_failed_test_',
    );
    addTearDown(() => workspaceRoot.deleteSync(recursive: true));

    final integrationOutput = File(
      p.join(
        workspaceRoot.path,
        'examples',
        'tagflow',
        'build',
        'integration_response_data.json',
      ),
    )..parent.createSync(recursive: true);

    var commandCount = 0;
    final runner = ProfileBaselineRunner(
      workspaceRoot: workspaceRoot,
      outputDirectory: Directory(
        p.join(workspaceRoot.path, 'build', 'benchmarks', 'profile'),
      ),
      renderers: const ['tagflow', 'flutter_html'],
      fixtures: const ['ai_answer_rich'],
      repeatCount: 1,
      runId: '2026-06-11T12-05-00Z',
      failFast: false,
      processRunner: (executable, arguments, options) async {
        commandCount += 1;
        if (commandCount == 1) {
          return ProcessResult(201, 1, 'profile stdout', 'unsupported device');
        }

        integrationOutput.writeAsStringSync(
          jsonEncode(<String, Object?>{
            'run': commandCount,
            'results': <String, Object?>{},
          }),
        );
        return ProcessResult(202, 0, 'ok', '');
      },
    );

    final manifest = await runner.run();

    expect(manifest.runs, hasLength(2));
    expect(manifest.runs.first.status, 'failed');
    expect(manifest.runs.first.exitCode, 1);
    expect(manifest.runs.first.artifactPath, isNull);
    expect(manifest.runs.first.logPath, endsWith('repeat-01.log'));
    expect(manifest.runs.last.status, 'passed');
    expect(manifest.runs.last.artifactPath, isNotNull);

    final failedLog = File(
      p.join(workspaceRoot.path, manifest.runs.first.logPath),
    );
    expect(failedLog.existsSync(), isTrue);
    expect(failedLog.readAsStringSync(), contains('unsupported device'));

    final manifestJson =
        jsonDecode(
              File(
                p.join(
                  workspaceRoot.path,
                  'build',
                  'benchmarks',
                  'profile',
                  '2026-06-11T12-05-00Z',
                  'profile-baseline-manifest.json',
                ),
              ).readAsStringSync(),
            )
            as Map<String, Object?>;
    expect(manifestJson['failFast'], isFalse);
    final runs = manifestJson['runs']! as List<Object?>;
    expect(runs.first, containsPair('status', 'failed'));
    expect(runs.first, containsPair('artifactPath', null));
  });

  test('can continue through timed-out profile runs and write logs', () async {
    final workspaceRoot = Directory.systemTemp.createTempSync(
      'tagflow_profile_runner_timeout_test_',
    );
    addTearDown(() => workspaceRoot.deleteSync(recursive: true));

    final integrationOutput = File(
      p.join(
        workspaceRoot.path,
        'examples',
        'tagflow',
        'build',
        'integration_response_data.json',
      ),
    )..parent.createSync(recursive: true);

    final timeouts = <Duration?>[];
    var commandCount = 0;
    final runner = ProfileBaselineRunner(
      workspaceRoot: workspaceRoot,
      outputDirectory: Directory(
        p.join(workspaceRoot.path, 'build', 'benchmarks', 'profile'),
      ),
      renderers: const ['tagflow', 'flutter_html'],
      fixtures: const ['ai_answer_rich'],
      repeatCount: 1,
      runId: '2026-06-12T13-00-00Z',
      failFast: false,
      runTimeout: const Duration(seconds: 180),
      processRunner: (executable, arguments, options) async {
        commandCount += 1;
        timeouts.add(options.timeout);
        if (commandCount == 1) {
          return ProcessResult(
            901,
            profileRunTimeoutExitCode,
            '',
            'Profile benchmark process timed out after 180 seconds.',
          );
        }

        integrationOutput.writeAsStringSync(
          jsonEncode(<String, Object?>{
            'run': commandCount,
            'results': <String, Object?>{},
          }),
        );
        return ProcessResult(902, 0, 'ok', '');
      },
    );

    final manifest = await runner.run();

    expect(timeouts, <Duration?>[
      const Duration(seconds: 180),
      const Duration(seconds: 180),
    ]);
    expect(manifest.runTimeoutSeconds, 180);
    expect(manifest.runs, hasLength(2));
    expect(manifest.runs.first.status, 'timedOut');
    expect(manifest.runs.first.exitCode, profileRunTimeoutExitCode);
    expect(manifest.runs.first.artifactPath, isNull);
    expect(manifest.runs.last.status, 'passed');
    expect(manifest.runs.last.artifactPath, isNotNull);

    final timedOutLog = File(
      p.join(workspaceRoot.path, manifest.runs.first.logPath),
    );
    expect(timedOutLog.existsSync(), isTrue);
    final logJson =
        jsonDecode(timedOutLog.readAsStringSync()) as Map<String, Object?>;
    expect(logJson['runTimeoutSeconds'], 180);
    expect(logJson['exitCode'], profileRunTimeoutExitCode);
    expect(
      logJson['stderr'],
      contains('Profile benchmark process timed out after 180 seconds.'),
    );

    final manifestJson =
        jsonDecode(
              File(
                p.join(
                  workspaceRoot.path,
                  'build',
                  'benchmarks',
                  'profile',
                  '2026-06-12T13-00-00Z',
                  'profile-baseline-manifest.json',
                ),
              ).readAsStringSync(),
            )
            as Map<String, Object?>;
    expect(manifestJson['runTimeoutSeconds'], 180);
    final runs = manifestJson['runs']! as List<Object?>;
    expect(runs.first, containsPair('status', 'timedOut'));
    expect(runs.first, containsPair('exitCode', profileRunTimeoutExitCode));
  });

  test('records flutter version from flutter version machine output', () async {
    final workspaceRoot = Directory.systemTemp.createTempSync(
      'tagflow_profile_runner_flutter_version_test_',
    );
    addTearDown(() => workspaceRoot.deleteSync(recursive: true));

    File(p.join(workspaceRoot.path, 'packages', 'tagflow', 'pubspec.yaml'))
      ..parent.createSync(recursive: true)
      ..writeAsStringSync('version: 1.0.0-alpha.1\n');

    final integrationOutput = File(
      p.join(
        workspaceRoot.path,
        'examples',
        'tagflow',
        'build',
        'integration_response_data.json',
      ),
    )..parent.createSync(recursive: true);

    final runner = ProfileBaselineRunner(
      workspaceRoot: workspaceRoot,
      outputDirectory: Directory(
        p.join(workspaceRoot.path, 'build', 'benchmarks', 'profile'),
      ),
      renderers: const ['tagflow'],
      fixtures: const ['ai_answer_rich'],
      repeatCount: 1,
      runId: '2026-06-11T12-10-00Z',
      processRunner: (executable, arguments, options) async {
        integrationOutput.writeAsStringSync(
          jsonEncode(<String, Object?>{
            'run': 1,
            'results': <String, Object?>{},
          }),
        );
        return ProcessResult(301, 0, 'ok', '');
      },
      environmentProcessRunner: (executable, arguments, {workingDirectory}) {
        if (executable == 'flutter' &&
            arguments.length == 2 &&
            arguments[0] == '--version' &&
            arguments[1] == '--machine') {
          return ProcessResult(
            302,
            0,
            jsonEncode(<String, Object?>{
              'frameworkVersion': '3.45.0-0.1.pre',
              'channel': 'master',
            }),
            '',
          );
        }
        return ProcessResult(303, 1, '', 'unexpected command');
      },
    );

    final manifest = await runner.run();

    expect(manifest.environment.flutterVersion, '3.45.0-0.1.pre (master)');
  });
}
