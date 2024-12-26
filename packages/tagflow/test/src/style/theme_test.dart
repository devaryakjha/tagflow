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
        defaultStyle: TagflowStyle(),
        styles: {
          'blockquote': TagflowStyle(
            backgroundColor: Colors.grey,
          ),
          'blockquote p': TagflowStyle(
            margin: EdgeInsets.zero,
          ),
        },
      );

      const blockquote = TagflowElement(tag: 'blockquote');
      final paragraph = const TagflowElement(tag: 'p').reparent(blockquote);

      final resolvedStyle = theme.resolveStyle(paragraph);
      expect(resolvedStyle.margin, EdgeInsets.zero);
    });

    test('merges inline styles correctly', () {
      const theme = TagflowTheme.raw(
        defaultStyle: TagflowStyle(),
        styles: {},
      );

      final element = TagflowElement(
        tag: 'div',
        attributes: LinkedHashMap.from({
          'style': 'color: red; padding: 10px',
        }),
      );

      final resolvedStyle = theme.resolveStyle(element);
      expect(resolvedStyle.padding, const EdgeInsets.all(10));
    });
  });
}
