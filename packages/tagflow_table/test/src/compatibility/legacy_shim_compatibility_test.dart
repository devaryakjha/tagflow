// Exercises the deprecated legacy converter shim, which stays supported
// through 1.x.
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/tagflow.dart';
import 'package:tagflow_table/src/widgets/tagflow_table.dart';
import 'package:tagflow_table/tagflow_table.dart';

// Pins Tagflow.html(...) table output so deprecating the legacy converter shim
// does not change what existing users see, and checks that the semantic
// registry path renders through the same first-party table render object.

const _tableHtml = '''
<table border="1">
  <caption>Quarterly numbers</caption>
  <tr><th>Quarter</th><th style="text-align: right;">Revenue</th></tr>
  <tr><td>Q1</td><td style="text-align: right;">10</td></tr>
  <tr style="background-color: #f9f9f9;">
    <td rowspan="2">H2</td><td style="text-align: right;">20</td>
  </tr>
  <tr><td style="text-align: right;">30</td></tr>
  <tr><td colspan="2">Total: 60</td></tr>
</table>
''';

Future<void> _pump(WidgetTester tester, Widget tagflow) async {
  tester.view
    ..physicalSize = const Size(600, 600)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
        body: RepaintBoundary(
          key: const ValueKey('tagflow-output'),
          child: SingleChildScrollView(child: tagflow),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder get _output => find.byKey(const ValueKey('tagflow-output'));

void main() {
  group('tagflow_table legacy shim compatibility', () {
    testWidgets('legacy converter shim output is unchanged', (tester) async {
      await _pump(
        tester,
        const Tagflow.html(
          html: _tableHtml,
          converters: [TagflowTableConverter(), TagflowTableCellConverter()],
        ),
      );

      expect(find.byType(TagflowTable), findsOneWidget);
      expect(find.text('Total: 60'), findsOneWidget);
      await expectLater(
        _output,
        matchesGoldenFile('goldens/table_legacy_shim.png'),
      );
    });

    testWidgets('tagflowTableComponents renders the same HTML table', (
      tester,
    ) async {
      await _pump(
        tester,
        Tagflow.html(
          html: _tableHtml,
          registry: TagflowComponentRegistry(
            extensions: [tagflowTableComponents()],
          ),
        ),
      );

      expect(find.byType(TagflowTable), findsOneWidget);
      expect(find.text('Quarterly numbers'), findsOneWidget);
      expect(find.text('Total: 60'), findsOneWidget);
      await expectLater(
        _output,
        matchesGoldenFile('goldens/table_semantic_registry.png'),
      );
    });
  });
}
