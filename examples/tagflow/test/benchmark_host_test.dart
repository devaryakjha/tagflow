import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow_example/benchmarks/benchmark_host.dart';
import 'package:tagflow_example/benchmarks/fixtures.dart';
import 'package:tagflow_example/benchmarks/renderer_registry.dart';

Future<void> _pumpHost(WidgetTester tester, BenchmarkHost host) async {
  await tester.pumpWidget(MaterialApp(home: host));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump(const Duration(milliseconds: 50));
}

void main() {
  testWidgets('loads the markdown benchmark fixture asset', (tester) async {
    await _pumpHost(
      tester,
      BenchmarkHost(
        fixture: profileBenchmarkFixtureById('ai_answer_rich_md'),
        renderer: benchmarkRendererById('flutter_markdown_plus'),
      ),
    );

    expect(find.byKey(BenchmarkHost.contentKey), findsOneWidget);
    expect(find.text('Fixture: ai_answer_rich_md'), findsOneWidget);
    expect(find.textContaining('Input: markdown,'), findsOneWidget);
  });
}
