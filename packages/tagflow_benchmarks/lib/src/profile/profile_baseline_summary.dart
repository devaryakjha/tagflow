import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

const double _frameBudgetMillis = 16.667;

/// Summary for a collected profile baseline matrix.
final class ProfileBaselineSummary {
  /// Creates a profile baseline summary.
  const ProfileBaselineSummary({
    required this.runId,
    required this.manifestPath,
    required this.runDirectory,
    required this.generatedAt,
    required this.totalRuns,
    required this.successfulRuns,
    required this.runStatusCounts,
    required this.failedRuns,
    required this.cellSummaries,
  });

  /// Stable id of the underlying baseline run.
  final String runId;

  /// Manifest file that drove the summary.
  final String manifestPath;

  /// Run directory containing raw profile JSON artifacts.
  final String runDirectory;

  /// UTC timestamp when the summary was generated.
  final DateTime generatedAt;

  /// Number of manifest entries seen in this run.
  final int totalRuns;

  /// Number of successful profile artifacts summarized.
  final int successfulRuns;

  /// Count of manifest entries by status.
  final Map<String, int> runStatusCounts;

  /// Failed or incomplete manifest entries requiring reviewer attention.
  final List<ProfileBaselineFailedRun> failedRuns;

  /// Summary for each renderer/fixture cell.
  final List<ProfileBaselineCellSummary> cellSummaries;

  /// Converts this summary to machine-readable JSON.
  Map<String, Object?> toJson() => <String, Object?>{
    'runId': runId,
    'manifestPath': manifestPath,
    'runDirectory': runDirectory,
    'generatedAt': generatedAt.toUtc().toIso8601String(),
    'totalRuns': totalRuns,
    'successfulRuns': successfulRuns,
    'runStatusCounts': runStatusCounts,
    'failedRuns': failedRuns.map((run) => run.toJson()).toList(),
    'cellSummaries': cellSummaries.map((cell) => cell.toJson()).toList(),
  };
}

/// A failed or incomplete profile baseline manifest entry.
final class ProfileBaselineFailedRun {
  /// Creates a failed run summary.
  const ProfileBaselineFailedRun({
    required this.renderer,
    required this.fixture,
    required this.repeat,
    required this.status,
    required this.exitCode,
    required this.logPath,
    required this.artifactPath,
  });

  /// Renderer id.
  final String renderer;

  /// Fixture id.
  final String fixture;

  /// One-based repeat index.
  final int repeat;

  /// Manifest status for this run.
  final String status;

  /// Process exit code, when present in the manifest.
  final int? exitCode;

  /// Per-run stdout/stderr log path, when present.
  final String? logPath;

  /// Raw profile JSON artifact path, when present.
  final String? artifactPath;

  /// Converts this failed run to JSON.
  Map<String, Object?> toJson() => <String, Object?>{
    'renderer': renderer,
    'fixture': fixture,
    'repeat': repeat,
    'status': status,
    'exitCode': exitCode,
    'logPath': logPath,
    'artifactPath': artifactPath,
  };
}

/// Summary for one renderer/fixture cell across repeated runs.
final class ProfileBaselineCellSummary {
  /// Creates a profile baseline cell summary.
  const ProfileBaselineCellSummary({
    required this.renderer,
    required this.fixture,
    required this.observedRepeats,
    required this.frameCount,
    required this.averageBuildMillis,
    required this.p90BuildMillis,
    required this.worstBuildMillis,
    required this.averageRasterMillis,
    required this.p90RasterMillis,
    required this.worstRasterMillis,
    required this.missedBuildBudgetCount,
    required this.missedRasterBudgetCount,
    required this.newGenGcCount,
    required this.oldGenGcCount,
    required this.outlierRepeats,
  });

  /// Renderer id.
  final String renderer;

  /// Fixture id.
  final String fixture;

  /// Number of successful repeats summarized.
  final int observedRepeats;

  /// Frame count distribution across repeats.
  final ProfileBaselineNumberSummary frameCount;

  /// Average build time distribution across repeats.
  final ProfileBaselineNumberSummary averageBuildMillis;

