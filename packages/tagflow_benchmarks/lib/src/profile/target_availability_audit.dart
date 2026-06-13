import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

/// Runs a target availability probe process.
typedef TargetAuditProcessRunner =
    Future<ProcessResult> Function(
      String executable,
      List<String> arguments, {
      String? workingDirectory,
    });

/// Describes one command used by the target availability audit.
final class TargetAuditCommandSpec {
  /// Creates a command spec.
  const TargetAuditCommandSpec({
    required this.id,
    required this.executable,
    this.arguments = const <String>[],
  });

  /// Stable command id used in JSON output.
  final String id;

  /// Executable name or path.
  final String executable;

  /// Process arguments.
  final List<String> arguments;
}

/// Result of running one target audit command.
final class TargetAuditCommandResult {
  /// Creates a command result.
  const TargetAuditCommandResult({
    required this.id,
    required this.executable,
    required this.arguments,
    required this.exitCode,
    required this.stdout,
    required this.stderr,
  });

  /// Stable command id.
  final String id;

  /// Executable name or path.
  final String executable;

  /// Process arguments.
  final List<String> arguments;

  /// Process exit code, or `null` when the process could not start.
  final int? exitCode;

  /// Captured stdout.
  final String stdout;

  /// Captured stderr.
  final String stderr;

  /// Converts this result to machine-readable JSON.
  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'executable': executable,
    'arguments': arguments,
    'exitCode': exitCode,
    'stdout': stdout,
    'stderr': stderr,
  };
}

/// One physical target candidate seen during availability discovery.
final class TargetCandidate {
  /// Creates a target candidate.
  const TargetCandidate({
    required this.id,
    required this.name,
    required this.platform,
    required this.source,
    this.isWireless = false,
    this.isOffline = false,
    this.blockingReasons = const <String>[],
  });

  /// Device id or UDID.
  final String id;

  /// Human-readable device name.
  final String name;

  /// Platform, such as `ios` or `android`.
  final String platform;

  /// Discovery source, such as `flutter`, `xctrace`, or `adb`.
  final String source;

  /// Whether the candidate is wireless-only from the discovery source.
  final bool isWireless;

  /// Whether the candidate is explicitly offline.
  final bool isOffline;

  /// Reasons this candidate should not be used for a profile probe.
  final List<String> blockingReasons;

  /// Converts this candidate to machine-readable JSON.
  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'name': name,
    'platform': platform,
    'source': source,
    'isWireless': isWireless,
    'isOffline': isOffline,
    if (blockingReasons.isNotEmpty) 'blockingReasons': blockingReasons,
  };
}

/// Signals extracted from target availability command output.
final class TargetAvailabilitySignals {
  /// Creates parsed availability signals.
  const TargetAvailabilitySignals({
    required this.flutterConnectedPhysicalIos,
    required this.flutterIosSimulators,
    required this.flutterWirelessIos,
    required this.flutterConnectedAndroid,
    required this.xctraceOnlinePhysicalIos,
    required this.xctraceOfflinePhysicalIos,
    required this.coreDeviceAvailableIos,
    required this.coreDeviceBlockingIds,
    required this.adbAttachedAndroid,
  });

  /// Wired physical iOS devices seen by Flutter.
  final List<TargetCandidate> flutterConnectedPhysicalIos;

  /// iOS Simulator targets seen by Flutter.
  final List<TargetCandidate> flutterIosSimulators;

  /// Wireless-only iOS devices seen by Flutter.
  final List<TargetCandidate> flutterWirelessIos;

  /// Android devices seen by Flutter.
  final List<TargetCandidate> flutterConnectedAndroid;

  /// Physical iOS devices listed online by Instruments.
  final List<TargetCandidate> xctraceOnlinePhysicalIos;

  /// Physical iOS devices listed offline by Instruments.
  final List<TargetCandidate> xctraceOfflinePhysicalIos;

  /// Physical iOS devices marked available by CoreDevice.
  final List<TargetCandidate> coreDeviceAvailableIos;

  /// CoreDevice ids with disconnected, unavailable, or DDI-blocked state.
  final List<String> coreDeviceBlockingIds;

  /// Android devices attached through ADB.
  final List<TargetCandidate> adbAttachedAndroid;

