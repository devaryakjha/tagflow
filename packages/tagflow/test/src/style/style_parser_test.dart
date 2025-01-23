import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/tagflow.dart';

void main() {
  group('StyleParser', () {
    group('parseSize', () {
      test('parses pixel values', () {
        expect(StyleParser.parseSize('10px'), 10.0);
        expect(StyleParser.parseSize('0px'), 0.0);
        expect(StyleParser.parseSize('-10px'), -10.0);
        expect(StyleParser.parseSize('10.5px'), 10.5);
      });

      test('parses rem values', () {
        expect(StyleParser.parseSize('1rem'), 16.0);
        expect(StyleParser.parseSize('1.5rem'), 24.0);
        expect(StyleParser.parseSize('1rem', 20), 20.0);
        expect(StyleParser.parseSize('0.5rem'), 8.0);
      });

      test('parses em values', () {
        expect(StyleParser.parseSize('1em'), 16.0);
        expect(StyleParser.parseSize('1.5em'), 24.0);
        expect(StyleParser.parseSize('1em', 20), 20.0);
      });

      test('parses pt values', () {
        expect(StyleParser.parseSize('12pt'), 16.0);
        expect(StyleParser.parseSize('9pt'), 12.0);
      });

      test('parses viewport relative units', () {
        expect(StyleParser.parseSize('10vh'), isNull);
        expect(StyleParser.parseSize('10vw'), isNull);
      });

      test('parses percentage values', () {
        expect(StyleParser.parseSize('100%'), null);
        expect(StyleParser.parseSize('50%'), null);
        expect(StyleParser.parseSize('0%'), null);
        expect(StyleParser.parseSize('150%'), null);
      });

      test('handles invalid values', () {
        expect(StyleParser.parseSize('invalid'), null);
        expect(StyleParser.parseSize(''), null);
        expect(StyleParser.parseSize('px'), null);
        expect(StyleParser.parseSize('10x'), null);
      });
    });

    group('parseColor', () {
      test('parses hex colors', () {
        expect(StyleParser.parseColor('#000000'), const Color(0xFF000000));
        expect(StyleParser.parseColor('#fff'), const Color(0xFFFFFFFF));
        expect(StyleParser.parseColor('#FF0000'), const Color(0xFFFF0000));
        expect(StyleParser.parseColor('#00ff00'), const Color(0xFF00FF00));
        expect(StyleParser.parseColor('#0000ff'), const Color(0xFF0000FF));
      });

      test('parses rgb/rgba colors', () {
        expect(StyleParser.parseColor('rgb(0,0,0)'), const Color(0xFF000000));
        expect(StyleParser.parseColor('rgb(255,0,0)'), const Color(0xFFFF0000));
        expect(StyleParser.parseColor('rgb(0,255,0)'), const Color(0xFF00FF00));
        expect(StyleParser.parseColor('rgb(0,0,255)'), const Color(0xFF0000FF));
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
        expect(
          StyleParser.parseColor('rgba(255,255,255,0)'),
          const Color(0x00FFFFFF),
        );
        expect(
          StyleParser.parseColor('rgba(0,0,0,0.1)'),
          const Color(0x1A000000),
        );
      });

      test('parses rgb/rgba colors with spaces', () {
        expect(StyleParser.parseColor('rgb(0, 0, 0)'), const Color(0xFF000000));
        expect(
          StyleParser.parseColor('rgba(255, 0, 0, 1.0)'),
          const Color(0xFFFF0000),
        );
        expect(
          StyleParser.parseColor('rgba(0, 0, 0, 0.5)'),
          const Color(0x80000000),
        );
      });

      test('parses named colors', () {
        const namedColors = {
          'black': Color(0xFF000000),
          'white': Color(0xFFFFFFFF),
          'red': Color(0xFFFF0000),
          'green': Color(0xFF00FF00),
          'blue': Color(0xFF0000FF),
          'custom': Color(0xFF123456),
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
        expect(
          StyleParser.parseColor('custom', namedColors),
          const Color(0xFF123456),
        );
      });

      test('handles invalid values', () {
        expect(StyleParser.parseColor('invalid'), null);
        expect(StyleParser.parseColor(''), null);
        expect(StyleParser.parseColor('#xyz'), null);
        expect(StyleParser.parseColor('#12'), null);
        expect(StyleParser.parseColor('#12345'), null);
        expect(StyleParser.parseColor('rgb(256,0,0)'), null);
        expect(StyleParser.parseColor('rgb(0,0)'), null);
        expect(StyleParser.parseColor('rgba(0,0,0,2)'), null);
        expect(StyleParser.parseColor('rgba(0,0,0,-1)'), null);
      });
    });

    group('parseInlineStyle', () {
      test('parses basic styles', () {
        final style = StyleParser.parseInlineStyle(
          'color: red; padding: 10px; margin: 5px;',
          const TagflowTheme.raw(
            defaultStyle: TagflowStyle.empty,
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
        expect(StyleParser.parseFontWeight('200'), FontWeight.w200);
        expect(StyleParser.parseFontWeight('300'), FontWeight.w300);
        expect(StyleParser.parseFontWeight('400'), FontWeight.w400);
        expect(StyleParser.parseFontWeight('500'), FontWeight.w500);
        expect(StyleParser.parseFontWeight('600'), FontWeight.w600);
        expect(StyleParser.parseFontWeight('700'), FontWeight.w700);
        expect(StyleParser.parseFontWeight('800'), FontWeight.w800);
        expect(StyleParser.parseFontWeight('900'), FontWeight.w900);
      });

      test('parses named weights', () {
        expect(StyleParser.parseFontWeight('thin'), FontWeight.w100);
        expect(StyleParser.parseFontWeight('extralight'), FontWeight.w200);
        expect(StyleParser.parseFontWeight('light'), FontWeight.w300);
        expect(StyleParser.parseFontWeight('normal'), FontWeight.w400);
        expect(StyleParser.parseFontWeight('regular'), FontWeight.w400);
        expect(StyleParser.parseFontWeight('medium'), FontWeight.w500);
        expect(StyleParser.parseFontWeight('semibold'), FontWeight.w600);
        expect(StyleParser.parseFontWeight('bold'), FontWeight.w700);
        expect(StyleParser.parseFontWeight('extrabold'), FontWeight.w800);
        expect(StyleParser.parseFontWeight('black'), FontWeight.w900);
      });

      test('handles case insensitivity', () {
        expect(StyleParser.parseFontWeight('BOLD'), FontWeight.w700);
        expect(StyleParser.parseFontWeight('Normal'), FontWeight.w400);
        expect(StyleParser.parseFontWeight('THIN'), FontWeight.w100);
      });

      test('handles invalid values', () {
        expect(StyleParser.parseFontWeight('invalid'), null);
        expect(StyleParser.parseFontWeight(''), null);
        expect(StyleParser.parseFontWeight('0'), null);
        expect(StyleParser.parseFontWeight('1000'), null);
      });
    });

    group('parseFontStyle', () {
      test('parses valid values', () {
        expect(StyleParser.parseFontStyle('normal'), FontStyle.normal);
        expect(StyleParser.parseFontStyle('italic'), FontStyle.italic);
      });

      test('handles case insensitivity', () {
        expect(StyleParser.parseFontStyle('NORMAL'), FontStyle.normal);
        expect(StyleParser.parseFontStyle('Italic'), FontStyle.italic);
      });

      test('handles invalid values', () {
        expect(StyleParser.parseFontStyle('invalid'), null);
        expect(StyleParser.parseFontStyle(''), null);
        expect(StyleParser.parseFontStyle('oblique'), null);
      });
    });

    group('parseTextDecoration', () {
      test('parses single decorations', () {
        expect(
          StyleParser.parseTextDecoration('underline'),
          TextDecoration.underline,
        );
        expect(
          StyleParser.parseTextDecoration('line-through'),
          TextDecoration.lineThrough,
        );
        expect(
          StyleParser.parseTextDecoration('overline'),
          TextDecoration.overline,
        );
        expect(StyleParser.parseTextDecoration('none'), TextDecoration.none);
      });

      test('parses multiple decorations', () {
        expect(
          StyleParser.parseTextDecoration('underline line-through'),
          TextDecoration.combine(
            [TextDecoration.underline, TextDecoration.lineThrough],
          ),
        );
        expect(
          StyleParser.parseTextDecoration('underline overline line-through'),
          TextDecoration.combine([
            TextDecoration.underline,
            TextDecoration.overline,
            TextDecoration.lineThrough,
          ]),
        );
      });

      test('handles case insensitivity', () {
        expect(
          StyleParser.parseTextDecoration('UNDERLINE'),
          TextDecoration.underline,
        );
        expect(
          StyleParser.parseTextDecoration('Line-Through'),
          TextDecoration.lineThrough,
        );
      });

      test('handles invalid values', () {
        expect(StyleParser.parseTextDecoration('invalid'), null);
        expect(StyleParser.parseTextDecoration(''), null);
      });
    });

    group('parseTextAlign', () {
      test('parses valid values', () {
        expect(StyleParser.parseTextAlign('left'), TextAlign.left);
        expect(StyleParser.parseTextAlign('right'), TextAlign.right);
        expect(StyleParser.parseTextAlign('center'), TextAlign.center);
        expect(StyleParser.parseTextAlign('justify'), TextAlign.justify);
        expect(StyleParser.parseTextAlign('start'), TextAlign.start);
        expect(StyleParser.parseTextAlign('end'), TextAlign.end);
      });

      test('handles case insensitivity', () {
        expect(StyleParser.parseTextAlign('LEFT'), TextAlign.left);
        expect(StyleParser.parseTextAlign('Center'), TextAlign.center);
      });

      test('handles invalid values', () {
        expect(StyleParser.parseTextAlign('invalid'), null);
        expect(StyleParser.parseTextAlign(''), null);
      });
    });

    group('parseEdgeInsets', () {
      test('parses single value', () {
        expect(StyleParser.parseEdgeInsets('10px'), const EdgeInsets.all(10));
        expect(StyleParser.parseEdgeInsets('0'), null);
      });

      test('parses two values', () {
        expect(
          StyleParser.parseEdgeInsets('10px 20px'),
          const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        );
      });

      test('parses three values', () {
        expect(
          StyleParser.parseEdgeInsets('10px 20px 30px'),
          const EdgeInsets.only(top: 10, right: 20, left: 20, bottom: 30),
        );
      });

      test('parses four values', () {
        expect(
          StyleParser.parseEdgeInsets('10px 20px 30px 40px'),
          const EdgeInsets.fromLTRB(10, 20, 30, 40),
        );
      });

      test('handles mixed units', () {
        expect(
          StyleParser.parseEdgeInsets('1rem 10px'),
          const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 10,
          ),
        );
      });

      test('handles invalid values', () {
        expect(StyleParser.parseEdgeInsets('invalid'), null);
        expect(StyleParser.parseEdgeInsets(''), null);
        expect(StyleParser.parseEdgeInsets('10px invalid'), null);
        expect(StyleParser.parseEdgeInsets('10px 20px invalid'), null);
      });
    });

    group('parseBorderRadius', () {
      test('parses pixel values', () {
        expect(
          StyleParser.parseBorderRadius('10px'),
          BorderRadius.circular(10),
        );
        expect(
          StyleParser.parseBorderRadius('0px'),
          BorderRadius.circular(0),
        );
      });

      test('parses rem values', () {
        expect(
          StyleParser.parseBorderRadius('1rem'),
          BorderRadius.circular(16),
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
        expect(
          StyleParser.parseBorderSide('1.5px solid rgba(0,0,0,0.5)'),
          const BorderSide(width: 1.5, color: Color(0x80000000)),
        );
      });

      test('handles dashed style', () {
        expect(
          StyleParser.parseBorderSide('1px dashed black'),
          const BorderSide(style: BorderStyle.none),
        );
      });

      test('handles invalid values', () {
        expect(StyleParser.parseBorderSide('invalid'), null);
        expect(StyleParser.parseBorderSide(''), null);
        expect(StyleParser.parseBorderSide('1px'), null);
        expect(StyleParser.parseBorderSide('solid black'), null);
      });
    });

    group('parseBoxShadow', () {
      test('parses single shadow', () {
        final shadows =
            StyleParser.parseBoxShadow('2px 4px 8px rgba(0,0,0,0.2)');
        expect(shadows?.length, 1);
        expect(shadows?.first.offset, const Offset(2, 4));
        expect(shadows?.first.blurRadius, 8);
        expect(shadows?.first.color, const Color(0x33000000));
      });

      test('parses multiple shadows', () {
        final shadows = StyleParser.parseBoxShadow(
          '2px 4px 8px rgba(0,0,0,0.2), -2px -4px 8px rgba(0,0,0,0.1)',
        );
        expect(shadows?.length, 2);
        expect(shadows?[0].offset, const Offset(2, 4));
        expect(shadows?[1].offset, const Offset(-2, -4));
      });

      test('parses shadow with spread', () {
        final shadows =
            StyleParser.parseBoxShadow('2px 4px 8px 4px rgba(0,0,0,0.2)');
        expect(shadows, isNotNull);
        expect(shadows?.first.spreadRadius, 4);
      });

      test('handles invalid values', () {
        expect(StyleParser.parseBoxShadow('invalid'), null);
        expect(StyleParser.parseBoxShadow(''), null);
        expect(StyleParser.parseBoxShadow('2px'), null);
        expect(StyleParser.parseBoxShadow('2px 4px'), null);
      });

      test('parseBoxShadow handles absolute units', () {
        // Test with explicit color
        final shadows =
            StyleParser.parseBoxShadow('2px 3px 4px rgba(0,0,0,0.2)');
        expect(shadows, isNotNull);
        expect(shadows!.length, equals(1));
        expect(shadows.first.offset.dx, equals(2));
        expect(shadows.first.offset.dy, equals(3));
        expect(shadows.first.blurRadius, equals(4));
        expect(shadows.first.color, const Color(0x33000000));

        // Test with spread radius
        final shadowsWithSpread =
            StyleParser.parseBoxShadow('2px 3px 4px 5px rgba(0,0,0,0.2)');
        expect(shadowsWithSpread, isNotNull);
        expect(shadowsWithSpread!.length, equals(1));
        expect(shadowsWithSpread.first.offset.dx, equals(2));
        expect(shadowsWithSpread.first.offset.dy, equals(3));
        expect(shadowsWithSpread.first.blurRadius, equals(4));
        expect(shadowsWithSpread.first.spreadRadius, equals(5));
        expect(shadowsWithSpread.first.color, const Color(0x33000000));

        // Test with multiple shadows
        final multipleShadows = StyleParser.parseBoxShadow(
          '2px 3px 4px rgba(0,0,0,0.2), 4px 6px 8px rgba(0,0,0,0.1)',
        );
        expect(multipleShadows, isNotNull);
        expect(multipleShadows!.length, equals(2));
        expect(multipleShadows[0].offset.dx, equals(2));
        expect(multipleShadows[0].offset.dy, equals(3));
        expect(multipleShadows[0].blurRadius, equals(4));
        expect(multipleShadows[0].color, const Color(0x33000000));
        expect(multipleShadows[1].offset.dx, equals(4));
        expect(multipleShadows[1].offset.dy, equals(6));
        expect(multipleShadows[1].blurRadius, equals(8));
        expect(multipleShadows[1].color, const Color(0x1A000000));

        // Test with rem units
        final remShadows =
            StyleParser.parseBoxShadow('1rem 1.5rem 2rem rgba(0,0,0,0.2)');
        expect(remShadows, isNotNull);
        expect(remShadows!.length, equals(1));
        expect(remShadows.first.offset.dx, equals(16)); // 1rem = 16px
        expect(remShadows.first.offset.dy, equals(24)); // 1.5rem = 24px
        expect(remShadows.first.blurRadius, equals(32)); // 2rem = 32px
        expect(remShadows.first.color, const Color(0x33000000));
      });

      test('parseBoxShadow returns null for relative units', () {
        expect(
          StyleParser.parseBoxShadow('10% 10% 10% rgba(0,0,0,0.2)'),
          isNull,
        );
        expect(
          StyleParser.parseBoxShadow('10vh 10vh 10vh rgba(0,0,0,0.2)'),
          isNull,
        );
        expect(
          StyleParser.parseBoxShadow('10vw 10vw 10vw rgba(0,0,0,0.2)'),
          isNull,
        );
      });

      test('parseBoxShadow handles invalid values', () {
        expect(StyleParser.parseBoxShadow(''), isNull);
        expect(StyleParser.parseBoxShadow('invalid'), isNull);
        expect(StyleParser.parseBoxShadow('2px'), isNull);
        expect(StyleParser.parseBoxShadow('2px 3px'), isNull);
        expect(StyleParser.parseBoxShadow('2px 3px invalid'), isNull);
      });
    });

    group('parseTransform', () {
      test('parses translate', () {
        final transform = StyleParser.parseTransform('translate(10px, 20px)');
        expect(transform, isNotNull);
        final offset = transform!.getTranslation();
        expect(offset.x, 10);
        expect(offset.y, 20);
      });

      test('parses translate3d', () {
        final transform =
            StyleParser.parseTransform('translate(10px, 20px, 30px)');
        expect(transform, isNotNull);
        final offset = transform!.getTranslation();
        expect(offset.x, 10);
        expect(offset.y, 20);
        expect(offset.z, 30);
      });

      test('parses multiple transforms', () {
        final transform = StyleParser.parseTransform(
          'translate(10px, 20px) translate(5px, 10px)',
        );
        expect(transform, isNotNull);
        final offset = transform!.getTranslation();
        expect(offset.x, 15);
        expect(offset.y, 30);
      });

      test('handles invalid values', () {
        expect(StyleParser.parseTransform('invalid'), null);
        expect(StyleParser.parseTransform(''), null);
        expect(StyleParser.parseTransform('translate()'), null);
        expect(StyleParser.parseTransform('translate(invalid)'), null);
      });
    });
  });

  group('StyleParser - Size Value Parsing', () {
    test('parseSizeValue handles pixel values', () {
      final result = StyleParser.parseSizeValue('10px');
      expect(result, isNotNull);
      expect(result!.value, equals(10));
      expect(result.unit, equals(SizeUnit.px));
    });

    test('parseSizeValue handles percentage values', () {
      final result = StyleParser.parseSizeValue('50%');
      expect(result, isNotNull);
      expect(result!.value, equals(50));
      expect(result.unit, equals(SizeUnit.percentage));
    });

    test('parseSizeValue handles rem values', () {
      final result = StyleParser.parseSizeValue('2.5rem');
      expect(result, isNotNull);
      expect(result!.value, equals(2.5));
      expect(result.unit, equals(SizeUnit.rem));
    });

    test('parseSizeValue handles viewport height values', () {
      final result = StyleParser.parseSizeValue('75vh');
      expect(result, isNotNull);
      expect(result!.value, equals(75));
      expect(result.unit, equals(SizeUnit.vh));
    });

    test('parseSizeValue handles viewport width values', () {
      final result = StyleParser.parseSizeValue('25vw');
      expect(result, isNotNull);
      expect(result!.value, equals(25));
      expect(result.unit, equals(SizeUnit.vw));
    });

    test('parseSizeValue handles numbers without units as pixels', () {
      final result = StyleParser.parseSizeValue('42');
      expect(result, isNotNull);
      expect(result!.value, equals(42));
      expect(result.unit, equals(SizeUnit.px));
    });

    test('parseSizeValue handles invalid values', () {
      expect(StyleParser.parseSizeValue(''), isNull);
      expect(StyleParser.parseSizeValue('invalid'), isNull);
      expect(StyleParser.parseSizeValue('px'), isNull);
      expect(StyleParser.parseSizeValue('%'), isNull);
      expect(StyleParser.parseSizeValue('rem'), isNull);
    });

    test('parseSizeValue handles decimal values', () {
      final result = StyleParser.parseSizeValue('10.5px');
      expect(result, isNotNull);
      expect(result!.value, equals(10.5));
      expect(result.unit, equals(SizeUnit.px));
    });

    test('parseSizeValue handles whitespace', () {
      final result = StyleParser.parseSizeValue('  15.5px  ');
      expect(result, isNotNull);
      expect(result!.value, equals(15.5));
      expect(result.unit, equals(SizeUnit.px));
    });
  });

  group('SizeValue - Resolution', () {
    testWidgets('resolves different unit types correctly', (tester) async {
      const screenWidth = 800.0;
      const screenHeight = 600.0;
      const textScaleFactor = 1.2;

      late BuildContext capturedContext;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(screenWidth, screenHeight),
            textScaler: TextScaler.linear(textScaleFactor),
          ),
          child: Builder(
            builder: (context) {
              capturedContext = context;
              return Container();
            },
          ),
        ),
      );

      // Test pixel values
      const pixelSize = SizeValue(100, SizeUnit.px);
      expect(pixelSize.resolve(capturedContext), equals(100));

      // Test percentage values
      const percentageSize = SizeValue(50, SizeUnit.percentage);
      expect(
        percentageSize.resolve(capturedContext, parentSize: 200),
        equals(100),
      );
      expect(
        percentageSize.resolve(capturedContext, parentSize: 400),
        equals(200),
      );
      expect(
        percentageSize.resolve(capturedContext),
        equals(0),
      ); // No parent size

      // Test rem values
      const remSize = SizeValue(2, SizeUnit.rem);
      // Base size (16) * text scale factor (1.2) * rem value (2)
      expect(remSize.resolve(capturedContext), equals(38.4));

      // Test viewport height values
      const vhSize = SizeValue(50, SizeUnit.vh);
      expect(vhSize.resolve(capturedContext), equals(screenHeight * 0.5));

      // Test viewport width values
      const vwSize = SizeValue(50, SizeUnit.vw);
      expect(vwSize.resolve(capturedContext), equals(screenWidth * 0.5));

      // Test zero values
      const zeroSize = SizeValue(0, SizeUnit.percentage);
      expect(zeroSize.resolve(capturedContext, parentSize: 200), equals(0));

      // Test negative values
      const negativeSize = SizeValue(-10, SizeUnit.px);
      expect(negativeSize.resolve(capturedContext), equals(-10));
    });
  });

  group('StyleParser - Integration with SizeValue', () {
    test('parseSize handles absolute units', () {
      expect(StyleParser.parseSize('10px'), equals(10));
      expect(StyleParser.parseSize('2rem'), equals(32)); // 16 * 2
    });

    test('parseSize returns null for relative units', () {
      expect(StyleParser.parseSize('50%'), isNull);
      expect(StyleParser.parseSize('50vh'), isNull);
      expect(StyleParser.parseSize('50vw'), isNull);
    });

    test('parseBorderRadius handles absolute units', () {
      final radius = StyleParser.parseBorderRadius('10px');
      expect(radius, isNotNull);
      expect(radius!.topLeft.x, equals(10));
    });

    test('parseBorderRadius returns null for relative units', () {
      expect(StyleParser.parseBorderRadius('10%'), isNull);
      expect(StyleParser.parseBorderRadius('10vh'), isNull);
      expect(StyleParser.parseBorderRadius('10vw'), isNull);
    });

    test('parseBorder handles absolute units', () {
      final border = StyleParser.parseBorder('2px solid black');
      expect(border, isNotNull);
      expect(border!.top.width, equals(2));
    });

    test('parseBorder returns null for relative units', () {
      expect(StyleParser.parseBorder('10% solid black'), isNull);
      expect(StyleParser.parseBorder('10vh solid black'), isNull);
      expect(StyleParser.parseBorder('10vw solid black'), isNull);
    });

    test('parseBoxShadow handles absolute units', () {
      final shadows = StyleParser.parseBoxShadow('2px 3px 4px black');
      expect(shadows, isNotNull);
      expect(shadows!.length, equals(1));
      expect(shadows.first.offset.dx, equals(2));
      expect(shadows.first.offset.dy, equals(3));
      expect(shadows.first.blurRadius, equals(4));
    });

    test('parseBoxShadow returns null for relative units', () {
      expect(StyleParser.parseBoxShadow('10% 10% 10% black'), isNull);
      expect(StyleParser.parseBoxShadow('10vh 10vh 10vh black'), isNull);
      expect(StyleParser.parseBoxShadow('10vw 10vw 10vw black'), isNull);
    });
  });
}
