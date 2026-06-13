import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

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
    this.retainingPathClassTargets = const <String>[],
    this.retainingPathSampleLimit = 1,
    this.retainingPathLimit = 20,
    this.writeRawHeapSnapshot = false,
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

  /// Class targets for optional retained-path sampling.
  ///
  /// A target may be either a class name such as `TagflowDocumentNode`, or a
  /// library-qualified selector such as
  /// `package:tagflow/src/runtime/document.dart::TagflowDocumentNode`.
  final List<String> retainingPathClassTargets;

  /// Maximum instances to sample for each matched retained-path class target.
  final int retainingPathSampleLimit;

  /// Maximum number of objects to include in each retaining path.
  final int retainingPathLimit;

  /// Whether to write raw VM-service heap snapshot chunks.
  final bool writeRawHeapSnapshot;
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
    this.retainingPathsPath,
    this.heapSnapshotPath,
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

  /// Path to the retained-path JSON, when class targets were requested.
  final String? retainingPathsPath;

  /// Path to the raw heap snapshot JSON, when requested.
  final String? heapSnapshotPath;

  /// Converts this result to machine-readable JSON.
  Map<String, Object?> toJson() => <String, Object?>{
    'vmServiceUri': vmServiceUri.toString(),
    'isolateId': isolateId,
    'checkpoint': checkpoint,
    'heapSummaryPath': heapSummaryPath,
    'allocationProfilePath': allocationProfilePath,
    if (retainingPathsPath != null) 'retainingPathsPath': retainingPathsPath,
    if (heapSnapshotPath != null) 'heapSnapshotPath': heapSnapshotPath,
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

    String? heapSnapshotPath;
    if (options.writeRawHeapSnapshot) {
      heapSnapshotPath = paths.heapSnapshotPath;
      _writePrettyJson(
        File(heapSnapshotPath),
        serializeRawHeapSnapshotChunks(
          heapSnapshot.toChunks(),
          graphName: heapSnapshot.name,
        ),
      );
    }

    String? retainingPathsPath;
    if (options.retainingPathClassTargets.isNotEmpty) {
      retainingPathsPath = paths.retainingPathsPath;
      _writePrettyJson(
        File(retainingPathsPath),
        await exportRetainingPathSummary(
          service: service,
          isolateId: isolateId,
          allocationProfile: allocationProfile,
          classTargets: options.retainingPathClassTargets,
          sampleLimit: options.retainingPathSampleLimit,
          retainingPathLimit: options.retainingPathLimit,
        ),
      );
    }

    return MemoryEvidenceExportResult(
      vmServiceUri: options.vmServiceUri,
      isolateId: isolateId,
      checkpoint: options.checkpoint,
      heapSummaryPath: paths.heapSummaryPath,
      allocationProfilePath: paths.allocationProfilePath,
      retainingPathsPath: retainingPathsPath,
      heapSnapshotPath: heapSnapshotPath,
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
    required this.retainingPathsPath,
    required this.heapSnapshotPath,
    required this.allocationDiffPath,
  });

  /// Heap snapshot class summary path.
  final String heapSummaryPath;

  /// Allocation profile path.
  final String allocationProfilePath;

  /// Retained-path sampling path.
  final String retainingPathsPath;

  /// Raw VM-service heap snapshot path.
  final String heapSnapshotPath;

  /// Class-level allocation diff path.
  final String allocationDiffPath;
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
    retainingPathsPath: p.join(
      outputDirectory.path,
      '$normalizedCheckpoint-retaining-paths.json',
    ),
    heapSnapshotPath: p.join(
      outputDirectory.path,
      '$normalizedCheckpoint-heap-snapshot.json',
    ),
    allocationDiffPath: p.join(
      outputDirectory.path,
      '$normalizedCheckpoint-allocation-diff.json',
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

/// Serializes raw VM-service heap snapshot chunks to JSON.
Map<String, Object?> serializeRawHeapSnapshotChunks(
  List<ByteData> chunks, {
  required String graphName,
}) {
  return <String, Object?>{
    'type': 'tagflow.memory.heapSnapshot',
    'format': 'vmService.heapSnapshotGraph.chunks.base64',
    'name': graphName,
    'chunkCount': chunks.length,
    'chunksBase64': [
      for (final chunk in chunks)
        base64Encode(
          Uint8List.view(
            chunk.buffer,
            chunk.offsetInBytes,
            chunk.lengthInBytes,
          ),
        ),
    ],
  };
}

/// Parses a raw heap snapshot artifact written by
/// [serializeRawHeapSnapshotChunks].
HeapSnapshotGraph parseRawHeapSnapshotArtifact(Map<String, Object?> artifact) {
  if (artifact['type'] != 'tagflow.memory.heapSnapshot') {
    throw const FormatException('Expected tagflow.memory.heapSnapshot.');
  }
  if (artifact['format'] != 'vmService.heapSnapshotGraph.chunks.base64') {
    throw const FormatException('Unsupported heap snapshot artifact format.');
  }

  final chunksJson = artifact['chunksBase64'];
  if (chunksJson is! List) {
    throw const FormatException('Heap snapshot chunksBase64 must be a list.');
  }

  return HeapSnapshotGraph.fromChunks(
    [
      for (final encoded in chunksJson)
        if (encoded is String)
          ByteData.sublistView(Uint8List.fromList(base64Decode(encoded)))
        else
          throw const FormatException(
            'Heap snapshot chunksBase64 entries must be strings.',
          ),
    ],
    calculateReferrers: false,
    decodeObjectData: false,
    decodeExternalProperties: false,
    decodeIdentityHashCodes: false,
  );
}

/// Builds a report-only class-level diff from two memory evidence artifacts.
Future<Map<String, Object?>> diffMemoryEvidenceArtifacts({
  required String baseArtifactPath,
  required String headArtifactPath,
  List<String> classTargets = const <String>[],
  int topClasses = 30,
}) async {
  if (topClasses < 1) {
    throw ArgumentError.value(topClasses, 'topClasses', 'Must be at least 1.');
  }

  final base = _readMemoryClassRows(File(baseArtifactPath));
  final head = _readMemoryClassRows(File(headArtifactPath));
  final normalizedTargets = normalizeRetainingPathClassTargets(classTargets);
  final selectedKeys = <String>{};

  final selectedClasses = [
    for (final target in normalizedTargets)
      _diffForTarget(
        target: target,
        baseRows: base.rows,
        headRows: head.rows,
        selectedKeys: selectedKeys,
      ),
  ];

  final topDeltas =
      _diffRows(
          base.rows,
          head.rows,
        ).where((row) => !selectedKeys.contains(row.key)).toList()
        ..sort(_compareDiffRows);

  final complete =
      base.coverage == _MemoryArtifactCoverage.rawHeapSnapshot &&
      head.coverage == _MemoryArtifactCoverage.rawHeapSnapshot;
  return <String, Object?>{
    'type': 'tagflow.memory.allocationDiff',
    'baseArtifact': <String, Object?>{
      'path': baseArtifactPath,
      'type': base.type,
    },
    'headArtifact': <String, Object?>{
      'path': headArtifactPath,
      'type': head.type,
    },
    'coverage': <String, Object?>{
      'base': base.coverage.name,
      'head': head.coverage.name,
      'complete': complete,
    },
    if (!complete)
      'warnings': [
        [
          'Heap summary inputs only cover embedded class rows; raw heap',
          'snapshots provide complete diff coverage.',
        ].join(' '),
      ],
    'classTargets': normalizedTargets,
    'selectedClasses': selectedClasses,
    'topDeltas': [for (final row in topDeltas.take(topClasses)) row.toJson()],
  };
}

/// Exports bounded retained-path samples for selected allocation classes.
Future<Map<String, Object?>> exportRetainingPathSummary({
  required VmService service,
  required String isolateId,
  required AllocationProfile allocationProfile,
  required List<String> classTargets,
  int sampleLimit = 1,
  int retainingPathLimit = 20,
}) async {
  if (sampleLimit < 1) {
    throw ArgumentError.value(
      sampleLimit,
      'sampleLimit',
      'Must be at least 1.',
    );
  }
  if (retainingPathLimit < 1) {
    throw ArgumentError.value(
      retainingPathLimit,
      'retainingPathLimit',
      'Must be at least 1.',
    );
  }

  final normalizedTargets = normalizeRetainingPathClassTargets(classTargets);
  final members = allocationProfile.members ?? const <ClassHeapStats>[];

  return <String, Object?>{
    'type': 'tagflow.memory.retainingPaths',
    'isolateId': isolateId,
    'classTargets': normalizedTargets,
    'sampleLimit': sampleLimit,
    'retainingPathLimit': retainingPathLimit,
    'classes': [
      for (final target in normalizedTargets)
        <String, Object?>{
          'target': target,
          'matches': [
            for (final member in members)
              if (_matchesClassTarget(member.classRef, target))
                await _retainingPathClassSummary(
                  service: service,
                  isolateId: isolateId,
                  classStats: member,
                  sampleLimit: sampleLimit,
                  retainingPathLimit: retainingPathLimit,
                ),
          ],
        },
    ],
  };
}

/// Normalizes retained-path class targets from CLI/config input.
List<String> normalizeRetainingPathClassTargets(Iterable<String> targets) {
  final normalized = <String>[];
  final seen = <String>{};
  for (final target in targets) {
    for (final part in target.split(',')) {
      final value = part.trim();
      if (value.isEmpty) {
        continue;
      }
      if (!RegExp(
        r'^[A-Za-z0-9_.$:/-]+(?:::[A-Za-z0-9_.$-]+)?$',
      ).hasMatch(value)) {
        throw ArgumentError.value(
          value,
          'targets',
          'Use class names or library-uri::ClassName selectors.',
        );
      }
      if (seen.add(value)) {
        normalized.add(value);
      }
    }
  }
  return List.unmodifiable(normalized);
}

bool _matchesClassTarget(ClassRef? classRef, String target) {
  if (classRef == null) {
    return false;
  }
  final className = classRef.name;
  if (className == target) {
    return true;
  }
  final libraryUri = classRef.library?.uri;
  return libraryUri != null && '$libraryUri::$className' == target;
}

Future<Map<String, Object?>> _retainingPathClassSummary({
  required VmService service,
  required String isolateId,
  required ClassHeapStats classStats,
  required int sampleLimit,
  required int retainingPathLimit,
}) async {
  final classRef = classStats.classRef;
  final classId = classRef?.id;
  if (classRef == null || classId == null) {
    return <String, Object?>{
      'class': classRef?.toJson(),
      'error': 'Matched class does not expose a VM-service class id.',
    };
  }

  final instanceSet = await service.getInstances(
    isolateId,
    classId,
    sampleLimit,
  );
  final instances = instanceSet.instances ?? const <ObjRef>[];

  return <String, Object?>{
    'class': classRef.toJson(),
    'instancesCurrent': classStats.instancesCurrent,
    'bytesCurrent': classStats.bytesCurrent,
    'totalCount': instanceSet.totalCount,
    'sampledInstances': [
      for (final instance in instances)
        await _retainingPathInstanceSummary(
          service: service,
          isolateId: isolateId,
          instance: instance,
          retainingPathLimit: retainingPathLimit,
        ),
    ],
  };
}

Future<Map<String, Object?>> _retainingPathInstanceSummary({
  required VmService service,
  required String isolateId,
  required ObjRef instance,
  required int retainingPathLimit,
}) async {
  final instanceId = instance.id;
  if (instanceId == null) {
    return <String, Object?>{
      'instance': instance.toJson(),
      'error': 'Instance does not expose a VM-service object id.',
    };
  }

  final retainingPath = await service.getRetainingPath(
    isolateId,
    instanceId,
    retainingPathLimit,
  );
  return <String, Object?>{
    'instance': instance.toJson(),
    'retainingPath': retainingPath.toJson(),
  };
}

void _writePrettyJson(File file, Object? json) {
  file.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(json)}\n',
  );
}

