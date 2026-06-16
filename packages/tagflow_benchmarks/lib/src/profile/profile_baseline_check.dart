import 'dart:convert';
import 'dart:io';

/// Expected viewport metadata for a stable benchmark environment.
final class ProfileBaselineExpectedViewport {
  /// Creates an expected viewport guard.
  const ProfileBaselineExpectedViewport({
    required this.logicalWidth,
    required this.logicalHeight,
    required this.devicePixelRatio,
  });

  /// Reads expected viewport metadata from machine-readable policy JSON.
  factory ProfileBaselineExpectedViewport.fromJson(Map<String, Object?> json) {
    final viewport = ProfileBaselineExpectedViewport(
      logicalWidth: _readDouble(json, 'logicalWidth'),
      logicalHeight: _readDouble(json, 'logicalHeight'),
      devicePixelRatio: _readDouble(json, 'devicePixelRatio'),
    );
    if (viewport.logicalWidth <= 0 ||
        viewport.logicalHeight <= 0 ||
        viewport.devicePixelRatio <= 0) {
      throw const FormatException(
        'Expected viewport values must be greater than 0.',
      );
    }
    return viewport;
  }

  /// Expected logical Flutter view width.
  final double logicalWidth;

  /// Expected logical Flutter view height.
  final double logicalHeight;

  /// Expected Flutter view device-pixel ratio.
  final double devicePixelRatio;

  /// Converts this viewport guard to machine-readable JSON.
  Map<String, Object?> toJson() => <String, Object?>{
    'logicalWidth': logicalWidth,
    'logicalHeight': logicalHeight,
    'devicePixelRatio': devicePixelRatio,
  };

  bool matches(Map<String, Object?> viewport) {
    return _readDouble(viewport, 'logicalWidth') == logicalWidth &&
        _readDouble(viewport, 'logicalHeight') == logicalHeight &&
        _readDouble(viewport, 'devicePixelRatio') == devicePixelRatio;
  }
}

/// Renderer/fixture allowlist declared by a profile baseline policy.
final class ProfileBaselinePolicyMatrix {
  /// Creates a profile baseline policy matrix.
  const ProfileBaselinePolicyMatrix({
    required this.renderers,
    required this.fixtures,
  });

  /// Reads a policy matrix from machine-readable JSON.
  factory ProfileBaselinePolicyMatrix.fromJson(Map<String, Object?> json) {
    final matrix = ProfileBaselinePolicyMatrix(
      renderers: _readStringSet(json, 'renderers'),
      fixtures: _readStringSet(json, 'fixtures'),
    );
    if (matrix.renderers.isEmpty || matrix.fixtures.isEmpty) {
      throw const FormatException(
        'Profile baseline policy matrix renderers and fixtures must not be '
        'empty.',
      );
    }
    return matrix;
  }

  /// Renderer ids accepted by this policy.
  final Set<String> renderers;

  /// Fixture ids accepted by this policy.
  final Set<String> fixtures;

  /// Converts this policy matrix to machine-readable JSON.
  Map<String, Object?> toJson() => <String, Object?>{
    'renderers': renderers.toList(growable: false),
    'fixtures': fixtures.toList(growable: false),
  };

  /// Returns whether [cell] belongs to this policy matrix.
  bool containsCell(Map<String, Object?> cell) {
    return renderers.contains(cell['renderer']) &&
        fixtures.contains(cell['fixture']);
  }
}

/// Viewport metadata policy for a profile baseline check.
enum ProfileBaselineViewportPolicyMode {
  /// Require a real observed-host viewport and reject synthetic metadata.
  observedHost,

  /// Require synthetic requested/applied metadata.
  synthetic,
}

/// Machine-readable policy for the profile baseline checker.
final class ProfileBaselineCheckPolicy {
  /// Creates a profile baseline check policy.
  const ProfileBaselineCheckPolicy({
    required this.id,
    required this.matrix,
    required this.minRepeats,
    required this.viewportMode,
    required this.expectedViewport,
    required this.thresholdMode,
  });

  /// Reads a checker policy from a JSON file.
  factory ProfileBaselineCheckPolicy.fromFile(File file) {
    final decoded = jsonDecode(file.readAsStringSync());
    if (decoded is! Map<String, Object?>) {
      throw const FormatException(
        'Profile baseline policy must be a JSON map.',
      );
    }
    return ProfileBaselineCheckPolicy.fromJson(decoded);
  }

