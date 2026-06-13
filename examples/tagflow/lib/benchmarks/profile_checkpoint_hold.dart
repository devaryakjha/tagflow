/// Default hold-open duration for profile checkpoint replay.
const int defaultProfileCheckpointHoldOpenSeconds = 120;

/// Parsed hold-open configuration for benchmark checkpoint replay.
final class ProfileCheckpointHoldOptions {
  const ProfileCheckpointHoldOptions._({
    required this.enabled,
    required this.holdOpenSeconds,
  });

  /// Parses compile-time environment values for checkpoint replay.
  factory ProfileCheckpointHoldOptions.parse({
    required String enabledValue,
    String? holdOpenSecondsValue,
  }) {
    final parsedSeconds = _optionalPositiveInt(holdOpenSecondsValue);
    final enabled = _boolFlag(enabledValue) || parsedSeconds != null;
    return ProfileCheckpointHoldOptions._(
      enabled: enabled,
      holdOpenSeconds: enabled
          ? parsedSeconds ?? defaultProfileCheckpointHoldOpenSeconds
          : 0,
    );
  }

  /// Whether named checkpoint replay should run after measurement.
  final bool enabled;

  /// Seconds to hold each checkpoint open.
  final int holdOpenSeconds;

  /// Hold duration derived from [holdOpenSeconds].
  Duration get holdDuration => Duration(seconds: holdOpenSeconds);

  /// Converts the hold-open configuration into machine-readable JSON.
  Map<String, Object?> toJson() => <String, Object?>{
    'enabled': enabled,
    'holdOpenSeconds': holdOpenSeconds,
  };
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

bool _boolFlag(String value) {
  final normalized = value.trim().toLowerCase();
  return normalized == 'true' || normalized == '1' || normalized == 'yes';
}
