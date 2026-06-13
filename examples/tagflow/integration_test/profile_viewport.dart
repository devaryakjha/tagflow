import 'dart:ui' show Size;

import 'package:flutter_test/flutter_test.dart';

/// Profile benchmark viewport mode parsed from compile-time configuration.
enum ProfileViewportMode {
  /// Use the host viewport reported by Flutter without test overrides.
  observedHost,

  /// Apply a synthetic logical size and DPR through test view overrides.
  synthetic,
}

/// Requested synthetic viewport for profile benchmark collection.
final class RequestedProfileViewport {
  /// Creates requested synthetic viewport metadata.
  const RequestedProfileViewport({
    required this.logicalWidth,
    required this.logicalHeight,
    required this.devicePixelRatio,
  });

  /// Requested logical Flutter view width.
  final double logicalWidth;

  /// Requested logical Flutter view height.
  final double logicalHeight;

  /// Requested Flutter view device-pixel ratio.
  final double devicePixelRatio;

  /// Converts this viewport to JSON.
  Map<String, Object?> toJson() => <String, Object?>{
    'logicalWidth': logicalWidth,
    'logicalHeight': logicalHeight,
    'devicePixelRatio': devicePixelRatio,
  };
}

/// Profile viewport options parsed by the integration profile benchmark.
final class ProfileViewportOptions {
  /// Creates default observed-host viewport options.
  const ProfileViewportOptions.observedHost()
    : mode = ProfileViewportMode.observedHost,
      requested = null;

  /// Creates synthetic viewport options.
  const ProfileViewportOptions.synthetic({required this.requested})
    : mode = ProfileViewportMode.synthetic;

  /// Parses viewport options from profile benchmark string values.
  factory ProfileViewportOptions.parse({
    required String modeValue,
    required String? logicalSizeValue,
    required String? devicePixelRatioValue,
  }) {
    final mode = switch (modeValue.trim()) {
      '' ||
      'observed_host' ||
      'observedHost' => ProfileViewportMode.observedHost,
      'synthetic' => ProfileViewportMode.synthetic,
      _ => throw FormatException(
        'Expected TAGFLOW_PROFILE_VIEWPORT_MODE observed_host or synthetic, '
        'got: $modeValue',
      ),
    };
    final hasLogicalSize = logicalSizeValue != null;
    final hasDevicePixelRatio = devicePixelRatioValue != null;
    if (mode == ProfileViewportMode.observedHost) {
      if (hasLogicalSize || hasDevicePixelRatio) {
        throw const FormatException(
          'Synthetic viewport inputs require synthetic viewport mode.',
        );
      }
      return const ProfileViewportOptions.observedHost();
    }

    if (!hasLogicalSize || !hasDevicePixelRatio) {
      throw const FormatException(
        'Synthetic viewport mode requires logical size and device pixel ratio.',
      );
    }
    final logicalSize = parseProfileLogicalSize(logicalSizeValue);
    return ProfileViewportOptions.synthetic(
      requested: RequestedProfileViewport(
        logicalWidth: logicalSize.$1,
        logicalHeight: logicalSize.$2,
        devicePixelRatio: parsePositiveProfileDouble(devicePixelRatioValue),
      ),
    );
  }

  /// Viewport mode.
  final ProfileViewportMode mode;

  /// Requested synthetic viewport, when [mode] is synthetic.
  final RequestedProfileViewport? requested;
}

/// Viewport-mode payload emitted by the integration profile benchmark.
final class ProfileViewportModePayload {
  /// Creates viewport-mode payload metadata.
  const ProfileViewportModePayload({
    required this.mode,
    required this.effectiveViewport,
    required this.requested,
    required this.observedHostBeforeOverride,
    required this.applied,
    required this.caveats,
  });

  /// Serialized viewport mode, such as `observedHost` or `synthetic`.
  final String mode;

  /// Effective benchmark viewport recorded under the legacy viewport key.
  final Map<String, Object?> effectiveViewport;

  /// Requested synthetic viewport, when synthetic mode is enabled.
  final Map<String, Object?>? requested;

  /// Host viewport observed before any synthetic override.
  final Map<String, Object?> observedHostBeforeOverride;

