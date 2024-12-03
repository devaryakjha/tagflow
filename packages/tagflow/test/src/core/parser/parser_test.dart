// test/src/core/parser/parser_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/src/core/parser/parser.dart';

void main() {
  group('TagflowParser', () {
    late TagflowParser parser;

    setUp(() {
      parser = TagflowParser();
    });

    test('parses simple HTML correctly', () {
      const html =
          '<div><p>This is a paragraph</p><h1>This is a heading1</h1></div>';
      final result = parser.parse(html);

      expect(result.tag, 'div');
      expect(result.children.length, 2);

      final p = result.children[0];
      expect(p.tag, 'p');
      expect(p.children[0].textContent, 'This is a paragraph');

      final h1 = result.children[1];
      expect(h1.tag, 'h1');
      expect(h1.children[0].textContent, 'This is a heading1');
    });

    test('handles multiple consecutive self-closing tags correctly', () {
      const html = '<br /><img src="image.jpeg"/>';
      final result = parser.parse(html);

      // Multiple root elements should be wrapped in a div
      expect(
        result.tag,
        'div',
        reason: 'Multiple root elements should be wrapped in a div',
      );
      expect(result.children.length, 2);

      final span = result.children[0];
      expect(span.tag, 'br');
      expect(span.children, isEmpty);

      final img = result.children[1];
      expect(img.tag, 'img');
      expect(img.children, isEmpty);
    });

    test('handles single self-closing tag correctly', () {
      const html = '<img src="test.jpg"/>';
      final result = parser.parse(html);

      expect(result.tag, 'img');
      expect(result.children, isEmpty);
    });

    test('handles mixed content with self-closing tags', () {
      const html = '<div>Text<br/>More text<img src="test.jpg"/>Final</div>';
      final result = parser.parse(html);

      expect(result.tag, 'div');
      expect(result.children.length, 5);
      expect(result.children[0].textContent, 'Text');
      expect(result.children[1].tag, 'br');
      expect(result.children[2].textContent, 'More text');
      expect(result.children[3].tag, 'img');
      expect(result.children[4].textContent, 'Final');
    });

    test('handles empty text nodes correctly', () {
      const html = '<div>  <span />  </div>';
      final result = parser.parse(html);

      expect(result.tag, 'div');
      expect(result.children.length, 1); // Only the span, whitespace is trimmed
      expect(result.children[0].tag, 'span');
    });
  });
}
