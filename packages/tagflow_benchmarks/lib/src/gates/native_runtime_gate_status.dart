import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

/// Gate status values accepted by the native runtime gate manifest.
enum NativeRuntimeGateStatus {
  /// Gate has evidence strong enough for the selected profile.
  satisfied,

  /// Gate is still open and requires more evidence or owner input.
  open,

  /// Gate is blocked on external state, but may still be tracked.
  blocked,

  /// Gate is intentionally deferred to a later release phase.
  deferred,
}

/// Evidence entry type accepted by the native runtime gate manifest.
enum NativeRuntimeGateEvidenceType {
  /// Workspace-relative local file path.
  localPath,

  /// External URL.
  url,

  /// Verification command.
  command,

  /// Human-readable evidence note.
  note,
}

/// Evidence supporting a native runtime gate status.
final class NativeRuntimeGateEvidence {
  /// Creates a gate evidence entry.
  const NativeRuntimeGateEvidence({
    required this.type,
    required this.value,
    this.cwd,
    this.env = const <String, String>{},
  });

  /// Reads evidence from JSON.
  ///
  /// Plain string entries are treated as notes for compatibility with the
  /// original gate manifest shape.
  factory NativeRuntimeGateEvidence.fromJson(Object? json) {
    if (json is String && json.trim().isNotEmpty) {
      return NativeRuntimeGateEvidence(
        type: NativeRuntimeGateEvidenceType.note,
        value: json,
      );
    }

    if (json is! Map<String, Object?>) {
      throw const FormatException(
        'Native runtime gate evidence must be a string or map.',
      );
    }

    final type = _readEvidenceType(json['type']);
    final value = _readNonEmptyString(json, 'value');
    final cwd = _readOptionalString(json, 'cwd');
    final env = _readOptionalStringMap(json, 'env');
    _validateEvidenceValue(type: type, value: value, cwd: cwd, env: env);

    return NativeRuntimeGateEvidence(
      type: type,
      value: value,
      cwd: cwd,
      env: env,
    );
  }

  /// Evidence entry type.
  final NativeRuntimeGateEvidenceType type;

  /// Evidence value.
  final String value;

  /// Optional workspace-relative command working directory.
  final String? cwd;

  /// Optional command environment metadata.
  final Map<String, String> env;

  /// Converts this evidence entry to machine-readable JSON.
  Map<String, Object?> toJson() => <String, Object?>{
    'type': _evidenceTypeValue(type),
    'value': value,
    if (cwd != null) 'cwd': cwd,
    if (env.isNotEmpty) 'env': env,
  };
}

/// A named release-readiness profile from the gate manifest.
final class NativeRuntimeGateProfile {
  /// Creates a gate profile.
  const NativeRuntimeGateProfile({
    required this.id,
    required this.description,
    required this.requiredGateIds,
  });

  /// Reads a gate profile from JSON.
  factory NativeRuntimeGateProfile.fromJson(Map<String, Object?> json) {
    final id = _readNonEmptyString(json, 'id');
    final description = _readNonEmptyString(json, 'description');
    final requiredGateIds = _readStringList(json, 'requiredGateIds');
    if (requiredGateIds.isEmpty) {
      throw FormatException(
        'Native runtime gate profile "$id" must require at least one gate.',
      );
    }

    return NativeRuntimeGateProfile(
      id: id,
      description: description,
      requiredGateIds: requiredGateIds,
    );
  }

  /// Stable profile id.
  final String id;

  /// Human-readable profile purpose.
  final String description;

  /// Gate ids that must be `satisfied` for this profile to pass.
  final List<String> requiredGateIds;

  /// Converts this profile to machine-readable JSON.
  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'description': description,
    'requiredGateIds': requiredGateIds,
  };
}

/// A single native runtime release-readiness gate.
final class NativeRuntimeGate {
  /// Creates a gate.
  const NativeRuntimeGate({
    required this.id,
    required this.status,
    required this.summary,
    required this.tracker,
    required this.claimBoundary,
    required this.evidence,
  });

  /// Reads a gate from JSON.
  factory NativeRuntimeGate.fromJson(Map<String, Object?> json) {
    return NativeRuntimeGate(
      id: _readNonEmptyString(json, 'id'),
      status: _readGateStatus(json['status']),
      summary: _readNonEmptyString(json, 'summary'),
      tracker: _readOptionalHttpsUrl(json, 'tracker'),
      claimBoundary: _readOptionalString(json, 'claimBoundary'),
      evidence: _readEvidenceList(json, 'evidence'),
    );
  }

  /// Stable gate id.
  final String id;

  /// Current gate status.
  final NativeRuntimeGateStatus status;

  /// Human-readable gate summary.
  final String summary;

  /// Optional external tracker URL.
  final String? tracker;

  /// Optional boundary for what this gate status is allowed to claim.
  final String? claimBoundary;