  /// Reads a checker policy from machine-readable JSON.
  factory ProfileBaselineCheckPolicy.fromJson(Map<String, Object?> json) {
    final schemaVersion = json['schemaVersion'];
    if (schemaVersion != 1) {
      throw const FormatException(
        'Profile baseline policy schemaVersion must be 1.',
      );
    }

    final id = json['id'];
    if (id is! String || id.trim().isEmpty) {
      throw const FormatException(
        'Profile baseline policy id must be a non-empty string.',
      );
    }

    final check = json['check'];
    if (check is! Map<String, Object?>) {
      throw const FormatException(
        'Profile baseline policy check must be a map.',
      );
    }

    final rawMatrix = json['matrix'];
    final ProfileBaselinePolicyMatrix? matrix;
    if (rawMatrix == null) {
      matrix = null;
    } else if (rawMatrix is Map<String, Object?>) {
      matrix = ProfileBaselinePolicyMatrix.fromJson(rawMatrix);
    } else {
      throw const FormatException(
        'Profile baseline policy matrix must be a map.',
      );
    }

    final minRepeats = check['minRepeats'];
    if (minRepeats is! int || minRepeats < 1) {
      throw const FormatException(
        'Profile baseline policy check.minRepeats must be an integer >= 1.',
      );
    }

    final viewportMode = _readViewportPolicyMode(check['viewportMode']);

    final thresholdPolicy = json['thresholdPolicy'];
    if (thresholdPolicy is! Map<String, Object?>) {
      throw const FormatException(
        'Profile baseline policy thresholdPolicy must be a map.',
      );
    }

    final thresholdMode = thresholdPolicy['mode'];
    if (thresholdMode is! String || thresholdMode != 'report_only') {
      throw const FormatException(
        'Profile baseline policy thresholdPolicy.mode must be report_only.',
      );
    }

    final rawExpectedViewport = check['expectedViewport'];
    final ProfileBaselineExpectedViewport? expectedViewport;
    if (rawExpectedViewport == null) {
      expectedViewport = null;
    } else if (rawExpectedViewport is Map<String, Object?>) {
      expectedViewport = ProfileBaselineExpectedViewport.fromJson(
        rawExpectedViewport,
      );
    } else {
      throw const FormatException(
        'Profile baseline policy check.expectedViewport must be a map.',
      );
    }

    if (viewportMode == ProfileBaselineViewportPolicyMode.synthetic &&
        expectedViewport == null) {
      throw const FormatException(
        'Synthetic profile baseline policy requires check.expectedViewport.',
      );
    }

    return ProfileBaselineCheckPolicy(
      id: id,
      matrix: matrix,
      minRepeats: minRepeats,
      viewportMode: viewportMode,
      expectedViewport: expectedViewport,
      thresholdMode: thresholdMode,
    );
  }

  /// Stable policy id.
  final String id;

  /// Optional renderer/fixture matrix this policy is allowed to qualify.
  final ProfileBaselinePolicyMatrix? matrix;

  /// Minimum successful repeat count per renderer/fixture cell.
  final int minRepeats;

  /// Viewport metadata mode required by this policy.
  final ProfileBaselineViewportPolicyMode viewportMode;

  /// Expected viewport for a pinned reference runner, when known.
  final ProfileBaselineExpectedViewport? expectedViewport;

  /// Threshold behavior for performance metrics.
  ///
  /// Alpha policies must stay `report_only` until a stable reference
  /// environment and numeric regression policy are reviewed.
  final String thresholdMode;

  /// Converts this policy to machine-readable JSON.
  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    if (matrix != null) 'matrix': matrix!.toJson(),
    'minRepeats': minRepeats,
    'viewportMode': _viewportPolicyModeValue(viewportMode),
    'expectedViewport': expectedViewport?.toJson(),
    'thresholdMode': thresholdMode,
  };
}

/// Machine-checkable result for a profile baseline summary.
final class ProfileBaselineCheckResult {
  /// Creates a profile baseline check result.
  const ProfileBaselineCheckResult({
    required this.summaryPath,
    required this.minRepeats,
    required this.policy,
    required this.passed,
    required this.issues,
    required this.reportOnlyFindings,
  });

  /// Checked `profile-baseline-summary.json` path.
  final String summaryPath;

  /// Required successful repeat count per renderer/fixture cell.
  final int minRepeats;

