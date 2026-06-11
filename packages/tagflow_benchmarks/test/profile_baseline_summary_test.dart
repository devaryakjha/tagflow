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
          'tagflow_ai_answer_rich_initial_render': <String, Object?>{
            'average_frame_build_time_millis': 1.2,
            '90th_percentile_frame_build_time_millis': 1.3,
            'worst_frame_build_time_millis': 1.5,
            'average_frame_rasterizer_time_millis': 2.1,
            '90th_percentile_frame_rasterizer_time_millis': 2.9,
            'worst_frame_rasterizer_time_millis': 9.0,
            'missed_frame_build_budget_count': 0,
            'missed_frame_rasterizer_budget_count': 0,
            'frame_count': 4,
            'new_gen_gc_count': 1,
            'old_gen_gc_count': 0,
          },
          'tagflow_ai_answer_rich_warm_rebuild': <String, Object?>{
            'average_frame_build_time_millis': 0.8,
            '90th_percentile_frame_build_time_millis': 1.0,
            'worst_frame_build_time_millis': 1.2,
            'average_frame_rasterizer_time_millis': 1.6,
            '90th_percentile_frame_rasterizer_time_millis': 2.1,
            'worst_frame_rasterizer_time_millis': 6.0,
            'missed_frame_build_budget_count': 0,
            'missed_frame_rasterizer_budget_count': 0,
            'frame_count': 3,
            'new_gen_gc_count': 1,
            'old_gen_gc_count': 0,
          },
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
        'tagflow_ai_answer_rich_initial_render': <String, Object?>{
          'average_frame_build_time_millis': 1.4,
          '90th_percentile_frame_build_time_millis': 1.6,
          'worst_frame_build_time_millis': 1.8,
          'average_frame_rasterizer_time_millis': 2.3,
          '90th_percentile_frame_rasterizer_time_millis': 3.4,
          'worst_frame_rasterizer_time_millis': 10.5,
          'missed_frame_build_budget_count': 0,
          'missed_frame_rasterizer_budget_count': 0,
          'frame_count': 5,
          'new_gen_gc_count': 1,
          'old_gen_gc_count': 0,
        },
        'tagflow_ai_answer_rich_warm_rebuild': <String, Object?>{
          'average_frame_build_time_millis': 1.1,
          '90th_percentile_frame_build_time_millis': 1.4,
          'worst_frame_build_time_millis': 1.7,
          'average_frame_rasterizer_time_millis': 1.9,
          '90th_percentile_frame_rasterizer_time_millis': 2.8,
          'worst_frame_rasterizer_time_millis': 7.5,
          'missed_frame_build_budget_count': 0,
          'missed_frame_rasterizer_budget_count': 0,
          'frame_count': 4,
          'new_gen_gc_count': 1,
          'old_gen_gc_count': 0,
        },
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
    expect(cell.framePhaseSummaries.keys, [
      'warmScroll',
      'coldInitialRender',
      'warmRebuild',
    ]);
    expect(cell.framePhaseSummaries['warmScroll']!.observedRepeats, 2);
    expect(cell.framePhaseSummaries['warmScroll']!.worstRasterMillis.max, 18.5);
    expect(cell.framePhaseSummaries['coldInitialRender']!.observedRepeats, 2);
    expect(
      cell.framePhaseSummaries['coldInitialRender']!.worstRasterMillis.max,
      10.5,
    );
    expect(cell.framePhaseSummaries['warmRebuild']!.observedRepeats, 2);
    expect(cell.framePhaseSummaries['warmRebuild']!.worstRasterMillis.max, 7.5);
    expect(cell.toJson(), contains('framePhaseSummaries'));
    expect(cell.updateSummary, isNull);
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

  test('summarizes manifests stored in a custom output directory', () {
    final workspaceRoot = Directory.systemTemp.createTempSync(
      'tagflow_profile_summary_custom_output_test_',
    );
    addTearDown(() => workspaceRoot.deleteSync(recursive: true));

    final runDirectory = Directory(
      p.join(workspaceRoot.path, 'tmp', 'profile-runs', 'custom-run'),
    )..createSync(recursive: true);
    final artifactPath = p.join(
      'tmp',
      'profile-runs',
      'custom-run',
      'tagflow',
      'ai_answer_rich',
      'repeat-01.json',
    );

    File(p.join(workspaceRoot.path, artifactPath))
      ..parent.createSync(recursive: true)
      ..writeAsStringSync(
        jsonEncode(<String, Object?>{
          'tagflow_ai_answer_rich_scroll': <String, Object?>{
            'average_frame_build_time_millis': 0.2,
            '90th_percentile_frame_build_time_millis': 0.3,
            'worst_frame_build_time_millis': 0.4,
            'average_frame_rasterizer_time_millis': 0.8,
            '90th_percentile_frame_rasterizer_time_millis': 1.1,
            'worst_frame_rasterizer_time_millis': 4.0,
            'missed_frame_build_budget_count': 0,
            'missed_frame_rasterizer_budget_count': 0,
            'frame_count': 23,
            'new_gen_gc_count': 0,
            'old_gen_gc_count': 0,
          },
          'tagflow_ai_answer_rich_viewport': <String, Object?>{
            'logicalWidth': 800.0,
            'logicalHeight': 632.0,
            'physicalWidth': 1600.0,
            'physicalHeight': 1264.0,
            'devicePixelRatio': 2.0,
          },
        }),
      );

    final manifestFile =
        File(p.join(runDirectory.path, 'profile-baseline-manifest.json'))
          ..writeAsStringSync(
            jsonEncode(<String, Object?>{
              'runId': 'custom-run',
              'outputDirectory': p.join('tmp', 'profile-runs', 'custom-run'),
              'runs': [
                <String, Object?>{
                  'renderer': 'tagflow',
                  'fixture': 'ai_answer_rich',
                  'repeat': 1,
                  'status': 'passed',
                  'artifactPath': artifactPath,
                },
              ],
            }),
          );

    final summary = summarizeProfileBaselineManifest(
      manifestFile: manifestFile,
      workspaceRoot: workspaceRoot,
      clock: () => DateTime.utc(2026, 6, 11, 8),
    );

    expect(summary.runDirectory, p.join('tmp', 'profile-runs', 'custom-run'));
    expect(summary.cellSummaries.single.observedRepeats, 1);
    expect(summary.cellSummaries.single.viewports, hasLength(1));
    expect(summary.cellSummaries.single.viewports.single.logicalWidth, 800.0);
    expect(summary.cellSummaries.single.viewports.single.devicePixelRatio, 2.0);
    expect(
      summary.cellSummaries.single.toJson().containsKey('updateSummary'),
      isFalse,
    );
  });

  test('summarizes legacy update latencies without phase fields', () {
    const scrollKey =
        'tagflow_semantic_patch_streaming_ai_authored_insertion_patches_scroll';
    const updatesKey =
        'tagflow_semantic_patch_streaming_ai_authored_insertion_patches_'
        'updates';
    const updateLatenciesKey =
        'tagflow_semantic_patch_streaming_ai_authored_insertion_patches_'
        'update_latencies';
    final workspaceRoot = Directory.systemTemp.createTempSync(
      'tagflow_profile_summary_updates_test_',
    );
    addTearDown(() => workspaceRoot.deleteSync(recursive: true));

    final runDirectory = Directory(
      p.join(
        workspaceRoot.path,
        'build',
        'benchmarks',
        'profile',
        '2026-06-11-authored-insertion-pair-repeat5',
      ),
    )..createSync(recursive: true);

    File(
        p.join(
          runDirectory.path,
          'tagflow_semantic_patch',
          'streaming_ai_authored_insertion_patches',
          'repeat-01.json',
        ),
      )
      ..parent.createSync(recursive: true)
      ..writeAsStringSync(
        jsonEncode(<String, Object?>{
          scrollKey: <String, Object?>{
            'average_frame_build_time_millis': 0.2,
            '90th_percentile_frame_build_time_millis': 0.3,
            'worst_frame_build_time_millis': 0.5,
            'average_frame_rasterizer_time_millis': 0.8,
            '90th_percentile_frame_rasterizer_time_millis': 1.2,
            'worst_frame_rasterizer_time_millis': 3.8,
            'missed_frame_build_budget_count': 0,
            'missed_frame_rasterizer_budget_count': 0,
            'frame_count': 24,
            'new_gen_gc_count': 0,
            'old_gen_gc_count': 0,
          },
          updatesKey: <String, Object?>{
            'average_frame_build_time_millis': 1.1,
            '90th_percentile_frame_build_time_millis': 1.6,
            'worst_frame_build_time_millis': 3.2,
            'average_frame_rasterizer_time_millis': 2.2,
            '90th_percentile_frame_rasterizer_time_millis': 3.4,
            'worst_frame_rasterizer_time_millis': 5.6,
            'missed_frame_build_budget_count': 0,
            'missed_frame_rasterizer_budget_count': 0,
            'frame_count': 3,
            'new_gen_gc_count': 0,
            'old_gen_gc_count': 0,
          },
          updateLatenciesKey: <Object?>[
            <String, Object?>{
              'chunk': 1,
              'fraction': 0.33,
              'inputLength': 2000,
              'elapsedMicros': 110118,
            },
            <String, Object?>{
              'chunk': 2,
              'fraction': 0.66,
              'inputLength': 4000,
              'elapsedMicros': 116790,
            },
          ],
        }),
      );

    File(
      p.join(
        runDirectory.path,
        'tagflow_semantic_patch',
        'streaming_ai_authored_insertion_patches',
        'repeat-02.json',
      ),
    ).writeAsStringSync(
      jsonEncode(<String, Object?>{
        scrollKey: <String, Object?>{
          'average_frame_build_time_millis': 0.2,
          '90th_percentile_frame_build_time_millis': 0.3,
          'worst_frame_build_time_millis': 0.5,
          'average_frame_rasterizer_time_millis': 0.8,
          '90th_percentile_frame_rasterizer_time_millis': 1.2,
          'worst_frame_rasterizer_time_millis': 3.8,
          'missed_frame_build_budget_count': 0,
          'missed_frame_rasterizer_budget_count': 0,
          'frame_count': 24,
          'new_gen_gc_count': 0,
          'old_gen_gc_count': 0,
        },
        updatesKey: <String, Object?>{
          'average_frame_build_time_millis': 5.4,
          '90th_percentile_frame_build_time_millis': 8.9,
          'worst_frame_build_time_millis': 18.8,
          'average_frame_rasterizer_time_millis': 7.6,
          '90th_percentile_frame_rasterizer_time_millis': 14.2,
          'worst_frame_rasterizer_time_millis': 21.132,
          'missed_frame_build_budget_count': 0,
          'missed_frame_rasterizer_budget_count': 1,
          'frame_count': 3,
          'new_gen_gc_count': 0,
          'old_gen_gc_count': 0,
        },
        updateLatenciesKey: <Object?>[
          <String, Object?>{
            'chunk': 1,
            'fraction': 0.33,
            'inputLength': 2000,
            'elapsedMicros': 249327401,
          },
          <String, Object?>{
            'chunk': 2,
            'fraction': 0.66,
            'inputLength': 4000,
            'elapsedMicros': 114001,
          },
        ],
      }),
    );

    final manifestFile =
        File(p.join(runDirectory.path, 'profile-baseline-manifest.json'))
          ..writeAsStringSync(
            jsonEncode(<String, Object?>{
              'runId': '2026-06-11-authored-insertion-pair-repeat5',
              'runs': [
                <String, Object?>{
                  'renderer': 'tagflow_semantic_patch',
                  'fixture': 'streaming_ai_authored_insertion_patches',
                  'repeat': 1,
                  'status': 'passed',
                  'artifactPath':
                      'build/benchmarks/profile/'
                      '2026-06-11-authored-insertion-pair-repeat5/'
                      'tagflow_semantic_patch/'
                      'streaming_ai_authored_insertion_patches/'
                      'repeat-01.json',
                },
                <String, Object?>{
                  'renderer': 'tagflow_semantic_patch',
                  'fixture': 'streaming_ai_authored_insertion_patches',
                  'repeat': 2,
                  'status': 'passed',
                  'artifactPath':
                      'build/benchmarks/profile/'
                      '2026-06-11-authored-insertion-pair-repeat5/'
                      'tagflow_semantic_patch/'
                      'streaming_ai_authored_insertion_patches/'
                      'repeat-02.json',
                },
              ],
            }),
          );

    final summary = summarizeProfileBaselineManifest(
      manifestFile: manifestFile,
      clock: () => DateTime.utc(2026, 6, 11, 9),
    );

    final cell = summary.cellSummaries.single;
    expect(cell.updateSummary, isNotNull);
    final updateSummary = cell.updateSummary!;
    expect(updateSummary.observedRepeats, 2);
    expect(updateSummary.observedUpdateCount, 4);
    expect(updateSummary.maxElapsedMicros, 249327401);
    expect(updateSummary.maxElapsedMillis, closeTo(249327.401, 0.0001));
    expect(updateSummary.maxElapsedRepeat, 2);
    expect(updateSummary.maxElapsedChunk, 1);
    expect(updateSummary.maxElapsedFraction, 0.33);
    expect(updateSummary.maxElapsedInputLength, 2000);
    expect(updateSummary.worstBuildMillis, isNotNull);
    expect(updateSummary.worstBuildMillis!.max, 18.8);
    expect(updateSummary.worstRasterMillis, isNotNull);
    expect(updateSummary.worstRasterMillis!.max, 21.132);
    expect(updateSummary.missedBuildBudgetCount, isNotNull);
    expect(updateSummary.missedBuildBudgetCount!.total, 0);
    expect(updateSummary.missedRasterBudgetCount, isNotNull);
    expect(updateSummary.missedRasterBudgetCount!.total, 1);
    expect(updateSummary.phaseMaxima, isEmpty);
    expect(updateSummary.worstAttributedFrame, isNull);
    expect(updateSummary.toJson().containsKey('phaseMaxima'), isFalse);

    expect(cell.outlierRepeats, hasLength(1));
    expect(cell.outlierRepeats.single.repeat, 2);
    expect(
      cell.outlierRepeats.single.reasons,
      containsAll(<String>[
        'update_latency_spike',
        'update_missed_raster_budget',
        'update_worst_build_over_budget',
        'update_worst_raster_over_budget',
      ]),
    );
    expect(cell.outlierRepeats.single.updatePhaseMaxima, isEmpty);
    expect(cell.outlierRepeats.single.updateWorstAttributedFrame, isNull);
  });

  test('summarizes update phase maxima when phase timings exist', () {
    const scrollKey =
        'tagflow_semantic_patch_streaming_ai_authored_insertion_patches_scroll';
    const updatesKey =
        'tagflow_semantic_patch_streaming_ai_authored_insertion_patches_'
        'updates';
    const updateLatenciesKey =
        'tagflow_semantic_patch_streaming_ai_authored_insertion_patches_'
        'update_latencies';
    final workspaceRoot = Directory.systemTemp.createTempSync(
      'tagflow_profile_summary_update_phases_test_',
    );
    addTearDown(() => workspaceRoot.deleteSync(recursive: true));

    final runDirectory = Directory(
      p.join(
        workspaceRoot.path,
        'build',
        'benchmarks',
        'profile',
        '2026-06-11-update-phases',
      ),
    )..createSync(recursive: true);

    File(
        p.join(
          runDirectory.path,
          'tagflow_semantic_patch',
          'streaming_ai_authored_insertion_patches',
          'repeat-01.json',
        ),
      )
      ..parent.createSync(recursive: true)
      ..writeAsStringSync(
        jsonEncode(<String, Object?>{
          scrollKey: <String, Object?>{
            'average_frame_build_time_millis': 0.2,
            '90th_percentile_frame_build_time_millis': 0.3,
            'worst_frame_build_time_millis': 0.5,
            'average_frame_rasterizer_time_millis': 0.8,
            '90th_percentile_frame_rasterizer_time_millis': 1.2,
            'worst_frame_rasterizer_time_millis': 3.8,
            'missed_frame_build_budget_count': 0,
            'missed_frame_rasterizer_budget_count': 0,
            'frame_count': 24,
            'new_gen_gc_count': 0,
            'old_gen_gc_count': 0,
          },
          updatesKey: <String, Object?>{
            'average_frame_build_time_millis': 1.1,
            '90th_percentile_frame_build_time_millis': 1.6,
            'worst_frame_build_time_millis': 3.2,
            'average_frame_rasterizer_time_millis': 2.2,
            '90th_percentile_frame_rasterizer_time_millis': 3.4,
            'worst_frame_rasterizer_time_millis': 5.6,
            'missed_frame_build_budget_count': 0,
            'missed_frame_rasterizer_budget_count': 0,
            'frame_count': 3,
            'new_gen_gc_count': 0,
            'old_gen_gc_count': 0,
          },
          updateLatenciesKey: <Object?>[
            <String, Object?>{
              'chunk': 1,
              'fraction': 0.33,
              'inputLength': 2000,
              'applyPatchMicros': 1800,
              'pumpWidgetMicros': 12000,
              'settleMicros': 95000,
              'elapsedMicros': 110118,
              'frameTimingAttribution': <String, Object?>{
                'frameCount': 2,
                'missedBuildBudgetCount': 0,
                'missedRasterBudgetCount': 0,
                'worstFrame': <String, Object?>{
                  'phase': 'settle',
                  'buildMillis': 4.2,
                  'rasterMillis': 7.8,
                  'buildOverBudget': false,
                  'rasterOverBudget': false,
                },
              },
            },
            <String, Object?>{
              'chunk': 2,
              'fraction': 0.66,
              'inputLength': 4000,
              'applyPatchMicros': 2400,
              'pumpWidgetMicros': 14000,
              'settleMicros': 98000,
              'elapsedMicros': 116790,
              'frameTimingAttribution': <String, Object?>{
                'frameCount': 2,
                'missedBuildBudgetCount': 0,
                'missedRasterBudgetCount': 0,
                'worstFrame': <String, Object?>{
                  'phase': 'pumpWidget',
                  'buildMillis': 9.7,
                  'rasterMillis': 6.1,
                  'buildOverBudget': false,
                  'rasterOverBudget': false,
                },
              },
            },
          ],
        }),
      );

    File(
      p.join(
        runDirectory.path,
        'tagflow_semantic_patch',
        'streaming_ai_authored_insertion_patches',
        'repeat-02.json',
      ),
    ).writeAsStringSync(
      jsonEncode(<String, Object?>{
        scrollKey: <String, Object?>{
          'average_frame_build_time_millis': 0.2,
          '90th_percentile_frame_build_time_millis': 0.3,
          'worst_frame_build_time_millis': 0.5,
          'average_frame_rasterizer_time_millis': 0.8,
          '90th_percentile_frame_rasterizer_time_millis': 1.2,
          'worst_frame_rasterizer_time_millis': 3.8,
          'missed_frame_build_budget_count': 0,
          'missed_frame_rasterizer_budget_count': 0,
          'frame_count': 24,
          'new_gen_gc_count': 0,
          'old_gen_gc_count': 0,
        },
        updatesKey: <String, Object?>{
          'average_frame_build_time_millis': 5.4,
          '90th_percentile_frame_build_time_millis': 8.9,
          'worst_frame_build_time_millis': 18.8,
          'average_frame_rasterizer_time_millis': 7.6,
          '90th_percentile_frame_rasterizer_time_millis': 14.2,
          'worst_frame_rasterizer_time_millis': 21.132,
          'missed_frame_build_budget_count': 0,
          'missed_frame_rasterizer_budget_count': 1,
          'frame_count': 3,
          'new_gen_gc_count': 0,
          'old_gen_gc_count': 0,
        },
        updateLatenciesKey: <Object?>[
          <String, Object?>{
            'chunk': 1,
            'fraction': 0.33,
            'inputLength': 2000,
            'applyPatchMicros': 1200,
            'pumpWidgetMicros': 9000,
            'settleMicros': 249315000,
            'elapsedMicros': 249327401,
            'frameTimingAttribution': <String, Object?>{
              'frameCount': 3,
              'missedBuildBudgetCount': 0,
              'missedRasterBudgetCount': 1,
              'worstFrame': <String, Object?>{
                'phase': 'unknown',
                'buildMillis': 8.4,
                'rasterMillis': 19.725,
                'buildOverBudget': false,
                'rasterOverBudget': true,
              },
            },
          },
          <String, Object?>{
            'chunk': 2,
            'fraction': 0.66,
            'inputLength': 4000,
            'applyPatchMicros': 1100,
            'pumpWidgetMicros': 16000,
            'settleMicros': 96800,
            'elapsedMicros': 114001,
            'frameTimingAttribution': <String, Object?>{
              'frameCount': 1,
              'missedBuildBudgetCount': 1,
              'missedRasterBudgetCount': 0,
              'worstFrame': <String, Object?>{
                'phase': 'pumpWidget',
                'buildMillis': 18.2,
                'rasterMillis': 5.0,
                'buildOverBudget': true,
                'rasterOverBudget': false,
              },
            },
          },
        ],
      }),
    );

    final manifestFile =
        File(p.join(runDirectory.path, 'profile-baseline-manifest.json'))
          ..writeAsStringSync(
            jsonEncode(<String, Object?>{
              'runId': '2026-06-11-update-phases',
              'runs': [
                <String, Object?>{
                  'renderer': 'tagflow_semantic_patch',
                  'fixture': 'streaming_ai_authored_insertion_patches',
                  'repeat': 1,
                  'status': 'passed',
                  'artifactPath':
                      'build/benchmarks/profile/2026-06-11-update-phases/'
                      'tagflow_semantic_patch/'
                      'streaming_ai_authored_insertion_patches/'
                      'repeat-01.json',
                },
                <String, Object?>{
                  'renderer': 'tagflow_semantic_patch',
                  'fixture': 'streaming_ai_authored_insertion_patches',
                  'repeat': 2,
                  'status': 'passed',
                  'artifactPath':
                      'build/benchmarks/profile/2026-06-11-update-phases/'
                      'tagflow_semantic_patch/'
                      'streaming_ai_authored_insertion_patches/'
                      'repeat-02.json',
                },
              ],
            }),
          );

    final summary = summarizeProfileBaselineManifest(
      manifestFile: manifestFile,
      clock: () => DateTime.utc(2026, 6, 11, 9, 30),
    );

    final cell = summary.cellSummaries.single;
    final updateSummary = cell.updateSummary!;
    expect(
      updateSummary.phaseMaxima.keys,
      containsAll(<String>[
        'applyPatchMicros',
        'pumpWidgetMicros',
        'settleMicros',
      ]),
    );
    expect(updateSummary.phaseMaxima['applyPatchMicros']!.maxMicros, 2400);
    expect(updateSummary.phaseMaxima['applyPatchMicros']!.repeat, 1);
    expect(updateSummary.phaseMaxima['pumpWidgetMicros']!.maxMicros, 16000);
    expect(updateSummary.phaseMaxima['pumpWidgetMicros']!.repeat, 2);
    expect(updateSummary.phaseMaxima['settleMicros']!.maxMicros, 249315000);
    expect(updateSummary.phaseMaxima['settleMicros']!.repeat, 2);
    expect(updateSummary.worstAttributedFrame, isNotNull);
    expect(updateSummary.worstAttributedFrame!.repeat, 2);
    expect(updateSummary.worstAttributedFrame!.chunk, 1);
    expect(updateSummary.worstAttributedFrame!.fraction, 0.33);
    expect(updateSummary.worstAttributedFrame!.phase, 'unknown');
    expect(updateSummary.worstAttributedFrame!.rasterOverBudget, isTrue);
    expect(
      updateSummary.worstAttributedFrame!.rasterMillis,
      closeTo(19.725, 0.0001),
    );
    expect(updateSummary.toJson(), contains('phaseMaxima'));
    expect(updateSummary.toJson(), contains('worstAttributedFrame'));

    expect(cell.outlierRepeats, hasLength(1));
    expect(
      cell.outlierRepeats.single.updatePhaseMaxima['settleMicros']!.maxMicros,
      249315000,
    );
    expect(cell.outlierRepeats.single.updateWorstAttributedFrame, isNotNull);
    expect(cell.outlierRepeats.single.updateWorstAttributedFrame!.chunk, 1);
    expect(
      cell.outlierRepeats.single.updateWorstAttributedFrame!.phase,
      'unknown',
    );
  });

  test('ignores null or missing phase timings safely', () {
    const scrollKey = 'tagflow_streaming_chunks_streaming_ai_chunks_scroll';
    const updateLatenciesKey =
        'tagflow_streaming_chunks_streaming_ai_chunks_update_latencies';
    final workspaceRoot = Directory.systemTemp.createTempSync(
      'tagflow_profile_summary_update_phase_nulls_test_',
    );
    addTearDown(() => workspaceRoot.deleteSync(recursive: true));

    final runDirectory = Directory(
      p.join(
        workspaceRoot.path,
        'build',
        'benchmarks',
        'profile',
        '2026-06-11-update-phase-nulls',
      ),
    )..createSync(recursive: true);

    File(
        p.join(
          runDirectory.path,
          'tagflow_streaming_chunks',
          'streaming_ai_chunks',
          'repeat-01.json',
        ),
      )
      ..parent.createSync(recursive: true)
      ..writeAsStringSync(
        jsonEncode(<String, Object?>{
          scrollKey: <String, Object?>{
            'average_frame_build_time_millis': 0.2,
            '90th_percentile_frame_build_time_millis': 0.3,
            'worst_frame_build_time_millis': 0.5,
            'average_frame_rasterizer_time_millis': 0.8,
            '90th_percentile_frame_rasterizer_time_millis': 1.2,
            'worst_frame_rasterizer_time_millis': 3.8,
            'missed_frame_build_budget_count': 0,
            'missed_frame_rasterizer_budget_count': 0,
            'frame_count': 24,
            'new_gen_gc_count': 0,
            'old_gen_gc_count': 0,
          },
          updateLatenciesKey: <Object?>[
            <String, Object?>{
              'chunk': 1,
              'fraction': 0.5,
              'inputLength': 2000,
              'applyPatchMicros': null,
              'pumpWidgetMicros': 7000,
              'settleMicros': 108000,
              'elapsedMicros': 115000,
            },
            <String, Object?>{
              'chunk': 2,
              'fraction': 1.0,
              'inputLength': 4000,
              'pumpWidgetMicros': 9000,
              'elapsedMicros': 118000,
            },
          ],
        }),
      );

    final manifestFile =
        File(p.join(runDirectory.path, 'profile-baseline-manifest.json'))
          ..writeAsStringSync(
            jsonEncode(<String, Object?>{
              'runId': '2026-06-11-update-phase-nulls',
              'runs': [
                <String, Object?>{
                  'renderer': 'tagflow_streaming_chunks',
                  'fixture': 'streaming_ai_chunks',
                  'repeat': 1,
                  'status': 'passed',
                  'artifactPath':
                      'build/benchmarks/profile/'
                      '2026-06-11-update-phase-nulls/'
                      'tagflow_streaming_chunks/streaming_ai_chunks/'
                      'repeat-01.json',
                },
              ],
            }),
          );

    final summary = summarizeProfileBaselineManifest(
      manifestFile: manifestFile,
      clock: () => DateTime.utc(2026, 6, 11, 10),
    );

    final updateSummary = summary.cellSummaries.single.updateSummary!;
    expect(updateSummary.observedUpdateCount, 2);
    expect(
      updateSummary.phaseMaxima.keys,
      containsAll(<String>['pumpWidgetMicros', 'settleMicros']),
    );
    expect(updateSummary.phaseMaxima.containsKey('applyPatchMicros'), isFalse);
    expect(updateSummary.phaseMaxima['pumpWidgetMicros']!.maxMicros, 9000);
    expect(updateSummary.phaseMaxima['settleMicros']!.maxMicros, 108000);
    expect(updateSummary.worstAttributedFrame, isNull);
  });
}
