import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/tagflow.dart';
import 'package:tagflow_table/src/widgets/tagflow_table.dart';
import 'package:tagflow_table/tagflow_table.dart';

void main() {
  testWidgets('renders Markdown GFM tables through TagflowTable', (
    tester,
  ) async {
    final registry = TagflowComponentRegistry(
      extensions: [tagflowTableComponents()],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Tagflow.markdown(
          markdown: '| Name | Stars |\n|:--|--:|\n| Tagflow | 1 |',
          registry: registry,
        ),
      ),
    );

    expect(find.byType(TagflowTable), findsOneWidget);
    expect(find.byType(Table), findsNothing);
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Tagflow'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });
}