  /// Build p90 distribution across repeats.
  final ProfileBaselineNumberSummary p90BuildMillis;

  /// Worst build duration distribution across repeats.
  final ProfileBaselineNumberSummary worstBuildMillis;

  /// Average raster time distribution across repeats.
  final ProfileBaselineNumberSummary averageRasterMillis;

  /// Raster p90 distribution across repeats.
  final ProfileBaselineNumberSummary p90RasterMillis;

  /// Worst raster duration distribution across repeats.
  final ProfileBaselineNumberSummary worstRasterMillis;

  /// Missed build-budget counts across repeats.
  final ProfileBaselineCountSummary missedBuildBudgetCount;

  /// Missed raster-budget counts across repeats.
  final ProfileBaselineCountSummary missedRasterBudgetCount;

  /// New-gen GC counts across repeats.
  final ProfileBaselineCountSummary newGenGcCount;

  /// Old-gen GC counts across repeats.
  final ProfileBaselineCountSummary oldGenGcCount;

  /// Repeats that merit reviewer attention.
  final List<ProfileBaselineOutlier> outlierRepeats;

  /// Converts this cell summary to JSON.
  Map<String, Object?> toJson() => <String, Object?>{
    'renderer': renderer,
    'fixture': fixture,
    'observedRepeats': observedRepeats,
    'frameCount': frameCount.toJson(),
    'averageBuildMillis': averageBuildMillis.toJson(),
    'p90BuildMillis': p90BuildMillis.toJson(),
    'worstBuildMillis': worstBuildMillis.toJson(),
    'averageRasterMillis': averageRasterMillis.toJson(),
    'p90RasterMillis': p90RasterMillis.toJson(),
    'worstRasterMillis': worstRasterMillis.toJson(),
    'missedBuildBudgetCount': missedBuildBudgetCount.toJson(),
    'missedRasterBudgetCount': missedRasterBudgetCount.toJson(),
    'newGenGcCount': newGenGcCount.toJson(),
    'oldGenGcCount': oldGenGcCount.toJson(),
    'outlierRepeats': outlierRepeats
        .map((outlier) => outlier.toJson())
        .toList(),
  };
}

/// Numeric distribution summary across repeats.
final class ProfileBaselineNumberSummary {
  /// Creates a numeric distribution summary.
  const ProfileBaselineNumberSummary({
    required this.min,
    required this.max,
    required this.mean,
    required this.median,
  });

  /// Minimum observed value.
  final double min;

  /// Maximum observed value.
  final double max;

  /// Mean observed value.
  final double mean;

  /// Median observed value.
  final double median;

  /// Converts this numeric summary to JSON.
  Map<String, Object?> toJson() => <String, Object?>{
    'min': min,
    'max': max,
    'mean': mean,
    'median': median,
  };
}

/// Integer count summary across repeats.
final class ProfileBaselineCountSummary {
  /// Creates an integer count summary.
  const ProfileBaselineCountSummary({
    required this.min,
    required this.max,
    required this.total,
    required this.mean,
  });

  /// Minimum observed count.
  final int min;

  /// Maximum observed count.
  final int max;

  /// Sum across repeats.
  final int total;

  /// Mean observed count.
  final double mean;

  /// Converts this count summary to JSON.
  Map<String, Object?> toJson() => <String, Object?>{
    'min': min,
    'max': max,
    'total': total,
    'mean': mean,
  };
}

/// A repeat that showed a notable variance signal.
final class ProfileBaselineOutlier {
  /// Creates an outlier record.
  const ProfileBaselineOutlier({
    required this.repeat,
    required this.artifactPath,
    required this.reasons,
    required this.frameCount,
    required this.worstBuildMillis,
    required this.worstRasterMillis,
    required this.missedBuildBudgetCount,
    required this.missedRasterBudgetCount,
    required this.oldGenGcCount,
  });

  /// One-based repeat index.
  final int repeat;

  /// Artifact path relative to the workspace root.
  final String artifactPath;

  /// Reviewer-facing outlier reasons.
  final List<String> reasons;

