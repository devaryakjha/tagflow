import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

const double _frameBudgetMillis = 16.667;
const int _updateLatencySpikeThresholdMicros = 500000;
const int _updateLatencySpikeMultiplier = 5;

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
    required this.viewports,
    required this.inputSummary,
    required this.framePhaseSummaries,
    required this.launchAttribution,
    required this.updateSummary,
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

  /// Unique viewport configurations observed across repeats.
  final List<ProfileBaselineViewport> viewports;

  /// Optional input metadata captured for this renderer/fixture cell.
  final ProfileBaselineInputSummary? inputSummary;

  /// Phase-labeled frame summaries across repeated runs.
  final Map<String, ProfileBaselineFramePhaseSummary> framePhaseSummaries;

  /// Explicit launch-attribution status for this cell.
  final ProfileBaselineLaunchAttributionSummary launchAttribution;

  /// Optional update-path summary for dynamic benchmarks.
  final ProfileBaselineCellUpdateSummary? updateSummary;

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
    'viewports': viewports.map((viewport) => viewport.toJson()).toList(),
    if (inputSummary != null) 'inputSummary': inputSummary!.toJson(),
    if (framePhaseSummaries.isNotEmpty)
      'framePhaseSummaries': framePhaseSummaries.map(
        (phase, summary) => MapEntry(phase, summary.toJson()),
      ),
    'launchAttribution': launchAttribution.toJson(),
    if (updateSummary != null) 'updateSummary': updateSummary!.toJson(),
    'outlierRepeats': outlierRepeats
        .map((outlier) => outlier.toJson())
        .toList(),
  };
}

/// Fixture input metadata summarized across repeated profile runs.
final class ProfileBaselineInputSummary {
  /// Creates an input metadata summary.
  const ProfileBaselineInputSummary({
    required this.observedRepeats,
    required this.inputBytes,
    required this.inputLength,
    required this.sourceTypes,
    required this.assetPaths,
  });

  /// Successful repeats that emitted input metadata.
  final int observedRepeats;

  /// UTF-8 input byte count distribution across repeats.
  final ProfileBaselineNumberSummary inputBytes;

  /// Dart string character count distribution across repeats.
  final ProfileBaselineNumberSummary inputLength;

  /// Source type labels seen across repeats.
  final List<String> sourceTypes;

  /// Fixture asset paths seen across repeats.
  final List<String> assetPaths;

  /// Converts this input summary to JSON.
  Map<String, Object?> toJson() => <String, Object?>{
    'observedRepeats': observedRepeats,
    'inputBytes': inputBytes.toJson(),
    'inputLength': inputLength.toJson(),
    if (sourceTypes.isNotEmpty) 'sourceTypes': sourceTypes,
    if (assetPaths.isNotEmpty) 'assetPaths': assetPaths,
  };
}

/// Launch-attribution status and interval summaries for one benchmark cell.
final class ProfileBaselineLaunchAttributionSummary {
  /// Creates a launch-attribution summary.
  const ProfileBaselineLaunchAttributionSummary({
    required this.status,
    required this.observedRepeats,
    required this.missingRepeats,
    required this.provenances,
    required this.scopes,
    required this.intervalMicros,
    required this.unavailableReasons,
  });

  /// `available`, `partial`, or `unavailable`.
  final String status;

  /// Successful repeats that emitted explicit launch markers.
  final int observedRepeats;

  /// Successful repeats without explicit launch markers.
  final int missingRepeats;

  /// Unique provenance labels from supporting artifacts.
  final List<String> provenances;

  /// Unique evidence scopes from supporting artifacts.
  final List<String> scopes;

  /// Interval summaries keyed by interval name in microseconds.
  final Map<String, ProfileBaselineNumberSummary> intervalMicros;

  /// Unique reasons that launch attribution was unavailable.
  final List<String> unavailableReasons;

  /// Converts this summary to JSON.
  Map<String, Object?> toJson() => <String, Object?>{
    'status': status,
    'observedRepeats': observedRepeats,
    'missingRepeats': missingRepeats,
    if (provenances.isNotEmpty) 'provenances': provenances,
    if (scopes.isNotEmpty) 'scopes': scopes,
    if (intervalMicros.isNotEmpty)
      'intervalMicros': intervalMicros.map(
        (name, summary) => MapEntry(name, summary.toJson()),
      ),
    if (unavailableReasons.isNotEmpty) 'unavailableReasons': unavailableReasons,
  };
}

/// Frame metrics summarized for one named profile phase.
final class ProfileBaselineFramePhaseSummary {
  /// Creates a phase summary.
  const ProfileBaselineFramePhaseSummary({
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
  });

  /// Number of repeats with this phase payload.
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

  /// Converts this phase summary to JSON.
  Map<String, Object?> toJson() => <String, Object?>{
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
  };
}

/// Summary for optional update-path payloads across repeated runs.
final class ProfileBaselineCellUpdateSummary {
  /// Creates an update-path summary.
  const ProfileBaselineCellUpdateSummary({
    required this.observedRepeats,
    required this.observedUpdateCount,
    required this.maxElapsedMicros,
    required this.maxElapsedMillis,
    required this.maxElapsedRepeat,
    required this.maxElapsedChunk,
    required this.maxElapsedFraction,
    required this.maxElapsedInputLength,
    required this.maxElapsedArtifactPath,
    required this.worstBuildMillis,
    required this.worstRasterMillis,
    required this.missedBuildBudgetCount,
    required this.missedRasterBudgetCount,
    required this.phaseMaxima,
    required this.worstAttributedFrame,
  });

  /// Number of repeats that emitted update payloads.
  final int observedRepeats;

  /// Total update latency samples seen across all repeats.
  final int observedUpdateCount;

  /// Maximum observed update latency in microseconds.
  final int? maxElapsedMicros;

  /// Maximum observed update latency in milliseconds.
  final double? maxElapsedMillis;

