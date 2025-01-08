import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow_table/tagflow_table.dart';

void main() {
  group('TagflowTableBorder', () {
    test('none returns empty border', () {
      final border = TagflowTableBorder.none;
      expect(border.left, BorderSide.none);
      expect(border.right, BorderSide.none);
      expect(border.top, BorderSide.none);
      expect(border.bottom, BorderSide.none);
      expect(border.horizontalInside, BorderSide.none);
      expect(border.verticalInside, BorderSide.none);
    });

    test('all returns uniform border', () {
      final border = TagflowTableBorder.all(
        color: Colors.red,
        width: 2,
      );
      expect(border.left.color, Colors.red);
      expect(border.left.width, 2);
      expect(border.right.color, Colors.red);
      expect(border.right.width, 2);
      expect(border.top.color, Colors.red);
      expect(border.top.width, 2);
      expect(border.bottom.color, Colors.red);
      expect(border.bottom.width, 2);
      expect(border.horizontalInside.color, Colors.red);
      expect(border.horizontalInside.width, 2);
      expect(border.verticalInside.color, Colors.red);
      expect(border.verticalInside.width, 2);
    });

    test('symmetric returns symmetric border', () {
      final border = TagflowTableBorder.symmetric(
        outside: const BorderSide(color: Colors.red, width: 2),
        inside: const BorderSide(color: Colors.blue),
      );
      expect(border.left.color, Colors.red);
      expect(border.left.width, 2);
      expect(border.right.color, Colors.red);
      expect(border.right.width, 2);
      expect(border.top.color, Colors.red);
      expect(border.top.width, 2);
      expect(border.bottom.color, Colors.red);
      expect(border.bottom.width, 2);
      expect(border.horizontalInside.color, Colors.blue);
      expect(border.horizontalInside.width, 1);
      expect(border.verticalInside.color, Colors.blue);
      expect(border.verticalInside.width, 1);
    });

    test('constructor sets individual borders', () {
      final border = TagflowTableBorder(
        left: const BorderSide(color: Colors.red),
        right: const BorderSide(color: Colors.green, width: 2),
        top: const BorderSide(color: Colors.blue, width: 3),
        bottom: const BorderSide(color: Colors.yellow, width: 4),
        horizontalInside: const BorderSide(color: Colors.purple, width: 5),
        verticalInside: const BorderSide(color: Colors.orange, width: 6),
      );
      expect(border.left.color, Colors.red);
      expect(border.left.width, 1);
      expect(border.right.color, Colors.green);
      expect(border.right.width, 2);
      expect(border.top.color, Colors.blue);
      expect(border.top.width, 3);
      expect(border.bottom.color, Colors.yellow);
      expect(border.bottom.width, 4);
      expect(border.horizontalInside.color, Colors.purple);
      expect(border.horizontalInside.width, 5);
      expect(border.verticalInside.color, Colors.orange);
      expect(border.verticalInside.width, 6);
    });

    test('lerp returns null for null arguments', () {
      expect(TagflowTableBorder.lerp(null, null, 0), null);
    });

    test('lerp returns border for null other argument', () {
      final border = TagflowTableBorder.all(
        color: Colors.red,
        width: 2,
      );
      expect(TagflowTableBorder.lerp(border, null, 0), border);
      expect(TagflowTableBorder.lerp(null, border, 1), border);
    });

    test('lerp interpolates between borders', () {
      final border1 = TagflowTableBorder.all(
        color: Colors.red,
        width: 2,
      );
      final border2 = TagflowTableBorder.all(
        color: Colors.blue,
        width: 4,
      );
      final interpolated = TagflowTableBorder.lerp(border1, border2, 0.5);
      expect(
        interpolated!.left.color,
        Color.lerp(Colors.red, Colors.blue, 0.5),
      );
      expect(interpolated.left.width, 3);
    });

    test('copyWith copies with new values', () {
      final border = TagflowTableBorder.all(
        color: Colors.red,
        width: 2,
      );
      final copied = border.copyWith(
        left: const BorderSide(color: Colors.blue, width: 4),
      );
      expect(copied.left.color, Colors.blue);
      expect(copied.left.width, 4);
      expect(copied.right.color, Colors.red);
      expect(copied.right.width, 2);
    });

    test('scale scales all borders', () {
      final border = TagflowTableBorder.all(
        color: Colors.red,
        width: 2,
      );
      final scaled = border.scale(2);
      expect(scaled.left.width, 4);
      expect(scaled.right.width, 4);
      expect(scaled.top.width, 4);
      expect(scaled.bottom.width, 4);
      expect(scaled.horizontalInside.width, 4);
      expect(scaled.verticalInside.width, 4);
    });
  });
}
