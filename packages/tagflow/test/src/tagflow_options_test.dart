// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/legacy.dart';

void main() {
  group('TagflowSelectableOptions', () {
    test('can be created with default values', () {
      const options = TagflowSelectableOptions();
      expect(options.enabled, false);
      expect(
        options.imageSelectionBehavior,
        TagflowImageSelectionBehavior.altTextOnly,
      );
    });

    test('can be created with custom values', () {
      final options = TagflowSelectableOptions(
        enabled: true,
        imageSelectionBehavior: TagflowImageSelectionBehavior.urlAndAlt,
        imageSelectionBehaviorTextBuilder: (element, context) => 'Custom Text',
      );

      expect(options.enabled, true);
      expect(
        options.imageSelectionBehavior,
        TagflowImageSelectionBehavior.urlAndAlt,
      );
      expect(options.imageSelectionBehaviorTextBuilder, isNotNull);
    });

    test(
      'fails when imageSelectionBehavior is custom and imageSelectionBehaviorTextBuilder is null',
      () {
        expect(
          () => TagflowSelectableOptions(
            enabled: true,
            imageSelectionBehavior: TagflowImageSelectionBehavior.custom,
          ),
          throwsAssertionError,
        );
      },
    );
  });

  group('TagflowViewOptions', () {
    testWidgets('provides view options through context', (tester) async {
      late TagflowViewOptions capturedOptions;

      await tester.pumpWidget(
        TagflowScope.view(
          viewOptions: const TagflowViewOptions(debug: true),
          child: Builder(
            builder: (context) {
              capturedOptions = TagflowViewOptions.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(capturedOptions.debug, true);
    });

    test('copyWith works correctly', () {
      const options = TagflowViewOptions(
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

    testWidgets('updates when view options change', (tester) async {
      var buildCount = 0;

      await tester.pumpWidget(
        TagflowScope.view(
          viewOptions: TagflowViewOptions.defaults,
          child: Builder(
            builder: (context) {
              buildCount++;
              TagflowViewOptions.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(buildCount, 1);

      await tester.pumpWidget(
        TagflowScope.view(
          viewOptions: const TagflowViewOptions(debug: true),
          child: Builder(
            builder: (context) {
              buildCount++;
              TagflowViewOptions.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(buildCount, 2);
    });
  });

  group('TagflowOptions compatibility', () {
    testWidgets('provides legacy options through context', (tester) async {
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

    test('preserves render boundaries and converts to view options', () {
      const options = TagflowOptions(maxImageWidth: 100, maxImageHeight: 100);
      const boundary = TagflowRenderBoundary.comment(end: 'end-of-mobile');

      final copied = options.copyWith(
        debug: true,
        maxImageWidth: 200,
        maxImageHeight: 200,
        renderBoundary: boundary,
      );
      final viewOptions = copied.toViewOptions();
      final roundTripped = TagflowOptions.fromViewOptions(viewOptions);

      expect(copied.debug, true);
      expect(copied.maxImageWidth, 200);
      expect(copied.enableImageCache, true);
      expect(copied.renderBoundary, boundary);
      expect(roundTripped.renderBoundary, isNull);
    });
  });
}
