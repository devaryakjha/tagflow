// test/src/style/style_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/tagflow.dart';

void main() {
  group('ElementStyle', () {
    test('merges correctly', () {
      const baseStyle = ElementStyle(
        textStyle: TextStyle(fontSize: 16, color: Color(0xFF000000)),
        padding: EdgeInsets.all(8),
      );

      const overrideStyle = ElementStyle(
        textStyle: TextStyle(fontWeight: FontWeight.bold),
        margin: EdgeInsets.all(16),
      );

      final merged = baseStyle.merge(overrideStyle);

      expect(merged.textStyle?.fontSize, 16);
      expect(merged.textStyle?.fontWeight, FontWeight.bold);
      expect(merged.padding, const EdgeInsets.all(8));
      expect(merged.margin, const EdgeInsets.all(16));
    });
  });

  group('TagflowStyle', () {
    test('merges styles correctly', () {
      const baseStyle = TagflowStyle(
        textStyle: TextStyle(
          fontSize: 16,
          color: Color(0xFF000000),
        ),
        padding: EdgeInsets.all(8),
        elementStyles: {
          'p': ElementStyle(
            textStyle: TextStyle(height: 1.5),
            margin: EdgeInsets.symmetric(vertical: 8),
          ),
        },
      );

      const overrideStyle = TagflowStyle(
        textStyle: TextStyle(
          fontWeight: FontWeight.bold,
        ),
        margin: EdgeInsets.all(16),
        elementStyles: {
          'p': ElementStyle(
            textStyle: TextStyle(fontSize: 18),
          ),
          'span': ElementStyle(
            textStyle: TextStyle(fontStyle: FontStyle.italic),
          ),
        },
      );

      final merged = baseStyle.merge(overrideStyle);

      // Check base style merging
      expect(merged.textStyle?.fontSize, 16);
      expect(merged.textStyle?.fontWeight, FontWeight.bold);
      expect(merged.padding, const EdgeInsets.all(8));
      expect(merged.margin, const EdgeInsets.all(16));

      // Check element styles merging
      final pStyle = merged.elementStyles['p']!;
      expect(pStyle.textStyle?.height, 1.5);
      expect(pStyle.textStyle?.fontSize, 18);
      expect(pStyle.margin, const EdgeInsets.symmetric(vertical: 8));

      // Check new element style addition
      final spanStyle = merged.elementStyles['span']!;
      expect(spanStyle.textStyle?.fontStyle, FontStyle.italic);
    });

    test('copyWith works correctly', () {
      const style = TagflowStyle(
        textStyle: TextStyle(fontSize: 16),
        padding: EdgeInsets.all(8),
        elementStyles: {
          'p': ElementStyle(
            textStyle: TextStyle(height: 1.5),
          ),
        },
      );

      final copied = style.copyWith(
        textStyle: const TextStyle(fontSize: 20),
        elementStyles: {
          ...style.elementStyles,
          'h1': const ElementStyle(
            textStyle: TextStyle(fontSize: 32),
          ),
        },
      );

      expect(copied.textStyle?.fontSize, 20);
      expect(copied.padding, const EdgeInsets.all(8));
      expect(copied.elementStyles['p']?.textStyle?.height, 1.5);
      expect(copied.elementStyles['h1']?.textStyle?.fontSize, 32);
    });

    test('getElementStyle returns correct style', () {
      const style = TagflowStyle(
        elementStyles: {
          'p': ElementStyle(
            textStyle: TextStyle(height: 1.5),
          ),
          'h1': ElementStyle(
            textStyle: TextStyle(fontSize: 32),
          ),
        },
      );

      expect(style.getElementStyle('p')?.textStyle?.height, 1.5);
      expect(style.getElementStyle('h1')?.textStyle?.fontSize, 32);
      expect(style.getElementStyle('nonexistent'), isNull);
    });
  });

  group('TagflowTheme', () {
    testWidgets('provides theme through context', (tester) async {
      late TagflowTheme capturedTheme;

      await tester.pumpWidget(
        Builder(
          builder: (context) {
            return TagflowThemeProvider(
              theme: TagflowTheme.fromTheme(Theme.of(context)),
              child: Builder(
                builder: (context) {
                  capturedTheme = TagflowThemeProvider.of(context);
                  return Container();
                },
              ),
            );
          },
        ),
      );

      expect(capturedTheme.baseStyle.textStyle?.fontSize, 16);
      final h1Style = capturedTheme.baseStyle.elementStyles['h1'];
      expect(h1Style?.textStyle?.fontSize, 32);
    });
  });

  group('Universal style selector (*)', () {
    test('applies default style to elements without specific style', () {
      const style = TagflowStyle(
        defaultElementStyle: ElementStyle(
          margin: EdgeInsets.all(8),
          textStyle: TextStyle(color: Color(0xFF000000)),
        ),
      );

      final elementStyle = style.getElementStyle('any-tag');
      expect(elementStyle?.margin, const EdgeInsets.all(8));
      expect(elementStyle?.textStyle?.color, const Color(0xFF000000));
    });

    test('merges default style with element-specific style', () {
      const style = TagflowStyle(
        defaultElementStyle: ElementStyle(
          margin: EdgeInsets.all(8),
          textStyle: TextStyle(color: Color(0xFF000000)),
        ),
        elementStyles: {
          'p': ElementStyle(
            padding: EdgeInsets.all(16),
            textStyle: TextStyle(fontSize: 16),
          ),
        },
      );

      final pStyle = style.getElementStyle('p');
      expect(pStyle?.margin, const EdgeInsets.all(8)); // From default
      expect(pStyle?.padding, const EdgeInsets.all(16)); // From p
      expect(pStyle?.textStyle?.color, const Color(0xFF000000)); // From default
      expect(pStyle?.textStyle?.fontSize, 16); // From p
    });

    test('element-specific style overrides default style', () {
      const style = TagflowStyle(
        defaultElementStyle: ElementStyle(
          margin: EdgeInsets.all(8),
          textStyle: TextStyle(fontSize: 14),
        ),
        elementStyles: {
          'h1': ElementStyle(
            margin: EdgeInsets.all(16),
            textStyle: TextStyle(fontSize: 32),
          ),
        },
      );

      final h1Style = style.getElementStyle('h1');
      expect(h1Style?.margin, const EdgeInsets.all(16)); // Overridden
      expect(h1Style?.textStyle?.fontSize, 32); // Overridden
    });
  });
}
