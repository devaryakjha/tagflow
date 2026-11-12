import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/tagflow.dart';

Future<void> _pumpHtml(WidgetTester tester, String html) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(child: Tagflow.html(html: html)),
      ),
    ),
  );
}

List<int> _rowLengths(WidgetTester tester) {
  final table = tester.widget<Table>(find.byType(Table));
  return [for (final row in table.children) row.children.length];
}

void main() {
  group('core table renderer', () {
    testWidgets('should render colspan padding as empty cells', (tester) async {
      await _pumpHtml(tester, '''
<table>
  <tr><th colspan="2">A</th></tr>
  <tr><td>1</td><td>2</td></tr>
</table>
''');

      expect(tester.takeException(), isNull);
      expect(find.text('Unsupported content'), findsNothing);
      expect(find.text('A'), findsOneWidget);
      expect(_rowLengths(tester), [2, 2]);
    });

    testWidgets('should render rowspan padding as empty cells', (tester) async {
      await _pumpHtml(tester, '''
<table>
  <tr><td rowspan="2">1</td><td>2</td></tr>
  <tr><td>3</td></tr>
</table>
''');

      expect(tester.takeException(), isNull);
      expect(find.text('Unsupported content'), findsNothing);
      expect(_rowLengths(tester), [2, 2]);

      final table = tester.widget<Table>(find.byType(Table));
      final secondRow = table.children[1].children;
      expect(secondRow.first, isA<SizedBox>());
    });

    testWidgets('should render mixed spans on a plain grid', (tester) async {
      await _pumpHtml(tester, '''
<table>
  <tr><th colspan="2">A</th></tr>
  <tr><td rowspan="2">1</td><td>2</td></tr>
  <tr><td>3</td></tr>
</table>
''');

      expect(tester.takeException(), isNull);
      expect(find.text('Unsupported content'), findsNothing);
      for (final text in ['A', '1', '2', '3']) {
        expect(find.text(text), findsOneWidget);
      }
      expect(_rowLengths(tester), [2, 2, 2]);
    });

    testWidgets('should pad ragged rows to the widest row', (tester) async {
      await _pumpHtml(tester, '''
<table>
  <tr><td>1</td><td>2</td><td>3</td></tr>
  <tr><td>4</td></tr>
</table>
''');

      expect(tester.takeException(), isNull);
      expect(find.text('Unsupported content'), findsNothing);
      expect(_rowLengths(tester), [3, 3]);
    });

    testWidgets('should pad ragged rows of a native document', (tester) async {
      final document = TagflowDocument(
        id: 'ragged',
        children: [
          TagflowDocumentNode.table(
            id: 't',
            children: [
              TagflowDocumentNode.tableRow(
                id: 'r0',
                children: [
                  for (final i in [0, 1])
                    TagflowDocumentNode.tableCell(
                      id: 'r0c$i',
                      children: [
                        TagflowDocumentNode.text(id: 'r0c${i}t', text: 'c$i'),
                      ],
                    ),
                ],
              ),
              TagflowDocumentNode.tableRow(
                id: 'r1',
                children: [
                  TagflowDocumentNode.tableCell(
                    id: 'r1c0',
                    children: [
                      TagflowDocumentNode.text(id: 'r1c0t', text: 'only'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: Tagflow.document(document))),
      );

      expect(tester.takeException(), isNull);
      expect(_rowLengths(tester), [2, 2]);
    });

    test('should not keep parser padding cells in the adapted document', () {
      final document = const TagflowHtmlAdapter().parse('''
<table>
  <tr><th colspan="2">A</th></tr>
  <tr><td rowspan="2">1</td><td>2</td></tr>
  <tr><td>3</td></tr>
</table>
''');

      final rows = document.children.single.children;
      expect([for (final row in rows) row.children.length], [1, 2, 1]);
      expect(
        rows.expand((row) => row.children).map((cell) => cell.kind),
        everyElement(TagflowNodeKind.tableCell),
      );
    });
  });
}
