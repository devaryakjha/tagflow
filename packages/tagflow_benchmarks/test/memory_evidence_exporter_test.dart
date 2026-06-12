import 'dart:io';

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
    );

    expect(result.toJson(), <String, Object?>{
      'vmServiceUri': 'http://127.0.0.1:12345/abc=/',
      'isolateId': 'isolates/1',
      'checkpoint': 'after_scroll',
      'heapSummaryPath': 'after_scroll-heap-summary.json',
      'allocationProfilePath': 'after_scroll-allocation-profile.json',
    });
  });
}
