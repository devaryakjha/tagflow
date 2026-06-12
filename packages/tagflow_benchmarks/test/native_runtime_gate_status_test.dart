import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:tagflow_benchmarks/src/gates/native_runtime_gate_status.dart';
import 'package:tagflow_benchmarks/src/io/package_paths.dart';

void main() {
  test('passes a profile when all required gates are satisfied', () {
    final manifestFile = _writeManifest(
      requiredGateIds: <String>['runtime-surface', 'benchmark-gate'],
      gates: <Map<String, Object?>>[
        _gate('runtime-surface', 'satisfied'),
        _gate('benchmark-gate', 'satisfied'),
        _gate('real-app-route', 'open'),
      ],
    );
    addTearDown(() => manifestFile.parent.deleteSync(recursive: true));

    final result = checkNativeRuntimeGateStatus(
      manifestFile: manifestFile,
      profileId: 'draft',
    );

    expect(result.passed, isTrue);
    expect(result.issues, isEmpty);
    expect(result.nonRequiredOpenGates.single.id, 'real-app-route');
    expect(result.toJson(), containsPair('passed', true));
  });

  test('fails a profile when a required gate is open', () {
    final manifestFile = _writeManifest(
      requiredGateIds: <String>['runtime-surface', 'real-app-route'],
      gates: <Map<String, Object?>>[
        _gate('runtime-surface', 'satisfied'),
        _gate(
          'real-app-route',
          'open',
          tracker: 'https://github.com/devaryakjha/tagflow/issues/73',
        ),
      ],
    );
    addTearDown(() => manifestFile.parent.deleteSync(recursive: true));

    final result = checkNativeRuntimeGateStatus(
      manifestFile: manifestFile,
      profileId: 'draft',
    );

    expect(result.passed, isFalse);
    expect(result.issues, hasLength(1));
    expect(result.issues.single.code, 'required_gate_not_satisfied');
    expect(
      result.issues.single.details,
      containsPair('gateId', 'real-app-route'),
    );
    expect(
      result.issues.single.details,
      containsPair(
        'tracker',
        'https://github.com/devaryakjha/tagflow/issues/73',
      ),
    );
  });

  test('fails a profile when a required gate id is not defined', () {
    final manifestFile = _writeManifest(
      requiredGateIds: <String>['missing-gate'],
      gates: <Map<String, Object?>>[_gate('runtime-surface', 'satisfied')],
    );
    addTearDown(() => manifestFile.parent.deleteSync(recursive: true));

    final result = checkNativeRuntimeGateStatus(
      manifestFile: manifestFile,
      profileId: 'draft',
    );

    expect(result.passed, isFalse);
    expect(result.issues.single.code, 'required_gate_missing');
    expect(
      result.issues.single.details,
      containsPair('gateId', 'missing-gate'),
    );
  });

  test('rejects duplicate gate ids', () {
    final manifestFile = _writeManifest(
      requiredGateIds: <String>['runtime-surface'],
      gates: <Map<String, Object?>>[
        _gate('runtime-surface', 'satisfied'),
        _gate('runtime-surface', 'open'),
      ],
    );
    addTearDown(() => manifestFile.parent.deleteSync(recursive: true));

    expect(
      () => checkNativeRuntimeGateStatus(
        manifestFile: manifestFile,
        profileId: 'draft',
      ),
      throwsFormatException,
    );
  });

  test('reads the checked repo manifest profile boundaries', () {
    final workspaceRoot = resolveWorkspaceRoot();
    final result = checkNativeRuntimeGateStatus(
      manifestFile: File(
        p.join(
          workspaceRoot.path,
          'docs',
          'plans',
          'native-runtime-gate-status.json',
        ),
      ),
      profileId: 'pr72-draft',
    );

    expect(result.passed, isTrue);
    expect(
      result.nonRequiredOpenGates.map((gate) => gate.id),
      containsAll(<String>[
        'real-app-route',
        'physical-observed-profile',
        'memory-allocation-review',
        'release-approval',
      ]),
    );
  });
}

File _writeManifest({
  required List<String> requiredGateIds,
  required List<Map<String, Object?>> gates,
}) {
  final directory = Directory.systemTemp.createTempSync(
    'tagflow_gate_status_test_',
  );
  final file = File(p.join(directory.path, 'manifest.json'))
    ..writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(<String, Object?>{
        'schemaVersion': 1,
        'id': 'test-manifest',
        'description': 'Test manifest',
        'profiles': <Map<String, Object?>>[
          <String, Object?>{
            'id': 'draft',
            'description': 'Draft profile',
            'requiredGateIds': requiredGateIds,
          },
        ],
        'gates': gates,
      }),
    );
  return file;
}

Map<String, Object?> _gate(String id, String status, {String? tracker}) {
  return <String, Object?>{
    'id': id,
    'status': status,
    'summary': '$id summary',
    if (tracker != null) 'tracker': tracker,
  };
}
