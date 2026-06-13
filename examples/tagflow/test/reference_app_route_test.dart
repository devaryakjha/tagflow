import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow_example/screens/reference_app_route_screen.dart';
import 'package:tagflow_example/utils/router.dart';

void main() {
  testWidgets('home route opens the reference app route', (tester) async {
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Reference App Route'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Reference App Route'), findsOneWidget);

    await tester.tap(find.text('Reference App Route'));
    await tester.pumpAndSettle();

    expect(find.text('Revision: cms-rev-1'), findsOneWidget);
    expect(find.text('Release readiness brief'), findsOneWidget);
    expect(find.text('Article detail'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('reference-route-image-placeholder')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('reference-route-unsupported-placeholder')),
      findsOneWidget,
    );
  });

  testWidgets('applies CMS patches and records app links', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ReferenceAppRouteScreen()));
    await tester.pump();

    await tester.tap(find.text('release checklist'));
    await tester.pump();

    expect(
      find.text('Last link: app://brief/release-checklist'),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey('reference-route-apply-update')),
    );
    await tester.pump();

    expect(find.text('Revision: cms-rev-2'), findsOneWidget);
    expect(
      find.text('CMS update received: the alert surface is now ready.'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Record the reviewer-visible route evidence in the package repo.',
      ),
      findsOneWidget,
    );
  });
}
