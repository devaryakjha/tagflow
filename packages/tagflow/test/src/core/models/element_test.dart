import 'dart:collection';

import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/tagflow.dart';

void main() {
  group('TagflowElement', () {
    test('creates text node', () {
      final element = TagflowElement.text('Hello');

      expect(element.tag, '#text');
      expect(element.textContent, 'Hello');
      expect(element.isTextNode, true);
      expect(element.isEmpty, false);
    });

    test('handles attributes', () {
      final element = TagflowElement(
        tag: 'div',
        attributes: LinkedHashMap.from({
          'class': 'test',
          'style': 'color: red',
        }),
      );

      expect(element['class'], 'test');
      expect(element.style, 'color: red');
      expect(element.classList, ['test']);
    });

    test('manages parent-child relationships', () {
      const parent = TagflowElement(tag: 'div');

      final child = const TagflowElement(tag: 'p').reparent(parent);

      expect(child.parent, parent);
      expect(parent.children, [child]);
      expect(child.parentTag, 'div');
    });

    test('parses styles correctly', () {
      final element = TagflowElement(
        tag: 'div',
        attributes: LinkedHashMap.from({
          'style': 'color: red; padding: 10px',
        }),
      );

      expect(element.styles, {
        'color': 'red',
        'padding': '10px',
      });
    });

    test('handles class list operations', () {
      final element = TagflowElement(
        tag: 'div',
        attributes: LinkedHashMap.from({
          'class': 'one two  three',
        }),
      );

      expect(element.classList, ['one', 'two', 'three']);

      element.classList = ['four', 'five'];
      expect(element['class'], 'four five');
    });

    group('link operations', () {
      test('identifies anchor elements', () {
        final link = TagflowElement(
          tag: 'a',
          attributes: LinkedHashMap.from({'href': 'https://example.com'}),
        );
        const div = TagflowElement(tag: 'div');

        expect(link.isAnchor, true);
        expect(div.isAnchor, false);
        expect(link.href, 'https://example.com');
        expect(div.href, null);
      });

      test('handles nested link elements', () {
        final parent = TagflowElement(
          tag: 'a',
          attributes: LinkedHashMap.from({'href': 'https://example.com'}),
        );

        final child = const TagflowElement(tag: 'span').reparent(parent);

        expect(child.parentHref, 'https://example.com');
      });
    });

    group('size operations', () {
      test('parses width and height attributes', () {
        final element = TagflowElement(
          tag: 'div',
          attributes: LinkedHashMap.from({
            'width': '100px',
            'height': '50px',
          }),
        );

        expect(element.width, 100.0);
        expect(element.height, 50.0);
      });

      test('handles percentage values', () {
        final element = TagflowElement(
          tag: 'div',
          attributes: LinkedHashMap.from({
            'width': '50%',
            'height': '25%',
          }),
        );

        expect(element.width, 0.5);
        expect(element.height, 0.25);
      });

      test('handles invalid size values', () {
        final element = TagflowElement(
          tag: 'div',
          attributes: LinkedHashMap.from({
            'width': 'invalid',
            'height': '',
          }),
        );

        expect(element.width, null);
        expect(element.height, null);
      });
    });

    group('style operations', () {
      test('parses gap from styles', () {
        final element = TagflowElement(
          tag: 'div',
          attributes: LinkedHashMap.from({
            'style': 'gap: 10px',
          }),
        );

        expect(element.gap, 10.0);
      });
    });
  });
}