_MemoryClassRows _readMemoryClassRows(File file) {
  final decoded = jsonDecode(file.readAsStringSync());
  if (decoded is! Map<String, Object?>) {
    throw const FormatException(
      'Memory evidence artifact must be a JSON object.',
    );
  }

  switch (decoded['type']) {
    case 'tagflow.memory.heapSummary':
      return _MemoryClassRows(
        type: 'tagflow.memory.heapSummary',
        coverage: _MemoryArtifactCoverage.topClassesOnly,
        rows: _classRowsFromHeapSummary(decoded),
      );
    case 'tagflow.memory.heapSnapshot':
      return _MemoryClassRows(
        type: 'tagflow.memory.heapSnapshot',
        coverage: _MemoryArtifactCoverage.rawHeapSnapshot,
        rows: _classRowsFromGraph(parseRawHeapSnapshotArtifact(decoded)),
      );
  }

  throw FormatException(
    'Unsupported memory evidence artifact: ${decoded['type']}',
  );
}

List<_ClassRow> _classRowsFromHeapSummary(Map<String, Object?> artifact) {
  final topClasses = artifact['topClasses'];
  if (topClasses is! List) {
    throw const FormatException('Heap summary topClasses must be a list.');
  }

  return [
    for (final row in topClasses)
      if (row is Map<String, Object?>)
        _ClassRow(
          className: _requiredString(row, 'className'),
          libraryUri: _requiredString(row, 'libraryUri'),
          instanceCount: _requiredInt(row, 'instanceCount'),
          shallowSize: _requiredInt(row, 'shallowSize'),
        )
      else
        throw const FormatException('Heap summary class rows must be objects.'),
  ];
}