  /// Repeat containing the maximum update latency.
  final int? maxElapsedRepeat;

  /// Chunk index containing the maximum update latency.
  final int? maxElapsedChunk;

  /// Fraction marker containing the maximum update latency.
  final double? maxElapsedFraction;

  /// Input length captured at the maximum update latency.
  final int? maxElapsedInputLength;

  /// Artifact path for the repeat with the maximum update latency.
  final String? maxElapsedArtifactPath;

  /// Worst update build-time distribution across repeats.
  final ProfileBaselineNumberSummary? worstBuildMillis;

  /// Worst update raster-time distribution across repeats.
  final ProfileBaselineNumberSummary? worstRasterMillis;

  /// Missed update build-budget counts across repeats.
  final ProfileBaselineCountSummary? missedBuildBudgetCount;

  /// Missed update raster-budget counts across repeats.
  final ProfileBaselineCountSummary? missedRasterBudgetCount;

  /// Maximum observed duration for each measured update phase.
  final Map<String, ProfileBaselineUpdatePhaseMaximum> phaseMaxima;

  /// Worst observed attributed update frame, when raw artifacts captured it.
  final ProfileBaselineUpdateWorstFrame? worstAttributedFrame;

  /// Converts this update summary to JSON.
  Map<String, Object?> toJson() => <String, Object?>{
    'observedRepeats': observedRepeats,
    'observedUpdateCount': observedUpdateCount,
    if (maxElapsedMicros != null) 'maxElapsedMicros': maxElapsedMicros,
    if (maxElapsedMillis != null) 'maxElapsedMillis': maxElapsedMillis,
    if (maxElapsedRepeat != null) 'maxElapsedRepeat': maxElapsedRepeat,
    if (maxElapsedChunk != null) 'maxElapsedChunk': maxElapsedChunk,
    if (maxElapsedFraction != null) 'maxElapsedFraction': maxElapsedFraction,
    if (maxElapsedInputLength != null)
      'maxElapsedInputLength': maxElapsedInputLength,
    if (maxElapsedArtifactPath != null)
      'maxElapsedArtifactPath': maxElapsedArtifactPath,
    if (worstBuildMillis != null)
      'worstBuildMillis': worstBuildMillis!.toJson(),
    if (worstRasterMillis != null)
      'worstRasterMillis': worstRasterMillis!.toJson(),
    if (missedBuildBudgetCount != null)
      'missedBuildBudgetCount': missedBuildBudgetCount!.toJson(),
    if (missedRasterBudgetCount != null)
      'missedRasterBudgetCount': missedRasterBudgetCount!.toJson(),
    if (phaseMaxima.isNotEmpty)
      'phaseMaxima': phaseMaxima.map(
        (phase, maximum) => MapEntry(phase, maximum.toJson()),
      ),
    if (worstAttributedFrame != null)
      'worstAttributedFrame': worstAttributedFrame!.toJson(),
  };
}

/// Maximum observed duration for one measured update phase.
final class ProfileBaselineUpdatePhaseMaximum {
  /// Creates an update-phase maximum summary.
  const ProfileBaselineUpdatePhaseMaximum({
    required this.maxMicros,
    required this.maxMillis,
    required this.repeat,
    required this.chunk,
    required this.fraction,
    required this.inputLength,
    required this.artifactPath,
  });

  /// Maximum observed phase duration in microseconds.
  final int maxMicros;

  /// Maximum observed phase duration in milliseconds.
  final double maxMillis;

  /// Repeat containing the maximum phase duration.
  final int repeat;

  /// Chunk index containing the maximum phase duration.
  final int chunk;

  /// Fraction marker containing the maximum phase duration.
  final double fraction;

  /// Input length captured at the maximum phase duration.
  final int inputLength;

  /// Artifact path for the repeat with the maximum phase duration.
  final String artifactPath;

  /// Converts this phase maximum to JSON.
  Map<String, Object?> toJson() => <String, Object?>{
    'maxMicros': maxMicros,
    'maxMillis': maxMillis,
    'repeat': repeat,
    'chunk': chunk,
    'fraction': fraction,
    'inputLength': inputLength,
    'artifactPath': artifactPath,
  };
}

/// Worst observed update frame attributed back to one update sample.
final class ProfileBaselineUpdateWorstFrame {
  /// Creates an attributed update-frame summary.
  const ProfileBaselineUpdateWorstFrame({
    required this.repeat,
    required this.chunk,
    required this.fraction,
    required this.inputLength,
    required this.phase,
    required this.buildMillis,
    required this.rasterMillis,
    required this.buildOverBudget,
    required this.rasterOverBudget,
    required this.artifactPath,
  });

  /// Repeat containing the observed frame.
  final int repeat;

  /// Chunk index containing the observed frame.
  final int chunk;

  /// Fraction marker containing the observed frame.
  final double fraction;

  /// Input length captured for the owning update.
  final int inputLength;

  /// Conservative ownership window for the observed frame.
  final String phase;

  /// Build duration for the observed frame in milliseconds.
  final double buildMillis;

  /// Raster duration for the observed frame in milliseconds.
  final double rasterMillis;

  /// Whether the build duration exceeded the frame budget.
  final bool buildOverBudget;

  /// Whether the raster duration exceeded the frame budget.
  final bool rasterOverBudget;

  /// Artifact path for the repeat with the observed frame.
  final String artifactPath;

  /// Converts this frame summary to JSON.
  Map<String, Object?> toJson() => <String, Object?>{
    'repeat': repeat,
    'chunk': chunk,
    'fraction': fraction,
    'inputLength': inputLength,
    'phase': phase,
    'buildMillis': buildMillis,
    'rasterMillis': rasterMillis,
    'buildOverBudget': buildOverBudget,
    'rasterOverBudget': rasterOverBudget,
    'artifactPath': artifactPath,
  };
}