  /// Policy applied by the check, when one was provided.
  final ProfileBaselineCheckPolicy? policy;

  /// Whether the summary satisfies collection-completeness invariants.
  final bool passed;

  /// Issues found while checking the summary.
  final List<ProfileBaselineCheckIssue> issues;

  /// Reviewer-visible findings that do not affect pass/fail.
  final List<ProfileBaselineCheckIssue> reportOnlyFindings;

  /// Converts this result to machine-readable JSON.
  Map<String, Object?> toJson() => <String, Object?>{
    'summaryPath': summaryPath,
    'minRepeats': minRepeats,
    if (policy != null) 'policy': policy!.toJson(),
    'passed': passed,
    'issues': issues.map((issue) => issue.toJson()).toList(),
    'reportOnlyFindings': reportOnlyFindings
        .map((finding) => finding.toJson())
        .toList(),
  };
}

/// A collection-completeness issue in a profile baseline summary.
final class ProfileBaselineCheckIssue {
  /// Creates a profile baseline check issue.
  const ProfileBaselineCheckIssue({
    required this.code,
    required this.message,
    required this.details,
  });

  /// Stable issue code for automation.
  final String code;

  /// Reviewer-facing issue message.
  final String message;

  /// Machine-readable issue details.
  final Map<String, Object?> details;

  /// Converts this issue to machine-readable JSON.
  Map<String, Object?> toJson() => <String, Object?>{
    'code': code,
    'message': message,
    'details': details,
  };
}

