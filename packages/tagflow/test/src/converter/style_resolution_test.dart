// test/src/converter/style_resolution_test.dart
import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/src/converter/converter.dart';
import 'package:tagflow/src/converter/styled_converter.dart';
import 'package:tagflow/src/core/models/element.dart';
import 'package:tagflow/src/style/style.dart';

void main() {
  group('StyleResolution', () {
    late TagflowTheme theme;
    late ElementConverter testConverter;

    setUp(() {
      // Setup a test theme with known styles
      theme = const TagflowTheme(
        baseStyle: TagflowStyle(
          textStyle: TextStyle(fontSize: 16),
          defaultElementStyle: ElementStyle(
            margin: EdgeInsets.all(4),
          ),
          elementStyles: {
            'p': ElementStyle(
              textStyle: TextStyle(height: 1.5),
              margin: EdgeInsets.symmetric(vertical: 8),
            ),
          },
        ),
        tagStyles: {
          'p': TagflowStyle(
            textStyle: TextStyle(color: Color(0xFF000000)),
          ),
        },
        classStyles: {
          'highlight': TagflowStyle(
            backgroundColor: Color(0xFFFFF9C4),
          ),
        },
      );

      // Create a test converter
      testConverter = TestConverter();
    });

    testWidgets('resolves base styles', (tester) async {
      await tester.pumpWidget(
        TagflowThemeProvider(
          theme: theme,
          child: Builder(
            builder: (context) {
              final element = TagflowElement(tag: 'span');
              final style = testConverter.resolveStyle(element, context);

              expect(style.textStyle?.fontSize, 16);
              expect(style.margin, const EdgeInsets.all(4));
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('resolves element-specific styles', (tester) async {
      await tester.pumpWidget(
        TagflowThemeProvider(
          theme: theme,
          child: Builder(
            builder: (context) {
              final element = TagflowElement(tag: 'p');
              final style = testConverter.resolveStyle(element, context);

              expect(style.textStyle?.fontSize, 16);
              expect(style.textStyle?.height, 1.5);
              expect(style.textStyle?.color, const Color(0xFF000000));
              expect(style.margin, const EdgeInsets.symmetric(vertical: 8));
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('resolves class styles', (tester) async {
      await tester.pumpWidget(
        TagflowThemeProvider(
          theme: theme,
          child: Builder(
            builder: (context) {
              final element = TagflowElement(
                tag: 'p',
                attributes: LinkedHashMap.from({'class': 'highlight'}),
              );
              final style = testConverter.resolveStyle(element, context);

              expect(style.backgroundColor, const Color(0xFFFFF9C4));
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('resolves inline styles', (tester) async {
      await tester.pumpWidget(
        TagflowThemeProvider(
          theme: theme,
          child: Builder(
            builder: (context) {
              final element = TagflowElement(
                tag: 'p',
                attributes: LinkedHashMap.from({
                  'style': 'font-size: 20px; color: #ff0000; margin: 16px',
                }),
              );
              final style = testConverter.resolveStyle(element, context);

              expect(style.textStyle?.fontSize, 20);
              expect(style.textStyle?.color, const Color(0xFFFF0000));
              expect(style.margin, const EdgeInsets.all(16));
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('follows correct style precedence', (tester) async {
      await tester.pumpWidget(
        TagflowThemeProvider(
          theme: theme,
          child: Builder(
            builder: (context) {
              final element = TagflowElement(
                tag: 'p',
                attributes: LinkedHashMap.from({
                  'class': 'highlight',
                  'style': 'color: #ff0000; margin: 16px',
                }),
              );
              final style = testConverter.resolveStyle(element, context);

              // Base style (fontSize: 16)
              expect(style.textStyle?.fontSize, 16);

              // Element style (height: 1.5, margin: vertical 8)
              expect(style.textStyle?.height, 1.5);

              // Tag style (color: black) - overridden by inline

              // Class style (backgroundColor: yellow)
              expect(style.backgroundColor, const Color(0xFFFFF9C4));

              // Inline style (color: red, margin: 16) - highest precedence
              expect(style.textStyle?.color, const Color(0xFFFF0000));
              expect(style.margin, const EdgeInsets.all(16));

              return Container();
            },
          ),
        ),
      );
    });
  });
}

class TestConverter extends ElementConverter {
  @override
  Set<String> get supportedTags => {};

  @override
  bool canHandle(TagflowElement element) => true;

  @override
  Widget convert(
    TagflowElement element,
    BuildContext context,
    TagflowConverter converter,
  ) {
    return Container();
  }
}