/// Viewport metadata captured by the profile integration test.
final class ProfileBaselineViewport {
  /// Creates viewport metadata.
  const ProfileBaselineViewport({
    required this.logicalWidth,
    required this.logicalHeight,
    required this.physicalWidth,
    required this.physicalHeight,
    required this.devicePixelRatio,
  });

  /// Logical Flutter view width.
  final double logicalWidth;

  /// Logical Flutter view height.
  final double logicalHeight;

  /// Physical Flutter view width.
  final double physicalWidth;

  /// Physical Flutter view height.
  final double physicalHeight;

  /// Flutter view device-pixel ratio.
  final double devicePixelRatio;

  /// Converts this viewport to JSON.
  Map<String, Object?> toJson() => <String, Object?>{
    'logicalWidth': logicalWidth,
    'logicalHeight': logicalHeight,
    'physicalWidth': physicalWidth,
    'physicalHeight': physicalHeight,
    'devicePixelRatio': devicePixelRatio,
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
    required this.updateMaxElapsedMicros,
    required this.updateMaxElapsedChunk,
    required this.updateMaxElapsedFraction,
    required this.updateMaxElapsedInputLength,
    required this.updateWorstBuildMillis,
    required this.updateWorstRasterMillis,
    required this.updateMissedBuildBudgetCount,
    required this.updateMissedRasterBudgetCount,
    required this.updatePhaseMaxima,
    required this.updateWorstAttributedFrame,
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

  /// Maximum update latency in microseconds, when present.
  final int? updateMaxElapsedMicros;

  /// Chunk index for the maximum update latency, when present.
  final int? updateMaxElapsedChunk;

  /// Fraction marker for the maximum update latency, when present.
  final double? updateMaxElapsedFraction;

  /// Input length for the maximum update latency, when present.
  final int? updateMaxElapsedInputLength;

  /// Worst update build duration in milliseconds, when present.
  final double? updateWorstBuildMillis;

  /// Worst update raster duration in milliseconds, when present.
  final double? updateWorstRasterMillis;

  /// Missed update build-budget count, when present.
  final int? updateMissedBuildBudgetCount;

  /// Missed update raster-budget count, when present.
  final int? updateMissedRasterBudgetCount;

  /// Maximum observed duration for each measured update phase.
  final Map<String, ProfileBaselineUpdatePhaseMaximum> updatePhaseMaxima;

  /// Worst attributed update frame observed in this repeat, when present.
  final ProfileBaselineUpdateWorstFrame? updateWorstAttributedFrame;

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
    if (updateMaxElapsedMicros != null)
      'updateMaxElapsedMicros': updateMaxElapsedMicros,
    if (updateMaxElapsedChunk != null)
      'updateMaxElapsedChunk': updateMaxElapsedChunk,
    if (updateMaxElapsedFraction != null)
      'updateMaxElapsedFraction': updateMaxElapsedFraction,
    if (updateMaxElapsedInputLength != null)
      'updateMaxElapsedInputLength': updateMaxElapsedInputLength,
    if (updateWorstBuildMillis != null)
      'updateWorstBuildMillis': updateWorstBuildMillis,
    if (updateWorstRasterMillis != null)
      'updateWorstRasterMillis': updateWorstRasterMillis,
    if (updateMissedBuildBudgetCount != null)
      'updateMissedBuildBudgetCount': updateMissedBuildBudgetCount,
    if (updateMissedRasterBudgetCount != null)
      'updateMissedRasterBudgetCount': updateMissedRasterBudgetCount,
    if (updatePhaseMaxima.isNotEmpty)
      'updatePhaseMaxima': updatePhaseMaxima.map(
        (phase, maximum) => MapEntry(phase, maximum.toJson()),
      ),
    if (updateWorstAttributedFrame != null)
      'updateWorstAttributedFrame': updateWorstAttributedFrame!.toJson(),
  };
}

/// Summarizes a collected profile baseline matrix.
ProfileBaselineSummary summarizeProfileBaselineManifest({
  required File manifestFile,
  Directory? workspaceRoot,
  DateTime Function()? clock,
}) {
  final manifest =
      jsonDecode(manifestFile.readAsStringSync()) as Map<String, Object?>;
  final manifestDirectory = manifestFile.parent.path;
  final rootPath =
      workspaceRoot?.path ??
      manifestFile.parent.parent.parent.parent.parent.path;
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
    final artifactFile = File(p.join(rootPath, artifactPath));
    final artifact = _readArtifact(artifactFile, run);
    final record = _ProfileBaselineRunRecord(
      run: run,
      metrics: artifact.metrics,
      initialRenderMetrics: artifact.initialRenderMetrics,
      warmRebuildMetrics: artifact.warmRebuildMetrics,
      viewport: artifact.viewport,
      inputPayload: artifact.inputPayload,
      launchAttribution: artifact.launchAttribution,
      updateMetrics: artifact.updateMetrics,
      updateLatencies: artifact.updateLatencies,
    );
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
              viewports: _uniqueViewports(
                records
                    .map((record) => record.viewport)
                    .whereType<ProfileBaselineViewport>(),
              ),
              inputSummary: _buildInputSummary(records),
              framePhaseSummaries: _buildFramePhaseSummaries(records),
              launchAttribution: _buildLaunchAttributionSummary(records),
              updateSummary: _buildUpdateSummary(records),
              outlierRepeats: _detectOutliers(records),
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
    manifestPath: p.relative(manifestFile.path, from: rootPath),
    runDirectory: p.relative(manifestDirectory, from: rootPath),
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
  Directory? workspaceRoot,
  DateTime Function()? clock,
}) {
  final summary = summarizeProfileBaselineManifest(
    manifestFile: manifestFile,
    workspaceRoot: workspaceRoot,
    clock: clock,
  );
  return File(p.join(manifestFile.parent.path, 'profile-baseline-summary.json'))
    ..writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(summary.toJson())}\n',
    );
}