  /// Converts parsed signals to machine-readable JSON.
  Map<String, Object?> toJson() => <String, Object?>{
    'flutterConnectedPhysicalIos': flutterConnectedPhysicalIos
        .map((candidate) => candidate.toJson())
        .toList(),
    'flutterIosSimulators': flutterIosSimulators
        .map((candidate) => candidate.toJson())
        .toList(),
    'flutterWirelessIos': flutterWirelessIos
        .map((candidate) => candidate.toJson())
        .toList(),
    'flutterConnectedAndroid': flutterConnectedAndroid
        .map((candidate) => candidate.toJson())
        .toList(),
    'xctraceOnlinePhysicalIos': xctraceOnlinePhysicalIos
        .map((candidate) => candidate.toJson())
        .toList(),
    'xctraceOfflinePhysicalIos': xctraceOfflinePhysicalIos
        .map((candidate) => candidate.toJson())
        .toList(),
    'coreDeviceAvailableIos': coreDeviceAvailableIos
        .map((candidate) => candidate.toJson())
        .toList(),
    'coreDeviceBlockingIds': coreDeviceBlockingIds,
    'adbAttachedAndroid': adbAttachedAndroid
        .map((candidate) => candidate.toJson())
        .toList(),
  };
}

/// Machine-readable result for a physical profile target availability audit.
final class TargetAvailabilityAuditResult {
  /// Creates an audit result.
  const TargetAvailabilityAuditResult({
    required this.runId,
    required this.generatedAt,
    required this.commands,
    required this.signals,
    required this.credibleProfileTargets,
    required this.canRunPhysicalProfileProbe,
    required this.summary,
  });

  /// Stable id used for output directory naming.
  final String runId;

  /// UTC audit generation time.
  final DateTime generatedAt;

  /// Raw command results.
  final List<TargetAuditCommandResult> commands;

  /// Parsed target availability signals.
  final TargetAvailabilitySignals signals;

  /// Targets that passed the minimum credibility bar.
  final List<TargetCandidate> credibleProfileTargets;

  /// Whether a physical profile probe is credible from this machine.
  final bool canRunPhysicalProfileProbe;

  /// Human-readable summary.
  final String summary;

  /// Converts this result to machine-readable JSON.
  Map<String, Object?> toJson() => <String, Object?>{
    'runId': runId,
    'generatedAt': generatedAt.toUtc().toIso8601String(),
    'canRunPhysicalProfileProbe': canRunPhysicalProfileProbe,
    'summary': summary,
    'credibleProfileTargets': credibleProfileTargets
        .map((candidate) => candidate.toJson())
        .toList(),
    'signals': signals.toJson(),
    'commands': commands.map((command) => command.toJson()).toList(),
  };
}

/// Runs and classifies target availability commands for profile benchmarks.
final class TargetAvailabilityAuditor {
  /// Creates an auditor.
  const TargetAvailabilityAuditor({
    required this.workspaceRoot,
    required this.outputDirectory,
    required this.runId,
    this.processRunner = _defaultProcessRunner,
    this.generatedAt,
  });

  /// Workspace root used as command working directory.
  final Directory workspaceRoot;

  /// Directory where audit artifacts are written.
  final Directory outputDirectory;

  /// Stable run id used as output folder name.
  final String runId;

  /// Process runner for command execution.
  final TargetAuditProcessRunner processRunner;

  /// Optional clock injection for tests.
  final DateTime? generatedAt;

  /// Runs the audit and writes `target-availability-audit.json`.
  Future<TargetAvailabilityAuditResult> run() async {
    final commands = <TargetAuditCommandResult>[];
    for (final spec in _commandSpecs) {
      commands.add(await _runCommand(spec));
    }

    final signals = _parseSignals(commands);
    final credibleTargets = _credibleTargets(signals);
    final result = TargetAvailabilityAuditResult(
      runId: runId,
      generatedAt: (generatedAt ?? DateTime.now()).toUtc(),
      commands: commands,
      signals: signals,
      credibleProfileTargets: credibleTargets,
      canRunPhysicalProfileProbe: credibleTargets.isNotEmpty,
      summary: credibleTargets.isEmpty
          ? 'No credible physical profile target is available.'
          : 'Found ${credibleTargets.length} credible physical profile target'
                '${credibleTargets.length == 1 ? '' : 's'}.',
    );

    final runDirectory = Directory(p.join(outputDirectory.path, runId))
      ..createSync(recursive: true);
    File(
      p.join(runDirectory.path, 'target-availability-audit.json'),
    ).writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(result.toJson()),
    );

