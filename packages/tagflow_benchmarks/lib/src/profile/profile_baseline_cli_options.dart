import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:tagflow_benchmarks/src/profile/profile_baseline_runner.dart';

/// Parsed options for the profile baseline runner CLI.
final class ProfileBaselineCliOptions {
  /// Creates parsed profile baseline runner CLI options.
  const ProfileBaselineCliOptions({
    required this.renderers,
    required this.fixtures,
    required this.repeatCount,
    required this.device,
    required this.outputDirectory,
    required this.continueOnFailure,
    required this.profileMemory,
    required this.profileHoldOpen,
    required this.profileHoldOpenSeconds,
    this.pairs,
    this.runId,
  });

  /// Parses profile baseline runner arguments.
  factory ProfileBaselineCliOptions.parse(
    List<String> arguments, {
    Map<String, String>? environment,
  }) {
    final values = <String, String>{};
    final env = environment ?? Platform.environment;

    for (final argument in arguments) {
      if (!argument.startsWith('--')) {
        throw FormatException('Unknown positional argument: $argument');
      }

      final separator = argument.indexOf('=');
      if (separator == -1) {
        throw FormatException('Expected --name=value, got: $argument');
      }

      values[argument.substring(2, separator)] = argument.substring(
        separator + 1,
      );
    }

    final pairs = _pairs(
      values['pair'] ?? values['pairs'] ?? env['TAGFLOW_PROFILE_PAIR'],
    );
    final profileHoldOpenSeconds = _optionalPositiveInt(
      values['profile-hold-open-seconds'] ??
          env['TAGFLOW_PROFILE_HOLD_OPEN_SECONDS'],
    );
    final profileHoldOpen =
        _boolFlag(
          values['profile-hold-open'] ?? env['TAGFLOW_PROFILE_HOLD_OPEN'],
        ) ||
        profileHoldOpenSeconds != null;

    return ProfileBaselineCliOptions(
      renderers: pairs == null
          ? _csv(
              values['renderer'] ?? env['TAGFLOW_RENDERER'],
              defaultProfileBaselineRenderers,
            )
          : _unique(pairs.map((pair) => pair.renderer)),
      fixtures: pairs == null
          ? _csv(
              values['fixture'] ?? env['TAGFLOW_FIXTURE'],
              defaultProfileBaselineFixtures,
            )
          : _unique(pairs.map((pair) => pair.fixture)),
      repeatCount: _positiveInt(
        values['repeat'] ?? env['TAGFLOW_PROFILE_REPEAT'],
        defaultValue: 3,
      ),
      device: values['device'] ?? env['TAGFLOW_PROFILE_DEVICE'] ?? 'macos',
      outputDirectory:
          values['output-dir'] ??
          env['TAGFLOW_PROFILE_OUTPUT_DIR'] ??
          p.join('build', 'benchmarks', 'profile'),
      continueOnFailure: _boolFlag(
        values['continue-on-failure'] ??
            env['TAGFLOW_PROFILE_CONTINUE_ON_FAILURE'],
      ),
      profileMemory: _boolFlag(
        values['profile-memory'] ?? env['TAGFLOW_PROFILE_MEMORY'],
      ),
      profileHoldOpen: profileHoldOpen,
      profileHoldOpenSeconds: profileHoldOpen
          ? profileHoldOpenSeconds ?? defaultProfileHoldOpenSeconds
          : null,
      pairs: pairs,
      runId: values['run-id'] ?? env['TAGFLOW_PROFILE_RUN_ID'],
    );
  }

  /// Renderer ids included in the manifest.
  final List<String> renderers;

  /// Fixture ids included in the manifest.
  final List<String> fixtures;

  /// Explicit renderer/fixture cells to run instead of the renderer matrix.
  final List<ProfileBaselineCell>? pairs;

  /// Number of repeats per renderer/fixture pair.
  final int repeatCount;

  /// Flutter device id.
  final String device;

  /// Output directory path.
  final String outputDirectory;

  /// Whether to continue after failed profile runs.
  final bool continueOnFailure;

  /// Whether each profile cell should request `flutter drive --profile-memory`.
  final bool profileMemory;

  /// Whether each profile cell should replay named hold-open checkpoints.
  final bool profileHoldOpen;

  /// Hold-open duration in seconds, when checkpoint replay is enabled.
  final int? profileHoldOpenSeconds;

  /// Optional stable run id.
  final String? runId;
}

List<String> _csv(String? value, List<String> fallback) {
  if (value == null || value.trim().isEmpty || value == 'all') {
    return List<String>.unmodifiable(fallback);
  }

  final parsed = value
      .split(',')
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList(growable: false);

  if (parsed.isEmpty) {
    throw const FormatException('CSV option must not be empty.');
  }
  return List<String>.unmodifiable(parsed);
}

List<ProfileBaselineCell>? _pairs(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }

  final pairs = <ProfileBaselineCell>[];
  for (final rawPair in value.split(',')) {
    final pair = rawPair.trim();
    if (pair.isEmpty) {
      continue;
    }

    final separator = pair.indexOf(':');
    if (separator == -1 || separator != pair.lastIndexOf(':')) {
      throw FormatException(
        'Expected profile pair as <renderer>:<fixture>, got: $pair',
      );
    }

    final renderer = pair.substring(0, separator).trim();
    final fixture = pair.substring(separator + 1).trim();
    if (renderer.isEmpty || fixture.isEmpty) {
      throw FormatException(
        'Expected profile pair as <renderer>:<fixture>, got: $pair',
      );
    }

    pairs.add(ProfileBaselineCell(renderer: renderer, fixture: fixture));
  }

  if (pairs.isEmpty) {
    throw const FormatException('Profile pair option must not be empty.');
  }
  return List<ProfileBaselineCell>.unmodifiable(pairs);
}

int _positiveInt(String? value, {required int defaultValue}) {
  if (value == null) {
    return defaultValue;
  }

  final parsed = int.tryParse(value);
  if (parsed == null || parsed < 1) {
    throw FormatException('Expected a positive integer, got: $value');
  }
  return parsed;
}

int? _optionalPositiveInt(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }

  final parsed = int.tryParse(value);
  if (parsed == null || parsed < 1) {
    throw FormatException('Expected a positive integer, got: $value');
  }
  return parsed;
}

bool _boolFlag(String? value) {
  if (value == null) {
    return false;
  }
  final normalized = value.trim().toLowerCase();
  return normalized == 'true' || normalized == '1' || normalized == 'yes';
}

List<String> _unique(Iterable<String> values) {
  final seen = <String>{};
  final result = <String>[];
  for (final value in values) {
    if (seen.add(value)) {
      result.add(value);
    }
  }
  return List<String>.unmodifiable(result);
}