ProfileBaselineInputSummary? _buildInputSummary(
  List<_ProfileBaselineRunRecord> records,
) {
  final payloads = records
      .map((record) => record.inputPayload)
      .whereType<_ProfileInputPayload>()
      .toList(growable: false);
  if (payloads.isEmpty) {
    return null;
  }

  return ProfileBaselineInputSummary(
    observedRepeats: payloads.length,
    inputBytes: _summarizeInts(payloads.map((payload) => payload.inputBytes)),
    inputLength: _summarizeInts(payloads.map((payload) => payload.inputLength)),
    sourceTypes: _uniqueStrings(
      payloads.map((payload) => payload.sourceType).whereType<String>(),
    ),
    assetPaths: _uniqueStrings(
      payloads.map((payload) => payload.assetPath).whereType<String>(),
    ),
  );
}

Map<String, ProfileBaselineFramePhaseSummary> _buildFramePhaseSummaries(
  List<_ProfileBaselineRunRecord> records,
) {
  final summaries = <String, ProfileBaselineFramePhaseSummary>{
    'warmScroll': _summarizeFramePhaseMetrics(
      records.map((record) => record.metrics),
    ),
  };
  final initialRenderMetrics = records
      .map((record) => record.initialRenderMetrics)
      .whereType<_ProfileMetrics>()
      .toList(growable: false);
  if (initialRenderMetrics.isNotEmpty) {
    summaries['coldInitialRender'] = _summarizeFramePhaseMetrics(
      initialRenderMetrics,
    );
  }
  final warmRebuildMetrics = records
      .map((record) => record.warmRebuildMetrics)
      .whereType<_ProfileMetrics>()
      .toList(growable: false);
  if (warmRebuildMetrics.isNotEmpty) {
    summaries['warmRebuild'] = _summarizeFramePhaseMetrics(warmRebuildMetrics);
  }
  return Map<String, ProfileBaselineFramePhaseSummary>.unmodifiable(summaries);
}

ProfileBaselineLaunchAttributionSummary _buildLaunchAttributionSummary(
  List<_ProfileBaselineRunRecord> records,
) {
  final available = records
      .map((record) => record.launchAttribution)
      .where((payload) => payload.status == 'available')
      .toList(growable: false);
  final missingRepeats = records.length - available.length;
  final unavailableReasons = _uniqueStrings(
    records
        .map((record) => record.launchAttribution.reason)
        .whereType<String>()
        .where((reason) => reason.isNotEmpty),
  );
  final status = switch ((available.isNotEmpty, missingRepeats > 0)) {
    (true, true) => 'partial',
    (true, false) => 'available',
    (false, _) => 'unavailable',
  };
  final intervalSamples = <String, List<double>>{};
  for (final payload in available) {
    for (final entry in payload.intervals.entries) {
      intervalSamples
          .putIfAbsent(entry.key, () => <double>[])
          .add(entry.value.toDouble());
    }
  }

  return ProfileBaselineLaunchAttributionSummary(
    status: status,
    observedRepeats: available.length,
    missingRepeats: missingRepeats,
    provenances: _uniqueStrings(
      available.map((payload) => payload.provenance).whereType<String>(),
    ),
    scopes: _uniqueStrings(
      available.map((payload) => payload.scope).whereType<String>(),
    ),
    intervalMicros: Map<String, ProfileBaselineNumberSummary>.unmodifiable(
      intervalSamples.map(
        (name, values) => MapEntry(name, _summarizeDoubles(values)),
      ),
    ),
    unavailableReasons: unavailableReasons,
  );
}

ProfileBaselineFramePhaseSummary _summarizeFramePhaseMetrics(
  Iterable<_ProfileMetrics> metrics,
) {
  final values = metrics.toList(growable: false);
  return ProfileBaselineFramePhaseSummary(
    observedRepeats: values.length,
    frameCount: _summarizeInts(values.map((metric) => metric.frameCount)),
    averageBuildMillis: _summarizeDoubles(
      values.map((metric) => metric.averageBuildMillis),
    ),
    p90BuildMillis: _summarizeDoubles(
      values.map((metric) => metric.p90BuildMillis),
    ),
    worstBuildMillis: _summarizeDoubles(
      values.map((metric) => metric.worstBuildMillis),
    ),
    averageRasterMillis: _summarizeDoubles(
      values.map((metric) => metric.averageRasterMillis),
    ),
    p90RasterMillis: _summarizeDoubles(
      values.map((metric) => metric.p90RasterMillis),
    ),
    worstRasterMillis: _summarizeDoubles(
      values.map((metric) => metric.worstRasterMillis),
    ),
    missedBuildBudgetCount: _summarizeCounts(
      values.map((metric) => metric.missedBuildBudgetCount),
    ),
    missedRasterBudgetCount: _summarizeCounts(
      values.map((metric) => metric.missedRasterBudgetCount),
    ),
  );
}

final class _ProfileBaselineRunRecord {
  const _ProfileBaselineRunRecord({
    required this.run,
    required this.metrics,
    required this.initialRenderMetrics,
    required this.warmRebuildMetrics,
    required this.viewport,
    required this.inputPayload,
    required this.launchAttribution,
    required this.updateMetrics,
    required this.updateLatencies,
  });

  final _ManifestRun run;
  final _ProfileMetrics metrics;
  final _ProfileMetrics? initialRenderMetrics;
  final _ProfileMetrics? warmRebuildMetrics;
  final ProfileBaselineViewport? viewport;
  final _ProfileInputPayload? inputPayload;
  final _ProfileLaunchAttributionPayload launchAttribution;
  final _ProfileUpdateMetrics? updateMetrics;
  final List<_ProfileUpdateLatencySample> updateLatencies;
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

final class _ProfileUpdateMetrics {
  const _ProfileUpdateMetrics({
    required this.worstBuildMillis,
    required this.worstRasterMillis,
    required this.missedBuildBudgetCount,
    required this.missedRasterBudgetCount,
  });

