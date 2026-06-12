import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:vm_service/utils.dart';
import 'package:vm_service/vm_service.dart';
import 'package:vm_service/vm_service_io.dart';

/// Options for exporting report-only memory evidence from a live VM service.
final class MemoryEvidenceExportOptions {
  /// Creates memory evidence export options.
  const MemoryEvidenceExportOptions({
    required this.vmServiceUri,
    required this.outputDirectory,
    required this.checkpoint,
    this.isolateId,
    this.topClasses = 30,
    this.gc = true,
  });

  /// HTTP or WebSocket VM service URI for a live profile target.
  final Uri vmServiceUri;

  /// Directory where JSON evidence files should be written.
  final Directory outputDirectory;

  /// Reviewer-facing checkpoint label, for example `after_first_patch`.
  final String checkpoint;

  /// Optional exact isolate id. Defaults to the first isolate reported by VM.
  final String? isolateId;

  /// Number of heap classes to include in the summary.
  final int topClasses;

  /// Whether to request GC before reading the allocation profile.
  final bool gc;
}

/// Result produced by [exportMemoryEvidence].
final class MemoryEvidenceExportResult {
  /// Creates a memory evidence export result.
  const MemoryEvidenceExportResult({
    required this.vmServiceUri,
    required this.isolateId,
    required this.checkpoint,
    required this.heapSummaryPath,
    required this.allocationProfilePath,
  });

  /// Connected VM service URI.
  final Uri vmServiceUri;

  /// Isolate used for export.
  final String isolateId;

  /// Checkpoint label tied to this export.
  final String checkpoint;

  /// Path to the heap snapshot summary JSON.
  final String heapSummaryPath;

  /// Path to the allocation profile JSON.
  final String allocationProfilePath;

  /// Converts this result to machine-readable JSON.
  Map<String, Object?> toJson() => <String, Object?>{
    'vmServiceUri': vmServiceUri.toString(),
    'isolateId': isolateId,
    'checkpoint': checkpoint,
    'heapSummaryPath': heapSummaryPath,
    'allocationProfilePath': allocationProfilePath,
  };
}

/// Connects to `options.vmServiceUri` and writes report-only memory evidence.
Future<MemoryEvidenceExportResult> exportMemoryEvidence(
  MemoryEvidenceExportOptions options,
) async {
  final service = await vmServiceConnectUri(
    convertToWebSocketUrl(serviceProtocolUrl: options.vmServiceUri).toString(),
  );

  try {
    final vm = await service.getVM();
    final isolate = _selectIsolate(vm, options.isolateId);
    final isolateId = isolate.id;
    if (isolateId == null) {
      throw StateError('Selected VM isolate does not expose an id.');
    }

    options.outputDirectory.createSync(recursive: true);
    final paths = memoryEvidenceExportPaths(
      outputDirectory: options.outputDirectory,
      checkpoint: options.checkpoint,
    );

    final allocationProfile = await service.getAllocationProfile(
      isolateId,
      gc: options.gc,
    );
    _writePrettyJson(
      File(paths.allocationProfilePath),
      allocationProfile.toJson(),
    );

    final heapSnapshot = await HeapSnapshotGraph.getSnapshot(
      service,
      isolate,
      calculateReferrers: false,
      decodeObjectData: false,
      decodeExternalProperties: false,
      decodeIdentityHashCodes: false,
    );
    _writePrettyJson(
      File(paths.heapSummaryPath),
      summarizeHeapSnapshot(heapSnapshot, topClasses: options.topClasses),
    );

    return MemoryEvidenceExportResult(
      vmServiceUri: options.vmServiceUri,
      isolateId: isolateId,
      checkpoint: options.checkpoint,
      heapSummaryPath: paths.heapSummaryPath,
      allocationProfilePath: paths.allocationProfilePath,
    );
  } finally {
    await service.dispose();
  }
}

/// File paths used by one memory evidence export.
final class MemoryEvidenceExportPaths {
  /// Creates memory evidence export paths.
  const MemoryEvidenceExportPaths({
    required this.heapSummaryPath,
    required this.allocationProfilePath,
  });

