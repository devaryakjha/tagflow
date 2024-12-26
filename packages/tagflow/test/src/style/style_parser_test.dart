import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/tagflow.dart';

void main() {
  group('StyleParser', () {
    group('parseSize', () {
      test('parses pixel values', () {
        expect(StyleParser.parseSize('10px'), 10.0);
        expect(StyleParser.parseSize('0px'), 0.0);
        expect(StyleParser.parseSize('-10px'), -10.0);
      });

      test('parses rem values', () {
        expect(StyleParser.parseSize('1rem'), 16.0);
        expect(StyleParser.parseSize('1.5rem'), 24.0);
        expect(StyleParser.parseSize('1rem', 20), 20.0);
      });

      test('parses percentage values', () {
        expect(StyleParser.parseSize('100%'), 1.0);
        expect(StyleParser.parseSize('50%'), 0.5);
        expect(StyleParser.parseSize('0%'), 0.0);
      });

      test('handles invalid values', () {
        expect(StyleParser.parseSize('invalid'), null);
        expect(StyleParser.parseSize(''), null);
        expect(StyleParser.parseSize('px'), null);
      });
    });

    group('parseColor', () {
      test('parses hex colors', () {
        expect(StyleParser.parseColor('#000000'), const Color(0xFF000000));
        expect(StyleParser.parseColor('#fff'), const Color(0xFFFFFFFF));
        expect(StyleParser.parseColor('#FF0000'), const Color(0xFFFF0000));
      });

      test('parses rgb/rgba colors', () {
        expect(StyleParser.parseColor('rgb(0,0,0)'), const Color(0xFF000000));
        expect(
          StyleParser.parseColor('rgba(255,0,0,1)'),
          const Color(0xFFFF0000),
        );
        expect(
          StyleParser.parseColor('rgba(0,0,0,0.5)'),
          const Color(0x80000000),
        );
        expect(
          StyleParser.parseColor('rgba(0,0,0,0.25)'),
          const Color(0x40000000),
        );
      });

      test('parses named colors', () {
        const namedColors = {
          'black': Color(0xFF000000),
          'white': Color(0xFFFFFFFF),
          'red': Color(0xFFFF0000),
        };
        expect(
          StyleParser.parseColor('black', namedColors),
          const Color(0xFF000000),
        );
        expect(
          StyleParser.parseColor('white', namedColors),
          const Color(0xFFFFFFFF),
        );
        expect(
          StyleParser.parseColor('red', namedColors),
          const Color(0xFFFF0000),
        );
      });

      test('handles invalid values', () {
        expect(StyleParser.parseColor('invalid'), null);
        expect(StyleParser.parseColor(''), null);
        expect(StyleParser.parseColor('#xyz'), null);
      });
    });

    group('parseInlineStyle', () {
      test('parses basic styles', () {
        final style = StyleParser.parseInlineStyle(
          'color: red; padding: 10px; margin: 5px;',
          const TagflowTheme.raw(
            defaultStyle: TagflowStyle(),
            styles: {},
            namedColors: {
              'red': Color(0xFFFF0000),
            },
          ),
        );

        expect(style?.textStyleWithColor?.color, const Color(0xFFFF0000));
        expect(style?.padding, const EdgeInsets.all(10));
        expect(style?.margin, const EdgeInsets.all(5));
      });

      test('parses display and flex properties', () {
        final style = StyleParser.parseInlineStyle(
          'display: flex; flex-direction: row; justify-content: center;',
        );

        expect(style?.display, Display.flex);
        expect(style?.flexDirection, Axis.horizontal);
        expect(style?.justifyContent, MainAxisAlignment.center);
      });

      test('handles empty and invalid styles', () {
        expect(StyleParser.parseInlineStyle(''), null);
        expect(StyleParser.parseInlineStyle('invalid'), null);
        expect(
          StyleParser.parseInlineStyle('color:')?.textStyleWithColor?.color,
          null,
        );
      });
    });

    group('parseFontWeight', () {
      test('parses numeric weights', () {
        expect(StyleParser.parseFontWeight('100'), FontWeight.w100);
        expect(StyleParser.parseFontWeight('400'), FontWeight.w400);
        expect(StyleParser.parseFontWeight('900'), FontWeight.w900);
      });

      test('parses named weights', () {
        expect(StyleParser.parseFontWeight('normal'), FontWeight.w400);
        expect(StyleParser.parseFontWeight('bold'), FontWeight.w700);
        expect(StyleParser.parseFontWeight('lighter'), null);
      });
    });

    group('parseBoxFit', () {
      test('parses valid values', () {
        expect(StyleParser.parseBoxFit('contain'), BoxFit.contain);
        expect(StyleParser.parseBoxFit('cover'), BoxFit.cover);
        expect(StyleParser.parseBoxFit('fill'), BoxFit.fill);
      });

      test('handles invalid values', () {
        expect(StyleParser.parseBoxFit('invalid'), null);
        expect(StyleParser.parseBoxFit(''), null);
      });
    });

    group('parseBorderRadius', () {
      test('parses pixel values', () {
        expect(
          StyleParser.parseBorderRadius('10px'),
          BorderRadius.circular(10),
        );
      });

      test('handles invalid values', () {
        expect(StyleParser.parseBorderRadius('invalid'), null);
        expect(StyleParser.parseBorderRadius(''), null);
      });
    });

    group('parseBorderSide', () {
      test('parses valid border definitions', () {
        expect(
          StyleParser.parseBorderSide('1px solid rgb(0,0,0)'),
          const BorderSide(),
        );
        expect(
          StyleParser.parseBorderSide('2px solid #FF0000'),
          const BorderSide(width: 2, color: Color(0xFFFF0000)),
        );
      });

      test('handles invalid values', () {
        expect(StyleParser.parseBorderSide('invalid'), null);
        expect(StyleParser.parseBorderSide('1px'), null);
      });
    });
  });
}
