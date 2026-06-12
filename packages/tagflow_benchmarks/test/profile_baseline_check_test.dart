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
    expect(result.reportOnlyFindings, isEmpty);
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
    expect(result.reportOnlyFindings, isEmpty);
  });

  test('surfaces unavailable launch attribution as a report-only finding', () {
    final summaryFile = _writeSummary(
      totalRuns: 1,
      successfulRuns: 1,
      cellSummaries: <Map<String, Object?>>[
        _cellSummary(
          renderer: 'tagflow',
          fixture: 'ai_answer_rich',
          repeats: 1,
          launchAttribution: <String, Object?>{
            'status': 'unavailable',
            'observedRepeats': 0,
            'missingRepeats': 1,
            'unavailableReasons': <String>['platform_not_supported'],
          },
        ),
      ],
    );
    addTearDown(() => summaryFile.parent.deleteSync(recursive: true));

    final result = checkProfileBaselineSummary(summaryFile: summaryFile);

    expect(result.passed, isTrue);
    expect(result.issues, isEmpty);
    expect(result.reportOnlyFindings, hasLength(1));
    expect(
      result.reportOnlyFindings.single.code,
      'launch_attribution_unavailable',
    );
    expect(
      result.reportOnlyFindings.single.details,
      containsPair('renderer', 'tagflow'),
    );
    expect(
      result.reportOnlyFindings.single.details['launchAttribution'],
      isA<Map<String, Object?>>(),
    );
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

  test('surfaces outlier repeats as report-only findings', () {
    final summaryFile = _writeSummary(
      totalRuns: 2,
      successfulRuns: 2,
      cellSummaries: <Map<String, Object?>>[
        _cellSummary(
          renderer: 'tagflow_semantic_patch',
          fixture: 'streaming_ai_authored_insertion_patches',
          repeats: 2,
          outlierRepeats: <Map<String, Object?>>[
            <String, Object?>{
              'repeat': 2,
              'artifactPath':
                  'build/benchmarks/profile/run/'
                  'tagflow_semantic_patch/repeat-02.json',
              'reasons': <String>[
                'update_latency_spike',
                'update_missed_raster_budget',
              ],
              'frameCount': 24,
              'worstBuildMillis': 0.5,
              'worstRasterMillis': 3.8,
              'missedBuildBudgetCount': 0,
              'missedRasterBudgetCount': 0,
              'oldGenGcCount': 0,
              'updateMaxElapsedMicros': 249327401,
              'updateWorstBuildMillis': 18.8,
              'updateWorstRasterMillis': 21.132,
              'updateMissedBuildBudgetCount': 0,
              'updateMissedRasterBudgetCount': 1,
              'updatePhaseMaxima': <String, Object?>{
                'settleMicros': <String, Object?>{
                  'maxMicros': 249315000,
                  'maxMillis': 249315.0,
                  'repeat': 2,
                  'chunk': 1,
                  'fraction': 0.33,
                  'inputLength': 2000,
                  'artifactPath':
                      'build/benchmarks/profile/run/'
                      'tagflow_semantic_patch/repeat-02.json',
                },
              },
              'updateWorstAttributedFrame': <String, Object?>{
                'repeat': 2,
                'chunk': 1,
                'fraction': 0.33,
                'inputLength': 2000,
                'phase': 'unknown',
                'buildMillis': 8.4,
                'rasterMillis': 19.725,
                'buildOverBudget': false,
                'rasterOverBudget': true,
                'artifactPath':
                    'build/benchmarks/profile/run/'
                    'tagflow_semantic_patch/repeat-02.json',
              },
            },
          ],
        ),
      ],
    );
    addTearDown(() => summaryFile.parent.deleteSync(recursive: true));

    final result = checkProfileBaselineSummary(summaryFile: summaryFile);

    expect(result.passed, isTrue);
    expect(result.issues, isEmpty);
    expect(result.reportOnlyFindings, hasLength(1));
    expect(result.reportOnlyFindings.single.code, 'outlier_repeat_present');
    expect(
      result.reportOnlyFindings.single.details,
      containsPair('renderer', 'tagflow_semantic_patch'),
    );
    expect(result.reportOnlyFindings.single.details, containsPair('repeat', 2));
    expect(
      result.reportOnlyFindings.single.details,
      containsPair('reasons', <String>[
        'update_latency_spike',
        'update_missed_raster_budget',
      ]),
    );
    final updatePhaseMaxima =
        result.reportOnlyFindings.single.details['updatePhaseMaxima'];
    expect(updatePhaseMaxima, isA<Map<String, Object?>>());
    final settleMicros = switch (updatePhaseMaxima) {
      final Map<String, Object?> phaseMaxima => phaseMaxima['settleMicros'],
      _ => null,
    };
    expect(settleMicros, containsPair('maxMicros', 249315000));
    final worstAttributedFrame =
        result.reportOnlyFindings.single.details['updateWorstAttributedFrame'];
    expect(worstAttributedFrame, isA<Map<String, Object?>>());
    expect(worstAttributedFrame, containsPair('chunk', 1));
    expect(worstAttributedFrame, containsPair('fraction', 0.33));
    expect(worstAttributedFrame, containsPair('phase', 'unknown'));
    expect(result.toJson(), contains('reportOnlyFindings'));
  });

  test('surfaces memory allocation lanes as report-only findings', () {
    final summaryFile = _writeSummary(
      totalRuns: 5,
      successfulRuns: 5,
      cellSummaries: <Map<String, Object?>>[
        _cellSummary(
          renderer: 'tagflow',
          fixture: 'large_article',
          repeats: 5,
          newGenGcCount: _countSummary(max: 2, total: 6),
          oldGenGcCount: _countSummary(max: 0, total: 0),
        ),
        _cellSummary(
          renderer: 'tagflow',
          fixture: 'ai_answer_rich',
          repeats: 5,
          newGenGcCount: _countSummary(max: 1, total: 2),
          oldGenGcCount: _countSummary(max: 0, total: 0),
        ),
      ],
    );
    addTearDown(() => summaryFile.parent.deleteSync(recursive: true));

    final result = checkProfileBaselineSummary(summaryFile: summaryFile);

    expect(result.passed, isTrue);
    expect(result.issues, isEmpty);
    expect(result.reportOnlyFindings, hasLength(1));
    expect(
      result.reportOnlyFindings.single.code,
      'memory_allocation_evidence_required',
    );
    expect(
      result.reportOnlyFindings.single.details,
      containsPair('evidenceLane', 'tagflow:large_article'),
    );
    expect(
      result.reportOnlyFindings.single.details['requiredEvidence'],
      containsAll(<String>[
        'devtools_memory_export',
        'allocation_profile_or_snapshot_diff',
        'reviewed_baseline_note',
      ]),
    );
  });

  test('surfaces old-gen GC activity as a report-only finding', () {
    final summaryFile = _writeSummary(
      totalRuns: 5,
      successfulRuns: 5,
      cellSummaries: <Map<String, Object?>>[
        _cellSummary(
          renderer: 'tagflow_semantic_patch',
          fixture: 'streaming_ai_authored_insertion_patches',
          repeats: 5,
          newGenGcCount: _countSummary(max: 3, total: 8),
          oldGenGcCount: _countSummary(max: 1, total: 1),
        ),
      ],
    );
    addTearDown(() => summaryFile.parent.deleteSync(recursive: true));

    final result = checkProfileBaselineSummary(summaryFile: summaryFile);

    expect(result.passed, isTrue);
    expect(result.issues, isEmpty);
    expect(
      result.reportOnlyFindings.map((finding) => finding.code),
      containsAll(<String>[
        'memory_allocation_evidence_required',
        'old_gen_gc_review_required',
      ]),
    );
    final oldGenFinding = result.reportOnlyFindings.singleWhere(
      (finding) => finding.code == 'old_gen_gc_review_required',
    );
    expect(
      oldGenFinding.details,
      containsPair('fixture', 'streaming_ai_authored_insertion_patches'),
    );
    expect(oldGenFinding.details['oldGenGcCount'], containsPair('total', 1));
  });

  test('loads a report-only check policy from JSON', () {
    final policyFile = _writePolicy(includeMatrix: true);
    addTearDown(() => policyFile.parent.deleteSync(recursive: true));

    final policy = ProfileBaselineCheckPolicy.fromFile(policyFile);

    expect(policy.id, 'tagflow-alpha-macos-reference-report-only');
    expect(policy.matrix?.renderers, <String>{'tagflow'});
    expect(policy.matrix?.fixtures, <String>{'ai_answer_rich'});
    expect(policy.minRepeats, 5);
    expect(policy.viewportMode, ProfileBaselineViewportPolicyMode.observedHost);
    expect(policy.thresholdMode, 'report_only');
    expect(policy.expectedViewport?.logicalWidth, 800);
    expect(policy.expectedViewport?.logicalHeight, 600);
    expect(policy.expectedViewport?.devicePixelRatio, 2);
  });

  test('defaults missing policy viewport mode to observed-host', () {
    final policyFile = _writePolicy(includeViewportMode: false);
    addTearDown(() => policyFile.parent.deleteSync(recursive: true));

    final policy = ProfileBaselineCheckPolicy.fromFile(policyFile);

    expect(policy.viewportMode, ProfileBaselineViewportPolicyMode.observedHost);
  });

  test('rejects synthetic policy without expected viewport', () {
    final policyFile = _writePolicy(
      viewportMode: 'synthetic',
      includeExpectedViewport: false,
    );
    addTearDown(() => policyFile.parent.deleteSync(recursive: true));

    expect(
      () => ProfileBaselineCheckPolicy.fromFile(policyFile),
      throwsA(isA<FormatException>()),
    );
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

  test('policy matrix rejects undeclared renderer fixture cells', () {
    final policyFile = _writePolicy(
      includeMatrix: true,
      viewportMode: 'synthetic',
      minRepeats: 1,
    );
    final summaryFile = _writeSummary(
      totalRuns: 1,
      successfulRuns: 1,
      cellSummaries: <Map<String, Object?>>[
        _cellSummary(
          renderer: 'tagflow',
          fixture: 'table_stress',
          repeats: 1,
          viewportModes: <Map<String, Object?>>[_syntheticViewportMode()],
        ),
      ],
    );
    addTearDown(() => policyFile.parent.deleteSync(recursive: true));
    addTearDown(() => summaryFile.parent.deleteSync(recursive: true));

    final result = checkProfileBaselineSummary(
      summaryFile: summaryFile,
      policy: ProfileBaselineCheckPolicy.fromFile(policyFile),
    );

    expect(result.passed, isFalse);
    expect(
      result.issues.map((issue) => issue.code),
      contains('cell_outside_policy_matrix'),
    );
    final matrixIssue = result.issues.singleWhere(
      (issue) => issue.code == 'cell_outside_policy_matrix',
    );
    expect(matrixIssue.details, containsPair('fixture', 'table_stress'));
    expect(
      matrixIssue.details['policyMatrix'],
      containsPair('fixtures', <String>['ai_answer_rich']),
    );
  });

  test('observed-host policy rejects synthetic viewport metadata', () {
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
          viewportModes: <Map<String, Object?>>[_syntheticViewportMode()],
        ),
      ],
    );
    addTearDown(() => policyFile.parent.deleteSync(recursive: true));
    addTearDown(() => summaryFile.parent.deleteSync(recursive: true));

    final result = checkProfileBaselineSummary(
      summaryFile: summaryFile,
      policy: ProfileBaselineCheckPolicy.fromFile(policyFile),
    );

    expect(result.passed, isFalse);
    expect(result.issues.single.code, 'synthetic_viewport_not_allowed');
    expect(
      result.issues.single.details,
      containsPair('policyViewportMode', 'observed_host'),
    );
  });

  test('synthetic policy fails when synthetic mode metadata is missing', () {
    final policyFile = _writePolicy(viewportMode: 'synthetic', minRepeats: 1);
    final summaryFile = _writeSummary(
      totalRuns: 1,
      successfulRuns: 1,
      cellSummaries: <Map<String, Object?>>[
        _cellSummary(
          renderer: 'tagflow',
          fixture: 'ai_answer_rich',
          repeats: 1,
        ),
      ],
    );
    addTearDown(() => policyFile.parent.deleteSync(recursive: true));
    addTearDown(() => summaryFile.parent.deleteSync(recursive: true));

    final result = checkProfileBaselineSummary(
      summaryFile: summaryFile,
      policy: ProfileBaselineCheckPolicy.fromFile(policyFile),
    );

    expect(result.passed, isFalse);
    expect(result.issues.single.code, 'missing_synthetic_viewport_mode');
  });

  test('synthetic policy fails when requested metadata is missing', () {
    final policyFile = _writePolicy(viewportMode: 'synthetic', minRepeats: 1);
    final summaryFile = _writeSummary(
      totalRuns: 1,
      successfulRuns: 1,
      cellSummaries: <Map<String, Object?>>[
        _cellSummary(
          renderer: 'tagflow',
          fixture: 'ai_answer_rich',
          repeats: 1,
          viewportModes: <Map<String, Object?>>[
            _syntheticViewportMode(requested: null),
          ],
        ),
      ],
    );
    addTearDown(() => policyFile.parent.deleteSync(recursive: true));
    addTearDown(() => summaryFile.parent.deleteSync(recursive: true));

    final result = checkProfileBaselineSummary(
      summaryFile: summaryFile,
      policy: ProfileBaselineCheckPolicy.fromFile(policyFile),
    );

    expect(result.passed, isFalse);
    expect(result.issues.single.code, 'missing_synthetic_requested_viewport');
  });

  test('synthetic policy fails when requested metadata mismatches policy', () {
    final policyFile = _writePolicy(viewportMode: 'synthetic', minRepeats: 1);
    final summaryFile = _writeSummary(
      totalRuns: 1,
      successfulRuns: 1,
      cellSummaries: <Map<String, Object?>>[
        _cellSummary(
          renderer: 'tagflow',
          fixture: 'ai_answer_rich',
          repeats: 1,
          viewportModes: <Map<String, Object?>>[
            _syntheticViewportMode(
              requested: <String, Object?>{
                'logicalWidth': 390.0,
                'logicalHeight': 844.0,
                'devicePixelRatio': 3.0,
              },
            ),
          ],
        ),
      ],
    );
    addTearDown(() => policyFile.parent.deleteSync(recursive: true));
    addTearDown(() => summaryFile.parent.deleteSync(recursive: true));

    final result = checkProfileBaselineSummary(
      summaryFile: summaryFile,
      policy: ProfileBaselineCheckPolicy.fromFile(policyFile),
    );

    expect(result.passed, isFalse);
    expect(
      result.issues.single.code,
      'unexpected_synthetic_requested_viewport',
    );
    expect(result.issues.single.details, contains('observedRequestedViewport'));
  });

  test('synthetic policy fails when applied metadata is missing', () {
    final policyFile = _writePolicy(viewportMode: 'synthetic', minRepeats: 1);
    final summaryFile = _writeSummary(
      totalRuns: 1,
      successfulRuns: 1,
      cellSummaries: <Map<String, Object?>>[
        _cellSummary(
          renderer: 'tagflow',
          fixture: 'ai_answer_rich',
          repeats: 1,
          viewportModes: <Map<String, Object?>>[
            _syntheticViewportMode(applied: null),
          ],
        ),
      ],
    );
    addTearDown(() => policyFile.parent.deleteSync(recursive: true));
    addTearDown(() => summaryFile.parent.deleteSync(recursive: true));

    final result = checkProfileBaselineSummary(
      summaryFile: summaryFile,
      policy: ProfileBaselineCheckPolicy.fromFile(policyFile),
    );

    expect(result.passed, isFalse);
    expect(result.issues.single.code, 'missing_synthetic_applied_viewport');
  });

  test('synthetic policy fails when applied metadata mismatches policy', () {
    final policyFile = _writePolicy(viewportMode: 'synthetic', minRepeats: 1);
    final summaryFile = _writeSummary(
      totalRuns: 1,
      successfulRuns: 1,
      cellSummaries: <Map<String, Object?>>[
        _cellSummary(
          renderer: 'tagflow',
          fixture: 'ai_answer_rich',
          repeats: 1,
          viewportModes: <Map<String, Object?>>[
            _syntheticViewportMode(
              applied: _viewport(
                logicalWidth: 1024,
                logicalHeight: 768,
                devicePixelRatio: 2,
              ),
            ),
          ],
        ),
      ],
    );
    addTearDown(() => policyFile.parent.deleteSync(recursive: true));
    addTearDown(() => summaryFile.parent.deleteSync(recursive: true));

    final result = checkProfileBaselineSummary(
      summaryFile: summaryFile,
      policy: ProfileBaselineCheckPolicy.fromFile(policyFile),
    );

    expect(result.passed, isFalse);
    expect(result.issues.single.code, 'unexpected_synthetic_applied_viewport');
    expect(result.issues.single.details, contains('observedAppliedViewport'));
  });

  test('synthetic policy fails when host metadata is missing', () {
    final policyFile = _writePolicy(viewportMode: 'synthetic', minRepeats: 1);
    final summaryFile = _writeSummary(
      totalRuns: 1,
      successfulRuns: 1,
      cellSummaries: <Map<String, Object?>>[
        _cellSummary(
          renderer: 'tagflow',
          fixture: 'ai_answer_rich',
          repeats: 1,
          viewportModes: <Map<String, Object?>>[
            _syntheticViewportMode(observedHostBeforeOverride: null),
          ],
        ),
      ],
    );
    addTearDown(() => policyFile.parent.deleteSync(recursive: true));
    addTearDown(() => summaryFile.parent.deleteSync(recursive: true));

    final result = checkProfileBaselineSummary(
      summaryFile: summaryFile,
      policy: ProfileBaselineCheckPolicy.fromFile(policyFile),
    );

    expect(result.passed, isFalse);
    expect(result.issues.single.code, 'missing_synthetic_host_viewport');
  });

  test(
    'synthetic policy passes collection quality with report-only finding',
    () {
      final policyFile = _writePolicy(viewportMode: 'synthetic', minRepeats: 1);
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
                logicalWidth: 800,
                logicalHeight: 600,
                devicePixelRatio: 2,
              ),
            ],
            viewportModes: <Map<String, Object?>>[_syntheticViewportMode()],
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
      expect(result.issues, isEmpty);
      expect(
        result.policy!.viewportMode,
        ProfileBaselineViewportPolicyMode.synthetic,
      );
      expect(
        result.reportOnlyFindings.map((finding) => finding.code),
        contains('synthetic_viewport_not_reference_target'),
      );
    },
  );

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
  List<Map<String, Object?>> viewportModes = const <Map<String, Object?>>[],
  List<Map<String, Object?>> outlierRepeats = const <Map<String, Object?>>[],
  Map<String, Object?>? launchAttribution,
  Map<String, Object?>? newGenGcCount,
  Map<String, Object?>? oldGenGcCount,
}) => <String, Object?>{
  'renderer': renderer,
  'fixture': fixture,
  'observedRepeats': repeats,
  if (newGenGcCount != null) 'newGenGcCount': newGenGcCount,
  if (oldGenGcCount != null) 'oldGenGcCount': oldGenGcCount,
  'viewports': viewports,
  if (viewportModes.isNotEmpty) 'viewportModes': viewportModes,
  'launchAttribution':
      launchAttribution ??
      <String, Object?>{
        'status': 'available',
        'observedRepeats': repeats,
        'missingRepeats': 0,
        'provenances': <String>['macos_app_delegate_uptime_markers_v1'],
        'scopes': <String>['local_runner_only'],
        'intervalMicros': <String, Object?>{
          'appDelegateInitToIntegrationTestRequestMicros': <String, Object?>{
            'min': 43000.0,
            'max': 43000.0,
            'mean': 43000.0,
            'median': 43000.0,
          },
        },
        'unavailableReasons': <String>[],
      },
  'outlierRepeats': outlierRepeats,
};

