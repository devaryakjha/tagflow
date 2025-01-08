import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/tagflow.dart';

void main() {
  group('StyleExtension', () {
    test('hasBorder returns true when border is set', () {
      final style = TagflowStyle(
        border: Border.all(),
      );
      expect(style.hasBorder, isTrue);
    });

    test('hasBorder returns true when individual borders are set', () {
      const style = TagflowStyle(
        borderLeft: BorderSide(),
      );
      expect(style.hasBorder, isTrue);

      const style2 = TagflowStyle(
        borderRight: BorderSide(),
      );
      expect(style2.hasBorder, isTrue);

      const style3 = TagflowStyle(
        borderTop: BorderSide(),
      );
      expect(style3.hasBorder, isTrue);

      const style4 = TagflowStyle(
        borderBottom: BorderSide(),
      );
      expect(style4.hasBorder, isTrue);
    });

    test('hasBorder returns false when no borders are set', () {
      const style = TagflowStyle();
      expect(style.hasBorder, isFalse);
    });

    test('effectiveBorder combines individual borders', () {
      const style = TagflowStyle(
        borderLeft: BorderSide(),
        borderRight: BorderSide(width: 2),
        borderTop: BorderSide(width: 3),
        borderBottom: BorderSide(width: 4),
      );
      final border = style.effectiveBorder;
      expect(border, isNotNull);
      expect(border!.left.width, 1);
      expect(border.right.width, 2);
      expect(border.top.width, 3);
      expect(border.bottom.width, 4);
    });

    test('effectiveBorder returns null when no borders are set', () {
      const style = TagflowStyle();
      expect(style.effectiveBorder, isNull);
    });

    test('hasBoxDecoration returns true when decoration properties are set',
        () {
      const style = TagflowStyle(
        backgroundColor: Colors.red,
      );
      expect(style.hasBoxDecoration, isTrue);

      final style2 = TagflowStyle(
        borderRadius: BorderRadius.circular(8),
      );
      expect(style2.hasBoxDecoration, isTrue);

      final style3 = TagflowStyle(
        border: Border.all(),
      );
      expect(style3.hasBoxDecoration, isTrue);

      const style4 = TagflowStyle(
        boxShadow: [BoxShadow(blurRadius: 4)],
      );
      expect(style4.hasBoxDecoration, isTrue);
    });

    test('hasBoxDecoration returns false when no decoration properties are set',
        () {
      const style = TagflowStyle();
      expect(style.hasBoxDecoration, isFalse);
    });

    test('toBoxDecoration returns null when no decoration properties are set',
        () {
      const style = TagflowStyle();
      expect(style.toBoxDecoration(), isNull);
    });

    test('toBoxDecoration includes all decoration properties', () {
      final style = TagflowStyle(
        backgroundColor: Colors.red,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(),
        boxShadow: const [BoxShadow(blurRadius: 4)],
      );
      final decoration = style.toBoxDecoration();
      expect(decoration, isNotNull);
      expect(decoration!.color, Colors.red);
      expect(decoration.borderRadius, BorderRadius.circular(8));
      expect(decoration.border, isNotNull);
      expect(decoration.boxShadow, isNotNull);
    });

    test('textStyleWithColor handles null textStyle', () {
      const style = TagflowStyle(
        color: Colors.red,
      );
      final textStyle = style.textStyleWithColor;
      expect(textStyle, isNotNull);
      expect(textStyle!.color, Colors.red);
    });

    test('textStyleWithColor merges color with existing textStyle', () {
      const style = TagflowStyle(
        textStyle: TextStyle(fontSize: 16),
        color: Colors.red,
      );
      final textStyle = style.textStyleWithColor;
      expect(textStyle, isNotNull);
      expect(textStyle!.color, Colors.red);
      expect(textStyle.fontSize, 16);
    });
  });
}