    return result;
  }

  Future<TargetAuditCommandResult> _runCommand(
    TargetAuditCommandSpec spec,
  ) async {
    try {
      final result = await processRunner(
        spec.executable,
        spec.arguments,
        workingDirectory: workspaceRoot.path,
      );
      return TargetAuditCommandResult(
        id: spec.id,
        executable: spec.executable,
        arguments: spec.arguments,
        exitCode: result.exitCode,
        stdout: result.stdout.toString(),
        stderr: result.stderr.toString(),
      );
    } on ProcessException catch (error) {
      if (spec.id == 'adbDevices') {
        final fallback = _fallbackAdbExecutable();
        if (fallback != null) {
          try {
            final result = await processRunner(
              fallback,
              spec.arguments,
              workingDirectory: workspaceRoot.path,
            );
            return TargetAuditCommandResult(
              id: spec.id,
              executable: fallback,
              arguments: spec.arguments,
              exitCode: result.exitCode,
              stdout: result.stdout.toString(),
              stderr: result.stderr.toString(),
            );
          } on ProcessException catch (fallbackError) {
            return TargetAuditCommandResult(
              id: spec.id,
              executable: fallback,
              arguments: spec.arguments,
              exitCode: null,
              stdout: '',
              stderr: fallbackError.message,
            );
          }
        }
      }
      return TargetAuditCommandResult(
        id: spec.id,
        executable: spec.executable,
        arguments: spec.arguments,
        exitCode: null,
        stdout: '',
        stderr: error.message,
      );
    }
  }
}

/// Creates a stable default run id for target availability audits.
String defaultTargetAvailabilityRunId({DateTime? now}) {
  final timestamp = (now ?? DateTime.now()).toUtc().toIso8601String();
  return timestamp.replaceAll(':', '-').replaceAll('.', '-');
}

const List<TargetAuditCommandSpec> _commandSpecs = [
  TargetAuditCommandSpec(
    id: 'flutterDevices',
    executable: 'flutter',
    arguments: ['devices', '-v'],
  ),
  TargetAuditCommandSpec(
    id: 'xctraceDevices',
    executable: 'xcrun',
    arguments: ['xctrace', 'list', 'devices'],
  ),
  TargetAuditCommandSpec(
    id: 'coreDeviceList',
    executable: 'xcrun',
    arguments: ['devicectl', 'list', 'devices'],
  ),
  TargetAuditCommandSpec(
    id: 'coreDeviceVerbose',
    executable: 'xcrun',
    arguments: ['devicectl', 'list', 'devices', '--verbose'],
  ),
  TargetAuditCommandSpec(
    id: 'adbDevices',
    executable: 'adb',
    arguments: ['devices', '-l'],
  ),
  TargetAuditCommandSpec(
    id: 'usbDevices',
    executable: 'system_profiler',
    arguments: ['SPUSBDataType'],
  ),
];

Future<ProcessResult> _defaultProcessRunner(
  String executable,
  List<String> arguments, {
  String? workingDirectory,
}) {
  return Process.run(executable, arguments, workingDirectory: workingDirectory);
}

String? _fallbackAdbExecutable() {
  final androidHome = Platform.environment['ANDROID_HOME'];
  final candidates = <String>[
    if (androidHome != null) p.join(androidHome, 'platform-tools', 'adb'),
    p.join(
      Platform.environment['HOME'] ?? '',
      'Library',
      'Android',
      'sdk',
      'platform-tools',
      'adb',
    ),
  ];

  for (final candidate in candidates) {
    if (candidate.isNotEmpty && File(candidate).existsSync()) {
      return candidate;
    }
  }

  return null;
}

TargetAvailabilitySignals _parseSignals(
  List<TargetAuditCommandResult> commands,
) {
  final byId = {for (final command in commands) command.id: command};
  final flutter = byId['flutterDevices']?.stdout ?? '';
  final xctrace = byId['xctraceDevices']?.stdout ?? '';
  final coreDeviceList = byId['coreDeviceList']?.stdout ?? '';
  final coreDeviceVerbose = byId['coreDeviceVerbose']?.stdout ?? '';
  final adb = byId['adbDevices']?.stdout ?? '';

  final flutterIos = _parseFlutterDevices(flutter, platform: 'ios');
  return TargetAvailabilitySignals(
    flutterConnectedPhysicalIos: flutterIos
        .where(
          (candidate) =>
              !candidate.isWireless &&
              !candidate.blockingReasons.contains('simulator'),
        )
        .toList(),
    flutterIosSimulators: flutterIos
        .where((candidate) => candidate.blockingReasons.contains('simulator'))
        .toList(),
    flutterWirelessIos: flutterIos
        .where(
          (candidate) =>
              candidate.isWireless &&
              !candidate.blockingReasons.contains('simulator'),
        )
        .toList(),
    flutterConnectedAndroid: _parseFlutterDevices(flutter, platform: 'android'),
    xctraceOnlinePhysicalIos: _parseXctraceDevices(xctrace, offline: false),
    xctraceOfflinePhysicalIos: _parseXctraceDevices(xctrace, offline: true),
    coreDeviceAvailableIos: _parseCoreDeviceAvailable(coreDeviceList),
    coreDeviceBlockingIds: _parseCoreDeviceBlockingIds(coreDeviceVerbose),
    adbAttachedAndroid: _parseAdbDevices(adb),
  );
}

