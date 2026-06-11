import 'dart:convert';
import 'dart:io';

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
    if (observedRepeats >= minRepeats) {
      continue;
    }

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

  return ProfileBaselineCheckResult(
    summaryPath: summaryFile.path,
    minRepeats: minRepeats,
    passed: issues.isEmpty,
    issues: List<ProfileBaselineCheckIssue>.unmodifiable(issues),
  );
}
