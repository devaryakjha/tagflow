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
}) => <String, Object?>{
  'renderer': renderer,
  'fixture': fixture,
  'observedRepeats': repeats,
};
