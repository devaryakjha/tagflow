import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/src/style/style.dart';

void main() {
  group('TagflowStyle', () {
    test('merges styles correctly', () {
      const baseStyle = TagflowStyle(
        textStyle: TextStyle(
          fontSize: 16,
          color: Color(0xFF000000),
        ),
        padding: EdgeInsets.all(8),
      );

      const overrideStyle = TagflowStyle(
        textStyle: TextStyle(
          fontWeight: FontWeight.bold,
        ),
        margin: EdgeInsets.all(16),
      );

      final merged = baseStyle.merge(overrideStyle);

      expect(merged.textStyle?.fontSize, 16);
      expect(merged.textStyle?.fontWeight, FontWeight.bold);
      expect(merged.padding, const EdgeInsets.all(8));
      expect(merged.margin, const EdgeInsets.all(16));
    });

    test('copyWith works correctly', () {
      const style = TagflowStyle(
        textStyle: TextStyle(fontSize: 16),
        padding: EdgeInsets.all(8),
      );

      final copied = style.copyWith(
        textStyle: const TextStyle(fontSize: 20),
      );

      expect(copied.textStyle?.fontSize, 20);
      expect(copied.padding, const EdgeInsets.all(8));
    });
  });

  group('TagflowTheme', () {
    testWidgets('provides theme through context', (tester) async {
      late TagflowTheme capturedTheme;

      await tester.pumpWidget(
        TagflowThemeProvider(
          theme: TagflowTheme.light(),
          child: Builder(
            builder: (context) {
              capturedTheme = TagflowThemeProvider.of(context);
              return Container();
            },
          ),
        ),
      );

      expect(capturedTheme.baseStyle.textStyle?.fontSize, 16);
      expect(capturedTheme.baseStyle.headingStyles['h1']?.fontSize, 32);
    });

    test('light theme has correct defaults', () {
      final theme = TagflowTheme.light();

      expect(theme.baseStyle.textStyle?.color, const Color(0xFF000000));
      expect(theme.baseStyle.headingStyles['h1']?.fontSize, 32);
      expect(theme.baseStyle.linkStyle?.color, const Color(0xFF2563EB));
    });

    test('dark theme has correct defaults', () {
      final theme = TagflowTheme.dark();

      expect(theme.baseStyle.textStyle?.color, const Color(0xFFFFFFFF));
    });
  });
}