/// Checks a profile baseline summary without introducing performance gates.
ProfileBaselineCheckResult checkProfileBaselineSummary({
  required File summaryFile,
  int? minRepeats,
  ProfileBaselineExpectedViewport? expectedViewport,
  ProfileBaselineCheckPolicy? policy,
}) {
  final effectiveMinRepeats = minRepeats ?? policy?.minRepeats ?? 1;
  final effectiveViewport = expectedViewport ?? policy?.expectedViewport;
  final effectiveViewportMode =
      policy?.viewportMode ?? ProfileBaselineViewportPolicyMode.observedHost;
  if (effectiveMinRepeats < 1) {
    throw ArgumentError.value(
      effectiveMinRepeats,
      'minRepeats',
      'Must be at least 1.',
    );
  }

  final summary =
      jsonDecode(summaryFile.readAsStringSync()) as Map<String, Object?>;
  final totalRuns = summary['totalRuns']! as int;
  final successfulRuns = summary['successfulRuns']! as int;
  final failedRuns = (summary['failedRuns']! as List<Object?>)
      .cast<Map<String, Object?>>();
  final cellSummaries = (summary['cellSummaries']! as List<Object?>)
      .cast<Map<String, Object?>>();

  final issues = <ProfileBaselineCheckIssue>[];
  final reportOnlyFindings = <ProfileBaselineCheckIssue>[];

  if (failedRuns.isNotEmpty) {
    issues.add(
      ProfileBaselineCheckIssue(
        code: 'failed_runs_present',
        message: 'The profile baseline summary contains failed runs.',
        details: <String, Object?>{
          'failedRunCount': failedRuns.length,
          'failedRuns': failedRuns,
        },
      ),
    );
  }

  if (successfulRuns != totalRuns) {
    issues.add(
      ProfileBaselineCheckIssue(
        code: 'successful_runs_mismatch',
        message: 'successfulRuns must match totalRuns.',
        details: <String, Object?>{
          'successfulRuns': successfulRuns,
          'totalRuns': totalRuns,
        },
      ),
    );
  }

  if (cellSummaries.isEmpty) {
    issues.add(
      const ProfileBaselineCheckIssue(
        code: 'no_cell_summaries',
        message: 'The summary contains no successful renderer/fixture cells.',
        details: <String, Object?>{},
      ),
    );
  }

  for (final cell in cellSummaries) {
    final matrix = policy?.matrix;
    if (matrix != null && !matrix.containsCell(cell)) {
      issues.add(
        ProfileBaselineCheckIssue(
          code: 'cell_outside_policy_matrix',
          message:
              'A renderer/fixture cell is outside the profile policy matrix.',
          details: <String, Object?>{
            'renderer': cell['renderer'],
            'fixture': cell['fixture'],
            'policyMatrix': matrix.toJson(),
          },
        ),
      );
    }

    final observedRepeats = cell['observedRepeats']! as int;
    if (observedRepeats < effectiveMinRepeats) {
      issues.add(
        ProfileBaselineCheckIssue(
          code: 'insufficient_repeats',
          message: 'A renderer/fixture cell has too few successful repeats.',
          details: <String, Object?>{
            'renderer': cell['renderer'],
            'fixture': cell['fixture'],
            'observedRepeats': observedRepeats,
            'minRepeats': effectiveMinRepeats,
          },
        ),
      );
    }

    final outlierRepeats =
        ((cell['outlierRepeats'] as List<Object?>?) ?? const [])
            .cast<Map<String, Object?>>();
    for (final outlier in outlierRepeats) {
      reportOnlyFindings.add(
        ProfileBaselineCheckIssue(
          code: 'outlier_repeat_present',
          message:
              'A renderer/fixture cell recorded a report-only outlier repeat.',
          details: <String, Object?>{
            'renderer': cell['renderer'],
            'fixture': cell['fixture'],
            ...outlier,
          },
        ),
      );
    }

    final memoryEvidenceFixture = _memoryEvidenceFixtureFor(cell);
    if (memoryEvidenceFixture != null && _hasGcSummary(cell)) {
      reportOnlyFindings.add(
        ProfileBaselineCheckIssue(
          code: 'memory_allocation_evidence_required',
          message:
              'This renderer/fixture cell is listed in the memory allocation '
              'playbook. GC counts are review inputs only; DevTools Memory '
              'exports or equivalent allocation evidence are still required '
              'before memory wording can be promoted.',
          details: <String, Object?>{
            'renderer': cell['renderer'],
            'fixture': cell['fixture'],
            'evidenceLane': memoryEvidenceFixture,
            'newGenGcCount': cell['newGenGcCount'],
            'oldGenGcCount': cell['oldGenGcCount'],
            'requiredEvidence': <String>[
              'devtools_memory_export',
              'allocation_profile_or_snapshot_diff',
              'reviewed_baseline_note',
            ],
          },
        ),
      );
    }

    final oldGenGcCount = cell['oldGenGcCount'] as Map<String, Object?>?;
    if (_countTotal(oldGenGcCount) > 0) {
      reportOnlyFindings.add(
        ProfileBaselineCheckIssue(
          code: 'old_gen_gc_review_required',
          message:
              'The renderer/fixture cell recorded old-gen GC activity. Review '
              'allocation evidence before using this lane for memory or '
              'dynamic-content claims.',
          details: <String, Object?>{
            'renderer': cell['renderer'],
            'fixture': cell['fixture'],
            'oldGenGcCount': oldGenGcCount,
          },
        ),
      );
    }

    final launchAttribution =
        cell['launchAttribution'] as Map<String, Object?>?;
    final launchStatus = launchAttribution?['status'] as String?;
    if (launchStatus != 'available') {
      reportOnlyFindings.add(
        ProfileBaselineCheckIssue(
          code: launchStatus == 'partial'
              ? 'launch_attribution_partial'
              : 'launch_attribution_unavailable',
          message:
              'Launch attribution remains report-only and is not fully '
              'available for this renderer/fixture cell.',
          details: <String, Object?>{
            'renderer': cell['renderer'],
            'fixture': cell['fixture'],
            'launchAttribution':
                launchAttribution ??
                <String, Object?>{
                  'status': 'unavailable',
                  'unavailableReasons': <String>[
                    'missing_summary_launch_attribution',
                  ],
                },
          },
        ),
      );
    }

    final viewportModes =
        ((cell['viewportModes'] as List<Object?>?) ?? const [])
            .cast<Map<String, Object?>>();

    if (effectiveViewportMode == ProfileBaselineViewportPolicyMode.synthetic) {
      _checkSyntheticViewportMode(
        cell: cell,
        viewportModes: viewportModes,
        expectedViewport: effectiveViewport!,
        issues: issues,
        reportOnlyFindings: reportOnlyFindings,
      );
      continue;
    }

    final syntheticViewportModes = viewportModes
        .where((mode) => mode['mode'] == 'synthetic')
        .toList(growable: false);
    if (syntheticViewportModes.isNotEmpty) {
      issues.add(
        ProfileBaselineCheckIssue(
          code: 'synthetic_viewport_not_allowed',
          message:
              'An observed-host profile policy cannot qualify synthetic '
              'viewport artifacts.',
          details: <String, Object?>{
            'renderer': cell['renderer'],
            'fixture': cell['fixture'],
            'policyViewportMode': 'observed_host',
            'viewportModes': syntheticViewportModes,
          },
        ),
      );
    }

    if (effectiveViewport == null) {
      continue;
    }

    final viewports = ((cell['viewports'] as List<Object?>?) ?? const [])
        .cast<Map<String, Object?>>();
    if (viewports.isEmpty) {
      issues.add(
        ProfileBaselineCheckIssue(
          code: 'missing_viewport_metadata',
          message:
              'A renderer/fixture cell is missing viewport metadata required '
              'by the configured environment guard.',
          details: <String, Object?>{
            'renderer': cell['renderer'],
            'fixture': cell['fixture'],
            'expectedViewport': effectiveViewport.toJson(),
          },
        ),
      );
      continue;
    }

    if (viewports.every(effectiveViewport.matches)) {
      continue;
    }

    issues.add(
      ProfileBaselineCheckIssue(
        code: 'unexpected_viewport',
        message:
            'A renderer/fixture cell observed viewport metadata that does not '
            'match the configured environment guard.',
        details: <String, Object?>{
          'renderer': cell['renderer'],
          'fixture': cell['fixture'],
          'expectedViewport': effectiveViewport.toJson(),
          'observedViewports': viewports,
        },
      ),
    );
  }

  return ProfileBaselineCheckResult(
    summaryPath: summaryFile.path,
    minRepeats: effectiveMinRepeats,
    policy: policy,
    passed: issues.isEmpty,
    issues: List<ProfileBaselineCheckIssue>.unmodifiable(issues),
    reportOnlyFindings: List<ProfileBaselineCheckIssue>.unmodifiable(
      reportOnlyFindings,
    ),
  );
}

