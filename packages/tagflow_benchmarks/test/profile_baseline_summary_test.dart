import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:tagflow_benchmarks/src/profile/profile_baseline_summary.dart';

void main() {
  test('summarizes repeated profile artifacts and flags outliers', () {
    final workspaceRoot = Directory.systemTemp.createTempSync(
      'tagflow_profile_summary_test_',
    );
    addTearDown(() => workspaceRoot.deleteSync(recursive: true));

    final runDirectory = Directory(
      p.join(
        workspaceRoot.path,
        'build',
        'benchmarks',
        'profile',
        '2026-06-11-reference',
      ),
    )..createSync(recursive: true);

    File(
        p.join(
          runDirectory.path,
          'tagflow',
          'ai_answer_rich',
          'repeat-01.json',
        ),
      )
      ..parent.createSync(recursive: true)
      ..writeAsStringSync(
        jsonEncode(<String, Object?>{
          'tagflow_ai_answer_rich_scroll': <String, Object?>{
            'average_frame_build_time_millis': 0.2,
            '90th_percentile_frame_build_time_millis': 0.3,
            'worst_frame_build_time_millis': 0.5,
            'average_frame_rasterizer_time_millis': 1.1,
            '90th_percentile_frame_rasterizer_time_millis': 1.9,
            'worst_frame_rasterizer_time_millis': 8.0,
            'missed_frame_build_budget_count': 0,
            'missed_frame_rasterizer_budget_count': 0,
            'frame_count': 24,
            'new_gen_gc_count': 2,
            'old_gen_gc_count': 0,
          },
        }),
      );

    File(
      p.join(runDirectory.path, 'tagflow', 'ai_answer_rich', 'repeat-02.json'),
    ).writeAsStringSync(
      jsonEncode(<String, Object?>{
        'tagflow_ai_answer_rich_scroll': <String, Object?>{
          'average_frame_build_time_millis': 0.4,
          '90th_percentile_frame_build_time_millis': 0.6,
          'worst_frame_build_time_millis': 0.8,
          'average_frame_rasterizer_time_millis': 1.3,
          '90th_percentile_frame_rasterizer_time_millis': 2.4,
          'worst_frame_rasterizer_time_millis': 18.5,
          'missed_frame_build_budget_count': 0,
          'missed_frame_rasterizer_budget_count': 1,
          'frame_count': 22,
          'new_gen_gc_count': 2,
          'old_gen_gc_count': 1,
        },
      }),
    );

    final manifestFile =
        File(p.join(runDirectory.path, 'profile-baseline-manifest.json'))
          ..writeAsStringSync(
            jsonEncode(<String, Object?>{
              'runId': '2026-06-11-reference',
              'runs': [
                <String, Object?>{
                  'renderer': 'tagflow',
                  'fixture': 'ai_answer_rich',
                  'repeat': 1,
                  'status': 'passed',
                  'artifactPath':
                      'build/benchmarks/profile/2026-06-11-reference/'
                      'tagflow/ai_answer_rich/repeat-01.json',
                },
                <String, Object?>{
                  'renderer': 'tagflow',
                  'fixture': 'ai_answer_rich',
                  'repeat': 2,
                  'status': 'passed',
                  'artifactPath':
                      'build/benchmarks/profile/2026-06-11-reference/'
                      'tagflow/ai_answer_rich/repeat-02.json',
                },
                <String, Object?>{
                  'renderer': 'tagflow',
                  'fixture': 'ai_answer_rich',
                  'repeat': 3,
                  'status': 'failed',
                  'exitCode': 1,
                  'artifactPath': null,
                  'logPath':
                      'build/benchmarks/profile/2026-06-11-reference/'
                      'tagflow/ai_answer_rich/repeat-03.log',
                },
              ],
            }),
          );

    final summary = summarizeProfileBaselineManifest(
      manifestFile: manifestFile,
      clock: () => DateTime.utc(2026, 6, 11, 7),
    );

    expect(summary.totalRuns, 3);
    expect(summary.successfulRuns, 2);
    expect(summary.runStatusCounts, <String, int>{'passed': 2, 'failed': 1});
    expect(summary.failedRuns, hasLength(1));
    expect(summary.failedRuns.single.status, 'failed');
    expect(summary.failedRuns.single.exitCode, 1);
    expect(
      summary.failedRuns.single.logPath,
      'build/benchmarks/profile/2026-06-11-reference/'
      'tagflow/ai_answer_rich/repeat-03.log',
    );
    expect(summary.cellSummaries, hasLength(1));

    final cell = summary.cellSummaries.single;
    expect(cell.renderer, 'tagflow');
    expect(cell.fixture, 'ai_answer_rich');
    expect(cell.observedRepeats, 2);
    expect(cell.frameCount.min, 22);
    expect(cell.frameCount.max, 24);
    expect(cell.averageBuildMillis.mean, closeTo(0.3, 0.0001));
    expect(cell.worstRasterMillis.max, 18.5);
    expect(cell.missedRasterBudgetCount.total, 1);
    expect(cell.oldGenGcCount.max, 1);
    expect(cell.outlierRepeats, hasLength(1));
    expect(cell.outlierRepeats.single.repeat, 2);
    expect(
      cell.outlierRepeats.single.reasons,
      containsAll(<String>[
        'missed_raster_budget',
        'old_gen_gc',
        'worst_raster_over_budget',
      ]),
    );
  });
}