  /// Evidence supporting the current status.
  final List<NativeRuntimeGateEvidence> evidence;

  /// Converts this gate to machine-readable JSON.
  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'status': _gateStatusValue(status),
    'summary': summary,
    if (tracker != null) 'tracker': tracker,
    if (claimBoundary != null) 'claimBoundary': claimBoundary,
    if (evidence.isNotEmpty)
      'evidence': evidence.map((entry) => entry.toJson()).toList(),
  };
}

/// Machine-readable native runtime gate manifest.
final class NativeRuntimeGateManifest {
  /// Creates a gate manifest.
  const NativeRuntimeGateManifest({
    required this.id,
    required this.description,
    required this.profiles,
    required this.gates,
  });

  /// Reads a gate manifest from a JSON file.
  factory NativeRuntimeGateManifest.fromFile(File file) {
    final decoded = jsonDecode(file.readAsStringSync());
    if (decoded is! Map<String, Object?>) {
      throw const FormatException(
        'Native runtime gate manifest must be a JSON map.',
      );
    }
    return NativeRuntimeGateManifest.fromJson(decoded);
  }

  /// Reads a gate manifest from JSON.
  factory NativeRuntimeGateManifest.fromJson(Map<String, Object?> json) {
    final schemaVersion = json['schemaVersion'];
    if (schemaVersion != 1) {
      throw const FormatException(
        'Native runtime gate manifest schemaVersion must be 1.',
      );
    }

    final profiles = _readMapList(
      json,
      'profiles',
    ).map(NativeRuntimeGateProfile.fromJson).toList();
    if (profiles.isEmpty) {
      throw const FormatException(
        'Native runtime gate manifest must define at least one profile.',
      );
    }

    final gates = _readMapList(
      json,
      'gates',
    ).map(NativeRuntimeGate.fromJson).toList();
    if (gates.isEmpty) {
      throw const FormatException(
        'Native runtime gate manifest must define at least one gate.',
      );
    }

    _validateUniqueIds(
      label: 'profile',
      ids: profiles.map((profile) => profile.id),
    );
    _validateUniqueIds(label: 'gate', ids: gates.map((gate) => gate.id));
    _validateProfileGateReferences(profiles: profiles, gates: gates);

    return NativeRuntimeGateManifest(
      id: _readNonEmptyString(json, 'id'),
      description: _readNonEmptyString(json, 'description'),
      profiles: profiles,
      gates: gates,
    );
  }

  /// Stable manifest id.
  final String id;

  /// Human-readable manifest purpose.
  final String description;

  /// Readiness profiles.
  final List<NativeRuntimeGateProfile> profiles;

  /// Gate status entries.
  final List<NativeRuntimeGate> gates;

  /// Finds a profile by id.
  NativeRuntimeGateProfile profileById(String id) {
    for (final profile in profiles) {
      if (profile.id == id) {
        return profile;
      }
    }
    throw FormatException('Unknown native runtime gate profile: $id.');
  }

  /// Finds a gate by id.
  NativeRuntimeGate? gateById(String id) {
    for (final gate in gates) {
      if (gate.id == id) {
        return gate;
      }
    }
    return null;
  }

  /// Converts this manifest to machine-readable JSON.
  Map<String, Object?> toJson() => <String, Object?>{
    'schemaVersion': 1,
    'id': id,
    'description': description,
    'profiles': profiles.map((profile) => profile.toJson()).toList(),
    'gates': gates.map((gate) => gate.toJson()).toList(),
  };
}

/// Machine-checkable gate status issue.
final class NativeRuntimeGateStatusIssue {
  /// Creates a gate status issue.
  const NativeRuntimeGateStatusIssue({
    required this.code,
    required this.message,
    required this.details,
  });

  /// Stable issue code.
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

/// Result from checking one manifest profile.
final class NativeRuntimeGateStatusCheckResult {
  /// Creates a gate status check result.
  const NativeRuntimeGateStatusCheckResult({
    required this.manifestPath,
    required this.manifestId,
    required this.profile,
    required this.passed,
    required this.issues,
    required this.nonRequiredOpenGates,
  });

  /// Checked manifest path.
  final String manifestPath;

  /// Checked manifest id.
  final String manifestId;

  /// Checked readiness profile.
  final NativeRuntimeGateProfile profile;

  /// Whether every required gate is satisfied.
  final bool passed;

  /// Blocking issues for the selected profile.
  final List<NativeRuntimeGateStatusIssue> issues;

  /// Non-required gates that are still not satisfied.
  final List<NativeRuntimeGate> nonRequiredOpenGates;