void _checkSyntheticViewportMode({
  required Map<String, Object?> cell,
  required List<Map<String, Object?>> viewportModes,
  required ProfileBaselineExpectedViewport expectedViewport,
  required List<ProfileBaselineCheckIssue> issues,
  required List<ProfileBaselineCheckIssue> reportOnlyFindings,
}) {
  final syntheticModes = viewportModes
      .where((mode) => mode['mode'] == 'synthetic')
      .toList(growable: false);
  if (syntheticModes.isEmpty) {
    issues.add(
      ProfileBaselineCheckIssue(
        code: 'missing_synthetic_viewport_mode',
        message:
            'A synthetic profile policy requires synthetic viewport-mode '
            'metadata.',
        details: <String, Object?>{
          'renderer': cell['renderer'],
          'fixture': cell['fixture'],
          'expectedViewport': expectedViewport.toJson(),
        },
      ),
    );
    return;
  }

  final missingRequested = syntheticModes
      .where((mode) => mode['requested'] == null)
      .toList(growable: false);
  if (missingRequested.isNotEmpty) {
    issues.add(
      ProfileBaselineCheckIssue(
        code: 'missing_synthetic_requested_viewport',
        message:
            'Synthetic viewport-mode metadata is missing the requested '
            'viewport.',
        details: <String, Object?>{
          'renderer': cell['renderer'],
          'fixture': cell['fixture'],
          'expectedViewport': expectedViewport.toJson(),
          'viewportModes': missingRequested,
        },
      ),
    );
  }

  final missingHost = syntheticModes
      .where((mode) => mode['observedHostBeforeOverride'] == null)
      .toList(growable: false);
  if (missingHost.isNotEmpty) {
    issues.add(
      ProfileBaselineCheckIssue(
        code: 'missing_synthetic_host_viewport',
        message:
            'Synthetic viewport-mode metadata is missing host viewport '
            'metadata captured before the override.',
        details: <String, Object?>{
          'renderer': cell['renderer'],
          'fixture': cell['fixture'],
          'viewportModes': missingHost,
        },
      ),
    );
  }

  final missingApplied = syntheticModes
      .where((mode) => mode['applied'] == null)
      .toList(growable: false);
  if (missingApplied.isNotEmpty) {
    issues.add(
      ProfileBaselineCheckIssue(
        code: 'missing_synthetic_applied_viewport',
        message:
            'Synthetic viewport-mode metadata is missing the applied '
            'viewport.',
        details: <String, Object?>{
          'renderer': cell['renderer'],
          'fixture': cell['fixture'],
          'expectedViewport': expectedViewport.toJson(),
          'viewportModes': missingApplied,
        },
      ),
    );
  }

  for (final mode in syntheticModes) {
    final requested = mode['requested'];
    if (requested is Map<String, Object?> &&
        !expectedViewport.matches(requested)) {
      issues.add(
        ProfileBaselineCheckIssue(
          code: 'unexpected_synthetic_requested_viewport',
          message:
              'Synthetic requested viewport metadata does not match the '
              'configured policy.',
          details: <String, Object?>{
            'renderer': cell['renderer'],
            'fixture': cell['fixture'],
            'expectedViewport': expectedViewport.toJson(),
            'observedRequestedViewport': requested,
          },
        ),
      );
    }

    final applied = mode['applied'];
    if (applied is Map<String, Object?> && !expectedViewport.matches(applied)) {
      issues.add(
        ProfileBaselineCheckIssue(
          code: 'unexpected_synthetic_applied_viewport',
          message:
              'Synthetic applied viewport metadata does not match the '
              'configured policy.',
          details: <String, Object?>{
            'renderer': cell['renderer'],
            'fixture': cell['fixture'],
            'expectedViewport': expectedViewport.toJson(),
            'observedAppliedViewport': applied,
          },
        ),
      );
    }
  }

  reportOnlyFindings.add(
    ProfileBaselineCheckIssue(
      code: 'synthetic_viewport_not_reference_target',
      message:
          'Synthetic viewport profile evidence is harness-stability evidence '
          'only and does not qualify a real reference display target.',
      details: <String, Object?>{
        'renderer': cell['renderer'],
        'fixture': cell['fixture'],
        'policyViewportMode': 'synthetic',
        'expectedViewport': expectedViewport.toJson(),
        'viewportModes': syntheticModes,
      },
    ),
  );
}

