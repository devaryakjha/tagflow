import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:tagflow_benchmarks/src/profile/profile_baseline_check.dart';

void main() {
  test('passes when all runs succeed and each cell meets repeat count', () {
    final summaryFile = _writeSummary(
      totalRuns: 2,
      successfulRuns: 2,
      cellSummaries: <Map<String, Object?>>[
        _cellSummary(
          renderer: 'tagflow',
          fixture: 'ai_answer_rich',
          repeats: 2,
        ),
      ],
    );
    addTearDown(() => summaryFile.parent.deleteSync(recursive: true));

    final result = checkProfileBaselineSummary(
      summaryFile: summaryFile,
      minRepeats: 2,
    );

    expect(result.passed, isTrue);
    expect(result.issues, isEmpty);
    expect(result.toJson(), containsPair('passed', true));
  });

  test('keeps viewport metadata report-only by default', () {
    final summaryFile = _writeSummary(
      totalRuns: 1,
      successfulRuns: 1,
      cellSummaries: <Map<String, Object?>>[
        _cellSummary(
          renderer: 'tagflow',
          fixture: 'ai_answer_rich',
          repeats: 1,
          viewports: <Map<String, Object?>>[
            _viewport(
              logicalWidth: 1024,
              logicalHeight: 768,
              devicePixelRatio: 2,
            ),
          ],
        ),
      ],
    );
    addTearDown(() => summaryFile.parent.deleteSync(recursive: true));

    final result = checkProfileBaselineSummary(summaryFile: summaryFile);

    expect(result.passed, isTrue);
    expect(result.issues, isEmpty);
  });

  test(
    'fails when failed runs are present or successful run count mismatches',
    () {
      final summaryFile = _writeSummary(
        totalRuns: 2,
        successfulRuns: 1,
        failedRuns: <Map<String, Object?>>[
          <String, Object?>{
            'renderer': 'tagflow',
            'fixture': 'ai_answer_rich',
            'repeat': 2,
            'status': 'failed',
            'exitCode': 1,
            'logPath': 'build/benchmarks/profile/run/tagflow/repeat-02.log',
            'artifactPath': null,
          },
        ],
        cellSummaries: <Map<String, Object?>>[
          _cellSummary(
            renderer: 'tagflow',
            fixture: 'ai_answer_rich',
            repeats: 1,
          ),
        ],
      );
      addTearDown(() => summaryFile.parent.deleteSync(recursive: true));

      final result = checkProfileBaselineSummary(summaryFile: summaryFile);

      expect(result.passed, isFalse);
      expect(
        result.issues.map((issue) => issue.code),
        containsAll(<String>[
          'failed_runs_present',
          'successful_runs_mismatch',
        ]),
      );
    },
  );

  test('fails when a renderer fixture cell has too few repeats', () {
    final summaryFile = _writeSummary(
      totalRuns: 1,
      successfulRuns: 1,
      cellSummaries: <Map<String, Object?>>[
        _cellSummary(renderer: 'tagflow', fixture: 'table_stress', repeats: 1),
      ],
    );
    addTearDown(() => summaryFile.parent.deleteSync(recursive: true));

    final result = checkProfileBaselineSummary(
      summaryFile: summaryFile,
      minRepeats: 5,
    );

    expect(result.passed, isFalse);
    expect(result.issues, hasLength(1));
    expect(result.issues.single.code, 'insufficient_repeats');
    expect(
      result.issues.single.details,
      containsPair('fixture', 'table_stress'),
    );
  });

  test('fails when the summary has no successful cells', () {
    final summaryFile = _writeSummary(totalRuns: 0, successfulRuns: 0);
    addTearDown(() => summaryFile.parent.deleteSync(recursive: true));

    final result = checkProfileBaselineSummary(summaryFile: summaryFile);

    expect(result.passed, isFalse);
    expect(result.issues.single.code, 'no_cell_summaries');
  });

  test('fails when expected viewport metadata is missing', () {
    final summaryFile = _writeSummary(
      totalRuns: 1,
      successfulRuns: 1,
      cellSummaries: <Map<String, Object?>>[
        _cellSummary(renderer: 'tagflow', fixture: 'table_stress', repeats: 1),
      ],
    );
    addTearDown(() => summaryFile.parent.deleteSync(recursive: true));

    final result = checkProfileBaselineSummary(
      summaryFile: summaryFile,
      expectedViewport: const ProfileBaselineExpectedViewport(
        logicalWidth: 800,
        logicalHeight: 600,
        devicePixelRatio: 2,
      ),
    );

    expect(result.passed, isFalse);
    expect(result.issues, hasLength(1));
    expect(result.issues.single.code, 'missing_viewport_metadata');
    expect(
      result.issues.single.details,
      containsPair('fixture', 'table_stress'),
    );
  });

  test('fails when observed viewport metadata does not match expectation', () {
    final summaryFile = _writeSummary(
      totalRuns: 1,
      successfulRuns: 1,
      cellSummaries: <Map<String, Object?>>[
        _cellSummary(
          renderer: 'tagflow',
          fixture: 'table_stress',
          repeats: 1,
          viewports: <Map<String, Object?>>[
            _viewport(
              logicalWidth: 1024,
              logicalHeight: 768,
              devicePixelRatio: 2,
            ),
          ],
        ),
      ],
    );
    addTearDown(() => summaryFile.parent.deleteSync(recursive: true));

    final result = checkProfileBaselineSummary(
      summaryFile: summaryFile,
      expectedViewport: const ProfileBaselineExpectedViewport(
        logicalWidth: 800,
        logicalHeight: 600,
        devicePixelRatio: 2,
      ),
    );

    expect(result.passed, isFalse);
    expect(result.issues, hasLength(1));
    expect(result.issues.single.code, 'unexpected_viewport');
    expect(
      result.issues.single.details,
      containsPair('expectedViewport', <String, Object?>{
        'logicalWidth': 800.0,
        'logicalHeight': 600.0,
        'devicePixelRatio': 2.0,
      }),
    );
  });

  test('passes when observed viewport metadata matches expectation', () {
    final summaryFile = _writeSummary(
      totalRuns: 1,
      successfulRuns: 1,
      cellSummaries: <Map<String, Object?>>[
        _cellSummary(
          renderer: 'tagflow',
          fixture: 'table_stress',
          repeats: 1,
          viewports: <Map<String, Object?>>[
            _viewport(
              logicalWidth: 800,
              logicalHeight: 600,
              devicePixelRatio: 2,
            ),
          ],
        ),
      ],
    );
    addTearDown(() => summaryFile.parent.deleteSync(recursive: true));

    final result = checkProfileBaselineSummary(
      summaryFile: summaryFile,
      expectedViewport: const ProfileBaselineExpectedViewport(
        logicalWidth: 800,
        logicalHeight: 600,
        devicePixelRatio: 2,
      ),
    );

    expect(result.passed, isTrue);
    expect(result.issues, isEmpty);
  });

  test('loads a report-only check policy from JSON', () {
    final policyFile = _writePolicy();
    addTearDown(() => policyFile.parent.deleteSync(recursive: true));

    final policy = ProfileBaselineCheckPolicy.fromFile(policyFile);

    expect(policy.id, 'tagflow-alpha-macos-reference-report-only');
    expect(policy.minRepeats, 5);
    expect(policy.thresholdMode, 'report_only');
    expect(policy.expectedViewport?.logicalWidth, 800);
    expect(policy.expectedViewport?.logicalHeight, 600);
    expect(policy.expectedViewport?.devicePixelRatio, 2);
  });

  test('applies policy repeat count and viewport guard', () {
    final policyFile = _writePolicy();
    final summaryFile = _writeSummary(
      totalRuns: 5,
      successfulRuns: 5,
      cellSummaries: <Map<String, Object?>>[
        _cellSummary(
          renderer: 'tagflow',
          fixture: 'ai_answer_rich',
          repeats: 5,
          viewports: <Map<String, Object?>>[
            _viewport(
              logicalWidth: 800,
              logicalHeight: 600,
              devicePixelRatio: 2,
            ),
          ],
        ),
      ],
    );
    addTearDown(() => policyFile.parent.deleteSync(recursive: true));
    addTearDown(() => summaryFile.parent.deleteSync(recursive: true));

    final policy = ProfileBaselineCheckPolicy.fromFile(policyFile);
    final result = checkProfileBaselineSummary(
      summaryFile: summaryFile,
      policy: policy,
    );

    expect(result.passed, isTrue);
    expect(result.minRepeats, 5);
    expect(result.toJson(), containsPair('policy', policy.toJson()));
  });

  test('rejects policy modes that would add performance gates', () {
    final policyFile = _writePolicy(thresholdMode: 'enforced');
    addTearDown(() => policyFile.parent.deleteSync(recursive: true));

    expect(
      () => ProfileBaselineCheckPolicy.fromFile(policyFile),
      throwsA(isA<FormatException>()),
    );
  });
}

