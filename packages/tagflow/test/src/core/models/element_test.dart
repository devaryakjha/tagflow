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

    test('creates empty node', () {
      final element = TagflowElement.empty();

      expect(element.tag, '#empty');
      expect(element.textContent, null);
      expect(element.isTextNode, false);
      expect(element.isEmpty, true);
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
      final parent = TagflowElement(tag: 'div');
      final child = TagflowElement(tag: 'p');

      parent.addChild(child);

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
  });
}
