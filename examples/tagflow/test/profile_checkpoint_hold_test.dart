import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow_example/benchmarks/profile_checkpoint_hold.dart';

void main() {
  test('stays disabled when no hold-open flags are provided', () {
    final options = ProfileCheckpointHoldOptions.parse(enabledValue: 'false');

    expect(options.enabled, isFalse);
    expect(options.holdOpenSeconds, 0);
    expect(options.holdDuration, Duration.zero);
  });

  test('uses the default hold-open duration when explicitly enabled', () {
    final options = ProfileCheckpointHoldOptions.parse(enabledValue: 'true');

    expect(options.enabled, isTrue);
    expect(options.holdOpenSeconds, 120);
    expect(options.holdDuration, const Duration(seconds: 120));
  });

  test('treats an explicit hold-open seconds value as opt-in', () {
    final options = ProfileCheckpointHoldOptions.parse(
      enabledValue: 'false',
      holdOpenSecondsValue: '90',
    );

    expect(options.enabled, isTrue);
    expect(options.holdOpenSeconds, 90);
  });

  test('rejects non-positive hold-open seconds', () {
    expect(
      () => ProfileCheckpointHoldOptions.parse(
        enabledValue: 'true',
        holdOpenSecondsValue: '0',
      ),
      throwsFormatException,
    );
  });
}
