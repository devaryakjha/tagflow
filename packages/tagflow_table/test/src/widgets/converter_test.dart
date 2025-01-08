import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/tagflow.dart';
import 'package:tagflow_table/tagflow_table.dart';

void main() {
  group('TagflowTableConverter', () {
    late TagflowParser parser;
    late TagflowConverter converter;

    setUp(() {
      parser = const TagflowParser(
        parsers: [
          TableParser(),
          ElementParser(),
        ],
      );
      converter = TagflowConverter([
        TagflowTableConverter(),
        const TagflowTableCellConverter(),
      ]);
    });

    Widget buildTestWidget(TagflowNode node) {
      return MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => converter.convert(node, context),
          ),
        ),
      );
    }

    testWidgets('renders basic table structure', (tester) async {
      const html = '''
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
      ''';

      final node = parser.parse(html);
      await tester.pumpWidget(buildTestWidget(node));

      expect(find.byType(TagflowTable), findsOneWidget);
      expect(find.text('Cell 1'), findsOneWidget);
      expect(find.text('Cell 2'), findsOneWidget);
      expect(find.text('Cell 3'), findsOneWidget);
      expect(find.text('Cell 4'), findsOneWidget);
    });

    testWidgets('handles colspan and rowspan', (tester) async {
      const html = '''
        <table>
          <tr>
            <td rowspan="2">Spans 2 Rows</td>
            <td>Cell 2</td>
          </tr>
          <tr>
            <td>Cell 3</td>
          </tr>
          <tr>
            <td colspan="2">Spans 2 Columns</td>
          </tr>
        </table>
      ''';

      final node = parser.parse(html);
      await tester.pumpWidget(buildTestWidget(node));

      expect(find.byType(TagflowTable), findsOneWidget);
      expect(find.text('Spans 2 Rows'), findsOneWidget);
      expect(find.text('Cell 2'), findsOneWidget);
      expect(find.text('Cell 3'), findsOneWidget);
      expect(find.text('Spans 2 Columns'), findsOneWidget);
    });

    testWidgets('renders table with caption', (tester) async {
      const html = '''
        <table>
          <caption>Table Caption</caption>
          <tr>
            <td>Cell 1</td>
            <td>Cell 2</td>
          </tr>
        </table>
      ''';

      final node = parser.parse(html);
      await tester.pumpWidget(buildTestWidget(node));

      expect(find.byType(TagflowTable), findsOneWidget);
      expect(find.text('Table Caption'), findsOneWidget);
      expect(find.text('Cell 1'), findsOneWidget);
      expect(find.text('Cell 2'), findsOneWidget);
    });

    testWidgets('handles nested tables', (tester) async {
      const html = '''
        <table>
          <tr>
            <td>
              <table>
                <tr>
                  <td>Nested Cell 1</td>
                  <td>Nested Cell 2</td>
                </tr>
              </table>
            </td>
            <td>Outer Cell</td>
          </tr>
        </table>
      ''';

      final node = parser.parse(html);
      await tester.pumpWidget(buildTestWidget(node));

      expect(find.byType(TagflowTable), findsNWidgets(2));
      expect(find.text('Nested Cell 1'), findsOneWidget);
      expect(find.text('Nested Cell 2'), findsOneWidget);
      expect(find.text('Outer Cell'), findsOneWidget);
    });

    testWidgets('applies table styles', (tester) async {
      const html = '''
        <table style="border: 1px solid black; background-color: #f0f0f0;">
          <tr>
            <td style="padding: 8px; color: red;">Styled Cell</td>
          </tr>
        </table>
      ''';

      final node = parser.parse(html);
      await tester.pumpWidget(buildTestWidget(node));

      expect(find.byType(TagflowTable), findsOneWidget);
      expect(find.text('Styled Cell'), findsOneWidget);

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(TagflowTable),
              matching: find.byType(Container),
            )
            .first,
      );
      expect(container.decoration, isNotNull);
    });

    testWidgets('handles empty cells', (tester) async {
      const html = '''
        <table>
          <tr>
            <td>Cell 1</td>
            <td></td>
            <td>Cell 3</td>
          </tr>
        </table>
      ''';

      final node = parser.parse(html);
      await tester.pumpWidget(buildTestWidget(node));

      expect(find.byType(TagflowTable), findsOneWidget);
      expect(find.text('Cell 1'), findsOneWidget);
      expect(find.text('Cell 3'), findsOneWidget);
    });

    testWidgets('handles thead and tbody sections', (tester) async {
      const html = '''
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
      ''';

      final node = parser.parse(html);
      await tester.pumpWidget(buildTestWidget(node));

      expect(find.byType(TagflowTable), findsOneWidget);
      expect(find.text('Header 1'), findsOneWidget);
      expect(find.text('Header 2'), findsOneWidget);
      expect(find.text('Data 1'), findsOneWidget);
      expect(find.text('Data 2'), findsOneWidget);
    });

    testWidgets('handles complex spanning patterns', (tester) async {
      const html = '''
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
      ''';

      final node = parser.parse(html);
      await tester.pumpWidget(buildTestWidget(node));

      expect(find.byType(TagflowTable), findsOneWidget);
      expect(find.text('Large Cell'), findsOneWidget);
      expect(find.text('Top Right'), findsOneWidget);
      expect(find.text('Middle Right'), findsOneWidget);
      expect(find.text('Bottom Span'), findsOneWidget);
    });
  });
}