  final double worstBuildMillis;
  final double worstRasterMillis;
  final int missedBuildBudgetCount;
  final int missedRasterBudgetCount;
}

final class _ProfileUpdateLatencySample {
  const _ProfileUpdateLatencySample({
    required this.chunk,
    required this.fraction,
    required this.inputLength,
    required this.elapsedMicros,
    required this.applyPatchMicros,
    required this.pumpWidgetMicros,
    required this.settleMicros,
    required this.frameTimingAttribution,
  });

  final int chunk;
  final double fraction;
  final int inputLength;
  final int elapsedMicros;
  final int? applyPatchMicros;
  final int? pumpWidgetMicros;
  final int? settleMicros;
  final _ProfileUpdateFrameTimingAttribution? frameTimingAttribution;

  int? phaseMicros(String phaseField) => switch (phaseField) {
    'applyPatchMicros' => applyPatchMicros,
    'pumpWidgetMicros' => pumpWidgetMicros,
    'settleMicros' => settleMicros,
    _ => null,
  };
}

final class _ProfileUpdateFrameTimingAttribution {
  const _ProfileUpdateFrameTimingAttribution({
    required this.frameCount,
    required this.missedBuildBudgetCount,
    required this.missedRasterBudgetCount,
    required this.worstFrame,
  });

  final int frameCount;
  final int missedBuildBudgetCount;
  final int missedRasterBudgetCount;
  final _ProfileUpdateAttributedFrame? worstFrame;
}

final class _ProfileUpdateAttributedFrame {
  const _ProfileUpdateAttributedFrame({
    required this.phase,
    required this.buildMillis,
    required this.rasterMillis,
    required this.buildOverBudget,
    required this.rasterOverBudget,
  });

  final String phase;
  final double buildMillis;
  final double rasterMillis;
  final bool buildOverBudget;
  final bool rasterOverBudget;

  double get score => buildMillis > rasterMillis ? buildMillis : rasterMillis;
}

final class _ProfileLaunchAttributionPayload {
  const _ProfileLaunchAttributionPayload({
    required this.status,
    required this.scope,
    required this.provenance,
    required this.reason,
    required this.intervals,
  });

  final String status;
  final String? scope;
  final String? provenance;
  final String? reason;
  final Map<String, int> intervals;
}

final class _ProfileInputPayload {
  const _ProfileInputPayload({
    required this.inputBytes,
    required this.inputLength,
    required this.sourceType,
    required this.assetPath,
  });

  final int inputBytes;
  final int inputLength;
  final String? sourceType;
  final String? assetPath;
}

final class _ProfileArtifact {
  const _ProfileArtifact({
    required this.metrics,
    required this.initialRenderMetrics,
    required this.warmRebuildMetrics,
    required this.viewport,
    required this.inputPayload,
    required this.launchAttribution,
    required this.updateMetrics,
    required this.updateLatencies,
  });

