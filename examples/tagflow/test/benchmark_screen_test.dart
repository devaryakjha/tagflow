import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow_example/benchmarks/benchmark_host.dart';
import 'package:tagflow_example/benchmarks/fixtures.dart';
import 'package:tagflow_example/screens/benchmark_screen.dart';

Future<void> _pumpBenchmarkScreen(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump(const Duration(milliseconds: 50));
}

List<SegmentedButton<String>> _segmentedButtons(WidgetTester tester) {
  return tester
      .widgetList<SegmentedButton<String>>(find.byType(SegmentedButton<String>))
      .toList();
}

void main() {
  testWidgets('renders default benchmark fixture', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: BenchmarkScreen()));
    await _pumpBenchmarkScreen(tester);

    expect(find.text('Benchmarks'), findsOneWidget);
    expect(find.text(defaultProfileBenchmarkFixtureId), findsWidgets);
    expect(find.text('Renderer: Tagflow'), findsOneWidget);
    expect(find.byKey(BenchmarkHost.scrollKey), findsOneWidget);
    expect(find.byKey(BenchmarkHost.contentKey), findsOneWidget);
  });

  testWidgets('can switch benchmark fixtures', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: BenchmarkScreen()));
    await _pumpBenchmarkScreen(tester);

    await tester.tap(find.text('table_dense'));
    await _pumpBenchmarkScreen(tester);

    expect(_segmentedButtons(tester).first.selected, {'table_dense'});
  });

  testWidgets('can switch benchmark renderers', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: BenchmarkScreen()));
    await _pumpBenchmarkScreen(tester);

    await tester.tap(find.text('Flutter HTML'));
    await _pumpBenchmarkScreen(tester);

    expect(_segmentedButtons(tester)[1].selected, {'flutter_html'});
  });

  testWidgets('applies explicit fixture and renderer ids', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: BenchmarkScreen(
          fixtureId: 'table_dense',
          rendererId: 'flutter_html',
        ),
      ),
    );
    await _pumpBenchmarkScreen(tester);

    final segmentedButtons = _segmentedButtons(tester);
    expect(segmentedButtons.first.selected, {'table_dense'});
    expect(segmentedButtons[1].selected, {'flutter_html'});
    expect(find.byKey(BenchmarkHost.contentKey), findsOneWidget);
  });
}