List<_ClassRow> _classRowsFromGraph(HeapSnapshotGraph graph) {
  final summaries = <String, _HeapClassSummary>{};
  for (final object in graph.objects.skip(1)) {
    final klass = object.klass;
    final key = '${klass.libraryUri}::${klass.name}';
    summaries
        .putIfAbsent(
          key,
          () => _HeapClassSummary(
            classId: klass.classId,
            className: klass.name,
            libraryUri: klass.libraryUri.toString(),
          ),
        )
        .addObject(object.shallowSize);
  }

  return [
    for (final summary in summaries.values)
      _ClassRow(
        className: summary.className,
        libraryUri: summary.libraryUri,
        instanceCount: summary.instanceCount,
        shallowSize: summary.shallowSize,
      ),
  ];
}

Map<String, Object?> _diffForTarget({
  required String target,
  required List<_ClassRow> baseRows,
  required List<_ClassRow> headRows,
  required Set<String> selectedKeys,
}) {
  final baseRow = baseRows.cast<_ClassRow?>().firstWhere(
    (row) => row != null && _matchesClassRowTarget(row, target),
    orElse: () => null,
  );
  final headRow = headRows.cast<_ClassRow?>().firstWhere(
    (row) => row != null && _matchesClassRowTarget(row, target),
    orElse: () => null,
  );
  final row = _ClassDiffRow.fromRows(baseRow: baseRow, headRow: headRow);
  selectedKeys.add(row.key);
  return <String, Object?>{'target': target, ...row.toJson()};
}

