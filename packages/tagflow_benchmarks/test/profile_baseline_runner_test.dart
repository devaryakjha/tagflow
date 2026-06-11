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
}