File _writeSummary({
  required int totalRuns,
  required int successfulRuns,
  List<Map<String, Object?>> failedRuns = const <Map<String, Object?>>[],
  List<Map<String, Object?>> cellSummaries = const <Map<String, Object?>>[],
}) {
  final directory = Directory.systemTemp.createTempSync(
    'tagflow_profile_check_test_',
  );
  final summaryFile = File(p.join(directory.path, 'profile-summary.json'))
    ..writeAsStringSync(
      jsonEncode(<String, Object?>{
        'runId': 'test-run',
        'manifestPath':
            'build/benchmarks/profile/test-run/'
            'profile-baseline-manifest.json',
        'runDirectory': 'build/benchmarks/profile/test-run',
        'generatedAt': DateTime.utc(2026, 6, 11).toIso8601String(),
        'totalRuns': totalRuns,
        'successfulRuns': successfulRuns,
        'runStatusCounts': <String, Object?>{
          if (successfulRuns > 0) 'passed': successfulRuns,
        },
        'failedRuns': failedRuns,
        'cellSummaries': cellSummaries,
      }),
    );
  return summaryFile;
}

Map<String, Object?> _cellSummary({
  required String renderer,
  required String fixture,
  required int repeats,
  List<Map<String, Object?>> viewports = const <Map<String, Object?>>[],
}) => <String, Object?>{
  'renderer': renderer,
  'fixture': fixture,
  'observedRepeats': repeats,
  'viewports': viewports,
};