  /// Converts this result to machine-readable JSON.
  Map<String, Object?> toJson() => <String, Object?>{
    'manifestPath': manifestPath,
    'manifestId': manifestId,
    'profile': profile.toJson(),
    'passed': passed,
    'issues': issues.map((issue) => issue.toJson()).toList(),
    'nonRequiredOpenGates': nonRequiredOpenGates
        .map((gate) => gate.toJson())
        .toList(),
  };
}

/// Checks one native runtime gate manifest profile.
NativeRuntimeGateStatusCheckResult checkNativeRuntimeGateStatus({
  required File manifestFile,
  required String profileId,
  Directory? evidenceRoot,
}) {
  final manifest = NativeRuntimeGateManifest.fromFile(manifestFile);
  final profile = manifest.profileById(profileId);
  final requiredGateIds = profile.requiredGateIds.toSet();
  final resolvedEvidenceRoot = evidenceRoot ?? manifestFile.parent;
  final issues = <NativeRuntimeGateStatusIssue>[];

  for (final gateId in profile.requiredGateIds) {
    final gate = manifest.gateById(gateId);
    if (gate == null) {
      issues.add(
        NativeRuntimeGateStatusIssue(
          code: 'required_gate_missing',
          message: 'Required gate "$gateId" is not defined in the manifest.',
          details: <String, Object?>{'gateId': gateId},
        ),
      );
      continue;
    }

    if (gate.status != NativeRuntimeGateStatus.satisfied) {
      issues.add(
        NativeRuntimeGateStatusIssue(
          code: 'required_gate_not_satisfied',
          message:
              'Required gate "${gate.id}" is ${_gateStatusValue(gate.status)}.',
          details: <String, Object?>{
            'gateId': gate.id,
            'status': _gateStatusValue(gate.status),
            'summary': gate.summary,
            if (gate.tracker != null) 'tracker': gate.tracker,
          },
        ),
      );
    }

    for (final issue in _checkLocalEvidencePaths(
      gate: gate,
      evidenceRoot: resolvedEvidenceRoot,
    )) {
      issues.add(issue);
    }
  }

  for (final gate in manifest.gates.where(
    (gate) => !requiredGateIds.contains(gate.id),
  )) {
    for (final issue in _checkLocalEvidencePaths(
      gate: gate,
      evidenceRoot: resolvedEvidenceRoot,
    )) {
      issues.add(issue);
    }
  }

  final nonRequiredOpenGates = manifest.gates
      .where(
        (gate) =>
            !requiredGateIds.contains(gate.id) &&
            gate.status != NativeRuntimeGateStatus.satisfied,
      )
      .toList();

  return NativeRuntimeGateStatusCheckResult(
    manifestPath: manifestFile.path,
    manifestId: manifest.id,
    profile: profile,
    passed: issues.isEmpty,
    issues: issues,
    nonRequiredOpenGates: nonRequiredOpenGates,
  );
}

String _readNonEmptyString(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('$key must be a non-empty string.');
  }
  return value;
}

String? _readOptionalString(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value == null) {
    return null;
  }
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('$key must be a non-empty string when provided.');
  }
  return value;
}

String? _readOptionalHttpsUrl(Map<String, Object?> json, String key) {
  final value = _readOptionalString(json, key);
  if (value == null) {
    return null;
  }
  _validateHttpsUrl(value, label: key);
  return value;
}

List<String> _readStringList(
  Map<String, Object?> json,
  String key, {
  bool required = true,
}) {
  final value = json[key];
  if (value == null && !required) {
    return const <String>[];
  }
  if (value is! List<Object?>) {
    throw FormatException('$key must be a list of strings.');
  }
  final strings = <String>[];
  for (final item in value) {
    if (item is! String || item.trim().isEmpty) {
      throw FormatException('$key must contain only non-empty strings.');
    }
    strings.add(item);
  }
  return strings;
}

Map<String, String> _readOptionalStringMap(
  Map<String, Object?> json,
  String key,
) {
  final value = json[key];
  if (value == null) {
    return const <String, String>{};
  }
  if (value is! Map<String, Object?>) {
    throw FormatException('$key must be a map of strings.');
  }
  return value.map((entryKey, entryValue) {
    if (entryKey.trim().isEmpty ||
        entryValue is! String ||
        entryValue.trim().isEmpty) {
      throw FormatException('$key must contain only non-empty strings.');
    }
    return MapEntry(entryKey, entryValue);
  });
}

List<NativeRuntimeGateEvidence> _readEvidenceList(
  Map<String, Object?> json,
  String key,
) {
  final value = json[key];
  if (value == null) {
    return const <NativeRuntimeGateEvidence>[];
  }
  if (value is! List<Object?>) {
    throw FormatException('$key must be a list.');
  }
  return value.map(NativeRuntimeGateEvidence.fromJson).toList();
}

List<Map<String, Object?>> _readMapList(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! List<Object?>) {
    throw FormatException('$key must be a list of maps.');
  }
  return value.map((item) {
    if (item is! Map<String, Object?>) {
      throw FormatException('$key must contain only maps.');
    }
    return item;
  }).toList();
}

