import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/tagflow.dart';

void main() {
  group('TagflowHtmlAdapter whitespace', () {
    String plainText(TagflowDocumentNode node) {
      final buffer = StringBuffer(node.text ?? '');
      for (final child in node.children) {
        buffer.write(plainText(child));
      }
      return buffer.toString();
    }

    TagflowDocumentNode first(String html) {
      return const TagflowHtmlAdapter().parse(html).children.single;
    }

    test('should keep one space between adjacent inline elements', () {
      final paragraph = first(
        '<p><strong>Strong</strong> <b>bold</b>\n<em>em</em></p>',
      );

      expect(plainText(paragraph), 'Strong bold em');
    });

    test('should collapse source newlines and indentation to one space', () {
      final list = first('''
<ul>
  <li>A longer item that wraps
      onto a second source line.</li>
</ul>''');

      expect(
        plainText(list.children.single),
        'A longer item that wraps onto a second source line.',
      );
    });

    test('should collapse spaces across inline element boundaries', () {
      final paragraph = first(
        '<p>Read <a href="https://a.dev"> docs </a> now</p>',
      );

      expect(plainText(paragraph), 'Read docs now');
    });

    test('should trim whitespace at the start and end of blocks', () {
      final item = first('''
<ul><li>
    Item with a nested list
    <ul><li> Nested </li></ul>
  </li></ul>''').children.single;

      expect(item.children.first.text, 'Item with a nested list');
      expect(plainText(item.children.last), 'Nested');
    });

    test('should keep whitespace inside pre as written', () {
      final code = first('''
<pre><code>void main() {
  if (ok) {
\tprint('a  b');
  }
}</code></pre>''');

      expect(code.kind, TagflowNodeKind.codeBlock);
      expect(code.text, "void main() {\n  if (ok) {\n\tprint('a  b');\n  }\n}");
    });

    test('should map br to a line break and trim spaces around it', () {
      final paragraph = first('<p>one <br> two</p>');

      expect(plainText(paragraph), 'one\ntwo');
      expect(paragraph.children[1].htmlTag, 'br');
    });

    test('should drop whitespace-only text between blocks', () {
      final document = const TagflowHtmlAdapter().parse(
        '<div>\n  <p>a</p>\n  <p>b</p>\n</div>',
      );
      final container = document.children.single;

      expect(container.children.map((node) => node.kind), [
        TagflowNodeKind.paragraph,
        TagflowNodeKind.paragraph,
      ]);
    });

    test('should keep unique ids after dropping whitespace nodes', () {
      final document = const TagflowHtmlAdapter().parse(
        '<p><b>a</b> <i>b</i> <u>c</u></p>',
      );
      final ids = <String>[];
      void collect(TagflowDocumentNode node) {
        ids.add(node.id);
        node.children.forEach(collect);
      }

      document.children.forEach(collect);

      expect(ids.toSet().length, ids.length);
    });

    test('should produce no text for whitespace-only input', () {
      final document = const TagflowHtmlAdapter().parse('  \n ');

      expect(document.children.map(plainText).join(), isEmpty);
    });
  });
}
