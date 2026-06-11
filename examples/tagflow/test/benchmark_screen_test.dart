import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow_example/benchmarks/benchmark_host.dart';
import 'package:tagflow_example/benchmarks/fixtures.dart';
import 'package:tagflow_example/screens/benchmark_screen.dart';

void main() {
  testWidgets('renders default benchmark fixture', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: BenchmarkScreen()));
    await tester.pump();

    expect(find.text('Benchmarks'), findsOneWidget);
    expect(find.text(defaultProfileBenchmarkFixtureId), findsWidgets);
    expect(find.text('Tagflow'), findsWidgets);
    expect(find.text('Renderer: Tagflow'), findsOneWidget);
    expect(find.byKey(BenchmarkHost.scrollKey), findsOneWidget);
    expect(find.byKey(BenchmarkHost.contentKey), findsOneWidget);
  });

  testWidgets('can switch benchmark fixtures', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: BenchmarkScreen()));
    await tester.pump();

    await tester.tap(find.text('table_dense'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Fixture: table_dense'), findsOneWidget);
  });
}
