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

/// Machine-checkable result for a profile baseline summary.
final class ProfileBaselineCheckResult {
  /// Creates a profile baseline check result.
  const ProfileBaselineCheckResult({
    required this.summaryPath,
    required this.minRepeats,
    required this.passed,
    required this.issues,
  });

  /// Checked `profile-baseline-summary.json` path.
  final String summaryPath;

  /// Required successful repeat count per renderer/fixture cell.
  final int minRepeats;

  /// Whether the summary satisfies collection-completeness invariants.
  final bool passed;

  /// Issues found while checking the summary.
  final List<ProfileBaselineCheckIssue> issues;

  /// Converts this result to machine-readable JSON.
  Map<String, Object?> toJson() => <String, Object?>{
    'summaryPath': summaryPath,
    'minRepeats': minRepeats,
    'passed': passed,
    'issues': issues.map((issue) => issue.toJson()).toList(),
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
  int minRepeats = 1,
  ProfileBaselineExpectedViewport? expectedViewport,
}) {
  if (minRepeats < 1) {
    throw ArgumentError.value(minRepeats, 'minRepeats', 'Must be at least 1.');
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
    if (observedRepeats < minRepeats) {
      issues.add(
        ProfileBaselineCheckIssue(
          code: 'insufficient_repeats',
          message: 'A renderer/fixture cell has too few successful repeats.',
          details: <String, Object?>{
            'renderer': cell['renderer'],
            'fixture': cell['fixture'],
            'observedRepeats': observedRepeats,
            'minRepeats': minRepeats,
          },
        ),
      );
    }

    if (expectedViewport == null) {
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
            'expectedViewport': expectedViewport.toJson(),
          },
        ),
      );
      continue;
    }

    if (viewports.every(expectedViewport.matches)) {
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
          'expectedViewport': expectedViewport.toJson(),
          'observedViewports': viewports,
        },
      ),
    );
  }

  return ProfileBaselineCheckResult(
    summaryPath: summaryFile.path,
    minRepeats: minRepeats,
    passed: issues.isEmpty,
    issues: List<ProfileBaselineCheckIssue>.unmodifiable(issues),
  );
}

double _readDouble(Map<String, Object?> map, String key) {
  final value = map[key];
  if (value case final num number) {
    return number.toDouble();
  }

  throw FormatException('Expected numeric "$key" in viewport metadata.');
}