List<_ClassDiffRow> _diffRows(
  List<_ClassRow> baseRows,
  List<_ClassRow> headRows,
) {
  final rowsByKey = <String, (_ClassRow?, _ClassRow?)>{};
  for (final row in baseRows) {
    rowsByKey[row.key] = (row, rowsByKey[row.key]?.$2);
  }
  for (final row in headRows) {
    rowsByKey[row.key] = (rowsByKey[row.key]?.$1, row);
  }

  return [
    for (final entry in rowsByKey.entries)
      _ClassDiffRow.fromRows(baseRow: entry.value.$1, headRow: entry.value.$2),
  ];
}

int _compareDiffRows(_ClassDiffRow left, _ClassDiffRow right) {
  final leftGrowth = left.deltaShallowSize >= 0 ? 1 : 0;
  final rightGrowth = right.deltaShallowSize >= 0 ? 1 : 0;
  final growthComparison = rightGrowth.compareTo(leftGrowth);
  if (growthComparison != 0) {
    return growthComparison;
  }

  final sizeComparison = right.deltaShallowSize.abs().compareTo(
    left.deltaShallowSize.abs(),
  );
  if (sizeComparison != 0) {
    return sizeComparison;
  }

  final countComparison = right.deltaInstanceCount.abs().compareTo(
    left.deltaInstanceCount.abs(),
  );
  if (countComparison != 0) {
    return countComparison;
  }

  return left.className.compareTo(right.className);
}

