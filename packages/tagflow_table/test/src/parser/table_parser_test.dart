import 'package:flutter_test/flutter_test.dart';
import 'package:html/parser.dart' show parse;
import 'package:tagflow/tagflow.dart';

void main() {
  group('TableParser', () {
    late TableParser parser;
    late TagflowParser tagflowParser;

    setUp(() {
      parser = const TableParser();
      tagflowParser = const TagflowParser(
        parsers: [
          TableParser(),
          ElementParser(),
        ],
      );
    });

    test('canHandle returns true for table elements', () {
      final document = parse('<table></table>');
      final tableElement = document.querySelector('table')!;
      expect(parser.canHandle(tableElement), isTrue);
    });

    test('canHandle returns false for non-table elements', () {
      final document = parse('<div></div>');
      final divElement = document.querySelector('div')!;
      expect(parser.canHandle(divElement), isFalse);
    });

    test('parses basic table structure', () {
      final document = parse('''
        <table>
          <tr>
            <td>Cell 1</td>
            <td>Cell 2</td>
          </tr>
        </table>
      ''');
      final tableElement = document.querySelector('table')!;
      final result = parser.tryParse(tableElement, tagflowParser);

      expect(result, isNotNull);
      expect(result!.rowCount, 1);
      expect(result.columnCount, 2);
      expect(result.rows.length, 1);
      expect(result.rows[0].children.length, 2);
    });

    test('parses table with caption', () {
      final document = parse('''
        <table>
          <caption>Table Caption</caption>
          <tr>
            <td>Cell 1</td>
          </tr>
        </table>
      ''');
      final tableElement = document.querySelector('table')!;
      final result = parser.tryParse(tableElement, tagflowParser);

      expect(result, isNotNull);
      expect(result!.caption, isNotNull);
      expect(result.caption!.children[0].textContent, 'Table Caption');
    });

    test('handles colspan and rowspan', () {
      final document = parse('''
        <table>
          <tr>
            <td rowspan="2" colspan="2">Large Cell</td>
            <td>Cell 2</td>
          </tr>
          <tr>
            <td>Cell 3</td>
          </tr>
        </table>
      ''');
      final tableElement = document.querySelector('table')!;
      final result = parser.tryParse(tableElement, tagflowParser);

      expect(result, isNotNull);
      expect(result!.rowCount, 2);
      expect(result.columnCount, 3);

      final span = result.getSpan(0, 0);
      expect(span, isNotNull);
      expect(span!.rowSpan, 2);
      expect(span.colSpan, 2);
    });

    test('handles thead and tbody sections', () {
      final document = parse('''
        <table>
          <thead>
            <tr>
              <th>Header 1</th>
              <th>Header 2</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>Data 1</td>
              <td>Data 2</td>
            </tr>
          </tbody>
        </table>
      ''');
      final tableElement = document.querySelector('table')!;
      final result = parser.tryParse(tableElement, tagflowParser);

      expect(result, isNotNull);
      expect(result!.rowCount, 2);
      expect(result.columnCount, 2);
      expect(result.rows.length, 2);
    });

    test('handles empty cells', () {
      final document = parse('''
        <table>
          <tr>
            <td>Cell 1</td>
            <td></td>
            <td>Cell 3</td>
          </tr>
        </table>
      ''');
      final tableElement = document.querySelector('table')!;
      final result = parser.tryParse(tableElement, tagflowParser);

      expect(result, isNotNull);
      expect(result!.rowCount, 1);
      expect(result.columnCount, 3);
      expect(result.rows[0].children.length, 3);
      expect(result.rows[0].children[1].children.isEmpty, isTrue);
    });

    test('handles nested tables', () {
      final document = parse('''
        <table>
          <tr>
            <td>
              <table>
                <tr>
                  <td>Nested Cell</td>
                </tr>
              </table>
            </td>
          </tr>
        </table>
      ''');
      final tableElement = document.querySelector('table')!;
      final result = parser.tryParse(tableElement, tagflowParser);

      expect(result, isNotNull);
      expect(result!.rowCount, 1);
      expect(result.columnCount, 1);

      final nestedTable = result.rows[0].children[0].children
          .firstWhere((node) => node.tag == 'table');
      expect(nestedTable, isNotNull);
    });

    test('handles complex spanning patterns', () {
      final document = parse('''
        <table>
          <tr>
            <td rowspan="2" colspan="2">Large Cell</td>
            <td>Top Right</td>
          </tr>
          <tr>
            <td>Middle Right</td>
          </tr>
          <tr>
            <td colspan="3">Bottom Span</td>
          </tr>
        </table>
      ''');
      final tableElement = document.querySelector('table')!;
      final result = parser.tryParse(tableElement, tagflowParser);

      expect(result, isNotNull);
      expect(result!.rowCount, 3);
      expect(result.columnCount, 3);

      // Check spans
      final largeCell = result.getSpan(0, 0);
      expect(largeCell!.rowSpan, 2);
      expect(largeCell.colSpan, 2);

      final bottomSpan = result.getSpan(2, 0);
      expect(bottomSpan!.colSpan, 3);
    });

    test('handles invalid rowspan/colspan values', () {
      final document = parse('''
        <table>
          <tr>
            <td rowspan="invalid" colspan="abc">Cell</td>
          </tr>
        </table>
      ''');
      final tableElement = document.querySelector('table')!;
      final result = parser.tryParse(tableElement, tagflowParser);

      expect(result, isNotNull);
      expect(result!.rowCount, 1);
      expect(result.columnCount, 1);
      expect(result.rows[0].children.length, 1);

      // Should use default values for invalid spans
      final span = result.getSpan(0, 0);
      expect(span?.rowSpan ?? 1, 1); // Default value
      expect(span?.colSpan ?? 1, 1); // Default value
    });
  });
}