double _readDouble(Map<String, Object?> map, String key) {
  final value = map[key];
  if (value case final num number) {
    return number.toDouble();
  }

  throw FormatException('Expected numeric "$key" in viewport metadata.');
}

Set<String> _readStringSet(Map<String, Object?> map, String key) {
  final value = map[key];
  if (value is! List<Object?>) {
    throw FormatException(
      'Profile baseline policy matrix.$key must be a list.',
    );
  }

  final values = <String>{};
  for (final item in value) {
    if (item is! String || item.trim().isEmpty) {
      throw FormatException(
        'Profile baseline policy matrix.$key must contain non-empty strings.',
      );
    }
    values.add(item);
  }
  return values;
}

ProfileBaselineViewportPolicyMode _readViewportPolicyMode(Object? value) {
  if (value == null) {
    return ProfileBaselineViewportPolicyMode.observedHost;
  }
  if (value is! String) {
    throw const FormatException(
      'Profile baseline policy check.viewportMode must be a string.',
    );
  }
  return switch (value.trim()) {
    'observed_host' ||
    'observedHost' => ProfileBaselineViewportPolicyMode.observedHost,
    'synthetic' => ProfileBaselineViewportPolicyMode.synthetic,
    _ => throw FormatException(
      'Expected policy check.viewportMode observed_host or synthetic, got: '
      '$value',
    ),
  };
}

String _viewportPolicyModeValue(ProfileBaselineViewportPolicyMode mode) {
  return switch (mode) {
    ProfileBaselineViewportPolicyMode.observedHost => 'observed_host',
    ProfileBaselineViewportPolicyMode.synthetic => 'synthetic',
  };
}

String? _memoryEvidenceFixtureFor(Map<String, Object?> cell) {
  final renderer = cell['renderer'];
  final fixture = cell['fixture'];
  return switch ((renderer, fixture)) {
    ('tagflow', 'large_article') => 'tagflow:large_article',
    ('tagflow', 'table_stress') => 'tagflow:table_stress',
    ('tagflow_semantic_patch', 'streaming_ai_authored_insertion_patches') =>
      'tagflow_semantic_patch:streaming_ai_authored_insertion_patches',
    ('tagflow_native_json', 'native_large_article') =>
      'tagflow_native_json:native_large_article',
    _ => null,
  };
}

bool _hasGcSummary(Map<String, Object?> cell) {
  return cell['newGenGcCount'] is Map<String, Object?> ||
      cell['oldGenGcCount'] is Map<String, Object?>;
}

int _countTotal(Map<String, Object?>? summary) {
  final total = summary?['total'];
  if (total is int) {
    return total;
  }
  if (total is num) {
    return total.toInt();
  }
  return 0;
}