  /// Heap snapshot class summary path.
  final String heapSummaryPath;

  /// Allocation profile path.
  final String allocationProfilePath;
}

/// Resolves output paths for a checkpoint memory export.
MemoryEvidenceExportPaths memoryEvidenceExportPaths({
  required Directory outputDirectory,
  required String checkpoint,
}) {
  final normalizedCheckpoint = normalizeMemoryEvidenceCheckpoint(checkpoint);
  return MemoryEvidenceExportPaths(
    heapSummaryPath: p.join(
      outputDirectory.path,
      '$normalizedCheckpoint-heap-summary.json',
    ),
    allocationProfilePath: p.join(
      outputDirectory.path,
      '$normalizedCheckpoint-allocation-profile.json',
    ),
  );
}

/// Validates and normalizes a memory evidence checkpoint name for file output.
String normalizeMemoryEvidenceCheckpoint(String checkpoint) {
  final normalized = checkpoint.trim();
  if (!RegExp(r'^[A-Za-z0-9_.-]+$').hasMatch(normalized)) {
    throw ArgumentError.value(
      checkpoint,
      'checkpoint',
      'Use only letters, numbers, underscore, dash, or dot.',
    );
  }
  return normalized;
}

/// Produces a compact class-level summary from a VM-service heap snapshot.
Map<String, Object?> summarizeHeapSnapshot(
  HeapSnapshotGraph graph, {
  int topClasses = 30,
}) {
  if (topClasses < 1) {
    throw ArgumentError.value(topClasses, 'topClasses', 'Must be at least 1.');
  }

  final classes = <int, _HeapClassSummary>{};
  for (final object in graph.objects.skip(1)) {
    final klass = object.klass;
    classes
        .putIfAbsent(
          klass.classId,
          () => _HeapClassSummary(
            classId: klass.classId,
            className: klass.name,
            libraryUri: klass.libraryUri.toString(),
          ),
        )
        .addObject(object.shallowSize);
  }

  final topClassSummaries = classes.values.toList()
    ..sort((left, right) {
      final sizeComparison = right.shallowSize.compareTo(left.shallowSize);
      if (sizeComparison != 0) {
        return sizeComparison;
      }
      return right.instanceCount.compareTo(left.instanceCount);
    });

  return <String, Object?>{
    'type': 'tagflow.memory.heapSummary',
    'name': graph.name,
    'objectCount': graph.objects.isNotEmpty ? graph.objects.length - 1 : 0,
    'classCount': classes.length,
    'shallowSize': graph.shallowSize,
    'capacity': graph.capacity,
    'externalSize': graph.externalSize,
    'referenceCount': graph.referenceCount,
    'topClasses': topClassSummaries
        .take(topClasses)
        .map((summary) => summary.toJson())
        .toList(),
  };
}

void _writePrettyJson(File file, Object? json) {
  file.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(json)}\n',
  );
}

IsolateRef _selectIsolate(VM vm, String? isolateId) {
  final isolates = vm.isolates ?? const <IsolateRef>[];
  if (isolates.isEmpty) {
    throw StateError('VM service reported no isolates.');
  }
  if (isolateId == null || isolateId.trim().isEmpty) {
    return isolates.first;
  }
  for (final isolate in isolates) {
    if (isolate.id == isolateId || isolate.name == isolateId) {
      return isolate;
    }
  }
  throw StateError('No isolate matched "$isolateId".');
}

final class _HeapClassSummary {
  _HeapClassSummary({
    required this.classId,
    required this.className,
    required this.libraryUri,
  });

  final int classId;
  final String className;
  final String libraryUri;
  int instanceCount = 0;
  int shallowSize = 0;

  void addObject(int objectShallowSize) {
    instanceCount += 1;
    shallowSize += objectShallowSize;
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'classId': classId,
    'className': className,
    'libraryUri': libraryUri,
    'instanceCount': instanceCount,
    'shallowSize': shallowSize,
  };
}
