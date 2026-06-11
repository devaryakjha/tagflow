import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow_example/screens/internal_app_validation_screen.dart';

void main() {
  testWidgets('renders internal app validation fixture', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: InternalAppValidationScreen()),
    );
    await tester.pump();

    expect(find.text('Internal App Validation'), findsOneWidget);
    expect(find.text('June margin update'), findsOneWidget);
    expect(find.text('Margin impact chart'), findsNothing);
    expect(
      find.byKey(const ValueKey('internal-validation-image-placeholder')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('internal-validation-unsupported-placeholder')),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.text('Controlled HTML probe'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();

    expect(find.text('Controlled HTML probe'), findsOneWidget);
    expect(find.text('safe policy link'), findsOneWidget);
  });

  testWidgets('records native document link taps', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: InternalAppValidationScreen()),
    );
    await tester.pump();

    await tester.tap(find.text('policy checklist'));
    await tester.pump();

    expect(
      find.text('Last link: app://policy/margin-checklist'),
      findsOneWidget,
    );
  });
}
