import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow_benchmarks/src/io/package_paths.dart';

void main() {
  test(
    'native runtime gate CLI passes the default draft profile',
    () async {
      final result = await _runGateCli();
      final json = _decodeJson(result.stdout);

      expect(result.exitCode, 0);
      expect(json['passed'], isTrue);
      expect(json['profile'], containsPair('id', 'pr72-draft'));
      expect(json['issues'], isEmpty);
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  test(
    'native runtime gate CLI fails beta-preapproval on open owner gates',
    () async {
      final result = await _runGateCli(profile: 'beta-preapproval');
      final json = _decodeJson(result.stdout);
      final requiredOpenGates = (json['requiredOpenGates']! as List<Object?>)
          .cast<Map<String, Object?>>();

      expect(result.exitCode, 1);
      expect(json['passed'], isFalse);
      expect(json['profile'], containsPair('id', 'beta-preapproval'));
      expect(requiredOpenGates.map((gate) => gate['id']), <String>[
        'real-app-route',
        'physical-observed-profile',
      ]);
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  test(
    'native runtime gate CLI accepts expected beta-preapproval open gates',
    () async {
      final result = await _runGateCli(
        profile: 'beta-preapproval',
        expectedOpenGates: <String>[
          'real-app-route',
          'physical-observed-profile',
        ],
      );
      final json = _decodeJson(result.stdout);

      expect(result.exitCode, 0);
      expect(json['passed'], isFalse);
      expect(json['expectationPassed'], isTrue);
      expect(json['expectedOpenGateIds'], <String>[
        'real-app-route',
        'physical-observed-profile',
      ]);
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  test(
    'native runtime gate CLI accepts profile expected open gates',
    () async {
      final result = await _runGateCli(
        profile: 'beta-preapproval',
        expectProfileOpenGates: true,
      );
      final json = _decodeJson(result.stdout);

      expect(result.exitCode, 0);
      expect(json['passed'], isFalse);
      expect(json['expectationPassed'], isTrue);
      expect(json['expectedOpenGateIds'], <String>[
        'real-app-route',
        'physical-observed-profile',
      ]);
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  test(
    'native runtime gate CLI rejects mismatched expected open gates',
    () async {
      final result = await _runGateCli(
        profile: 'beta-preapproval',
        expectedOpenGates: <String>['real-app-route'],
      );
      final json = _decodeJson(result.stdout);

      expect(result.exitCode, 1);
      expect(json['passed'], isFalse);
      expect(json['expectationPassed'], isFalse);
      expect(json['expectedOpenGateIds'], <String>['real-app-route']);
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  test(
    'native runtime gate CLI rejects mixed expectation sources',
    () async {
      final result = await _runGateCli(
        profile: 'beta-preapproval',
        expectedOpenGates: <String>['real-app-route'],
        expectProfileOpenGates: true,
      );

      expect(result.exitCode, 64);
      expect(
        result.stderr,
        contains(
          'Use either --expect-open-gates or --expect-profile-open-gates',
        ),
      );
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}

Future<ProcessResult> _runGateCli({
  String? profile,
  List<String>? expectedOpenGates,
  bool expectProfileOpenGates = false,
}) {
  final packageRoot = resolveBenchmarkPackageRoot();
  return Process.run('dart', <String>[
    'run',
    'bin/check_native_runtime_gates.dart',
    if (profile != null) '--profile=$profile',
    if (expectedOpenGates != null)
      '--expect-open-gates=${expectedOpenGates.join(',')}',
    if (expectProfileOpenGates) '--expect-profile-open-gates=true',
  ], workingDirectory: packageRoot.path);
}

Map<String, Object?> _decodeJson(Object? stdout) {
  final decoded = jsonDecode(stdout! as String);
  expect(decoded, isA<Map<String, Object?>>());
  return (decoded as Map).cast<String, Object?>();
}
