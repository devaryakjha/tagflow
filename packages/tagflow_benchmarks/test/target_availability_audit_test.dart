import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:tagflow_benchmarks/src/profile/target_availability_audit.dart';

void main() {
  test(
    'records no credible target for wireless and offline iOS state',
    () async {
      final workspaceRoot = Directory.systemTemp.createTempSync(
        'tagflow_target_audit_wireless_test_',
      );
      addTearDown(() => workspaceRoot.deleteSync(recursive: true));

      final auditor = TargetAvailabilityAuditor(
        workspaceRoot: workspaceRoot,
        outputDirectory: Directory(
          p.join(workspaceRoot.path, 'build', 'benchmarks', 'targets'),
        ),
        runId: 'wireless-ios',
        generatedAt: DateTime.utc(2026, 6, 12, 12),
        processRunner: _fakeRunner({
          'flutter devices -v': '''
Found 3 connected devices:
  iPhone 17 (mobile) • 3BA9E377-4B6F-49A7-83FA-F640060D6442 • ios • iOS 26.5
  macOS (desktop)    • macos                                • darwin-arm64
  Chrome (web)       • chrome                               • web-javascript
Found 1 wirelessly connected device:
  Aryakumar Jha's iPad (wireless) • 00008120-0006395208E14032 • ios • iOS 27.0
''',
          'xcrun xctrace list devices': '''
== Devices ==
Arya's Mac (18.5) (00000000-0000-0000-0000-000000000000)
== Devices Offline ==
Aryakumar Jha's iPad (27.0) (00008120-0006395208E14032)
''',
          'xcrun devicectl list devices': '''
Aryakumar Jha's iPad 00008120-0006395208E14032 available (paired)
Arya's Iphone 17 00008150-00110C960186401C unavailable
''',
          'xcrun devicectl list devices --verbose': '''
identifier: 00008120-0006395208E14032
transportType: localNetwork
tunnelState: disconnected
ddiServicesAvailable: false
developerModeStatus: enabled
''',
          'adb devices -l': 'List of devices attached\n\n',
          'system_profiler SPUSBDataType': '',
        }),
      );

      final result = await auditor.run();

      expect(result.canRunPhysicalProfileProbe, isFalse);
      expect(result.credibleProfileTargets, isEmpty);
      expect(result.signals.flutterIosSimulators, hasLength(1));
      expect(
        result.signals.flutterIosSimulators.single.id,
        '3BA9E377-4B6F-49A7-83FA-F640060D6442',
      );
      expect(result.signals.flutterWirelessIos, hasLength(1));
      expect(result.signals.xctraceOfflinePhysicalIos, hasLength(1));
      expect(
        result.signals.coreDeviceBlockingIds,
        contains('00008120-0006395208E14032'),
      );

      final artifact = File(
        p.join(
          workspaceRoot.path,
          'build',
          'benchmarks',
          'targets',
          'wireless-ios',
          'target-availability-audit.json',
        ),
      );
      expect(artifact.existsSync(), isTrue);

      final json =
          jsonDecode(artifact.readAsStringSync()) as Map<String, Object?>;
      expect(json['canRunPhysicalProfileProbe'], isFalse);
      expect(json['summary'], contains('No credible physical profile target'));
      final signals = json['signals']! as Map<String, Object?>;
      final simulators = signals['flutterIosSimulators']! as List<Object?>;
      expect(simulators, hasLength(1));
    },
  );

  test('records iOS simulators without qualifying physical targets', () async {
    final workspaceRoot = Directory.systemTemp.createTempSync(
      'tagflow_target_audit_ios_simulator_test_',
    );
    addTearDown(() => workspaceRoot.deleteSync(recursive: true));

    final auditor = TargetAvailabilityAuditor(
      workspaceRoot: workspaceRoot,
      outputDirectory: Directory(
        p.join(workspaceRoot.path, 'build', 'benchmarks', 'targets'),
      ),
      runId: 'ios-simulator',
      generatedAt: DateTime.utc(2026, 6, 12, 12),
      processRunner: _fakeRunner({
        'flutter devices -v': '''
Found 1 connected device:
  iPhone 17 (mobile) • 3BA9E377-4B6F-49A7-83FA-F640060D6442 • ios • com.apple.CoreSimulator.SimRuntime.iOS-26-5 (simulator)
''',
        'xcrun xctrace list devices': '''
== Simulators ==
iPhone 17 (26.5) (3BA9E377-4B6F-49A7-83FA-F640060D6442)
''',
        'xcrun devicectl list devices': '',
        'xcrun devicectl list devices --verbose': '',
        'adb devices -l': 'List of devices attached\n\n',
        'system_profiler SPUSBDataType': '',
      }),
    );

    final result = await auditor.run();

    expect(result.canRunPhysicalProfileProbe, isFalse);
    expect(result.credibleProfileTargets, isEmpty);
    expect(result.signals.flutterConnectedPhysicalIos, isEmpty);
    expect(result.signals.flutterWirelessIos, isEmpty);
    expect(result.signals.flutterIosSimulators, hasLength(1));
    expect(result.signals.flutterIosSimulators.single.blockingReasons, [
      'simulator',
    ]);
  });

  test('qualifies iOS only when Flutter and Instruments agree', () async {
    final workspaceRoot = Directory.systemTemp.createTempSync(
      'tagflow_target_audit_ios_test_',
    );
    addTearDown(() => workspaceRoot.deleteSync(recursive: true));

    final auditor = TargetAvailabilityAuditor(
      workspaceRoot: workspaceRoot,
      outputDirectory: Directory(
        p.join(workspaceRoot.path, 'build', 'benchmarks', 'targets'),
      ),
      runId: 'wired-ios',
      generatedAt: DateTime.utc(2026, 6, 12, 12),
      processRunner: _fakeRunner({
        'flutter devices -v': '''
Found 1 connected device:
  Arya's Iphone 17 (mobile) • 0000815000110C960186401C • ios • iOS 27.0
''',
        'xcrun xctrace list devices': '''
== Devices ==
Arya's Iphone 17 (27.0) (0000815000110C960186401C)
== Simulators ==
iPhone 17 (26.5) (3BA9E377-4B6F-49A7-83FA-F640060D6442)
''',
        'xcrun devicectl list devices': '''
Arya's Iphone 17 0000815000110C960186401C available (paired)
''',
        'xcrun devicectl list devices --verbose': '''
identifier: 0000815000110C960186401C
transportType: usb
tunnelState: connected
ddiServicesAvailable: true
''',
        'adb devices -l': 'List of devices attached\n\n',
        'system_profiler SPUSBDataType': '',
      }),
    );

    final result = await auditor.run();

    expect(result.canRunPhysicalProfileProbe, isTrue);
    expect(result.credibleProfileTargets, hasLength(1));
    expect(result.credibleProfileTargets.single.platform, 'ios');
    expect(result.credibleProfileTargets.single.id, '0000815000110C960186401C');
  });

  test('qualifies Android only when Flutter and ADB agree', () async {
    final workspaceRoot = Directory.systemTemp.createTempSync(
      'tagflow_target_audit_android_test_',
    );
    addTearDown(() => workspaceRoot.deleteSync(recursive: true));

    final auditor = TargetAvailabilityAuditor(
      workspaceRoot: workspaceRoot,
      outputDirectory: Directory(
        p.join(workspaceRoot.path, 'build', 'benchmarks', 'targets'),
      ),
      runId: 'android',
      generatedAt: DateTime.utc(2026, 6, 12, 12),
      processRunner: _fakeRunner({
        'flutter devices -v': '''
Found 1 connected device:
  Pixel 8 (mobile) • android-1234 • android-arm64 • Android 16
''',
        'xcrun xctrace list devices': '',
        'xcrun devicectl list devices': '',
        'xcrun devicectl list devices --verbose': '',
        'adb devices -l': '''
List of devices attached
android-1234 device product:pixel model:Pixel_8 transport_id:1
''',
        'system_profiler SPUSBDataType': '',
      }),
    );

    final result = await auditor.run();

    expect(result.canRunPhysicalProfileProbe, isTrue);
    expect(result.credibleProfileTargets, hasLength(1));
    expect(result.credibleProfileTargets.single.platform, 'android');
    expect(result.credibleProfileTargets.single.id, 'android-1234');
  });

  test('does not qualify Android emulators as physical targets', () async {
    final workspaceRoot = Directory.systemTemp.createTempSync(
      'tagflow_target_audit_android_emulator_test_',
    );
    addTearDown(() => workspaceRoot.deleteSync(recursive: true));

    final auditor = TargetAvailabilityAuditor(
      workspaceRoot: workspaceRoot,
      outputDirectory: Directory(
        p.join(workspaceRoot.path, 'build', 'benchmarks', 'targets'),
      ),
      runId: 'android-emulator',
      generatedAt: DateTime.utc(2026, 6, 12, 12),
      processRunner: _fakeRunner({
        'flutter devices -v': '''
Found 1 connected device:
  sdk gphone64 arm64 (mobile) • emulator-5554 • android-arm64 • Android 16
''',
        'xcrun xctrace list devices': '',
        'xcrun devicectl list devices': '',
        'xcrun devicectl list devices --verbose': '',
        'adb devices -l': '''
List of devices attached
emulator-5554 device product:sdk_gphone64 model:sdk_gphone64 transport_id:1
''',
        'system_profiler SPUSBDataType': '',
      }),
    );

    final result = await auditor.run();

    expect(result.canRunPhysicalProfileProbe, isFalse);
    expect(result.signals.flutterConnectedAndroid, isEmpty);
    expect(result.signals.adbAttachedAndroid, isEmpty);
  });

  test('uses Flutter wireless section to block physical iOS claims', () async {
    final workspaceRoot = Directory.systemTemp.createTempSync(
      'tagflow_target_audit_wireless_section_test_',
    );
    addTearDown(() => workspaceRoot.deleteSync(recursive: true));

    final auditor = TargetAvailabilityAuditor(
      workspaceRoot: workspaceRoot,
      outputDirectory: Directory(
        p.join(workspaceRoot.path, 'build', 'benchmarks', 'targets'),
      ),
      runId: 'wireless-section-ios',
      generatedAt: DateTime.utc(2026, 6, 12, 12),
      processRunner: _fakeRunner({
        'flutter devices -v': '''
Found 1 wirelessly connected device:
  Arya's Iphone 17 (mobile) • 0000815000110C960186401C • ios • iOS 27.0
''',
        'xcrun xctrace list devices': '''
== Devices ==
Arya's Iphone 17 (27.0) (0000815000110C960186401C)
''',
        'xcrun devicectl list devices': '''
Arya's Iphone 17 0000815000110C960186401C available (paired)
''',
        'xcrun devicectl list devices --verbose': '''
identifier: 0000815000110C960186401C
transportType: localNetwork
tunnelState: connected
ddiServicesAvailable: true
''',
        'adb devices -l': 'List of devices attached\n\n',
        'system_profiler SPUSBDataType': '',
      }),
    );

    final result = await auditor.run();

    expect(result.canRunPhysicalProfileProbe, isFalse);
    expect(result.signals.flutterConnectedPhysicalIos, isEmpty);
    expect(result.signals.flutterWirelessIos, hasLength(1));
    expect(
      result.signals.flutterWirelessIos.single.id,
      '0000815000110C960186401C',
    );
  });

  test('records command start failures without throwing', () async {
    final workspaceRoot = Directory.systemTemp.createTempSync(
      'tagflow_target_audit_process_error_test_',
    );
    addTearDown(() => workspaceRoot.deleteSync(recursive: true));

    final auditor = TargetAvailabilityAuditor(
      workspaceRoot: workspaceRoot,
      outputDirectory: Directory(
        p.join(workspaceRoot.path, 'build', 'benchmarks', 'targets'),
      ),
      runId: 'process-error',
      processRunner: (executable, arguments, {workingDirectory}) async {
        throw const ProcessException('adb', ['devices'], 'missing');
      },
    );

    final result = await auditor.run();

    expect(result.canRunPhysicalProfileProbe, isFalse);
    expect(result.commands, hasLength(6));
    expect(
      result.commands.every((command) => command.exitCode == null),
      isTrue,
    );
    expect(result.commands.first.stderr, 'missing');
  });
}

TargetAuditProcessRunner _fakeRunner(Map<String, String> outputByCommand) {
  return (executable, arguments, {workingDirectory}) async {
    final command = [executable, ...arguments].join(' ');
    final output = outputByCommand[command];
    if (output == null) {
      return ProcessResult(1, 127, '', 'missing fake output for $command');
    }
    return ProcessResult(1, 0, output, '');
  };
}
