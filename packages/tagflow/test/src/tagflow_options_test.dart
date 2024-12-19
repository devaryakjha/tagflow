import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/tagflow.dart';

void main() {
  group('TagflowOptions', () {
    testWidgets('provides options through context', (tester) async {
      late TagflowOptions capturedOptions;

      await tester.pumpWidget(
        TagflowScope(
          options: const TagflowOptions(debug: true),
          child: Builder(
            builder: (context) {
              capturedOptions = TagflowOptions.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(capturedOptions.debug, true);
    });

    test('copyWith works correctly', () {
      const options = TagflowOptions(
        maxImageWidth: 100,
        maxImageHeight: 100,
      );

      final copied = options.copyWith(
        debug: true,
        maxImageWidth: 200,
        maxImageHeight: 200,
      );

      expect(copied.debug, true);
      expect(copied.maxImageWidth, 200);
      expect(copied.enableImageCache, true);
    });

    testWidgets('updates when options change', (tester) async {
      var buildCount = 0;

      await tester.pumpWidget(
        TagflowScope(
          options: TagflowOptions.defaults,
          child: Builder(
            builder: (context) {
              buildCount++;
              TagflowOptions.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(buildCount, 1);

      await tester.pumpWidget(
        TagflowScope(
          options: const TagflowOptions(debug: true),
          child: Builder(
            builder: (context) {
              buildCount++;
              TagflowOptions.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(buildCount, 2);
    });
  });
}
