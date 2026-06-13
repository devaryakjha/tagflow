import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow_example/benchmarks/benchmark_host.dart';
import 'package:tagflow_example/benchmarks/fixtures.dart';
import 'package:tagflow_example/benchmarks/renderer_registry.dart';
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
    expect(find.text('Renderer: Tagflow (compat)'), findsOneWidget);
    expect(find.byKey(BenchmarkHost.scrollKey), findsOneWidget);
    expect(find.byKey(BenchmarkHost.contentKey), findsOneWidget);
  });

  testWidgets('can switch benchmark fixtures', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: BenchmarkScreen()));
    await _pumpBenchmarkScreen(tester);

    final tableFixtureFinder = find.text('table_dense');
    await tester.ensureVisible(tableFixtureFinder);
    await tester.tap(tableFixtureFinder);
    await _pumpBenchmarkScreen(tester);

    expect(_segmentedButtons(tester).first.selected, {'table_dense'});
  });

  testWidgets('switching to markdown fixture picks a markdown renderer', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: BenchmarkScreen()));
    await _pumpBenchmarkScreen(tester);

    final markdownFixtureFinder = find.text('ai_answer_rich_md');
    await tester.ensureVisible(markdownFixtureFinder);
    await tester.tap(markdownFixtureFinder);
    await _pumpBenchmarkScreen(tester);

    final segmentedButtons = _segmentedButtons(tester);
    expect(segmentedButtons.first.selected, {'ai_answer_rich_md'});
    expect(segmentedButtons[1].selected, {'flutter_markdown_plus'});
  });

  testWidgets('switching to streaming fixture keeps an HTML renderer', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: BenchmarkScreen()));
    await _pumpBenchmarkScreen(tester);

    final streamingFixtureFinder = find.text('streaming_ai_chunks');
    await tester.ensureVisible(streamingFixtureFinder);
    await tester.tap(streamingFixtureFinder);
    await _pumpBenchmarkScreen(tester);

    final segmentedButtons = _segmentedButtons(tester);
    expect(segmentedButtons.first.selected, {'streaming_ai_chunks'});
    expect(segmentedButtons[1].selected, {defaultBenchmarkRendererId});
  });

  testWidgets('switching to patch fixture selects the patch renderer', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: BenchmarkScreen()));
    await _pumpBenchmarkScreen(tester);

    final patchFixtureFinder = find.text(semanticPatchBenchmarkFixtureId);
    await tester.ensureVisible(patchFixtureFinder);
    await tester.tap(patchFixtureFinder);
    await _pumpBenchmarkScreen(tester);

    final segmentedButtons = _segmentedButtons(tester);
    expect(segmentedButtons.first.selected, {semanticPatchBenchmarkFixtureId});
    expect(segmentedButtons[1].selected, {semanticPatchBenchmarkRendererId});
  });

  testWidgets('can switch benchmark renderers', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: BenchmarkScreen()));
    await _pumpBenchmarkScreen(tester);

    final rendererFinder = find.text('Flutter Widget from HTML (core)');
    await tester.ensureVisible(rendererFinder);
    await tester.tap(rendererFinder);
    await _pumpBenchmarkScreen(tester);

    expect(_segmentedButtons(tester)[1].selected, {'flutter_widget_from_html'});
  });

  testWidgets('applies explicit fixture and renderer ids', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: BenchmarkScreen(
          fixtureId: 'table_dense',
          rendererId: 'flutter_widget_from_html',
        ),
      ),
    );
    await _pumpBenchmarkScreen(tester);

    final segmentedButtons = _segmentedButtons(tester);
    expect(segmentedButtons.first.selected, {'table_dense'});
    expect(segmentedButtons[1].selected, {'flutter_widget_from_html'});
    expect(find.byKey(BenchmarkHost.contentKey), findsOneWidget);
  });
}
