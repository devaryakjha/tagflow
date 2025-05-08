import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/tagflow.dart';

void main() {
  group('TagflowTheme', () {
    test('creates article theme with correct defaults', () {
      final theme = TagflowTheme.article(
        baseTextStyle: const TextStyle(),
        headingTextStyle: const TextStyle(),
      );

      expect(theme.styles['p'], isNotNull);
      expect(theme.styles['h1'], isNotNull);
      expect(theme.styles['blockquote'], isNotNull);
    });

    test('resolves nested styles correctly', () {
      const theme = TagflowTheme.raw(
        defaultStyle: TagflowStyle.empty,
        styles: {
          'blockquote': TagflowStyle(backgroundColor: Colors.grey),
          'blockquote p': TagflowStyle(margin: EdgeInsets.zero),
        },
      );

      const blockquote = TagflowElement(tag: 'blockquote');
      final paragraph = const TagflowElement(tag: 'p').reparent(blockquote);

      final resolvedStyle = theme.resolveStyle(paragraph, inherit: true);
      expect(resolvedStyle.margin, EdgeInsets.zero);
    });

    test('merges inline styles correctly', () {
      const theme = TagflowTheme.raw(
        defaultStyle: TagflowStyle.empty,
        styles: {},
      );

      final element = TagflowElement(
        tag: 'div',
        attributes: LinkedHashMap.from({'style': 'color: red; padding: 10px'}),
      );

      final resolvedStyle = theme.resolveStyle(element, inherit: true);
      expect(resolvedStyle.padding, const EdgeInsets.all(10));
    });

    test('includes default named colors', () {
      final theme = TagflowTheme.fromTheme(ThemeData.light());

      expect(theme.namedColors['red'], Colors.red);
      expect(theme.namedColors['green'], Colors.green);
      expect(theme.namedColors['blue'], Colors.blue);
      expect(theme.namedColors['yellow'], Colors.yellow);
      expect(theme.namedColors['purple'], Colors.purple);
      expect(theme.namedColors['orange'], Colors.orange);
      expect(theme.namedColors['pink'], Colors.pink);
      expect(theme.namedColors['gray'], Colors.grey);
      expect(theme.namedColors['black'], Colors.black);
      expect(theme.namedColors['white'], Colors.white);
      expect(theme.namedColors['transparent'], Colors.transparent);
    });

    test('excludes default named colors when disabled', () {
      final theme = TagflowTheme.fromTheme(
        ThemeData.light(),
        useNamedDefaultColors: false,
      );

      expect(theme.namedColors['red'], isNull);
      expect(theme.namedColors['green'], isNull);
      expect(theme.namedColors['blue'], isNull);
    });

    test('resolves th and td styles correctly', () {
      final theme = TagflowTheme.fromTheme(ThemeData.light());

      // Test th style
      const thElement = TagflowElement(tag: 'th');
      final thStyle = theme.resolveStyle(thElement, inherit: true);
      expect(thStyle.textStyle?.fontWeight, FontWeight.bold);
      expect(thStyle.padding, isNotNull);

      // Test td style
      const tdElement = TagflowElement(tag: 'td');
      final tdStyle = theme.resolveStyle(tdElement, inherit: true);
      expect(tdStyle.padding, isNotNull);
    });

    test('respects inherit parameter in resolveStyle', () {
      const theme = TagflowTheme.raw(
        defaultStyle: TagflowStyle(
          textStyle: TextStyle(fontSize: 16),
          padding: EdgeInsets.all(8),
        ),
        styles: {
          'p': TagflowStyle(
            margin: EdgeInsets.all(16),
            textStyle: TextStyle(color: Colors.red),
          ),
        },
      );

      const element = TagflowElement(tag: 'p');

      // With inherit: true
      final inheritedStyle = theme.resolveStyle(element, inherit: true);
      expect(inheritedStyle.textStyle?.fontSize, 16);
      expect(inheritedStyle.textStyle?.color, Colors.red);
      expect(inheritedStyle.padding, const EdgeInsets.all(8));
      expect(inheritedStyle.margin, const EdgeInsets.all(16));

      // With inherit: false
      final nonInheritedStyle = theme.resolveStyle(element, inherit: false);
      expect(nonInheritedStyle.textStyle?.fontSize, isNull);
      expect(nonInheritedStyle.textStyle?.color, Colors.red);
      expect(nonInheritedStyle.padding, isNull);
      expect(nonInheritedStyle.margin, const EdgeInsets.all(16));
    });

    test('resolves pseudo-selector styles correctly', () {
      const theme = TagflowTheme.raw(
        defaultStyle: TagflowStyle.empty,
        styles: {
          'p': TagflowStyle(margin: EdgeInsets.all(8)),
          'p:first-child': TagflowStyle(margin: EdgeInsets.zero),
          'p:last-child': TagflowStyle(margin: EdgeInsets.zero),
        },
      );

      final parent =
          const TagflowElement(
            tag: 'div',
            children: [
              TagflowElement(tag: 'p', attributes: {'id': 'first'}),
              TagflowElement(tag: 'p', attributes: {'id': 'middle'}),
              TagflowElement(tag: 'p', attributes: {'id': 'last'}),
            ],
          ).reparent();

      final firstChild = parent.children.first;
      final middleChild = parent.children[1];
      final lastChild = parent.children.last;

      // First child should have no top margin
      final firstStyle = theme.resolveStyle(firstChild, inherit: true);
      expect(firstStyle.margin, EdgeInsets.zero);

      // Middle child should have all margins
      final middleStyle = theme.resolveStyle(middleChild, inherit: true);
      expect(middleStyle.margin, const EdgeInsets.all(8));

      // Last child should have no bottom margin
      final lastStyle = theme.resolveStyle(lastChild, inherit: true);
      expect(lastStyle.margin, EdgeInsets.zero);
    });
  });
}
