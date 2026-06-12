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
          'tagflow_ai_answer_rich_launch_attribution': <String, Object?>{
            'schemaVersion': 1,
            'status': 'available',
            'host': 'macos',
            'scope': 'local_runner_only',
            'provenance': 'macos_app_delegate_uptime_markers_v1',
            'intervals': <String, Object?>{
              'appDelegateInitToDidFinishLaunchingMicros': 2500,
              'appDelegateInitToFlutterViewControllerReadyMicros': 12000,
              'appDelegateInitToIntegrationTestRequestMicros': 43000,
            },
          },
          'tagflow_ai_answer_rich_input': <String, Object?>{
            'schemaVersion': 1,
            'sourceType': 'html',
            'assetPath': 'assets/benchmarks/ai_answer_rich.html',
            'inputLength': 1100,
            'inputBytes': 1108,
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
        'tagflow_ai_answer_rich_launch_attribution': <String, Object?>{
          'schemaVersion': 1,
          'status': 'available',
          'host': 'macos',
          'scope': 'local_runner_only',
          'provenance': 'macos_app_delegate_uptime_markers_v1',
          'intervals': <String, Object?>{
            'appDelegateInitToDidFinishLaunchingMicros': 3000,
            'appDelegateInitToFlutterViewControllerReadyMicros': 13500,
            'appDelegateInitToIntegrationTestRequestMicros': 47000,
          },
        },
        'tagflow_ai_answer_rich_input': <String, Object?>{
          'schemaVersion': 1,
          'sourceType': 'html',
          'assetPath': 'assets/benchmarks/ai_answer_rich.html',
          'inputLength': 1100,
          'inputBytes': 1108,
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
                  'startedAt': '2026-06-11T07:00:00.000Z',
                  'finishedAt': '2026-06-11T07:00:01.000Z',
                  'artifactPath':
                      'build/benchmarks/profile/2026-06-11-reference/'
                      'tagflow/ai_answer_rich/repeat-01.json',
                },
                <String, Object?>{
                  'renderer': 'tagflow',
                  'fixture': 'ai_answer_rich',
                  'repeat': 2,
                  'status': 'passed',
                  'startedAt': '2026-06-11T07:01:00.000Z',
                  'finishedAt': '2026-06-11T07:01:02.000Z',
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
    expect(cell.inputSummary, isNotNull);
    expect(cell.inputSummary!.observedRepeats, 2);
    expect(cell.inputSummary!.inputBytes.min, 1108);
    expect(cell.inputSummary!.inputBytes.max, 1108);
    expect(cell.inputSummary!.inputLength.mean, 1100);
    expect(cell.inputSummary!.sourceTypes, ['html']);
    expect(cell.inputSummary!.assetPaths, [
      'assets/benchmarks/ai_answer_rich.html',
    ]);
    expect(cell.toJson(), contains('inputSummary'));
    expect(cell.launchAttribution.status, 'available');
    expect(cell.launchAttribution.observedRepeats, 2);
    expect(cell.launchAttribution.missingRepeats, 0);
    expect(
      cell.launchAttribution.caveats,
      containsAll(<String>[
        'not_process_cold_start',
        'command_envelope_includes_melos_flutter_drive_and_artifact_copy',
        'cold_initial_render_is_first_fixture_render_inside_integration_test',
      ]),
    );
    expect(cell.launchAttribution.commandEnvelope, isNotNull);
    expect(
      cell.launchAttribution.commandEnvelope!.scope,
      'flutter_drive_command_envelope',
    );
    expect(
      cell.launchAttribution.commandEnvelope!.isProcessColdStartMetric,
      isFalse,
    );
    expect(cell.launchAttribution.commandEnvelope!.observedRepeats, 2);
    expect(cell.launchAttribution.commandEnvelope!.durationMicros.min, 1000000);
    expect(cell.launchAttribution.commandEnvelope!.durationMicros.max, 2000000);
    expect(
      cell.launchAttribution.commandEnvelope!.startedAt.min,
      DateTime.utc(2026, 6, 11, 7),
    );
    expect(
      cell.launchAttribution.commandEnvelope!.finishedAt.max,
      DateTime.utc(2026, 6, 11, 7, 1, 2),
    );
    expect(cell.launchAttribution.firstFixtureRender, isNotNull);
    expect(
      cell.launchAttribution.firstFixtureRender!.phase,
      'coldInitialRender',
    );
    expect(
      cell.launchAttribution.firstFixtureRender!.isProcessColdStartMetric,
      isFalse,
    );
    expect(cell.launchAttribution.provenances, [
      'macos_app_delegate_uptime_markers_v1',
    ]);
    expect(
      cell.launchAttribution.intervalMicros.keys,
      containsAll(<String>[
        'appDelegateInitToDidFinishLaunchingMicros',
        'appDelegateInitToFlutterViewControllerReadyMicros',
        'appDelegateInitToIntegrationTestRequestMicros',
      ]),
    );
    expect(
      cell
          .launchAttribution
          .intervalMicros['appDelegateInitToIntegrationTestRequestMicros']!
          .max,
      47000,
    );
    expect(cell.toJson(), contains('launchAttribution'));
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
          'tagflow_ai_answer_rich_viewport_mode': <String, Object?>{
            'schemaVersion': 1,
            'mode': 'observedHost',
            'requested': null,
            'observedHostBeforeOverride': <String, Object?>{
              'logicalWidth': 800.0,
              'logicalHeight': 632.0,
              'physicalWidth': 1600.0,
              'physicalHeight': 1264.0,
              'devicePixelRatio': 2.0,
            },
            'applied': null,
            'caveats': <String>[],
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
    expect(summary.cellSummaries.single.viewportModes, hasLength(1));
    expect(
      summary.cellSummaries.single.viewportModes.single.mode,
      'observedHost',
    );
    expect(summary.cellSummaries.single.viewportModes.single.requested, isNull);
    expect(
      summary
          .cellSummaries
          .single
          .viewportModes
          .single
          .observedHostBeforeOverride!
          .logicalWidth,
      800.0,
    );
    expect(summary.cellSummaries.single.viewportModes.single.applied, isNull);
    expect(summary.cellSummaries.single.viewportModes.single.caveats, isEmpty);
    expect(
      summary.cellSummaries.single.toJson(),
      containsPair('viewportModes', <Object?>[
        <String, Object?>{
          'schemaVersion': 1,
          'mode': 'observedHost',
          'requested': null,
          'observedHostBeforeOverride': <String, Object?>{
            'logicalWidth': 800.0,
            'logicalHeight': 632.0,
            'physicalWidth': 1600.0,
            'physicalHeight': 1264.0,
            'devicePixelRatio': 2.0,
          },
          'applied': null,
          'caveats': <String>[],
        },
      ]),
    );
    expect(summary.cellSummaries.single.inputSummary, isNull);
    expect(
      summary.cellSummaries.single.toJson().containsKey('updateSummary'),
      isFalse,
    );
    expect(
      summary.cellSummaries.single.launchAttribution.status,
      'unavailable',
    );
    expect(summary.cellSummaries.single.launchAttribution.unavailableReasons, [
      'missing_launch_attribution_payload',
    ]);
    expect(
      summary.cellSummaries.single.launchAttribution.commandEnvelope,
      isNull,
    );
    expect(
      summary.cellSummaries.single.launchAttribution.caveats,
      contains('not_process_cold_start'),
    );
  });

  test('parses synthetic requested viewport mode metadata', () {
    final workspaceRoot = Directory.systemTemp.createTempSync(
      'tagflow_profile_summary_synthetic_viewport_test_',
    );
    addTearDown(() => workspaceRoot.deleteSync(recursive: true));

    final runDirectory = Directory(
      p.join(workspaceRoot.path, 'build', 'benchmarks', 'profile', 'synthetic'),
    )..createSync(recursive: true);
    final artifactPath = p.join(
      'build',
      'benchmarks',
      'profile',
      'synthetic',
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
          'tagflow_ai_answer_rich_viewport_mode': <String, Object?>{
            'schemaVersion': 1,
            'mode': 'synthetic',
            'requested': <String, Object?>{
              'logicalWidth': 800.0,
              'logicalHeight': 600.0,
              'devicePixelRatio': 2.0,
            },
            'observedHostBeforeOverride': <String, Object?>{
              'logicalWidth': 800.0,
              'logicalHeight': 600.0,
              'physicalWidth': 800.0,
              'physicalHeight': 600.0,
              'devicePixelRatio': 1.0,
            },
            'applied': <String, Object?>{
              'logicalWidth': 800.0,
              'logicalHeight': 600.0,
              'physicalWidth': 1600.0,
              'physicalHeight': 1200.0,
              'devicePixelRatio': 2.0,
            },
            'caveats': <String>['test_view_override'],
          },
        }),
      );

    final manifestFile =
        File(p.join(runDirectory.path, 'profile-baseline-manifest.json'))
          ..writeAsStringSync(
            jsonEncode(<String, Object?>{
              'runId': 'synthetic',
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
      clock: () => DateTime.utc(2026, 6, 12, 10),
    );

    final viewportMode = summary.cellSummaries.single.viewportModes.single;
    expect(viewportMode.mode, 'synthetic');
    expect(viewportMode.requested!.logicalWidth, 800.0);
    expect(viewportMode.requested!.logicalHeight, 600.0);
    expect(viewportMode.requested!.devicePixelRatio, 2.0);
    expect(viewportMode.observedHostBeforeOverride!.devicePixelRatio, 1.0);
    expect(viewportMode.applied!.physicalWidth, 1600.0);
    expect(viewportMode.caveats, ['test_view_override']);
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
