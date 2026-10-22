import 'dart:async';

// The golden harness and fonts live in the core package so both packages
// render baselines identically.
import '../../../tagflow/test/goldens/golden_harness.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await loadGoldenFonts('../tagflow/test/goldens/fonts');
  await testMain();
}
