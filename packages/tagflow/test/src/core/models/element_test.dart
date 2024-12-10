// test/src/core/models/element_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/src/core/models/element.dart';

void main() {
  group('TagflowElement', () {
    test('creates text node correctly', () {
      final element = TagflowElement.text('Hello');

      expect(element.tag, '#text');
      expect(element.textContent, 'Hello');
      expect(element.isTextNode, true);
      expect(element.children, isEmpty);
    });

    test('creates element node correctly', () {
      final element = TagflowElement(
        tag: 'div',
        children: [
          TagflowElement.text('Hello'),
        ],
      );

      expect(element.tag, 'div');
      expect(element.textContent, null);
      expect(element.isTextNode, false);
      expect(element.children.length, 1);
      expect(element.children.first.textContent, 'Hello');
    });

    test('toString formats correctly', () {
      final textElement = TagflowElement.text('Hello');
      final divElement = TagflowElement(tag: 'div');

      expect(textElement.toString(), contains('text: Hello'));
      expect(divElement.toString(), contains('tag: div'));
    });
  });
}
