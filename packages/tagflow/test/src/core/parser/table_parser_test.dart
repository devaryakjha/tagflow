import 'package:flutter_test/flutter_test.dart';
import 'package:html/parser.dart' as html;
import 'package:tagflow/tagflow.dart';

void main() {
  group('TableParser', () {
    const parser = TableParser();

    test('canHandle correctly identifies table elements', () {
      final tableNode = html.parse('<table></table>').body!.firstChild!;
      final divNode = html.parse('<div></div>').body!.firstChild!;

      expect(parser.canHandle(tableNode), true);
      expect(parser.canHandle(divNode), false);
    });

    test('parses basic table structure', () {
      final document = html.parse('''
        <table>
          <tr>
            <td>Cell 1</td>
            <td>Cell 2</td>
          </tr>
          <tr>
            <td>Cell 3</td>
            <td>Cell 4</td>
          </tr>
        </table>
      ''');

      final tableNode = document.body!.firstChild!;
      final table = parser.tryParse(tableNode, const TagflowParser());

      expect(table, isNotNull);
      expect(table!.rowCount, 2);
      expect(table.columnCount, 2);
      expect(table.rows.length, 2);
      expect(table.rows[0].children.length, 2);
      expect(table.rows[1].children.length, 2);
    });

    test('handles empty and invalid cells', () {
      final document = html.parse('''
        <table>
          <tr>
            <td></td>
            <td>Valid Cell</td>
          </tr>
          <tr>
            <td colspan="invalid">Cell</td>
            <td rowspan="invalid">Cell</td>
          </tr>
        </table>
      ''');

      final tableNode = document.body!.firstChild!;
      final table = parser.tryParse(tableNode, const TagflowParser());

      expect(table, isNotNull);
      expect(table!.rowCount, 2);
      expect(table.columnCount, 2);
      expect(table.rows[0].children[0].children, isEmpty);
      expect(table.rows[0].children[1].children[0].textContent, 'Valid Cell');
      expect(table.rows[1].children[0].children[0].textContent, 'Cell');
      expect(table.rows[1].children[1].children[0].textContent, 'Cell');
    });

    test('handles nested content in cells', () {
      final document = html.parse('''
        <table>
          <tr>
            <td><strong>Bold Text</strong></td>
            <td><p>Paragraph</p></td>
          </tr>
        </table>
      ''');

      final tableNode = document.body!.firstChild!;
      final table = parser.tryParse(tableNode, const TagflowParser());

      expect(table, isNotNull);
      expect(table!.rows[0].children[0].children[0].tag, 'strong');
      expect(table.rows[0].children[1].children[0].tag, 'p');
    });

    test('preserves table attributes', () {
      final document = html.parse('''
        <table class="styled" style="border: 1px solid black">
          <tr>
            <td>Cell</td>
          </tr>
        </table>
      ''');

      final tableNode = document.body!.firstChild!;
      final table = parser.tryParse(tableNode, const TagflowParser());

      expect(table, isNotNull);
      expect(table!['class'], 'styled');
      expect(table.style, 'border: 1px solid black');
    });
  });
}