NativeRuntimeGateEvidenceType _readEvidenceType(Object? value) {
  if (value is! String || value.trim().isEmpty) {
    throw const FormatException(
      'Native runtime gate evidence type must be a non-empty string.',
    );
  }
  for (final type in NativeRuntimeGateEvidenceType.values) {
    if (_evidenceTypeValue(type) == value) {
      return type;
    }
  }
  throw FormatException(
    'Unsupported native runtime gate evidence type: $value.',
  );
}

NativeRuntimeGateStatus _readGateStatus(Object? value) {
  if (value is! String || value.trim().isEmpty) {
    throw const FormatException('Gate status must be a non-empty string.');
  }
  for (final status in NativeRuntimeGateStatus.values) {
    if (_gateStatusValue(status) == value) {
      return status;
    }
  }
  throw FormatException('Unsupported native runtime gate status: $value.');
}

String _evidenceTypeValue(NativeRuntimeGateEvidenceType type) {
  return switch (type) {
    NativeRuntimeGateEvidenceType.localPath => 'localPath',
    NativeRuntimeGateEvidenceType.url => 'url',
    NativeRuntimeGateEvidenceType.command => 'command',
    NativeRuntimeGateEvidenceType.note => 'note',
  };
}

void _validateEvidenceValue({
  required NativeRuntimeGateEvidenceType type,
  required String value,
  required String? cwd,
  required Map<String, String> env,
}) {
  if (type != NativeRuntimeGateEvidenceType.command &&
      (cwd != null || env.isNotEmpty)) {
    throw const FormatException(
      'Native runtime gate evidence metadata is only supported for commands.',
    );
  }

  switch (type) {
    case NativeRuntimeGateEvidenceType.localPath:
      _validateWorkspaceRelativePath(value, label: 'localPath evidence');
    case NativeRuntimeGateEvidenceType.url:
      _validateHttpsUrl(value, label: 'url evidence');
    case NativeRuntimeGateEvidenceType.command:
      if (cwd != null) {
        _validateWorkspaceRelativePath(cwd, label: 'command cwd');
      }
    case NativeRuntimeGateEvidenceType.note:
      break;
  }
}

List<NativeRuntimeGateStatusIssue> _checkLocalEvidencePaths({
  required NativeRuntimeGate gate,
  required Directory evidenceRoot,
}) {
  final issues = <NativeRuntimeGateStatusIssue>[];
  for (final evidence in gate.evidence.where(
    (entry) => entry.type == NativeRuntimeGateEvidenceType.localPath,
  )) {
    final evidencePath = p.join(evidenceRoot.path, evidence.value);
    if (!File(evidencePath).existsSync() &&
        !Directory(evidencePath).existsSync()) {
      issues.add(
        NativeRuntimeGateStatusIssue(
          code: 'gate_evidence_path_missing',
          message: 'Gate "${gate.id}" references missing evidence path.',
          details: <String, Object?>{
            'gateId': gate.id,
            'path': evidence.value,
            'resolvedPath': evidencePath,
          },
        ),
      );
    }
  }
  return issues;
}

void _validateHttpsUrl(String value, {required String label}) {
  final uri = Uri.tryParse(value);
  if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
    throw FormatException('Native runtime gate $label must be an https URL.');
  }
}

void _validateWorkspaceRelativePath(String value, {required String label}) {
  final normalized = p.normalize(value);
  if (p.isAbsolute(value) ||
      normalized == '..' ||
      normalized.startsWith('..${p.separator}')) {
    throw FormatException(
      'Native runtime gate $label must be workspace-relative.',
    );
  }
}

String _gateStatusValue(NativeRuntimeGateStatus status) {
  return switch (status) {
    NativeRuntimeGateStatus.satisfied => 'satisfied',
    NativeRuntimeGateStatus.open => 'open',
    NativeRuntimeGateStatus.blocked => 'blocked',
    NativeRuntimeGateStatus.deferred => 'deferred',
  };
}

void _validateUniqueIds({
  required String label,
  required Iterable<String> ids,
}) {
  final seen = <String>{};
  for (final id in ids) {
    if (!seen.add(id)) {
      throw FormatException('Duplicate native runtime gate $label id: $id.');
    }
  }
}

void _validateProfileGateReferences({
  required List<NativeRuntimeGateProfile> profiles,
  required List<NativeRuntimeGate> gates,
}) {
  final gateIds = gates.map((gate) => gate.id).toSet();
  for (final profile in profiles) {
    for (final gateId in profile.requiredGateIds) {
      if (!gateIds.contains(gateId)) {
        throw FormatException(
          'Native runtime gate profile "${profile.id}" references undefined '
          'gate: $gateId.',
        );
      }
    }
  }
}
