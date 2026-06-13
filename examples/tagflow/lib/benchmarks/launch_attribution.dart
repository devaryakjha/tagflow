import 'dart:io';

import 'package:flutter/services.dart';

const _channelName = 'dev.arya.tagflow/benchmark_launch_attribution';

/// Launch-attribution payload stored in profile benchmark artifacts.
final class BenchmarkLaunchAttributionPayload {
  /// Creates a launch-attribution payload.
  const BenchmarkLaunchAttributionPayload._(this._json);

  /// Creates an explicit unsupported payload.
  factory BenchmarkLaunchAttributionPayload.unavailable({
    required String host,
    required String reason,
  }) {
    return BenchmarkLaunchAttributionPayload._(<String, Object?>{
      'schemaVersion': 1,
      'status': 'unavailable',
      'host': host,
      'scope': 'local_runner_only',
      'reason': reason,
    });
  }

  /// Reads native launch markers when the runner exposes them.
  static Future<BenchmarkLaunchAttributionPayload> capture() async {
    if (!Platform.isMacOS) {
      return BenchmarkLaunchAttributionPayload.unavailable(
        host: Platform.operatingSystem,
        reason: 'platform_not_supported',
      );
    }

    try {
      final result = await const MethodChannel(
        _channelName,
      ).invokeMapMethod<String, Object?>('getLaunchAttribution');
      if (result == null || result.isEmpty) {
        return BenchmarkLaunchAttributionPayload.unavailable(
          host: Platform.operatingSystem,
          reason: 'missing_native_launch_payload',
        );
      }
      return BenchmarkLaunchAttributionPayload._(
        Map<String, Object?>.unmodifiable(result),
      );
    } on MissingPluginException {
      return BenchmarkLaunchAttributionPayload.unavailable(
        host: Platform.operatingSystem,
        reason: 'native_channel_unavailable',
      );
    } on PlatformException {
      return BenchmarkLaunchAttributionPayload.unavailable(
        host: Platform.operatingSystem,
        reason: 'native_channel_error',
      );
    }
  }

  final Map<String, Object?> _json;

  /// Converts this payload to JSON for `IntegrationTestWidgetsFlutterBinding`.
  Map<String, Object?> toJson() => _json;
}