Map<String, Object?> _countSummary({required int max, required int total}) {
  return <String, Object?>{
    'min': 0,
    'max': max,
    'total': total,
    'mean': total / 5,
  };
}

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

Map<String, Object?> _syntheticViewportMode({
  Map<String, Object?>? requested = const <String, Object?>{
    'logicalWidth': 800.0,
    'logicalHeight': 600.0,
    'devicePixelRatio': 2.0,
  },
  Map<String, Object?>? observedHostBeforeOverride = const <String, Object?>{
    'logicalWidth': 800.0,
    'logicalHeight': 600.0,
    'physicalWidth': 800.0,
    'physicalHeight': 600.0,
    'devicePixelRatio': 1.0,
  },
  Map<String, Object?>? applied = const <String, Object?>{
    'logicalWidth': 800.0,
    'logicalHeight': 600.0,
    'physicalWidth': 1600.0,
    'physicalHeight': 1200.0,
    'devicePixelRatio': 2.0,
  },
}) {
  return <String, Object?>{
    'schemaVersion': 1,
    'mode': 'synthetic',
    'requested': requested,
    'observedHostBeforeOverride': observedHostBeforeOverride,
    'applied': applied,
    'caveats': <String>[
      'test_view_override',
      'not_real_display_scale',
      'not_public_reference_target',
    ],
  };
}

File _writePolicy({
  String thresholdMode = 'report_only',
  String viewportMode = 'observed_host',
  int minRepeats = 5,
  bool includeMatrix = false,
  bool includeViewportMode = true,
  bool includeExpectedViewport = true,
}) {
  final directory = Directory.systemTemp.createTempSync(
    'tagflow_profile_policy_test_',
  );
  return File(p.join(directory.path, 'profile-policy.json'))..writeAsStringSync(
    jsonEncode(<String, Object?>{
      'schemaVersion': 1,
      'id': 'tagflow-alpha-macos-reference-report-only',
      if (includeMatrix)
        'matrix': <String, Object?>{
          'renderers': <String>['tagflow'],
          'fixtures': <String>['ai_answer_rich'],
        },
      'check': <String, Object?>{
        'minRepeats': minRepeats,
        if (includeViewportMode) 'viewportMode': viewportMode,
        if (includeExpectedViewport)
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