List<TargetCandidate> _credibleTargets(TargetAvailabilitySignals signals) {
  final xctraceOnlineIds = signals.xctraceOnlinePhysicalIos
      .map((candidate) => candidate.id)
      .toSet();
  final coreBlockingIds = signals.coreDeviceBlockingIds.toSet();
  final adbIds = signals.adbAttachedAndroid.map((candidate) => candidate.id);
  final adbAttachedIds = adbIds.toSet();

  final iosTargets = signals.flutterConnectedPhysicalIos.where((candidate) {
    return xctraceOnlineIds.contains(candidate.id) &&
        !coreBlockingIds.contains(candidate.id);
  });
  final androidTargets = signals.flutterConnectedAndroid.where((candidate) {
    return adbAttachedIds.contains(candidate.id);
  });

  return <TargetCandidate>[...iosTargets, ...androidTargets];
}

List<TargetCandidate> _parseFlutterDevices(
  String output, {
  required String platform,
}) {
  final candidates = <TargetCandidate>[];
  final linePattern = RegExp(r'^(.+?)\s+•\s+(.+?)\s+•\s+(.+?)\s+•\s+(.+)$');
  var inWirelessSection = false;

  for (final rawLine in const LineSplitter().convert(output)) {
    final rawLower = rawLine.toLowerCase();
    if (rawLower.contains('wirelessly connected')) {
      inWirelessSection = true;
      continue;
    }
    if (rawLower.startsWith('found ') && rawLower.contains('connected')) {
      inWirelessSection = false;
    }

    final line = _stripFlutterVerbosePrefix(rawLine.trim());
    final match = linePattern.firstMatch(line);
    if (match == null) {
      continue;
    }

    final name = match.group(1)!.trim();
    final id = match.group(2)!.trim();
    final platformField = match.group(3)!.trim().toLowerCase();
    final description = match.group(4)!.trim().toLowerCase();
    final lineLower = line.toLowerCase();

    if (platform == 'ios') {
      if (platformField != 'ios') {
        continue;
      }
      final isSimulator =
          _looksLikeSimulatorId(id) ||
          description.contains('simulator') ||
          lineLower.contains('coresimulator');
      candidates.add(
        TargetCandidate(
          id: id,
          name: name,
          platform: 'ios',
          source: 'flutter',
          isWireless: inWirelessSection || lineLower.contains('wireless'),
          blockingReasons: isSimulator ? const <String>['simulator'] : const [],
        ),
      );
    } else if (platform == 'android' &&
        (platformField.startsWith('android') ||
            description.contains('android'))) {
      if (_looksLikeAndroidEmulator(id, name, description)) {
        continue;
      }
      candidates.add(
        TargetCandidate(
          id: id,
          name: name,
          platform: 'android',
          source: 'flutter',
        ),
      );
    }
  }

  return _uniqueCandidates(candidates);
}

List<TargetCandidate> _parseXctraceDevices(
  String output, {
  required bool offline,
}) {
  final candidates = <TargetCandidate>[];
  var section = '';
  final sectionPattern = RegExp(r'^==\s+(.+?)\s+==$');
  final devicePattern = RegExp(r'^\s*(.+?)\s+\(([^()]+)\)\s+\(([^()]+)\)');

  for (final line in const LineSplitter().convert(output)) {
    final sectionMatch = sectionPattern.firstMatch(line.trim());
    if (sectionMatch != null) {
      section = sectionMatch.group(1)!.toLowerCase();
      continue;
    }

    final inExpectedSection = offline
        ? section == 'devices offline'
        : section == 'devices';
    if (!inExpectedSection) {
      continue;
    }

    final match = devicePattern.firstMatch(line);
    if (match == null) {
      continue;
    }

    final name = match.group(1)!.trim();
    final id = match.group(3)!.trim();
    if (!_looksLikeIosPhysicalDevice(name)) {
      continue;
    }

    candidates.add(
      TargetCandidate(
        id: id,
        name: name,
        platform: 'ios',
        source: 'xctrace',
        isOffline: offline,
      ),
    );
  }

  return _uniqueCandidates(candidates);
}