  /// Applied synthetic viewport, when synthetic mode is enabled.
  final Map<String, Object?>? applied;

  /// Caveats describing how this viewport mode should be interpreted.
  final List<String> caveats;

  /// Converts this payload to JSON.
  Map<String, Object?> toJson() => <String, Object?>{
    'schemaVersion': 1,
    'mode': mode,
    'requested': requested,
    'observedHostBeforeOverride': observedHostBeforeOverride,
    'applied': applied,
    'caveats': caveats,
  };
}

/// Applies profile viewport options and returns metadata for artifact output.
ProfileViewportModePayload applyProfileViewport(
  WidgetTester tester, {
  required ProfileViewportOptions options,
}) {
  final observedHost = captureProfileViewport(tester);
  if (options.mode == ProfileViewportMode.observedHost) {
    return ProfileViewportModePayload(
      mode: 'observedHost',
      effectiveViewport: observedHost,
      requested: null,
      observedHostBeforeOverride: observedHost,
      applied: null,
      caveats: const <String>[],
    );
  }

  final requested = options.requested!;
  tester.view.devicePixelRatio = requested.devicePixelRatio;
  tester.view.physicalSize = Size(
    requested.logicalWidth * requested.devicePixelRatio,
    requested.logicalHeight * requested.devicePixelRatio,
  );
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  final applied = captureProfileViewport(tester);
  verifyAppliedSyntheticViewport(requested: requested, applied: applied);
  return ProfileViewportModePayload(
    mode: 'synthetic',
    effectiveViewport: applied,
    requested: requested.toJson(),
    observedHostBeforeOverride: observedHost,
    applied: applied,
    caveats: const <String>[
      'test_view_override',
      'not_real_display_scale',
      'not_public_reference_target',
    ],
  );
}

/// Captures current Flutter test view metadata.
Map<String, Object?> captureProfileViewport(WidgetTester tester) {
  final physicalSize = tester.view.physicalSize;
  final devicePixelRatio = tester.view.devicePixelRatio;
  return <String, Object?>{
    'logicalWidth': physicalSize.width / devicePixelRatio,
    'logicalHeight': physicalSize.height / devicePixelRatio,
    'physicalWidth': physicalSize.width,
    'physicalHeight': physicalSize.height,
    'devicePixelRatio': devicePixelRatio,
  };
}

/// Verifies the applied synthetic viewport matches the requested viewport.
void verifyAppliedSyntheticViewport({
  required RequestedProfileViewport requested,
  required Map<String, Object?> applied,
}) {
  final logicalWidth = applied['logicalWidth']! as double;
  final logicalHeight = applied['logicalHeight']! as double;
  final devicePixelRatio = applied['devicePixelRatio']! as double;
  if (!_almostEqual(logicalWidth, requested.logicalWidth) ||
      !_almostEqual(logicalHeight, requested.logicalHeight) ||
      !_almostEqual(devicePixelRatio, requested.devicePixelRatio)) {
    throw StateError(
      'Applied synthetic viewport does not match the requested viewport. '
      'Requested ${requested.logicalWidth}x${requested.logicalHeight} '
      '@ ${requested.devicePixelRatio}x, got '
      '${logicalWidth}x$logicalHeight @ ${devicePixelRatio}x.',
    );
  }
}

/// Parses a profile logical size in `<width>x<height>` format.
(double, double) parseProfileLogicalSize(String value) {
  final normalized = value.trim().toLowerCase();
  final separator = normalized.indexOf('x');
  if (separator == -1 || separator != normalized.lastIndexOf('x')) {
    throw FormatException(
      'Expected synthetic logical size as <width>x<height>, got: $value',
    );
  }
  return (
    parsePositiveProfileDouble(normalized.substring(0, separator)),
    parsePositiveProfileDouble(normalized.substring(separator + 1)),
  );
}

/// Parses a finite positive profile number.
double parsePositiveProfileDouble(String value) {
  final parsed = double.tryParse(value.trim());
  if (parsed == null || !parsed.isFinite || parsed <= 0) {
    throw FormatException('Expected a finite positive number, got: $value');
  }
  return parsed;
}

bool _almostEqual(double a, double b) => (a - b).abs() < 0.000001;
