import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/tagflow.dart';

void main() {
  group('built-in surface colors', () {
    const html = '<pre><code>x</code></pre><hr>';

    Future<BoxDecoration> codeBlockDecoration(
      WidgetTester tester,
      ThemeData theme,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(body: Tagflow.html(html: html)),
        ),
      );
      final box = tester.widget<DecoratedBox>(
        find
            .ancestor(of: find.text('x'), matching: find.byType(DecoratedBox))
            .first,
      );
      return box.decoration as BoxDecoration;
    }

    testWidgets('should tint surfaces from dark text in the light theme', (
      tester,
    ) async {
      final decoration = await codeBlockDecoration(tester, ThemeData.light());
      final color = decoration.color!;

      expect(color.a, closeTo(0x12 / 255, 0.001));
      expect(color.computeLuminance(), lessThan(0.1));
    });

    testWidgets('should tint surfaces from light text in the dark theme', (
      tester,
    ) async {
      final decoration = await codeBlockDecoration(tester, ThemeData.dark());
      final color = decoration.color!;

      expect(color.a, closeTo(0x12 / 255, 0.001));
      expect(color.computeLuminance(), greaterThan(0.5));
    });
  });
}
