import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow_example/screens/native_json_example.dart';

void main() {
  testWidgets('renders native JSON and applies patch envelope', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: NativeJsonExample()));
    await tester.pump();

    expect(find.text('Native JSON Transport'), findsOneWidget);
    expect(find.text('Revision: cms-rev-17'), findsOneWidget);
    expect(find.text('Risk controls update'), findsOneWidget);
    expect(
      find.text('Tap this risk desk note to inspect the native block.'),
      findsOneWidget,
    );
    expect(
      find.text('New order checks apply to equity and F&O baskets.'),
      findsOneWidget,
    );
    expect(find.text('Keep the legacy banner enabled.'), findsOneWidget);

    await tester.tap(
      find.text('Tap this risk desk note to inspect the native block.'),
    );
    await tester.pump();

    expect(
      find.text(
        'Selected block: Risk desk action | risk-update.callout | '
        'container | open-risk-desk',
      ),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('native-json-apply-patch')));
    await tester.pump();

    expect(find.text('Revision: cms-rev-18'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('native-json-selected-node')),
      findsNothing,
    );
    expect(
      find.text('Updated checks now apply before market and limit orders.'),
      findsOneWidget,
    );
    expect(
      find.text('This payload came from trusted app-controlled JSON.'),
      findsOneWidget,
    );
    expect(
      find.text('Notify support after the rollout flag is enabled.'),
      findsOneWidget,
    );
    expect(find.text('Keep the legacy banner enabled.'), findsNothing);

    await tester.tap(
      find.text('Notify support after the rollout flag is enabled.'),
    );
    await tester.pump();

    expect(
      find.text(
        'Selected block: Support action | risk-update.actions.notify | '
        'listItem | notify-support',
      ),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('native-json-reset')));
    await tester.pump();

    expect(find.text('Revision: cms-rev-17'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('native-json-selected-node')),
      findsNothing,
    );
    expect(find.text('Keep the legacy banner enabled.'), findsOneWidget);
  });
}
