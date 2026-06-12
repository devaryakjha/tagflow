import 'dart:ui' show Size;

import 'package:flutter_test/flutter_test.dart';

import '../integration_test/profile_viewport.dart';

void main() {
  testWidgets('records observed-host viewport metadata', (tester) async {
    tester.view.devicePixelRatio = 1.5;
    tester.view.physicalSize = const Size(1200, 900);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final payload = applyProfileViewport(
      tester,
      options: const ProfileViewportOptions.observedHost(),
    );

    expect(payload.mode, 'observedHost');
    expect(payload.requested, isNull);
    expect(payload.applied, isNull);
    expect(payload.caveats, isEmpty);
    expect(payload.effectiveViewport, <String, Object?>{
      'logicalWidth': 800.0,
      'logicalHeight': 600.0,
      'physicalWidth': 1200.0,
      'physicalHeight': 900.0,
      'devicePixelRatio': 1.5,
    });
    expect(payload.observedHostBeforeOverride, payload.effectiveViewport);
    expect(
      payload.toJson(),
      containsPair('observedHostBeforeOverride', payload.effectiveViewport),
    );
  });

  testWidgets('records requested and applied synthetic viewport metadata', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 600);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final payload = applyProfileViewport(
      tester,
      options: const ProfileViewportOptions.synthetic(
        requested: RequestedProfileViewport(
          logicalWidth: 800,
          logicalHeight: 600,
          devicePixelRatio: 2,
        ),
      ),
    );

    expect(payload.mode, 'synthetic');
    expect(payload.requested, <String, Object?>{
      'logicalWidth': 800.0,
      'logicalHeight': 600.0,
      'devicePixelRatio': 2.0,
    });
    expect(payload.observedHostBeforeOverride, <String, Object?>{
      'logicalWidth': 800.0,
      'logicalHeight': 600.0,
      'physicalWidth': 800.0,
      'physicalHeight': 600.0,
      'devicePixelRatio': 1.0,
    });
    expect(payload.applied, <String, Object?>{
      'logicalWidth': 800.0,
      'logicalHeight': 600.0,
      'physicalWidth': 1600.0,
      'physicalHeight': 1200.0,
      'devicePixelRatio': 2.0,
    });
    expect(payload.effectiveViewport, payload.applied);
    expect(payload.caveats, <String>[
      'test_view_override',
      'not_real_display_scale',
      'not_public_reference_target',
    ]);
    expect(payload.toJson(), <String, Object?>{
      'schemaVersion': 1,
      'mode': 'synthetic',
      'requested': payload.requested,
      'observedHostBeforeOverride': payload.observedHostBeforeOverride,
      'applied': payload.applied,
      'caveats': payload.caveats,
    });
  });

  test('rejects non-finite viewport values', () {
    expect(
      () => ProfileViewportOptions.parse(
        modeValue: 'synthetic',
        logicalSizeValue: '800xNaN',
        devicePixelRatioValue: '2.0',
      ),
      throwsFormatException,
    );
    expect(
      () => ProfileViewportOptions.parse(
        modeValue: 'synthetic',
        logicalSizeValue: '800x600',
        devicePixelRatioValue: 'Infinity',
      ),
      throwsFormatException,
    );
  });
}