bool _matchesClassRowTarget(_ClassRow row, String target) {
  return row.className == target || row.key == target;
}

String _requiredString(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is String) {
    return value;
  }
  throw FormatException('$key must be a string.');
}

int _requiredInt(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is int) {
    return value;
  }
  throw FormatException('$key must be an integer.');
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

enum _MemoryArtifactCoverage { rawHeapSnapshot, topClassesOnly }

final class _MemoryClassRows {
  const _MemoryClassRows({
    required this.type,
    required this.coverage,
    required this.rows,
  });

  final String type;
  final _MemoryArtifactCoverage coverage;
  final List<_ClassRow> rows;
}

final class _ClassRow {
  const _ClassRow({
    required this.className,
    required this.libraryUri,
    required this.instanceCount,
    required this.shallowSize,
  });

  final String className;
  final String libraryUri;
  final int instanceCount;
  final int shallowSize;

  String get key => '$libraryUri::$className';
}

final class _ClassDiffRow {
  const _ClassDiffRow({
    required this.className,
    required this.libraryUri,
    required this.baseInstanceCount,
    required this.headInstanceCount,
    required this.baseShallowSize,
    required this.headShallowSize,
  });

  factory _ClassDiffRow.fromRows({
    required _ClassRow? baseRow,
    required _ClassRow? headRow,
  }) {
    final row = headRow ?? baseRow;
    if (row == null) {
      return const _ClassDiffRow(
        className: '',
        libraryUri: '',
        baseInstanceCount: 0,
        headInstanceCount: 0,
        baseShallowSize: 0,
        headShallowSize: 0,
      );
    }
    return _ClassDiffRow(
      className: row.className,
      libraryUri: row.libraryUri,
      baseInstanceCount: baseRow?.instanceCount ?? 0,
      headInstanceCount: headRow?.instanceCount ?? 0,
      baseShallowSize: baseRow?.shallowSize ?? 0,
      headShallowSize: headRow?.shallowSize ?? 0,
    );
  }

  final String className;
  final String libraryUri;
  final int baseInstanceCount;
  final int headInstanceCount;
  final int baseShallowSize;
  final int headShallowSize;

  int get deltaInstanceCount => headInstanceCount - baseInstanceCount;

  int get deltaShallowSize => headShallowSize - baseShallowSize;

  String get key => '$libraryUri::$className';

  Map<String, Object?> toJson() => <String, Object?>{
    'className': className,
    'libraryUri': libraryUri,
    'baseInstanceCount': baseInstanceCount,
    'headInstanceCount': headInstanceCount,
    'deltaInstanceCount': deltaInstanceCount,
    'baseShallowSize': baseShallowSize,
    'headShallowSize': headShallowSize,
    'deltaShallowSize': deltaShallowSize,
  };
}
