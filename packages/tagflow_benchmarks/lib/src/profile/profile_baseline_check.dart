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

/// Machine-readable policy for the profile baseline checker.
final class ProfileBaselineCheckPolicy {
  /// Creates a profile baseline check policy.
  const ProfileBaselineCheckPolicy({
    required this.id,
    required this.minRepeats,
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

    final minRepeats = check['minRepeats'];
    if (minRepeats is! int || minRepeats < 1) {
      throw const FormatException(
        'Profile baseline policy check.minRepeats must be an integer >= 1.',
      );
    }

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

    return ProfileBaselineCheckPolicy(
      id: id,
      minRepeats: minRepeats,
      expectedViewport: expectedViewport,
      thresholdMode: thresholdMode,
    );
  }

  /// Stable policy id.
  final String id;

  /// Minimum successful repeat count per renderer/fixture cell.
  final int minRepeats;

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
    'minRepeats': minRepeats,
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

double _readDouble(Map<String, Object?> map, String key) {
  final value = map[key];
  if (value case final num number) {
    return number.toDouble();
  }

  throw FormatException('Expected numeric "$key" in viewport metadata.');
}
