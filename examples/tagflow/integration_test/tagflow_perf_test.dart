import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tagflow_example/benchmarks/benchmark_host.dart';
import 'package:tagflow_example/benchmarks/fixtures.dart';
import 'package:tagflow_example/benchmarks/renderer_registry.dart';
import 'package:tagflow_example/screens/benchmark_screen.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('scrolls a Tagflow benchmark fixture', (tester) async {
    // ignore: prefer_const_declarations
    final fixtureId = const String.fromEnvironment(
      'TAGFLOW_FIXTURE',
      defaultValue: defaultProfileBenchmarkFixtureId,
    );
    // ignore: prefer_const_declarations
    final rendererId = const String.fromEnvironment(
      'TAGFLOW_RENDERER',
      defaultValue: defaultBenchmarkRendererId,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BenchmarkScreen(
          fixtureId: fixtureId,
          rendererId: rendererId,
          showFixturePicker: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(BenchmarkHost.contentKey), findsOneWidget);

    await binding.watchPerformance(() async {
      await tester.fling(
        find.byKey(BenchmarkHost.scrollKey),
        const Offset(0, -1200),
        10000,
      );
      await tester.pumpAndSettle();
    }, reportKey: '${rendererId}_${fixtureId}_scroll');
  });
}
