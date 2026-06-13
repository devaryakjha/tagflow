import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow_example/utils/router.dart';

void main() {
  testWidgets('home route opens native JSON example with tappable blocks', (
    tester,
  ) async {
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('Tagflow Examples'), findsOneWidget);
    expect(find.text('Native JSON Transport'), findsOneWidget);

    await tester.tap(find.text('Native JSON Transport'));
    await tester.pumpAndSettle();

    expect(find.text('Revision: cms-rev-17'), findsOneWidget);
    expect(
      find.text('Tap this risk desk note to inspect the native block.'),
      findsOneWidget,
    );

    await tester.tap(
      find.text('Tap this risk desk note to inspect the native block.'),
    );
    await tester.pump();

    expect(
      find.text(
        'Selected block: Risk desk action | risk-update.callout | '
        'callout | open-risk-desk',
      ),
      findsOneWidget,
    );
  });
}