Map<String, Object?> _viewport({
  required num logicalWidth,
  required num logicalHeight,
  required num devicePixelRatio,
}) => <String, Object?>{
  'logicalWidth': logicalWidth.toDouble(),
  'logicalHeight': logicalHeight.toDouble(),
  'physicalWidth': logicalWidth.toDouble() * devicePixelRatio.toDouble(),
  'physicalHeight': logicalHeight.toDouble() * devicePixelRatio.toDouble(),
  'devicePixelRatio': devicePixelRatio.toDouble(),
};

File _writePolicy({String thresholdMode = 'report_only'}) {
  final directory = Directory.systemTemp.createTempSync(
    'tagflow_profile_policy_test_',
  );
  return File(p.join(directory.path, 'profile-policy.json'))..writeAsStringSync(
    jsonEncode(<String, Object?>{
      'schemaVersion': 1,
      'id': 'tagflow-alpha-macos-reference-report-only',
      'check': <String, Object?>{
        'minRepeats': 5,
        'expectedViewport': <String, Object?>{
          'logicalWidth': 800,
          'logicalHeight': 600,
          'devicePixelRatio': 2,
        },
      },
      'thresholdPolicy': <String, Object?>{
        'mode': thresholdMode,
        'performanceGates': <Object?>[],
      },
    }),
  );
}
