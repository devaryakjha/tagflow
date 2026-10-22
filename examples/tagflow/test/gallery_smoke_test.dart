import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow_example/utils/examples.dart';
import 'package:tagflow_example/utils/router.dart';
import 'package:tagflow_example/utils/theme_mode.dart';

Future<void> _pumpRoute(WidgetTester tester, String path) async {
  router.go(path);
  await tester.pumpWidget(
    ValueListenableBuilder(
      valueListenable: themeMode,
      builder: (context, mode, _) => MaterialApp.router(
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: mode,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  tearDown(() => themeMode.value = ThemeMode.light);

  group('gallery route', () {
    for (final example in allExamples) {
      testWidgets('should render ${example.path} without errors', (
        tester,
      ) async {
        // Tests have no network, so remote images fail to load. The image
        // widgets handle that themselves; every other error fails the test.
        final reportError = FlutterError.onError;
        FlutterError.onError = (details) {
          if (details.exception is NetworkImageLoadException) return;
          reportError?.call(details);
        };
        try {
          await _pumpRoute(tester, example.path);

          expect(find.byType(Scaffold), findsOneWidget);
          expect(find.byKey(const ValueKey('theme-mode-toggle')), findsWidgets);
        } finally {
          FlutterError.onError = reportError;
        }
      });
    }
  });

  testWidgets('should list every example under its section on home', (
    tester,
  ) async {
    await _pumpRoute(tester, '/');

    for (final section in ExampleSection.values) {
      await tester.scrollUntilVisible(
        find.text(section.label),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text(section.label), findsOneWidget);
    }
  });

  testWidgets('should switch the gallery to the dark theme', (tester) async {
    await _pumpRoute(tester, '/');
    BuildContext homeContext() => tester.element(find.text('Inputs'));

    expect(Theme.of(homeContext()).brightness, Brightness.light);

    await tester.tap(find.byKey(const ValueKey('theme-mode-toggle')));
    await tester.pumpAndSettle();

    expect(themeMode.value, ThemeMode.dark);
    expect(Theme.of(homeContext()).brightness, Brightness.dark);
  });
}