  final _ProfileMetrics metrics;
  final _ProfileMetrics? initialRenderMetrics;
  final _ProfileMetrics? warmRebuildMetrics;
  final ProfileBaselineViewport? viewport;
  final _ProfileInputPayload? inputPayload;
  final _ProfileLaunchAttributionPayload launchAttribution;
  final _ProfileUpdateMetrics? updateMetrics;
  final List<_ProfileUpdateLatencySample> updateLatencies;
}

_ProfileArtifact _readArtifact(File artifactFile, _ManifestRun run) {
  final root =
      jsonDecode(artifactFile.readAsStringSync()) as Map<String, Object?>;
  final metricsKey = '${run.renderer}_${run.fixture}_scroll';
  final payload = root[metricsKey] ?? _findMetricsPayload(root);
  final initialRenderKey = '${run.renderer}_${run.fixture}_initial_render';
  final initialRenderPayload = root[initialRenderKey];
  final warmRebuildKey = '${run.renderer}_${run.fixture}_warm_rebuild';
  final warmRebuildPayload = root[warmRebuildKey];
  if (payload is! Map<String, Object?>) {
    throw const FormatException(
      'Expected benchmark frame metrics in the profile artifact.',
    );
  }

  final viewportKey = '${run.renderer}_${run.fixture}_viewport';
  final viewportPayload = root[viewportKey];
  final inputKey = '${run.renderer}_${run.fixture}_input';
  final inputPayload = root[inputKey];
  final launchAttributionKey =
      '${run.renderer}_${run.fixture}_launch_attribution';
  final launchAttributionPayload = root[launchAttributionKey];
  final updateMetricsKey = '${run.renderer}_${run.fixture}_updates';
  final updateMetricsPayload = root[updateMetricsKey];
  final updateLatenciesKey = '${run.renderer}_${run.fixture}_update_latencies';
  final updateLatenciesPayload = root[updateLatenciesKey];

  return _ProfileArtifact(
    metrics: _readProfileMetrics(payload),
    initialRenderMetrics: initialRenderPayload is Map<String, Object?>
        ? _readProfileMetrics(initialRenderPayload)
        : null,
    warmRebuildMetrics: warmRebuildPayload is Map<String, Object?>
        ? _readProfileMetrics(warmRebuildPayload)
        : null,
    viewport: viewportPayload is Map<String, Object?>
        ? _readViewport(viewportPayload)
        : null,
    inputPayload: inputPayload is Map<String, Object?>
        ? _readInputPayload(inputPayload)
        : null,
    launchAttribution: launchAttributionPayload is Map<String, Object?>
        ? _readLaunchAttributionPayload(launchAttributionPayload)
        : const _ProfileLaunchAttributionPayload(
            status: 'unavailable',
            scope: null,
            provenance: null,
            reason: 'missing_launch_attribution_payload',
            intervals: <String, int>{},
          ),
    updateMetrics: updateMetricsPayload is Map<String, Object?>
        ? _readUpdateMetrics(updateMetricsPayload)
        : null,
    updateLatencies: updateLatenciesPayload is List<Object?>
        ? _readUpdateLatencies(updateLatenciesPayload)
        : const <_ProfileUpdateLatencySample>[],
  );
}

_ProfileInputPayload _readInputPayload(Map<String, Object?> payload) {
  final inputBytes = _readOptionalInt(payload, 'inputBytes');
  final inputLength = _readOptionalInt(payload, 'inputLength');
  if (inputBytes == null && inputLength == null) {
    throw const FormatException(
      'Expected inputBytes or inputLength in the input metadata payload.',
    );
  }

  return _ProfileInputPayload(
    inputBytes: inputBytes ?? inputLength!,
    inputLength: inputLength ?? inputBytes!,
    sourceType: payload['sourceType'] as String?,
    assetPath: payload['assetPath'] as String?,
  );
}

_ProfileLaunchAttributionPayload _readLaunchAttributionPayload(
  Map<String, Object?> payload,
) {
  final status = payload['status'] as String? ?? 'unavailable';
  final intervals = <String, int>{};
  final rawIntervals = payload['intervals'];
  if (rawIntervals is Map<String, Object?>) {
    for (final entry in rawIntervals.entries) {
      final value = entry.value;
      if (value is int) {
        intervals[entry.key] = value;
      } else if (value is num) {
        intervals[entry.key] = value.round();
      }
    }
  }

  return _ProfileLaunchAttributionPayload(
    status: status,
    scope: payload['scope'] as String?,
    provenance: payload['provenance'] as String?,
    reason: payload['reason'] as String?,
    intervals: Map<String, int>.unmodifiable(intervals),
  );
}

_ProfileMetrics _readProfileMetrics(Map<String, Object?> payload) {
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

_ProfileUpdateMetrics _readUpdateMetrics(Map<String, Object?> payload) {
  return _ProfileUpdateMetrics(
    worstBuildMillis: (payload['worst_frame_build_time_millis']! as num)
        .toDouble(),
    worstRasterMillis: (payload['worst_frame_rasterizer_time_millis']! as num)
        .toDouble(),
    missedBuildBudgetCount: payload['missed_frame_build_budget_count']! as int,
    missedRasterBudgetCount:
        payload['missed_frame_rasterizer_budget_count']! as int,
  );
}

List<_ProfileUpdateLatencySample> _readUpdateLatencies(List<Object?> payload) {
  return List<_ProfileUpdateLatencySample>.unmodifiable(
    payload.map((entry) {
      final json = entry! as Map<String, Object?>;
      return _ProfileUpdateLatencySample(
        chunk: json['chunk']! as int,
        fraction: (json['fraction']! as num).toDouble(),
        inputLength: json['inputLength']! as int,
        elapsedMicros: json['elapsedMicros']! as int,
        applyPatchMicros: _readOptionalInt(json, 'applyPatchMicros'),
        pumpWidgetMicros: _readOptionalInt(json, 'pumpWidgetMicros'),
        settleMicros: _readOptionalInt(json, 'settleMicros'),
        frameTimingAttribution: _readUpdateFrameTimingAttribution(
          json['frameTimingAttribution'],
        ),
      );
    }),
  );
}

_ProfileUpdateFrameTimingAttribution? _readUpdateFrameTimingAttribution(
  Object? payload,
) {
  if (payload == null) {
    return null;
  }
  if (payload is! Map<String, Object?>) {
    throw const FormatException(
      'Expected frameTimingAttribution to be a JSON map.',
    );
  }

  final frameCount = payload['frameCount'];
  if (frameCount is! int || frameCount < 0) {
    throw const FormatException(
      'frameTimingAttribution.frameCount must be an integer >= 0.',
    );
  }

  return _ProfileUpdateFrameTimingAttribution(
    frameCount: frameCount,
    missedBuildBudgetCount:
        _readOptionalInt(payload, 'missedBuildBudgetCount') ?? 0,
    missedRasterBudgetCount:
        _readOptionalInt(payload, 'missedRasterBudgetCount') ?? 0,
    worstFrame: _readUpdateAttributedFrame(payload['worstFrame']),
  );
}

_ProfileUpdateAttributedFrame? _readUpdateAttributedFrame(Object? payload) {
  if (payload == null) {
    return null;
  }
  if (payload is! Map<String, Object?>) {
    throw const FormatException(
      'Expected frameTimingAttribution.worstFrame to be a JSON map.',
    );
  }

  final phase = payload['phase'];
  if (phase is! String || phase.trim().isEmpty) {
    throw const FormatException(
      'frameTimingAttribution.worstFrame.phase must be a non-empty string.',
    );
  }

  return _ProfileUpdateAttributedFrame(
    phase: phase,
    buildMillis: (payload['buildMillis']! as num).toDouble(),
    rasterMillis: (payload['rasterMillis']! as num).toDouble(),
    buildOverBudget: payload['buildOverBudget'] as bool? ?? false,
    rasterOverBudget: payload['rasterOverBudget'] as bool? ?? false,
  );
}

int? _readOptionalInt(Map<String, Object?> payload, String key) {
  final value = payload[key];
  if (value == null) {
    return null;
  }
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  throw FormatException('Expected optional integer "$key".');
}

Map<String, Object?>? _findMetricsPayload(Map<String, Object?> root) {
  for (final value in root.values) {
    if (value is Map<String, Object?> && value.containsKey('frame_count')) {
      return value;
    }
  }
  return null;
}

ProfileBaselineViewport _readViewport(Map<String, Object?> payload) {
  return ProfileBaselineViewport(
    logicalWidth: (payload['logicalWidth']! as num).toDouble(),
    logicalHeight: (payload['logicalHeight']! as num).toDouble(),
    physicalWidth: (payload['physicalWidth']! as num).toDouble(),
    physicalHeight: (payload['physicalHeight']! as num).toDouble(),
    devicePixelRatio: (payload['devicePixelRatio']! as num).toDouble(),
  );
}

List<ProfileBaselineViewport> _uniqueViewports(
  Iterable<ProfileBaselineViewport> viewports,
) {
  final unique = <String, ProfileBaselineViewport>{};
  for (final viewport in viewports) {
    unique.putIfAbsent(jsonEncode(viewport.toJson()), () => viewport);
  }
  return List<ProfileBaselineViewport>.unmodifiable(unique.values);
}

List<String> _uniqueStrings(Iterable<String> values) {
  final unique = <String>{};
  for (final value in values) {
    if (value.trim().isEmpty) {
      continue;
    }
    unique.add(value);
  }
  final ordered = unique.toList()..sort();
  return List<String>.unmodifiable(ordered);
}

ProfileBaselineCellUpdateSummary? _buildUpdateSummary(
  List<_ProfileBaselineRunRecord> records,
) {
  final updateRecords = records
      .where(
        (record) =>
            record.updateMetrics != null || record.updateLatencies.isNotEmpty,
      )
      .toList(growable: false);
  if (updateRecords.isEmpty) {
    return null;
  }

  final latencyEntries = <_ObservedUpdateLatency>[];
  final updateMetrics = <_ProfileUpdateMetrics>[];
  for (final record in updateRecords) {
    final metrics = record.updateMetrics;
    if (metrics != null) {
      updateMetrics.add(metrics);
    }
    for (final sample in record.updateLatencies) {
      latencyEntries.add(
        _ObservedUpdateLatency(
          repeat: record.run.repeat,
          artifactPath: record.run.artifactPath!,
          sample: sample,
        ),
      );
    }
  }

  _ObservedUpdateLatency? maxLatency;
  for (final entry in latencyEntries) {
    if (maxLatency == null ||
        entry.sample.elapsedMicros > maxLatency.sample.elapsedMicros) {
      maxLatency = entry;
    }
  }

  return ProfileBaselineCellUpdateSummary(
    observedRepeats: updateRecords.length,
    observedUpdateCount: latencyEntries.length,
    maxElapsedMicros: maxLatency?.sample.elapsedMicros,
    maxElapsedMillis: maxLatency == null
        ? null
        : maxLatency.sample.elapsedMicros / 1000.0,
    maxElapsedRepeat: maxLatency?.repeat,
    maxElapsedChunk: maxLatency?.sample.chunk,
    maxElapsedFraction: maxLatency?.sample.fraction,
    maxElapsedInputLength: maxLatency?.sample.inputLength,
    maxElapsedArtifactPath: maxLatency?.artifactPath,
    worstBuildMillis: updateMetrics.isEmpty
        ? null
        : _summarizeDoubles(
            updateMetrics.map((metrics) => metrics.worstBuildMillis),
          ),
    worstRasterMillis: updateMetrics.isEmpty
        ? null
        : _summarizeDoubles(
            updateMetrics.map((metrics) => metrics.worstRasterMillis),
          ),
    missedBuildBudgetCount: updateMetrics.isEmpty
        ? null
        : _summarizeCounts(
            updateMetrics.map((metrics) => metrics.missedBuildBudgetCount),
          ),
    missedRasterBudgetCount: updateMetrics.isEmpty
        ? null
        : _summarizeCounts(
            updateMetrics.map((metrics) => metrics.missedRasterBudgetCount),
          ),
    phaseMaxima: _summarizeUpdatePhaseMaxima(latencyEntries),
    worstAttributedFrame: _summarizeWorstAttributedFrame(latencyEntries),
  );
}

List<ProfileBaselineOutlier> _detectOutliers(
  List<_ProfileBaselineRunRecord> records,
) {
  final perRepeatMaxUpdateLatencies = records
      .map(_maxUpdateLatencyMicros)
      .whereType<int>()
      .toList(growable: false);
  final medianUpdateLatencyMicros = perRepeatMaxUpdateLatencies.isEmpty
      ? null
      : _medianInt(perRepeatMaxUpdateLatencies);

  return List<ProfileBaselineOutlier>.unmodifiable(
    records
        .map(
          (record) => _detectOutlier(
            record,
            medianUpdateLatencyMicros: medianUpdateLatencyMicros,
          ),
        )
        .whereType<ProfileBaselineOutlier>(),
  );
}

ProfileBaselineOutlier? _detectOutlier(
  _ProfileBaselineRunRecord record, {
  required int? medianUpdateLatencyMicros,
}) {
  final reasons = <String>[];
  final metrics = record.metrics;
  final updateMetrics = record.updateMetrics;
  final maxUpdateLatency = _maxObservedUpdateLatency(record);

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
  if (_isUpdateLatencySpike(
    maxLatency: maxUpdateLatency?.sample.elapsedMicros,
    medianLatency: medianUpdateLatencyMicros,
  )) {
    reasons.add('update_latency_spike');
  }
  if (updateMetrics != null && updateMetrics.missedBuildBudgetCount > 0) {
    reasons.add('update_missed_build_budget');
  }
  if (updateMetrics != null && updateMetrics.missedRasterBudgetCount > 0) {
    reasons.add('update_missed_raster_budget');
  }
  if (updateMetrics != null &&
      updateMetrics.worstBuildMillis > _frameBudgetMillis) {
    reasons.add('update_worst_build_over_budget');
  }
  if (updateMetrics != null &&
      updateMetrics.worstRasterMillis > _frameBudgetMillis) {
    reasons.add('update_worst_raster_over_budget');
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
    updateMaxElapsedMicros: maxUpdateLatency?.sample.elapsedMicros,
    updateMaxElapsedChunk: maxUpdateLatency?.sample.chunk,
    updateMaxElapsedFraction: maxUpdateLatency?.sample.fraction,
    updateMaxElapsedInputLength: maxUpdateLatency?.sample.inputLength,
    updateWorstBuildMillis: updateMetrics?.worstBuildMillis,
    updateWorstRasterMillis: updateMetrics?.worstRasterMillis,
    updateMissedBuildBudgetCount: updateMetrics?.missedBuildBudgetCount,
    updateMissedRasterBudgetCount: updateMetrics?.missedRasterBudgetCount,
    updatePhaseMaxima: _summarizeUpdatePhaseMaxima(
      record.updateLatencies
          .map(
            (sample) => _ObservedUpdateLatency(
              repeat: record.run.repeat,
              artifactPath: record.run.artifactPath!,
              sample: sample,
            ),
          )
          .toList(growable: false),
    ),
    updateWorstAttributedFrame: _summarizeWorstAttributedFrame(
      record.updateLatencies
          .map(
            (sample) => _ObservedUpdateLatency(
              repeat: record.run.repeat,
              artifactPath: record.run.artifactPath!,
              sample: sample,
            ),
          )
          .toList(growable: false),
    ),
  );
}

final class _ObservedUpdateLatency {
  const _ObservedUpdateLatency({
    required this.repeat,
    required this.artifactPath,
    required this.sample,
  });

  final int repeat;
  final String artifactPath;
  final _ProfileUpdateLatencySample sample;
}

final class _ObservedUpdateWorstFrame {
  const _ObservedUpdateWorstFrame({
    required this.observedLatency,
    required this.frame,
  });

  final _ObservedUpdateLatency observedLatency;
  final _ProfileUpdateAttributedFrame frame;
}

_ObservedUpdateLatency? _maxObservedUpdateLatency(
  _ProfileBaselineRunRecord record,
) {
  _ObservedUpdateLatency? maxLatency;
  for (final sample in record.updateLatencies) {
    final observed = _ObservedUpdateLatency(
      repeat: record.run.repeat,
      artifactPath: record.run.artifactPath!,
      sample: sample,
    );
    if (maxLatency == null ||
        observed.sample.elapsedMicros > maxLatency.sample.elapsedMicros) {
      maxLatency = observed;
    }
  }
  return maxLatency;
}

int? _maxUpdateLatencyMicros(_ProfileBaselineRunRecord record) {
  final latency = _maxObservedUpdateLatency(record);
  return latency?.sample.elapsedMicros;
}

bool _isUpdateLatencySpike({
  required int? maxLatency,
  required int? medianLatency,
}) {
  if (maxLatency == null || maxLatency < _updateLatencySpikeThresholdMicros) {
    return false;
  }
  if (medianLatency == null || medianLatency <= 0) {
    return true;
  }
  return maxLatency >= medianLatency * _updateLatencySpikeMultiplier;
}

const List<String> _updatePhaseFields = <String>[
  'applyPatchMicros',
  'pumpWidgetMicros',
  'settleMicros',
];

Map<String, ProfileBaselineUpdatePhaseMaximum> _summarizeUpdatePhaseMaxima(
  Iterable<_ObservedUpdateLatency> latencyEntries,
) {
  final maxima = <String, _ObservedUpdateLatencyWithPhase>{};
  for (final entry in latencyEntries) {
    for (final phaseField in _updatePhaseFields) {
      final phaseMicros = entry.sample.phaseMicros(phaseField);
      if (phaseMicros == null) {
        continue;
      }
      final observed = _ObservedUpdateLatencyWithPhase(
        observedLatency: entry,
        phaseField: phaseField,
        phaseMicros: phaseMicros,
      );
      final current = maxima[phaseField];
      if (current == null || observed.phaseMicros > current.phaseMicros) {
        maxima[phaseField] = observed;
      }
    }
  }

  return Map<String, ProfileBaselineUpdatePhaseMaximum>.unmodifiable(
    maxima.map(
      (phaseField, observed) => MapEntry(
        phaseField,
        ProfileBaselineUpdatePhaseMaximum(
          maxMicros: observed.phaseMicros,
          maxMillis: observed.phaseMicros / 1000.0,
          repeat: observed.observedLatency.repeat,
          chunk: observed.observedLatency.sample.chunk,
          fraction: observed.observedLatency.sample.fraction,
          inputLength: observed.observedLatency.sample.inputLength,
          artifactPath: observed.observedLatency.artifactPath,
        ),
      ),
    ),
  );
}

ProfileBaselineUpdateWorstFrame? _summarizeWorstAttributedFrame(
  Iterable<_ObservedUpdateLatency> latencyEntries,
) {
  _ObservedUpdateWorstFrame? worstFrame;
  for (final entry in latencyEntries) {
    final observedFrame = entry.sample.frameTimingAttribution?.worstFrame;
    if (observedFrame == null) {
      continue;
    }
    final observed = _ObservedUpdateWorstFrame(
      observedLatency: entry,
      frame: observedFrame,
    );
    final current = worstFrame;
    if (current == null ||
        observed.frame.score > current.frame.score ||
        (observed.frame.score == current.frame.score &&
            observed.observedLatency.repeat < current.observedLatency.repeat)) {
      worstFrame = observed;
    }
  }

  if (worstFrame == null) {
    return null;
  }

  return ProfileBaselineUpdateWorstFrame(
    repeat: worstFrame.observedLatency.repeat,
    chunk: worstFrame.observedLatency.sample.chunk,
    fraction: worstFrame.observedLatency.sample.fraction,
    inputLength: worstFrame.observedLatency.sample.inputLength,
    phase: worstFrame.frame.phase,
    buildMillis: worstFrame.frame.buildMillis,
    rasterMillis: worstFrame.frame.rasterMillis,
    buildOverBudget: worstFrame.frame.buildOverBudget,
    rasterOverBudget: worstFrame.frame.rasterOverBudget,
    artifactPath: worstFrame.observedLatency.artifactPath,
  );
}

int _medianInt(List<int> values) {
  final sorted = values.toList(growable: false)..sort();
  return sorted[(sorted.length - 1) ~/ 2];
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

final class _ObservedUpdateLatencyWithPhase {
  const _ObservedUpdateLatencyWithPhase({
    required this.observedLatency,
    required this.phaseField,
    required this.phaseMicros,
  });

  final _ObservedUpdateLatency observedLatency;
  final String phaseField;
  final int phaseMicros;
}
