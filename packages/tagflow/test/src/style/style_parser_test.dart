// test/src/style/style_parser_test.dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/src/style/style_parser.dart';

void main() {
  group('StyleParser', () {
    group('parseFontSize', () {
      test('parses pixel values', () {
        expect(StyleParser.parseFontSize('16px'), 16.0);
        expect(StyleParser.parseFontSize('24.5px'), 24.5);
      });

      test('parses rem values', () {
        expect(StyleParser.parseFontSize('1rem'), 16.0);
        expect(StyleParser.parseFontSize('1.5rem'), 24.0);
      });

      test('parses plain numbers', () {
        expect(StyleParser.parseFontSize('16'), 16.0);
      });

      test('returns null for invalid values', () {
        expect(StyleParser.parseFontSize('invalid'), null);
        expect(StyleParser.parseFontSize(''), null);
      });
    });

    group('parseFontWeight', () {
      test('parses numeric weights', () {
        expect(StyleParser.parseFontWeight('400'), FontWeight.w400);
        expect(StyleParser.parseFontWeight('700'), FontWeight.w700);
      });

      test('parses named weights', () {
        expect(StyleParser.parseFontWeight('normal'), FontWeight.w400);
        expect(StyleParser.parseFontWeight('bold'), FontWeight.w700);
      });

      test('returns null for invalid values', () {
        expect(StyleParser.parseFontWeight('invalid'), null);
        expect(StyleParser.parseFontWeight('1000'), null);
      });
    });

    group('parseColor', () {
      test('parses hex colors', () {
        expect(StyleParser.parseColor('#ff0000'), const Color(0xFFFF0000));
        expect(StyleParser.parseColor('#f00'), const Color(0xFFFF0000));
        expect(StyleParser.parseColor('#00ff00'), const Color(0xFF00FF00));
        expect(StyleParser.parseColor('#0f0'), const Color(0xFF00FF00));
      });

      test('parses rgb colors', () {
        expect(
          StyleParser.parseColor('rgb(255, 0, 0)'),
          const Color(0xFFFF0000),
        );
        expect(
          StyleParser.parseColor('rgb(0, 255, 0)'),
          const Color(0xFF00FF00),
        );
        expect(
          StyleParser.parseColor('rgb(0,0,255)'), // No spaces
          const Color(0xFF0000FF),
        );
      });

      test('parses rgba colors', () {
        expect(
          StyleParser.parseColor('rgba(255, 0, 0, 0.5)'),
          const Color(0x80FF0000),
        );
        expect(
          StyleParser.parseColor('rgba(0, 255, 0, 0.3)'),
          const Color(0x4D00FF00),
        );
        expect(
          StyleParser.parseColor('rgba(0,0,255,1)'), // No spaces, full opacity
          const Color(0xFF0000FF),
        );
        expect(
          StyleParser.parseColor('rgba(255,0,0,0)'), // Full transparency
          const Color(0x00FF0000),
        );
      });

      test('handles invalid color values', () {
        expect(StyleParser.parseColor('rgb(255, 0)'), null); // Missing value
        expect(
          StyleParser.parseColor('rgb(abc, 0, 0)'),
          null,
        ); // Invalid number
        expect(StyleParser.parseColor('#xyz'), null); // Invalid hex
        expect(StyleParser.parseColor('invalid'), null);
      });

      test('handles whitespace in color values', () {
        expect(
          StyleParser.parseColor('rgb(255,\n0,\t0)'),
          const Color(0xFFFF0000),
        );
        expect(
          StyleParser.parseColor('rgba(255,   0,   0,    0.5)'),
          const Color(0x80FF0000),
        );
      });
    });

    group('parseEdgeInsets', () {
      test('parses single value', () {
        expect(StyleParser.parseEdgeInsets('8px'), const EdgeInsets.all(8));
      });

      test('parses two values', () {
        expect(
          StyleParser.parseEdgeInsets('8px 16px'),
          const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        );
      });

      test('parses four values', () {
        expect(
          StyleParser.parseEdgeInsets('1px 2px 3px 4px'),
          const EdgeInsets.fromLTRB(1, 2, 3, 4),
        );
      });

      test('returns null for invalid values', () {
        expect(StyleParser.parseEdgeInsets('invalid'), null);
        expect(
          StyleParser.parseEdgeInsets('8px 16px 24px'),
          null,
        ); // 3 values not supported
      });
    });
  });
}
