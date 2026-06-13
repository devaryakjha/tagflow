import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:tagflow_benchmarks/src/profile/memory_evidence_exporter.dart';

void main() {
  test('resolves checkpoint export paths under the output directory', () {
    final paths = memoryEvidenceExportPaths(
      outputDirectory: Directory(p.join('build', 'memory')),
      checkpoint: 'after_first_patch',
    );

    expect(
      paths.heapSummaryPath,
      p.join('build', 'memory', 'after_first_patch-heap-summary.json'),
    );
    expect(
      paths.allocationProfilePath,
      p.join('build', 'memory', 'after_first_patch-allocation-profile.json'),
    );
    expect(
      paths.retainingPathsPath,
      p.join('build', 'memory', 'after_first_patch-retaining-paths.json'),
    );
    expect(
      paths.heapSnapshotPath,
      p.join('build', 'memory', 'after_first_patch-heap-snapshot.json'),
    );
    expect(
      paths.allocationDiffPath,
      p.join('build', 'memory', 'after_first_patch-allocation-diff.json'),
    );
  });

  test('rejects unsafe checkpoint names', () {
    expect(
      () => normalizeMemoryEvidenceCheckpoint('../after_scroll'),
      throwsArgumentError,
    );
    expect(
      () => normalizeMemoryEvidenceCheckpoint('after scroll'),
      throwsArgumentError,
    );
  });

  test('serializes export results for command output', () {
    final result = MemoryEvidenceExportResult(
      vmServiceUri: Uri.parse('http://127.0.0.1:12345/abc=/'),
      isolateId: 'isolates/1',
      checkpoint: 'after_scroll',
      heapSummaryPath: 'after_scroll-heap-summary.json',
      allocationProfilePath: 'after_scroll-allocation-profile.json',
      retainingPathsPath: 'after_scroll-retaining-paths.json',
    );

    expect(result.toJson(), <String, Object?>{
      'vmServiceUri': 'http://127.0.0.1:12345/abc=/',
      'isolateId': 'isolates/1',
      'checkpoint': 'after_scroll',
      'heapSummaryPath': 'after_scroll-heap-summary.json',
      'allocationProfilePath': 'after_scroll-allocation-profile.json',
      'retainingPathsPath': 'after_scroll-retaining-paths.json',
    });
  });

  test('omits retaining path output when it was not requested', () {
    final result = MemoryEvidenceExportResult(
      vmServiceUri: Uri.parse('http://127.0.0.1:12345/abc=/'),
      isolateId: 'isolates/1',
      checkpoint: 'after_scroll',
      heapSummaryPath: 'after_scroll-heap-summary.json',
      allocationProfilePath: 'after_scroll-allocation-profile.json',
    );

    expect(result.toJson(), isNot(contains('retainingPathsPath')));
  });

  test('serializes raw heap snapshot chunks as base64 json', () {
    final artifact = serializeRawHeapSnapshotChunks([
      ByteData.sublistView(Uint8List.fromList([1, 2, 3])),
      ByteData.sublistView(Uint8List.fromList([4, 5])),
    ], graphName: 'main');

    expect(artifact, <String, Object?>{
      'type': 'tagflow.memory.heapSnapshot',
      'format': 'vmService.heapSnapshotGraph.chunks.base64',
      'name': 'main',
      'chunkCount': 2,
      'chunksBase64': ['AQID', 'BAU='],
    });
  });

  test('builds a class-level diff from heap summary inputs', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'tagflow-memory-diff-test',
    );
    addTearDown(() async {
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    final basePath = p.join(tempDir.path, 'before-heap-summary.json');
    final headPath = p.join(tempDir.path, 'after-heap-summary.json');
    await File(basePath).writeAsString(
      const JsonEncoder.withIndent('  ').convert(<String, Object?>{
        'type': 'tagflow.memory.heapSummary',
        'name': 'before_first_patch',
        'topClasses': [
          {
            'classId': 1,
            'className': 'TagflowDocumentNode',
            'libraryUri': 'package:tagflow/runtime.dart',
            'instanceCount': 2,
            'shallowSize': 40,
          },
          {
            'classId': 2,
            'className': 'Widget',
            'libraryUri': 'package:flutter/widgets.dart',
            'instanceCount': 4,
            'shallowSize': 100,
          },
        ],
      }),
    );
    await File(headPath).writeAsString(
      const JsonEncoder.withIndent('  ').convert(<String, Object?>{
        'type': 'tagflow.memory.heapSummary',
        'name': 'after_scroll',
        'topClasses': [
          {
            'classId': 1,
            'className': 'TagflowDocumentNode',
            'libraryUri': 'package:tagflow/runtime.dart',
            'instanceCount': 3,
            'shallowSize': 60,
          },
          {
            'classId': 3,
            'className': 'RenderObject',
            'libraryUri': 'package:flutter/rendering.dart',
            'instanceCount': 1,
            'shallowSize': 50,
          },
        ],
      }),
    );

    final diff = await diffMemoryEvidenceArtifacts(
      baseArtifactPath: basePath,
      headArtifactPath: headPath,
      classTargets: const ['package:tagflow/runtime.dart::TagflowDocumentNode'],
      topClasses: 2,
    );

    expect(diff['type'], 'tagflow.memory.allocationDiff');
    final baseArtifact = diff['baseArtifact']! as Map<String, Object?>;
    final headArtifact = diff['headArtifact']! as Map<String, Object?>;
    expect(baseArtifact['path'], basePath);
    expect(headArtifact['path'], headPath);
    expect(diff['coverage'], <String, Object?>{
      'base': 'topClassesOnly',
      'head': 'topClassesOnly',
      'complete': false,
    });
    expect(
      diff['warnings'],
      contains(
        'Heap summary inputs only cover embedded class rows; raw heap '
        'snapshots provide complete diff coverage.',
      ),
    );
    expect(diff['selectedClasses'], [
      <String, Object?>{
        'target': 'package:tagflow/runtime.dart::TagflowDocumentNode',
        'className': 'TagflowDocumentNode',
        'libraryUri': 'package:tagflow/runtime.dart',
        'baseInstanceCount': 2,
        'headInstanceCount': 3,
        'deltaInstanceCount': 1,
        'baseShallowSize': 40,
        'headShallowSize': 60,
        'deltaShallowSize': 20,
      },
    ]);
    expect(diff['topDeltas'], [
      <String, Object?>{
        'className': 'RenderObject',
        'libraryUri': 'package:flutter/rendering.dart',
        'baseInstanceCount': 0,
        'headInstanceCount': 1,
        'deltaInstanceCount': 1,
        'baseShallowSize': 0,
        'headShallowSize': 50,
        'deltaShallowSize': 50,
      },
      <String, Object?>{
        'className': 'Widget',
        'libraryUri': 'package:flutter/widgets.dart',
        'baseInstanceCount': 4,
        'headInstanceCount': 0,
        'deltaInstanceCount': -4,
        'baseShallowSize': 100,
        'headShallowSize': 0,
        'deltaShallowSize': -100,
      },
    ]);
  });

  test('normalizes retained-path class selectors', () {
    expect(
      normalizeRetainingPathClassTargets([
        'TagflowDocumentNode, TagflowDocument',
        'package:tagflow/src/runtime/document.dart::TagflowDocumentNode',
      ]),
      [
        'TagflowDocumentNode',
        'TagflowDocument',
        'package:tagflow/src/runtime/document.dart::TagflowDocumentNode',
      ],
    );
  });

  test('deduplicates retained-path class selectors in first-seen order', () {
    const qualifiedTagflowDocumentNode =
        'package:tagflow/src/runtime/document.dart::TagflowDocumentNode';

    expect(
      normalizeRetainingPathClassTargets([
        'TagflowDocumentNode, TagflowDocument',
        'TagflowDocumentNode',
        qualifiedTagflowDocumentNode,
        'TagflowDocument, $qualifiedTagflowDocumentNode',
      ]),
      ['TagflowDocumentNode', 'TagflowDocument', qualifiedTagflowDocumentNode],
    );
  });

  test('rejects unsafe retained-path class selectors', () {
    expect(
      () => normalizeRetainingPathClassTargets(['Tagflow Document']),
      throwsArgumentError,
    );
  });
}