List<TargetCandidate> _parseCoreDeviceAvailable(String output) {
  final candidates = <TargetCandidate>[];

  for (final line in const LineSplitter().convert(output)) {
    if (!line.toLowerCase().contains('available') ||
        line.toLowerCase().contains('unavailable') ||
        !_looksLikeIosPhysicalDevice(line)) {
      continue;
    }

    final id =
        _coreDeviceIdPattern.firstMatch(line)?.group(1) ??
        _physicalIosIdPattern.firstMatch(line)?.group(1);
    if (id == null) {
      continue;
    }

    candidates.add(
      TargetCandidate(
        id: id,
        name: _coreDeviceNameBeforeId(line, id),
        platform: 'ios',
        source: 'coredevice',
      ),
    );
  }

  return _uniqueCandidates(candidates);
}

List<String> _parseCoreDeviceBlockingIds(String output) {
  final ids = <String>{};
  final lines = const LineSplitter().convert(output);

  for (var index = 0; index < lines.length; index += 1) {
    final id = _physicalIosIdPattern.firstMatch(lines[index])?.group(1);
    if (id == null) {
      continue;
    }

    final lowerWindow = lines.skip(index).take(30).join('\n').toLowerCase();
    final blocked =
        lowerWindow.contains('tunnelstate: disconnected') ||
        lowerWindow.contains('tunnelstate: unavailable') ||
        lowerWindow.contains('transporttype: localnetwork') ||
        lowerWindow.contains('ddiservicesavailable: false') ||
        lowerWindow.contains('unavailable');
    if (blocked) {
      ids.add(id);
    }
  }

  return ids.toList()..sort();
}

List<TargetCandidate> _parseAdbDevices(String output) {
  final candidates = <TargetCandidate>[];

  for (final line in const LineSplitter().convert(output).skip(1)) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) {
      continue;
    }

    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length < 2 || parts[1] != 'device') {
      continue;
    }
    if (_looksLikeAndroidEmulator(parts.first, trimmed, trimmed)) {
      continue;
    }

    candidates.add(
      TargetCandidate(
        id: parts.first,
        name: parts.first,
        platform: 'android',
        source: 'adb',
      ),
    );
  }

  return _uniqueCandidates(candidates);
}

bool _looksLikeIosPhysicalDevice(String value) {
  final lower = value.toLowerCase();
  return lower.contains('iphone') ||
      lower.contains('ipad') ||
      lower.contains('ipod');
}

bool _looksLikeAndroidEmulator(String id, String name, String description) {
  final combined = '$id $name $description'.toLowerCase();
  return id.startsWith('emulator-') ||
      combined.contains('emulator') ||
      combined.contains('android_sdk') ||
      combined.contains('sdk_gphone') ||
      combined.contains('sdk phone');
}

String _stripFlutterVerbosePrefix(String line) {
  if (!line.startsWith('[')) {
    return line;
  }

  final endIndex = line.indexOf(']');
  if (endIndex == -1) {
    return line;
  }

  return line.substring(endIndex + 1).trimLeft();
}

bool _looksLikeSimulatorId(String value) {
  if (value.length != 36) {
    return false;
  }

  return RegExp(
    '^[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-'
    '[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}',
  ).hasMatch(value);
}

final RegExp _physicalIosIdPattern = RegExp(
  r'\b([0-9A-Fa-f]{8}-[0-9A-Fa-f]{16}|[0-9A-Fa-f]{24,40})\b',
);

final RegExp _coreDeviceIdPattern = RegExp(
  r'\b([0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-'
  r'[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12})\b',
);

String _nameBeforeId(String line, String id) {
  final prefix = line.substring(0, line.indexOf(id)).trim();
  return prefix.replaceAll(RegExp(r'\s+'), ' ');
}

String _coreDeviceNameBeforeId(String line, String id) {
  final prefix = line.substring(0, line.indexOf(id)).trimRight();
  final columns = prefix.split(RegExp(r'\s{2,}'));
  if (columns.isNotEmpty && columns.first.trim().isNotEmpty) {
    return columns.first.trim();
  }

  return _nameBeforeId(line, id);
}

List<TargetCandidate> _uniqueCandidates(List<TargetCandidate> candidates) {
  final byId = <String, TargetCandidate>{};
  for (final candidate in candidates) {
    byId[candidate.id] = candidate;
  }
  return byId.values.toList()..sort(
    (a, b) => '${a.platform}:${a.name}'.compareTo(
      '${b.platform}:'
      '${b.name}',
    ),
  );
}
