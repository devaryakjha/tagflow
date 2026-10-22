import 'dart:async';

import 'golden_harness.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await loadGoldenFonts('test/goldens/fonts');
  await testMain();
}