  /// Frame count captured in this repeat.
  final int frameCount;

  /// Worst build duration in milliseconds.
  final double worstBuildMillis;

  /// Worst raster duration in milliseconds.
  final double worstRasterMillis;

  /// Missed build-budget count.
  final int missedBuildBudgetCount;

  /// Missed raster-budget count.
  final int missedRasterBudgetCount;

  /// Old-gen GC count.
  final int oldGenGcCount;

  /// Converts this outlier to JSON.
  Map<String, Object?> toJson() => <String, Object?>{
    'repeat': repeat,
    'artifactPath': artifactPath,
    'reasons': reasons,
    'frameCount': frameCount,
    'worstBuildMillis': worstBuildMillis,
    'worstRasterMillis': worstRasterMillis,
    'missedBuildBudgetCount': missedBuildBudgetCount,
    'missedRasterBudgetCount': missedRasterBudgetCount,
    'oldGenGcCount': oldGenGcCount,
  };
}

/// Summarizes a collected profile baseline matrix.
ProfileBaselineSummary summarizeProfileBaselineManifest({
  required File manifestFile,
  DateTime Function()? clock,
}) {
  final manifest =
      jsonDecode(manifestFile.readAsStringSync()) as Map<String, Object?>;
  final manifestDirectory = manifestFile.parent.path;
  final workspaceRoot = manifestFile.parent.parent.parent.parent.parent.path;
  final runs = _readRuns(manifest['runs']);
  final successfulRuns = runs
      .where((run) => run.status == 'passed' && run.artifactPath != null)
      .length;
  final failedRuns = runs
      .where((run) => run.status != 'passed' || run.artifactPath == null)
      .map(
        (run) => ProfileBaselineFailedRun(
          renderer: run.renderer,
          fixture: run.fixture,
          repeat: run.repeat,
          status: run.status,
          exitCode: run.exitCode,
          logPath: run.logPath,
          artifactPath: run.artifactPath,
        ),
      )
      .toList(growable: false);

  final grouped = <String, List<_ProfileBaselineRunRecord>>{};
  for (final run in runs) {
    if (run.status != 'passed') {
      continue;
    }
    final artifactPath = run.artifactPath;
    if (artifactPath == null) {
      continue;
    }
    final artifactFile = File(p.join(workspaceRoot, artifactPath));
    final metrics = _readMetrics(artifactFile);
    final record = _ProfileBaselineRunRecord(run: run, metrics: metrics);
    final key = '${run.renderer}::${run.fixture}';
    grouped.putIfAbsent(key, () => <_ProfileBaselineRunRecord>[]).add(record);
  }

  final cellSummaries =
      grouped.entries
          .map((entry) {
            final first = entry.value.first.run;
            final records = entry.value
              ..sort((a, b) => a.run.repeat - b.run.repeat);

            return ProfileBaselineCellSummary(
              renderer: first.renderer,
              fixture: first.fixture,
              observedRepeats: records.length,
              frameCount: _summarizeInts(
                records.map((record) => record.metrics.frameCount),
              ),
              averageBuildMillis: _summarizeDoubles(
                records.map((record) => record.metrics.averageBuildMillis),
              ),
              p90BuildMillis: _summarizeDoubles(
                records.map((record) => record.metrics.p90BuildMillis),
              ),
              worstBuildMillis: _summarizeDoubles(
                records.map((record) => record.metrics.worstBuildMillis),
              ),
              averageRasterMillis: _summarizeDoubles(
                records.map((record) => record.metrics.averageRasterMillis),
              ),
              p90RasterMillis: _summarizeDoubles(
                records.map((record) => record.metrics.p90RasterMillis),
              ),
              worstRasterMillis: _summarizeDoubles(
                records.map((record) => record.metrics.worstRasterMillis),
              ),
              missedBuildBudgetCount: _summarizeCounts(
                records.map((record) => record.metrics.missedBuildBudgetCount),
              ),
              missedRasterBudgetCount: _summarizeCounts(
                records.map((record) => record.metrics.missedRasterBudgetCount),
              ),
              newGenGcCount: _summarizeCounts(
                records.map((record) => record.metrics.newGenGcCount),
              ),
              oldGenGcCount: _summarizeCounts(
                records.map((record) => record.metrics.oldGenGcCount),
              ),
              outlierRepeats: records
                  .map(_detectOutlier)
                  .whereType<ProfileBaselineOutlier>()
                  .toList(growable: false),
            );
          })
          .toList(growable: false)
        ..sort((a, b) {
          final rendererOrder = a.renderer.compareTo(b.renderer);
          if (rendererOrder != 0) {
            return rendererOrder;
          }
          return a.fixture.compareTo(b.fixture);
        });

  return ProfileBaselineSummary(
    runId: manifest['runId']! as String,
    manifestPath: p.relative(manifestFile.path, from: workspaceRoot),
    runDirectory: p.relative(manifestDirectory, from: workspaceRoot),
    generatedAt: (clock ?? DateTime.now)().toUtc(),
    totalRuns: runs.length,
    successfulRuns: successfulRuns,
    runStatusCounts: Map<String, int>.unmodifiable(_countRunStatuses(runs)),
    failedRuns: List<ProfileBaselineFailedRun>.unmodifiable(failedRuns),
    cellSummaries: List<ProfileBaselineCellSummary>.unmodifiable(cellSummaries),
  );
}

