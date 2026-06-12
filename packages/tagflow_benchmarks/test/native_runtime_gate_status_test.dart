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
        _gate(
          'runtime-surface',
          'satisfied',
          evidence: <Object?>[_evidence('note', 'runtime implemented')],
        ),
        _gate(
          'benchmark-gate',
          'satisfied',
          evidence: <Object?>[_evidence('note', 'benchmark accepted')],
        ),
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

  test('fails when required localPath evidence is missing', () {
    final manifestFile = _writeManifest(
      requiredGateIds: <String>['runtime-surface'],
      gates: <Map<String, Object?>>[
        _gate(
          'runtime-surface',
          'satisfied',
          evidence: <Object?>[_evidence('localPath', 'missing.md')],
        ),
      ],
    );
    addTearDown(() => manifestFile.parent.deleteSync(recursive: true));

    final result = checkNativeRuntimeGateStatus(
      manifestFile: manifestFile,
      profileId: 'draft',
      evidenceRoot: manifestFile.parent,
    );

    expect(result.passed, isFalse);
    expect(result.issues.single.code, 'gate_evidence_path_missing');
    expect(result.issues.single.details, containsPair('path', 'missing.md'));
  });

  test('fails when non-required localPath evidence is missing', () {
    final manifestFile = _writeManifest(
      requiredGateIds: <String>['runtime-surface'],
      gates: <Map<String, Object?>>[
        _gate('runtime-surface', 'satisfied'),
        _gate(
          'future-route',
          'open',
          evidence: <Object?>[_evidence('localPath', 'missing-future.md')],
        ),
      ],
    );
    addTearDown(() => manifestFile.parent.deleteSync(recursive: true));

    final result = checkNativeRuntimeGateStatus(
      manifestFile: manifestFile,
      profileId: 'draft',
      evidenceRoot: manifestFile.parent,
    );

    expect(result.passed, isFalse);
    expect(result.issues.single.code, 'gate_evidence_path_missing');
    expect(
      result.issues.single.details,
      containsPair('gateId', 'future-route'),
    );
  });

  test('accepts existing required localPath evidence', () {
    final directory = Directory.systemTemp.createTempSync(
      'tagflow_gate_status_evidence_test_',
    );
    final evidenceFile = File(p.join(directory.path, 'evidence.md'))
      ..writeAsStringSync('evidence');
    final manifestFile = _writeManifest(
      directory: directory,
      requiredGateIds: <String>['runtime-surface'],
      gates: <Map<String, Object?>>[
        _gate(
          'runtime-surface',
          'satisfied',
          evidence: <Object?>[_evidence('localPath', 'evidence.md')],
        ),
      ],
    );
    addTearDown(() => directory.deleteSync(recursive: true));

    final result = checkNativeRuntimeGateStatus(
      manifestFile: manifestFile,
      profileId: 'draft',
      evidenceRoot: directory,
    );

    expect(evidenceFile.existsSync(), isTrue);
    expect(result.passed, isTrue);
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
    expect(result.requiredOpenGates.map((gate) => gate.id), <String>[
      'real-app-route',
    ]);
    expect(
      result.toJson(),
      containsPair(
        'requiredOpenGates',
        contains(
          containsPair(
            'tracker',
            'https://github.com/devaryakjha/tagflow/issues/73',
          ),
        ),
      ),
    );
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

  test('rejects profile references to undefined gates', () {
    final manifestFile = _writeManifest(
      requiredGateIds: <String>['missing-gate'],
      gates: <Map<String, Object?>>[_gate('runtime-surface', 'satisfied')],
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

  test('rejects unsupported or unsafe typed evidence', () {
    expect(
      () => NativeRuntimeGateEvidence.fromJson(<String, Object?>{
        'type': 'unknown',
        'value': 'x',
      }),
      throwsFormatException,
    );
    expect(
      () => NativeRuntimeGateEvidence.fromJson(<String, Object?>{
        'type': 'url',
        'value': 'http://github.com/devaryakjha/tagflow',
      }),
      throwsFormatException,
    );
    expect(
      () => NativeRuntimeGateEvidence.fromJson(<String, Object?>{
        'type': 'localPath',
        'value': '../outside.md',
      }),
      throwsFormatException,
    );
    expect(
      () => NativeRuntimeGateEvidence.fromJson(<String, Object?>{
        'type': 'note',
        'value': 'not a command',
        'cwd': '.',
      }),
      throwsFormatException,
    );
  });

  test('round-trips structured command evidence metadata', () {
    const pathValue = r'/Users/arya/fvm/cache.git/bin:$PATH';
    final evidence = NativeRuntimeGateEvidence.fromJson(<String, Object?>{
      'type': 'command',
      'value': 'dart run melos run validate',
      'cwd': '.',
      'env': <String, Object?>{'PATH': pathValue},
    });

    expect(evidence.type, NativeRuntimeGateEvidenceType.command);
    expect(evidence.cwd, '.');
    expect(evidence.env, containsPair('PATH', pathValue));
    expect(evidence.toJson(), containsPair('cwd', '.'));
    expect(
      evidence.toJson(),
      containsPair('env', containsPair('PATH', pathValue)),
    );
  });

  test('rejects unsafe structured command evidence metadata', () {
    expect(
      () => NativeRuntimeGateEvidence.fromJson(<String, Object?>{
        'type': 'command',
        'value': 'dart run melos run validate',
        'cwd': '../outside',
      }),
      throwsFormatException,
    );
    expect(
      () => NativeRuntimeGateEvidence.fromJson(<String, Object?>{
        'type': 'command',
        'value': 'dart run melos run validate',
        'env': <String, Object?>{'PATH': ''},
      }),
      throwsFormatException,
    );
  });

  test('rejects non-https tracker URLs', () {
    final manifestFile = _writeManifest(
      requiredGateIds: <String>['runtime-surface'],
      gates: <Map<String, Object?>>[
        _gate(
          'runtime-surface',
          'satisfied',
          tracker: 'http://github.com/devaryakjha/tagflow/issues/73',
        ),
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

  test('round-trips manifest schema version', () {
    final manifestFile = _writeManifest(
      requiredGateIds: <String>['runtime-surface'],
      gates: <Map<String, Object?>>[_gate('runtime-surface', 'satisfied')],
    );
    addTearDown(() => manifestFile.parent.deleteSync(recursive: true));

    final manifest = NativeRuntimeGateManifest.fromFile(manifestFile);

    expect(manifest.toJson(), containsPair('schemaVersion', 1));
  });

  test('round-trips gate claim boundary', () {
    final manifestFile = _writeManifest(
      requiredGateIds: <String>['memory-allocation-review'],
      gates: <Map<String, Object?>>[
        _gate(
          'memory-allocation-review',
          'satisfied',
          claimBoundary: 'Report-only local evidence.',
        ),
      ],
    );
    addTearDown(() => manifestFile.parent.deleteSync(recursive: true));

    final manifest = NativeRuntimeGateManifest.fromFile(manifestFile);
    final gate = manifest.gateById('memory-allocation-review');

    expect(gate?.claimBoundary, 'Report-only local evidence.');
    expect(
      gate?.toJson(),
      containsPair('claimBoundary', 'Report-only local evidence.'),
    );
  });

  test('reads the checked repo manifest profile boundaries', () {
    final workspaceRoot = resolveWorkspaceRoot();
    final manifestFile = File(
      p.join(
        workspaceRoot.path,
        'docs',
        'plans',
        'native-runtime-gate-status.json',
      ),
    );
    final draftResult = checkNativeRuntimeGateStatus(
      manifestFile: manifestFile,
      profileId: 'pr72-draft',
      evidenceRoot: workspaceRoot,
    );
    final readyResult = checkNativeRuntimeGateStatus(
      manifestFile: manifestFile,
      profileId: 'pr72-ready',
      evidenceRoot: workspaceRoot,
    );
    final betaPreapprovalResult = checkNativeRuntimeGateStatus(
      manifestFile: manifestFile,
      profileId: 'beta-preapproval',
      evidenceRoot: workspaceRoot,
    );
    final betaResult = checkNativeRuntimeGateStatus(
      manifestFile: manifestFile,
      profileId: 'beta-candidate',
      evidenceRoot: workspaceRoot,
    );

    expect(draftResult.passed, isTrue);
    expect(
      draftResult.nonRequiredOpenGates.map((gate) => gate.id),
      containsAll(<String>[
        'real-app-route',
        'physical-observed-profile',
        'release-approval',
      ]),
    );
    expect(
      draftResult.nonRequiredOpenGates.map((gate) => gate.id),
      isNot(contains('memory-allocation-review')),
    );

    expect(readyResult.passed, isFalse);
    expect(readyResult.issues.map((issue) => issue.details['gateId']), <String>[
      'real-app-route',
    ]);

    expect(betaPreapprovalResult.passed, isFalse);
    expect(
      betaPreapprovalResult.issues.map((issue) => issue.details['gateId']),
      <String>['real-app-route', 'physical-observed-profile'],
    );
    expect(
      betaPreapprovalResult.requiredOpenGates.map((gate) => gate.id),
      <String>['real-app-route', 'physical-observed-profile'],
    );
    expect(
      betaPreapprovalResult.requiredOpenGates.map((gate) => gate.tracker),
      <String>[
        'https://github.com/devaryakjha/tagflow/issues/73',
        'https://github.com/devaryakjha/tagflow/issues/75',
      ],
    );
    expect(
      betaPreapprovalResult.requiredOpenGates
          .expand((gate) => gate.evidence)
          .map((entry) => entry.value),
      containsAll(<String>[
        'docs/validation/evidence/2026-06-12-kite-non-gitlab-owner-acceptance-request.md',
        'docs/benchmarks/baselines/2026-06-12-physical-observed-profile-owner-decision-request.md',
        'docs/benchmarks/baselines/2026-06-12-target-availability-coredevice-refresh.md',
      ]),
    );
    expect(
      betaPreapprovalResult.issues.map((issue) => issue.details['gateId']),
      isNot(contains('release-approval')),
    );
    expect(
      betaPreapprovalResult.issues.map((issue) => issue.details['tracker']),
      contains('https://github.com/devaryakjha/tagflow/issues/75'),
    );

    expect(betaResult.passed, isFalse);
    expect(betaResult.issues.map((issue) => issue.details['gateId']), <String>[
      'real-app-route',
      'physical-observed-profile',
      'release-approval',
    ]);
    expect(
      betaResult.issues.map((issue) => issue.details['gateId']),
      isNot(contains('memory-allocation-review')),
    );

    final manifest = NativeRuntimeGateManifest.fromFile(manifestFile);
    final memoryGate = manifest.gateById('memory-allocation-review');

    expect(memoryGate?.status, NativeRuntimeGateStatus.satisfied);
    expect(memoryGate?.claimBoundary, contains('Report-only local macOS'));
    expect(
      memoryGate?.evidence.map((entry) => entry.value),
      containsAll(<String>[
        'docs/benchmarks/baselines/2026-06-12-authored-insertion-raw-heap-diff-evidence.md',
        'docs/benchmarks/baselines/2026-06-12-large-article-raw-heap-diff-evidence.md',
        'docs/benchmarks/baselines/2026-06-12-table-stress-raw-heap-diff-evidence.md',
      ]),
    );
  });

  test('keeps repo manifest memory gate claim boundaries in JSON output', () {
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
      evidenceRoot: workspaceRoot,
    );
    final manifestJson = NativeRuntimeGateManifest.fromFile(
      File(
        p.join(
          workspaceRoot.path,
          'docs',
          'plans',
          'native-runtime-gate-status.json',
        ),
      ),
    ).toJson();
    final gates = manifestJson['gates']! as List<Object?>;
    final memoryGateJson = gates.cast<Map<String, Object?>>().singleWhere(
      (gate) => gate['id'] == 'memory-allocation-review',
    );

    expect(result.passed, isTrue);
    expect(
      memoryGateJson,
      containsPair('claimBoundary', contains('does not support leak-free')),
    );
  });

  test('keeps coordination drafts out of repo manifest gate evidence', () {
    final workspaceRoot = resolveWorkspaceRoot();
    final manifestFile = File(
      p.join(
        workspaceRoot.path,
        'docs',
        'plans',
        'native-runtime-gate-status.json',
      ),
    );
    final manifest = NativeRuntimeGateManifest.fromFile(manifestFile);
    final releaseGate = manifest.gateById('release-approval');
    final evidenceValues = manifest.gates
        .expand((gate) => gate.evidence)
        .map((entry) => entry.value);

    expect(releaseGate?.status, NativeRuntimeGateStatus.deferred);
    expect(
      releaseGate?.evidence.map((entry) => entry.value),
      contains('docs/plans/2026-06-12-beta-release-approval-plan.md'),
    );
    expect(
      evidenceValues,
      isNot(contains('docs/plans/2026-06-12-beta-preapproval-packet-draft.md')),
    );
    expect(
      evidenceValues,
      isNot(contains('docs/plans/2026-06-12-alpha4-prebeta-coordination.md')),
    );
  });
}

File _writeManifest({
  required List<String> requiredGateIds,
  required List<Map<String, Object?>> gates,
  Directory? directory,
}) {
  final manifestDirectory =
      directory ??
      Directory.systemTemp.createTempSync('tagflow_gate_status_test_');
  final file = File(p.join(manifestDirectory.path, 'manifest.json'))
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

Map<String, Object?> _gate(
  String id,
  String status, {
  String? tracker,
  String? claimBoundary,
  List<Object?> evidence = const <Object?>[],
}) {
  return <String, Object?>{
    'id': id,
    'status': status,
    'summary': '$id summary',
    if (tracker != null) 'tracker': tracker,
    if (claimBoundary != null) 'claimBoundary': claimBoundary,
    if (evidence.isNotEmpty) 'evidence': evidence,
  };
}

Map<String, Object?> _evidence(String type, String value) {
  return <String, Object?>{'type': type, 'value': value};
}