/// Writes a summary JSON file next to [manifestFile].
File writeProfileBaselineSummary({
  required File manifestFile,
  DateTime Function()? clock,
}) {
  final summary = summarizeProfileBaselineManifest(
    manifestFile: manifestFile,
    clock: clock,
  );
  return File(p.join(manifestFile.parent.path, 'profile-baseline-summary.json'))
    ..writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(summary.toJson())}\n',
    );
}

final class _ProfileBaselineRunRecord {
  const _ProfileBaselineRunRecord({required this.run, required this.metrics});

  final _ManifestRun run;
  final _ProfileMetrics metrics;
}

final class _ManifestRun {
  const _ManifestRun({
    required this.renderer,
    required this.fixture,
    required this.repeat,
    required this.status,
    required this.exitCode,
    required this.logPath,
    required this.artifactPath,
  });

  final String renderer;
  final String fixture;
  final int repeat;
  final String status;
  final int? exitCode;
  final String? logPath;
  final String? artifactPath;
}

List<_ManifestRun> _readRuns(Object? rawRuns) {
  final runList = rawRuns! as List<Object?>;
  return runList
      .map((rawRun) {
        final json = rawRun! as Map<String, Object?>;
        return _ManifestRun(
          renderer: json['renderer']! as String,
          fixture: json['fixture']! as String,
          repeat: json['repeat']! as int,
          status: json['status'] as String? ?? 'passed',
          exitCode: json['exitCode'] as int?,
          logPath: json['logPath'] as String?,
          artifactPath: json['artifactPath'] as String?,
        );
      })
      .toList(growable: false);
}

Map<String, int> _countRunStatuses(List<_ManifestRun> runs) {
  final counts = <String, int>{};
  for (final run in runs) {
    counts.update(run.status, (count) => count + 1, ifAbsent: () => 1);
  }
  return counts;
}

final class _ProfileMetrics {
  const _ProfileMetrics({
    required this.frameCount,
    required this.averageBuildMillis,
    required this.p90BuildMillis,
    required this.worstBuildMillis,
    required this.averageRasterMillis,
    required this.p90RasterMillis,
    required this.worstRasterMillis,
    required this.missedBuildBudgetCount,
    required this.missedRasterBudgetCount,
    required this.newGenGcCount,
    required this.oldGenGcCount,
  });

  final int frameCount;
  final double averageBuildMillis;
  final double p90BuildMillis;
  final double worstBuildMillis;
  final double averageRasterMillis;
  final double p90RasterMillis;
  final double worstRasterMillis;
  final int missedBuildBudgetCount;
  final int missedRasterBudgetCount;
  final int newGenGcCount;
  final int oldGenGcCount;
}

_ProfileMetrics _readMetrics(File artifactFile) {
  final root =
      jsonDecode(artifactFile.readAsStringSync()) as Map<String, Object?>;
  final payload = root.values.single;
  if (payload is! Map<String, Object?>) {
    throw const FormatException(
      'Expected a single benchmark payload object in the profile artifact.',
    );
  }

  return _ProfileMetrics(
    frameCount: payload['frame_count']! as int,
    averageBuildMillis: (payload['average_frame_build_time_millis']! as num)
        .toDouble(),
    p90BuildMillis: (payload['90th_percentile_frame_build_time_millis']! as num)
        .toDouble(),
    worstBuildMillis: (payload['worst_frame_build_time_millis']! as num)
        .toDouble(),
    averageRasterMillis:
        (payload['average_frame_rasterizer_time_millis']! as num).toDouble(),
    p90RasterMillis:
        (payload['90th_percentile_frame_rasterizer_time_millis']! as num)
            .toDouble(),
    worstRasterMillis: (payload['worst_frame_rasterizer_time_millis']! as num)
        .toDouble(),
    missedBuildBudgetCount: payload['missed_frame_build_budget_count']! as int,
    missedRasterBudgetCount:
        payload['missed_frame_rasterizer_budget_count']! as int,
    newGenGcCount: payload['new_gen_gc_count']! as int,
    oldGenGcCount: payload['old_gen_gc_count']! as int,
  );
}

ProfileBaselineOutlier? _detectOutlier(_ProfileBaselineRunRecord record) {
  final reasons = <String>[];
  final metrics = record.metrics;

  if (metrics.missedBuildBudgetCount > 0) {
    reasons.add('missed_build_budget');
  }
  if (metrics.missedRasterBudgetCount > 0) {
    reasons.add('missed_raster_budget');
  }
  if (metrics.oldGenGcCount > 0) {
    reasons.add('old_gen_gc');
  }
  if (metrics.worstBuildMillis > _frameBudgetMillis) {
    reasons.add('worst_build_over_budget');
  }
  if (metrics.worstRasterMillis > _frameBudgetMillis) {
    reasons.add('worst_raster_over_budget');
  }

  if (reasons.isEmpty) {
    return null;
  }

  return ProfileBaselineOutlier(
    repeat: record.run.repeat,
    artifactPath: record.run.artifactPath!,
    reasons: List<String>.unmodifiable(reasons),
    frameCount: metrics.frameCount,
    worstBuildMillis: metrics.worstBuildMillis,
    worstRasterMillis: metrics.worstRasterMillis,
    missedBuildBudgetCount: metrics.missedBuildBudgetCount,
    missedRasterBudgetCount: metrics.missedRasterBudgetCount,
    oldGenGcCount: metrics.oldGenGcCount,
  );
}

ProfileBaselineNumberSummary _summarizeDoubles(Iterable<double> values) {
  final sorted = values.toList(growable: false)..sort();
  final mean = sorted.reduce((sum, value) => sum + value) / sorted.length;
  return ProfileBaselineNumberSummary(
    min: sorted.first,
    max: sorted.last,
    mean: mean,
    median: sorted[(sorted.length - 1) ~/ 2],
  );
}

ProfileBaselineNumberSummary _summarizeInts(Iterable<int> values) {
  final sorted = values.toList(growable: false)..sort();
  final mean =
      sorted.map((value) => value.toDouble()).reduce((a, b) => a + b) /
      sorted.length;
  return ProfileBaselineNumberSummary(
    min: sorted.first.toDouble(),
    max: sorted.last.toDouble(),
    mean: mean,
    median: sorted[(sorted.length - 1) ~/ 2].toDouble(),
  );
}

ProfileBaselineCountSummary _summarizeCounts(Iterable<int> values) {
  final sorted = values.toList(growable: false)..sort();
  final total = sorted.fold<int>(0, (sum, value) => sum + value);
  return ProfileBaselineCountSummary(
    min: sorted.first,
    max: sorted.last,
    total: total,
    mean: total / sorted.length,
  );
}
